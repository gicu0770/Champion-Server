local downgrade_chance = 7
local UPGRADE_CRYSTAL = 26555
local PREFECT_UPGRADE_CRYSTAL = 0 -- 38496
local ANTI_DOWNGRADE_SCROLL = 38409
local MAX_UPGRADE_LEVEL = 15

local UPGRADE_DOWNGRADE_CHANCE = {
  [0] = 0,    -- 100%
  [1] = 0,    -- 100%
  [2] = 0,   -- 100%
  [3] = 5,   -- 95%
  [4] = 10,   -- 90%
  [5] = 20,   -- 80%
  [6] = 30,   -- 70%
  [7] = 40,   -- 60%
  [8] = 45,   -- 55%
  [9] = 50,   -- 50%
  [10] = 55,  -- +10 → +11 = 45%
  [11] = 65,  -- +11 → +12 = 35%
  [12] = 70,  -- +12 → +13 = 30%
  [13] = 85,  -- +13 → +14 = 15%
  [14] = 93,  -- +14 → +15 = 7%
  [15] = 95,  -- +14 → +15 = 5%
}

local LoginEvent = CreatureEvent("UpgradeLogin")
function LoginEvent.onLogin(player)
  player:registerEvent("UpgradeExtendedOpcode")
  return true
end

local ExtendedEvent = CreatureEvent("UpgradeExtendedOpcode")
function ExtendedEvent.onExtendedOpcode(player, opcode, buffer)
  if opcode ~= ExtendedOPCodes.CODE_UPGRADE_ITEMS then return false end
  local status, data = pcall(function() return json.decode(buffer) end)
  if not status then return false end

  if data[1] == 1 then
    player:upgradeItem(data[2], data[3], data[4])
  elseif data[1] == 2 then
    local item = Game.getRealUniqueItem(data[2])
    if item then
      local topParnet = item:getTopParent()
      local pid = 0
      if topParnet:isItem() then
        pid = topParnet:getCustomAttribute("pid") or 0
      end
      if topParnet ~= player then
        if pid ~= player:getId() then
          player:sendTextMessage(MESSAGE_STATUS_WARNING, "Something went wrong, try again.")
          return
        end
      end

      item:setCustomAttribute("locked", item:getCustomAttribute("locked") and (item:getCustomAttribute("locked") == 1 and 0 or 1) or 1)
      item:updateSelf()
      player:updateStore()
    end
  end

  return true
end

--[[
function calculatePowderCost(itemLevel, upgradeLevel, unique)
  if unique then
    local uniqueItem = US_UNIQUES[unique]
    if uniqueItem then
      local monsterLevel = (uniqueItem.monsterLevel or 1) + 10
      local chanceUnique = uniqueItem.chance or 100
      local powderValue = monsterLevel -- * ((100 - chanceUnique) / 10 + 1.0)
      powderCost = math.ceil((powderValue * (upgradeLevel)) * 0.05)
    end
  else
    local monsterLevel = (itemLevel or 1) + 10
    powderCost = math.ceil((monsterLevel * (upgradeLevel)) ^ 1.5)
  end

  return math.floor(powderCost)
end
--]]

function calculatePowderCost(itemLevel, upgradeLevel, unique)
  local powderCost = 0

  if unique then
    local uniqueItem = US_UNIQUES[unique]
    if uniqueItem then
      local monsterLevel = (uniqueItem.monsterLevel or 1) + 10
      local chanceUnique = uniqueItem.chance or 100
      local baseCost = monsterLevel * upgradeLevel * 0.05
      if itemLevel >= 100 and upgradeLevel > 10 then
        local extraLevels = upgradeLevel - 10
        baseCost = baseCost * (1.15 ^ extraLevels)
      end
      powderCost = math.ceil(baseCost)
    end
  else
    local monsterLevel = (itemLevel or 1) + 10
    local baseCost = (monsterLevel * upgradeLevel) ^ 1.5

    -- Dodatkowe zwiększenie kosztu dla itemLevel 100 i upgradeLevel powyżej 10
    if itemLevel >= 100 and upgradeLevel > 10 then
      local extraLevels = upgradeLevel - 10
      baseCost = baseCost * (1.15 ^ extraLevels)
      baseCost = baseCost * 6
    end

    powderCost = math.ceil(baseCost)
  end

  -- Podwojenie kosztu
  powderCost = powderCost * 2

  return math.floor(powderCost)
end

