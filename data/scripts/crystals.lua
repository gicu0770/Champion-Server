local crystal_fee = {
  add = 2000,
  remove = 1500,
}

local LoginEvent = CreatureEvent("CrystalLoginEvent")
function LoginEvent.onLogin(player)
  player:registerEvent("CrystalExtendedEvent")

  local item = player:getSlotItem(CONST_SLOT_FORGE)
  player:onItemMoveCrystal(item, CONST_SLOT_FORGE, item ~= nil)
  return true
end

local ExtendedEvent = CreatureEvent("CrystalExtendedEvent")
function ExtendedEvent.onExtendedOpcode(player, opcode, buffer)
  local status, data = pcall(function()
    return json.decode(buffer)
  end)

  if not status then
    return false
  end

  if opcode ~= ExtendedOPCodes.CODE_CRYSTALS then
    return false
  end

  if data[1] == 1 then -- add crystal to item
    
    local pos = Position(data[2])
    local id = data[3]
    local item = player:getItem(pos)

    if item then
      player:addCrystalToItem(id, item, pos)
    end
  
    return true
  elseif data[1] == 2 then -- remove crystal
    local pos = Position(data[2])
    local id = data[3]

    player:removeCrystal(id, pos)
    return true
  elseif data[1] == 3 then -- move place
    local from = data[2]
    local to = data[3]
    player:changeCrystalPos(from, to)
    return true
  end
end

function Player:addCrystalToItem(id, item, pos)
  local crystalData = CRYSTAL_DATA_FROM_ID[item:getId()]
  if not crystalData then
    self:sendTooltipMessage("1This item is not a valid crystal.")
    return
  end

  local mainItem = self:getSlotItem(CONST_SLOT_FORGE)
  if not mainItem then
    self:sendTooltipMessage("No item found in the crystal slot.")
    return
  end

  if mainItem:isMirrored() then
    self:sendTooltipMessage("Sorry, this item is mirrored and can't be modified!")
    return
  end

  local slots = mainItem:getCrystalSlots()
  if not slots or slots <= 0 then
    self:sendTooltipMessage("Item don't have enough crystal slots")
    return
  end

  local clientId = item:getType():getClientId()
  local bonuses = mainItem:getBonusFromCrystals()
  local count = 0 
  if bonuses then
    for _, checkBonus in ipairs(bonuses) do
      if checkBonus then
        if checkBonus[3] == clientId then
          count = count + 1
          if count >= 2 then
            self:sendTooltipMessage("You can't equip more than two of the same crystal in one item.")
            return
          end
        end
      end
    end
  end

  if CRYSTAL_ITEMTYPES[item:getId()] then
    local correctType = false
    local itemType = formatItemType(mainItem:getType(), item)
    for _, iType in ipairs(CRYSTAL_ITEMTYPES[item:getId()]) do
      if itemType == iType then
        correctType = true
        break
      end
    end

    if not correctType then
      self:sendTooltipMessage("You can't equip this crystal on this item, wrong item type.")
      return
    end
  end

  if id == 0 then
    for i = 1, slots do
      local checkBonus = mainItem:getBonusFromCrystal(i)
      if not checkBonus then
        id = i
        break
      end
    end

    if id == 0 then
      self:sendTooltipMessage("Item don't have any empty crystal slot.")
      return
    end
  end

  local itemLevel = mainItem:getItemLevel() or 1
  if mainItem:getSpellName() ~= "" then
    itemLevel = mainItem:getCustomAttribute("level") or 1
  end
  local cost = math.ceil(crystal_fee.add * itemLevel)
  if not self:removeTotalMoney(cost) then
    self:sendTooltipMessage("You need " .. cost .. " gold to add crystal to your item.")
    return
  end

  local oldStone = mainItem:getBonusFromCrystal(id)
  if oldStone then
    self:removeCrystal(id, pos)
  end

  local attr = crystalData[1]
  local clientId = item:getType():getClientId()
  local rarity = item:getRarityId()
  local value = crystalData[2][rarity]
  local multiplier = mainItem:getType():getSlotPosition() == 1072 and TWO_HANDED_MULTIPLIER or 1.0
  if mainItem:getId() == 29714 then
    multiplier = 1.5
  end
  mainItem:setCrystalValue(id, attr.. "|" .. value * multiplier .. "|" .. clientId .. "|".. rarity)
  item:remove(1)

  local itemType = item:getType()
  local dataToSend = {
    itemType:getClientId(),
    rarity,
    {attr, value, clientId, rarity}
  }
  self:sendExtendedOpcode(ExtendedOPCodes.CODE_CRYSTALS, json.encode({3, id, dataToSend}))
