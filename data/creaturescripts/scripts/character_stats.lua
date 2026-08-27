statIndexByName = {
  ["strength"] = CHARSTAT_STRENGTH,
  ["intelligence"] = CHARSTAT_INTELLIGENCE,
  ["melee"] = CHARSTAT_SPEED,
  ["vitality"] = CHARSTAT_VITALITY,
  ["skill"] = CHARSTAT_SKILL,
  ["dexterity"] = CHARSTAT_DEXTERITY,
  ["spirit"] = CHARSTAT_SPIRIT, -- shielding
  ["wisdom"] = CHARSTAT_WISDOM,
  ["perception"] = CHARSTAT_PERCEPTION,
  ["criticaldamage"] = CHARSTAT_CRITICAL_DAMAGE,
  ["regen"] = CHARSTAT_REGEN,
  ["life"] = CHARSTAT_LIFE,
  ["move"] = CHARSTAT_MOVEMENT_SPEED,
	["one"] = CHARSTAT_ONE,
	["two"] = CHARSTAT_TWO,
	["hphit"] = CHARSTAT_HPHIT,
	["eshit"] = CHARSTAT_ESHIT,
}

statNameByIndex = {
  [CHARSTAT_STRENGTH] = "strength",
  [CHARSTAT_INTELLIGENCE] = "intelligence",
  [CHARSTAT_SPEED] = "melee",
  [CHARSTAT_VITALITY] = "vitality",
  [CHARSTAT_SKILL] = "skill",
  [CHARSTAT_DEXTERITY] = "dexterity",
  [CHARSTAT_SPIRIT] = "spirit",
  [CHARSTAT_WISDOM] = "wisdom",
  [CHARSTAT_PERCEPTION] = "perception",
  [CHARSTAT_CRITICAL_DAMAGE] = "criticaldamage",
  [CHARSTAT_REGEN] = "regen",
  [CHARSTAT_LIFE] = "life",
  [CHARSTAT_MOVEMENT_SPEED] = "move",
  [CHARSTAT_ONE] = "one",
  [CHARSTAT_TWO] = "two", -- recovery effectiveness
  [CHARSTAT_HPHIT] = "hphit", -- HP&ES on hit
  [CHARSTAT_ESHIT] = "eshit"
}

    --[[
  statIndexByName = {
    ["strength"] = CHARSTAT_STRENGTH,  0 Strength
    ["intelligence"] = CHARSTAT_INTELLIGENCE,  1 Intelligence
    ["melee"] = CHARSTAT_SPEED,  2 Dexterity
    ["vitality"] = CHARSTAT_VITALITY,  3 Health Percent
    ["skill"] = CHARSTAT_SKILL,  4 Mana Percent
    ["dexterity"] = CHARSTAT_DEXTERITY,  5 Energy Shield Percent
    ["spirit"] = CHARSTAT_SPIRIT, -- 6 Health Regeneration Percent
    ["wisdom"] = CHARSTAT_WISDOM,  7 mana regen percent
    ["perception"] = CHARSTAT_PERCEPTION,  8 Critical Chance
    ["criticaldamage"] = CHARSTAT_CRITICAL_DAMAGE,  9 Attack Speed
    ["regen"] = CHARSTAT_REGEN,  10 Cooldown Reduction
    ["life"] = CHARSTAT_LIFE,  11 All Protection
    ["move"] = CHARSTAT_LIFE,  12 Movement Speed
  }
  --]]

valuePerStat = {
  [CHARSTAT_STRENGTH] = 1,
  [CHARSTAT_INTELLIGENCE] = 1,
  [CHARSTAT_SPEED] = 1,
  [CHARSTAT_VITALITY] = 1,
  [CHARSTAT_SKILL] = 1,
  [CHARSTAT_DEXTERITY] = 1,
  [CHARSTAT_SPIRIT] = 1,
  [CHARSTAT_WISDOM] = 1,
  [CHARSTAT_PERCEPTION] = 0.4,
  [CHARSTAT_CRITICAL_DAMAGE] = 1,
  [CHARSTAT_REGEN] = 0.5,
  [CHARSTAT_LIFE] = 0.5,
  [CHARSTAT_MOVEMENT_SPEED] = 1,
  [CHARSTAT_ONE] = 1,
  [CHARSTAT_TWO] = 1,
  [CHARSTAT_HPHIT] = 1,
  [CHARSTAT_ESHIT] = 1,
}

