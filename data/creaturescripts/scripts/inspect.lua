function onExtendedOpcode(player, opcode, buffer)
  if opcode == ExtendedOPCodes.CODE_INSPECT then
    local status, json_data =
      pcall(
      function()
        return json.decode(buffer)
      end
    )
    if not status then
      return false
    end

    if json_data.target then
      inspectPlayer(player, json_data.target, json_data.action)
    elseif json_data.block then
      player:setStorageValue(PlayerStorage.inspectable, json_data.block)
      player:sendExtendedOpcode(ExtendedOPCodes.CODE_INSPECT, json.encode({block = json_data.block}))
    end
  end
  return true
end

function inspectPlayer(player, targetName, category)
  local target = Player(targetName)
  if not target then
    return false
  end

  local canBeInspected = target:getStorageValue(PlayerStorage.inspectable)
  if canBeInspected == 1 and not player:getGroup():getAccess() and player ~= target then
    player:sendTooltipMessage("This player has disabled inspection.")
    return false
  end

  local data = {}
  if category == 1 then
    data.items = getItems(target)
    data.stats = getStats(target)
    data.relics = getRelics(target)
    data.details = getDetails(target)
  elseif category == 2 then
    data = getAttributes(target)
  elseif category == 3 then
    data = getTalents(target)
  end

  player:sendExtendedOpcode(ExtendedOPCodes.CODE_INSPECT, json.encode({data = data, action = category, voc = vocations}))
end

function getRelics(target)
  local relics = {}
  local relictBox = target:getSlotItem(CONST_SLOT_RELICT_BOX)
  if relictBox then
    local relicItems = relictBox:getItems()
    for _, item in ipairs(relicItems) do
      table.insert(relics, {id = item:getType():getClientId(), rarity = item:getRarityId() or 1, uid = item:getRealUID()})
    end
  end
  return relics
end

function getItems(target)
  local items = {}
  for slot = CONST_SLOT_HEAD, CONST_SLOT_POTION2 do
    local item = target:getSlotItem(slot)
    if item then
      local itemType = item:getType()
      local item_data = {
        uid = item:getRealUID(),
        clientId = itemType:getClientId(),
        count = item:getCount(),
        rarity = item:getCustomAttribute("rarity") or 0,
        th = itemType:getSlotPosition() == 1072 and 1 or nil,
        mr = item:isMirrored()
      }
      items[slot] = item_data
    else
      items[slot] = {empty = true}
    end
  end

  return items
end
local fusionNames = {
  [1]  = "Elementalist",
  [2]  = "Thundershot",
  [3]  = "Battlemage",
  [4]  = "Inquisitor",
  [5]  = "Warlock",
  [6]  = "Toxic Hunter",
  [7]  = "Warden",
  [8]  = "Hierophant",
  [9]  = "Umbral Shaman",
  [10] = "Siegebreaker",
  [11] = "Dawnstalker",
  [12] = "Nightstalker",
  [13] = "Crusader",
  [14] = "Bloody Slayer",
  [15] = "Abyssal Cleric",
}
function getStats(target)
  local stats = {}
  stats.vocation = target:getVocation():getName()

  stats.level = target:getLevel()
  local reborn = target:getStorageValue(707070)
  if reborn <= 0 then
    reborn = "None"
  elseif reborn == 1 then
    reborn = "First"
  elseif reborn == 2 then
    reborn = "Second"
  elseif reborn == 3 then
    reborn = "Third"
  elseif reborn == 4 then
    reborn = "Fourth"
  end
  local fusion = target:getStorageValue(435024)
  if fusion <= 0 then
    fusion = "None"
  elseif fusion > 0 then
    fusion = fusionNames[fusion]
  end

  stats.reborn = reborn
  stats.fusion = fusion
  stats.skills = {}

  local skillsIDS = {6, 2, 4, 5} -- 5 shield
  local baseMagic = target:getBaseMagicLevel()
  local totalMagic = target:getMagicLevel()
  stats.skills[1] = {
    total = totalMagic,
    bonus = totalMagic - baseMagic,
    percent = target:getMagicLevelPercent()
  }
  for i = 1, #skillsIDS do
    local totalSkill = target:getEffectiveSkillLevel(skillsIDS[i])
    local baseSkill = target:getSkillLevel(skillsIDS[i])
    local skillPercent = target:getSkillPercent(skillsIDS[i])
    local bonus = totalSkill - baseSkill
    stats.skills[i+1] = {
      total = totalSkill,
      bonus = bonus,
      percent = skillPercent
    }
  end

  return stats