end

function Player:removeCrystal(id, pos, force)
  local mainItem = self:getSlotItem(CONST_SLOT_FORGE)
  if not mainItem then
    self:sendTooltipMessage("No item found in the crystal slot.")
    return
  end

  if mainItem:isMirrored() then
    self:sendTooltipMessage("Sorry, this item is mirrored and can't be modified!")
    return
  end

  local bonusInfo = mainItem:getBonusFromCrystal(id)
  if not bonusInfo then
    self:sendTooltipMessage("No valid bonus found for the crystal, ( Item might be broken report this item. ).")
    return
  end

  local backpack
  if #pos == 0 then
    backpack = self:getSlotItem(CONST_SLOT_BACKPACK)
    if not backpack or backpack:getEmptySlots(true) <= 0 then
      self:sendTooltipMessage("You don't have enough space in backpack.")
      return false
    end
    backpack = self
  else
    backpack = self:getContainerByPos(pos)

    if not backpack or backpack:getEmptySlots(true) <= 0 then
      self:sendTooltipMessage("You don't have enough space in backpack.")
      return false
    end
  end

  local itemId = Game.getItemIdByClientId(bonusInfo[3])
  local item = Game.createItem(itemId, 1)
  if not item then
    self:sendTooltipMessage("Failed to add the item to the backpack, try again with other backpack.")
    item:remove(1)
    return
  end

  item:setRarity(bonusInfo[4])

  if not backpack:addItemEx(item) then
    self:sendTooltipMessage("Failed to add the item to the backpack, try again with other backpack.")
    item:remove(1)
    return
  end

  if not force then
    local itemLevel = mainItem:getItemLevel()
    if mainItem:getSpellName() ~= "" then
      itemLevel = mainItem:getCustomAttribute("level") or 1
    end
    local cost = math.ceil(crystal_fee.remove * itemLevel)
    if not self:removeTotalMoney(cost) then
      self:sendTooltipMessage("You need " .. cost .. " gold to add crystal to your item.")
      item:remove(1)
      return
    end
  end

  item:updateSelf()
  mainItem:setCrystalValue(id)
  self:sendExtendedOpcode(ExtendedOPCodes.CODE_CRYSTALS, json.encode({3, id}))
end

function Player:changeCrystalPos(from, to)
  local mainItem = self:getSlotItem(CONST_SLOT_FORGE)
  if not mainItem then
    self:sendTooltipMessage("No item found in the crystal slot.")
    return
  end

  if mainItem:isMirrored() then
    self:sendTooltipMessage("Sorry, this item is mirrored and can't be modified!")
    return
  end

  local bonusInfo = mainItem:getBonusFromCrystal(from)
  if not bonusInfo then
    self:sendTooltipMessage("No valid bonus found for the crystal, ( Item might be broken report this item. ).")
    return
  end

  local firstCrystal = CRYSTAL_DATA_FROM_ID[Game.getItemIdByClientId(bonusInfo[3])]
  if not firstCrystal then
    self:sendTooltipMessage("This item is not a valid crystal.")
    return
  end

  local multiplier = mainItem:getType():getSlotPosition() == 1072 and TWO_HANDED_MULTIPLIER or 1.0
  if mainItem:getId() == 29714 then
    multiplier = 1.5
  end
  local bonusInfo2 = mainItem:getBonusFromCrystal(to)
  if bonusInfo2 then
    local secondCrystal = CRYSTAL_DATA_FROM_ID[Game.getItemIdByClientId(bonusInfo2[3])]
    if not secondCrystal then
      self:sendTooltipMessage("This item is not a valid crystal.")
      return
    end

    local value2 = secondCrystal[2][bonusInfo[4]]
    if not value2 then
      self:sendTooltipMessage("Failed to move the crystal, try again.")
      return
    end
    mainItem:setCrystalValue(from, bonusInfo2[1].. "|" .. value2 * multiplier .. "|" .. bonusInfo2[3] .. "|".. bonusInfo2[4])
  else
    mainItem:setCrystalValue(from)
  end
  
  local value = firstCrystal[2][bonusInfo[4]]
  if not value then
    self:sendTooltipMessage("Failed to move the crystal, try again.")
    return
  end
  mainItem:setCrystalValue(to, bonusInfo[1].. "|" .. value * multiplier .. "|" .. bonusInfo[3] .. "|".. bonusInfo[4])

  local itemLevel = mainItem:getItemLevel() or 1
  if mainItem:getSpellName() ~= "" then
    itemLevel = mainItem:getCustomAttribute("level") or 1
  end

  local dataToSend = {
    itemLevel,
    mainItem:getCrystalSlots() or 0,
    mainItem:getBonusFromCrystals() or nil
  }
  self:sendExtendedOpcode(ExtendedOPCodes.CODE_CRYSTALS, json.encode({1, dataToSend}))
