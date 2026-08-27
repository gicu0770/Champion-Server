SPELL_CACHE = {}
POTION_CONFIG = {}
SPELLS = {}
POTIONS = {}
local healthCast = {}

-- Global table for tracking combat objects that need cleanup per player
-- This allows proper cleanup when players logout
SPELL_COMBATS_TO_REMOVE = {}

local LoginEvent = CreatureEvent("SpellsLogin")
function LoginEvent.onLogin(player)
  player:registerEvent("SpellsExtendedEvent")
  player:registerEvent("SpellHealthChangeEvent")
  player:registerEvent("SpellEndScriptOnEndMana")
  player:registerEvent("SpellMinusRegenHp")
  -- player:registerEvent("SpellsReconnect")
  for i = 1, 4 do
    local item = player:getSlotItem(11+i)
    if item then
      local name = item:getSpellName()
      local SPELL = SPELLS[name]
      if SPELL then
        if SPELL.disable then
          SPELL.disable(player, item)
        end
        local playerId = player:getId()
        local realUID = item:getRealUID()
        addEvent(function()
          local item = Game.getRealUniqueItem(realUID)
          if not item then return end
          item:applySupportSpells(SPELL:getConfig(), playerId)
        end, 200)
      end
    end
  end

  local playerId = player:getId()
  addEvent(function()
    local pla = Player(playerId)
    if not pla then return end
    for i = 1, 2 do
      local item = pla:getSlotItem(15+i)
      if item then
        local potion = POTION_CONFIG[item:getId()]
        if potion and potion.maxCharges then
          local charges = item:getCustomAttribute("charges") or potion.maxCharges
          pla:sendPotionCharges(i, charges, potion.maxCharges)
        end
      end
    end
    pla:updateMaxSpellLevelEver()
    pla:sendSpellUpgradeInfo()
  end, 300)

  return true
end

local ReconnectEvent = CreatureEvent("SpellsReconnect")
function ReconnectEvent.onReconnect(player)
  for i = 1, 4 do
    local item = player:getSlotItem(11+i)
    if item then
      local name = item:getSpellName()
      local SPELL = SPELLS[name]
      if SPELL and SPELL.isActive and SPELL.isActive(player) then
        player:sendExtendedOpcode(ExtendedOPCodes.CODE_CASTSPELL, json.encode({slot = i, enabled = true}))
      end
    end
  end
  return true
end

local LogoutEvent = CreatureEvent("SpellsLogout")
function LogoutEvent.onLogout(player)
  local playerId = player:getId()
  healthCast[playerId] = nil
  
  -- Clean up spell items
  for i = 1, 4 do
    local item = player:getSlotItem(11+i)
    if item then
      local name = item:getSpellName()
      local SPELL = SPELLS[name]
      if SPELL and SPELL.disable then
        SPELL.disable(player, item)
      end
      -- Clear spell cache for this item
      SPELL_CACHE[item:getRealUID()] = nil
    end
  end
  
  -- Clean up any accumulated combat objects for this player
  if SPELL_COMBATS_TO_REMOVE[playerId] then
    if SPELL_COMBATS_TO_REMOVE[playerId].combats then
      for i = 1, #SPELL_COMBATS_TO_REMOVE[playerId].combats do
        local combat = SPELL_COMBATS_TO_REMOVE[playerId].combats[i]
        if combat then
          pcall(function() combat:delete() end)
        end
      end
    end
    SPELL_COMBATS_TO_REMOVE[playerId] = nil
  end
  
  return true
end

function addHealthCast(id, value, force)
  healthCast[id] = healthCast[id] and healthCast[id] + value or value
  local player = Player(id)
  if not player or not player:isPlayer() then
    return
  end
  local amountToCast = player:getMaxHealth() * 0.001
  local amountToCastES = player:getMaxEnergyShield() * 0.001
  local castH = math.max(amountToCast, amountToCastES)
  if healthCast[id] <= (-castH) and not force then
    player:autoCastSpell(3)
    healthCast[id] = 0
  end
end

