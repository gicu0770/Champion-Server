TALENTS = {
  [1] = dofile('data/scripts/talents/data/sorcerer.lua'),
  [2] = dofile('data/scripts/talents/data/druid.lua'),
  [3] = dofile('data/scripts/talents/data/archer.lua'),
  [4] = dofile('data/scripts/talents/data/knight.lua'),
  [17] = dofile('data/scripts/talents/data/paladin.lua'),
  [21] = dofile('data/scripts/talents/data/shadow.lua'),
}

local specializations = {
  TOXIC_PATH,
  PYRO_PATH,
  CRYO_PATH,
  THUNDER_PATH,
  PASSING_PATH,
  SACRED_PATH,
  BLOODY_PATH,
}

local last_uid = 0
for _, TALENT in pairs(TALENTS) do
  for i = 1, #TALENT do
    for x = 1, #TALENT[i] do
      for j = 1, #TALENT[i][x].enchants do
        last_uid = last_uid + 1
        TALENT[i][x].enchants[j][3] = last_uid
      end
    end
  end
end

local talentsLinesLevel = {
  [1] = {
    3,
    8,
    15,
    23,
    30,
    40,
    50,
    60,
    70,
    80,
    90
  },
  [2] = {
    35,
    38,
    40,
    42,
    45,
    55,
    65,
    75,
    85,
    95
  }
}

local FUSIONS_EXTRA_ATTRIBUTES = {
  --[[
  [4] = {
    {110, 30}, -- mana 30% 
  },
  [15] = {
    {246, 1}, -- mana 30% 
  }
  --]]
}

local FUSIONS = {
  [1] = {
    [2] = 1,
    [3] = 2,
    [4] = 3,
    [17] = 4,
    [21] = 5
  },
  [2] = {
    [1] = 1,
    [3] = 6,
    [4] = 7,
    [17] = 8,
    [21] = 9
  },
  [3] = {
    [1] = 2,
    [2] = 6,
    [4] = 10,
    [17] = 11,
    [21] = 12
  },
  [4] = {
    [1] = 3,
    [2] = 7,
    [3] = 10,
    [17] = 13,
    [21] = 14
  },
  [17] = {
    [1] = 4,
    [2] = 8,
    [3] = 11,
    [4] = 13,
    [21] = 15
  },
  [21] = {
    [1] = 5,
    [2] = 9,
    [3] = 12,
    [4] = 14,
    [17] = 15
  }
}
local TALENTS_STORAGE = 435002
local SECOND_TALENT = 435001
local FUSION_STORAGE = 435024
local CAN_CHANGE_SECOND_TALENT = 435025
local FUSION_ULOCKED = 999030
local SPECIALIZATION = 999032

local TALENT_CHANGE_COST_PER_LEVEL = 10

local LoginEvent = CreatureEvent("TalentsLogin")
function LoginEvent.onLogin(player)
  player:registerEvent("TalentsExtendedOpcode")
  player:sendCurrentTalents(true)
  player:addFusionAttributes(player:getStorageValue(FUSION_STORAGE))
  player:addSpecialziationBuff(player:getStorageValue(SPECIALIZATION))
  return true
end

local traits = {
  { check = function(p) return p:isArcher() end, id = 3, buff = ARCHER_TRAIT },
  { check = function(p) return p:isSorcerer() end, id = 1, buff = SORCERER_TRAIT },
  { check = function(p) return p:isDruid() end, id = 2, buff = DRUID_TRAIT },
  { check = function(p) return p:isPaladin() end, id = 17, buff = PALADIN_TRAIT },
  { check = function(p) return p:isKnight() end, id = 4, buff = KNIGHT_TRAIT },
  { check = function(p) return p:isShadow() end, id = 21, buff = SHADOW_TRAIT }
}

local vocation_name = {
  [1] = "Sorcerer",
  [2] = "Druid",
  [3] = "Archer",
  [4] = "Knight",
  [17] = "Paladin",
  [21] = "Shadow",
}