CharacterStatsMaxValue = {
  [CHARSTAT_STRENGTH] = 30,
  [CHARSTAT_INTELLIGENCE] = 30,
  [CHARSTAT_SPEED] = 30,
  [CHARSTAT_VITALITY] = 30,
  [CHARSTAT_SKILL] = 30,
  [CHARSTAT_DEXTERITY] = 30,
  [CHARSTAT_SPIRIT] = 30,
  [CHARSTAT_WISDOM] = 30,
  [CHARSTAT_PERCEPTION] = 30,
  [CHARSTAT_CRITICAL_DAMAGE] = 30,
  [CHARSTAT_REGEN] = 30,
  [CHARSTAT_LIFE] = 30,
  [CHARSTAT_MOVEMENT_SPEED] = 30,
  [CHARSTAT_ONE] = 30,
  [CHARSTAT_TWO] = 30,
  [CHARSTAT_HPHIT] = 100,
  [CHARSTAT_ESHIT] = 100,
}

local StatsConfig = {
  levels = {
	2,
	5,
	7,
	10,
	15,
    25,
    50,
    75,
    100,
    125,
    150,
    175,
    200,
    225,
    250,
    275,
    300,
    325,
    350,
    375,
    400,
    425,
    450,
    475,
    500,
    550,
    600,
    650,
    700,
    750,
    800,
    850,
    900,
    950,
    1000,
	1050,
    1100,
	1150,
    1200,
	1250,
    1300,
	1350,
    1400,
	1450,
    1500
  }
}

function onAdvance(player, skill, oldLevel, newLevel)
  if skill ~= SKILL_LEVEL or newLevel <= oldLevel then
    return true
  end

  --[[
  local currentLevel = newLevel - 1
  local lastStatLevel = player:getStorageValue(PlayerStorageKeys.characterStatsLevel)

  if lastStatLevel < currentLevel then
    local statPointsToAdd = currentLevel - lastStatLevel
    player:addStatsPoints(statPointsToAdd)
    player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You have gained " .. statPointsToAdd .. " stat point(s).")
    player:setStorageValue(PlayerStorageKeys.characterStatsLevel, currentLevel)
  end
  --]]

  return true
end

function onExtendedOpcode(player, opcode, buffer)
  if opcode == ExtendedOPCodes.CODE_CHARSTATS then
    local status, json_data =
      pcall(
      function()
        return json.decode(buffer)
      end
    )
    if not status then
      return false
    end

    local action = json_data.action
    local data = json_data.data

    if action == "add" then
      addStat(player, data, json_data.points)
	    updateCharacterStatsBonuses(player, data)
      player:setCollectionInfo()
    elseif action == "reset" then
      resetStats(player)
	    updateCharacterStatsBonuses(player, data)
      player:setCollectionInfo()
    elseif action == "update" then
      player:updateCharacterStats()
    end
    player:updateInspect()
  end

  return true
end

function addStat(player, data, value)
  local playerPoints = player:getStatsPoints()
  if playerPoints <= 0 then
    return
  end
  if value > playerPoints then
    value = playerPoints
  end

  local statId = statIndexByName[data]
  if player:getCharacterStat(statId) >= CharacterStatsMaxValue[statId] then
    return
  end
  player:addCharacterStat(statId, value)
  player:addStatsPoints(-value, true)
  player:updateCharacterStats()
end