local ExtendedEvent = CreatureEvent("SpellsExtendedEvent")
function ExtendedEvent.onExtendedOpcode(player, opcode, buffer)
  local status, data = pcall(function()
    return json.decode(buffer)
  end)

  if not status then
    return false
  end

  if opcode == ExtendedOPCodes.CODE_CASTSPELL then
    if data and data.action == "getPotionCharges" then
      local slot = data.slot or 1
      local item = player:getSlotItem(15+slot)
      if item then
        local potion = POTION_CONFIG[item:getId()]
        if potion and potion.maxCharges then
          local charges = item:getCustomAttribute("charges") or potion.maxCharges
          player:sendPotionCharges(slot, charges, potion.maxCharges)
        end
      end
      return
    end

    if data and data.action == "requestSpellPoints" then
      player:updateMaxSpellLevelEver()
      player:sendSpellUpgradeInfo()
      return
    end

    if data and data.action == "upgradeSpell" then
      local slot = tonumber(data.slot)
      if slot then
        player:upgradeSpellSlot(slot)
      end
      return
    end

    if data[1] and data[1] > 4 then 
      player:usePotion(data[1]-4)
      return
    end

    local pos = nil
    if data[2] then
      pos = Position(data[2].x, data[2].y, data[2].z)
    end
    player:castSpell(data[1], pos)
    return
  end
end

function Player:sendMarketSpellTooltip(data, spellName)
  local item = Game.createItem(data.id)
  if not item then
    return false
  end

  item:setRealUID(0)
  item:setRarity(data.r or 0)
  item:setCustomAttribute("level", data.sl or 1)
  local SPELL = SPELLS[spellName]
  if not SPELL then
    item:remove()
    return false
  end

  local infoToSend = SPELL.getInfo(self, item)
  if not infoToSend then
    item:remove()
    return false
  end
  item:remove()

  if GLOBAL_SPELL_COOLDOWNS[SPELL.spellId] and GLOBAL_SPELL_COOLDOWNS[SPELL.spellId].tag then
    infoToSend.tag = GLOBAL_SPELL_COOLDOWNS[SPELL.spellId].tag
  end
  infoToSend.sx = data.sx or 0
  infoToSend.sl = data.sl or 1
  infoToSend.mx = data.mx or 100
  infoToSend.cs = data.cs or 0
  infoToSend.cm = data.cm or nil
  infoToSend.gp = data.gp or 0
  self:sendExtendedOpcode(106, json.encode({3, infoToSend}))
  return true
end

function Player:sendSpellTooltip(item, floor)
  if not item then
    return false
  end

  local name = item:getSpellName()
  local SPELL = SPELLS[name]
  if not SPELL then
    return false
  end

  local infoToSend = SPELL.getInfo(self, item)
  if not infoToSend then
    return false
  end
  if GLOBAL_SPELL_COOLDOWNS[SPELL.spellId] and GLOBAL_SPELL_COOLDOWNS[SPELL.spellId].tag then
    infoToSend.tag = GLOBAL_SPELL_COOLDOWNS[SPELL.spellId].tag
  end
  infoToSend.fl = floor
  infoToSend.sx = item:getCustomAttribute("exp") or 0
  infoToSend.sl = item:getCustomAttribute("level") or 1

  local tier = self:getDungeonTier()
  if tier < 0 then
    tier = 0
  end

  infoToSend.mx = 100 + (tier * 2)
  infoToSend.mx = math.min(infoToSend.mx, 500)

  infoToSend.cs = item:getCrystalSlots()
  if infoToSend.cs and infoToSend.cs > 0 then
    infoToSend.cm = item:getBonusFromCrystals() or nil
  end

  infoToSend.gp = item:calculateItemCost()

  self:sendExtendedOpcode(106, json.encode({3, infoToSend}))
  return true
end

