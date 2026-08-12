local ACTION = {
  SEND = {
    INFO_HOUSE = 1,
    ENTER_HOUSE = 2,
    LEAVE_HOUSE = 3,
    PLAYERS_INSIDE = 4,
    PLAYER_KICKED = 5,
  },
  RECIVE = {
    BUY_HOUSE = 1,
    MANAGE_HOUSE = 2,
    GET_PLAYERS_INSIDE = 3,
    KICK_PLAYER = 4,
    SELL_HOUSE = 5,
  }
}

local HOUSE_DOCUMENT = 38570
local HOUSE_OWNERSHIP_DOCUMENT = 38570

local LoginEvent = CreatureEvent("HouseLogin")
function LoginEvent.onLogin(player)
  player:registerEvent("HouseExtendedOpcode")

  local tile = Tile(player:getPosition())
  if tile then
    local house = tile:getHouse()
    if house then
      player:sendExtendedOpcode(ExtendedOPCodes.CODE_HOUSE, json.encode({ACTION.SEND.ENTER_HOUSE, house:getId()}))
    end
  end

  return true
end

local ExtendedEvent = CreatureEvent("HouseExtendedOpcode")
function ExtendedEvent.onExtendedOpcode(player, opcode, buffer)
  if opcode ~= ExtendedOPCodes.CODE_HOUSE then return false end
  local status, data = pcall(function() return json.decode(buffer) end)
  if not status then return false end

  if data[1] == ACTION.RECIVE.BUY_HOUSE then
    player:buyHouse(data[2])
  elseif data[1] == ACTION.RECIVE.MANAGE_HOUSE then
    player:manageHouse(data[2][1], data[2][2], data[2][3])
  elseif data[1] == ACTION.RECIVE.GET_PLAYERS_INSIDE then
    player:getPlayersInsideHouse(data[2][1])
  elseif data[1] == ACTION.RECIVE.KICK_PLAYER then
    player:kickPlayerFromHouse(data[2][1], data[2][2])
  elseif data[1] == ACTION.RECIVE.SELL_HOUSE then
    player:sellHouse(data[2])
  end
end

function Player:sendHouseInfo(house)
  if not house then return end
  local owner = nil
  if house:getOwnerGuid() ~= 0 then
    owner = house:getOwnerName()
  end
  self:sendExtendedOpcode(ExtendedOPCodes.CODE_HOUSE, json.encode({ACTION.SEND.INFO_HOUSE, {house:getName(), house:getTileCount(), house:getTileCount() * configManager.getNumber(configKeys.HOUSE_PRICE), house:getId(), owner}}))
end

function Player:failMessageHouse(msg, house)
  self:sendTooltipMessage(msg)
  self:sendHouseInfo(house)
end

function Player:walkHouse(house, enter)
  if enter then
    self:sendExtendedOpcode(ExtendedOPCodes.CODE_HOUSE, json.encode({ACTION.SEND.ENTER_HOUSE, house:getId()}))
  else
    self:sendExtendedOpcode(ExtendedOPCodes.CODE_HOUSE, json.encode({ACTION.SEND.LEAVE_HOUSE}))
  end
end

function Player:buyHouse(houseId)
  local house = Game.getHouseById(houseId)
  if not house then return end

  if house:getOwnerGuid() > 0 then
    self:failMessageHouse("This house already has an owner.", house)
    return
  end

  if self:getHouse() == house then
    self:failMessageHouse("You are already the owner of a house.", house)
    return
  end

  if self:getHouse() then
    self:failMessageHouse("You already own a house.", house)
    return
  end

  local houseDocument = self:getItemById(HOUSE_DOCUMENT, true)
  if not houseDocument then
    self:failMessageHouse("You need a house document to buy a house, obtain one from the store or the market.", house)
    return
  end

  local housePrice = configManager.getNumber(configKeys.HOUSE_PRICE) * house:getTileCount()
  if not self:removeTotalMoney(housePrice) then
		self:failMessageHouse("You do not have enough money.", house)
		return
	end

  houseDocument:remove(1)
  house:setOwnerGuid(self:getGuid())
end