end

function Player:onItemMoveCrystal(item, slot, equip, fromPosition)
  if not item then
    return
  end

  local crystalData = CRYSTAL_DATA_FROM_ID[item:getId()]
  if crystalData then
    self:addCrystalToItem(0, item)
    return false
  end

  if not item:getType():isUpgradable() or not item:getType():canHaveItemLevel() or item:getRealUID() == 0 then
    self:sendTooltipMessage("Item cant be upgraded")
    return false
  end

  if not equip then
    -- self:sendExtendedOpcode(ExtendedOPCodes.CODE_CRYSTALS, json.encode({ 2 }))
    return true
  end

  local itemLevel = item:getItemLevel() or 1
  if item:getSpellName() ~= "" then
    itemLevel = item:getCustomAttribute("level") or 1
  end

  local dataToSend = {
    itemLevel,
    item:getCrystalSlots() or 0,
    item:getBonusFromCrystals() or nil
  }

  self:sendExtendedOpcode(ExtendedOPCodes.CODE_CRYSTALS, json.encode({1, dataToSend}))
  return true
end

local OnUseAction = Action()
function OnUseAction.onUse(player, item, fromPosition, _, _, _)
  local rarity = item:getRarityId()
  local count = item:getCount()
  local itemId = item:getId()
  if rarity < 1 or rarity > 3 then
    player:sendTooltipMessage("This item already has the highest rarity.")
    return false
  elseif count < 3 then
    player:sendTooltipMessage("You need at least 3 crystals to merge them.")
    return false
  end

  local crystalData = CRYSTAL_DATA_FROM_ID[itemId]
  if not crystalData then
    player:sendTooltipMessage("This item is not a valid crystal.")
    return false
  end

  local parent = item:getParent()
  if not parent then
    player:sendTooltipMessage("Failed to merge the crystals, try again.")
    return false
  end

  local newRarity = rarity + 1
  local rest = count % 3
  local newCount = math.floor(count / 3)

  local remove = true
  if rest > 0 then
    item:setCount(rest)
    remove = false
  end

  local newItem = Game.createItem(itemId, newCount)
  if not newItem then
    player:sendTooltipMessage("Failed to merge the crystals, try again.")
    item:setCount(count)
    return false
  end

  newItem:setRarity(newRarity)
  if not parent:addItemEx(newItem, INDEX_WHEREEVER, FLAG_NOLIMIT) then
    player:sendTooltipMessage("Failed to merge the crystals, try again.")
    newItem:remove()
    item:setCount(count)
    return false
  end

  if remove then
    item:remove()
  else
    item:updateSelf()
  end

  newItem:updateSelf()
  return true
end

for id, _ in pairs(CRYSTAL_DATA_FROM_ID) do
  OnUseAction:id(id)
end
OnUseAction:register()

LoginEvent:type("login")
LoginEvent:register()
ExtendedEvent:type("extendedopcode")
ExtendedEvent:register()