function resetStats(player)
  local antiSpamCount = player:getStorageValue(52391)
  local timeBetween = os.time() - player:getStorageValue(52390)
  if antiSpamCount == 0 then
    if timeBetween < 5 then
      player:sendTooltipMessage("Slow Down! You have to wait ".. 5 - timeBetween .. " seconds before next try.")
      return false
    else
      player:setStorageValue(52391, 0)
    end
  else
    if timeBetween < 1 then
      player:setStorageValue(52391, antiSpamCount+1)
    else
      player:setStorageValue(52391, 0)
    end
  end
  player:setStorageValue(52390, os.time())

  for i = CHARSTAT_FIRST, CHARSTAT_LAST do
    local points = player:getStorageValue(PlayerStorageKeys.characterStatsPoints + i + 1)
    if points > 0 then
      player:setStorageValue(PlayerStorageKeys.characterStatsPoints + i + 1, -1)
      player:addStatsPoints(points, true)
    end
  end

  for i = CHARSTAT_FIRST, CHARSTAT_LAST do
    local points = player:getCharacterStat(i)
    player:setCharacterStat(i, 0)
    player:addStatsPoints(points, true)
  end

  player:sendTextMessage(MESSAGE_INFO_DESCR, "Character stats have been reset.")
  player:updateCharacterStats()
end

function Player:updateCharacterStats()
  local stats = {}
  local value = 0
  for i = CHARSTAT_FIRST, CHARSTAT_LAST do
    value = value + 1
    stats[value] = {
      self:getCharacterStat(i),
      valuePerStat[i] * self:getCharacterStat(i),
	    CharacterStatsMaxValue[i]
    }
  end

  local data = {
    self:getStatsPoints(),
    stats
  }
  for i = CHARSTAT_FIRST, CHARSTAT_LAST do
   updateCharacterStatsBonuses(self, statNameByIndex[i])
  end
  self:sendExtendedOpcode(ExtendedOPCodes.CODE_CHARSTATS, json.encode({action = "update", data = data}))
end

function Player:addStatsPoints(points, silent)
  local val = self:getStorageValue(PlayerStorageKeys.characterStatsPoints)
  if val == -1 then
    val = 0
  end
  self:setStorageValue(PlayerStorageKeys.characterStatsPoints, val + points)

  if not silent then
    self:updateCharacterStats()
  end
end

function Player:getStatsPoints()
  local val = self:getStorageValue(PlayerStorageKeys.characterStatsPoints)
  if val == -1 then
    val = 0
  end

  return val