function Player:manageHouse(houseId, listEditId, playerName)
  local house = Game.getHouseById(houseId)
  if not house then return end

  if self:getHouse() ~= house then
    self:sendTooltipMessage("You are not the owner of this house.")
    return
  end

  if listEditId == 1 then
   if not house:canEditAccessList(GUEST_LIST, creature) then
    self:sendTooltipMessage("You do not have permission to edit the guest list.")
    return
   end

    self:setEditHouse(house, GUEST_LIST)
	  self:sendHouseWindow(house, GUEST_LIST)
  elseif listEditId == 2 then
    if not house:canEditAccessList(SUBOWNER_LIST, creature) then
    self:sendTooltipMessage("You do not have permission to edit the subowner list.")
    return
   end

    self:setEditHouse(house, SUBOWNER_LIST)
	  self:sendHouseWindow(house, SUBOWNER_LIST)
  elseif listEditId == 3 then
    local target = Player(playerName)
    if not target then 
      self:sendTooltipMessage("Player not found.")
      return
    end

    if not house:canKickPlayer(target, creature) then
      self:sendTooltipMessage("You do not have permission to kick this player.")
      return
    end
  end
end

function Player:getPlayersInsideHouse(houseId)
  local house = Game.getHouseById(houseId)
  if not house then return end

  if self:getHouse() ~= house then
    self:sendTooltipMessage("You are not the owner of this house.")
    return
  end

  local houseTiles = house:getTiles()
  local playersInside = {}
  for _, tile in pairs(houseTiles) do
    for _, creature in pairs(tile:getCreatures()) do
      if self ~= creature and creature:isPlayer() then
        table.insert(playersInside, creature:getName())
      end
    end
  end

  if #playersInside == 0 then
    self:sendTooltipMessage("There are no players inside your house.")
    return
  end

  self:sendExtendedOpcode(ExtendedOPCodes.CODE_HOUSE, json.encode({ACTION.SEND.PLAYERS_INSIDE, {houseId, playersInside}}))
end

function Player:kickPlayerFromHouse(houseId, name)
  local house = Game.getHouseById(houseId)
  if not house then return end

  if self:getHouse() ~= house then
    self:sendTooltipMessage("You are not the owner of this house.")
    return
  end

  local target = Player(name)
  if not target then
    self:sendTooltipMessage("Player not found.")
    self:getPlayersInsideHouse(houseId)
    return
  end

	if not house:kickPlayer(self, target) then
    self:getPlayersInsideHouse(houseId)
    self:sendTooltipMessage("Something went wrong while trying to kick the player.")
		return
	end

  self:sendExtendedOpcode(ExtendedOPCodes.CODE_HOUSE, json.encode({ACTION.SEND.PLAYER_KICKED, {name}}))
end

function Player:sellHouse(houseId)
  self:sendTooltipMessage("This feature is not available yet.")
  -- local house = Game.getHouseById(houseId)
  -- if not house then return end

  -- if self:getHouse() ~= house then
  --   self:failMessageHouse("You are not the owner of this house.", house)
  --   return
  -- end

  -- local houseDocument = Game.createItem(HOUSE_OWNERSHIP_DOCUMENT)
  -- if not houseDocument then
  --   self:sendTooltipMessage("Something went wrong while trying to sell the house.")
  --   return
  -- end

  -- houseDocument:setCustomAttribute("houseId", house:getId())
  -- houseDocument:setAttribute(ITEM_ATTRIBUTE_NAME, house:getName())
  -- self:addItemEx(houseDocument)
end


-- local houseOwnership = Action()
-- function houseOwnership.onUse(player, item, fromPosition, target, toPosition, isHotkey)
--   if item:getId() ~= HOUSE_OWNERSHIP_DOCUMENT then
--     return false
--   end

--   local houseId = item:getCustomAttribute("houseId")
--   if not houseId then
--     player:sendTooltipMessage("This document is corrupted.")
--     return true
--   end

--   local house = Game.getHouseById(houseId)
--   if not house then
--     player:sendTooltipMessage("This house does not exist anymore.")
--     return true
--   end

--   house:setOwnerGuid(player:getGuid())
--   player:sendTextMessage(MESSAGE_INFO_DESCR, "You are now the owner of the house '" .. house:getName() .. "'.")
--   player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
--   item:remove(1)
-- 	return true
-- end


-- houseOwnership:id(HOUSE_OWNERSHIP_DOCUMENT)
-- houseOwnership:register()

LoginEvent:type("login")
LoginEvent:register()
ExtendedEvent:type("extendedopcode")
ExtendedEvent:register()