end

local needAdjustment = {
  --[[
  [30] = function(target, attribute) -- Critical Damage
    attribute.value = attribute.value + 50
    return attribute
  end,
  [52] = function(target, attribute) -- Energy Shield Percent
    attribute.value = attribute.value + target:getEffectiveSkillLevel(SKILL_FISHING)
    return attribute
  end,
  [109] = function(target, attribute) -- Health Percent
    attribute.value = attribute.value + (target:getEffectiveSkillLevel(SKILL_SHIELD) * 1.5)
    return attribute
  end,
  [110] = function(target, attribute) -- Mana Percent
    attribute.value = attribute.value + target:getEffectiveSkillLevel(SKILL_SHIELD)
    return attribute
  end,
  [9] = function(target, attribute) -- Dodge
    attribute.value = attribute.value + math.ceil(target:getEffectiveSkillLevel(SKILL_DISTANCE) / 2)
    return attribute
  end,
  [63] = function(target, attribute) -- Endurance
    attribute.value = attribute.value + target:getEffectiveSkillLevel(SKILL_MELEE)
    return attribute
  end,
  [20] = function(target, attribute) -- Damage
    attribute.value = attribute.value + target:getMagicLevel() * 1
    return attribute
  end,
  [22] = function(target, attribute) -- Damage Reduction
    attribute.value = attribute.value + target:getMagicLevel() * 0.1
    return attribute
  end,
  --]]
}



-- Subklas Overcharged Energy Subklas Bloodfire Subklas Sacred Impact Holy Aegis

-- koniec na 156
-- dodac all talenty do inspect