SPELL_UPGRADE_MILESTONES = {
  1,   -- Level 1: Point #1 (Unlock Skill 1 or Skill 2)
  4,   -- Level 4: Point #2 (Unlock Skill 2 or Skill 1)
  8,   -- Level 8: Point #3 (Skill 1 or Skill 2 -> Lvl 2)
  12,  -- Level 12: Point #4 (Skill 1 or Skill 2 -> Lvl 2)
  15,  -- Level 15: Point #5 (Unlock Ultimate Lvl 1)
  18,  -- Level 18: Point #6 (Skill 1 or Skill 2 -> Lvl 3)
  22,  -- Level 22: Point #7 (Skill 1 or Skill 2 -> Lvl 3)
  26,  -- Level 26: Point #8 (Skill 1 or Skill 2 -> Lvl 4)
  30,  -- Level 30: Point #9 (Upgrade Ultimate Lvl 2)
  34,  -- Level 34: Point #10 (Skill 1 or Skill 2 -> Lvl 4)
  38,  -- Level 38: Point #11 (Skill 1 or Skill 2 -> Lvl 5 - MAX)
  42,  -- Level 42: Point #12 (Skill 1 or Skill 2 -> Lvl 5 - MAX)
  50,  -- Level 50: Point #13 (Upgrade Ultimate Lvl 3 - MAX)
}

function getEarnedSpellPoints(maxLevel)
  local points = 0
  for _, reqLevel in ipairs(SPELL_UPGRADE_MILESTONES) do
    if maxLevel >= reqLevel then
      points = points + 1
    end
  end
  return points
end

function getMaxAllowedSpellLevel(slot, maxLevel)
  if slot == 1 or slot == 2 then
    if maxLevel < 1 then return 0
    elseif maxLevel < 8 then return 1
    elseif maxLevel < 18 then return 2
    elseif maxLevel < 26 then return 3
    elseif maxLevel < 38 then return 4
    else return 5
    end
  elseif slot == 3 then
    if maxLevel < 15 then return 0
    elseif maxLevel < 30 then return 1
    elseif maxLevel < 50 then return 2
    else return 3
    end
  end
  return 0
end

function Player:getMaxSpellLevelEver()
  local currentStored = self:getStorageValue(PlayerStorage.maxSpellLevelReached)
  local playerLevel = self:getLevel()
  if currentStored < 1 then
    currentStored = math.max(1, playerLevel)
    self:setStorageValue(PlayerStorage.maxSpellLevelReached, currentStored)
  end
  if playerLevel > currentStored then
    currentStored = playerLevel
    self:setStorageValue(PlayerStorage.maxSpellLevelReached, currentStored)
  end
  return currentStored
end

function Player:updateMaxSpellLevelEver()
  local currentStored = self:getStorageValue(PlayerStorage.maxSpellLevelReached)
  local playerLevel = self:getLevel()
  if currentStored < 1 then
    self:setStorageValue(PlayerStorage.maxSpellLevelReached, math.max(1, playerLevel))
  elseif playerLevel > currentStored then
    self:setStorageValue(PlayerStorage.maxSpellLevelReached, playerLevel)
  end
end

function Player:getSpellUpgradeState()
  local maxLevel = self:getMaxSpellLevelEver()
  local totalEarned = getEarnedSpellPoints(maxLevel)
  local totalSpent = 0
  local spellsInfo = {}

  for slot = 1, 3 do
    local item = self:getSlotItem(11 + slot)
    local curLevel = item and item:getCustomAttribute("level") or 0
    totalSpent = totalSpent + curLevel
    local maxAllowed = getMaxAllowedSpellLevel(slot, maxLevel)
    local maxRank = (slot == 3) and 3 or 5
    spellsInfo[slot] = {
      level = curLevel,
      maxAllowed = maxAllowed,
      maxRank = maxRank,
      hasItem = (item ~= nil),
      canUpgrade = false
    }
  end

  local availablePoints = math.max(0, totalEarned - totalSpent)

  for slot = 1, 3 do
    local info = spellsInfo[slot]
    if availablePoints > 0 and info.hasItem and info.level < info.maxAllowed and info.level < info.maxRank then
      info.canUpgrade = true
    end
  end

  return {
    action = "spellPoints",
    points = availablePoints,
    maxLevel = maxLevel,
    spells = spellsInfo
  }
end

function Player:sendSpellUpgradeInfo()
  local state = self:getSpellUpgradeState()
  self:sendExtendedOpcode(ExtendedOPCodes.CODE_CASTSPELL, json.encode(state))