-- 211
local ExtendedEvent = CreatureEvent("TalentsExtendedOpcode")
function ExtendedEvent.onExtendedOpcode(player, opcode, buffer)
  if opcode ~= ExtendedOPCodes.CODE_TALENTS then return false end
  local status, data = pcall(function() return json.decode(buffer) end)
  if not status then return false end

  if data[1] == 1 then
    local talentId = data[2]
    local lineId = data[3]
    local secondTalent = data[4]

    player:changeTalent(lineId, talentId, secondTalent)
  elseif data[1] == 2 then
    local CAN_CHANGE = player:getStorageValue(CAN_CHANGE_SECOND_TALENT)
    if CAN_CHANGE == -1 then
      player:sendTooltipMessage("You can't change your second talent.")
      return false
    end
  
    local secondTalent = data[2]
    if player:getStorageValue(SECOND_TALENT) == secondTalent then
      player:sendTooltipMessage("You already selected this vocation.")
      return false
    end

    if CAN_CHANGE > 2 then
      local item = player:getItem(CAN_CHANGE)
      if not item or not item:remove() then
        player:sendTooltipMessage("You don't have required item to reset your talents.")
        return false
      end
    end

    player:setStorageValue(SECOND_TALENT, secondTalent)
    for i = 1, 10 do 
      player:removeTalent(i, true)
    end
    player:sendExtendedOpcode(ExtendedOPCodes.CODE_TALENTS, json.encode({4}))
    player:sendCurrentTalents()
    player:setStorageValue(CAN_CHANGE_SECOND_TALENT, -1)
    player:removeFusionAttributes()

    if player:getStorageValue(PlayerStorage.fusionTalent) == 1 then
      fusion = FUSIONS[convertVocation[player:getVocation():getId()]][secondTalent]
      player:setStorageValue(FUSION_STORAGE, fusion)
      player:addFusionAttributes(fusion)
    end
    if player:getStorageValue(PlayerStorage.voortResetTalent) == 0 then
      player:setStorageValue(PlayerStorage.voortResetTalent, 1)
    end
    player:setCollectionInfo()
  elseif data[1] == 3 then
    if player:getStorageValue(PlayerStorage.secondTrait) > 0 then
      player:popupFYI("You already have a second Vocation Trait.")
      player:sendExtendedOpcode(ExtendedOPCodes.CODE_TALENTS, json.encode({6}))
      return true
    end

    local choiceId = data[2]
    if not choiceId then
      player:popupFYI("Something went wrong with selecting trait, try again!")
      player:sendExtendedOpcode(ExtendedOPCodes.CODE_TALENTS, json.encode({6}))
      return true
    end

    for _, trait in ipairs(traits) do
      player:removeBuff(trait.buff)
    end

    player:setStorageValue(PlayerStorage.secondTrait, choiceId)
    if choiceId == 3 then
      player:addBuff(ARCHER_TRAIT)
      player:setBuffStacks(ARCHER_TRAIT, player:getStorageValue(PlayerStorage.reborn) + 1)
			local hasteAdded = player:getBaseSpeed() * 15 / 100
			local conditionHaste = Condition(CONDITION_HASTE, CONDITIONID_DEFAULT)
			conditionHaste:setParameter(CONDITION_PARAM_SUBID, 717778)
			conditionHaste:setParameter(CONDITION_PARAM_TICKS, -1) --2 secs
			conditionHaste:setFormula(0.0, hasteAdded, 0.0, hasteAdded)
			player:addCondition(conditionHaste)
    elseif choiceId == 1 then
      player:addBuff(SORCERER_TRAIT)
      player:setBuffStacks(SORCERER_TRAIT, player:getStorageValue(PlayerStorage.reborn) + 1)
    elseif choiceId == 2 then
      player:addBuff(DRUID_TRAIT)
      player:setBuffStacks(DRUID_TRAIT, player:getStorageValue(PlayerStorage.reborn) + 1)
    elseif choiceId == 17 then
      player:addBuff(PALADIN_TRAIT)
      player:setBuffStacks(PALADIN_TRAIT, player:getStorageValue(PlayerStorage.reborn) + 1)
    elseif choiceId == 4 then
      player:addBuff(KNIGHT_TRAIT)
      player:setBuffStacks(KNIGHT_TRAIT, player:getStorageValue(PlayerStorage.reborn) + 1)
    elseif choiceId == 21 then
      player:addBuff(SHADOW_TRAIT)
      player:setBuffStacks(SHADOW_TRAIT, player:getStorageValue(PlayerStorage.reborn) + 1)
    end

		for _, trait in ipairs(traits) do
			if trait.check(player) or player:getStorageValue(PlayerStorage.secondTrait) == trait.id then
				player:addBuff(trait.buff)
				player:setBuffStacks(trait.buff, player:getStorageValue(PlayerStorage.reborn) + 1)
			end
		end

    player:getPosition():sendMagicEffect(31)
    player:sendExtendedOpcode(ExtendedOPCodes.CODE_TALENTS, json.encode({6}))
  elseif data[1] == 4 then
    local specializationValue = player:getStorageValue(SPECIALIZATION)
    if specializationValue == -1 then
      return
    end

    if specializationValue ~= 0 then
      if not player:removeTotalMoney(100000) then
        player:sendTooltipMessage("You need " .. 100000 .. " gold to change your specialzaition.")
        return
      end
    end

    for i = 1, #specializations do
      player:removeBuff(specializations[i])
    end

    player:setStorageValue(SPECIALIZATION, data[2])
    player:addSpecialziationBuff(data[2])
    player:sendExtendedOpcode(ExtendedOPCodes.CODE_TALENTS, json.encode({7, data[2]}))
  end

  return true