function getAttributes(target)
  local attributes = {}
  local function getBuffValue(target, buff, base, multi)
    local b = target:getBuff(buff)
    return b and (b.stacks * multi + base) or 0
  end

  local function addAttr(name, value, cat, percent)
    if value > 0 then attributes[name] = { value = value, category = cat, percent = percent } end
  end
  local tId = target:getId()
  local tInfo = colleftInfo[tId] and colleftInfo[tId].attributesItems or {}
  local attackpower = colleftInfo[tId] and colleftInfo[tId].attackPower or 0
  local attacker = target
  local player = target
  -- Uniques
  local elementalDamage = 0
  local dualityDamage = 0
  local physicalDamage = 0
  local damage = 0
  local basicDamage = 0
  local morePrimal = 0
  local damagePenetration = 0
  local elementalPenetration = 0
  local dualityPenetration = 0
  local physicalPenetration = 0
  local hphit = 0
  local eshit = 0

  if colleftInfo[target:getId()].attributesItems[212] then  -- unique Lava Focus - elemental damage
    elementalDamage = elementalDamage + math.min(math.floor(math.max(target:getMaxHealth(), target:getMaxEnergyShield()) * US_ENCHANTMENTS[212].subvalue), 400)
  end
  if colleftInfo[target:getId()].attributesItems[251] then -- unique Divine Focus - duality damage
    dualityDamage = dualityDamage + math.min(math.floor(math.max(target:getMaxHealth(), target:getMaxEnergyShield()) * US_ENCHANTMENTS[251].subvalue), 400)
  end
  if colleftInfo[target:getId()].attributesItems[252] then -- unique Divine Focus - physical damage
    physicalDamage = physicalDamage + math.min(math.floor(math.max(target:getMaxHealth(), target:getMaxEnergyShield()) * US_ENCHANTMENTS[252].subvalue), 400)
  end
  if colleftInfo[attacker:getId()].attributesItems[221] then   -- Hermes Speed
    local movementSpeedPercent = (((200 - attacker:getSpeed()) / 200) * 100) * -1
    damage = damage + math.min((movementSpeedPercent * US_ENCHANTMENTS[221].subvalue), 400)
  end
  if colleftInfo[attacker:getId()].attributesItems[256] then -- unique focused strike
    basicDamage = basicDamage + math.min((attacker:getVarStats(STAT_ATTACKSPEED) * US_ENCHANTMENTS[256].subvalue), 400)
  end
  if attacker:getStorageValue(PlayerStorage.endGame) >= 1 then
		damagePenetration = damagePenetration + 15
	end
  if colleftInfo[attacker:getId()].attributesItems[261] then   -- unique Raven Peck
    elementalPenetration = elementalPenetration + math.min(math.floor(highestStat(attacker) * US_ENCHANTMENTS[261].subvalue), US_ENCHANTMENTS[261].subvalue2)
  end
  if colleftInfo[attacker:getId()].attributesItems[263] then   -- unique Bloody Pact
    physicalPenetration = physicalPenetration + math.min(math.floor(highestStat(attacker) * US_ENCHANTMENTS[263].subvalue), US_ENCHANTMENTS[263].subvalue2)
  end
	if colleftInfo[attacker:getId()].attributesItems[260] then -- unique Soul Piercing
		dualityPenetration = dualityPenetration + math.min(math.floor(highestStat(attacker) * US_ENCHANTMENTS[260].subvalue), US_ENCHANTMENTS[260].subvalue2)
	end
	if colleftInfo[attacker:getId()].attributesItems[277] then -- unique Spark Speed
		local movementSpeedPercent = (((200 - attacker:getSpeed()) / 200) * 100) * -1
		damagePenetration = damagePenetration + math.min((movementSpeedPercent * US_ENCHANTMENTS[277].subvalue), US_ENCHANTMENTS[277].subvalue2)
	end
	if colleftInfo[attacker:getId()].attributesItems[278] then -- unique Ruby Speed
		damagePenetration = damagePenetration + math.min((attacker:getVarStats(STAT_ATTACKSPEED) * US_ENCHANTMENTS[278].subvalue), US_ENCHANTMENTS[278].subvalue2)
	end
	if colleftInfo[attacker:getId()].attributesItems[279] then -- unique Blow Strike
		damagePenetration = damagePenetration + math.min((attacker:getSpecialSkill(SPECIALSKILL_CRITICALHITCHANCE) * US_ENCHANTMENTS[279].subvalue), US_ENCHANTMENTS[279].subvalue2)
	end
	if colleftInfo[attacker:getId()].attributesItems[280] then -- unique Toxic Synergy
		if colleftInfo[attacker:getId()].totalailmentChances then
			damagePenetration = damagePenetration + math.min((colleftInfo[attacker:getId()].totalailmentChances * US_ENCHANTMENTS[280].subvalue), US_ENCHANTMENTS[280].subvalue2)
		end
	end
  -- Talents
  if colleftInfo[attacker:getId()].attributesItems[159] and colleftInfo[attacker:getId()].isTwoHanded then  -- Subklas Heaven's Fury Paladin
    damagePenetration = damagePenetration + US_ENCHANTMENTS[159].subvalue2
  end
  if colleftInfo[attacker:getId()].attributesItems[153] then  -- talent Grace Paladin
    dualityPenetration = dualityPenetration + US_ENCHANTMENTS[153].subvalue
  end
  if colleftInfo[attacker:getId()].attributesItems[152] then  -- Subklas Sacred Impact Paladin
    damagePenetration = damagePenetration + US_ENCHANTMENTS[152].subvalue2
  end
  if colleftInfo[attacker:getId()].attributesItems[170] then  -- Arcane Insight Knight
    elementalPenetration = elementalPenetration + US_ENCHANTMENTS[170].subvalue
  end
  if colleftInfo[attacker:getId()].attributesItems[164] then  -- Subklas Mighty Hands Knight
    physicalPenetration = physicalPenetration + US_ENCHANTMENTS[164].subvalue
  end
  if attacker:hasBuff(SHATTERSTORM) then -- Druid
    damagePenetration = damagePenetration + (attacker:getBuff(SHATTERSTORM).stacks * 3)
  end
  if colleftInfo[attacker:getId()].attributesItems[144] then  -- subklas Plague Druid
    damagePenetration = damagePenetration + US_ENCHANTMENTS[144].subvalue
  end
  if colleftInfo[attacker:getId()].attributesItems[146] then  -- subklas Ruinous Tremous Druid
    damagePenetration = damagePenetration + US_ENCHANTMENTS[146].subvalue
  end
  if colleftInfo[attacker:getId()].attributesItems[127] then  -- Subklas Overcharged Energy Sorcerer
    damagePenetration = damagePenetration + US_ENCHANTMENTS[127].subvalue2
  end
  if colleftInfo[attacker:getId()].attributesItems[132] then  -- Subklas Bloodfire Sorcerer
    damagePenetration = damagePenetration + US_ENCHANTMENTS[132].subvalue2
  end
  if colleftInfo[attacker:getId()].attributesItems[181] then  -- subklas Overcharged Arc Sorcerer
    damagePenetration = damagePenetration + US_ENCHANTMENTS[181].subvalue
  end
  if colleftInfo[attacker:getId()].attributesItems[195] then  -- subklas Suffering Power Shadow + crit redu wymagany inny talent
    damagePenetration = damagePenetration + US_ENCHANTMENTS[195].subvalue
  end

    -- Fusion
    if player:getStorageValue(435024) == 1 then -- Sorcerer + Druid Elementalist
				if player:hasBuff(FIRE) then
					morePrimal = morePrimal + FUSION_SCALING[1].bonus
				elseif player:hasBuff(ICE) then
					morePrimal = morePrimal + FUSION_SCALING[1].bonus
				elseif player:hasBuff(LIGHTNING) then
					morePrimal = morePrimal + FUSION_SCALING[1].bonus
				elseif player:hasBuff(EARTH) then
					morePrimal = morePrimal + FUSION_SCALING[1].bonus
				end
				morePrimal = morePrimal + (player:getEffectiveSkillLevel(SKILL_FISHING) * FUSION_SCALING[1].scaling)
		end
		if player:getStorageValue(435024) == 2 then -- Sorcerer + Archer  "Thundershot"
				local movementSpeedPercent = (((200 - player:getSpeed()) / 200) * 100) * -1
				morePrimal = morePrimal + (movementSpeedPercent * FUSION_SCALING[2].scaling)
		end
		if player:getStorageValue(435024) == 3 then -- Sorcerer + Knight Battlemage
			if colleftInfo[player:getId()].totalailmentChances then
				morePrimal = morePrimal + (colleftInfo[player:getId()].totalailmentChances * FUSION_SCALING[3].scaling)
			end
		end
		if player:getStorageValue(435024) == 4 then -- Sorcerer + Paladin Inquisitor
			morePrimal = morePrimal + (player:getMaxMana() * FUSION_SCALING[4].scaling)
		end
		if player:getStorageValue(435024) == 5 then -- Sorcerer + Shadow Warlock
			morePrimal = morePrimal + (math.max(player:getEffectiveSkillLevel(SKILL_DISTANCE), player:getEffectiveSkillLevel(SKILL_FISHING)) * FUSION_SCALING[5].scaling)
		end
		if player:getStorageValue(435024) == 6 then -- Druid + Archer Toxic hunter
			if colleftInfo[player:getId()].totalailmentChances then
				morePrimal = morePrimal + (colleftInfo[player:getId()].totalailmentChances * FUSION_SCALING[6].scaling)
			end
		end
		if player:getStorageValue(435024) == 7 then -- Druid + Knight Warden
			morePrimal = morePrimal + (player:getMaxMana() * FUSION_SCALING[7].scaling)
		end
		if player:getStorageValue(435024) == 8 then -- Druid + Paladin Hierophant
			if colleftInfo[player:getId()].totalailmentChances then
				morePrimal = morePrimal + (colleftInfo[player:getId()].totalailmentChances * FUSION_SCALING[8].scaling)
			end
		end
		if player:getStorageValue(435024) == 9 then -- -- Druid + Shadow Umbral Shaman
			morePrimal = morePrimal + (math.max(player:getEffectiveSkillLevel(SKILL_DISTANCE), player:getEffectiveSkillLevel(SKILL_FISHING)) * FUSION_SCALING[9].scaling)
		end
		if player:getStorageValue(435024) == 10 then -- Archer + Knight Siegebreaker
			morePrimal = morePrimal + math.floor(player:getVarStats(STAT_ATTACKSPEED) * FUSION_SCALING[10].scaling)
		end
		if player:getStorageValue(435024) == 11 then -- Archer + Paladin Dawnstalker
			local movementSpeedPercent = (((200 - attacker:getSpeed()) / 200) * 100) * -1
			morePrimal = morePrimal + (movementSpeedPercent * FUSION_SCALING[11].scaling)
		end
		if player:getStorageValue(435024) == 12 then -- Archer + Shadow Nightstalker
			morePrimal = morePrimal + math.floor(player:getSpecialSkill(SPECIALSKILL_CRITICALHITCHANCE) * FUSION_SCALING[12].scaling)
		end
		if player:getStorageValue(435024) == 13 then -- Knight + Paladin Crusader
			morePrimal = morePrimal + FUSION_SCALING[13].bonus + (player:getEffectiveSkillLevel(SKILL_MELEE) *  FUSION_SCALING[13].scaling)
		end
		if player:getStorageValue(435024) == 14 then -- Knight + Shadow Bloody Slayer
			morePrimal = morePrimal + math.floor(player:getVarStats(STAT_ATTACKSPEED) * FUSION_SCALING[14].scaling)
		end
		if player:getStorageValue(435024) == 15 then -- Paladin + Shadow Abyssal Cleric
			morePrimal = morePrimal + math.floor(player:getSpecialSkill(SPECIALSKILL_CRITICALHITCHANCE) * FUSION_SCALING[15].scaling)
      damagePenetration = damagePenetration + FUSION_SCALING[15].bonus
		end

    -- Aura
    if target:hasBuff(AURA_ELEMENTAL) then
      elementalDamage = elementalDamage + (5 + (target:getBuff(AURA_ELEMENTAL).stacks * 0.5))
    end
    if target:hasBuff(AURA_PHYSICAL) then
      physicalDamage = physicalDamage + (5 + (target:getBuff(AURA_PHYSICAL).stacks * 0.5))
    end
    if target:hasBuff(AURA_HOLLOW) then
      dualityDamage = dualityDamage + (5 + (target:getBuff(AURA_HOLLOW).stacks * 0.5))
    end
  --Trait
		local overpower = 0
		if spellOverpower(player, 0) then
			overpower = spellOverpower(player, 0)
		end
    local counterattack = 0
    if colleftInfo[player:getId()].attributesItems[208] then -- Bastion Each Strenght increase 4% Counterattack.
			counterattack = counterattack + (player:getEffectiveSkillLevel(SKILL_MELEE) * US_ENCHANTMENTS[208].subvalue)
		end
    if colleftInfo[player:getId()].attributesItems[258] then -- Demon Imbue Each Inteligence increase 4% Counterattack.
			counterattack = counterattack + (player:getEffectiveSkillLevel(SKILL_FISHING) * US_ENCHANTMENTS[258].subvalue)
		end
    eshit = eshit + player:getCharacterStat(CHARSTAT_ESHIT)
    hphit = hphit + player:getCharacterStat(CHARSTAT_HPHIT)

    addAttr("Counterattack", counterattack, 2, true)
    addAttr("Physical Overpower", (overpower), 1, true)
    addAttr("Elemental Overpower", (overpower), 1, true)
    addAttr("Duality Overpower", (overpower), 1, true)
    addAttr("More Damage", (morePrimal), 1, true)
    addAttr("Physical Penetration", (physicalPenetration), 1, true)
    addAttr("Elemental Penetration", (elementalPenetration), 1, true)
    addAttr("Duality Penetration", (dualityPenetration), 1, true)
    addAttr("Penetration", (damagePenetration), 1, true)
    addAttr("Elemental Damage", ( elementalDamage + getBuffValue(target, SORCERER_TRAIT, 20, 0)), 1, true)
    addAttr("Duality Damage", ( dualityDamage ), 1, true)
    addAttr("Physical Damage", ( physicalDamage ), 1, true)
    addAttr("Damage", ( damage ), 1, true)
    addAttr("Health on Hit", ( hphit ), 1, false)
    addAttr("Energy Shield on Hit", ( eshit ), 1, false)
    addAttr("Spell Damage", ( getBuffValue(target, SORCERER_TRAIT, 0, 5)), 1, true)

    addAttr("Basic Damage", ( basicDamage), 1, true)
    addAttr("Attack Speed", ( getBuffValue(target, ARCHER_TRAIT, 5, 5)), 1, true)

    addAttr("Critical Chance", ( getBuffValue(target, SHADOW_TRAIT, 5, 0)), 1, true)

    -- addAttr("DoT Damage", ( getBuffValue(target, DRUID_TRAIT, 50, 0)), 1, true)
    if colleftInfo[player:getId()].totalailmentChances then
      addAttr("All Ailments Combined", ( colleftInfo[player:getId()].totalailmentChances), 1, true)
    end
  --  addAttr("Aliment Chance", ( getBuffValue(target, DRUID_TRAIT, 4, 4)), 1, true)

  -- Talents



    -- Side Bossy