end

function Player:upgradeSpellSlot(slot)
  if slot < 1 or slot > 3 then
    return false
  end

  local item = self:getSlotItem(11 + slot)
  if not item then
    self:sendTextMessage(MESSAGE_STATUS_SMALL, "No spell rune equipped in this slot.")
    return false
  end

  local maxLevel = self:getMaxSpellLevelEver()
  local totalEarned = getEarnedSpellPoints(maxLevel)
  local totalSpent = 0
  local curLevels = {}
  for s = 1, 3 do
    local spItem = self:getSlotItem(11 + s)
    curLevels[s] = spItem and spItem:getCustomAttribute("level") or 0
    totalSpent = totalSpent + curLevels[s]
  end

  local availablePoints = math.max(0, totalEarned - totalSpent)
  if availablePoints <= 0 then
    self:sendTextMessage(MESSAGE_STATUS_SMALL, "You do not have any spell upgrade points.")
    return false
  end

  local currentLevel = curLevels[slot]
  local maxAllowed = getMaxAllowedSpellLevel(slot, maxLevel)
  local maxRank = (slot == 3) and 3 or 5

  if currentLevel >= maxAllowed or currentLevel >= maxRank then
    if slot == 3 and maxLevel < 15 then
      self:sendTextMessage(MESSAGE_STATUS_SMALL, "Ultimate spell unlocks at Level 15.")
    else
      self:sendTextMessage(MESSAGE_STATUS_SMALL, "You cannot upgrade this spell further at your level.")
    end
    return false
  end

  local newLevel = currentLevel + 1
  item:setCustomAttribute("level", newLevel)

  -- Invalidate cache so applySupportSpells recalculates with new level
  local realUID = item:getRealUID()
  if realUID and realUID ~= 0 then
    SPELL_CACHE[realUID] = nil
  end

  -- Update rarity if applicable
  local rarity = 0
  if newLevel >= 5 then
    rarity = 1
  end
  item:setRarity(rarity)
  item:updateSelf()

  -- Re-apply supports if SPELL exists
  local spellName = item:getSpellName()
  local SPELL = SPELLS[spellName]
  if SPELL then
    item:applySupportSpells(SPELL:getConfig(), self:getId())
  end

  -- In-game magic effect & text
  local pos = self:getPosition()
  pos:sendMagicEffect(237)
  self:sendTextMessage(MESSAGE_EVENT_ADVANCE, string.format("%s upgraded to Level %d!", spellName, newLevel))

  -- Notify client with spellUpgraded action + fresh state
  local state = self:getSpellUpgradeState()
  state.action = "spellUpgraded"
  state.upgradedSlot = slot
  state.newLevel = newLevel
  self:sendExtendedOpcode(ExtendedOPCodes.CODE_CASTSPELL, json.encode(state))

  -- Send updated tooltip info
  self:sendSpellTooltip(item, 0)
  return true
end

function Player:addGornShield()
  if self:getVocation():getId() == 2 then
    local maxHp = self:getMaxHealth()
    local shieldValue = math.ceil(25 + (maxHp * 0.05))

    if self:getMaxEnergyShield() < shieldValue then
      self:setMaxEnergyShield(shieldValue)
    end

    self:setEnergyShield(shieldValue)
    self:addBuff(GORN_SHIELD, 4000)
    self:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)

    local castTime = os.time()
    self:setStorageValue(PlayerStorage.gornShieldAmount, castTime)

    local cid = self:getId()
    addEvent(function(playerId, timestamp, amount)
      local p = Player(playerId)
      if p and p:getStorageValue(PlayerStorage.gornShieldAmount) == timestamp then
        local cur = p:getEnergyShield()
        if cur > 0 then
          p:setEnergyShield(math.max(0, cur - amount))
        end
        if p:getEnergyShield() <= 0 then
          p:setMaxEnergyShield(0)
        end
        p:removeBuff(GORN_SHIELD)
      end
    end, 4000, cid, castTime, shieldValue)
  end
end