function Player:upgradeItem(uid, itemId, antiDowngradeScroll)
  local item = Game.getRealUniqueItem(uid)
  if not item then
    self:sendTextMessage(MESSAGE_STATUS_WARNING, "Something went wrong, try again.")
    return
  end

  local scroll = nil
  if antiDowngradeScroll then
    scroll = self:getItemById(ANTI_DOWNGRADE_SCROLL, true)
    if not scroll then
      self:sendTooltipMessage("You don't have an Scroll Of Protection.")
      return
    end
  end

  local crystal = self:getItemById(itemId, true)
  if not crystal then
    self:sendTooltipMessage("You don't have the required upgrade crystal.")
    return
  end

  local topParnet = item:getTopParent()
  local pid = 0
  if topParnet ~= self then
    if topParnet:isItem() then
      pid = topParnet:getCustomAttribute("pid") or 0
    end
    if pid ~= self:getId() then
      self:sendTextMessage(MESSAGE_STATUS_WARNING, "Something went wrong, try again.")
      return
    end
  end

  local returnText = canUseOrb(item)
  local parent = item:getParent()
  if parent and parent:isPlayer() then
    self:sendTextMessage(MESSAGE_STATUS_WARNING, "Dequip this item to continue.")
    self:getPosition():sendMagicEffect(3)
    return true
  end

  local slotPosition = item:getType():getSlotPosition() - SLOTP_LEFT - SLOTP_RIGHT
  if slotPosition == SLOTP_SUPPORT1_1 or slotPosition == SLOTP_SPELL1 then
    self:sendTextMessage(MESSAGE_STATUS_WARNING, "You can't upgrade this item!")
    self:getPosition():sendMagicEffect(3)
    return false
  end

  if returnText then
    self:sendTextMessage(MESSAGE_STATUS_WARNING, returnText)
    self:getPosition():sendMagicEffect(3)
    return true
  end

  local itemLevel = item:getItemLevel()
  local upgradeLevel = item:getUpgradeLevel() or 0
  if upgradeLevel >= MAX_UPGRADE_LEVEL then
    self:sendTooltipMessage("This item has reached the maximum upgrade level.")
    return
  end
  local unique = item:getUnique()

  local storage = unique and PlayerStorage.forgePowder2 or PlayerStorage.forgePowder1
  local powderCost = calculatePowderCost(itemLevel, upgradeLevel+1, unique)
  local twoHanded = item:getType():getSlotPosition() == 1072
  if twoHanded then
    powderCost = math.floor(powderCost * TWO_HANDED_MULTIPLIER)
  end
  local powderCount = self:getStorageValue(storage)
  if powderCount < powderCost then
    self:sendTooltipMessage("You need " .. powderCost .. " powder to upgrade this item.")
    return true
  end

  local cost = calculateGoldCost(itemLevel, upgradeLevel+1) 
  if twoHanded then
    cost = math.floor(cost * TWO_HANDED_MULTIPLIER)
  end
  if not self:removeTotalMoney(cost) then
    self:sendTooltipMessage("You need " .. cost .. " gold to upgrade this item.")
    return true
  end

  self:setStorageValue(storage, powderCount - powderCost)

  -- local chance = downgrade_chance * (upgradeLevel + 1)
  local chance = UPGRADE_DOWNGRADE_CHANCE[upgradeLevel + 1] or 0
  if itemId == PREFECT_UPGRADE_CRYSTAL then
    chance = chance - 10
  end
  if chance >= 100 then
    chance = 99
  elseif chance < 0 then
    chance = 0
  end

  local fail = false
  if chance >= math.random(1, 100) then
    upgradeLevel = upgradeLevel - 1
    if upgradeLevel < 0 then
      upgradeLevel = 0
    end
    item:setUpgradeLevel(upgradeLevel)
    fail = true
  else
    item:setUpgradeLevel(upgradeLevel + 1)
  end

  upgradeLevel = item:getUpgradeLevel()
  cost = calculateGoldCost(itemLevel, upgradeLevel+1)
  powderCost = calculatePowderCost(itemLevel, upgradeLevel+1, unique)
  local twoHanded = item:getType():getSlotPosition() == 1072
  if twoHanded then
    cost = math.floor(cost * TWO_HANDED_MULTIPLIER)
    powderCost = math.floor(powderCost * TWO_HANDED_MULTIPLIER)
  end

  if antiDowngradeScroll and scroll then
    scroll:remove(1)
    if fail then
      upgradeLevel = upgradeLevel + 1
      item:setUpgradeLevel(upgradeLevel)
    end
  end


  if crystal then
    crystal:remove(1)
  end

  chance = UPGRADE_DOWNGRADE_CHANCE[upgradeLevel + 1] or 0 -- downgrade_chance * (upgradeLevel + 1)
  if itemId == PREFECT_UPGRADE_CRYSTAL then
    chance = chance - 10
  end
  if chance >= 100 then
    chance = 99
  elseif chance < 0 then
    chance = 0
  end

  self:sendExtendedOpcode(ExtendedOPCodes.CODE_UPGRADE_ITEMS, json.encode({1, {uid, item:getType():getClientId(), chance, upgradeLevel, cost, powderCost, unique or false, {self:getStorageValue(PlayerStorage.forgePowder1), self:getStorageValue(PlayerStorage.forgePowder2)}, itemId, fail}}))
end