--  local talent = target:getStorageValue(435024)
--[[

    addAttr("Health Percent", ( getBuffValue(target, KNIGHT_TRAIT, 10, 0)), 2, true)
    addAttr("Physical Protection", ( (target:getStorageValue(PlayerStorage.sideBoss6) >= 1) and 10 or 0 + getBuffValue(target, KNIGHT_TRAIT, 0, 5)), 2, true)

    addAttr("Elemental Protection", ( (target:getStorageValue(PlayerStorage.sideBoss8) >= 1) and 10 or 0 + getBuffValue(target, PALADIN_TRAIT, 0, 5)), 2, true)
    addAttr("Energy Shield Percent", ( getBuffValue(target, PALADIN_TRAIT, 10, 0)), 2, true)
    addAttr("Duality Protection", ( (target:getStorageValue(PlayerStorage.sideBoss7) >= 1) and 10 or 0 ), 2, true)

	local base_healthRegen = 5
	local base_manaRegen = 5
  local energyshieldregen = 1

  if target:getStorageValue(PlayerStorage.reborn) >= 0 then
		base_healthRegen = base_healthRegen + (target:getStorageValue(PlayerStorage.reborn) * 5)
		base_manaRegen = base_manaRegen + (target:getStorageValue(PlayerStorage.reborn) * 1)
		energyshieldregen = energyshieldregen + (target:getStorageValue(PlayerStorage.reborn) * 5)
	end
	base_healthRegen = base_healthRegen + (target:getLevel() * 1)
	energyshieldregen = energyshieldregen + (target:getLevel() * 1)
	if target:getStorageValue(PlayerStorage.sideBoss3) >= 1 then
		base_manaRegen = base_manaRegen + 1
	end

    addAttr("Health", ( (target:getStorageValue(PlayerStorage.sideBoss1) >= 1) and 100 or 0 ), 2, false)
    addAttr("Energy Shield", ( (target:getStorageValue(PlayerStorage.sideBoss2) >= 1) and 100 or 0 ), 2, false)
    addAttr("Mana", ( (target:getStorageValue(PlayerStorage.sideBoss3) >= 1) and 100 or 0 ), 2, false)

    addAttr("Health Regeneration", ( base_healthRegen ), 3, false)
    addAttr("Energy Shield Regeneration", ( energyshieldregen ), 3, false)
    addAttr("Mana Regeneration", ( base_manaRegen ), 3, false)



  addAttr("Physical Damage", getBuffValue(target, AURA_PHYSICAL, 10, 5) + (tInfo[43] and tInfo[43].value or 0), 1, true)
  addAttr("Elemental Damage", (tInfo[170] and target:getEffectiveSkillLevel(SKILL_FISHING) or 0) + getBuffValue(target, AURA_ELEMENTAL, 10, 5) + (tInfo[44] and tInfo[44].value or 0), 1, true)

  addAttr("Physical Protection", getBuffValue(target, AURA_PHYSICAL_PROTECTION, 10, 3), 2, true)
  addAttr("Elemental Protection", getBuffValue(target, AURA_ELEMENTAL_PROTECTION, 10, 3) + (tInfo[154] and tInfo[154].subvalue2 or 0), 2, true)
  addAttr("Duality Protection", (tInfo[153] and tInfo[153].subvalue2 or 0), 2, true)
--  addAttr("Counterattack", getBuffValue(target, AURA_HEDGEHOG, 5, 2), 2, true)
  addAttr("Attack Power", attackpower, 1, false)

  local block = 0
	if colleftInfo[target:getId()].attributesItems[8] then -- Block Chance
		block = block + colleftInfo[target:getId()].attributesItems[8].value
	end
  if tInfo[159] and colleftInfo[target:getId()].isTwoHanded then -- Subklas Heaven's Fury
    block = block + 25
  end
  -- addAttr("Block Chance", (tInfo[155] and block or 0), 2, true)
-- Druid + Paladin Frozen Saint
    local frozenSaint = 0
  	if target:getStorageValue(435024) == 8 then -- Druid + Paladin Frozen Saint
			frozenSaint = frozenSaint + (target:getMaxEnergyShield() * 0.075)
		end
  addAttr("Spell Damage", frozenSaint + (tInfo[43] and tInfo[43].value or 0) + (tInfo[44] and tInfo[44].value or 0) + getBuffValue(target, SHATTERSTORM, 0, 5), 1, true)



  addAttr("Damage Reduction", getBuffValue(target, GEOMANCER_PACT, 0, 0.2), 1, true)

  addAttr("Block Chance", ((tInfo[159] and colleftInfo[target:getId()].isTwoHanded) and 25 or 0), 2, true)
  addAttr("more Damage",  (tInfo[159] and math.floor(target:getEffectiveSkillLevel(SKILL_MELEE) / 3) or 0) + getBuffValue(target, RAGE, 0, 1), 1, true)

  addAttr("more Lightning Damage", (tInfo[127] and US_ENCHANTMENTS[127].subvalue or 0), 1, true)
  addAttr("more Fire Damage",  (tInfo[132] and US_ENCHANTMENTS[132].subvalue2 or 0), 1, true)
  addAttr("more Holy Damage", (tInfo[156] and ((target:getPrecentEnergyShieldMultiplier() * 100 - 100) / 2) or 0) + (tInfo[152] and tInfo[152].subvalue2 or 0), 1, true)

  addAttr("Energy Shield Percent", (tInfo[155] and block or 0) + (tInfo[137] and US_ENCHANTMENTS[137].subvalue2 or 0) + (tInfo[149] and US_ENCHANTMENTS[149].subvalue2 or 0) + (target:getEffectiveSkillLevel(SKILL_FISHING) * 0.25), 2, true)

  addAttr("Health Percent",  (tInfo[167] and US_ENCHANTMENTS[167].subvalue or 0) + (tInfo[137] and US_ENCHANTMENTS[137].subvalue or 0), 2, true)

  addAttr("Health On Hit",  (tInfo[161] and US_ENCHANTMENTS[161].subvalue2 or 0), 3, true)

  addAttr("Attack Speed",  ((tInfo[162] and not colleftInfo[target:getId()].isTwoHanded) and US_ENCHANTMENTS[162].subvalue or 0), 1, true)

  addAttr("Bleed Chance",  ((tInfo[163] and not colleftInfo[target:getId()].isTwoHanded) and getBuffValue(target, RAGE, 0, 2) or 0), 1, true)

  addAttr("Basic Damage",  getBuffValue(target, MULTISHOT, 25, 2) + getBuffValue(target, CLEAVE, 25, 2) + getBuffValue(target, MYSTIC_FOCUS, 25, 2), 1, true)
  --]]

