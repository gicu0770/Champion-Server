local actions = {
  loginUpdate = 1,
  upgrade = 2,
  updateEnchantment = 3,
}

GOLDEN_ENCHANTMENTS_CONFIG = {
  {enchant = 1, maxLevel = 100, value = 10, baseCost = 20000, multiplierCost = 1.5}, -- Health
  {enchant = 2, maxLevel = 100, value = 20, baseCost = 20000, multiplierCost = 1.5}, -- Mana 5% max mana
  {enchant = 71, maxLevel = 100, value = 15, baseCost = 20000, multiplierCost = 1.5}, -- ES
  {enchant = 20, maxLevel = 100, value = 5, baseCost = 20000, multiplierCost = 1.5}, -- Damage
  {enchant = 291, maxLevel = 100, value = 0.4, baseCost = 20000, multiplierCost = 1.5}, -- Penetration
--  {enchant = 12, maxLevel = 100, value = 5, baseCost = 1000, multiplierCost = 1.5}, -- Elemental Damage
--  {enchant = 196, maxLevel = 100, value = 5, baseCost = 1000, multiplierCost = 1.5}, -- Duality Damage
  {enchant = 3, maxLevel = 100, value = 1, baseCost = 20000, multiplierCost = 1.5}, -- INT 4%
  {enchant = 4, maxLevel = 100, value = 1, baseCost = 20000, multiplierCost = 1.5}, -- DEX 4%
  {enchant = 5, maxLevel = 100, value = 1, baseCost = 20000, multiplierCost = 1.5}, -- STR 4%
  {enchant = 27, maxLevel = 100, value = 0.571, baseCost = 20000, multiplierCost = 1.5}, -- Movement Speed 7%
  {enchant = 29, maxLevel = 100, value = 0.25, baseCost = 20000, multiplierCost = 1.5}, -- Critical Chance 16%
  {enchant = 210, maxLevel = 100, value = 0.615, baseCost = 20000, multiplierCost = 1.5}, -- Ailements Chance 6.5%
  {enchant = 55, maxLevel = 100, value = 1.29, baseCost = 20000, multiplierCost = 1.5}, -- Attack Speed 3.1%
  {enchant = 17, maxLevel = 100, value = 1, baseCost = 20000, multiplierCost = 1.5}, -- Gold
  {enchant = 10, maxLevel = 100, value = 1, baseCost = 20000, multiplierCost = 1.5}, -- Exp
}

local enchantments_client = {}
for i = 1, #GOLDEN_ENCHANTMENTS_CONFIG do
  enchantments_client[i] = { GOLDEN_ENCHANTMENTS_CONFIG[i].enchant, GOLDEN_ENCHANTMENTS_CONFIG[i].value, GOLDEN_ENCHANTMENTS_CONFIG[i].maxLevel, GOLDEN_ENCHANTMENTS_CONFIG[i].baseCost, GOLDEN_ENCHANTMENTS_CONFIG[i].multiplierCost }
end

local LoginEvent = CreatureEvent("EnchantmentsAltarLogin")
function LoginEvent.onLogin(player)
  player:registerEvent("EnchantmentsAltarExtendedOpcode")
  player:applyAltarEnchantments()
  return true
end

function Player:applyAltarEnchantments()
  for i = 1, #GOLDEN_ENCHANTMENTS_CONFIG do
    local level = self:getStorageValue(PlayerStorage.EnchantmentsAltar + i)
    if level > 0 then
      local bonusId = GOLDEN_ENCHANTMENTS_CONFIG[i].enchant
      local value = GOLDEN_ENCHANTMENTS_CONFIG[i].value * level
      local uid = bonusId + 400000
      local attr = US_ENCHANTMENTS[bonusId]
      if attr and attr.condition then
        local condition = Condition(attr.condition)
        condition:setParameter(CONDITION_PARAM_SUBID, uid)
        condition:setParameter(attr.param, value)
        condition:setParameter(CONDITION_PARAM_TICKS, -1)
        condition:setParameter(CONDITION_PARAM_BUFF_SPELL, false)
        self:addCondition(condition)
      end
    end
  end
  self:setCollectionInfo()
end