local OnUseAction = Action()
function OnUseAction.onUse(player, item, fromPosition, target, toPosition, isHotkey)
  if not target or not target:isItem() or item:getId() == 0 then return end
  local returnText = canUseOrb(target, toPosition)
  if returnText then
    player:sendTextMessage(MESSAGE_STATUS_WARNING, returnText)
    player:getPosition():sendMagicEffect(3)
    return true
  end

  local realUID = target:getRealUID()
  if not target:getType():isUpgradable() or not target:getType():canHaveItemLevel() or realUID == 0 then
    player:sendTextMessage(MESSAGE_STATUS_WARNING, "This item is not upgradable.")
    player:getPosition():sendMagicEffect(3)
    return false
  end

  local slotPosition = target:getType():getSlotPosition() - SLOTP_LEFT - SLOTP_RIGHT
  if slotPosition == SLOTP_SUPPORT1_1 or slotPosition == SLOTP_SPELL1 then
    player:sendTextMessage(MESSAGE_STATUS_WARNING, "This item is not upgradable.")
    player:getPosition():sendMagicEffect(3)
    return false
  end

  local unique = target:getUnique()
  local itemLevel = target:getItemLevel()
  local upgradeLevel = target:getUpgradeLevel() or 0
  if upgradeLevel >= MAX_UPGRADE_LEVEL then
    player:sendTextMessage(MESSAGE_STATUS_WARNING, "This item has reached the maximum upgrade level.")
    player:getPosition():sendMagicEffect(3)
    return true
  end
  local cost = calculateGoldCost(itemLevel, upgradeLevel+1)
  local powderCost = calculatePowderCost(itemLevel, upgradeLevel+1, unique)
  local twoHanded = target:getType():getSlotPosition() == 1072
  if twoHanded then
    cost = math.floor(cost * TWO_HANDED_MULTIPLIER)
    powderCost = math.floor(powderCost * TWO_HANDED_MULTIPLIER)
  end

  -- local chance = downgrade_chance * (upgradeLevel + 1)
  local chance = UPGRADE_DOWNGRADE_CHANCE[upgradeLevel + 1] or 0
  if item:getId() == PREFECT_UPGRADE_CRYSTAL then
    chance = chance - 10
  end
  if chance >= 100 then
    chance = 99
  elseif chance < 0 then
    chance = 0
  end

  player:sendExtendedOpcode(ExtendedOPCodes.CODE_UPGRADE_ITEMS, json.encode({1, {realUID, target:getType():getClientId(), chance, upgradeLevel, cost, powderCost, unique or false, {player:getStorageValue(PlayerStorage.forgePowder1), player:getStorageValue(PlayerStorage.forgePowder2)}, item:getId()}}))
	return true
end

function Player:addPowder(value, unique)
  if value <= 0 then
    return
  end

  local storage = unique and PlayerStorage.forgePowder2 or PlayerStorage.forgePowder1
  local itemId = unique and 28633 or 28635
  local currentPowder = self:getStorageValue(storage)

  currentPowder = currentPowder + value
  self:setStorageValue(storage, currentPowder)
  sendOrb(self, itemId, (unique and "Unique" or "Base") .. " Powder", unique and 5 or 1, value)
end

function Item:convertToPowder()
  local index
  local powder
  local rarity = self:getRarityId() or 0
  local unique = self:getUnique()
  local level = self:getCustomAttribute("level") or 0
  local isRelict = self:getCustomAttribute("relict")
  local upgradeLevel = self:getUpgradeLevel() or 0
  local quality = self:isQuality() or 0
  local lastCost = 0
  if upgradeLevel > 0 then
    lastCost = math.ceil(calculatePowderCost(self:getItemLevel(), upgradeLevel, unique) / 3)
  end
  local isCrystal = CRYSTAL_ITEMTYPES[self:getId()]
  if isCrystal then
    level = level + 30 * rarity
  end
  if isRelict then
    level = level + 50 * rarity
  end
  if unique then
    index = 2
    local uniqueItem = US_UNIQUES[unique]
    if uniqueItem then
      local monsterLevel = (uniqueItem.monsterLevel or 1) + 10 + level + quality
      local chanceUnique = uniqueItem.chance or 100
      local powderValue = (monsterLevel * ((100 - chanceUnique) / 10 + 1.0)) * 0.5
      powder = math.max(0, math.ceil(powderValue * 1)) + lastCost
    end
  else
    index = 1
    local monsterLevel = (self:getItemLevel() or 1) + 10 + math.max(100, level) + quality
    local rarityId = (self:getRarityId() or 0) * 2 + 1
    local powderValue = (monsterLevel * rarityId) * 0.33
    powder = math.max(0, math.ceil(powderValue * 1)) + lastCost
  end

  return index, powder
end

OnUseAction:id(UPGRADE_CRYSTAL, PREFECT_UPGRADE_CRYSTAL)
OnUseAction:register()
LoginEvent:type("login")
LoginEvent:register()
ExtendedEvent:type("extendedopcode")
ExtendedEvent:register()