local itemAttributes = colleftInfo[target:getId()] and colleftInfo[target:getId()].attributesItems or {}
for id, attribute in pairs(itemAttributes) do
    local tempAttribute = table.copy(attribute)
    local data = needAdjustment[id] and needAdjustment[id](target, tempAttribute) or tempAttribute

    local attributeName = data.text

    -- Sprawdzenie i Pominięcie Atrybutów
    if attributeName ~= "Intelligence" and 
       attributeName ~= "Dexterity" and 
       attributeName ~= "Strength" and 
       attributeName ~= "Vitality" 
    then
        -- Logika wykonuje się TYLKO, jeśli atrybut NIE jest jednym z ignorowanych
        if attributes[data.text] then
            attributes[data.text].value = attributes[data.text].value + data.value
        else
            attributes[data.text] = {
                value = data.value,
                category = data.category,
                percent = data.percent,
            }
        end
    end
end

  return attributes
end


local TALENTS_STORAGE = 435002
local SECOND_TALENT = 435001
local FUSION_STORAGE = 435024
local CAN_CHANGE_SECOND_TALENT = 435025
local FUSION_ULOCKED = 999030
local SPECIALIZATION = 999032

function getTalents(target)
  local vocation = convertVocation[target:getVocation():getId()]
  local second_talent = target:getStorageValue(SECOND_TALENT)
  local fusion = 0
  local show_fusion = target:getStorageValue(FUSION_ULOCKED) == 1
  local specialization =  target:getStorageValue(SPECIALIZATION)
  local current_talents = {
    {},
    {}
  }

  for i = 1, 6 do
    current_talents[1][i] = target:getStorageValue(TALENTS_STORAGE + i)
  end

  if second_talent ~= -1 then
    for i = 1, 6 do
      current_talents[2][i] = target:getStorageValue(TALENTS_STORAGE + 10 + i)
    end

    fusion = target:getStorageValue(FUSION_STORAGE)
  end

  return {
    talents = current_talents,
    second_talent = second_talent,
    fusion = fusion,
    show_fusion = show_fusion,
    vocation = vocation,
    spec = specialization,
  }
end