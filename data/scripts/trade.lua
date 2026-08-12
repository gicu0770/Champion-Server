-- PlayerStorage.tradeStorage  TRADE WITH
-- PlayerStorage.tradeStorage+1  GOLD
-- PlayerStorage.tradeStorage+2  RUBBIES
-- PlayerStorage.tradeStorage+3  STATUS

local tradeId = 0

local LoginEvent = CreatureEvent("TradeLogin")
function LoginEvent.onLogin(player)
  player:registerEvent("TradeExtendedEvent")
  return true
end

local LogoutEvent = CreatureEvent("TradeLogout")
function LogoutEvent.onLogout(player)

  return true
end

local ExtendedEvent = CreatureEvent("TradeExtendedEvent")
function ExtendedEvent.onExtendedOpcode(player, opcode, buffer)
  if opcode == ExtendedOPCodes.CODE_TRADE then
    local status, json_data =
      pcall(
      function()
        return json.decode(buffer)
      end
    )
    if not status then
      return false
    end

    if json_data.action == "request" then
      local partner = Player(json_data.name)
      if not partner then
        return true
      end

      -- if partner:getStorageValue(87363) ~= 0 or player:getStorageValue(87363) ~= 0 then
      --   return true
      -- end

      player:setStorageValue(87363, partner:getId())
      partner:sendExtendedOpcode(ExtendedOPCodes.CODE_TRADE, json.encode({action = "request", name = player:getName()}))
    elseif json_data.action == "accept" then
      local partner = Player(json_data.name)
      if not partner then
        return true
      end

      if player:getStorageValue(87363) ~= partner:getId() then
        return true
      end

      partner:setStorageValue(87363, player:getId())

      player:setStorageValue(87363+3, 1)
      partner:setStorageValue(87363+3, 1)

      player:sendExtendedOpcode(ExtendedOPCodes.CODE_TRADE, json.encode({action = "start", name = partner:getName()}))
      partner:sendExtendedOpcode(ExtendedOPCodes.CODE_TRADE, json.encode({action = "start", name = player:getName()}))
    elseif json_data.action == "additem" then
      local partner = Player(player:getStorageValue(87363))
      if not partner then
        return true
      end

      local pos = Position(json_data.pos.x, json_data.pos.y, json_data.pos.z, json_data.pos.stackpos)
      local item = player:getItem(pos)

			if not player:checkItem(item) then
				return true
			end

      tradeId = tradeId + 1
      item:setCustomAttribute("tradeId", tradeId)
      item:moveTo(player:getTradeStorage(), 1, INDEX_WHEREEVER, FLAG_NOLIMIT)
      player:updateTrade()
      partner:updateTrade()
    end
  end
end

function Player:updateTrade()
  local partner = Player(self:getStorageValue(87363))
  if not partner then
    return true
  end
  
  local tradeStorage = self:getTradeStorage():getItems()
  local data = {}
  local tradeItems = {}
  for i = 1, #tradeStorage do
    local item = tradeStorage[i]
    tradeItems[i] = {
      id = item:getType():getClientId(),
      count = item:getCount(),
      uid = item:getCustomAttribute("tradeId"),
      rarity = item:getRarityId(),
    }
  end

  data.own = {
    items = tradeItems,
    gold = self:getStorageValue(87363+1),
    rubies = self:getStorageValue(87363+2),
    status = self:getStorageValue(87363+3),
  }

  tradeStorage = partner:getTradeStorage():getItems()
  tradeItems = {}
  for i = 1, #tradeStorage do
    local item = tradeStorage[i]
    tradeItems[i] = {
      id = item:getType():getClientId(),
      count = item:getCount(),
      uid = item:getCustomAttribute("tradeId"),
      rarity = item:getRarityId(),
    }
  end

  data.partner = {
    items = tradeItems,
    gold = partner:getStorageValue(87363+1),
    rubies = partner:getStorageValue(87363+2),
    status = partner:getStorageValue(87363+3),
  }

  self:sendExtendedOpcode(ExtendedOPCodes.CODE_TRADE, json.encode({action = "update", data = data}))
end

LoginEvent:type("login")
LoginEvent:register()
LogoutEvent:type("logout")
LogoutEvent:register()
ExtendedEvent:type("extendedopcode")
ExtendedEvent:register()