end

function Player:showSecondTalentSelector(item)
  local id = item and item:getRealUID() or 1
  self:setStorageValue(CAN_CHANGE_SECOND_TALENT, id)
  self:finishQuest(5)
	self:startQuest(6)
  self:sendExtendedOpcode(ExtendedOPCodes.CODE_TALENTS, json.encode({3, convertVocation[self:getVocation():getId()]}))
end

function Player:showTraitSelector()
  self:finishQuest(12)
	self:startQuest(13)
  self:sendExtendedOpcode(ExtendedOPCodes.CODE_TALENTS, json.encode({5, convertVocation[self:getVocation():getId()]}))
end

function Player:sendCurrentTalents(login)
  local vocation = convertVocation[self:getVocation():getId()]
  local second_talent = self:getStorageValue(SECOND_TALENT)
  local show_button = false
  local playerLevel = self:getLevel()
  local fusion = 0
  local specialization = self:getStorageValue(SPECIALIZATION)
  local show_fusion = self:getStorageValue(FUSION_ULOCKED) == 1
  local current_talents = {
    {},
    {}
  }

  if specialization == 0 then
    show_button = true
  end

  for i = 1, 10 do
    current_talents[1][i] = self:getStorageValue(TALENTS_STORAGE + i)
    if current_talents[1][i] ~= -1 then
      self:changeTalent(i, current_talents[1][i], false, true)
    end
    if current_talents[1][i] == -1 and playerLevel >= talentsLinesLevel[1][i] then
      show_button = true
    end
  end

  if second_talent ~= -1 then
    for i = 1, 10 do
      current_talents[2][i] = self:getStorageValue(TALENTS_STORAGE + 10 + i)
      if current_talents[2][i] ~= -1 then
        self:changeTalent(i, current_talents[2][i], true, true)
      end
      if current_talents[2][i] == -1 and playerLevel >= talentsLinesLevel[2][i] then
        show_button = true
      end
    end

    if self:getStorageValue(PlayerStorage.fusionTalent) == 1 then
      fusion = FUSIONS[convertVocation[self:getVocation():getId()]][second_talent]
      self:setStorageValue(FUSION_STORAGE, fusion)
    end
  end

  self:sendExtendedOpcode(ExtendedOPCodes.CODE_TALENTS, json.encode({1, vocation, second_talent, current_talents, login or false, show_button, fusion, show_fusion, specialization}))
end