end
function updateCharacterStatsBonuses(player, data)
  local function applyStatCondition(player, statId, paramType, characterValue)
    if player:getCharacterStat(statId) >= 0 then
      local conditionCharacter = Condition(CONDITION_ATTRIBUTES)
      conditionCharacter:setParameter(CONDITION_PARAM_TICKS, -1)
      conditionCharacter:setParameter(paramType, characterValue)
      conditionCharacter:setParameter(CONDITION_PARAM_SUBID, 590001 + statId)
      player:addCondition(conditionCharacter)
      if player:getCharacterStat(statId) <= 0 then
        player:removeCondition(CONDITION_ATTRIBUTES, CONDITIONID_COMBAT, 590001 + statId)
      end
    end
  end

  local function applyHealthRegenPercent(player, statId, characterValue)
    if player:getCharacterStat(statId) >= 0 then
      player:addHealthPrecentGain(20, characterValue, true)
      player:addCondition(conditionCharacter)
      if player:getCharacterStat(statId) <= 0 then
        player:removeHealthPrecentGain(20)
      end
    end
  end

  local function applyManaRegenPercent(player, statId, characterValue)
    if player:getCharacterStat(statId) >= 0 then
      player:addManaPrecentGain(20, characterValue, true)
      player:addCondition(conditionCharacter)
      if player:getCharacterStat(statId) <= 0 then
        player:removeManaPrecentGain(20)
      end
    end
  end

  local function applyEnergyShieldRegenPercent(player, statId, characterValue)
    if player:getCharacterStat(statId) >= 0 then
      player:addEnergyShieldPrecentGainForce(20, characterValue, true)
      player:addCondition(conditionCharacter)
      if player:getCharacterStat(statId) <= 0 then
        player:removeEnergyShieldGainForce(20)
      end
    end
  end
  
  local statId = statIndexByName[data]
  local characterValue = player:getCharacterStat(statId)

  if statId == 0 then -- Strength
    applyStatCondition(player, statId, CONDITION_PARAM_SKILL_MELEE, characterValue)
  elseif statId == 1 then -- Intelligence
    applyStatCondition(player, statId, CONDITION_PARAM_SKILL_FISHING, characterValue)
  elseif statId == 2 then -- Dexterity
    applyStatCondition(player, statId, CONDITION_PARAM_SKILL_DISTANCE, characterValue)
  elseif statId == 3 then -- Health Percent
    applyStatCondition(player, statId, CONDITION_PARAM_STAT_MAXHITPOINTSPERCENT, characterValue)
  elseif statId == 4 then -- Mana Percent
    applyStatCondition(player, statId, CONDITION_PARAM_STAT_MAXMANAPOINTSPERCENT, characterValue)
  elseif statId == 5 then -- Energy Shield Percent
    applyStatCondition(player, statId, CONDITION_PARAM_STAT_MAXENERGYSHIELDPERCENT, characterValue)
  --  applyEnergyShieldRegenPercent(player, statId, characterValue)
  elseif statId == 6 then -- Health Regeneration Percent
    applyHealthRegenPercent(player, statId, characterValue)
  elseif statId == 7 then -- Mana Regeneration Percent
    applyManaRegenPercent(player, statId, characterValue)
  elseif statId == 8 then -- Critical Chance
    applyStatCondition(player, statId, CONDITION_PARAM_SPECIALSKILL_CRITICALHITCHANCE, characterValue * 0.4 )
  elseif statId == 9 then -- Attack Speed
  --  player:getTotalAttackSpeed()
  --  applyStatCondition(player, statId, CONDITION_PARAM_ATTACKSPEED, characterValue)
  --  elseif statId == 10 then -- Cooldown Reduction
  --  elseif statId == 11 then -- All Protection
  elseif statId == 12 then -- Movement Speed
  	if player:getCharacterStat(statId) >= 0 then
      local movementSpeedCondition = Condition(CONDITION_HASTE)
      local hasteAdded = player:getBaseSpeed() * characterValue / 100
      movementSpeedCondition:setParameter(CONDITION_PARAM_TICKS, -1)
      movementSpeedCondition:setParameter(CONDITION_PARAM_SUBID, 731600)
      movementSpeedCondition:setFormula(0.0, hasteAdded, 0.0, hasteAdded)
      player:addCondition(movementSpeedCondition)
    else
      player:removeCondition(CONDITION_HASTE, CONDITIONID_COMBAT, 731600)
    end
  elseif statId == 13 then
    applyEnergyShieldRegenPercent(player, statId, characterValue)
  end

    --[[
  statIndexByName = {
    ["strength"] = CHARSTAT_STRENGTH,  0 Strength
    ["intelligence"] = CHARSTAT_INTELLIGENCE,  1 Intelligence
    ["melee"] = CHARSTAT_SPEED,  2 Dexterity
    ["vitality"] = CHARSTAT_VITALITY,  3 Health Percent
    ["skill"] = CHARSTAT_SKILL,  4 Mana Percent
    ["dexterity"] = CHARSTAT_DEXTERITY,  5 Energy Shield Percent
    ["spirit"] = CHARSTAT_SPIRIT, -- 6 Health Regeneration Percent
    ["wisdom"] = CHARSTAT_WISDOM,  7 mana regen percent
    ["perception"] = CHARSTAT_PERCEPTION,  8 Critical Chance
    ["criticaldamage"] = CHARSTAT_CRITICAL_DAMAGE,  9 Attack Speed
    ["regen"] = CHARSTAT_REGEN,  10 Cooldown Reduction
    ["life"] = CHARSTAT_LIFE,  11 All Protection
    ["move"] = CHARSTAT_LIFE,  12 Movement Speed
    ["one"] = CHARSTAT_ONE,  13 energy shield regeneration percent
    ["two"] = CHARSTAT_TWO,  14 recovery effectiveness
    ["three"] = CHARSTAT_THREE,  15 Hp es on hit
  }
  --]]

 player:updateInspect()
end