function Player:reapplyAltarEnchantment(index)
  local level = self:getStorageValue(PlayerStorage.EnchantmentsAltar + index)
  if level > 0 then
    local bonusId = GOLDEN_ENCHANTMENTS_CONFIG[index].enchant
    local value = GOLDEN_ENCHANTMENTS_CONFIG[index].value * level
    local uid = bonusId + 400000
    local attr = US_ENCHANTMENTS[bonusId]
    if attr and attr.condition then
      local condition = Condition(attr.condition)
      condition:setParameter(CONDITION_PARAM_SUBID, uid)
      condition:setParameter(attr.param, value)
      condition:setParameter(CONDITION_PARAM_TICKS, -1)
      condition:setParameter(CONDITION_PARAM_BUFF_SPELL, false)
      self:addCondition(condition)
    end
  end
  self:setCollectionInfo()
end

local ExtendedEvent = CreatureEvent("EnchantmentsAltarExtendedOpcode")
function ExtendedEvent.onExtendedOpcode(player, opcode, buffer)
  if opcode ~= ExtendedOPCodes.CODE_ENCHANTMENTS then return false end
  local status, data = pcall(function() return json.decode(buffer) end)
  if not status then return false end

  if data[1] == actions.upgrade then
    if player:getStorageValue(PlayerStorage.endGame) < 0 then
      player:sendTooltipMessage("You need to defeat Voort!")
      return false
    end
  
    local index = data[2]
    local configEnchant = GOLDEN_ENCHANTMENTS_CONFIG[index]
    if not configEnchant then 
      player:sendTooltipMessage("Invalid enchantment index.")
      return false 
    end

    local currentLevel = player:getStorageValue(PlayerStorage.EnchantmentsAltar + index)
    if currentLevel < 0 then currentLevel = 0 end
    currentLevel = currentLevel + 1
    if currentLevel > configEnchant.maxLevel then 
      player:sendTooltipMessage("This enchantment is already at maximum level.")
      return false
    end

    -- local cost = configEnchant.baseCost * (configEnchant.multiplierCost * (currentLevel))
    local cost = math.floor(configEnchant.baseCost * (1.096 ^ (currentLevel - 1))) -- configEnchant.baseCost * (1.2 ^ currentLevel)
    if not player:removeTotalMoney(cost) then
      player:sendTooltipMessage("You don't have enough money to upgrade this enchantment.")
      return false
    end

    player:setStorageValue(PlayerStorage.EnchantmentsAltar + index, currentLevel)
    player:reapplyAltarEnchantment(index)
    player:sendExtendedOpcode(ExtendedOPCodes.CODE_ENCHANTMENTS, json.encode({actions.updateEnchantment, index, currentLevel}))
  elseif data[1] == actions.loginUpdate then
    player:sendEnchantmentAltarLoginData()
  end
  return true
end

function Player:sendEnchantmentAltarLoginData()
  local levels = {}
  for i = 1, #GOLDEN_ENCHANTMENTS_CONFIG do
    levels[i] = self:getStorageValue(PlayerStorage.EnchantmentsAltar + i)
    if levels[i] < 0 then levels[i] = 0 end
  end
  self:sendExtendedOpcode(ExtendedOPCodes.CODE_ENCHANTMENTS, json.encode({actions.loginUpdate, enchantments_client, levels, self:getStorageValue(PlayerStorage.endGame) < 0}))
end

function Player:resetAltarEnchantments()
  for i = 1, #GOLDEN_ENCHANTMENTS_CONFIG do
    local bonusId = GOLDEN_ENCHANTMENTS_CONFIG[i].enchant
    local uid = bonusId + 400000

    -- usuń condition (buff)
    local attr = US_ENCHANTMENTS[bonusId]
    if attr and attr.condition then
      self:removeCondition(attr.condition, CONDITIONID_COMBAT, uid)
    end

    -- reset levela
    self:setStorageValue(PlayerStorage.EnchantmentsAltar + i, 0)
  end

  -- odśwież klienta
  self:sendEnchantmentAltarLoginData()
end

LoginEvent:type("login")
LoginEvent:register()
ExtendedEvent:type("extendedopcode")
ExtendedEvent:register()