function Player:addFusionAttributes(id)
  if self:getStorageValue(PlayerStorage.fusionTalent) ~= 1 then
    return
  end
  local attributes = FUSIONS_EXTRA_ATTRIBUTES[id]
  if not attributes then return end

  for i = 1, #attributes do
    local value = attributes[i]
    local bonusId = value[1]
    local bonusValue = value[2]
    local uid = bonusId + 200000

    local attr = US_ENCHANTMENTS[bonusId]
    if attr then
      if attr.combatType == US_TYPES.CONDITION then
        if not US_CONDITIONS[bonusId] then
          US_CONDITIONS[bonusId] = {}
        end
        if not US_CONDITIONS[bonusId] then
          US_CONDITIONS[bonusId] = {}
        end
        if not US_CONDITIONS[bonusId][uid] then
          US_CONDITIONS[bonusId][uid] = Condition(attr.condition)
          US_CONDITIONS[bonusId][uid]:setParameter(CONDITION_PARAM_SUBID, uid)
          US_CONDITIONS[bonusId][uid]:setParameter(attr.param, attr.percentage == true and bonusValue or bonusValue)
          US_CONDITIONS[bonusId][uid]:setParameter(CONDITION_PARAM_TICKS, -1)
          US_CONDITIONS[bonusId][uid]:setParameter(CONDITION_PARAM_BUFF_SPELL, false)
          self:addCondition(US_CONDITIONS[bonusId][uid])
        else
          self:addCondition(US_CONDITIONS[bonusId][uid])
        end
      end
    end
  end
end

function Player:removeFusionAttributes()
  for _, data in pairs(FUSIONS_EXTRA_ATTRIBUTES) do
    for i = 1, #data do
      local value = data[i]
      local bonusId = value[1]
      local uid = bonusId + 200000

      local attr = US_ENCHANTMENTS[bonusId]
      if attr then
        if attr.combatType == US_TYPES.CONDITION then
          if US_CONDITIONS[bonusId] and US_CONDITIONS[bonusId] and US_CONDITIONS[bonusId][uid] then
            self:removeCondition(US_CONDITIONS[bonusId][uid]:getType(), CONDITIONID_COMBAT, US_CONDITIONS[bonusId][uid]:getSubId())
          end
        end
      end
    end
  end
end

function Player:addSpecialziationBuff(specValue)
  if specValue < 1 then
    return
  end
  local buff = specializations[specValue]
  if not buff then
    print("Specialzaition | can't find spec with id: " .. specValue)
    return
  end

  self:addBuff(buff)
end

function Player:removeTalent(lineId, secondTalent)
  local talents_data = nil
  local storage_id = TALENTS_STORAGE + lineId

  if secondTalent then
    talents_data = TALENTS[self:getStorageValue(SECOND_TALENT)]
    storage_id = storage_id + 10
  else
    talents_data = TALENTS[convertVocation[self:getVocation():getId()]]
  end

  local current_talent = self:getStorageValue(storage_id)
  if current_talent == -1 then
    return
  end

  local talent = talents_data[lineId][current_talent]
  if not talent then
    print("Talent not found.: " .. current_talent .. " - " .. lineId)
    return
  end

  for i = 1, #talent.enchants do
    local value = talent.enchants[i]
    local bonusId = value[1]
    local bonusValue = value[2]
    local uid = value[3] + 100000

    local attr = US_ENCHANTMENTS[bonusId]
    if attr then
      if attr.combatType == US_TYPES.CONDITION then
        if US_CONDITIONS[bonusId] and US_CONDITIONS[bonusId] and US_CONDITIONS[bonusId][uid] then
          self:removeCondition(US_CONDITIONS[bonusId][uid]:getType(), CONDITIONID_COMBAT, US_CONDITIONS[bonusId][uid]:getSubId())
        end
      end
    end
  end

  self:setStorageValue(storage_id, -1)
end