function Player:sendKnockup(target, duration, height)
  if not target or not target:isCreature() then return end
  local targetId = target:getId()
  local dur = duration or 500
  local h = height or 24
  local data = {
    action = "knockup",
    targetId = targetId,
    duration = dur,
    height = h
  }
  self:sendExtendedOpcode(ExtendedOPCodes.CODE_CASTSPELL, json.encode(data))

  if target:isPlayer() and target:getId() ~= self:getId() then
    target:sendExtendedOpcode(ExtendedOPCodes.CODE_CASTSPELL, json.encode(data))
  end
end

function Player:castSpell(id, pos, force)
  local item = self:getSlotItem(11+id)
  if not item then
    return
  end

  local spellLevel = item:getCustomAttribute("level") or 0
  if spellLevel <= 0 then
    self:sendTextMessage(MESSAGE_STATUS_SMALL, "You must unlock this spell first.")
    return
  end

  local name = item:getSpellName()
  local SPELL = SPELLS[name]
  if not SPELL then
    return
  end

  SPELL.cast(self, item, force, pos)
  self:addGornShield()

  local pInfo = colleftInfo and colleftInfo[self:getId()]
  if pInfo and pInfo.attributesItems and pInfo.attributesItems[34] then
    local now = os.time()
    local lastCd = self:getStorageValue(PlayerStorage.spellbladeCooldown)
    if lastCd < 0 or now >= lastCd then
      self:setStorageValue(PlayerStorage.spellbladeProc, now + 10)
      self:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
    end
  end
end

function Player:usePotion(id)
  local item = self:getSlotItem(15+id)
  if not item then
    return
  end

  local name = item:getPotionName()
  local POTION = POTIONS[name]
  if not POTION then
    return
  end

  self:autoCastSpell(4)
  POTION.use(self, item, id)
end

local EndScriptOnEndMana = CreatureEvent("SpellEndScriptOnEndMana")
function EndScriptOnEndMana.onEndScriptsRegen(player, health)
  if player then
    for i = 1, 4 do
      local item = player:getSlotItem(11+i)
      if item then
        local name = item:getSpellName()
        local SPELL = SPELLS[name]
        if SPELL then
          local data = SPELL_CACHE[item:getRealUID()]
          if SPELL.overTimeMana and data and data.lifeTap == health then
            SPELL.disable(player, item)
          end
        end
      end
    end
  end
end


-- local MinusRegenHp = CreatureEvent("SpellMinusRegenHp")
-- function MinusRegenHp.onMinusRegenHP(player, value)
--   player:autoCastSpell(3)
-- end

function Player:autoCastSpell(cast)
  for i = 1, 4 do
    local item = self:getSlotItem(11+i)
    if item then
      local sup_config = SPELL_CACHE[item:getRealUID()]
      if sup_config and sup_config.cast then
        if sup_config.cast == cast then
          self:castSpell(i, nil, true)
        end
      end 
    end
  end
end

local HealthChangeEvent = CreatureEvent("SpellHealthChangeEvent")
function HealthChangeEvent.onHealthChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin, critical)
  if origin == ORIGIN_AUTOCAST then
    return primaryDamage, primaryType, secondaryDamage, secondaryType, origin
  end

  if attacker and attacker:isPlayer() and critical then
    attacker:autoCastSpell(1)
  end
  if creature and creature:isPlayer() then
    local dmg = primaryDamage + secondaryDamage
    if dmg < 0 then
      creature:autoCastSpell(3)
    end
  end

  return primaryDamage, primaryType, secondaryDamage, secondaryType, origin
end


-- MinusRegenHp:type("minusregenhp")
-- MinusRegenHp:register()
HealthChangeEvent:type("healthchange")
HealthChangeEvent:register()
EndScriptOnEndMana:type("endscriptsregen")
EndScriptOnEndMana:register()
LogoutEvent:type("logout")
LogoutEvent:register()
ReconnectEvent:type("reconnect")
ReconnectEvent:register()
LoginEvent:type("login")
LoginEvent:register()
ExtendedEvent:type("extendedopcode")
ExtendedEvent:register()