function Player:changeTalent(lineId, talentId, secondTalent, login)
  local talents_data = nil
  local level_needed = 100
  local storage_id = TALENTS_STORAGE + lineId
  local playerLevel = self:getLevel()

  if secondTalent then
    talents_data = TALENTS[self:getStorageValue(SECOND_TALENT)]
    level_needed = talentsLinesLevel[2][lineId]
    storage_id = storage_id + 10
  else
    talents_data = TALENTS[convertVocation[self:getVocation():getId()]]
    level_needed = talentsLinesLevel[1][lineId]
  end

  if not talents_data then
    self:sendTooltipMessage("You can't learn this talent.")
    return
  end

  if playerLevel < level_needed then
    self:setStorageValue(storage_id, -1)
    self:sendTooltipMessage("You need level " .. level_needed .. " to learn this talent.")
    return
  end

  local current_talent = self:getStorageValue(storage_id)
  if not login and current_talent == talentId then
    return
  end

  if not login and current_talent ~= -1 then
    local cost = math.ceil((level_needed ^ 0.7 * 100) * TALENT_CHANGE_COST_PER_LEVEL)
    if not self:removeTotalMoney(cost) then
      self:sendTooltipMessage("You need " .. cost .. " gold to change your talent.")
      return
    end
  end

  if current_talent ~= -1 and not login then
    local old_talent = talents_data[lineId][current_talent]
    if old_talent then
      for i = 1, #old_talent.enchants do
        local value = old_talent.enchants[i]
        local bonusId = value[1]
        local bonusValue = value[2]
        local uid = value[3] + 100000

        local attr = US_ENCHANTMENTS[bonusId]
        if attr then
          if attr.combatType == US_TYPES.CONDITION then
            if US_CONDITIONS[bonusId] and US_CONDITIONS[bonusId]and US_CONDITIONS[bonusId][uid] then
              self:removeCondition(US_CONDITIONS[bonusId][uid]:getType(), CONDITIONID_COMBAT, US_CONDITIONS[bonusId][uid]:getSubId())
            end
          end
        end
      end
    end
  end

  local talent = talents_data[lineId][talentId]
  if not talent then
    print("Talent not found.: " .. talentId .. " - " .. lineId)
    return
  end

  for i = 1, #talent.enchants do
    local value = talent.enchants[i]
    local bonusId = value[1]
    local bonusValue = value[2]
    local uid = value[3] + 100000

    local attr = US_ENCHANTMENTS[bonusId]
    if attr then
      if attr.combatType == US_TYPES.CONDITION then
        if not US_CONDITIONS[bonusId] then
          US_CONDITIONS[bonusId] = {}
        end
        if not US_CONDITIONS[bonusId] then
          US_CONDITIONS[bonusId] = {}
        end
        if not US_CONDITIONS[bonusId][uid] then
          US_CONDITIONS[bonusId][uid] = Condition(attr.condition)
          US_CONDITIONS[bonusId][uid]:setParameter(CONDITION_PARAM_SUBID, uid)
          US_CONDITIONS[bonusId][uid]:setParameter(attr.param, attr.percentage == true and bonusValue or bonusValue)
          US_CONDITIONS[bonusId][uid]:setParameter(CONDITION_PARAM_TICKS, -1)
          US_CONDITIONS[bonusId][uid]:setParameter(CONDITION_PARAM_BUFF_SPELL, false)
          self:addCondition(US_CONDITIONS[bonusId][uid])
        else
          self:addCondition(US_CONDITIONS[bonusId][uid])
        end
      end
    end
  end

  if not login then
    self:setStorageValue(storage_id, talentId)
    self:setCollectionInfo()

    local show_button = false
    for i = 1, 10 do
      if self:getStorageValue(TALENTS_STORAGE + i) == -1 and playerLevel >= talentsLinesLevel[1][i] then
        show_button = true
      end
    end

    if secondTalent then
      for i = 1, 10 do
        if self:getStorageValue(TALENTS_STORAGE + 10 + i) == -1 and playerLevel >= talentsLinesLevel[2][i] then
          show_button = true
        end
      end
    end

    if self:getStorageValue(SPECIALIZATION) == 0 then
      show_button = true
    end

    self:sendExtendedOpcode(ExtendedOPCodes.CODE_TALENTS, json.encode({2, lineId, talentId, secondTalent or false, show_button}))
  end
end

LoginEvent:type("login")
LoginEvent:register()
ExtendedEvent:type("extendedopcode")
ExtendedEvent:register()