io.stdout:setvbuf("no")
io.stderr:setvbuf("no")

dofile('data/lib/lib.lua')
dofile('data/base_items.lua')
dofile('data/upgrade_system_core.lua')
dofile('data/upgrade_dungeon_modifiers.lua')
dofile('data/upgrade_enchantments.lua')
dofile('data/lib/vocation.lua')
dofile('data/lib/quest_chests.lua')
dofile('data/waypoints.lua')
dofile('data/tilewidgets.lua')

BUYABLE_ITEMS_BY_ID = {}
TWO_HANDED_MULTIPLIER = 1.90
RELICT_UBER_BOSS = 38418

EVENT_CHANCE = {
	["Treasure Goblin"] = {name = "Bilbo", chance = 150, relictHolderChance = 10, levelDrop = 105, gold = 300},
	["Champion"] = {name = "Gorok", chance = 150, relictHolderChance = 10, levelDrop = 105},
	["Strongbox"] = {name = "Viliaan", chance = 150, relictHolderChance = 10, levelDrop = 105},
	["Boss"] = {name = "Ascended Voort", relictHolderChance = 10, levelDrop = 105}, 
	["Abyss"] = {name = {"Demon", "Demon", "Demon"}, chance = 100000},
	["Stone"] = {name = "Stone", chance = 150, gold = 200, exp = 50}  --100000
	-- relictHolderChance = Szansa na Relict Holdera !!!
}
FUSION_SCALING = {
  [1]  = {name = "Elementalist",      scaling = 6.5,  bonus = 50},  -- INT = 50% more co cast spella
  [2]  = {name = "Thundershot",       scaling = 7,  bonus = 185, hp = 0.33},  -- Movement speed + 33% > HP 185% more damage
  [3]  = {name = "Battlemage",        scaling = 8,  bonus = 60, defense = 5},  -- Ailment chance + 60% na ignite mobs
  [4]  = {name = "Inquisitor",        scaling = 0.05,  bonus = 15, hp = 0.5, mana = 0.05},  -- MANA penetracja 10 + 10 50% Hp
  [5]  = {name = "Warlock",           scaling = 6.5,  bonus = 200, chance = 20, regen = 0.015},  -- dex / int + proc 20% na 200% more co daje 60% srednio
  [6]  = {name = "Toxic Hunter",      scaling = 8,  bonus = 100, defense = 5}, -- Ailment + 100% dot more
  [7]  = {name = "Warden",            scaling = 0.05,  mana = 0.05, bonus = 50},   -- MANA based + 5% mana na HP
  [8]  = {name = "Hierophant",        scaling = 8,  bonus = 100, hp = 0.5, defense = 5},  -- Ailment chance 100% more below 50%
  [9]  = {name = "Umbral Shaman",     scaling = 6.5,  bonus = 70},  -- INT/DEX + 15% of damage deal
  [10] = {name = "Siegebreaker",       scaling = 3.8,  bonus = 2},   -- ATTACK SPEED = physical pene 2% per stack
  [11] = {name = "Dawnstalker",        scaling = 7,  bonus = 2.00, chance = 5},  -- MOVEMENT + proc 5% na 200% aoe
  [12] = {name = "Nightstalker",       scaling = 20.0, bonus = 0},   -- CRIT = 15% CC z buff
  [13] = {name = "Crusader",           scaling = 6.5,  bonus = 50, hp = 220},  -- STR hp = 150 ile % na 150HP
  [14] = {name = "Bloody Slayer",      scaling = 3.8,  bonus = 2},  --  ATTACK SPEED  + deep wound stack 2% dmg (60%)
  [15] = {name = "Abyssal Cleric",     scaling = 20.0,  bonus = 15, chance = 5},  -- CRIT - 15% penetracji + 5% crit chance
}

RARITYS_STORE = {
  NORMAL = 1,
  COMMON = 2,
  MAGIC = 3,
  RARE = 4,
  LEGENDARY = 5,
  LIMITED = 6,
  SPECIAL = 7,
}

PATH_BUFFS = {
	{buff = TOXIC_PATH},
	{buff = PYRO_PATH},
	{buff = CRYO_PATH},
	{buff = THUNDER_PATH},
	{buff = PASSING_PATH},
	{buff = SACRED_PATH},
	{buff = BLOODY_PATH},
}

ELEMENTAL_TYPES = {
	[COMBAT_ENERGYDAMAGE] = true,
	[COMBAT_EARTHDAMAGE] = true,
	[COMBAT_FIREDAMAGE] = true,
	[COMBAT_ICEDAMAGE] = true,
	[COMBAT_ELEMENTAL_PROC_DAMAGE] = true,
	[COMBAT_ELEMENTAL_DOT] = true,
}

RARITY_NAMES = {
  [0] = "",
  [1] = "Common",
  [2] = "Magic",
  [3] = "Rare",
  [4] = "Legendary",
  [5] = "Unique",
  [6] = "Exalted"
}

INDIVIDUAL_WEAPON_TYPES = {
	US_ITEM_TYPES.WEAPON_CROSSBOW,
	US_ITEM_TYPES.WEAPON_BOW,
	US_ITEM_TYPES.WEAPON_KNIFE,
	US_ITEM_TYPES.WEAPON_WAND,
	US_ITEM_TYPES.WEAPON_WANDAOE,
	US_ITEM_TYPES.WEAPON_SWORD,
	US_ITEM_TYPES.WEAPON_CLUB,
	US_ITEM_TYPES.WEAPON_AXE
}

WEAPON_MELEE_TYPES = {
	US_ITEM_TYPES.WEAPON_SWORD,
	US_ITEM_TYPES.WEAPON_CLUB,
	US_ITEM_TYPES.WEAPON_AXE,
	US_ITEM_TYPES.WEAPON_KNIFE,
	US_ITEM_TYPES.WEAPON_WANDAOE
}

RELICTS_TYPES = {
	US_ITEM_TYPES.RELICT_DEFFENSIVE,
	US_ITEM_TYPES.RELICT_OFFENSIVE,
	US_ITEM_TYPES.RELICT_UTILITY,
	US_ITEM_TYPES.RELICT_GOBLIN,
	US_ITEM_TYPES.RELICT_CHAMPION,
	US_ITEM_TYPES.RELICT_STRONGBOX,
	US_ITEM_TYPES.RELICT_BOSS,
	US_ITEM_TYPES.RELICT_VOIDSTONE,
}

TRANSLATE_ITEM_TYPES = {
  [US_ITEM_TYPES.ALL] = 1,
  [US_ITEM_TYPES.HELMET] = 2,
  [US_ITEM_TYPES.ARMOR] = 3,
  [US_ITEM_TYPES.LEGS] = 4,
  [US_ITEM_TYPES.BOOTS] = 5,
  [US_ITEM_TYPES.RING] = 6,
  [US_ITEM_TYPES.NECKLACE] = 7,
  [US_ITEM_TYPES.SHIELD] = 8,
  [US_ITEM_TYPES.WEAPON_CROSSBOW] = 9,
  [US_ITEM_TYPES.WEAPON_BOW] = 10,
  [US_ITEM_TYPES.WEAPON_KNIFE] = 11,
  [US_ITEM_TYPES.WEAPON_WAND] = 12,
  [US_ITEM_TYPES.WEAPON_WANDAOE] = 13,
  [US_ITEM_TYPES.WEAPON_SWORD] = 14,
  [US_ITEM_TYPES.WEAPON_CLUB] = 15,
  [US_ITEM_TYPES.WEAPON_AXE] = 16,
  [US_ITEM_TYPES.GLOVES] = 17,
  [US_ITEM_TYPES.BELT] = 18,
  [US_ITEM_TYPES.RIGHT_RING] = 19,
  [US_ITEM_TYPES.PET] = 20,
  [US_ITEM_TYPES.WEAPON_MELEE] = 22,
  [US_ITEM_TYPES.WEAPON_ANY] = 23,
  [US_ITEM_TYPES.RELICT_ANY] = 27,
  [US_ITEM_TYPES.RELICT_DEFFENSIVE] = 27,
  [US_ITEM_TYPES.RELICT_OFFENSIVE] = 27,
  [US_ITEM_TYPES.RELICT_UTILITY] = 27,
  [US_ITEM_TYPES.RELICT_GOBLIN] = 27,
  [US_ITEM_TYPES.RELICT_CHAMPION] = 27,
  [US_ITEM_TYPES.RELICT_STRONGBOX] = 27,
  [US_ITEM_TYPES.RELICT_BOSS] = 27,
  [US_ITEM_TYPES.RELICT_VOIDSTONE] = 27,
}

US_ENCHANTMENTS_ITEMTYPE = {}

DUNGEON_MOD_ATTR_ADDED = {
	[3] = PlayerStorage.monsterModifier_damage,
	[5] = PlayerStorage.monsterModifier_physicalProtection,
	[6] = PlayerStorage.monsterModifier_elementalProtection,
	[7] = PlayerStorage.monsterModifier_dualityProtection,
	[8] = PlayerStorage.monsterModifier_spell_avoid,
	[9] = PlayerStorage.monsterModifier_dodge,
	[10] = PlayerStorage.monsterModifier_ailments,
	[11] = PlayerStorage.monsterModifier_movements,
	[12] = PlayerStorage.monsterModifier_rift,
	[13] = PlayerStorage.monsterModifier_phantom,
	[14] = PlayerStorage.monsterModifier_bloody,
	[15] = PlayerStorage.monsterModifier_armored,

	[19] = PlayerStorage.monsterModifier_extragold,
	[20] = PlayerStorage.monsterModifier_extraexp,
	[21] = PlayerStorage.monsterModifier_extracurrency,
}

function Player.getCharacterType(self)
	local typeEx = 1
	if CHAMPION_STATS[self:getVocation():getName()].physical_character then
		typeEx = self:getPhysicalAttack()
	elseif CHAMPION_STATS[self:getVocation():getName()].magic_character then
		typeEx = self:getMagicAttack()
	end
	return typeEx
end


function Player.getPhysicalAttack(self)
	if not self then return 0 end
	local getPhysicalAttack = CHAMPION_STATS[self:getVocation():getName()].physical_attack + (((CHAMPION_STATS[self:getVocation():getName()].physical_attackPL - CHAMPION_STATS[self:getVocation():getName()].physical_attack) / 50) * self:getLevel())
	if colleftInfo[self:getId()].attributesItems[6] then
		getPhysicalAttack = getPhysicalAttack + colleftInfo[self:getId()].attributesItems[6].value
	end
	return getPhysicalAttack
end

function Player.getMagicAttack(self)
	if not self then return 0 end
	local getMagicAttack = CHAMPION_STATS[self:getVocation():getName()].magic_attack + (((CHAMPION_STATS[self:getVocation():getName()].magic_attackPL - CHAMPION_STATS[self:getVocation():getName()].magic_attack) / 50) * self:getLevel()) 
	if colleftInfo[self:getId()] and colleftInfo[self:getId()].attributesItems then
		if colleftInfo[self:getId()].attributesItems[7] then
			getMagicAttack = getMagicAttack + colleftInfo[self:getId()].attributesItems[7].value
		end
		if colleftInfo[self:getId()].attributesItems[30] then
			local pct = colleftInfo[self:getId()].attributesItems[30].value or 30
			getMagicAttack = math.ceil(getMagicAttack * (1 + pct / 100))
		end
	end
	return getMagicAttack
end

function Player.getPhysicalDamage(self)
	if not self then return 0 end
	local getPhysicalDamage = 0
	if colleftInfo[self:getId()].attributesItems[3] then
		getPhysicalDamage = getPhysicalDamage + colleftInfo[self:getId()].attributesItems[3].value
	end
	return getPhysicalDamage
end

function Player.getMagicDamage(self)
	if not self then return 0 end
	local getMagicDamage = 0
	if colleftInfo[self:getId()].attributesItems[4] then
		getMagicDamage = getMagicDamage + colleftInfo[self:getId()].attributesItems[4].value
	end
	return getMagicDamage
end

function Player.getPhysicalDefense(self)
	if not self then return 0 end
	local getPhysicalDefense = 0
	getPhysicalDefense = CHAMPION_STATS[self:getVocation():getName()].physical_defense + (((CHAMPION_STATS[self:getVocation():getName()].physical_defensePL - CHAMPION_STATS[self:getVocation():getName()].physical_defense) / 50) * self:getLevel())
	if colleftInfo[self:getId()].attributesItems[8] then
		getPhysicalDefense = getPhysicalDefense + colleftInfo[self:getId()].attributesItems[8].value
	end
	return getPhysicalDefense
end

function Player.getPhysicalDefensePercent(self)
	if not self then return 0 end
	local getPhysicalDefensePercent = math.ceil((self:getPhysicalDefense() / (100 + self:getPhysicalDefense())) * 100)
	return getPhysicalDefensePercent
end


function Player.getMagicDefense(self)
	if not self then return 0 end
	local getMagicDefense = 0
	getMagicDefense = CHAMPION_STATS[self:getVocation():getName()].magic_defense + (((CHAMPION_STATS[self:getVocation():getName()].magic_defensePL - CHAMPION_STATS[self:getVocation():getName()].magic_defense) / 50) * self:getLevel())
	if colleftInfo[self:getId()].attributesItems[9] then
		getMagicDefense = getMagicDefense + colleftInfo[self:getId()].attributesItems[9].value
	end
	return getMagicDefense
end

function Player.getMagicDefensePercent(self)
	if not self then return 0 end
	local getMagicDefensePercent = math.ceil((self:getPhysicalDefense() / (100 + self:getPhysicalDefense())) * 100)
	return getMagicDefensePercent
end

function Player.getMonsterPhysicalDefensePercent(self)
	if not self then return 0 end
	local getPhysicalDefensePercent = math.ceil((MONSTER_CONFIG[self:getType():tier()].physical_defense / (100 + MONSTER_CONFIG[self:getType():tier()].physical_defense)) * 100)
	return getPhysicalDefensePercent
end
function Player.getMonsterMagicDefensePercent(self)
	if not self then return 0 end
	local getMagicDefensePercent = math.ceil((MONSTER_CONFIG[self:getType():tier()].magic_defense / (100 + MONSTER_CONFIG[self:getType():tier()].magic_defense)) * 100)
	return getMagicDefensePercent
end

function Player.getPhysicalSteal(self)
	if not self then return 0 end
	local getPhysicalSteal = 0
	local pInfo = colleftInfo[self:getId()]
	if pInfo and pInfo.attributesItems and pInfo.attributesItems[17] then
		getPhysicalSteal = getPhysicalSteal + (tonumber(pInfo.attributesItems[17].value) or 0)
	end
	return getPhysicalSteal
end

function Player.getMagicSteal(self)
	if not self then return 0 end
	local getMagicSteal = 0
	local pInfo = colleftInfo[self:getId()]
	if pInfo and pInfo.attributesItems and pInfo.attributesItems[18] then
		getMagicSteal = getMagicSteal + (tonumber(pInfo.attributesItems[18].value) or 0)
	end
	return getMagicSteal
end

function Player.getPhysicalPenetration(self)
	if not self then return 0 end
	local getPhysicalPenetration = 0
	local pInfo = colleftInfo[self:getId()]
	if pInfo and pInfo.attributesItems and pInfo.attributesItems[14] then
		getPhysicalPenetration = getPhysicalPenetration + pInfo.attributesItems[14].value
	end
	return getPhysicalPenetration
end

function Player.getMagicPenetration(self)
	if not self then return 0 end
	local getMagicPenetration = 0
	local pInfo = colleftInfo[self:getId()]
	if pInfo and pInfo.attributesItems and pInfo.attributesItems[15] then
		getMagicPenetration = getMagicPenetration + pInfo.attributesItems[15].value
	end
	return getMagicPenetration
end

function calculateUpgradeValue(upgradeLevel)
    -- Definicje stałych
    local MAX_LEVEL = 10
    local STATIC_BONUS_ABOVE_MAX = 10
    local VALUE_PER_LEVEL_1_TO_10 = 5 -- NOWA STAŁA: Wartość dodawana za każdy poziom 1-10
    
    -- Obliczamy wartość bazową dla Poziomu 10 zgodnie z nową logiką:
    -- Wartość na poziomie 10 to: 10 * 5 = 50
    local VALUE_AT_MAX = MAX_LEVEL * VALUE_PER_LEVEL_1_TO_10
    
    -- Sprawdzamy, czy poziom jest w zakresie 1-10
    if upgradeLevel <= MAX_LEVEL then
        -- Jeśli tak, używamy nowej formuły: poziom * stała wartość (5)
        -- Ta formuła zastępuje oryginalną formułę sumy ciągu arytmetycznego
        return upgradeLevel * VALUE_PER_LEVEL_1_TO_10
    else
        -- Jeśli poziom jest powyżej 10:
        -- 1. Obliczamy liczbę poziomów ponad 10
        local levelsAboveMax = upgradeLevel - MAX_LEVEL
        
        -- 2. Obliczamy dodatkowy bonus (stała wartość 10 * liczba poziomów)
        local extraBonus = levelsAboveMax * STATIC_BONUS_ABOVE_MAX
        
        -- 3. Sumujemy nową wartość bazową (50) z dodatkowym bonusem
        return VALUE_AT_MAX + extraBonus
    end
end

function sendAreaProjectiles(fromPos, area, effect, distance)
  local centerY = math.ceil(#area / 2)
  local centerX = math.ceil(#area[1] / 2)

  for y = 1, #area do
    for x = 1, #area[y] do
      if area[y][x] == 1 then
        local dx = x - centerX
        local dy = y - centerY
        local toPos = Position(fromPos.x + dx, fromPos.y + dy, fromPos.z)
		if effect then
			toPos:sendMagicEffect(effect)
		end
		if distance then
       		fromPos:sendDistanceEffect(toPos, distance)
		end
      end
    end
  end
end

function highestStat(player)
	if not player then return 0 end
	local highStat = math.max(player:getEffectiveSkillLevel(SKILL_MELEE), player:getEffectiveSkillLevel(SKILL_FISHING) ,player:getEffectiveSkillLevel(SKILL_DISTANCE))
	return highStat
end

function selfBoost(player, buffId, buffName)
	local extraTextInfo = "activated"
	local showText = true
	if player:hasBuff(buffId) then
		extraTextInfo = "extended"
		showText = false
	end
	local textChat = "You have " .. extraTextInfo .. " a Self " .. buffName .. " Boost"
	local textBr = " You have " ..
	extraTextInfo ..
	" a {Self " .. buffName .. " Boost}!\nYou gain +20% " .. buffName .. " for the next 60 minutes!\nTime to grind!"
	player:sendExtendedOpcode(71, json.encode({ text = textBr, color = "#f7ef8a" }))
	player:sendTextMessage(MESSAGE_EVENT_ORANGE, textChat)
	if showText then
		player:sendTextMessage(MESSAGE_EVENT_ORANGE, "You gain +20% " .. buffName .. " for the next 60 minutes!")
	end
	player:addBuff(buffId, 60 * 60 * 1000)
	return true
end

function selfBoostAll(player)
	local textChat = "You gain +20% EXP/GOLD/LOOT for the next 60 minutes!\nTime to grind!"
	local textBr = "You gain +{20}% EXP/GOLD/LOOT for the next {60} minutes!\nTime to grind!"
	player:sendExtendedOpcode(71, json.encode({ text = textBr, color = "#f7ef8a" }))
	player:sendTextMessage(MESSAGE_EVENT_ORANGE, textChat)
	player:addBuff(BUFF_EXP_BOOST, 60 * 60 * 1000)
	player:addBuff(SELF_GOLD_BOOST, 60 * 60 * 1000)
	player:addBuff(SELF_LOOT_BOOST, 60 * 60 * 1000)
	return true
end

function shockChance(player)
	if not player then return end
	local extraChance = 0
	if colleftInfo[player:getId()].attributesItems[41] then -- shock chance
		extraChance = extraChance + colleftInfo[player:getId()].attributesItems[41].value
	end
	if player:hasBuff(DRUID_TRAIT) then
		extraChance = extraChance + 20
	end
	if colleftInfo[player:getId()].attributesItems[210] then -- all aliments chance
		extraChance = extraChance + colleftInfo[player:getId()].attributesItems[210].value
	end
	return extraChance
end
function chillChance(player)
	if not player then return end
	local extraChance = 0
	if colleftInfo[player:getId()].attributesItems[37] then -- chill chance
		extraChance = extraChance + colleftInfo[player:getId()].attributesItems[37].value
	end
	if player:hasBuff(DRUID_TRAIT) then
		extraChance = extraChance + 20
	end
	if colleftInfo[player:getId()].attributesItems[210] then -- all aliments chance
		extraChance = extraChance + colleftInfo[player:getId()].attributesItems[210].value
	end
	return extraChance
end
function poisonChance(player)
	if not player then return end
	local extraChance = 0
	if colleftInfo[player:getId()].attributesItems[32] then -- poison chance
		extraChance = extraChance + colleftInfo[player:getId()].attributesItems[32].value
	end
	if player:hasBuff(DRUID_TRAIT) then
		extraChance = extraChance + 20
	end
	if colleftInfo[player:getId()].attributesItems[210] then -- all aliments chance
		extraChance = extraChance + colleftInfo[player:getId()].attributesItems[210].value
	end
	return extraChance
end
function igniteChance(player)
	if not player then return end
	local extraChance = 0
	if colleftInfo[player:getId()].attributesItems[28] then -- ignite chance
		extraChance = extraChance + colleftInfo[player:getId()].attributesItems[28].value
	end
	if player:hasBuff(DRUID_TRAIT) then
		extraChance = extraChance + 20
	end
	if colleftInfo[player:getId()].attributesItems[210] then -- all aliments chance
		extraChance = extraChance + colleftInfo[player:getId()].attributesItems[210].value
	end
	return extraChance
end
function bleedChance(player)
	if not player then return end
	local extraChance = 0
	if colleftInfo[player:getId()].attributesItems[21] then -- bleed chance
		extraChance = extraChance + colleftInfo[player:getId()].attributesItems[21].value
	end
	if player:hasBuff(DRUID_TRAIT) then
		extraChance = extraChance + 20
	end
	if colleftInfo[player:getId()].attributesItems[210] then -- all aliments chance
		extraChance = extraChance + colleftInfo[player:getId()].attributesItems[210].value
	end
	return extraChance
end
function harvestChance(player)
	if not player then return end
	local extraChance = 0
	if colleftInfo[player:getId()].attributesItems[42] then -- harvest chance
		extraChance = extraChance + colleftInfo[player:getId()].attributesItems[42].value
	end
	if player:hasBuff(DRUID_TRAIT) then
		extraChance = extraChance + 20
	end
	if colleftInfo[player:getId()].attributesItems[210] then -- all aliments chance
		extraChance = extraChance + colleftInfo[player:getId()].attributesItems[210].value
	end
	return extraChance
end
function suppressionChance(player)
	if not player then return end
	local extraChance = 0
	if colleftInfo[player:getId()].attributesItems[45] then -- suppresion chance
		extraChance = extraChance + colleftInfo[player:getId()].attributesItems[45].value
	end
	if player:hasBuff(DRUID_TRAIT) then
		extraChance = extraChance + 20
	end
	if colleftInfo[player:getId()].attributesItems[210] then -- all aliments chance
		extraChance = extraChance + colleftInfo[player:getId()].attributesItems[210].value
	end
	return extraChance
end
function getMonsterLevelByKeyTier(keyTier)
    local level = 105
    if keyTier <= 0 then
        return level
    end

    for tier = 2, keyTier do
        if level < 200 then -- 20 Tier
            level = math.min(level + 5, 200)
        elseif level < 500 then -- 50 tier
            level = math.min(level + 10, 500)
        elseif level < 800 then -- 70 tier
            level = math.min(level + 15, 800)
        elseif level < 1200 then -- 90 tier
            level = math.min(level + 20, 1200)
        elseif level < 2250 then -- 90 tier
            level = math.min(level + 30, 2250)
        else -- 125+
            level = level + 100
        end
    end

    return level
end

function getKeyTierByMonsterLevel(monsterLevel)
    local level = 105
    local tier = 1

    if monsterLevel <= level then
        return tier
    end

    while level < monsterLevel do
        tier = tier + 1

        if level < 200 then
            level = math.min(level + 5, 200)
        elseif level < 500 then
            level = math.min(level + 10, 500)
        elseif level < 800 then
            level = math.min(level + 15, 800)
        elseif level < 1200 then
            level = math.min(level + 20, 1200)
        elseif level < 2250 then -- 90 tier
            level = math.min(level + 30, 2250)
        else
            level = level + 100
        end
    end

    return tier
end

-- Function to apply monster modifiers and storage values
function applyMonsterModifiers(monster, config, instance)
	if not monster or monster:isRemoved() then
		print("ERROR: Invalid monster in applyMonsterModifiers")
		return false
	end
	if not config then
		print("ERROR: No config provided in applyMonsterModifiers")
		return false
	end
	if not instance then
		print("ERROR: No instance provided in applyMonsterModifiers")
		return false
	end
	for index, storageKey in pairs(DUNGEON_MOD_ATTR_ADDED) do
		local value = config[index] or 0
		if value > 0 then
			monster:setStorageValue(storageKey, value)
			if index == 11 then
				local sped = value
				local Chilling = Condition(CONDITION_PARALYZE)
				Chilling:setParameter(CONDITION_PARAM_TICKS, -1)
				Chilling:setParameter(CONDITION_PARAM_SPEED, sped)
				monster:addCondition(Chilling)
			end
		end
	end
	instance:addMonster(monster)
	monster:setStorageValue(PlayerStorage.keyTier, config.tier)
	monster:setStorageValue(PlayerStorage.monsterModifier_bonus, config.bonus)
	monster:setStorageValue(PlayerStorage.monsterModifier_partyBonus, config.partyBonus)
	if config.tier >= 1 then
		monster:setStorageValue(PlayerStorage.keyTier, config.tier)
	end
end

function decodeItemType(mask)
	local result = {}
	for _, value in pairs(US_ITEM_TYPES) do
		if bit.band(mask, value) == value then
			if value == US_ITEM_TYPES.RELICT_ANY then
				for _, v in pairs(RELICTS_TYPES) do
					table.insert(result, v)
				end
			elseif value == US_ITEM_TYPES.WEAPON_ANY then
				for _, v in pairs(INDIVIDUAL_WEAPON_TYPES) do
					table.insert(result, v)
				end
			elseif value == US_ITEM_TYPES.WEAPON_MELEE then
				for _, v in pairs(WEAPON_MELEE_TYPES) do
					table.insert(result, v)
				end
			else
				table.insert(result, value)
			end
		end
	end
	return result
end

function generateEncantmentsByItemType()
	for i = 1, #US_ENCHANTMENTS do
		local enchant = US_ENCHANTMENTS[i]
		local itemType = enchant.itemType
		local disabledTypes = enchant.disableItemTypes
		if enchant.minLevel and enchant.minLevel == 2000 then
			goto skip
		end

		if itemType then
			local itemTypes = {}
			if itemType == US_ITEM_TYPES.ALL then
				itemTypes = US_ITEM_TYPES
			elseif itemType == US_ITEM_TYPES.WEAPON_MELEE then
				itemTypes = WEAPON_MELEE_TYPES
			elseif itemType == US_ITEM_TYPES.WEAPON_ANY then
				itemTypes = INDIVIDUAL_WEAPON_TYPES
			elseif itemType == US_ITEM_TYPES.RELICT_ANY then
				itemTypes = RELICTS_TYPES
			else
				itemTypes = decodeItemType(enchant.itemType)
			end

			for _, bitData in pairs(itemTypes) do
				if disabledTypes then
					if bit.band(disabledTypes, bitData) ~= 0 then
						goto continue
					end
				end
				if not US_ENCHANTMENTS_ITEMTYPE[bitData] then
					US_ENCHANTMENTS_ITEMTYPE[bitData] = {}
				end

				enchant.id = i
				local levelRequirement = true
				if enchant.minLevel and enchant.minLevel == 2000 then
					levelRequirement = false
				end

				if levelRequirement then
					table.insert(US_ENCHANTMENTS_ITEMTYPE[bitData], enchant)
				end

				::continue::
			end
		end

		::skip::
	end
end
generateEncantmentsByItemType()

PLAYER_REGEN_EVENTS = {}

convertVocation = {
	[0] = 0,
	1, 2, 3, 4,
	1, 2, 3, 4,
	1, 2, 3, 4,
	1, 2, 3, 4,
	17, 17, 17, 17,
	21, 21, 21, 21
  }

 IMPLICT_BONUS = {
	[8] = {30, 30},  -- block chance
	[19] = {4, 10},  -- basic damage
	[27] = {3, 5},   -- movement speed
	[89] = {2, 6},   -- melee damage
	[90] = {2, 6},   -- magic damage
	[91] = {2, 6},    -- ranged damage
	[96] = {2, 6},    -- shield damage
	[29] = {1, 3},    -- critical chance
	[9] = {1, 2},    -- dodge
	[35] = {1, 2},    -- spell avoid
	[18] = {1, 3},    -- spell damage
	[12] = {1, 3},    -- elemental damage
	[196] = {1, 3},    -- duality damage
	[108] = {1, 3}, -- brute damage
	[1] = {25, 50},    -- health
	[71] = {25, 50},    -- Energy Shield
	[53] = {5, 15},    -- armor
	[55] = {2, 5},    -- attack speed
	[210] = {2, 5},    -- ailment chance
	[56] = {1, 3},    -- cooldown reduction
	[31] = {1, 2}, -- physical panetration damage
	[122] = {1, 2}, -- elemental panetration damage
	[198] = {1, 2}, -- duality panetration damage
	[11] = {2, 10}, -- zywioly damage
	[57] = {2, 10}, -- zywioly damage
	[58] = {2, 10}, -- zywioly damage
	[59] = {2, 10}, -- zywioly damage
	[60] = {2, 10}, -- zywioly damage
	[61] = {2, 10}, -- zywioly damage
	[62] = {2, 10}, -- zywioly damage
	[13] = {1, 3}, -- ele prot
	[14] = {1, 3}, -- phys prot
	[197] = {1, 3}, -- duality prot
	[47] = {2, 10} -- dot damage
}

 KEY_TIER_MULTIPLER = {
    [1] = 110,
    [2] = 115,
    [3] = 120,
    [4] = 125,
    [5] = 130,
    [6] = 135,
    [7] = 140,
    [8] = 150,
    [9] = 160,
    [10] = 200, -- Boss 250
    [11] = 215,
    [12] = 230,
    [13] = 245,
    [14] = 425,
    [15] = 450,
    [16] = 475,
    [17] = 500,
    [18] = 525,
    [19] = 550,
	[20] = 500, -- Boss 550
	[21] = 525,
	[22] = 550,
	[23] = 575,
	[24] = 600,
	[25] = 625,
	[26] = 650,
	[27] = 675,
	[28] = 700,
	[29] = 725,
	[30] = 750, -- Boss 800
	[31] = 800,
	[32] = 830,
	[33] = 860,
	[34] = 890,
	[35] = 920,
	[36] = 950,
	[37] = 980,
	[38] = 1010,
	[39] = 1040,
	[40] = 1070,
	[41] = 1100,
	[42] = 1130,
	[43] = 1160,
	[44] = 1190,
	[45] = 1220,
	[46] = 1250,
	[47] = 1280,
	[48] = 1310,
	[49] = 1340,
	[50] = 1370,
  }

function applyResourceRegen(player, resource, regenPercent, duration, eventId, buffIcon)
    if not player then return end
    local id = player:getId()
    if duration <= 0 then duration = 1 end
    -- Walidacja resource
    if resource ~= "health" and resource ~= "mana" and resource ~= "energyshield" then
        print("Warning: invalid resource type:", resource)
        return
    end

    -- Inicjalizacja tabeli gracza
    PLAYER_REGEN_EVENTS[id] = PLAYER_REGEN_EVENTS[id] or {}

    -- Zatrzymanie poprzedniego eventu o tym samym ID
    if PLAYER_REGEN_EVENTS[id][eventId] then
        stopEvent(PLAYER_REGEN_EVENTS[id][eventId])
        PLAYER_REGEN_EVENTS[id][eventId] = nil
    end

    -- Funkcja dodająca regen
    local function addRegen()
        if player then
            player:addBuff(buffIcon)
            if resource == "health" and type(player.addHealthPrecentGain) == "function" then
                player:addHealthPrecentGain(eventId, regenPercent, true)
            elseif resource == "mana" and type(player.addManaPrecentGain) == "function" then
                player:addManaPrecentGain(eventId, regenPercent, true)
            elseif resource == "energyshield" and type(player.addEnergyShieldGain) == "function" then
                player:addEnergyShieldGain(eventId, regenPercent, true)
            end
        end
    end

    -- Funkcja usuwająca regen
    local function removeRegen()
        local p = Player(id)
        if p then
            p:removeBuff(buffIcon)
            if resource == "health" and type(p.removeHealthPrecentGain) == "function" then
                p:removeHealthPrecentGain(eventId)
            elseif resource == "mana" and type(p.removeManaPrecentGain) == "function" then
                p:removeManaPrecentGain(eventId)
            elseif resource == "energyshield" and type(p.removeEnergyShieldGain) == "function" then
                p:removeEnergyShieldGain(eventId)
            end
        end
        if PLAYER_REGEN_EVENTS[id] then
            PLAYER_REGEN_EVENTS[id][eventId] = nil
        end
    end

    -- Dodanie regeneracji i ustawienie eventu do jej zdjęcia po czasie
    addRegen()
    PLAYER_REGEN_EVENTS[id][eventId] = addEvent(removeRegen, duration * 1000)
end

function resourceRegen(player, HP, duration, eventId, regenType)
    if not player then return end
    local id = player:getId()
    if not eventId then return end
    if not duration or duration <= 0 then duration = 1 end

    -- Inicjalizacja struktury dla eventów gracza
    PLAYER_REGEN_EVENTS[id] = PLAYER_REGEN_EVENTS[id] or {}

    -- Jeśli istnieje zdarzenie z tym samym eventId, zatrzymujemy je
    if PLAYER_REGEN_EVENTS[id][eventId] then
        stopEvent(PLAYER_REGEN_EVENTS[id][eventId])
        PLAYER_REGEN_EVENTS[id][eventId] = nil
    end

    -- Dodanie regeneracji
    if regenType == "health" and type(player.addHealthGain) == "function" then
        player:addHealthGain(eventId, HP / duration, true)
    elseif regenType == "mana" and type(player.addManaGain) == "function" then
        player:addManaGain(eventId, HP / duration, true)
    elseif regenType == "energyshield" and type(player.addEnergyShieldGainForce) == "function" then
        player:addEnergyShieldGainForce(eventId, HP / duration, true)
    else
        print("Warning: invalid regenType or missing function:", regenType)
        return
    end

    -- Dodanie zdarzenia, które usunie regenerację po czasie
    PLAYER_REGEN_EVENTS[id][eventId] = addEvent(function()
        local p = Player(id)
        if p then
            if regenType == "health" and type(p.removeHealthGain) == "function" then
                p:removeHealthGain(eventId, true)
            elseif regenType == "mana" and type(p.removeManaGain) == "function" then
                p:removeManaGain(eventId, true)
            elseif regenType == "energyshield" and type(p.removeEnergyShieldGainForce) == "function" then
                p:removeEnergyShieldGainForce(eventId, true)
            end
        end
        if PLAYER_REGEN_EVENTS[id] then
            PLAYER_REGEN_EVENTS[id][eventId] = nil
        end
    end, duration * 1000)
end

function totalAttackPower(player, type, spellId, baseChange, shield)
	if not player then
		return false
	end 
	local attackpower = player:getTotalAttack() -- colleftInfo[player:getId()].attackPower -- player:getTotalAttack() -- colleftInfo[player:getId()].attackPower
	if shield then
		if colleftInfo[player:getId()] and colleftInfo[player:getId()].attributesItems[96] then
			attackpower = attackpower + (colleftInfo[player:getId()].attributesItems[96].value * 2)
		end
	end
	if baseChange and baseChange > 0 then attackpower = baseChange end
	if spellId and spellId > 0 then
		if GLOBAL_SPELL_COOLDOWNS[spellId] then
			local attributeId = ({ [1] = 90, [2] = 89, [3] = 91 })
			[GLOBAL_SPELL_COOLDOWNS[spellId].addDamage]
			if attributeId and colleftInfo[player:getId()].attributesItems[attributeId] then
				attackpower = attackpower + colleftInfo[player:getId()].attributesItems[attributeId].value
			end
		end
	else
		for i = 89, 91 do
			attackpower = attackpower + (colleftInfo[player:getId()].attributesItems[i] and colleftInfo[player:getId()].attributesItems[i].value or 0)
		end
	end
	if colleftInfo[player:getId()].attributesItems[171] then -- Added Adaptive Damage
		attackpower = attackpower + colleftInfo[player:getId()].attributesItems[171].value
	end
	if colleftInfo[player:getId()].attributesItems[217] then -- unique Adaptive
		local levelCap = math.min(player:getLevel(), 100)
		attackpower = attackpower + levelCap * (colleftInfo[player:getId()].attributesItems[217].value * US_ENCHANTMENTS[217].subvalue)
	end
	if type == 2000 then
		for i = 68, 70 do
			attackpower = attackpower + (colleftInfo[player:getId()].attributesItems[i] and colleftInfo[player:getId()].attributesItems[i].value or 0)
		end
	elseif type then
		for id = 68, 70 do
			local enchant = US_ENCHANTMENTS[id]
			if enchant and bit.band(enchant.combatDamage, type) ~= 0 then
				local attr = colleftInfo[player:getId()].attributesItems[id]
				if attr then
					attackpower = attackpower + attr.value
				end
			end
		end
	end
	if player:getStorageValue(PlayerStorage.specialization) > 0 then -- 20% wiecej attack power z specializacji
		local added = math.ceil(attackpower * 0.20) -- (0.05 + 0.0025 * player:getBuff(v.buff).stacks)
		attackpower = attackpower + added
	end
	--[[
	for _, v in ipairs(PATH_BUFFS) do
		if player:hasBuff(v.buff) then
			local added = math.ceil(attackpower * 0.20) -- (0.05 + 0.0025 * player:getBuff(v.buff).stacks)
			attackpower = attackpower + added
		end
	end
	--]]
	return attackpower
end

function getDetails(target)
	local attrs = colleftInfo[target:getId()].attributesItems


	local attackspeed = math.floor((1000 / target:getAttackSpeed()) * 100 + 0.5) / 100
	local attackspeedPercent = target:getVarStats(STAT_ATTACKSPEED)
	local movementSpeedPercent = (((200 - target:getSpeed()) / 200) * 100) * -1
	local details = {}
	details[1] = target:getMaxHealth()
	details[2] = math.floor(target:getTotalHealthGain())
	details[3] = target:getMaxMana()
	details[4] = math.floor(target:getTotalManaGain())
	details[5] = math.ceil(target:getPhysicalAttack())
	details[6] = math.ceil(target:getMagicAttack())
	details[7] = math.ceil(target:getPhysicalDefense())
	details[8] = math.ceil(target:getMagicDefense())
	details[9] = string.format("%.2f | %s%%", attackspeed, attackspeedPercent)
	details[10] = target:getCooldownReduction()
	details[11] = target:getPhysicalSteal()
  	details[12] = target:getMagicSteal()
  	details[13] = target:getPhysicalPenetration() -- target:getSpecialSkill(SPECIALSKILL_MANALEECHAMOUNT)
  	details[14] = target:getMagicPenetration() -- target:getSpecialSkill(SPECIALSKILL_MANALEECHAMOUNT)
	details[15] = target:getSpecialSkill(SPECIALSKILL_CRITICALHITCHANCE)
	details[16] = target:getSpecialSkill(SPECIALSKILL_CRITICALHITAMOUNT)
	details[17] = string.format("%s | %s%%", target:getSpeed(), movementSpeedPercent) -- target:getSpeed()
	details[18] = 0 -- Resilience
	return details
  end

  --[[
details[1] = target:getMaxHealth()
  details[2] = target:getMaxMana()
  details[3] = math.ceil(target:getPhysicalAttack())
  details[4] = math.ceil(target:getMagicAttack())
  details[5] = math.ceil(target:getPhysicalDefense())
  details[6] = math.ceil(target:getMagicDefense())
  details[7] = target:getAttackSpeedValue()
  details[8] = target:getHaste()
  details[9] = target:getHealthRegen()
  details[10] = target:getManaRegen()
  details[11] = target:getPhysicalSteal()
  details[12] = target:getMagicSteal()
  details[13] = target:getPhysicalPenetration() -- target:getSpecialSkill(SPECIALSKILL_MANALEECHAMOUNT)
  details[14] = target:getMagicPenetration() -- target:getSpecialSkill(SPECIALSKILL_MANALEECHAMOUNT)
  details[15] = target:getSpeed()
  details[16] = target:getSpecialSkill(SPECIALSKILL_CRITICALHITCHANCE)
  details[17] = target:getSpecialSkill(SPECIALSKILL_CRITICALHITAMOUNT)
  --]]

CHANNEL_LOOT = 15

CREATURE_ACTIVE_BUFFS = {}
GLOBAL_ACTIVE_BUFFS = {}
AUTOLOOT_LIST = {}

GLOBAL_MULTIPLERS = {
	["exp"] = 0.35,
	["gold"] = 1.1,
	["damage"] = 4.0,
	["damageStart"] = 23,
	["health"] = 3,
	["elite"] = 3,
	["elite_damage_multipler"] = 50, -- 50% more damage
	["titan_damage_multipler"] = 50, -- 50% more damage
	["strongbox_damage_multipler"] = 50, -- 50% wiecej damage
	["champion_damage_multipler"] = 50, -- + elite 50 = 100% damage
	["eliteStrong_damage_multipler"] = 25, -- 50+25 = 75%
}
BOSSESS_DAMAGE_AUTO = {

}
BOSSESS_DAMAGE = {
	-- Titans
	-- ["Lava Golem"] = 300, -- 20mlvl
	-- ["Netherbane"] = 390, -- 29mlvl
	-- Dungeon Bosses
	-- ["Vampire Queen"] = 300, -- 25mlvl
	-- ["Pheonix"] = 410, -- 40mlvl
	-- ["Toxic Hydra"] = 500, -- 55mlvl
	-- Champions
	-- "War Wolf"
	-- "Behemoth"
	--[[
	["Twistgrove"] = 1,
	["Seano"] = 1,
	["Boa"] = 1,
	["Frogy"] = 1,
	["Minn"] = 1,
	["Tuu"] = 1,
	["Urna"] = 1,
	["Brute"] = 1,
	["Behemoth"] = 1,
	["War Wolf"] = 1,
	--]]
	-- ["Emberlord"] = 500,
	-- ["Voidlord"] = 1200,

}

ExtendedOPCodes = {
	CODE_MARKET = 38, --38 39
	CODE_SALVAGE = 53,
	CODE_TASKS = 96,
	CODE_BUFF = 100,
	CODE_GAMESTORE = 102,
	CODE_TOOLTIP = 105,
	CODE_ATTRIBUTE_SKILLS = 110,
	CODE_BATTLE_PASS = 111,
	CODE_ATTRIBUTE_SLOTS = 112,
	CODE_CORPSE_POS = 114,
	CODE_LOOT = 115,
	CODE_ENCHANTMENTS = 199,
	CODE_CHARSTATS = 200,
	CODE_INSPECT = 201,
	CODE_CRAFTING = 202,
	CODE_DUNGEONS = 203,
	CODE_BOSSBAR = 204,
	CODE_LOOK_TOOLTIP = 205,
	CODE_UPGRADE_ITEMS = 206,
	CODE_DAILY_REWARDS = 207,
	CODE_WAYPOINTS = 208,
	CODE_PETS = 209,
	CODE_RAGE = 210,
	CODE_TALENTS = 211,
	CODE_SPELLS = 212,
	CODE_UPGRADE_PLUS_ITEMS = 213,
	CODE_PRIVATE_SHOP = 214,
	CODE_OPTIONS = 215,
	CODE_REWARD = 216,
	CODE_TILEWIDGET = 217,
	CODE_DAILYQUEST = 218,
	LOOT = 219,
	CODE_CONTAINER = 220,
	CODE_INVENTORY = 221,
	CODE_FORGE = 224,
	CODE_OUTFITS = 225,
	CODE_TRADE = 226,
	CODE_CASTSPELL = 227,
	CODE_SPELLTOOLTIP = 228,
	CODE_CRYSTALS = 229,
	CODE_LOOTINFO = 230,
	CODE_ROCOMBOBULATOR = 231,
	CODE_RELICTBOX = 232,
	CODE_QUESTTRACKER = 233,
	CODE_TUTORIAL = 234,
	CODE_HOUSE = 235,
	CODE_MERGE_ITEMS = 236,
}

UNIQUE_BOSS_STORAGES = {}

EXALTED_ITEMS = {
--	level, chance, chance 7
	85, 1, 1, HEROIC
}
TIER_AFFIXES = {
	-- chance, Tier, odMonsterLevel, 
	{ 3000,   5, 45 },
	{ 10000,  4, 35 },
	{ 30000,  3, 20 },
	{ 50000,  2, 8 },
	{ 100000, 1, 1 },
  }

FORGE_POTENCIAL_RANDOM = {
	[1] = {min = 15, max = 30}, -- basic
	[2] = {min = 31, max = 45}, -- champion
	[3] = {min = 35, max = 50}, -- world boss 70% wiecej ?
	[4] = {min = 15, max = 30}, -- rare elite - 40% podstawy
	[5] = {min = 25, max = 40}, -- dungeons - 10%-60% w zaleznosci od poziomu trudnosci
   }


ArrowBoltAnimation = {
	[1] = CONST_ANI_THROWINGKNIFE,
	[36675] = CONST_77,
	[36676] = CONST_78,
	[36677] = CONST_79,
	[36678] = CONST_80,
	[36679] = CONST_81,
	[36680] = CONST_82,
	[36681] = CONST_83,
	[36682] = CONST_84,
	[2543] = CONST_ANI_BOLT,
	[2547] = CONST_ANI_POWERBOLT,
	[6529] = CONST_ANI_INFERNALBOLT,
	[7363] = CONST_ANI_PIERCINGBOLT,
	[15649] = CONST_ANI_VORTEXBOLT,
	[18435] = CONST_ANI_PRISMATICBOLT,
	[18436] = CONST_ANI_DRILLBOLT,
	[2544] = CONST_ANI_ARROW,
	[2545] = CONST_ANI_POISONARROW,
	[2546] = CONST_ANI_BURSTARROW,
	[7365] = CONST_ANI_ONYXARROW,
	[7364] = CONST_ANI_SNIPERARROW,
	[7838] = CONST_ANI_FLASHARROW,
	[7840] = CONST_ANI_FLAMMINGARROW,
	[7839] = CONST_ANI_SHIVERARROW,
	[7850] = CONST_ANI_EARTHARROW,
	[15648] = CONST_ANI_TARSALARROW,
	[18437] = CONST_ANI_ENVENOMEDARROW,
	[18304] = CONST_ANI_CRYSTALLINEARROW,

	[2111] = CONST_ANI_SNOWBALL,
	[2389] = CONST_ANI_SPEAR,
	[3965] = CONST_ANI_HUNTINGSPEAR,
	[7367] = CONST_ANI_ENCHANTEDSPEAR,
	[7378] = CONST_ANI_ROYALSPEAR,
	[2399] = CONST_ANI_THROWINGSTAR,
	[7368] = CONST_ANI_REDSTAR,
	[7366] = CONST_ANI_GREENSTAR,
	[2410] = CONST_ANI_THROWINGKNIFE
}

Effect_Damage = {
	[7840] = COMBAT_FIREDAMAGE,
	[7850] = COMBAT_EARTHDAMAGE,
	[7838] = COMBAT_ENERGYDAMAGE,
	[7839] = COMBAT_ICEDAMAGE,
	[15648] = CONST_ANI_TARSALARROW,
}

element_names = {
	[1] = "Physical",  --COMBAT_PHYSICALDAMAGE,
	[2] = "Energy",    --COMBAT_ENERGYDAMAGE,
	[4] = "Earth",     --COMBAT_EARTHDAMAGE,
	[8] = "Fire",      --COMBAT_FIREDAMAGE,
	[16] = "Penetration", --COMBAT_UNDEFINEDDAMAGE,
	[32] = "Lifedrain", --COMBAT_LIFEDRAIN,
	[64] = "Manadrain", --COMBAT_MANADRAIN,
	[128] = "Healing", --COMBAT_HEALING,
	[256] = "Drown",   --COMBAT_DROWNDAMAGE,
	[512] = "Ice",     --COMBAT_ICEDAMAGE,
	[1024] = "Holy",   --COMBAT_HOLYDAMAGE,
	[2048] = "Death",  --COMBAT_DEATHDAMAGE,
}
element_id_to_combat = {
	[1] = COMBAT_PHYSICALDAMAGE, -- 1
	[2] = COMBAT_ENERGYDAMAGE,  -- 2
	[4] = COMBAT_EARTHDAMAGE,   -- 4
	[8] = COMBAT_FIREDAMAGE,    -- 8
	[16] = COMBAT_UNDEFINEDDAMAGE, -- 16
	[32] = COMBAT_LIFEDRAIN,    -- 32
	[64] = COMBAT_MANADRAIN,    -- 64
	[128] = COMBAT_HEALING,     -- 128
	[256] = COMBAT_DROWNDAMAGE, -- 256
	[512] = COMBAT_ICEDAMAGE,   -- 512
	[1024] = COMBAT_HOLYDAMAGE, -- 1024
	[2048] = COMBAT_DEATHDAMAGE, -- 2048
}

CAP_ATTRIBUTES = {
	[22] = { cap = 85, perItem = 30 }, -- Damage Reduction 2
	[13] = { cap = 85, perItem = 50 }, -- Physical Protection 5
	[14] = { cap = 85, perItem = 50 }, -- Elemental Protection 5
	[21] = { cap = 85, perItem = 30 }, -- Spell Damage Reduction 3

	[55] = { cap = 90, perItem = 25 }, -- Attack Speed
	[56] = { cap = 90, perItem = 15 }, -- Cooldown Reduction
}

 STABLE_ATTRIBUTE = {
	[25] = { block = 10 }, -- Executor
	[38] = { block = 20 }, -- Damage Buff
	[39] = { block = 5 }, -- Critical Chance Buff
	[40] = { block = 30 }, -- Critical Damage Buff
	[15] = { block = 10 }, -- Explosion on Kill
}

TAGS = {
	[1] = {"physical", "#FF0000"},
    [2] = {"fire", "#FF9900"},
	[3] = {"ice", "#99FFFF"},
	[4] = {"magic", "#aa46e3"},
	[5] = {"earth", "#00FF00"},
	[6] = {"death", "#999999"},
	[7] = {"holy", "#FFFF00"},
    [8] = {"int", "#00BBFF"},
	[9] = {"str", "#FF7777"},
	[10] = {"dex", "#00CA00"},
	[11] = {"ranged", "#85c83a"},
	[12] = {"melee", "#fa3302"},
	[13] = {"magic", "#bc17e1"},
	[14] = {"dot", "#42757d"},
	[15] = {"move", "#da932d"},
	[16] = {"wave", "#da932d"},
	[17] = {"path", "#da932d"},
	[18] = {"bounce", "#da932d"},
	[19] = {"projectile", "#da932d"},
	[20] = {"area", "#da932d"},
	[21] = {"close", "#da932d"},
	[22] = {"aura", "#da932d"},
	[23] = {"basic", "#da932d"},
	[24] = {"counter", "#da932d"},
	[25] = {"buff", "#da932d"},
	[26] = {"single", "#da932d"},
	[27] = {"expansion", "#da932d"},
	[28] = {"basic aura", "#da932d"},
	[29] = {"shield", "#da932d"},
}
GLOBAL_SPELL_COOLDOWNS = { -- scaling 1 = "Inteligence", 2 = Strenght, 3 = Dexterity, addDamage 1 = magic, addDamage 2 = melee, addDamage 3 = ranged        PATH nie istnieja mozan dodac cos innego
	[1] = {name = "Fireball", cooldown = 2000, manaCost = 12, range = 5, hits = 1, multipler = 0.8, baseDamage = 30, baseDamagePerLevel = 20, scaling = 1, addDamage = 1, tag = {13, 19, 20}, element = 100, aoe = true},-- "Fireball",
	[2] = {name = "Searing Torrent", cooldown = 3500, manaCost = 15, range = 4, hits = 1, multipler = 0.6, baseDamage = 25, baseDamagePerLevel = 15, scaling = 1, addDamage = 1, tag = {13, 16, 20}, element = 100, aoe = true},-- "Searing Torrent",
	[3] = {name = "Vengeance Flame", cooldown = 3000, manaCost = 20, range = 0, hits = 1, multipler = 0, baseDamage = 0, baseDamagePerLevel = 0, scaling = 1, addDamage = 1, tag = {13, 25}, element = 100, aoe = false},-- "Vengeance Flame",
	[4] = {name = "Thousand Pounder", cooldown = 4000, manaCost = 0, range = 4, hits = 1, multipler = 0.5, baseDamage = 300, baseDamagePerLevel = 60, scaling = 2, addDamage = 2, tag = {12, 15, 20}, element = 100, aoe = true},-- "Thousand Pounder",
	[5] = {name = "Body Slam", cooldown = 3500, manaCost = 0, range = 0, hits = 1, multipler = 0, baseDamage = 270, baseDamagePerLevel = 50, scaling = 2, addDamage = 2, tag = {12, 20, 27}, element = 100, aoe = true},-- "Body Slam",
	[6] = {name = "Heavy Spin", cooldown = 6000, manaCost = 0, range = 0, hits = 4, multipler = 0.3, baseDamage = 150, baseDamagePerLevel = 75, scaling = 2, addDamage = 2, tag = {12, 20, 27}, element = 100, aoe = true},-- "Heavy Spin",
	[7] = {name = "Rapid Fire", cooldown = 8000, manaCost = 0, range = 0, hits = 1, multipler = 0, baseDamage = 0, baseDamagePerLevel = 0, scaling = 2, addDamage = 3, tag = {11, 25}, element = 100, aoe = false},-- "Rapid Fire",
	[8] = {name = "Arrow Volley", cooldown = 4000, manaCost = 0, range = 6, hits = 1, multipler = 0.6, baseDamage = 200, baseDamagePerLevel = 45, scaling = 2, addDamage = 3, tag = {11, 16, 20}, element = 100, aoe = true},-- "Arrow Volley",
	[9] = {name = "Arrow Rain", cooldown = 10000, manaCost = 0, range = 6, hits = 3, multipler = 0.4, baseDamage = 180, baseDamagePerLevel = 50, scaling = 2, addDamage = 3, tag = {11, 20, 27}, element = 100, aoe = true},-- "Arrow Rain",
}
-- SCALING NIE JEST JUZ AKTYWNY!
--[[
TAGS = {
	[1] = {"physical", "#FF0000"},
    [2] = {"fire", "#FF9900"},
	[3] = {"ice", "#99FFFF"},
	[4] = {"Lightning", "#aa46e3"},
	[5] = {"earth", "#00FF00"},
	[6] = {"death", "#999999"},
	[7] = {"holy", "#FFFF00"},
    [8] = {"int", "#00BBFF"},
	[9] = {"str", "#FF7777"},
	[10] = {"dex", "#00CA00"},
	[11] = {"ranged", "#85c83a"},
	[12] = {"melee", "#fa3302"},
	[13] = {"magic", "#bc17e1"},
	[14] = {"dot", "#42757d"},
	[15] = {"move", "#da932d"},
	[16] = {"wave", "#da932d"},
	[17] = {"path", "#da932d"},
	[18] = {"bounce", "#da932d"},
	[19] = {"projectile", "#da932d"},
	[20] = {"area", "#da932d"},
	[21] = {"close", "#da932d"},
	[22] = {"aura", "#da932d"},
	[23] = {"basic", "#da932d"},
	[24] = {"counter", "#da932d"},
	[25] = {"buff", "#da932d"},
	[26] = {"single", "#da932d"},
	[27] = {"aoe", "#da932d"}
}
--]]

GLOBAL_SPELL_NUMBER = {
	[1] = "Fireball",
	[2] = "Searing Torrent",
	[3] = "Vengeance Flame",
	[4] = "Thousand Pounder",
	[5] = "Body Slam",
	[6] = "Heavy Spin",
	[7] = "Rapid Fire",
	[8] = "Arrow Volley",
	[9] = "Arrow Rain",
	[10] = "Anger Aura",
	[11] = "Physical Aura",
	[12] = "Elemental Aura",
	[13] = "Stone Aura",
	[14] = "Magic Aura",
	[15] = "Thornmail Aura",
	[16] = "Aimed Shot",
	[17] = "Wild Vines",
	[18] = "Ricochet",
	[19] = "Firestorm",
	[20] = "Flicker Strike",
	[21] = "Spark",
	[22] = "Cold Snap",
	[23] = "Poison Plague",
	[24] = "Tornado",
	[25] = "Lightning Barrage",
	[26] = "Amok",
	[27] = "Combat Aura",
	[28] = "Perforate",
	[29] = "Leap Slam",
	[30] = "Sunder",
	[31] = "Winter Wind",
	[32] = "Affliction Aura",
	[33] = "Acid Bomb",
	[34] = "Rain Of Arrows",
	[35] = "Illumination",
	[36] = "Holy Dash",
	[37] = "Molten Strike",
	[38] = "Weakness Explosion",
	[39] = "Death Strike",
	[40] = "Earth Bolt",
	[41] = "Rend",
	[42] = "Death Wave",
	[43] = "Ice Surge",
	[44] = "Lava Crash",
	[45] = "Shield Bash",
	[46] = "Black Hole",
	[47] = "Wrath",
	[48] = "Holy Shine",
	[49] = "Frostbolt",
	[50] = "Ball Lightning",
	[51] = "Fire Wall",
	[52] = "Frostbite",
	[53] = "Lightning Arrow",
	[54] = "Rotten Gas Shot",
	[55] = "Phantom Run",
	[56] = "Toxic Arrow",
	[57] = "Plagued Burst",
	[58] = "Shockchain Arrow",
	[59] = "Blazing Shout",
	[60] = "Magma Fissue",
	[61] = "Frozen Stomp",
	[62] = "Shattering Dash",
	[63] = "Blessed Aura",
	[64] = "Hollow Aura",
	[65] = "Frenzy Aura",
	[66] = "Spark Dart",
	[67] = "Maelstrom",
	[68] = "Fire Lance",
	[69] = "Icicle",
	[70] = "Stonefall",
	[71] = "Rootgrasp",
	[72] = "Frigid Split",
	[73] = "Essence Drain",
	[74] = "Tempest",
	[75] = "Blizzard",
	[76] = "Oblivion",
	[77] = "Venom Nova",
	[78] = "Groundbreaker",
	[79] = "Multishot",
	[80] = "Mystic Focus",
    [81] = "Cleave",
    [82] = "Split Arrow",
	[83] = "Fan Knives Aura",
	[84] = "Frozen Shards Aura",
	[85] = "Shield Throw",
    [86] = "Crushing Blow",
	[87] = "Riposte",
	[88] = "Judgement Aura",
	[89] = "Saint Cross",
	[90] = "Flame Tongue",
	[91] = "Venom Arrow Rain",
	[92] = "Frozen Ground",
	[93] = "Sky Shock",
	[94] = "Weapon Throw",
	[95] = "Dancing Steel",
	[96] = "Frosty Link",
	[97] = "Arctic Volley",
	[98] = "Holy Scatter",
	[99] = "Bouncing Venom",
	[100] = "Sacred Lance",
	[101] = "Venom Sting",
	[102] = "Toxic Split",
	[103] = "Stoning",
	[104] = "Flame Sting",
	[105] = "Cold Burst",
	[106] = "Heavy Strike",
	[107] = "Shield Strike",
	[108] = "Dent",
	[109] = "Frosty Bounce",
	[110] = "Thunder Strike",
	[111] = "Blitz",
	[112] = "Static Condition",
	[113] = "Zeus Wrath",
	[114] = "Death Bolt",
	[115] = "Leaping Death",
	[116] = "Rotten Vine",
	[117] = "Black Matter",
	[118] = "Sacred Bolt",
	[119] = "Bloody Skulls",
	[120] = "Hemorrhage Nova",
	[121] = "Vital Surge",
	[122] = "Frosty Sky",
	[123] = "Avoid Aura",

}

function getSpellPowerTotal(player, spellID, item, quality, level)
	if not player then
		return false
	end
	if item == nil then
		return false
	end
	if item:getId() == 0 then
		return false
	end
	if not quality then
		quality = 0
	end
	local extra_damage = 0
	if GLOBAL_SPELL_COOLDOWNS[spellID].element then
		if colleftInfo[player:getId()].attributesItems[GLOBAL_SPELL_COOLDOWNS[spellID].element] then
			extra_damage = extra_damage + (colleftInfo[player:getId()].attributesItems[GLOBAL_SPELL_COOLDOWNS[spellID].element].value * 0.02)
		end
	end
	if colleftInfo[player:getId()].attributesItems[230] then -- Duality Spells
		if GLOBAL_SPELL_COOLDOWNS[spellID].element then
			if GLOBAL_SPELL_COOLDOWNS[spellID].element == 104 or GLOBAL_SPELL_COOLDOWNS[spellID].element == 105 then
				extra_damage = extra_damage + (colleftInfo[player:getId()].attributesItems[230].value * 0.02)
			end
		end
	end
	if colleftInfo[player:getId()].attributesItems[228] then -- Elemental Spells
		if GLOBAL_SPELL_COOLDOWNS[spellID].element then
			if GLOBAL_SPELL_COOLDOWNS[spellID].element >= 100 and GLOBAL_SPELL_COOLDOWNS[spellID].element <= 103 then
				extra_damage = extra_damage + (colleftInfo[player:getId()].attributesItems[228].value * 0.02)
			end
		end
	end
	if colleftInfo[player:getId()].attributesItems[229] then -- Brute Spells
		if GLOBAL_SPELL_COOLDOWNS[spellID].element then
			if GLOBAL_SPELL_COOLDOWNS[spellID].element == 106 then
				extra_damage = extra_damage + (colleftInfo[player:getId()].attributesItems[229].value * 0.02)
			end
		end
	end
	if colleftInfo[player:getId()].attributesItems[262] then -- Basic Spells
		if GLOBAL_SPELL_COOLDOWNS[spellID].basic_aura then
			extra_damage = extra_damage + (colleftInfo[player:getId()].attributesItems[262].value * 0.02)
		end
	end
	extra_damage = extra_damage + (0.01 * quality)
	if level then -- base level spell -- item:getCustomAttribute("level")
		extra_damage = extra_damage + (level * 0.02)
	end
	if colleftInfo[player:getId()].spellallLevels then -- All Spells from orb of Spellweaver
		extra_damage = extra_damage + (colleftInfo[player:getId()].spellallLevels * 0.02)
	end	
	if item:getCustomAttribute("empower_spellrune") then
		extra_damage = extra_damage + (item:getCustomAttribute("empower_spellrune") * 0.02)
	end
	if item:getCustomAttribute("support_level_increased") then
		extra_damage = extra_damage + (item:getCustomAttribute("support_level_increased") * 0.02)
	end
	if colleftInfo[player:getId()].attributesItems[107] then -- All Spells
		extra_damage = extra_damage + (colleftInfo[player:getId()].attributesItems[107].value * 0.02)
	end
	if colleftInfo[player:getId()] then
		if colleftInfo[player:getId()].spellLvl[spellID] then
			extra_damage = extra_damage + (colleftInfo[player:getId()].spellLvl[spellID] * 0.02)
		end
	end
	extra_damage = (extra_damage * 1.5) * GLOBAL_SPELL_COOLDOWNS[spellID].multipler

	return extra_damage
end

function getSpellTotalLevel(player, spellID, item)
	if not player then
		return false
	end
	if item == nil then
		return false
	end
	if item:getId() == 0 then
		return false
	end
	local extra_damage = 0
	if item:getCustomAttribute("empower_spellrune") then
		extra_damage = extra_damage + item:getCustomAttribute("empower_spellrune")
	end
	if item:getCustomAttribute("support_level_increased") then
		extra_damage = extra_damage + item:getCustomAttribute("support_level_increased")
	end
	if colleftInfo[player:getId()].spellallLevels then -- All Spells from orb of Spellweaver
		extra_damage = extra_damage + colleftInfo[player:getId()].spellallLevels
	end		
	if colleftInfo[player:getId()].attributesItems[107] then -- All Spells
		extra_damage = extra_damage + colleftInfo[player:getId()].attributesItems[107].value
	end
	if GLOBAL_SPELL_COOLDOWNS[spellID].element then
		if colleftInfo[player:getId()].attributesItems[GLOBAL_SPELL_COOLDOWNS[spellID].element] then
			extra_damage = extra_damage + colleftInfo[player:getId()].attributesItems[GLOBAL_SPELL_COOLDOWNS[spellID].element].value
		end
	end
	if colleftInfo[player:getId()].attributesItems[230] then -- Duality Spells
		if GLOBAL_SPELL_COOLDOWNS[spellID].element then
			if GLOBAL_SPELL_COOLDOWNS[spellID].element == 104 or GLOBAL_SPELL_COOLDOWNS[spellID].element == 105 then
				extra_damage = extra_damage + colleftInfo[player:getId()].attributesItems[230].value
			end
		end
	end
	if colleftInfo[player:getId()].attributesItems[228] then -- Elemental Spells
		if GLOBAL_SPELL_COOLDOWNS[spellID].element then
			if GLOBAL_SPELL_COOLDOWNS[spellID].element >= 100 and GLOBAL_SPELL_COOLDOWNS[spellID].element <= 103 then
				extra_damage = extra_damage + colleftInfo[player:getId()].attributesItems[228].value
			end
		end
	end
	if colleftInfo[player:getId()].attributesItems[229] then -- Brute Spells
		if GLOBAL_SPELL_COOLDOWNS[spellID].element then
			if GLOBAL_SPELL_COOLDOWNS[spellID].element == 106 then
				extra_damage = extra_damage + colleftInfo[player:getId()].attributesItems[229].value
			end
		end
	end
	if colleftInfo[player:getId()].attributesItems[262] then -- Basic Spells
		if GLOBAL_SPELL_COOLDOWNS[spellID].basic_aura then
			extra_damage = extra_damage + colleftInfo[player:getId()].attributesItems[262].value
		end
	end
	if colleftInfo[player:getId()] then
		if colleftInfo[player:getId()].spellLvl[spellID] then
			extra_damage = extra_damage + colleftInfo[player:getId()].spellLvl[spellID]
		end
	end
	return extra_damage
end


element_id_to_effect = {
	[1] = 1,  -- 1
	[2] = 12, -- 2
	[4] = 17, -- 4
	[8] = 16, -- 8
	[16] = 3, -- 16
	[32] = 3, -- 32
	[64] = 3, -- 64
	[128] = 3, -- 128
	[256] = 3, -- 256
	[512] = 44, -- 512
	[1024] = 40, -- 1024
	[2048] = 18, -- 2048
}
ELEMENT_ROW = { COMBAT_PHYSICALDAMAGE, COMBAT_ENERGYDAMAGE, COMBAT_EARTHDAMAGE, COMBAT_FIREDAMAGE, COMBAT_ICEDAMAGE,
	COMBAT_HOLYDAMAGE, COMBAT_DEATHDAMAGE
}
ELEMENT_ROW_NAME = { "Physical", "Energy", "Earth", "Fire", "Ice", "Holy", "Death"
}


-- AutoLoot config
AUTO_LOOT_MAX_ITEMS = 100

-- Reserved storage
AUTOLOOT_STORAGE_START = PlayerStorage.autoLoot
AUTOLOOT_STORAGE_END = AUTOLOOT_STORAGE_START + AUTO_LOOT_MAX_ITEMS
-- AutoLoot config end
colleftInfo = {}

function Player.hasMeleeWeapon(self)
    local weapon = self:getSlotItem(CONST_SLOT_LEFT)
    if not weapon then
        weapon = self:getSlotItem(CONST_SLOT_RIGHT)
    end
    if not weapon then
        return false
    end

    local weaponType = weapon:getType():getWeaponType()

    return weaponType == WEAPON_SWORD
        or weaponType == WEAPON_AXE
        or weaponType == WEAPON_CLUB
end

local AILMENTS = {
    ["bleed"]     = 21,
    ["ignite"]    = 28,
    ["poison"]    = 32,
    ["chill"]     = 37,
    ["shock"]     = 41,
    ["harvest"]   = 42,
    ["suppression"]= 45,
}

function getAilmentChancesFromTable(player, attributesTables)
    if not player then return end
    local result = {}

    for name, attrId in pairs(AILMENTS) do
        local chance = 0

        -- szansa z itemów w attributesTables
        if attributesTables[attrId] then
            chance = chance + attributesTables[attrId].value
        end

        -- DRUID_TRAIT buff
        if player:hasBuff(DRUID_TRAIT) then
            chance = chance + 20
        end

        -- all ailments chance (id = 210)
        if attributesTables[210] then
            chance = chance + attributesTables[210].value
        end

        result[name] = chance
    end

    return result
end

function getTotalAilmentChanceFromTable(player, attributesTables)
    if not player or not attributesTables then return 0 end

    local totalChance = 0
    -- suma indywidualnych szans + DRUID_TRAIT
    for _, attrId in pairs(AILMENTS) do
        local chance = 0
        if attributesTables[attrId] then
            chance = chance + attributesTables[attrId].value
        end
        totalChance = totalChance + chance
    end

    -- all ailments chance dodajemy tylko raz
    if attributesTables[210] then
        totalChance = totalChance + attributesTables[210].value
    end
    if player:hasBuff(DRUID_TRAIT) then
        totalChance = totalChance + 20
     end

    return totalChance
end

function Player.setCollectionInfo(self)
	spellIds = {}
	spellLevels = {}
	attributesTables = {}
	armorTot = {}
	attack = {}
	basicItemsTable = {}
	isTwoHanded = {}
	isDualWielding = {}
	isShield = {}
	shotTypeLeft = {}
	shotTypeRight = {}
	convertWeaponType = {}
	hasMeleeWeapon = {}
	spellallLevels = {}
	ailmentChances = {}
	totalailmentChances = {}
	local spell_level = 0
	-- Armor + Defense + Endurance
	armorTot = (self:getTotalArmor() + self:getTotalDefense())
	attack = 0
	local twohanded = false
	local dual = false
	local shield = false
	local conWeapon = false
	local total = 0
	local leftHand = self:getSlotItem(CONST_SLOT_LEFT)
	local rightHand = self:getSlotItem(CONST_SLOT_RIGHT)
	local meleeWeapon = self:hasMeleeWeapon()
	if leftHand then
		local itType = leftHand:getType()
		if itType:getId() == 25523 or itType:getId() == 2376 or itType:getId() == 38362 or itType:getId() == 38817 then
			convertWeaponType[self:getId()] = COMBAT_DEATHDAMAGE
		end
		if itType:getId() == 36056 or itType:getId() == 38034 or itType:getId() == 35786 or itType:getId() == 7407 or itType:getId() == 38645 or itType:getId() == 38815 then
			convertWeaponType[self:getId()] = COMBAT_ENERGYDAMAGE
		end
		if itType:getId() == 37925 or itType:getId() == 26782 or itType:getId() == 38804 then
			convertWeaponType[self:getId()] = COMBAT_EARTHDAMAGE
		end
		if itType:getId() == 35693 or itType:getId() == 2432 or itType:getId() == 38652 then
			convertWeaponType[self:getId()] = COMBAT_FIREDAMAGE
		end
		if itType:getId() == 7771 or itType:getId() == 7776 or itType:getId() == 35765 or itType:getId() == 38705 or itType:getId() == 7767 or itType:getId() == 25915 then
			convertWeaponType[self:getId()] = COMBAT_ICEDAMAGE
		end
		if itType:getId() == 2444 or itType:getId() == 22402 or itType:getId() == 38539 or itType:getId() == 34651 then
			convertWeaponType[self:getId()] = COMBAT_HOLYDAMAGE
		end
		if itType:getShootType() then
			leftHand = itType:getShootType()
		end
	else
		leftHand = 0
	end
	if rightHand then
		local itType = rightHand:getType()
		if itType:getId() == 25523 or itType:getId() == 2376 or itType:getId() == 38362 or itType:getId() == 38817 then
			convertWeaponType[self:getId()] = COMBAT_DEATHDAMAGE
		end
		if itType:getId() == 36056 or itType:getId() == 38034 or itType:getId() == 35786 or itType:getId() == 7407 or itType:getId() == 38645 or itType:getId() == 38815 then
			convertWeaponType[self:getId()] = COMBAT_ENERGYDAMAGE
		end
		if itType:getId() == 37925 or itType:getId() == 26782 or itType:getId() == 38804 then
			convertWeaponType[self:getId()] = COMBAT_EARTHDAMAGE
		end
		if itType:getId() == 35693 or itType:getId() == 2432 or itType:getId() == 38652 then
			convertWeaponType[self:getId()] = COMBAT_FIREDAMAGE
		end
		if itType:getId() == 7771 or itType:getId() == 7776 or itType:getId() == 35765 or itType:getId() == 38705 or itType:getId() == 7767 or itType:getId() == 25915 then
			convertWeaponType[self:getId()] = COMBAT_ICEDAMAGE
		end
		if itType:getId() == 2444 or itType:getId() == 22402 or itType:getId() == 38539 or itType:getId() == 34651 then
			convertWeaponType[self:getId()] = COMBAT_HOLYDAMAGE
		end
		if itType:getShootType() then
			rightHand = itType:getShootType()
		end
	else
		rightHand = 0
	end
	if self:getSlotItem(CONST_SLOT_RIGHT) and self:getSlotItem(CONST_SLOT_LEFT) then
		if self:getSlotItem(CONST_SLOT_RIGHT):isWeapon() and self:getSlotItem(CONST_SLOT_LEFT):isWeapon() then
			dual = true
		end
	end

	local itemsToCheck = {}
	for slot = CONST_SLOT_HEAD, CONST_SLOT_POTION2 do
		local item = self:getSlotItem(slot)
		if item then
			if item:getId() == 38037 then
				local ringSlot = slot == CONST_SLOT_RING and CONST_SLOT_RING2 or CONST_SLOT_RING
				local ring = self:getSlotItem(ringSlot)
				if ring then
					item = ring
				end
			end
			table.insert(itemsToCheck, item)
		end
	end

	local relictBox = self:getSlotItem(CONST_SLOT_RELICT_BOX)
	if relictBox then
		local maxWeight = relictBox:getCustomAttribute("maxWeight") or 0
		if maxWeight > 0 then
			local relictItems = relictBox:getItems()
			for _, item in ipairs(relictItems) do
				table.insert(itemsToCheck, item)
			end
		end
	end

	for _, item in ipairs(itemsToCheck) do
		local spellId = item:getCustomAttribute("spellid")
		local spellIdLevel = item:getCustomAttribute("spelllevel")
		local itType = item:getType()
		local weaponType = itType:getWeaponType()
		local slotPosition = itType:getSlotPosition() - SLOTP_LEFT - SLOTP_RIGHT
		local quality = 0
		local qualityS = 0
		if item:isQuality() then
			quality = item:isQuality()
		end
		local upgradeLevel = item:getUpgradeLevel()
		if upgradeLevel then
			quality = quality + calculateUpgradeValue(upgradeLevel)
		end

		if item:getCustomAttribute("spelllevelall") then
			spell_level = spell_level + math.floor((item:getCustomAttribute("spelllevelall") * (1 + quality / 100)))
		end

		if spellId then
			if spellLevels[spellId] ~= nil then
				spellLevels[spellId] = spellLevels[spellId] + spellIdLevel
			else
				spellLevels[spellId] = spellIdLevel
			end
		end

		if slotPosition == 1024 then
			twohanded = true
		end
		if weaponType > 0 then
			if weaponType == WEAPON_SHIELD then
				shield = true
			end
		end
		local attackT = 0

		if itType:getAttack() > 0 then -- XX
			if item:getAttribute(ITEM_ATTRIBUTE_ATTACK) > 0 then
				attackT = attackT + math.floor((item:getAttribute(ITEM_ATTRIBUTE_ATTACK) * (1 + quality / 100)))
			else
				attackT =  math.floor((itType:getAttack() * (1 + quality / 100)))
			end
		end

		total = total + attackT

		local slotsMax = item:getMaxAttributes()
		for i = 1, slotsMax do
			local enchant = item:getBonusAttribute(i)
			if enchant and #enchant > 0 then
				local attrId = enchant[1]
				local value = enchant[2]
				local attr = US_ENCHANTMENTS[attrId]
				local haveValue = not attr.noValue
				if haveValue then
					haveValue = not attr.noQuality
				end
				if attributesTables[attrId] ~= nil then
					if attr and attr.unique then
						attributesTables[attrId].value = math.max(attributesTables[attrId].value, value)
					elseif quality and haveValue then
						attributesTables[attrId].value = attributesTables[attrId].value + math.floor((value * (1 + quality / 100)))
					else
						attributesTables[attrId].value = attributesTables[attrId].value + value
					end
					attributesTables[attrId].text = attr.name
				else
					if quality and haveValue and (not attr or not attr.unique) then
						value = math.floor((value * (1 + quality / 100)))
					end
					attributesTables[attrId] = {
						text = attr.name,
						value = value,
						category = attr.category,
						percent = attr.percent
					}
				end
			end
		end

		local slotsMaxImplict = item:getImplictSlots()
		for i = 1, slotsMaxImplict do
			local enchant = item:getImplictBonusAttribute(i)
			if enchant and #enchant > 0 then
				local attrId = enchant[1]
				local value = enchant[2]
				local attr = US_ENCHANTMENTS[attrId]
				local haveValue = not attr.noValue
				if haveValue then
					haveValue = not attr.noQuality
				end
				if attrId == 91 then -- distance
					total = total + math.floor((value * (1 + quality / 100)))
				end
				if attrId == 90 then -- magic
					total = total + math.floor((value * (1 + quality / 100)))
				end
				if attrId == 89 then -- melee
					total = total + math.floor((value * (1 + quality / 100)))
				end

				if attributesTables[attrId] ~= nil then
					if attr and attr.unique then
						attributesTables[attrId].value = math.max(attributesTables[attrId].value, value)
					elseif quality and haveValue then
						attributesTables[attrId].value = attributesTables[attrId].value + math.floor((value * (1 + quality / 100)))
					else
						attributesTables[attrId].value = attributesTables[attrId].value + value
					end
					attributesTables[attrId].text = attr.name
				else
					if quality and haveValue and (not attr or not attr.unique) then
						value = math.floor((value * (1 + quality / 100)))
					end
					attributesTables[attrId] = {
						text = attr.name,
						value = value,
						category = attr.category,
						percent = attr.percent
					}
				end
			end
		end


		local crystalBonuses = item:getBonusFromCrystals()
		if crystalBonuses then
			for i = 1, #crystalBonuses do
				local enchant = crystalBonuses[i]
				if enchant and #enchant > 0 then
					local attrId = enchant[1]
					local value = enchant[2]
					local quality = enchant[5]
					local attr = US_ENCHANTMENTS[attrId]
					if attributesTables[attrId] ~= nil then
						if attr and attr.unique then
							attributesTables[attrId].value = math.max(attributesTables[attrId].value, value)
						elseif quality then
							attributesTables[attrId].value = attributesTables[attrId].value + math.floor((value * (1 + quality / 100)))
						else
							attributesTables[attrId].value = attributesTables[attrId].value + value
						end
						attributesTables[attrId].text = attr.name
					else
						attributesTables[attrId] = {
							text = attr.name,
							value = value,
							category = attr.category,
							percent = attr.percent
						}
					end
				end
			end

		end
	end
	attack = total + attack

	local talents_data = TALENTS[convertVocation[self:getVocation():getId()]] or TALENTS[1]
	if talents_data then
		for i = 1, #talents_data do
			local talentId = self:getStorageValue(435002 + i)
			local talent = talents_data[i] and talents_data[i][talentId]
			if talent then
				for x = 1, #talent.enchants do
					local enchant = talent.enchants[x]
					local attr = US_ENCHANTMENTS[enchant[1]]
					local value = enchant[2]
					if attributesTables[enchant[1]] ~= nil then
						if attr and attr.unique then
							attributesTables[enchant[1]].value = math.max(attributesTables[enchant[1]].value, value)
						else
							attributesTables[enchant[1]].value = attributesTables[enchant[1]].value + value
						end
						attributesTables[enchant[1]].text = attr.name
					else
						attributesTables[enchant[1]] = {
							text = attr.name,
							value = value,
							category = attr.category,
							percent = attr.percent
						}
					end
				end
			end
		end
	end

	local second_talent = self:getStorageValue(435001)
	if second_talent ~= -1 then
		local talents_data = TALENTS[second_talent] or TALENTS[1]
		if talents_data then
			for i = 1, #talents_data do 
				local talentId = self:getStorageValue(435002 + 10 + i)
				local talent = talents_data[i] and talents_data[i][talentId]
				if talent then
					for x = 1, #talent.enchants do
						local enchant = talent.enchants[x]
						local attr = US_ENCHANTMENTS[enchant[1]]
						local value = enchant[2]
						if attributesTables[enchant[1]] ~= nil then
							if attr and attr.unique then
								attributesTables[enchant[1]].value = math.max(attributesTables[enchant[1]].value, value)
							else
								attributesTables[enchant[1]].value = attributesTables[enchant[1]].value + value
							end
							attributesTables[enchant[1]].text = attr.name
						else
							attributesTables[enchant[1]] = {
								text = attr.name,
								value = value,
								category = attr.category,
								percent = attr.percent,
							}
						end
					end
				end
			end
		end
	end

	for i = 1, #GOLDEN_ENCHANTMENTS_CONFIG do
		local level = self:getStorageValue(PlayerStorage.EnchantmentsAltar + i)
		if level > 0 then
			local enchant = GOLDEN_ENCHANTMENTS_CONFIG[i].enchant
			local attr = US_ENCHANTMENTS[enchant]
			local value = GOLDEN_ENCHANTMENTS_CONFIG[i].value * level
			if attributesTables[enchant] ~= nil then
				if attr and attr.unique then
					attributesTables[enchant].value = math.max(attributesTables[enchant].value, value)
				else
					attributesTables[enchant].value = attributesTables[enchant].value + value
				end
				attributesTables[enchant].text = attr.name
			else
				attributesTables[enchant] = {
					text = attr.name,
					value = value,
					category = attr.category,
					percent = attr.percent,
				}
			end
		end
	end

	ailmentChances = getAilmentChancesFromTable(self, attributesTables)
	totalailmentChances = getTotalAilmentChanceFromTable(self, attributesTables)
	--local shock = shockChance(self)
	--local chill = chillChance(self)

	colleftInfo[self:getId()] = {
		attributesItems = attributesTables,
		basicItems = basicItemsTable,
		spellLvl = spellLevels,
		spellallLevels = spell_level,
		armor = armorTot,
		attackPower = math.floor(attack),
		isTwoHanded = twohanded,
		isDualWielding = dual,
		isShield = shield,
		shotTypeLeft = leftHand,
		shotTypeRight = rightHand,
		convertWeaponType = convertWeaponType,
		hasMeleeWeapon = meleeWeapon,
		ailmentChances = ailmentChances,  -- <- tutaj zapis
		totalailmentChances = totalailmentChances,
	--	shockChance = shock,
	--	chillChance = chill,
	}
	--[[
	if self:getStorageValue(435024) == 8 then -- Druid + Paladin Hierophant
		self:setLimitMaxHealth(1)
	else
		self:setLimitMaxHealth(0)
	end
	--]]

	self:setStatistics()
	self:getTotalAttackSpeed()
	self:getCooldownReduction()
	self:setGemSpell()
	self:updateInspect()
	self:sendStats()

	for i = CONST_SLOT_SPELL1, CONST_SLOT_SPELL4 do
		local item = self:getSlotItem(i)
		if item then
			SPELL_CACHE[item:getRealUID()] = nil
			local spellName = item:getSpellName()
			local SPELL = SPELLS[spellName]
			if SPELL then
				item:applySupportSpells(SPELL:getConfig(), self:getId())
				if SPELL.disable then
					SPELL.disable(self, item)
				end
			end
		end
	end
end

ACTIVATED_DOT = {}
function doDamageDOT(cid, aid, damage, precentage, ticks, effect, typeDmg, maxStacks, dotId, stacked)
	local creature = Creature(cid)
	local attacker = Creature(aid)
	if not ACTIVATED_DOT[cid] or not ACTIVATED_DOT[cid][dotId] or not ACTIVATED_DOT[cid][dotId][aid] then
		return
	end

	if not creature or not attacker then
		ACTIVATED_DOT[cid][dotId][aid] = nil
		return
	end

	-- Cache the DOT data table for performance
	local dotData = ACTIVATED_DOT[cid][dotId][aid]
	if not dotData then
		return
	end
	
	local morePrimal = 0
	local increase = 0
	local physicalPenetration = 0
	local elementalPenetration = 0
	local dualityPenetration = 0
	local damageReduction = 0
	local overpower = 0
	
	local stacks = dotData.stacks
	dotData.maxStacks = maxStacks
	if stacks > maxStacks then
		stacks = maxStacks
		dotData.stacks = maxStacks
	end
	if stacked then
		stacks = 1
	end

	local baseDoT = damage
	tempDmg = math.ceil(damage * stacks)

	if creature:hasBuff(RESTART_IMMORTAL) or creature:hasBuff(GHOST) or not creature:hasBuff(dotId) then
		if dotData.event then
			stopEvent(dotData.event)
		end
		ACTIVATED_DOT[cid][dotId][aid] = nil
		return
	end
	if tempDmg > 0 then tempDmg = tempDmg * -1 end
	local origin = ORIGIN_CONDITION
	if attacker:isPlayer() then
		origin = ORIGIN_DOT
	elseif attacker:isMonster() then
		origin = ORIGIN_CONDITION
	end
	if attacker:isPlayer() then
		increase = spellGlobalTotalDamage(attacker, 0, true, typeDmg)
		if colleftInfo[attacker:getId()].attributesItems[33] then -- Boss Damage
			if creature:isMonster() and MonsterType(creature:getName()):getRace() == 6 then
				increase = increase + colleftInfo[attacker:getId()].attributesItems[33].value
			end
		end
		if colleftInfo[attacker:getId()].attributesItems[36] then -- Elite Damage
			if creature:isMonster() and creature:getSkull() >= 7 then
				increase = increase + colleftInfo[attacker:getId()].attributesItems[36].value
			end
		end
		--Uniques
		if colleftInfo[attacker:getId()].attributesItems[184] then -- unique Mana Cape Mana Core
			if attacker:getMaxMana() >= US_ENCHANTMENTS[184].subvalue2 then
				increase = increase + US_ENCHANTMENTS[184].subvalue3
			end
		end
		if colleftInfo[attacker:getId()].attributesItems[212] then -- unique Lava Focus - elemental damage
			if typeDmg == COMBAT_FIREDAMAGE or typeDmg == COMBAT_ICEDAMAGE or typeDmg == COMBAT_EARTHDAMAGE or typeDmg == COMBAT_ENERGYDAMAGE then
				local hpores = math.floor(math.max(attacker:getMaxHealth(), attacker:getMaxEnergyShield()) * US_ENCHANTMENTS[212].subvalue)
				increase = increase + math.min(hpores, 400)
			end
		end
		if colleftInfo[attacker:getId()].attributesItems[251] then -- unique Divine Blessing - duality damage
			if typeDmg == COMBAT_HOLYDAMAGE or typeDmg == COMBAT_DEATHDAMAGE then
				local hpores = math.floor(math.max(attacker:getMaxHealth(), attacker:getMaxEnergyShield()) * US_ENCHANTMENTS[251].subvalue)
				increase = increase + math.min(hpores, 400)
			end
		end
		if colleftInfo[attacker:getId()].attributesItems[252] then -- uniqueRaw Strength - physical damage
			if typeDmg == COMBAT_PHYSICALDAMAGE then
				local hpores = math.floor(math.max(attacker:getMaxHealth(), attacker:getMaxEnergyShield()) * US_ENCHANTMENTS[252].subvalue)
				increase = increase + math.min(hpores, 400)
			end
		end
		if colleftInfo[attacker:getId()].attributesItems[221] then -- Hermes Speed
			local movementSpeedPercent = (((200 - attacker:getSpeed()) / 200) * 100) * -1
			increase = increase + math.min((movementSpeedPercent * US_ENCHANTMENTS[221].subvalue), 400)
		end
		local ailmnetTotal = 0
		if colleftInfo[attacker:getId()].totalailmentChances then
			ailmnetTotal = colleftInfo[attacker:getId()].totalailmentChances
		end
		--[[
		if attacker:hasBuff(TOXIC_PATH) then
			increase = increase + ailmnetTotal
		elseif attacker:hasBuff(SACRED_PATH) then
			increase = increase + ailmnetTotal
		elseif attacker:hasBuff(CRYO_PATH)  then
			increase = increase + ailmnetTotal
		elseif attacker:hasBuff(THUNDER_PATH) then
			increase = increase + ailmnetTotal
		elseif attacker:hasBuff(PASSING_PATH) then
			increase = increase + ailmnetTotal
		elseif attacker:hasBuff(BLOODY_PATH) then
			increase = increase + ailmnetTotal
		elseif attacker:hasBuff(PYRO_PATH) then
			increase = increase + ailmnetTotal
		end
		--]]
		if attacker:getStorageValue(PlayerStorage.specialization) >= 0 then
			if colleftInfo[attacker:getId()].totalailmentChances then
				increase = increase + colleftInfo[attacker:getId()].totalailmentChances
			end
		end
		 tempDmg = tempDmg + (tempDmg * (increase / 100))
		-- more damage
		if colleftInfo[attacker:getId()].attributesItems[206] then
			local ailmentBuffs = {
				IGNITE_ITEM, POISON_ITEM, CHILL, SHOCK, BLEED_ITEM, SUPPRESSION, HARVEST_DEBUFF
			}
			local totalAilments = 0
			for _, buff in ipairs(ailmentBuffs) do
				if creature:hasBuff(buff) then
					totalAilments = totalAilments + 1
				end
			end
			morePrimal = morePrimal + (100 * totalAilments)
		end
		if attacker:hasBuff(SAINT_BUFF) then
			if typeDmg == COMBAT_HOLYDAMAGE then
				morePrimal = morePrimal + attacker:getBuff(SAINT_BUFF).stacks
			end
		end
		if colleftInfo[attacker:getId()].attributesItems[180] then -- subklas Static Conduit
			morePrimal = morePrimal + US_ENCHANTMENTS[180].subvalue3
		end
		if colleftInfo[attacker:getId()].attributesItems[176] then -- subklas Culling Strike
			morePrimal = morePrimal + US_ENCHANTMENTS[176].subvalue2
		end
		if creature:hasBuff(SUPPRESSION) then -- subklas Heaven's Strike
			if colleftInfo[attacker:getId()].attributesItems[157] then
				if math.random(100) <= US_ENCHANTMENTS[157].subvalue then
					morePrimal = morePrimal + US_ENCHANTMENTS[157].subvalue2
				end
			end
		end
		if colleftInfo[attacker:getId()].attributesItems[150] then -- subklas Crusader Onslaught
			if math.random(1, 100) <= US_ENCHANTMENTS[150].subvalue5 then
				morePrimal = morePrimal + US_ENCHANTMENTS[150].subvalue6
				creature:getPosition():sendMagicEffect(91)
			elseif math.random(1, 100) <= US_ENCHANTMENTS[150].subvalue3 then
				morePrimal = morePrimal + US_ENCHANTMENTS[150].subvalue4
				creature:getPosition():sendMagicEffect(91)
			elseif math.random(1, 100) <= US_ENCHANTMENTS[150].subvalue then
				morePrimal = morePrimal + US_ENCHANTMENTS[150].subvalue2
				creature:getPosition():sendMagicEffect(49)
			end
		end
		if colleftInfo[attacker:getId()].attributesItems[168] then -- subklas Determination
			morePrimal = morePrimal + US_ENCHANTMENTS[168].subvalue
		end
		if colleftInfo[attacker:getId()].attributesItems[141] then -- Subklas Frigid Execution
			if creature:getHealth() <= (creature:getMaxHealth() * US_ENCHANTMENTS[141].subvalue) then
				morePrimal = morePrimal + US_ENCHANTMENTS[141].subvalue2
			end
		end
		if colleftInfo[attacker:getId()].attributesItems[133] then -- Subklas Infernal Wrath
			if creature:getHealth() >= (creature:getMaxHealth() * US_ENCHANTMENTS[133].subvalue) then
				morePrimal = morePrimal + US_ENCHANTMENTS[133].subvalue2
			end
		end
		if colleftInfo[attacker:getId()].attributesItems[194] then -- subklas Unstable Darkness
			morePrimal = morePrimal + math.random(US_ENCHANTMENTS[194].subvalue, US_ENCHANTMENTS[194].subvalue2)
		end
		if colleftInfo[attacker:getId()].attributesItems[50] and typeDmg == COMBAT_EARTHDAMAGE then -- Unique
			if math.random(100) <= colleftInfo[attacker:getId()].attributesItems[50].value then
				morePrimal = morePrimal + 100
			end
		end
		if colleftInfo[attacker:getId()].attributesItems[50] then -- unique Critical Poison
			if typeDmg == COMBAT_EARTHDAMAGE then
				morePrimal = morePrimal + ((attacker:getSpecialSkill(SPECIALSKILL_CRITICALHITCHANCE)) * US_ENCHANTMENTS[50].subvalue)
			end
		end
		-- Fusions
		if attacker:getStorageValue(435024) == 1 then -- Sorcerer + Druid Elementalist
			if typeDmg == COMBAT_FIREDAMAGE or typeDmg == COMBAT_ICEDAMAGE or typeDmg == COMBAT_ENERGYDAMAGE or typeDmg == COMBAT_EARTHDAMAGE then
				if attacker:hasBuff(FIRE) then
					morePrimal = morePrimal + FUSION_SCALING[1].bonus
				elseif attacker:hasBuff(ICE) then
					morePrimal = morePrimal + FUSION_SCALING[1].bonus
				elseif attacker:hasBuff(LIGHTNING) then
					morePrimal = morePrimal + FUSION_SCALING[1].bonus
				elseif attacker:hasBuff(EARTH) then
					morePrimal = morePrimal + FUSION_SCALING[1].bonus
				end
				morePrimal = morePrimal + (attacker:getEffectiveSkillLevel(SKILL_FISHING) * FUSION_SCALING[1].scaling)
			end
		end
		if attacker:getStorageValue(435024) == 4 then -- Sorcerer + Paladin Inquisitor
			morePrimal = morePrimal + (attacker:getMaxMana() * FUSION_SCALING[4].scaling)
		end
		if attacker:getStorageValue(435024) == 2 then -- Sorcerer + Archer Thundershot
				local hpActual = creature:getHealth()
				local hpLower = (creature:getMaxHealth() * FUSION_SCALING[2].hp)
				if hpActual <= hpLower then
					morePrimal = morePrimal + FUSION_SCALING[2].bonus
				end
				local movementSpeedPercent = (((200 - attacker:getSpeed()) / 200) * 100) * -1
				morePrimal = morePrimal + (movementSpeedPercent * FUSION_SCALING[2].scaling)
		end
		if attacker:getStorageValue(435024) == 3 then -- Sorcerer + Knight Battlemage
			if creature:hasBuff(IGNITE_ITEM) then
				morePrimal = morePrimal + FUSION_SCALING[3].bonus
			end
			if colleftInfo[attacker:getId()].totalailmentChances then
				morePrimal = morePrimal + (colleftInfo[attacker:getId()].totalailmentChances * FUSION_SCALING[3].scaling)
			end
		end
		if attacker:hasBuff(RAGE) then -- subklas Rage
			morePrimal = morePrimal + attacker:getBuff(RAGE).stacks * 2
		end
		if attacker:getStorageValue(435024) == 5 then -- Sorcerer + Shadow Warlock
			if math.random(100) <= FUSION_SCALING[5].chance then
				morePrimal = morePrimal + FUSION_SCALING[5].bonus
			end
			morePrimal = morePrimal + (math.max(attacker:getEffectiveSkillLevel(SKILL_DISTANCE), attacker:getEffectiveSkillLevel(SKILL_FISHING)) * FUSION_SCALING[5].scaling)
		end
		if attacker:getStorageValue(435024) == 6 then -- Druid + Archer Toxic hunter
			if colleftInfo[attacker:getId()].totalailmentChances then
				morePrimal = morePrimal + (colleftInfo[attacker:getId()].totalailmentChances * FUSION_SCALING[6].scaling)
			end
			morePrimal = morePrimal + FUSION_SCALING[6].bonus
		end
		if attacker:getStorageValue(435024) == 7 then -- Druid + Knight Warden
			morePrimal = morePrimal + (attacker:getMaxMana() * FUSION_SCALING[7].scaling)
		end
		if attacker:getStorageValue(435024) == 8 then -- Druid + Paladin Hierophant
			if colleftInfo[attacker:getId()].totalailmentChances then
				morePrimal = morePrimal + (colleftInfo[attacker:getId()].totalailmentChances * FUSION_SCALING[8].scaling)
			end
			if creature:getHealth() >= (creature:getMaxHealth() * FUSION_SCALING[8].hp) then
				morePrimal = morePrimal + FUSION_SCALING[8].bonus
			end
		end
		if attacker:getStorageValue(435024) == 9 then -- -- Druid + Shadow Umbral Shaman
			creature:addBuff(TOXIC_MARK)
			if creature:hasBuff(TOXIC_MARK) and creature:getBuff(TOXIC_MARK).stacks >= 10 then
				morePrimal = morePrimal + FUSION_SCALING[9].bonus
			end
			morePrimal = morePrimal + (math.max(attacker:getEffectiveSkillLevel(SKILL_DISTANCE), attacker:getEffectiveSkillLevel(SKILL_FISHING)) * FUSION_SCALING[9].scaling)
		end
		if attacker:getStorageValue(435024) == 10 then -- Archer + Knight Siegebreaker
			morePrimal = morePrimal + math.floor(attacker:getVarStats(STAT_ATTACKSPEED) * FUSION_SCALING[10].scaling)
		end
		if attacker:getStorageValue(435024) == 11 then -- Archer + Paladin Dawnstalker
			local movementSpeedPercent = (((200 - attacker:getSpeed()) / 200) * 100) * -1
			morePrimal = morePrimal + (movementSpeedPercent * FUSION_SCALING[11].scaling)
		end
		if attacker:getStorageValue(435024) == 12 then -- Archer + Shadow Nightstalker
			morePrimal = morePrimal + math.floor(attacker:getSpecialSkill(SPECIALSKILL_CRITICALHITCHANCE) * FUSION_SCALING[12].scaling)
		end
		if attacker:getStorageValue(435024) == 13 then -- Knight + Paladin Crusader
			morePrimal = morePrimal + FUSION_SCALING[13].bonus + (attacker:getEffectiveSkillLevel(SKILL_MELEE) * FUSION_SCALING[13].scaling)
		end
		if attacker:getStorageValue(435024) == 14 then -- Knight + Shadow Bloody Slayer
			if creature:hasBuff(DEEP_WOUNDS) then
				morePrimal = morePrimal + (creature:getBuff(DEEP_WOUNDS).stacks * FUSION_SCALING[14].bonus)
			end
			morePrimal = morePrimal + math.floor(attacker:getVarStats(STAT_ATTACKSPEED) * FUSION_SCALING[14].scaling)
		end
		if attacker:getStorageValue(435024) == 15 then -- Paladin + Shadow Abyssal Cleric
			morePrimal = morePrimal + math.floor(attacker:getSpecialSkill(SPECIALSKILL_CRITICALHITCHANCE) * FUSION_SCALING[15].scaling)
		end
		if colleftInfo[attacker:getId()].attributesItems[145] and creature:hasBuff(POISON_ITEM) then -- Epidemic
			morePrimal = morePrimal + US_ENCHANTMENTS[145].subvalue
		end
		if morePrimal > 0 then
			tempDmg = tempDmg + (tempDmg * morePrimal / 100)
		end
		overpower = spellOverpower(attacker, typeDmg)
		if overpower > 0 then
			tempDmg = math.floor(tempDmg + (tempDmg * overpower / 100))
		end
		-- Monster damage reduction
		if attacker:isPlayer() and creature:isMonster() then -- gracz atakuje moba
			local skull = creature:getSkull()
			local originalDamage = tempDmg
			if attacker:getStorageValue(435024) == 10 then -- Archer + Knight Siegebreaker
				attacker:addBuff(QUICK_STAB)
				if attacker:hasBuff(QUICK_STAB) then
					physicalPenetration = physicalPenetration + (attacker:getBuff(QUICK_STAB).stacks * FUSION_SCALING[10].bonus)
				end
			end
			if colleftInfo[attacker:getId()] then
				if colleftInfo[attacker:getId()].attributesItems[31] then -- Physical Penetration Damage 31
					physicalPenetration = physicalPenetration + colleftInfo[attacker:getId()].attributesItems[31].value
				end
				if colleftInfo[attacker:getId()].attributesItems[122] then -- Elemental Penetration Damage 31
					elementalPenetration = elementalPenetration + colleftInfo[attacker:getId()].attributesItems[122].value
				end
				if colleftInfo[attacker:getId()].attributesItems[198] then -- Duality Penetration Damage 198
					dualityPenetration = dualityPenetration + colleftInfo[attacker:getId()].attributesItems[198].value
				end
			end
			-- Dungeon Modifier
			if creature:getStorageValue(PlayerStorage.monsterModifier_physicalProtection) > 0 then
				if typeDmg == COMBAT_PHYSICALDAMAGE then
					damageReduction = damageReduction + creature:getStorageValue(PlayerStorage.monsterModifier_physicalProtection)
				end
			end
			if creature:getStorageValue(PlayerStorage.monsterModifier_elementalProtection) > 0 then
				if typeDmg == COMBAT_FIREDAMAGE or typeDmg == COMBAT_ICEDAMAGE or typeDmg == COMBAT_ENERGYDAMAGE or typeDmg == COMBAT_EARTHDAMAGE then
					damageReduction = damageReduction + creature:getStorageValue(PlayerStorage.monsterModifier_elementalProtection)
				end
			end
			if creature:getStorageValue(PlayerStorage.monsterModifier_dualityProtection) > 0 then
				if typeDmg == COMBAT_DEATHDAMAGE or typeDmg == COMBAT_HOLYDAMAGE then
					damageReduction = damageReduction + creature:getStorageValue(PlayerStorage.monsterModifier_dualityProtection)
				end
			end
			if skull >= 7 then -- Increase DAMAGE REDUCED ALL elite
				damageReduction = damageReduction + 20
			end
			if skull == 7 then -- REDUCED DAMAGE
				if typeDmg == COMBAT_PHYSICALDAMAGE then
					damageReduction = damageReduction + 20
				end
			elseif skull == 27 or creature:getType():items() == "dungeonboss" or creature:getType():items() == "uberboss" then -- veterna
				damageReduction = damageReduction + 30
			elseif skull == 8 then -- REFLECT DAMAGE
				if attacker and origin == ORIGIN_SPELL or origin == ORIGIN_MELEE or origin == ORIGIN_RANGED or origin == ORIGIN_WAND then
					local damage = (damageFormula(creature:getMonsterLevel()) / 15)
					doTargetCombatHealth(creature:getId(), attacker:getId(), typeDmg, -damage, -damage, 0, ORIGIN_CONDITION)
				end
				creature:getPosition():sendDistanceEffect(attacker:getPosition(), 41)
			elseif skull == 19 then -- duality prot
				if typeDmg == COMBAT_DEATHDAMAGE or typeDmg == COMBAT_HOLYDAMAGE then
					damageReduction = damageReduction + 25
				end
			elseif skull == 20 then -- dodger 50% na dodge
				if math.random(100) <= 50 then
					primaryDamage = 0
					secondaryDamage = 0
					Game.sendAnimatedText('DODGE', creature:getPosition(), 129)
					creature:getPosition():sendMagicEffect(3)
				end
			elseif skull == 21 then -- anti magic
				if typeDmg == COMBAT_FIREDAMAGE or typeDmg == COMBAT_EARTHDAMAGE or typeDmg == COMBAT_ENERGYDAMAGE or typeDmg == COMBAT_ICEDAMAGE  then
					damageReduction = damageReduction + 25
				end
			end
			-- Odpornosc Moba
			local monsterLevel = creature:getMonsterLevel()
			local baseMonsterProt = 0
			if monsterLevel then
				baseMonsterProt = math.ceil(monsterLevel / 2)
				if baseMonsterProt >= 80 then
					baseMonsterProt = 80
				end
			end
			damageReduction = damageReduction + baseMonsterProt
			if attacker:getStorageValue(PlayerStorage.endGame) >= 1 then
				damageReduction = damageReduction - 15
			end
			-- Fusion
			if attacker:getStorageValue(435024) == 15 then -- Paladin + Shadow Abyssal Cleric
				damageReduction = damageReduction - FUSION_SCALING[15].bonus
			end
			-- Paths
			if attacker:hasBuff(PYRO_PATH) and creature:hasBuff(IGNITE_ITEM) then
				if typeDmg == COMBAT_FIREDAMAGE then
					damageReduction = damageReduction - 15
				end
			end
			if attacker:hasBuff(BLOODY_PATH) and creature:hasBuff(BLEED_ITEM) then
				if typeDmg == COMBAT_PHYSICALDAMAGE then
					if creature:getHealth() < creature:getMaxHealth() * 0.5 then
						damageReduction = damageReduction - 25
					end
				end
			end
			-- Mods
			if colleftInfo[attacker:getId()].attributesItems[159] then -- Penetration Damage
				damageReduction = damageReduction - colleftInfo[attacker:getId()].attributesItems[159].value
			end
			-- Talents
			if colleftInfo[attacker:getId()].attributesItems[159] and colleftInfo[attacker:getId()].isTwoHanded then -- Subklas Heaven's Fury
				damageReduction = damageReduction - US_ENCHANTMENTS[159].subvalue2
			end
			if colleftInfo[attacker:getId()].attributesItems[153] then -- talent Grace
				if typeDmg == COMBAT_DEATHDAMAGE or typeDmg == COMBAT_HOLYDAMAGE then
					damageReduction = damageReduction - US_ENCHANTMENTS[153].subvalue
				end
			end
			if colleftInfo[attacker:getId()].attributesItems[152] then -- Subklas Sacred Impact
				damageReduction = damageReduction - US_ENCHANTMENTS[152].subvalue2
			end
			if colleftInfo[attacker:getId()].attributesItems[170] then -- Arcane Insight
				if typeDmg == COMBAT_ICEDAMAGE or typeDmg == COMBAT_FIREDAMAGE or typeDmg == COMBAT_EARTHDAMAGE or typeDmg == COMBAT_ENERGYDAMAGE then
					damageReduction = damageReduction - US_ENCHANTMENTS[170].subvalue
				end
			end
			if colleftInfo[attacker:getId()].attributesItems[164] then -- Subklas Mighty Hands
				if typeDmg == COMBAT_PHYSICALDAMAGE then
					damageReduction = damageReduction - US_ENCHANTMENTS[164].subvalue
				end
			end
			if colleftInfo[attacker:getId()].attributesItems[127] then -- Subklas Overcharged Energy
				damageReduction = damageReduction - US_ENCHANTMENTS[127].subvalue2
			end
			if colleftInfo[attacker:getId()].attributesItems[132] then -- Subklas Bloodfire
				damageReduction = damageReduction - US_ENCHANTMENTS[132].subvalue2
			end
			if colleftInfo[attacker:getId()].attributesItems[195] then -- subklas Suffering Power
				damageReduction = damageReduction - US_ENCHANTMENTS[195].subvalue
			end
			if attacker:getStorageValue(435024) == 4 then -- Sorcerer + Paladin Inquisitor
				damageReduction = damageReduction - FUSION_SCALING[4].bonus
				if creature:getHealth() < (creature:getMaxHealth() * FUSION_SCALING[4].hp) then
					damageReduction = damageReduction - FUSION_SCALING[4].bonus
				end
			end
			if creature:hasBuff(EARTH_WEAKNESS) then
				if typeDmg == COMBAT_EARTHDAMAGE then
					damageReduction = damageReduction - 20
				end
			end
			if creature:hasBuff(SHOCK) then
				if typeDmg == COMBAT_ENERGYDAMAGE then
					damageReduction = damageReduction - 20
				end
			end
			if creature:hasBuff(EARTH_WEAKNESS_SPELL) then
				if typeDmg == COMBAT_EARTHDAMAGE then
					damageReduction = damageReduction - 20
				end
			end
			if creature:hasBuff(FROSTBITE_WEAKNESS) then
				if typeDmg == COMBAT_ICEDAMAGE then
					damageReduction = damageReduction - 20
				end
			end
			if creature:hasBuff(FIRE_WEAKNESS) then
				if typeDmg == COMBAT_FIREDAMAGE then
					damageReduction = damageReduction - 20
				end
			end
			if creature:hasBuff(WEAKNESS_ARROW) then
				damageReduction = damageReduction - 25
			end
			if creature:hasBuff(HOLY_WEAKNESS) and typeDmg == COMBAT_HOLYDAMAGE then -- unique Holy Imbue
				damageReduction = damageReduction - US_ENCHANTMENTS[287].subvalue
			end
			if colleftInfo[attacker:getId()].attributesItems[175] then -- subklas Multishot Enhancment
				damageReduction = damageReduction - US_ENCHANTMENTS[175].subvalue3
			end
			if colleftInfo[attacker:getId()] then
				if colleftInfo[attacker:getId()].attributesItems[186] then -- subklas Deadly Precision
					if critical then
						damageReduction = damageReduction - US_ENCHANTMENTS[186].subvalue2
					end
				end
			end
			if colleftInfo[attacker:getId()].attributesItems[139] and creature:getBuff(CHILL) then -- Subklas Permafrost Surge
				damageReduction = damageReduction - US_ENCHANTMENTS[139].subvalue
			end
			if attacker:hasBuff(SHATTERSTORM) then
				damageReduction = damageReduction - (attacker:getBuff(SHATTERSTORM).stacks * 3)
			end
			if colleftInfo[attacker:getId()].attributesItems[146] then -- subklas Ruinous Tremous
				damageReduction = damageReduction - US_ENCHANTMENTS[146].subvalue
				local hpLower = (creature:getMaxHealth() * US_ENCHANTMENTS[146].subvalue3)
				if creature:getHealth() <= hpLower then
					damageReduction = damageReduction - US_ENCHANTMENTS[146].subvalue2
				end
			end
			if colleftInfo[attacker:getId()].attributesItems[261] then -- unique Raven Peck
				if typeDmg == COMBAT_FIREDAMAGE or typeDmg == COMBAT_ENERGYDAMAGE or typeDmg == COMBAT_ICEDAMAGE or typeDmg == COMBAT_EARTHDAMAGE then
					damageReduction = damageReduction - math.min(math.floor(highestStat(attacker) * US_ENCHANTMENTS[261].subvalue), US_ENCHANTMENTS[261].subvalue2)
				end
			end
			if colleftInfo[attacker:getId()].attributesItems[263] then -- unique Bloody Pact
				if typeDmg == COMBAT_PHYSICALDAMAGE then
					damageReduction = damageReduction - math.min(math.floor(highestStat(attacker) * US_ENCHANTMENTS[263].subvalue), US_ENCHANTMENTS[263].subvalue2)
				end
			end
			if colleftInfo[attacker:getId()].attributesItems[260] then -- unique Soul Piercing
				if typeDmg == COMBAT_DEATHDAMAGE or typeDmg == COMBAT_HOLYDAMAGE then
					damageReduction = damageReduction - math.min(math.floor(highestStat(attacker) * US_ENCHANTMENTS[260].subvalue), US_ENCHANTMENTS[260].subvalue2)
				end
			end
			if colleftInfo[attacker:getId()].attributesItems[277] then -- unique Spark Speed
				local movementSpeedPercent = (((200 - attacker:getSpeed()) / 200) * 100) * -1
				damageReduction = damageReduction - math.min((movementSpeedPercent * US_ENCHANTMENTS[277].subvalue), US_ENCHANTMENTS[277].subvalue2)
			end
			if colleftInfo[attacker:getId()].attributesItems[278] then -- unique Ruby Speed
				damageReduction = damageReduction - math.min((attacker:getVarStats(STAT_ATTACKSPEED) * US_ENCHANTMENTS[278].subvalue), US_ENCHANTMENTS[278].subvalue2)
			end
			if colleftInfo[attacker:getId()].attributesItems[279] then -- unique Blow Strike
				damageReduction = damageReduction - math.min((attacker:getSpecialSkill(SPECIALSKILL_CRITICALHITCHANCE) * US_ENCHANTMENTS[279].subvalue), US_ENCHANTMENTS[279].subvalue2)
			end
			if colleftInfo[attacker:getId()].attributesItems[280] then -- unique Toxic Synergy
				if colleftInfo[attacker:getId()].totalailmentChances then
					damageReduction = damageReduction - math.min((colleftInfo[attacker:getId()].totalailmentChances * US_ENCHANTMENTS[280].subvalue), US_ENCHANTMENTS[280].subvalue2)
				end
			end
			if origin == ORIGIN_SPELL or origin == ORIGIN_AUTOCAST then -- Only Spells
				if colleftInfo[attacker:getId()].attributesItems[181] then -- subklas Overcharged Arc
					damageReduction = damageReduction - US_ENCHANTMENTS[181].subvalue
				end
			end
			if creature:hasBuff(SUPPORT_PHYSICAL_REDUCTION) then
				if typeDmg == COMBAT_PHYSICALDAMAGE then
					damageReduction = damageReduction - creature:getBuff(SUPPORT_PHYSICAL_REDUCTION).stacks
				end
			end
			if creature:hasBuff(SUPPORT_ELEMENTAL_REDUCTION) then
				if typeDmg == COMBAT_FIREDAMAGE or typeDmg == COMBAT_ICEDAMAGE or typeDmg == COMBAT_ENERGYDAMAGE or typeDmg == COMBAT_EARTHDAMAGE then
					damageReduction = damageReduction - creature:getBuff(SUPPORT_ELEMENTAL_REDUCTION).stacks
				end
			end
			if creature:hasBuff(SUPPORT_DUALITY_REDUCTION) then
				if typeDmg == COMBAT_HOLYDAMAGE or typeDmg == COMBAT_DEATHDAMAGE then
					damageReduction = damageReduction - creature:getBuff(SUPPORT_DUALITY_REDUCTION).stacks
				end
			end
			if physicalPenetration > 0 then
				if typeDmg == COMBAT_PHYSICALDAMAGE then
					if attacker:isPlayer() and creature:isMonster() then
						damageReduction = damageReduction - physicalPenetration
					end
				end
			end
			if elementalPenetration > 0 then
				if typeDmg == COMBAT_FIREDAMAGE or typeDmg == COMBAT_EARTHDAMAGE or typeDmg == COMBAT_ICEDAMAGE or typeDmg == COMBAT_ENERGYDAMAGE then
					if attacker:isPlayer() and creature:isMonster() then
						damageReduction = damageReduction - elementalPenetration
					end
				end
			end
			if dualityPenetration > 0 then
				if typeDmg == COMBAT_DEATHDAMAGE or typeDmg == COMBAT_HOLYDAMAGE then
					if attacker:isPlayer() and creature:isMonster() then
						damageReduction = damageReduction - dualityPenetration
					end
				end
			end
			if tempDmg < 0 then
				if damageReduction >= 100 then
					damageReduction = 100
				end
				tempDmg = math.floor(tempDmg - (tempDmg * damageReduction / 100))
				if attacker:hasBuff(CLEAVE) or attacker:hasBuff(MULTISHOT) or attacker:hasBuff(MYSTIC_FOCUS) then
					tempDmg = tempDmg / 4
				end
				if colleftInfo[attacker:getId()].attributesItems[142] then -- unique Boner Bow
					tempDmg = tempDmg * 1.2
				end
			end
		end
	end
	if doTargetCombatHealth(attacker:getId(), creature:getId(), typeDmg, tempDmg, tempDmg, effect, origin, 0, 300) then
		if attacker:isPlayer() then
			if creature and creature:isMonster() then
				local mType = creature:getType()
				local titan = mType:items() == "titan"
				local champion = mType:items() == "champion"
				local dungeonboss = mType:items() == "dungeonboss"
				local stone = mType:items() == "stone"
				local damageTotal = tempDmg
				if colleftInfo[attacker:getId()].attributesItems[182] then -- Subklas Venomous Shots
					doTargetCombatHealth(attacker:getId(), creature, COMBAT_EARTHDAMAGE, tempDmg * US_ENCHANTMENTS[182].subvalue, tempDmg * US_ENCHANTMENTS[182].subvalue, 21, ORIGIN_CONDITION, 0, 24)
					damageTotal = damageTotal + (tempDmg * US_ENCHANTMENTS[182].subvalue)
				end
				if attacker:hasBuff(PASSING_PATH) and typeDmg == COMBAT_DEATHDAMAGE then -- Passing Path
					if creature:getHealth() > 0 then
						local hpActual = creature:getHealth() + damageTotal
						local hpLower = (creature:getMaxHealth() * 0.15)
						if hpActual <= hpLower and not (titan or champion or dungeonboss or stone) then
							doTargetCombatHealth(attacker:getId(), creature, COMBAT_UNDEFINEDDAMAGE, -creature:getHealth(), -creature:getHealth(), 94, ORIGIN_CONDITION, 0, 114)
						--	Game.sendAnimatedText('Passing Path', attacker:getPosition(), 192, "Reggae One-10px-bordered")
						end
					end
				end
				if colleftInfo[attacker:getId()].attributesItems[187] then -- Subklas Unrelenting Strike
					if critical then
						doTargetCombatHealth(attacker:getId(), creature, typeDmg, tempDmg * US_ENCHANTMENTS[187].subvalue, tempDmg * US_ENCHANTMENTS[187].subvalue, 18, ORIGIN_CONDITION, 0, 109)
					--	Game.sendAnimatedText('Unrelenting Strike', attacker:getPosition(), 129, "Reggae One-10px-bordered")
					end
				end
				if colleftInfo[attacker:getId()].attributesItems[144] then -- subklas Plague
					local damagePlague = US_ENCHANTMENTS[144].subvalue
					local hpLower = (creature:getMaxHealth() * US_ENCHANTMENTS[144].subvalue3)
					if creature:getHealth() <= hpLower then
						damagePlague = damagePlague + US_ENCHANTMENTS[144].subvalue2
					end
					doTargetCombatHealth(attacker:getId(), creature, typeDmg, tempDmg * damagePlague, tempDmg * damagePlague, 0, ORIGIN_CONDITION, 0, 106)
				end
				if colleftInfo[attacker:getId()].attributesItems[192] then -- subklas Deferred Death
					local sped2 = attacker:getBaseSpeed() * US_ENCHANTMENTS[192].subvalue
					local chill2 = Condition(CONDITION_PARALYZE)
					chill2:setParameter(CONDITION_PARAM_TICKS, 2000)
					chill2:setParameter(CONDITION_PARAM_SPEED, -sped2)
					chill2:setParameter(CONDITION_PARAM_SUBID, 777783)
					creature:addCondition(chill2)
					creature:addBuff(DEFERRED_DEATH)
					doTargetCombatHealth(attacker:getId(), creature, typeDmg, tempDmg * US_ENCHANTMENTS[192].subvalue2, tempDmg * US_ENCHANTMENTS[192].subvalue2, 18, ORIGIN_CONDITION, 0, 25)
				end
			--	if attacker:getStorageValue(435024) == 3 or attacker:getStorageValue(435024) == 6 or attacker:getStorageValue(435024) == 7 then -- Battlemage Toxic Hunter Hieropath
			--		local ailemtDmg = 0
			--		if colleftInfo[attacker:getId()].totalailmentChances then
			--			ailemtDmg = colleftInfo[attacker:getId()].totalailmentChances * 0.1
			--		end
			--		if doAreaCombatHealth(attacker:getId(), typeDmg, creature:getPosition(), area3x3, tempDmg * ailemtDmg, tempDmg * ailemtDmg, 0, ORIGIN_CONDITION, 300, 115) then
			--			Position(creature:getPosition().x + 1, creature:getPosition().y + 1, creature:getPosition().z):sendMagicEffect(540)
			--		end
			--	end
				if colleftInfo[attacker:getId()].attributesItems[177] then -- Subklas Decimating Strike
					if creature:isMonster() and creature:getHealth() > 0 then
						if creature:getName() == "Dummy DPS" or creature:getName() == "Dummy Armored" or creature:getName() == "Dummy Boss" then
						else
							local healthPercent = US_ENCHANTMENTS[177].subvalue
							local damageRemove = creature:getMaxHealth() * healthPercent
							if creature:getHealth() == creature:getMaxHealth() and not (titan or champion or dungeonboss or stone) then
								doTargetCombatHealth(attacker:getId(), creature, COMBAT_UNDEFINEDDAMAGE, -damageRemove,-damageRemove, 154, ORIGIN_CONDITION, 0, 23)
							--	Game.sendAnimatedText('Decimating Strike', attacker:getPosition(), 192,"Reggae One-10px-bordered")
							end
						end
					end
				end
				if colleftInfo[attacker:getId()].attributesItems[176] then -- Subklas Culling Strike
					if creature:getHealth() > 0 then
						local healthPercent = US_ENCHANTMENTS[176].subvalue
						local hpActual = creature:getHealth() + damageTotal
						local hpLower = (creature:getMaxHealth() * healthPercent)
						if hpActual <= hpLower and not (titan or champion or dungeonboss or stone) then
							doTargetCombatHealth(attacker:getId(), creature, COMBAT_UNDEFINEDDAMAGE, -creature:getHealth(), -creature:getHealth(), 94, ORIGIN_CONDITION, 0, 22)
						--	Game.sendAnimatedText('Culling Strike', attacker:getPosition(), 192, "Reggae One-10px-bordered")
						end
					end
				end
				if colleftInfo[attacker:getId()].attributesItems[174] then -- subklas Bloody Arrow
					if math.random(100) <= US_ENCHANTMENTS[174].subvalue then
						doAreaCombatHealth(attacker:getId(), typeDmg, creature:getPosition(), area3x3, tempDmg * US_ENCHANTMENTS[174].subvalue2, tempDmg * US_ENCHANTMENTS[174].subvalue2, 0, ORIGIN_CONDITION, 100, 108)
					--	attacker:getPosition():sendDistanceEffect(creature:getPosition(), 102)
						Position(creature:getPosition().x + 1, creature:getPosition().y + 1, creature:getPosition().z):sendMagicEffect(622)
					end
				end
				if colleftInfo[attacker:getId()].attributesItems[134] then -- subklas Fury Flames
					doAreaCombatHealth(attacker:getId(), typeDmg, creature:getPosition(), area3x3, tempDmg * US_ENCHANTMENTS[134].subvalue, tempDmg * US_ENCHANTMENTS[134].subvalue, 0, ORIGIN_CONDITION, 0, 101)
					Position(creature:getPosition().x + 3, creature:getPosition().y + 3, creature:getPosition().z):sendMagicEffect(488)
				end
				if attacker:isPlayer() and colleftInfo[attacker:getId()].attributesItems[163] then -- Subklas Bloody Fury
					if creature:hasBuff(BLEED_ITEM) then
						doTargetCombatHealth(attacker:getId(), creature, typeDmg, typeDmg * US_ENCHANTMENTS[163].subvalue, typeDmg * US_ENCHANTMENTS[163].subvalue, 1, ORIGIN_CONDITION, 0, 28)
					end
				end
				if colleftInfo[attacker:getId()].attributesItems[169] then -- subklas More Power
					doTargetCombatHealth(attacker:getId(), creature, typeDmg, typeDmg * US_ENCHANTMENTS[169].subvalue, typeDmg * US_ENCHANTMENTS[169].subvalue, 1, ORIGIN_CONDITION, 0, 27)
				end
				if attacker:getStorageValue(435024) == 11 then -- Archer + Paladin Dawnstalker
					if math.random(100) <= FUSION_SCALING[11].chance then
						if doAreaCombatHealth(attacker:getId(), typeDmg, creature:getPosition(), area3x3, typeDmg * FUSION_SCALING[11].bonus, typeDmg * FUSION_SCALING[11].bonus, 0, ORIGIN_CONDITION, 100, 107) then
						--	Game.sendAnimatedText('Flash Cut', attacker:getPosition(), 192, "Reggae One-10px-bordered")
							Position(creature:getPosition().x + 3, creature:getPosition().y + 3, creature:getPosition().z):sendMagicEffect(614)
						end
					end
				end
				if colleftInfo[attacker:getId()].attributesItems[147] then -- subklas Boulder
					if math.random(100) <= US_ENCHANTMENTS[147].subvalue2 then
						local boulderDamage = tempDmg * US_ENCHANTMENTS[147].subvalue
						if doAreaCombatHealth(attacker:getId(), COMBAT_EARTHDAMAGE, creature:getPosition(), area3x3, boulderDamage, boulderDamage, 0, ORIGIN_CONDITION, 100, 102) then
						--	Game.sendAnimatedText('Boulder', attacker:getPosition(), 192, "Reggae One-10px-bordered")
							Position(creature:getPosition().x + 6, creature:getPosition().y + 6, creature:getPosition().z):sendMagicEffect(619)
						end
					end
				end
				if attacker and attacker:getStorageValue(PlayerStorage.damageDotInfo) == 1 then
					if attacker:openChannel(31) then
						local increaseTxT = math.ceil(increase)
						local nameDot = BUFFS[dotId].name
						local afterIncrease = baseDoT + (baseDoT * increase)
						local afterMore = afterIncrease * (morePrimal / 100 + 1)
						local afterOverpower = afterMore * (overpower / 100 + 1)
						local afterStacks = afterOverpower * stacks
						attacker:sendChannelMessage(""," ["..nameDot.."] Damage Base ["..shortNumbers(-baseDoT,2).."] Increase " ..increaseTxT .. "% ["..shortNumbers(-afterIncrease,2).."] More "..morePrimal.."% ["..shortNumbers(-afterMore,2).."] Overpower: "..overpower.."% ["..shortNumbers(-afterOverpower,2).."] x "..stacks.." Stack ["..shortNumbers(-afterStacks,2).."] Damage - DR "..damageReduction.."% " .. shortNumbers(-tempDmg,2) .. "]",TALKTYPE_CHANNEL_R1, 31)
					end
				end
			end
		end
	end

	if dotData.stacks < 1 then
		if dotData.event then
			stopEvent(dotData.event)
		end
		ACTIVATED_DOT[cid][dotId][aid] = nil
		return
	end
	
	-- Stop the previous event before creating a new one to prevent event accumulation
	if dotData.event then
		stopEvent(dotData.event)
	end
	
	dotData.event = addEvent(function() doDamageDOT(cid, aid, damage, precentage, ticks, effect, typeDmg, maxStacks, dotId, stacked) end, ticks)
end

-- DoT helper delegates for backward compatibility (engine in data/scripts/dot_system.lua)
function removeStackFromBuff(cid, buffId, aid, removeStacks)
	local creature = Creature(cid)
	if creature and not creature:isRemoved() then
		if DOT_SYSTEM then
			creature:stopDOT(buffId)
		end
	end
end

ropeSpots = { 384, 418, 8278, 8592, 13189, 14435, 14436, 15635, 19518, 26019 }

doors = {
	[1209] = 1211,
	[1210] = 1211,
	[1212] = 1214,
	[1213] = 1214,
	[1219] = 1220,
	[1221] = 1222,
	[1231] = 1233,
	[1232] = 1233,
	[1234] = 1236,
	[1235] = 1236,
	[1237] = 1238,
	[1239] = 1240,
	[1249] = 1251,
	[1250] = 1251,
	[1252] = 1254,
	[1253] = 1254,
	[1539] = 1540,
	[1541] = 1542,
	[3535] = 3537,
	[3536] = 3537,
	[3538] = 3539,
	[3544] = 3546,
	[3545] = 3546,
	[3547] = 3548,
	[4913] = 4915,
	[4914] = 4915,
	[4916] = 4918,
	[4917] = 4918,
	[5082] = 5083,
	[5084] = 5085,
	[5098] = 5100,
	[5099] = 5100,
	[5101] = 5102,
	[5107] = 5109,
	[5108] = 5109,
	[5110] = 5111,
	[5116] = 5118,
	[5117] = 5118,
	[5119] = 5120,
	[5125] = 5127,
	[5126] = 5127,
	[5128] = 5129,
	[5134] = 5136,
	[5135] = 5136,
	[5137] = 5139,
	[5138] = 5139,
	[5140] = 5142,
	[5141] = 5142,
	[5143] = 5145,
	[5144] = 5145,
	[5278] = 5280,
	[5279] = 5280,
	[5281] = 5283,
	[5282] = 5283,
	[5284] = 5285,
	[5286] = 5287,
	[5515] = 5516,
	[5517] = 5518,
	[5732] = 5734,
	[5733] = 5734,
	[5735] = 5737,
	[5736] = 5737,
	[6192] = 6194,
	[6193] = 6194,
	[6195] = 6197,
	[6196] = 6197,
	[6198] = 6199,
	[6200] = 6201,
	[6249] = 6251,
	[6250] = 6251,
	[6252] = 6254,
	[6253] = 6254,
	[6255] = 6256,
	[6257] = 6258,
	[6795] = 6796,
	[6797] = 6798,
	[6799] = 6800,
	[6801] = 6802,
	[6891] = 6893,
	[6892] = 6893,
	[6894] = 6895,
	[6900] = 6902,
	[6901] = 6902,
	[6903] = 6904,
	[7033] = 7035,
	[7034] = 7035,
	[7036] = 7037,
	[7042] = 7044,
	[7043] = 7044,
	[7045] = 7046,
	[7054] = 7055,
	[7056] = 7057,
	[8541] = 8543,
	[8542] = 8543,
	[8544] = 8546,
	[8545] = 8546,
	[8547] = 8548,
	[8549] = 8550,
	[9165] = 9167,
	[9166] = 9167,
	[9168] = 9170,
	[9169] = 9170,
	[9171] = 9172,
	[9173] = 9174,
	[9267] = 9269,
	[9268] = 9269,
	[9270] = 9272,
	[9271] = 9272,
	[9273] = 9274,
	[9275] = 9276,
	[10276] = 10277,
	[10274] = 10275,
	[10268] = 10270,
	[10269] = 10270,
	[10271] = 10273,
	[10272] = 10273,
	[10471] = 10472,
	[10480] = 10481,
	[10477] = 10479,
	[10478] = 10479,
	[10468] = 10470,
	[10469] = 10470,
	[10775] = 10777,
	[10776] = 10777,
	[12092] = 12094,
	[12093] = 12094,
	[12188] = 12190,
	[12189] = 12190,
	[19840] = 19842,
	[19841] = 19842,
	[19843] = 19844,
	[19980] = 19982,
	[19981] = 19982,
	[19983] = 19984,
	[20273] = 20275,
	[20274] = 20275,
	[20276] = 20277,
	[17235] = 17236,
	[18208] = 18209,
	[13022] = 13023,
	[10784] = 10786,
	[10785] = 10786,
	[12099] = 12101,
	[12100] = 12101,
	[12197] = 12199,
	[12198] = 12199,
	[19849] = 19851,
	[19850] = 19851,
	[19852] = 19853,
	[19989] = 19991,
	[19990] = 19991,
	[19992] = 19993,
	[20282] = 20284,
	[20283] = 20284,
	[20285] = 20286,
	[17237] = 17238,
	[13020] = 13021,
	[10780] = 10781,
	[12095] = 12096,
	[12195] = 12196,
	[19845] = 19846,
	[19985] = 19986,
	[20278] = 20279,
	[10789] = 10790,
	[12102] = 12103,
	[12204] = 12205,
	[19854] = 19855,
	[19994] = 19995,
	[20287] = 20288,
	[10782] = 10783,
	[12097] = 12098,
	[12193] = 12194,
	[19847] = 19848,
	[19987] = 19988,
	[20280] = 20281,
	[10791] = 10792,
	[12104] = 12105,
	[12202] = 12203,
	[19856] = 19857,
	[19996] = 19997,
	[20289] = 20290,
	[25158] = 25159,
	[25160] = 25161,
	[22817] = 22818,
	[22826] = 22827,
	[22828] = 22829,
	[22819] = 22820
}
verticalOpenDoors = { 1211, 1220, 1224, 1228, 1233, 1238, 1242, 1246, 1251, 1256, 1260, 1540, 3546, 3548, 3550, 3552,
	4915, 5083, 5109, 5111, 5113, 5115, 5127, 5129, 5131, 5133, 5142, 5145, 5283, 5285, 5289, 5293, 5516, 5737, 5749,
	6194, 6199, 6203, 6207, 6251, 6256, 6260, 6264, 6798, 6802, 6902, 6904, 6906, 6908, 7044, 7046, 7048, 7050, 7055,
	8543, 8548, 8552, 8556, 9167, 9172, 9269, 9274, 9274, 9269, 9278, 9282, 10270, 10275, 10279, 10283, 10479, 10481,
	10485, 10483, 10786, 12101, 12199, 19851, 19853, 19991, 19993, 20284, 20286, 17238, 13021, 10790, 12103, 12205,
	19855, 19995, 20288, 10792, 12105, 12203, 19857, 19997, 20290, 22827, 22829 }
horizontalOpenDoors = { 1214, 1222, 1226, 1230, 1236, 1240, 1244, 1248, 1254, 1258, 1262, 1542, 3537, 3539, 3541, 3543,
	4918, 5085, 5100, 5102, 5104, 5106, 5118, 5120, 5122, 5124, 5136, 5139, 5280, 5287, 5291, 5295, 5518, 5734, 5746,
	6197, 6201, 6205, 6209, 6254, 6258, 6262, 6266, 6796, 6800, 6893, 6895, 6897, 6899, 7035, 7037, 7039, 7041, 7057,
	8546, 8550, 8554, 8558, 9170, 9174, 9272, 9276, 9280, 9284, 10273, 10277, 10281, 10285, 10470, 10472, 10476, 10474,
	10777, 12094, 12190, 19842, 19844, 19982, 19984, 20275, 20277, 17236, 18209, 13023, 10781, 12096, 12196, 19846,
	19986, 20279, 10783, 12098, 12194, 19848, 19988, 20281, 22818, 22820 }
openQuestDoors = { 1224, 1226, 1242, 1244, 1256, 1258, 3543, 3552, 5106, 5115, 5124, 5133, 5289, 5291, 5746, 5749, 6203,
	6205, 6260, 6262, 6899, 6908, 7041, 7050, 8552, 8554, 9176, 9178, 9278, 9280, 10279, 10281, 10476, 10485, 10783,
	10792, 12098, 12105, 12194, 12203, 19848, 19857, 19988, 19997, 20281, 20290 }
openLevelDoors = { 1228, 1230, 1246, 1248, 1260, 1262, 3541, 3550, 5104, 5113, 5122, 5131, 5293, 5295, 6207, 6209, 6264,
	6266, 6897, 6906, 7039, 7048, 8556, 8558, 9180, 9182, 9282, 9284, 10283, 10285, 10474, 10483, 10781, 10790, 12096,
	12103, 12196, 12205, 19846, 19855, 19986, 19995, 20279, 20288 }
questDoors = { 1223, 1225, 1241, 1243, 1255, 1257, 3542, 3551, 5105, 5114, 5123, 5132, 5288, 5290, 5745, 5748, 6202,
	6204, 6259, 6261, 6898, 6907, 7040, 7049, 8551, 8553, 9175, 9177, 9277, 9279, 10278, 10280, 10475, 10484, 10782,
	10791, 12097, 12104, 12193, 12202, 19847, 19856, 19987, 19996, 20280, 20289 }
levelDoors = { 1227, 1229, 1245, 1247, 1259, 1261, 3540, 3549, 5103, 5112, 5121, 5130, 5292, 5294, 6206, 6208, 6263,
	6265, 6896, 6905, 7038, 7047, 8555, 8557, 9179, 9181, 9281, 9283, 10282, 10284, 10473, 10482, 10780, 10789, 10780,
	12095, 12102, 12204, 12195, 19845, 19854, 19985, 19994, 20278, 20287 }
keys = { 2086, 2087, 2088, 2089, 2090, 2091, 2092, 10032 }

function convertKeysToString(tableData)
	local newTable = {}

	for key, value in pairs(tableData) do
			local stringKey = tostring(key)

			if type(value) == "table" then
					newTable[stringKey] = convertKeysToString(value)
			else
					newTable[stringKey] = value
			end
	end

	return newTable
end

local function convertKeysToNumbers(tableData)
	local newTable = {}

	for key, value in pairs(tableData) do
			local numberKey = tonumber(key) or key

			if type(value) == "table" then
					newTable[numberKey] = convertKeysToNumbers(value)
			else
					newTable[numberKey] = value
			end
	end

	return newTable
end

local function saveTableToFile(tableData, filePath)
	local validTable = convertKeysToString(tableData)

	local file, err = io.open(filePath, "w")
	if not file then
		print("Could not open file for writing: " .. err)
			return
	end

	local content = json.encode(validTable, { indent = true })

	file:write(content)
	file:close()
end

local function loadTableFromFile(filePath)
	local file, err = io.open(filePath, "r")
	if not file then
			return nil
	end

	local content = file:read("*all")
	file:close()

	local tableData = json.decode(content)
	return convertKeysToNumbers(tableData)
end

function saveBuffs()
	for key, value in pairs(CREATURE_ACTIVE_BUFFS) do
			if value.monster then
					CREATURE_ACTIVE_BUFFS[key] = nil
			end
	end

	saveTableToFile(GLOBAL_ACTIVE_BUFFS, "data/temp/global_buff.json")
	saveTableToFile(CREATURE_ACTIVE_BUFFS, "data/temp/creature_buff.json")
end

function loadBuffs()
	GLOBAL_ACTIVE_BUFFS = loadTableFromFile("data/temp/global_buff.json") or {}
	CREATURE_ACTIVE_BUFFS = loadTableFromFile("data/temp/creature_buff.json") or {}
end

function shortNumbers(num, places)
	local ret
	local placeValue = ("%%.%df"):format(places or 0)
	if num < 0 then num = num * -1 end
	num = math.ceil(num)
	if not num then
		return 0
	elseif num >= 1000000000000 then
		ret = placeValue:format(num / 1000000000000) .. "T" -- trillion
	elseif num >= 1000000000 then
		ret = placeValue:format(num / 1000000000) .. "B" -- billion
	elseif num >= 1000000 then
		ret = placeValue:format(num / 1000000) .. "M" -- million
	elseif num >= 1000 then
		ret = placeValue:format(num / 1000) .. "K"    -- thousand
	else
		ret = num                                     -- hundreds
	end
	return ret
end

function getDistanceBetween(firstPosition, secondPosition)
	local xDif = math.abs(firstPosition.x - secondPosition.x)
	local yDif = math.abs(firstPosition.y - secondPosition.y)
	local posDif = math.max(xDif, yDif)
	if firstPosition.z ~= secondPosition.z then
		posDif = posDif + 15
	end
	return posDif
end

function getFormattedWorldTime()
	local worldTime = getWorldTime()
	local hours = math.floor(worldTime / 60)

	local minutes = worldTime % 60
	if minutes < 10 then
		minutes = '0' .. minutes
	end
	return hours .. ':' .. minutes
end

function getLootRandom()
	local loot = math.random(0, MAX_LOOTCHANCE) / configManager.getNumber(configKeys.RATE_LOOT)
	if Game.isGlobalBuffActive(BUFF_GLOBAL_LOOT) then
		loot = loot - math.floor(loot / 2)
	end
	return loot
end

-- @docclass table

function table.dump(t, depth)
  if not depth then depth = 0 end
  for k,v in pairs(t) do
    str = (' '):rep(depth * 2) .. k .. ': '
    if type(v) ~= "table" then
      print(str .. tostring(v))
    else
      print(str)
      table.dump(v, depth+1)
    end
  end
end

function table.clear(t)
  for k,v in pairs(t) do
    t[k] = nil
  end
end

function table.copy(t)
  local res = {}
  for k,v in pairs(t) do
    res[k] = v
  end
  return res
end

function table.recursivecopy(t)
  local res = {}
  for k,v in pairs(t) do
    if type(v) == "table" then
      res[k] = table.recursivecopy(v)
    else
      res[k] = v
    end
  end
  return res
end

function table.selectivecopy(t, keys)
  local res = { }
  for i,v in ipairs(keys) do
    res[v] = t[v]
  end
  return res
end

function table.merge(t, src)
  for k,v in pairs(src) do
    t[k] = v
  end
end

function table.find(t, value, lowercase)
  for k,v in pairs(t) do
    if lowercase and type(value) == 'string' and type(v) == 'string' then
      if v:lower() == value:lower() then return k end
    end
    if v == value then return k end
  end
end

function table.findbykey(t, key, lowercase)
  for k,v in pairs(t) do
    if lowercase and type(key) == 'string' and type(k) == 'string' then
      if k:lower() == key:lower() then return v end
    end
    if k == key then return v end
  end
end

function table.contains(t, value, lowercase)
  return table.find(t, value, lowercase) ~= nil
end

function table.findkey(t, key)
  if t and type(t) == 'table' then
    for k,v in pairs(t) do
      if k == key then return k end
    end
  end
end

function table.haskey(t, key)
  return table.findkey(t, key) ~= nil
end

function table.removevalue(t, value)
  for k,v in pairs(t) do
    if v == value then
      table.remove(t, k)
      return true
    end
  end
  return false
end

function table.popvalue(value)
  local index = nil
  for k,v in pairs(t) do
    if v == value or not value then
      index = k
    end
  end
  if index then
    table.remove(t, index)
    return true
  end
  return false
end

function table.compare(t, other)
  if #t ~= #other then return false end
  for k,v in pairs(t) do
    if v ~= other[k] then return false end
  end
  return true
end

function table.empty(t)
  if t and type(t) == 'table' then
    return next(t) == nil
  end
  return true
end

function table.permute(t, n, count)
  n = n or #t
  for i=1,count or n do
    local j = math.random(i, n)
    t[i], t[j] = t[j], t[i]
  end
  return t
end

function table.findbyfield(t, fieldname, fieldvalue)
  for _i,subt in pairs(t) do
    if subt[fieldname] == fieldvalue then
      return subt
    end
  end
  return nil
end

function table.size(t)
  local size = 0
  for i, n in pairs(t) do
    size = size + 1
  end

  return size
end

function table.tostring(t)
  local maxn = #t
  local str = ""
  for k,v in pairs(t) do
    v = tostring(v)
    if k == maxn and k ~= 1 then
      str = str .. " and " .. v
    elseif maxn > 1 and k ~= 1 then
      str = str .. ", " .. v
    else
      str = str .. " " .. v
    end
  end
  return str
end

function table.collect(t, func)
  local res = {}
  for k,v in pairs(t) do
    local a,b = func(k,v)
    if a and b then
      res[a] = b
    elseif a ~= nil then
      table.insert(res,a)
    end
  end
  return res
end

function table.equals(t, comp)
  if type(t) == "table" and type(comp) == "table" then
    for k,v in pairs(t) do
      if v ~= comp[k] then return false end
    end
  end
  return true
end

function table.equal(t1,t2,ignore_mt)
   local ty1 = type(t1)
   local ty2 = type(t2)
   if ty1 ~= ty2 then return false end
   -- non-table types can be directly compared
   if ty1 ~= 'table' and ty2 ~= 'table' then return t1 == t2 end
   -- as well as tables which have the metamethod __eq
   local mt = getmetatable(t1)
   if not ignore_mt and mt and mt.__eq then return t1 == t2 end
   for k1,v1 in pairs(t1) do
      local v2 = t2[k1]
      if v2 == nil or not table.equal(v1,v2) then return false end
   end
   for k2,v2 in pairs(t2) do
      local v1 = t1[k2]
      if v1 == nil or not table.equal(v1,v2) then return false end
   end
   return true
end

function table.isList(t)
  local size = #t
  return table.size(t) == size and size > 0
end

function table.isStringList(t)
  if not table.isList(t) then return false end
  for k,v in ipairs(t) do
    if type(v) ~= 'string' then
      return false
    end
  end
  return true
end

function table.isStringPairList(t)
  if not table.isList(t) then return false end
  for k,v in ipairs(t) do
    if type(v) ~= 'table' or #v ~= 2 or type(v[1]) ~= 'string' or type(v[2]) ~= 'string' then
      return false
    end
  end
  return true
end

function table.encodeStringPairList(t)
  local ret = ""
  for k,v in ipairs(t) do
    if v[2]:find("\n") then
      ret = ret .. v[1] .. ":[[\n" .. v[2] .. "\n]]\n"
    else
      ret = ret .. v[1] .. ":" .. v[2] .. "\n"
    end
  end
  return ret
end

function table.decodeStringPairList(l)
  local ret = {}
  local r = regexMatch(l, "(?:^|\\n)([^:^\n]{1,20}):?(.*)(?:$|\\n)")
  local multiline = ""
  local multilineKey = ""
  local multilineActive = false
  for k,v in ipairs(r) do
    if multilineActive then
      local endPos = v[1]:find("%]%]")
      if endPos then
        if endPos > 1 then
          table.insert(ret, {multilineKey, multiline .. "\n" .. v[1]:sub(1, endPos - 1)})       
        else
          table.insert(ret, {multilineKey, multiline})       
        end
        multilineActive = false
        multiline = ""
        multilineKey = ""
      else
        if multiline:len() == 0 then
          multiline = v[1]
        else
          multiline = multiline .. "\n" .. v[1]        
        end
      end
    else
      local bracketPos = v[3]:find("%[%[")
      if bracketPos == 1 then -- multiline begin
        multiline = v[3]:sub(bracketPos + 2)
        multilineActive = true
        multilineKey = v[2]
      elseif v[2]:len() > 0 and v[3]:len() > 0 then
        table.insert(ret, {v[2], v[3]})
      end
    end    
  end
  return ret
end

string.split = function(str, sep)
	local res = {}
	for v in str:gmatch("([^" .. sep .. "]+)") do
		res[#res + 1] = v
	end
	return res
end

string.splitTrimmed = function(str, sep)
	local res = {}
	for v in str:gmatch("([^" .. sep .. "]+)") do
		res[#res + 1] = v:trim()
	end
	return res
end

string.trim = function(str)
	return str:match '^()%s*$' and '' or str:match '^%s*(.*%S)'
end

if not nextUseStaminaTime then
	nextUseStaminaTime = {}
end

function getPlayerDatabaseInfo(name_or_guid)
	local sql_where = ""

	if type(name_or_guid) == 'string' then
		sql_where = "WHERE `p`.`name`=" .. db.escapeString(name_or_guid) .. ""
	elseif type(name_or_guid) == 'number' then
		sql_where = "WHERE `p`.`id`='" .. name_or_guid .. "'"
	else
		return false
	end

	local sql_query = [[
		SELECT
			`p`.`id` as `guid`,
			`p`.`name`,
			CASE WHEN `po`.`player_id` IS NULL
				THEN 0
				ELSE 1
			END AS `online`,
			`p`.`group_id`,
			`p`.`level`,
			`p`.`experience`,
			`p`.`vocation`,
			`p`.`maglevel`,
			`p`.`skill_fist`,
			`p`.`skill_melee`,
			`p`.`skill_dist`,
			`p`.`skill_shielding`,
			`p`.`skill_fishing`,
			`p`.`town_id`,
			`p`.`balance`,
			`gm`.`guild_id`,
			`gm`.`nick`,
			`g`.`name` AS `guild_name`,
			CASE WHEN `p`.`id` = `g`.`ownerid`
				THEN 1
				ELSE 0
			END AS `is_leader`,
			`gr`.`name` AS `rank_name`,
			`gr`.`level` AS `rank_level`,
			`h`.`id` AS `house_id`,
			`h`.`name` AS `house_name`,
			`h`.`town_id` AS `house_town`
		FROM `players` AS `p`
		LEFT JOIN `players_online` AS `po`
			ON `p`.`id` = `po`.`player_id`
		LEFT JOIN `guild_membership` AS `gm`
			ON `p`.`id` = `gm`.`player_id`
		LEFT JOIN `guilds` AS `g`
			ON `gm`.`guild_id` = `g`.`id`
		LEFT JOIN `guild_ranks` AS `gr`
			ON `gm`.`rank_id` = `gr`.`id`
		LEFT JOIN `houses` AS `h`
			ON `p`.`id` = `h`.`owner`
	]] .. sql_where

	local query = db.storeQuery(sql_query)
	if not query then
		return false
	end

	local info = {
		["guid"] = result.getNumber(query, "guid"),
		["name"] = result.getString(query, "name"),
		["online"] = result.getNumber(query, "online"),
		["group_id"] = result.getNumber(query, "group_id"),
		["level"] = result.getNumber(query, "level"),
		["experience"] = result.getNumber(query, "experience"),
		["vocation"] = result.getNumber(query, "vocation"),
		["maglevel"] = result.getNumber(query, "maglevel"),
		["skill_fist"] = result.getNumber(query, "skill_fist"),
		["skill_melee"] = result.getNumber(query, "skill_melee"),
		["skill_dist"] = result.getNumber(query, "skill_dist"),
		["skill_shielding"] = result.getNumber(query, "skill_shielding"),
		["skill_fishing"] = result.getNumber(query, "skill_fishing"),
		["town_id"] = result.getNumber(query, "town_id"),
		["balance"] = result.getNumber(query, "balance"),
		["guild_id"] = result.getNumber(query, "guild_id"),
		["nick"] = result.getString(query, "nick"),
		["guild_name"] = result.getString(query, "guild_name"),
		["is_leader"] = result.getNumber(query, "is_leader"),
		["rank_name"] = result.getString(query, "rank_name"),
		["rank_level"] = result.getNumber(query, "rank_level"),
		["house_id"] = result.getNumber(query, "house_id"),
		["house_name"] = result.getString(query, "house_name"),
		["house_town"] = result.getNumber(query, "house_town")
	}

	result.free(query)
	return info
end

function getItemAttribute(uid, key)
	local i = ItemType(Item(uid):getId())
	local string_attributes = {
		[ITEM_ATTRIBUTE_NAME] = i:getName(),
		[ITEM_ATTRIBUTE_ARTICLE] = i:getArticle(),
		[ITEM_ATTRIBUTE_PLURALNAME] = i:getPluralName(),
		["name"] = i:getName(),
		["article"] = i:getArticle(),
		["pluralname"] = i:getPluralName()
	}

	local numeric_attributes = {
		[ITEM_ATTRIBUTE_WEIGHT] = i:getWeight(),
		[ITEM_ATTRIBUTE_ATTACK] = i:getAttack(),
		[ITEM_ATTRIBUTE_DEFENSE] = i:getDefense(),
		[ITEM_ATTRIBUTE_EXTRADEFENSE] = i:getExtraDefense(),
		[ITEM_ATTRIBUTE_ARMOR] = i:getArmor(),
		[ITEM_ATTRIBUTE_HITCHANCE] = i:getHitChance(),
		[ITEM_ATTRIBUTE_SHOOTRANGE] = i:getShootRange(),
		["weight"] = i:getWeight(),
		["attack"] = i:getAttack(),
		["defense"] = i:getDefense(),
		["extradefense"] = i:getExtraDefense(),
		["armor"] = i:getArmor(),
		["hitchance"] = i:getHitChance(),
		["shootrange"] = i:getShootRange()
	}

	local attr = Item(uid):getAttribute(key)
	if tonumber(attr) then
		if numeric_attributes[key] then
			return attr ~= 0 and attr or numeric_attributes[key]
		end
	else
		if string_attributes[key] then
			if attr == "" then
				return string_attributes[key]
			end
		end
	end
	return attr
end

function doItemSetAttribute(uid, key, value)
	return Item(uid):setAttribute(key, value)
end

function doItemEraseAttribute(uid, key)
	return Item(uid):removeAttribute(key)
end

function Container.getItemsById(self, itemId)
	local list = {}
	for index = 0, (self:getSize() - 1) do
		local item = self:getItem(index)
		if item then
			if item:isContainer() then
				local rlist = item:getItemsById(itemId)
				if type(rlist) == 'table' then
					for _, v in pairs(rlist) do
						table.insert(list, v)
					end
				end
			else
				if item:getId() == itemId then
					table.insert(list, item)
				end
			end
		end
	end
	return list
end

-------------------------------AUTOMATIC TASK FUNCTIONS
table.append = table.insert
table.empty = function(t)
	return next(t) == nil
end

table.find = function(table, value)
	for i, v in pairs(table) do
		if (v == value) then
			return i
		end
	end

	return nil
end

table.count = function(table, item)
	local count = 0
	for i, n in pairs(table) do
		if (item == n) then
			count = count + 1
		end
	end

	return count
end
table.countElements = table.count

table.getCombinations = function(table, num)
	local a, number, select, newlist = {}, #table, num, {}
	for i = 1, select do
		a[#a + 1] = i
	end

	local newthing = {}
	while (true) do
		local newrow = {}
		for i = 1, select do
			newrow[#newrow + 1] = table[a[i]]
		end

		newlist[#newlist + 1] = newrow
		i = select
		while (a[i] == (number - select + i)) do
			i = i - 1
		end

		if (i < 1) then
			break
		end

		a[i] = a[i] + 1
		for j = i, select do
			a[j] = a[i] + j - i
		end
	end

	return newlist
end

function table.serialize(x, recur)
	local t = type(x)
	recur = recur or {}

	if (t == nil) then
		return "nil"
	elseif (t == "string") then
		return string.format("%q", x)
	elseif (t == "number") then
		return tostring(x)
	elseif (t == "boolean") then
		return t and "true" or "false"
	elseif (getmetatable(x)) then
		error("Can not serialize a table that has a metatable associated with it.")
	elseif (t == "table") then
		if (table.find(recur, x)) then
			error("Can not serialize recursive tables.")
		end
		table.append(recur, x)

		local s = "{"
		for k, v in pairs(x) do
			s = s .. "[" .. table.serialize(k, recur) .. "]"
			s = s .. " = " .. table.serialize(v, recur) .. ","
		end
		s = s .. "}"
		return s
	else
		error("Can not serialize value of type '" .. t .. "'.")
	end
end

function table.unserialize(str)
	return loadstring("return " .. str)()
end

function getMonsterInfo(param)
	local target = Creature(param)
	if target == nil then
		return false
	end
	return target
end

function getAllItemsById(cid, id)
	local containers = {}
	local items = {}

	for i = CONST_SLOT_FIRST, CONST_SLOT_LAST do
		local sitem = getPlayerSlotItem(cid, i)
		if sitem.uid > 0 then
			if isContainer(sitem.uid) then
				table.insert(containers, sitem.uid)
			elseif not (id) or id == sitem.itemid then
				table.insert(items, sitem)
			end
		end
	end

	while #containers > 0 do
		for k = (getContainerSize(containers[1]) - 1), 0, -1 do
			local tmp = getContainerItem(containers[1], k)
			if isContainer(tmp.uid) then
				table.insert(containers, tmp.uid)
			elseif not (id) or id == tmp.itemid then
				table.insert(items, tmp)
			end
		end
		table.remove(containers, 1)
	end

	return items
end

function getAllItemsBySlot(cid, slot, id)
	local containers = {}
	local items = {}

	local sitem = getPlayerSlotItem(cid, i)
	if sitem.uid > 0 then
		if isContainer(sitem.uid) then
			table.insert(containers, sitem.uid)
		elseif not (id) or id == sitem.itemid then
			table.insert(items, sitem)
		end
	end

	while #containers > 0 do
		for k = (getContainerSize(containers[1]) - 1), 0, -1 do
			local tmp = getContainerItem(containers[1], k)
			if isContainer(tmp.uid) then
				table.insert(containers, tmp.uid)
			elseif not (id) or id == tmp.itemid then
				table.insert(items, tmp)
			end
		end
		table.remove(containers, 1)
	end

	return items
end

function comma_value(amount)
	local formatted = amount
	while true do
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", "%1.%2")
		if (k == 0) then
			break
		end
	end
	return formatted
end

function Player.removeTotalMoney(self, amount, dontSendMessage)
	local moneyCount = self:getMoney()
	local bankCount = self:getBankBalance()

	if amount <= moneyCount then
		self:removeMoney(amount)
		return true
	elseif amount <= (moneyCount + bankCount) then
		if moneyCount ~= 0 then
			self:removeMoney(moneyCount)
			local remains = amount - moneyCount
			self:setBankBalance(bankCount - remains)
			self:refreshBalance()
			if not dontSendMessage then
				self:sendTextMessage(MESSAGE_INFO_DESCR,
					("Paid %s from inventory and %s gold from bank account. Your account balance is now %s gold."):format(
						comma_value(moneyCount), comma_value(amount - moneyCount), comma_value(self:getBankBalance())))
			end
			return true
		else
			self:setBankBalance(bankCount - amount)
			if not dontSendMessage then
				self:sendTextMessage(MESSAGE_INFO_DESCR,
					("Paid %s gold from bank account. Your account balance is now %s gold."):format(comma_value(amount),
						comma_value(self:getBankBalance())))
			end
			self:refreshBalance()
			return true
		end
	end
	return false
end

function Player.getTotalMoney(self)
	return self:getMoney() + self:getBankBalance()
end

function isValidMoney(money)
	return isNumber(money) and money > 0
end

function getMoneyCount(string)
	local b, e = string:find("%d+")
	local money = b and e and tonumber(string:sub(b, e)) or -1
	if isValidMoney(money) then
		return money
	end
	return -1
end

function getMoneyWeight(money)
	local gold = money
	local crystal = math.floor(gold / 10000)
	gold = gold - crystal * 10000
	local platinum = math.floor(gold / 100)
	gold = gold - platinum * 100
	return (ItemType(ITEM_CRYSTAL_COIN):getWeight() * crystal) + (ItemType(ITEM_PLATINUM_COIN):getWeight() * platinum) +
		(ItemType(ITEM_GOLD_COIN):getWeight() * gold)
end

-- This function will capitalize the first letter of every word.
function capAll(str)
	local newStr = ""; wordSeparate = string.gmatch(str, "([^%s]+)")
	for v in wordSeparate do
		v = v:gsub("^%l", string.upper)
		if newStr ~= "" then
			newStr = newStr .. " " .. v
		else
			newStr = v
		end
	end
	return newStr
end

globalStorages = {}

function Game.getStorageValue(key)
	return globalStorageTable[key]
end

function Game.setStorageValue(key, value)
	globalStorageTable[key] = value
end

function Player.getTotalArmor(self)
	local total = 0
	local slots = { CONST_SLOT_HEAD, CONST_SLOT_ARMOR, CONST_SLOT_LEGS, CONST_SLOT_FEET } -- CONST_SLOT_NECKLACE, CONST_SLOT_RING, CONST_SLOT_GLOVES, CONST_SLOT_RING2
	local item
	for i = 1, #slots do
		item = self:getSlotItem(slots[i])
		if item then
			local attackT = item:hasAttribute(ITEM_ATTRIBUTE_ARMOR) and item:getAttribute(ITEM_ATTRIBUTE_ARMOR) or item:getType():getArmor()
			total = total + attackT
		end
	end
	return total
end

function Player.getTotalDefense(self)
	local total = 0
	local slots = { CONST_SLOT_RIGHT, CONST_SLOT_LEFT }
	local item
	for i = 1, #slots do
		item = self:getSlotItem(slots[i])
		if item then
			local attackT = item:hasAttribute(ITEM_ATTRIBUTE_DEFENSE) and item:getAttribute(ITEM_ATTRIBUTE_DEFENSE) or item:getType():getDefense()
			total = total + attackT
		end
	end
	return total
end

function Player.getTotalAttack(self)
	local total = 0
	local dualWilding = false
	local slots = { CONST_SLOT_RIGHT, CONST_SLOT_LEFT } -- CONST_SLOT_GLOVES
	local item
	for i = 1, #slots do
		item = self:getSlotItem(slots[i])
		if item then
			local attackT = item:hasAttribute(ITEM_ATTRIBUTE_ATTACK) and item:getAttribute(ITEM_ATTRIBUTE_ATTACK) or item:getType():getAttack()
			if item:getQuality() or item:getUpgradeLevel() then
				attackT = attackT + math.ceil(attackT * (item:getQuality() + calculateUpgradeValue(item:getUpgradeLevel() or 0)) / 100) -- math.floor((attackT * (1 + (item:getQuality() + calculateUpgradeValue(item:getUpgradeLevel() or 0) / 100)))) 
			end
			total = total + attackT
			if colleftInfo[self:getId()].attributesItems[217] then -- unique Adaptive
				local levelCap = math.min(self:getLevel(), 100)
				local adapriveAt = (levelCap * (colleftInfo[self:getId()].attributesItems[217].value * US_ENCHANTMENTS[217].subvalue))
				local adptiveTotal = math.ceil(adapriveAt * (item:getQuality() + calculateUpgradeValue(item:getUpgradeLevel() or 0)) / 100)
				total = total + adptiveTotal
			end
		end
	end
	return total
end

function Player.getAttackBoth(self)
	local total = 0
	local slots = { CONST_SLOT_RIGHT, CONST_SLOT_LEFT } -- CONST_SLOT_GLOVES
	local item
	for i = 1, #slots do
		item = self:getSlotItem(slots[i])
		if item then
			local attackT = item:hasAttribute(ITEM_ATTRIBUTE_ATTACK) and item:getAttribute(ITEM_ATTRIBUTE_ATTACK) or item:getType():getAttack()
			total = total + attackT
		end
	end
	return total
end

MONSTER_STORAGE = MONSTER_STORAGE or {}

function Monster.setStorageValue(self, key, value)
	local cid = self:getId()
	local storageMap = MONSTER_STORAGE[cid]
	if cid then
		if not storageMap then
			MONSTER_STORAGE[cid] = { [key] = value }
		else
			storageMap[key] = value
		end
	end
end

function Monster.getStorageValue(self, key)
	local storageMap = MONSTER_STORAGE[self:getId()]
	if storageMap then
		return storageMap[key] or -1
	end
	return -1
end

area3x3 = createCombatArea {
	{ 1, 1, 1 },
	{ 1, 3, 1 },
	{ 1, 1, 1 }
}

area3x3nocenter = createCombatArea {
	{ 1, 1, 1 },
	{ 1, 2, 1 },
	{ 1, 1, 1 }
}

cleaveAreaNORTH = createCombatArea {
	{ 1, 1, 1 },
	{ 0, 2, 0 },
	{ 0, 0, 0 }
}
cleaveAreaEAST = createCombatArea {
	{ 1, 0, 0 },
	{ 1, 2, 0 },
	{ 1, 0, 0 }
}
cleaveAreaSOUTH = createCombatArea {
	{ 0, 0, 0 },
	{ 0, 2, 0 },
	{ 1, 1, 1 }
}
cleaveAreaWEST = createCombatArea {
	{ 0, 0, 1 },
	{ 0, 2, 1 },
	{ 0, 0, 1 }
}

areaPaladin = createCombatArea {
	{ 1, 0, 1 },
	{ 0, 3, 0 },
	{ 1, 0, 1 }
}
a3x3effect = createCombatArea {
	{ 0, 0, 0, 0, 0, 0, 0 },
	{ 0, 0, 1, 1, 1, 0, 0 },
	{ 0, 1, 1, 1, 1, 1, 0 },
	{ 0, 1, 1, 3, 1, 1, 0 },
	{ 0, 1, 1, 1, 1, 1, 0 },
	{ 0, 0, 1, 1, 1, 0, 0 },
	{ 0, 0, 0, 0, 0, 0, 0 }
}
a3x3effectnocenter = createCombatArea {
	{ 0, 0, 0, 0, 0, 0, 0 },
	{ 0, 0, 1, 1, 1, 0, 0 },
	{ 0, 1, 1, 1, 1, 1, 0 },
	{ 0, 1, 1, 2, 1, 1, 0 },
	{ 0, 1, 1, 1, 1, 1, 0 },
	{ 0, 0, 1, 1, 1, 0, 0 },
	{ 0, 0, 0, 0, 0, 0, 0 }
}

masshealingArea = createCombatArea {
	{ 0, 0, 1, 1, 1, 0, 0 },
	{ 0, 1, 1, 1, 1, 1, 0 },
	{ 1, 1, 1, 1, 1, 1, 1 },
	{ 1, 1, 1, 3, 1, 1, 1 },
	{ 1, 1, 1, 1, 1, 1, 1 },
	{ 0, 1, 1, 1, 1, 1, 0 },
	{ 0, 0, 1, 1, 1, 0, 0 }
}

masshealingAreaCleave = createCombatArea {
	{ 0, 0, 1, 1, 1, 0, 0 },
	{ 0, 1, 1, 1, 1, 1, 0 },
	{ 1, 1, 1, 1, 1, 1, 1 },
	{ 1, 1, 1, 2, 1, 1, 1 },
	{ 1, 1, 1, 1, 1, 1, 1 },
	{ 0, 1, 1, 1, 1, 1, 0 },
	{ 0, 0, 1, 1, 1, 0, 0 }
}

AREA_CIRCLE4X4combat = createCombatArea {
	{ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
	{ 0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0 },
	{ 0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0 },
	{ 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0 },
	{ 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0 },
	{ 0, 1, 1, 1, 1, 3, 1, 1, 1, 1, 0 },
	{ 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0 },
	{ 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0 },
	{ 0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0 },
	{ 0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0 },
	{ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }
}

function formatItemTypeUPGRADE(itemType)
	local weaponType = itemType:getWeaponType()
	if weaponType ~= WEAPON_SHIELD then
		local slotPosition = itemType:getSlotPosition() - SLOTP_LEFT - SLOTP_RIGHT
		if weaponType == WEAPON_SWORD then
			return "Sword"
		elseif weaponType == WEAPON_CLUB then
			return "Club"
		elseif weaponType == WEAPON_AXE then
			return "Axe"
		elseif itemType:getName():find("knife") and weaponType == WEAPON_DISTANCE then
			return "Tknife"
		elseif itemType:getName():find("Crossbow") and weaponType == WEAPON_DISTANCE then
			return "Crossbow"
		elseif itemType:getName():find("Bow") and weaponType == WEAPON_DISTANCE then
			return "Bow"
		elseif itemType:getName():find("AoE") and weaponType == WEAPON_WAND then
			return "BloodyWand"
		elseif not itemType:getName():find("AoE") and weaponType == WEAPON_WAND then
			return "Wand"
		elseif slotPosition == SLOTP_CZTERY then
			return "Pet"
		elseif slotPosition == SLOTP_HEAD then
			return "Helmet"
		elseif slotPosition == SLOTP_NECKLACE then
			return "Necklace"
		elseif slotPosition == SLOTP_ARMOR then
			return "Armor"
		elseif slotPosition == SLOTP_LEGS then
			return "Legs"
		elseif slotPosition == SLOTP_FEET then
			return "Boots"
		elseif slotPosition == SLOTP_RING or slotPosition == SLOTP_RING2 then
			return "Ring"
		elseif slotPosition == SLOTP_GLOVES then
			return "Gloves"
		elseif itemType:isRune() then
			return "Rune"
		elseif itemType:isContainer() then
			return "Container"
		elseif itemType:isFluidContainer() then
			return "Potion"
		elseif itemType:isUseable() then
			return "Usable"
		end
	else
		return "Shield"
	end
	return "Common"
end

function setEndlessArenaLevel(player, point)
	db.query("UPDATE `players` SET `endless_level` = " .. point .. " WHERE `id` = " .. player:getGuid())
	return point
end

function getEndlessArenaLevel(player)
	local point = 0
	local resultId = db.storeQuery("SELECT `endless_level` FROM `players` WHERE `id` = " .. player:getGuid())
	if resultId ~= false then
		point = result.getDataInt(resultId, "endless_level")
		result.free(resultId)
	end
	return point
end

function getDay(player)
	local day = 0
	local resultId = db.storeQuery("SELECT `day` FROM `znote_accounts` WHERE `account_id` = " .. player:getAccountId())
	if resultId ~= false then
		day = result.getDataInt(resultId, "day")
		result.free(resultId)
	end
	return day
end

function setDay(player, add_point)
	db.query("UPDATE `znote_accounts` SET `day` = " .. add_point .. " WHERE `account_id` = " .. player:getAccountId())
	return day
end

function getDailyRewards(player)
	local daily_rewards = 0
	local resultId = db.storeQuery("SELECT `daily_rewards` FROM `znote_accounts` WHERE `account_id` = " ..
		player:getAccountId())
	if resultId ~= false then
		daily_rewards = result.getDataInt(resultId, "daily_rewards")
		result.free(resultId)
	end
	return daily_rewards
end

function setDailyRewards(player, add_point)
	db.query("UPDATE `znote_accounts` SET `daily_rewards` = " ..
		add_point .. " WHERE `account_id` = " .. player:getAccountId())
	return daily_rewards
end

function getSeasonPoints(player) -- season points
	local season_pass_points = 0
	local resultId = db.storeQuery("SELECT `season_pass_points` FROM `znote_accounts` WHERE `account_id` = " ..
		player:getAccountId())
	if resultId ~= false then
		season_pass_points = result.getDataInt(resultId, "season_pass_points")
		result.free(resultId)
	end
	return season_pass_points
end

function getSeasonLevel(player) -- season reward free
	local season_pass_level = 0
	local resultId = db.storeQuery("SELECT `season_pass_level` FROM `znote_accounts` WHERE `account_id` = " ..
		player:getAccountId())
	if resultId ~= false then
		season_pass_level = result.getDataInt(resultId, "season_pass_level")
		result.free(resultId)
	end
	return season_pass_level
end

function setSeasonLevel(player, add_point) -- season points add
	db.query("UPDATE `znote_accounts` SET `season_pass_level` = " ..
		add_point .. " WHERE `account_id` = " .. player:getAccountId())
	return season_pass_level
end

function getSeasonRewardFree(player) -- season reward free
	local season_pass_reward_free = 0
	local resultId = db.storeQuery("SELECT `season_pass_reward_free` FROM `znote_accounts` WHERE `account_id` = " ..
		player:getAccountId())
	if resultId ~= false then
		season_pass_reward_free = result.getDataInt(resultId, "season_pass_reward_free")
		result.free(resultId)
	end
	return season_pass_reward_free
end

function getSeasonRewardPremium(player) -- season reward premium
	local season_pass_reward_premium = 0
	local resultId = db.storeQuery("SELECT `season_pass_reward_premium` FROM `znote_accounts` WHERE `account_id` = " ..
		player:getAccountId())
	if resultId ~= false then
		season_pass_reward_premium = result.getDataInt(resultId, "season_pass_reward_premium")
		result.free(resultId)
	end
	return season_pass_reward_premium
end

function hasSeasonPass(player) -- season pass have or not
	local season_pass = 0
	local resultId = db.storeQuery("SELECT `season_pass` FROM `znote_accounts` WHERE `account_id` = " ..
		player:getAccountId())
	if resultId ~= false then
		season_pass = result.getDataInt(resultId, "season_pass")
		result.free(resultId)
	end
	return season_pass
end

function setSeasonPoints(player, add_point) -- season points add
	db.query("UPDATE `znote_accounts` SET `season_pass_points` = " ..
		add_point .. " WHERE `account_id` = " .. player:getAccountId())
	return season_pass_points
end

function setSeasonPass(player, season_get) -- season pass add
	db.query("UPDATE `znote_accounts` SET `season_pass` = " ..
		season_get .. " WHERE `account_id` = " .. player:getAccountId())
	return season_pass_points
end

function setSeasonRewardFree(player, add_point) -- season reard add point
	db.query("UPDATE `znote_accounts` SET `season_pass_reward_free` = " ..
		add_point .. " WHERE `account_id` = " .. player:getAccountId())
	return season_pass_reward_free
end

function setSeasonRewardPremium(player, add_point) -- season reard add point
	db.query("UPDATE `znote_accounts` SET `season_pass_reward_premium` = " ..
		add_point .. " WHERE `account_id` = " .. player:getAccountId())
	return season_pass_reward_premium
end

function getMlvlSQL(player) -- season reward premium
	local season_mlvl = 0
	local playerId = player:getGuid()
	local resultId = db.storeQuery("SELECT `maglevel` FROM `players` WHERE `id` = " .. playerId)
	if resultId ~= false then
		season_mlvl = result.getDataInt(resultId, "maglevel")
		result.free(resultId)
	end
	return season_mlvl
end

function print_r(t)
	local print_r_cache = {}
	local function sub_print_r(t, indent)
		if (print_r_cache[tostring(t)]) then
			print(indent .. "*" .. tostring(t))
		else
			print_r_cache[tostring(t)] = true
			if (type(t) == "table") then
				for pos, val in pairs(t) do
					if (type(val) == "table") then
						print(indent .. "[" .. pos .. "] => " .. tostring(t) .. " {")
						sub_print_r(val, indent .. string.rep(" ", string.len(pos) + 8))
						print(indent .. string.rep(" ", string.len(pos) + 6) .. "}")
					else
						print(indent .. "[" .. pos .. "] => " .. tostring(val))
					end
				end
			else
				print(indent .. tostring(t))
			end
		end
	end
	sub_print_r(t, "  ")
end

function getNextAvailableContainer(container)
	if container:getEmptySlots() > 0 then
		return container
	end

	for index = 0, container:getSize() - 1, 1 do
		local item = container:getItem(index)

		if item:isContainer() then
			item = getNextAvailableContainer(item)

			if item ~= nil then
				return item
			end
		end
	end

	return nil
end

function isBadTile(pos)
	local tile = Tile(pos)
	return (
		tile == nil or tile:getGround() == nil
		or isItem(tile:getThing()) and not isMoveable(tile:getThing())
		or tile:hasProperty(TILESTATE_NONE)
		or tile:hasFlag(TILESTATE_FLOORCHANGE)
		or tile:hasFlag(TILESTATE_HOUSE)
		or tile:hasFlag(TILESTATE_BLOCKSOLID)
		or not tile:isWalkable()
		or tile:hasFlag(TILESTATE_PROTECTIONZONE)
		or tile:getTopCreature()
	)
end


function formatDamage(damage)
  local units = {
      {1e15, "Q"},
      {1e12, "T"},
      {1e9,  "B"},
      {1e6,  "M"},
      {1e3,  "K"}
  }

  for _, unit in ipairs(units) do
		local value, suffix = unit[1], unit[2]
		if damage >= value then
			return string.format("%.2f%s", damage / value, suffix)
		end
  end

  return tostring(damage)
end

function isBadTileCreature(pos)
	local tile = Tile(pos)
	return (
		tile == nil or tile:getGround() == nil
		or isItem(tile:getThing()) and not isMoveable(tile:getThing())
		or tile:hasProperty(TILESTATE_NONE)
		or tile:hasFlag(TILESTATE_FLOORCHANGE)
		or tile:hasFlag(TILESTATE_HOUSE)
		or tile:hasFlag(TILESTATE_BLOCKSOLID)
		or not tile:isWalkable()
		or tile:hasFlag(TILESTATE_PROTECTIONZONE)
	)
end

function isBadTileOEN(tile)
	return (tile == nil
		or tile:getGround() == nil
		or tile:hasProperty(TILESTATE_NONE)
		or tile:hasProperty(TILESTATE_FLOORCHANGE_EAST)
		or tile:hasFlag(TILESTATE_FLOORCHANGE)
		or tile:hasFlag(TILESTATE_HOUSE)
		or tile:hasFlag(TILESTATE_BLOCKSOLID)
		or isItem(tile:getThing()) and not isMoveable(tile:getThing())
		or tile:getTopCreature()
		or not tile:isWalkable()
		or tile:hasFlag(TILESTATE_PROTECTIONZONE)
	)
end

function isBadTile2(tile)
	return (tile == nil
		or tile:getGround() == nil
		or tile:hasProperty(TILESTATE_NONE)
		-- or tile:hasProperty(TILESTATE_FLOORCHANGE_EAST)
		or tile:hasFlag(TILESTATE_FLOORCHANGE)
		or tile:hasFlag(TILESTATE_HOUSE)
		or tile:hasFlag(TILESTATE_BLOCKSOLID)
		or isItem(tile:getThing()) and not isMoveable(tile:getThing())
		or not tile:isWalkable()
		or tile:hasFlag(TILESTATE_PROTECTIONZONE)
	)
end

function Player.savePosition(self, storage)
	self:setStorageValue(storage, self:getPosition().x)
	self:setStorageValue(storage + 1, self:getPosition().y)
	self:setStorageValue(storage + 2, self:getPosition().z)
end

function Player.loadPosition(self, storage)
	return Position(self:getStorageValue(storage), self:getStorageValue(storage + 1), self:getStorageValue(storage + 2))
end


function setAncientItemAttackArmorDefense(player, item, atk, arm, def, hitChance)
	if item:getId() == 0 then return end
	if item then
		local weaponTypeID = item:getType()
		local weaponType = formatItemTypeUPGRADE(weaponTypeID)
		if weaponTypeID:getArmor() > 0 then
			item:setAttribute(ITEM_ATTRIBUTE_ARMOR, arm)
		elseif weaponType == "Wand" then
			item:setAttribute(ITEM_ATTRIBUTE_ATTACK, atk)
		elseif weaponTypeID:getShootRange() > 1 then
			item:setAttribute(ITEM_ATTRIBUTE_ATTACK, atk)
			if weaponType == "Bow" or weaponType == "Crossbow" or weaponType == "Tknife" then
				item:setAttribute(ITEM_ATTRIBUTE_HITCHANCE, hitChance)
			end
		elseif weaponTypeID:getAttack() > 0 then
			item:setAttribute(ITEM_ATTRIBUTE_ATTACK, atk)
			item:setAttribute(ITEM_ATTRIBUTE_DEFENSE, 0)
		elseif weaponTypeID:getDefense() > 0 then
			item:setAttribute(ITEM_ATTRIBUTE_DEFENSE, def)
		end
	end
	return true
end

function setItemStatsPercent(player, item, percent)
	if item:getId() == 0 then return end
	if item then
		local weaponTypeID = item:getType()
		local weaponType = formatItemTypeUPGRADE(weaponTypeID)
		if weaponTypeID:getArmor() > 0 then
			item:setAttribute(ITEM_ATTRIBUTE_ARMOR, item:getCustomAttribute("base_armor") + (item:getCustomAttribute("base_armor") * percent))
		elseif weaponType == "Wand" then
			item:setAttribute(ITEM_ATTRIBUTE_ATTACK,
				item:getAttribute(ITEM_ATTRIBUTE_ATTACK) +
				math.ceil((item:getAttribute(ITEM_ATTRIBUTE_ATTACK) * percent)))
		elseif weaponTypeID:getShootRange() > 1 then
			item:setAttribute(ITEM_ATTRIBUTE_ATTACK, item:getCustomAttribute("base_attack") + (item:getCustomAttribute("base_attack") * percent))
			if weaponType == "Bow" or weaponType == "Crossbow" or weaponType == "Tknife" then
				item:setAttribute(ITEM_ATTRIBUTE_HITCHANCE, 1)
			end
		elseif weaponTypeID:getAttack() > 0 then
			item:setAttribute(ITEM_ATTRIBUTE_ATTACK, item:getCustomAttribute("base_attack") + (item:getCustomAttribute("base_attack") * percent))
			item:setAttribute(ITEM_ATTRIBUTE_DEFENSE, 0)
		elseif weaponTypeID:getDefense() > 0 then
			item:setAttribute(ITEM_ATTRIBUTE_DEFENSE, item:getCustomAttribute("base_defense") + (item:getCustomAttribute("base_defense") * percent))
		end
	end
	return true
end


function Player.getTotalAttackSpeed(self, checkCollectInfo)
	if checkCollectInfo and colleftInfo[self:getId()] == nil then
		return 0
	end

	local as = (CHAMPION_STATS[self:getVocation():getName()].asPL / 60) * self:getLevel()

	if colleftInfo[self:getId()].attributesItems[11] then
		as = as + colleftInfo[self:getId()].attributesItems[11].value
	end
	if as == 0 then
		self:removeCondition(CONDITION_ATTRIBUTES, CONDITIONID_COMBAT, 712345)
	else
		local conditionHaste = Condition(CONDITION_ATTRIBUTES)
		conditionHaste:setParameter(CONDITION_PARAM_SUBID, 712345)
		conditionHaste:setParameter(CONDITION_PARAM_ATTACKSPEED, as)
		conditionHaste:setParameter(CONDITION_PARAM_TICKS, -1) --2 secs
		self:addCondition(conditionHaste)
	end

	return as
end

function Player.getAST(self)
	local as = 0
	if self:hasBuff(AMOK) then
		as = as + (self:getBuff(AMOK).stacks * 5)
	end
	if self:hasBuff(SWIFT_KILLER) then
		as = as + (self:getBuff(SWIFT_KILLER).stacks * 1)
	end
	if self:hasBuff(FRENZY_AURA) then
		as = as + (10 + self:getBuff(FRENZY_AURA).stacks * 0.37)
	end
	if colleftInfo[self:getId()].attributesItems[55] then
		as = as + colleftInfo[self:getId()].attributesItems[55].value
	end
	if self:hasBuff(SHRINE_ATTACKSPEED) then
		as = as + 300
	end
	-- Trait
	if self:hasBuff(ARCHER_TRAIT) then
		as = as + (5 + self:getBuff(ARCHER_TRAIT).stacks * 5)
	end
	if self:getCharacterStat(CHARSTAT_CRITICAL_DAMAGE) then
		as = as + self:getCharacterStat(CHARSTAT_CRITICAL_DAMAGE)
	end
	return as
end

function Player.getCooldownReduction(self)
	local cd = 0
	if self:hasBuff(CD_FLASK) then
		cd = cd + 30
	end
	if colleftInfo[self:getId()].attributesItems[56] then
		cd = cd + colleftInfo[self:getId()].attributesItems[56].value
	end
	if self:getCharacterStat(CHARSTAT_REGEN) then
		cd = cd + (self:getCharacterStat(CHARSTAT_REGEN) / 2)
	end
--	if cd >= 70 then
--		cd = 70
--	end
	self:setStorageValue(800201, cd)
	return cd
end

function Creature.setShader(self, shaderName, ticks_seconds)
	if not self then return 0 end
	local conditionOutfit = Condition(CONDITION_OUTFIT)
	conditionOutfit:setTicks(ticks_seconds * 1000)
	local outfit = self:getOutfit()
	conditionOutfit:setOutfit({ lookType = outfit.lookType, lookHead = outfit.lookHead, lookBody = outfit.lookBody,
		lookLegs = outfit.lookLegs, lookFeet = outfit.lookFeet, lookAddons = outfit.lookAddons,
		lookMount = outfit.lookMount, lookWings = outfit.lookWings, lookAura = outfit.lookAura,
		lookHealthBar = outfit.lookHealthBar, lookShader = shaderName })
	self:addCondition(conditionOutfit)
	return true
end

function Creature.setAura(self, auraId, ticks_seconds)
	if not self then return 0 end
	local conditionOutfit = Condition(CONDITION_OUTFIT)
	conditionOutfit:setTicks(ticks_seconds * 1000)
	local outfit = self:getOutfit()
	conditionOutfit:setOutfit({ lookType = outfit.lookType, lookHead = outfit.lookHead, lookBody = outfit.lookBody,
		lookLegs = outfit.lookLegs, lookFeet = outfit.lookFeet, lookAddons = outfit.lookAddons,
		lookMount = outfit.lookMount, lookWings = outfit.lookWings, lookAura = auraId,
		lookHealthBar = outfit.lookHealthBar, lookShader = outfit.lookShader })
	self:addCondition(conditionOutfit)
	return true
end

function Creature.setWings(self, wingsId, ticks_seconds)
	if not self then return 0 end
	local conditionOutfit = Condition(CONDITION_OUTFIT)
	conditionOutfit:setTicks(ticks_seconds * 1000)
	local outfit = self:getOutfit()
	conditionOutfit:setOutfit({ lookType = outfit.lookType, lookHead = outfit.lookHead, lookBody = outfit.lookBody,
		lookLegs = outfit.lookLegs, lookFeet = outfit.lookFeet, lookAddons = outfit.lookAddons,
		lookMount = outfit.lookMount, lookWings = wingsId, lookAura = outfit.lookAura,
		lookHealthBar = outfit.lookHealthBar, lookShader = outfit.lookShader })
	self:addCondition(conditionOutfit)
	return true
end

function Item.calculateSlots(self, rarity)
	local value = rarity
	if rarity >= 3 then
		rarity = 3
	end
	return value
end

function Item.rollRarity(self, player, magicFind)
	local rarity = COMMON
	local itemFindEND = 1
	if not magicFind then magicFind = 0 end
	if self then
	  local raritySpecial = #US_CONFIG.RARITY
	  for i = raritySpecial, 1, -1 do
		local raritySpecialChance = US_CONFIG.RARITY[i].chance
		  raritySpecialChance = raritySpecialChance + ((raritySpecialChance * magicFind) / 100)
		if math.random(1, 100000) <= raritySpecialChance then
		  rarity = i
		  break
		end
	  end
	else
	  for i = raritySpecial, 1, -1 do
		if math.random(1, 100000) <= raritySpecialChance then
		  rarity = i
		  break
		end
	  end
	end
	self:setRarity(rarity)
	self:setModifiersSlots(self:calculateSlots(rarity))
	if player then
	  local eee = itemFindEND / 1000
	  if self:getRarity().name == "Common" then
		player:getPosition():sendMagicEffect(13)
	  end
	  if self:getRarity().name == "Rare" then
		player:getPosition():sendMagicEffect(11)
	  end
	  if self:getRarity().name == "Epic" then
		player:getPosition():sendMagicEffect(5)
	  end
	  if self:getRarity().name == "Legendary" then
		player:getPosition():sendMagicEffect(37)
	  end
	  if self:getRarity().name == "Divine" then
		player:getPosition():sendMagicEffect(50)
		Game.broadcastMessage("Congratulations! " ..player:getName() .. " discovered " .. self:getRarity().name .. " " ..self:getName() .. "! Drop Chance:  " .. eee .. "%   ", MESSAGE_STATUS_WARNING)
		for _, targetPlayer in ipairs(Game.getPlayers()) do
		  targetPlayer:sendExtendedOpcode(71,json.encode({text = "Congratulations {" ..player:getName() .."} discovered {" ..self:getRarity().name .. "} " .. self:getName() .. "! Drop Chance:  " .. eee .. "%   ",color = "#e6cc07"}))
		end
	  end
	end
  end

  function Item.setUnique(self, uniqueId)
	if self:getId() == 0 then return end
	self:setCustomAttribute("unique", uniqueId)
	local unique = US_UNIQUES[uniqueId]
	if unique then
	  for i = 1, #unique.attributes do
		local attrId = unique.attributes[i]
		local attr = US_ENCHANTMENTS[attrId]
		local attr_value = unique.attributes_value[i]
		local value = math.floor(attr_value)
		self:setCustomAttribute("Slot" .. self:getLastSlot() + 1, attrId .. "|" .. value)
	  end
	end
	self:setAttribute(ITEM_ATTRIBUTE_NAME, unique.name)
  end


local ATTRIBUTE_CHANCE_ADD = {
	[1] = 400, -- /10  == 40%
	[2] = 200,
	[3] = 80,
	[4] = 40,
	[5] = 20,
	[6] = 8
}

function Item.rollAttribute(self, magicFind, forceAttributeCount)
	if self:getId() == 0 then return end
	if not self then return end
	if not magicFind then magicFind = 0 end
	local itemLevel = self:getItemLevel()

	local attributeCount = 0
	if forceAttributeCount then
		attributeCount = forceAttributeCount
	else
		for i = 6, 1, -1 do
			local chance = (ATTRIBUTE_CHANCE_ADD[i] + (ATTRIBUTE_CHANCE_ADD[i] * (itemLevel + magicFind) / 100)) * 10
			if math.random(1, 10000) <= chance then
				attributeCount = i
				break
			end
		end
		self:setModifiersSlots(attributeCount)
	end


  for i = 1, attributeCount do
    local attr = self:randomizeAttribute()
    if not attr then
      print("rollAttribute | " .. self:getId() .. " can't find new radmon attribute")
			return false
    end

    local tier = getTierAttribute(self, magicFind/100) -- , multipler
    local value = generateRandomAttributeValue(attr, tier, self)
    self:setAttributeValue(i, attr.."|"..value.."|"..tier)
  end

	self:setCorrectRarity()
	return true
end

  function Item.addImplict(self, slot, attr, value)
	if self:getId() == 0 then return end
	self:setCustomAttribute("Implict" .. slot, attr .. "|" .. value)
  end

	function Item.setImplictValue(self, slot, value)
		if self:getId() == 0 then return end
		if not value then
			self:removeCustomAttribute("Implict"..slot)
			return
		end
	
		self:setCustomAttribute("Implict" .. slot, value)
	end


  function Item.setImplictSlots(self, value)
	if self:getId() == 0 then return end
	self:setCustomAttribute("Implict Slots", value)
  end
  function Item.getImplictSlots(self)
	if self:getId() == 0 then return end
	return self:getCustomAttribute("Implict Slots") or 0
  end
  function Item.getImplictBonusAttribute(self, slot)
	if self:getId() == 0 then return end
	local bonuses = self:getCustomAttribute("Implict" .. slot)
	if bonuses then
	  local data = {}
	  for bonus in bonuses:gmatch("([^|]+)") do
		data[#data + 1] = tonumber(bonus)
	  end
	  return data
	end
	return nil
  end

  function Item.getImplictBonusAttributes(self)
	if self:getId() == 0 then return end
	local data = {}
	local slotss = self:getImplictSlots()
	for i = 1, slotss do
	  local bonuses = self:getCustomAttribute("Implict" .. i)
	  if bonuses then
		local t = {}
		for bonus in bonuses:gmatch("([^|]+)") do
		  t[#t + 1] = tonumber(bonus)
		end
		data[#data + 1] = t
		if not t[4] then
			t[4] = 0
		end
		t[5] = i
	  end
	end
	return #data > 0 and data or nil
  end


function Item.getImplictLastSlot(self)
	if self:getId() == 0 then return end
	local slot = 0
	local bonuses = self:getImplictBonusAttributes()
	if not bonuses then
		return slot
	end

	for i = 1, #bonuses do
		if bonuses[i][5] > slot then
			slot = bonuses[i][5]
		end
	end

	return slot
end

function expFormula(monsterLevel)
	local expF = monsterLevel --  math.ceil(monsterLevel + ((0.0015 * (monsterLevel * 3) ^ 1 + 5 * (monsterLevel * 3) - 4))) -- math.ceil((0.0015 * (monsterLevel * GLOBAL_MULTIPLERS["exp"]) ^ 1 + 5 * (monsterLevel * GLOBAL_MULTIPLERS["exp"]) - 4) * 0.80)
	if monsterLevel >= 1 and monsterLevel <= 10 then -- Goblins
		expF = expF + 1
	elseif monsterLevel >= 11 and monsterLevel <= 20 then -- cyclops
		expF = expF + 3
	elseif monsterLevel >= 12 and monsterLevel <= 30 then -- dragon
		expF = expF + 5
	elseif monsterLevel >= 15 and monsterLevel <= 40 then -- herous
		expF = expF + 7
	elseif monsterLevel >= 19 and monsterLevel <= 50 then	-- demons
		expF = expF + 15
	elseif monsterLevel >= 26 and monsterLevel <= 60 then
		expF = expF + 20
	elseif monsterLevel >= 40 and monsterLevel <= 70 then
		expF = expF + 40
	elseif monsterLevel >= 52 and monsterLevel <= 80 then -- burning i undeady
		expF = expF + 60
	elseif monsterLevel >= 61 and monsterLevel <= 90 then -- do prison
		expF = expF + 80
	elseif monsterLevel >= 70 and monsterLevel <= 95 then -- Undearworlds
		expF = expF + 90
	elseif monsterLevel >= 96 then
		expF = expF + 150
	end
	return expF
end
function goldFormula(monsterLevel)
	local gold = monsterLevel * 0.5 -- math.ceil(0.0015 * monsterLevel ^ GLOBAL_MULTIPLERS["gold"] + GLOBAL_MULTIPLERS["gold"] * monsterLevel - 6)
	if monsterLevel >= 1 and monsterLevel <= 10 then -- Goblins
		gold = gold + 1
	elseif monsterLevel >= 11 and monsterLevel <= 20 then -- cyclops
		gold = gold + 3
	elseif monsterLevel >= 12 and monsterLevel <= 30 then -- dragon
		gold = gold + 5
	elseif monsterLevel >= 15 and monsterLevel <= 40 then -- herous
		gold = gold + 7
	elseif monsterLevel >= 19 and monsterLevel <= 50 then	-- demons
		gold = gold + 10
	elseif monsterLevel >= 26 and monsterLevel <= 60 then
		gold = gold + 15
	elseif monsterLevel >= 40 and monsterLevel <= 70 then
		gold = gold + 20
	elseif monsterLevel >= 52 and monsterLevel <= 80 then -- burning i undeady
		gold = gold + 25
	elseif monsterLevel >= 61 and monsterLevel <= 90 then -- do prison
		gold = gold + 30
	elseif monsterLevel >= 70 and monsterLevel <= 95 then -- Undearworlds
		gold = gold + 40
	elseif monsterLevel >= 96 then
		gold = gold + 50
	end
	return gold
end
function damageFormula(monsterLevel)
	local damage = 20 + (monsterLevel * 2)
	if monsterLevel >= 1 and monsterLevel <= 10 then -- Goblins
		damage = damage + 5
	elseif monsterLevel >= 11 and monsterLevel <= 20 then -- cyclops
		damage = damage + 10
	elseif monsterLevel >= 12 and monsterLevel <= 30 then -- dragon
		damage = damage + 15
	elseif monsterLevel >= 15 and monsterLevel <= 40 then -- herous
		damage = damage + 20
	elseif monsterLevel >= 19 and monsterLevel <= 50 then	-- demons
		damage = damage + 25
	elseif monsterLevel >= 26 and monsterLevel <= 60 then
		damage = damage + 30
	elseif monsterLevel >= 40 and monsterLevel <= 70 then
		damage = damage + 35
	elseif monsterLevel >= 52 and monsterLevel <= 80 then -- burning i undeady
		damage = damage + 40
	elseif monsterLevel >= 61 and monsterLevel <= 90 then -- do prison
		damage = damage + 45
	elseif monsterLevel >= 70 and monsterLevel <= 95 then -- Undearworlds
		damage = damage + 50
	elseif monsterLevel >= 96 then
		damage = damage + 60
	end

	return damage
end

function healthFormula(monsterLevel)
    local health = 100 + (monsterLevel * 5)
	if monsterLevel >= 1 and monsterLevel <= 10 then -- Goblins
		health = health * 1.10
	elseif monsterLevel >= 11 and monsterLevel <= 20 then -- cyclops
		health = health * 1.25
	elseif monsterLevel >= 12 and monsterLevel <= 30 then -- dragon
		health = health * 1.40
	elseif monsterLevel >= 15 and monsterLevel <= 40 then -- herous
		health = health * 1.70
	elseif monsterLevel >= 19 and monsterLevel <= 50 then	-- demons
		health = health * 2.10
	elseif monsterLevel >= 26 and monsterLevel <= 60 then
		health = health * 2.60
	elseif monsterLevel >= 40 and monsterLevel <= 70 then
		health = health * 3.20
	elseif monsterLevel >= 52 and monsterLevel <= 80 then -- burning i undeady
		health = health * 4.00
	elseif monsterLevel >= 61 and monsterLevel <= 90 then -- do prison
		health = health * 5.00
	elseif monsterLevel >= 70 and monsterLevel <= 95 then -- Undearworlds
		health = health * 6.00
	elseif monsterLevel >= 96 then
		health = health * 7.00
	end
    return math.ceil(health)
end

function setLootItem(player, item, tier, monsterLevel, strongBox, magicFind)
	if item:getId() == 0 then return end
	local itemType = ItemType(item.itemid)
	if item:getId() == 0 then return end
	local epic_slots = {
		{5000, 3}, -- 3-6
		{10000, 2}, -- 3-5
		{20000, 1}, -- 3-5
		{100000, 0}, -- 1-2
	}
	if player then
		if item:getType():isArmors() then
			item:rollRarity(player, magicFind)
			if item:getRarityId() == 3 then
				local epicSlotsPlus = 0
				local rand = math.random(100000)
				for i = 1, #epic_slots do
					if rand <= epic_slots[i][1] then
						epicSlotsPlus = epic_slots[i][2]
						break
					end
				end

				item:setModifiersSlots(3 + epicSlotsPlus)
			end
			item:setTier(tier)
			item:setItemLevel(monsterLevel)

			local weaponType = item:getType():getWeaponType()
			local attackFix = 1
			local armorFix = 1
			local defenseFix = 1
			if monsterLevel >= 1 then
				attackFix = 5 + math.ceil(monsterLevel * 0.50)
				armorFix = math.ceil(monsterLevel * 1.1)
				defenseFix = math.ceil(monsterLevel * 3)
			else
				if item:getAttribute(ITEM_ATTRIBUTE_ATTACK) then
					attackFix = item:getAttribute(ITEM_ATTRIBUTE_ATTACK)
				end
			end

			local slot = ItemType(item:getId()):getSlotPosition() -- gives me 2096 on two handed and 48 on onehanded and other items
			if (slot == 1072) and monsterLevel >= 1 then
				attackFix = attackFix * TWO_HANDED_MULTIPLIER
			end
			if item:getCustomAttribute("no_stat") then
				armorFix = 0
				defenseFix = 0
			end
			if attackFix > 1 then
				item:setCustomAttribute("base_attack", attackFix)
			end
			if armorFix > 1 then
				item:setCustomAttribute("base_armor", armorFix)
			end
			--[[
			if formatItemTypeUPGRADE(item:getType()) == "Shield" then
				item:setCustomAttribute("base_defense", attackFix)
			end
			]]
			setAncientItemAttackArmorDefense(player, item, attackFix, armorFix, defenseFix, 1)
			math.randomseed(os.time())
			local skill_chance = 200
			if not item:getCustomAttribute("spellid") then
				math.randomseed(os.time())
				if math.random(100000) <= skill_chance then
					local randomNum = math.random(1, #GLOBAL_SPELL_NUMBER)
					item:setCustomAttribute("spellid", randomNum)
					local slot = ItemType(item:getId()):getSlotPosition()
					if (slot == 1072) then
						item:setCustomAttribute("spelllevel", math.random(2, 10))
					  else
						item:setCustomAttribute("spelllevel", math.random(1, 6))
					end
				end
			else
				math.randomseed(os.time())
				if math.random(100000) <= skill_chance then
					local randomNum = math.random(1, #GLOBAL_SPELL_NUMBER)
					item:setCustomAttribute("spellid", randomNum)
					local slot = ItemType(item:getId()):getSlotPosition()
					if (slot == 1072) then
						item:setCustomAttribute("spelllevel", math.random(2, 10))
					  else
						item:setCustomAttribute("spelllevel", math.random(1, 6))
					end
				else
					item:removeCustomAttribute("spellid")
					item:removeCustomAttribute("spelllevel")
				end
			end
			local rand_quality = math.random(100)
			if rand_quality <= 5 then
				item:setQuality(math.random(8,10))
				if special_potion then
					item:setQuality(math.random(8,10))
				end
			elseif rand_quality <= 20 then
				item:setQuality(math.random(4,7))
				if special_potion then
					item:setQuality(math.random(4,7))
				end
			else
				item:setQuality(math.random(1,3))
				if special_potion then
					item:setQuality(math.random(1,3))
				end
			end
			if item:getRarityId() ~= 4 then
				item:rollAttribute(magicFind)
			end
			player:sendExtendedOpcode(105, json.encode({reload = "reload"}))
		end
	end
	return true
end

function randomSpellRune(player, corpse, rarityRare, rarityMagic, rarityLegendary, lootItems)
	if not player then
		return false
	end
	if not corpse then
		return false
	end
	math.randomseed(os.time())
	local randomitem = math.random(SPELL_RUNES[1], SPELL_RUNES[2])
	local rand = math.random(1, 100000)
	local rarity = COMMON
    if rand <= rarityLegendary then
        rarity = LEGENDARY
    elseif rand <= rarityMagic then
        rarity = EPIC
     elseif rand <= rarityRare then
        rarity = RARE
    elseif rand <= 1000 then
        rarity = COMMON
	else
		rarity = false
    end
	local raritys = {
		[1] = 1,
		[2] = 2,
		[3] = 3,
		[4] = 4
	}
	local size = 1
	size = raritys[rarity]
	if rarity then
		local item = corpse:addItem(randomitem, 1)
		if item then
			item:setRarity(rarity)
			if not item:getCustomAttribute("empower_spellrune") then
				math.randomseed(os.time())
				if math.random(100000) <= 500 then
					item:setCustomAttribute("empower_spellrune", math.random(1, 3))
					local name = item:getName()
					item:setAttribute(ITEM_ATTRIBUTE_NAME, "Enhanced " .. name .. "")
				end
			else
				math.randomseed(os.time())
				if math.random(100000) <= 500 then
					item:setCustomAttribute("empower_spellrune", math.random(1, 3))
					local name = item:getName()
					item:setAttribute(ITEM_ATTRIBUTE_NAME, "Enhanced " .. name .. "")
				else
					item:removeCustomAttribute("empower_spellrune")
				end
			end
			local rand_quality = math.random(100)
			if rand_quality <= 5 then
				item:setQuality(math.random(8,10))
				if special_potion then
					item:setQuality(math.random(8,10))
				end
			elseif rand_quality <= 20 then
				item:setQuality(math.random(4,7))
				if special_potion then
					item:setQuality(math.random(4,7))
				end
			else
				item:setQuality(math.random(1,3))
				if special_potion then
					item:setQuality(math.random(1,3))
				end
			end


			local item_data = {
				item:getCount(),
				item:getType():getClientId(),
				item:getRealUID(),
				item:getRarityId(),
				{},
			}
			table.insert(lootItems, item_data)
		end
	end
	return true
end

function randomSupportRune(player, corpse, rarityRare, rarityMagic, rarityLegendary, lootItems)
	if not player then
		return false
	end
	if not corpse then
		return false
	end
	math.randomseed(os.time())
	local randomitem = math.random(SUPPORT_RUNES[1], SUPPORT_RUNES[2])
	local rand = math.random(1, 100000)
	local rarity = COMMON
    if rand <= rarityLegendary then
        rarity = LEGENDARY
    elseif rand <= rarityMagic then
        rarity = EPIC
     elseif rand <= rarityRare then
        rarity = RARE
    elseif rand <= 1000 then
        rarity = COMMON
	else
		rarity = false
    end
	if rarity then
		local item = corpse:addItem(randomitem, 1)
		if item then
			item:setRarity(rarity)

			local item_data = {
				item:getCount(),
				item:getType():getClientId(),
				item:getRealUID(),
				rarity,
				{},
			}
			table.insert(lootItems, item_data)
		end
	end
	return true
end

function randomPotionLoot(player, corpse, attribute1, attribute2, monsterLevel, lootItems)
	if not player then
		return false
	end
	if not corpse then
		return false
	end
	local tierReward = nil
	local POTION_TIER_LOOT = {
		[1] = { minlevel = 1, maxlevel = 10, tierReward = {7618, 7620, 7623}, tier = 1, monster_tier = 0 },

		[3] = { minlevel = 11, maxlevel = 24, tierReward = {7588, 7589, 7622}, tier = 2, monster_tier = 1 },

		[2] = { minlevel = 25, maxlevel = 39, tierReward = {7590, 7591, 8472}, tier = 3, monster_tier = 2  },

		[4] = { minlevel = 40, maxlevel = 59, tierReward = {8473, 26029, 26030}, tier = 4, monster_tier = 3  },

		[5] = { minlevel = 60, maxlevel = 74, tierReward = {27217, 26031, 7621}, tier = 5, monster_tier = 4  },

		[6] = { minlevel = 75, maxlevel = 1000, tierReward = {36912, 36913, 36916}, tier = 6, monster_tier = 5  },

	}
	local tier = 1
	local level = player:getLevel()
	for i = 1, #POTION_TIER_LOOT do
		if monsterLevel >= POTION_TIER_LOOT[i].minlevel and monsterLevel <= POTION_TIER_LOOT[i].maxlevel then
			tierReward = POTION_TIER_LOOT[i].tierReward[math.random(#POTION_TIER_LOOT[i].tierReward)]
			tier = POTION_TIER_LOOT[i].tier
		end
	end
	math.randomseed(os.time())
	local item = corpse:addItem(tierReward, 1)
	-- Flask Bonuses
	-- first set
	-- 1 = strenght 2 = dexterity 3 = intelligence 4 vitality 
	-- 5 basic damage +40%
	-- 6 critical damage 7 dot damage +25% 8 = counterattack 35%
	-- 9 regen 2% max HP i 2 mana per second
	-- 10 critical chance 5% 11 cast damage +25%
	if item then
		item:setRarity(1)
		item:setTier(tier)
		if math.random(1, 100000) <= attribute1 then
			item:setFlaskBonus(math.random(1, 12))
			item:setRarity(item:getRarityId() + 1)
		end
		if math.random(1, 100000) <= attribute2 then
			item:setFlask(math.random(1, 6))
			item:setRarity(item:getRarityId() + 1)
		end
		local rand_quality = math.random(100)
		if rand_quality <= 5 then
			item:setQuality(math.random(8,10))
			if special_potion then
				item:setQuality(math.random(8,10))
			end
		elseif rand_quality <= 20 then
			item:setQuality(math.random(4,7))
			if special_potion then
				item:setQuality(math.random(4,7))
			end
		else
			item:setQuality(math.random(1,3))
			if special_potion then
				item:setQuality(math.random(1,3))
			end
		end

	local rarirty = item:getRarityId()
	local currentAttr = item:getBonusAttributes()
    local item_data = {
      item:getCount(),
      item:getType():getClientId(),
      item:getRealUID(),
      rarirty,
      currentAttr,
    }
    table.insert(lootItems, item_data)
	end

	return true
end



function currencyDrop(player, corpse, monsterLevel, multipreChance)
	if not player then
		return false
	end
	if not corpse then
		return false
	end
	local lootBonus = 0
	if player:hasBuff(MONSTER_SOUL_LOOT) then
		lootBonus = lootBonus + 10
	end
	if getGlobalBuff(BUFF_GLOBAL_LOOT) then
		lootBonus = lootBonus + 2
	end
	if player:hasBuff(STORE_LOOT_BOOST) then
		lootBonus = lootBonus + 2
	end

	if multipreChance then
		lootBonus = lootBonus + multipreChance
	end

	CURRENCY_DROPS = {
		-- Immposible
		{ 5,  37114, 900 }, -- Orb of Creation 
		{ 5,  37119, 900 }, -- Orb of Despair

		-- High
		{ 100,  37109, 600 }, -- Orb of Spell Enhancement
		{ 100,  8302, 600 }, -- Orb of Spellweaver
		{ 100,  10577, 600 }, -- Mystical Hourglass

		-- Medium
		{ 500,  37112, 400 }, -- Orb of Fortune
		{ 500,  37115, 400 }, -- Orb of Rune Level
		{ 500,  37116, 400 }, -- Orb of Rune Quality
		{ 500,  37117, 400 }, -- Orb of Potion Quality
		-- Low
		{ 1000,  37113, 1 }, -- Orb of Hope
		{ 1000,  18422, 1 }, -- Orb of Chaos
		{ 1000,  8303, 1 }, -- Orb of Refinement
		{ 1000,  37120, 1 }, -- Orb of Discovery
	}

	math.randomseed(os.time())

	for i = 1, #CURRENCY_DROPS do
		if player:getLevel() >= CURRENCY_DROPS[i][3] then
			local rand = math.random(100000)
			if rand <= CURRENCY_DROPS[i][1] then
				corpse:addItem(CURRENCY_DROPS[i][2], 1)
			end
		end
	end

	return true
end

function Player.getAttackPower(self)
	if not self then return 0 end
	local total = 0
	local slots = { CONST_SLOT_RIGHT, CONST_SLOT_LEFT } -- CONST_SLOT_GLOVES
	local item
	for i = 1, #slots do
		item = self:getSlotItem(slots[i])
		if item then
			local attackT = item:hasAttribute(ITEM_ATTRIBUTE_ATTACK) and item:getAttribute(ITEM_ATTRIBUTE_ATTACK) or item:getType():getAttack()
			total = total + attackT
		end
	end
	return total
end



function Player.getVocationSkill(self)
	if not self then return 0 end
	local skillValue = 0
	if self:isSorcerer() or self:isDruid() then
		skillValue = self:getEffectiveSkillLevel(SKILL_FISHING)
	elseif self:isArcher() or self:isShadow() then
		skillValue = self:getEffectiveSkillLevel(SKILL_DISTANCE)
	elseif self:isPaladin() or self:isKnight() then
		skillValue = self:getEffectiveSkillLevel(SKILL_MELEE)
	end
	return skillValue
end

function Player.getVocationSkillBuff(self)
	if not self then return 0 end
	local skillValue = 0
	if self:isSorcerer() or self:isDruid() then
		skillValue = CONDITION_PARAM_SKILL_FISHING
	elseif self:isArcher() or self:isShadow() then
		skillValue = CONDITION_PARAM_SKILL_DISTANCE
	elseif self:isPaladin() or self:isKnight() then
		skillValue = CONDITION_PARAM_SKILL_MELEE
	end
	return skillValue
end

local sorcVociation = { 1, 5, 9, 13 }
function Player.isSorcerer(self)
    local vocation = self:getVocation()
    if not vocation then
        return false
    end

    return isInArray(sorcVociation, vocation:getId())
end

local druidVociation = { 2, 6, 10, 14 }
function Player.isDruid(self)
    local vocation = self:getVocation()
    if not vocation then
        return false
    end

		return isInArray(druidVociation, vocation:getId())
end

local archerVociation = { 3, 7, 11, 15 }
function Player.isArcher(self)
    local vocation = self:getVocation()
    if not vocation then
        return false
    end

		return isInArray(archerVociation, vocation:getId())
end

local knightVociation = { 4, 8, 12, 16 }
function Player.isKnight(self)
    local vocation = self:getVocation()
    if not vocation then
        return false
    end

		return isInArray(knightVociation, vocation:getId())
end

local paladinVociation = { 17, 18, 19, 20 }
function Player.isPaladin(self)
    local vocation = self:getVocation()
    if not vocation then
        return false
    end

		return isInArray(paladinVociation, vocation:getId())
end

local shadowVociation = { 21, 22, 23, 24 }
function Player.isShadow(self)
    local vocation = self:getVocation()
    if not vocation then
        return false
    end

		return isInArray(shadowVociation, vocation:getId())
end


local heavyVociation = { 4, 8, 12, 16, 17, 18, 19, 20 }
function Player.isHeavyVocation(self)
    local vocation = self:getVocation()
    if not vocation then
        return false
    end

		return isInArray(heavyVociation, vocation:getId())
end

local lightVociation = { 3, 7, 11, 15, 21, 22, 23, 24 }
function Player.isLightVocation(self)
    local vocation = self:getVocation()
    if not vocation then
        return false
    end

		return isInArray(lightVociation, vocation:getId())
end

local magicVociation = { 1, 5, 9, 13, 2, 6, 10, 14 }
function Player.isMagicVocation(self)
    local vocation = self:getVocation()
    if not vocation then
        return false
    end

		return isInArray(magicVociation, vocation:getId())
end

local physVociation = { 4, 8, 12, 16, 3, 7, 11, 15, 21, 22, 23, 24 }
function Player.isPhysicalVocation(self)
    local vocation = self:getVocation()
    if not vocation then
        return false
    end

		return isInArray(physVociation, vocation:getId())
end

local eleVociation = { 1, 5, 9, 13, 2, 6, 10, 14, 17, 18, 19, 20 }
function Player.isElementalVocation(self)
    local vocation = self:getVocation()
    if not vocation then
        return false
    end

		return isInArray(eleVociation, vocation:getId())
end

function Player.DamageTypePROC(self)
	if not self then return end
	local damageType = COMBAT_PHYSICAL_PROC_DAMAGE
	if self:isPhysicalVocation() then
		damageType = COMBAT_PHYSICAL_PROC_DAMAGE
	elseif self:isElementalVocation() then
		damageType = COMBAT_ELEMENTAL_PROC_DAMAGE
	end
	return damageType
end

function getExpForLevel(level)
	if level >= 349 then
		return 0
	end
	level = level + 1
	local baseExp = 50
	if level >= 50 then
			baseExp = baseExp + (level - 50)
	end

	local exp = ((baseExp * level^3) / 3 - 100 * level^2 + (850 * level) / 3 - 200) * 2

	if level >= 85 then
			local extraFactor = 1 + (level - 85) * 0.1
			exp = exp * extraFactor
	end
	--[[
	if level >= 120 then
		local power = 1.6 -- im większa, tym szybciej rośnie
		local factor = ((level - 119) ^ power) / (1 ^ power)
		exp = exp * factor
	end
	--]]
	    -- smooth scaling po 120 (bez ściany)
	if level >= 120 then
		local x = level - 120
		local factor = 1 + x * 0.174
		exp = exp * factor
	end

	return math.floor(exp)
end

function Player.setTileWidget(self, pos, id, data, time)
	self:sendExtendedOpcode(
		ExtendedOPCodes.CODE_TILEWIDGET,
		json.encode(
			{
				action = "createwidget",
				data = {
					pos = pos,
					id = id,
					msg = data,
					time = time,
				}
			}
		)
	)
	return true
end

function sendDistanceEffectCircle(pos, distanceEffect)
	if pos then
		pos:sendDistanceEffect(Position(pos.x - 1, pos.y - 1, pos.z), distanceEffect)
		pos:sendDistanceEffect(Position(pos.x + 1, pos.y + 1, pos.z), distanceEffect)
		pos:sendDistanceEffect(Position(pos.x + 1, pos.y, pos.z), distanceEffect)
		pos:sendDistanceEffect(Position(pos.x, pos.y + 1, pos.z), distanceEffect)
		pos:sendDistanceEffect(Position(pos.x - 1, pos.y, pos.z), distanceEffect)
		pos:sendDistanceEffect(Position(pos.x + 1, pos.y - 1, pos.z), distanceEffect)
		pos:sendDistanceEffect(Position(pos.x - 1, pos.y + 1, pos.z), distanceEffect)
		pos:sendDistanceEffect(Position(pos.x, pos.y - 1, pos.z), distanceEffect)
	end
end

function magicEffectPOP(center, effect, rand1, rand2, rand3, rand4)
	for i = rand1, rand2 do
		local top = Position(center.x + i, center.y - rand3, center.z)
		local middle = Position(center.x + i, center.y, center.z)
		local bottom = Position(center.x + i, center.y + rand4, center.z)
		top:sendMagicEffect(effect)
		middle:sendMagicEffect(effect)
		bottom:sendMagicEffect(effect)
	end
end

function RemovePets(cid)
	local summons = getCreatureSummons(cid)
	if #summons > 0 then
		for i, v in ipairs(summons) do
			doRemoveCreature(v)
		end
	end
end

function Player:paragonUP(exp, animated)
	local paragonLevel = self:getStorageValue(PlayerStorage.paragonLevel)
	local expParagon = self:getStorageValue(PlayerStorage.paragonEXP)
	if self:getLevel() >= 1500 then
		if paragonLevel == -1 then
			paragonLevel = 0
		end
		if expParagon < 0 then
			expParagon = 0
		end
		self:setStorageValue(PlayerStorage.paragonEXP, expParagon + ((exp / 30) / 5))
		local level = self:getLevel()
		local expNeed = (getExpForLevel(level + 1 + paragonLevel) - getExpForLevel(level)) / 1000
		local expParagon = self:getStorageValue(PlayerStorage.paragonEXP)
		if expParagon >= expNeed then
			self:setStorageValue(PlayerStorage.paragonLevel, paragonLevel + 1)
			self:setStorageValue(PlayerStorage.paragonEXP, 0)
			self:addStatsPoints(1)
			self:sendExtendedOpcode(71,
				json.encode({
					text = "Congratulations! You've advanced to a {Paragon Level} \nYou have gained a new stat point!",
					color = "#f0ab0a"
				}))
		end
		local paragonLevel = self:getStorageValue(PlayerStorage.paragonLevel)
		local expParagon = self:getStorageValue(PlayerStorage.paragonEXP)
		if paragonLevel == -1 then
			paragonLevel = 0
		end
		if expParagon < 0 then
			expParagon = 0
		end
		local expNeed = (getExpForLevel(level + 1 + paragonLevel) - getExpForLevel(level)) / 1000
		local prec = math.ceil(expParagon / expNeed * 100)
		local paragon = {
			paragonLevel,
			expParagon,
			expNeed,
			prec
		}
		self:sendExtendedOpcode(110, json.encode({ paragon = paragon }))
		setParagonLevel(self, paragonLevel)
		if paragonLevel == 50 then
			self:setStorageValue(PlayerStorage.playerTier, 9)
		elseif paragonLevel == 200 then
			self:setStorageValue(PlayerStorage.playerTier, 10)
		end
		if animated then
			local expP = exp / 10
			Game.sendAnimatedText("PEXP +" .. expP .. "", self:getPosition(), 52)
		end
		return 0
	else
		local paragon = {
			0,
			0,
			0,
			0
		}
		self:sendExtendedOpcode(110, json.encode({ paragon = paragon }))
	end
end

function Player:removeAllOldStats()
	self:removeCondition(CONDITION_ATTRIBUTES, CONDITIONID_COMBAT, 810001)
	self:removeCondition(CONDITION_ATTRIBUTES, CONDITIONID_COMBAT, 810002)
	self:removeCondition(CONDITION_ATTRIBUTES, CONDITIONID_COMBAT, 810003)
	self:removeCondition(CONDITION_ATTRIBUTES, CONDITIONID_COMBAT, 810004)
	self:removeCondition(CONDITION_HASTE, CONDITIONID_COMBAT, 731567)
	self:removeCondition(CONDITION_ATTRIBUTES, CONDITIONID_COMBAT, 731563)
	self:removeCondition(CONDITION_ATTRIBUTES, CONDITIONID_COMBAT, 731565)
	self:removeCondition(CONDITION_ATTRIBUTES, CONDITIONID_COMBAT, 731564)
	self:removeCondition(CONDITION_ATTRIBUTES, CONDITIONID_COMBAT, 731569)
	self:removeCondition(CONDITION_ATTRIBUTES, CONDITIONID_COMBAT, 731566)
	self:removeCondition(CONDITION_REGENERATION, CONDITIONID_COMBAT, 731556)
	self:removeCondition(CONDITION_ATTRIBUTES, CONDITIONID_COMBAT, 731570)
	self:removeCondition(CONDITION_ATTRIBUTES, CONDITIONID_COMBAT, 731554)
	self:removeCondition(CONDITION_ATTRIBUTES, CONDITIONID_COMBAT, 731555)
	self:removeCondition(CONDITION_ATTRIBUTES, CONDITIONID_COMBAT, 423554)
	self:removeCondition(CONDITION_ATTRIBUTES, CONDITIONID_COMBAT, 731560)
	self:removeCondition(CONDITION_ATTRIBUTES, CONDITIONID_COMBAT, 731568)
	self:removeCondition(CONDITION_ATTRIBUTES, CONDITIONID_COMBAT, 731557)
	self:removeCondition(CONDITION_ATTRIBUTES, CONDITIONID_COMBAT, 731562)
	self:removeCondition(CONDITION_ATTRIBUTES, CONDITIONID_COMBAT, 731561)
	self:removeCondition(CONDITION_ATTRIBUTES, CONDITIONID_COMBAT, 731559)
	self:removeCondition(CONDITION_ATTRIBUTES, CONDITIONID_COMBAT, 731571)
	self:removeCondition(CONDITION_ATTRIBUTES, CONDITIONID_COMBAT, 812002)
	self:removeEnergyShieldGainForce(1)
end

function Player.setStatistics(self)
	if not self then return end
	self:removeAllOldStats()
	local healthPlus = 0
	local healthPlusLevel = 0
	local manaPlus = 0
	local manaPlusLevel = 0
	local Healthadded = 0
	local Manaadded = 0
	local energyShieldadded = 0
	local influHRegen = 0
	local allAttributes = 0
	local CriticalChance = 0
	local CriticalDamage = 0
	local influShielding = 0
	local melee_skill = 0
	local magic_skill = 0
	local distance_skill = 0
	local shield_skill = 0
	local mana = 0
	local movementSpeed = 0
	local manaPlusPercent = 0
	local healthRegen = 0
	local manaRegen = 0
	local healthRegenPercent = 0
	local energyShieldPercentRegen = 0
	local manaRegenPercent = 0
	local energyShieldPercent = 0
	local healthPercent = 0
	local manaPercent = 0
	local energyshieldregen = 1
	-- bazowa regeneracja
	local base_healthRegen = 1
	local base_manaRegen = 1




	self:addHealthGain(1, base_healthRegen, true)
	self:addManaGain(1, base_manaRegen, true)
	if colleftInfo[self:getId()].attributesItems[4] then -- health regeneration
		healthRegen = healthRegen + colleftInfo[self:getId()].attributesItems[4].value
	end
	if colleftInfo[self:getId()].attributesItems[5] then -- mana regeneration
		manaRegen = manaRegen + colleftInfo[self:getId()].attributesItems[5].value
	end
	if colleftInfo[self:getId()].attributesItems[20] then -- Energy Shield Regeneration
		energyshieldregen = energyshieldregen + colleftInfo[self:getId()].attributesItems[20].value
	end
	if colleftInfo[self:getId()].attributesItems[33] then -- Warmog's Heart: Regenerate 3% Max Health every second
		local regenPct = colleftInfo[self:getId()].attributesItems[33].value or 3
		healthRegen = healthRegen + math.ceil(self:getMaxHealth() * (regenPct / 100))
	end
	local movementSpeedFlat = 0
	if colleftInfo[self:getId()].attributesItems[10] then
		movementSpeed = movementSpeed + colleftInfo[self:getId()].attributesItems[10].value
	end
	if colleftInfo[self:getId()].attributesItems[21] then
		movementSpeedFlat = movementSpeedFlat + colleftInfo[self:getId()].attributesItems[21].value
	end

	self:addHealthGain(2, healthRegen, true)
	self:addManaGain(2, manaRegen, true)
	self:addHealthPrecentGain(1, healthRegenPercent, true)
	self:addManaPrecentGain(1, manaRegenPercent, true)
	self:addEnergyShieldPrecentGainForce(1, energyShieldPercentRegen, true)

	if manaPercent > 0 or manaPercent < 0 then
		local conditionES = Condition(CONDITION_ATTRIBUTES)
		conditionES:setParameter(CONDITION_PARAM_SUBID, 810004)
		conditionES:setParameter(CONDITION_PARAM_TICKS, -1)
		conditionES:setParameter(CONDITION_PARAM_STAT_MAXMANAPOINTSPERCENT, manaPercent)
		self:addCondition(conditionES)
	end

	self:addHealthGain(5, 0, true)

	if energyshieldregen > 0 then
		self:addEnergyShieldGainForce(1, energyshieldregen, true)
	end

	if movementSpeed ~= 0 or movementSpeedFlat ~= 0 then
		local movementSpeedCondition = Condition(CONDITION_HASTE)
		local hasteAdded = (self:getBaseSpeed() * movementSpeed / 100) + movementSpeedFlat
		movementSpeedCondition:setParameter(CONDITION_PARAM_TICKS, -1)
		movementSpeedCondition:setParameter(CONDITION_PARAM_SUBID, 731567)
		movementSpeedCondition:setFormula(0.0, hasteAdded, 0.0, hasteAdded)
		self:addCondition(movementSpeedCondition)
	end

	if melee_skill > 0 then
		local infSkills = Condition(CONDITION_ATTRIBUTES)
		infSkills:setParameter(CONDITION_PARAM_TICKS, -1)
		infSkills:setParameter(CONDITION_PARAM_SKILL_MELEE, melee_skill)
		infSkills:setParameter(CONDITION_PARAM_SUBID, 731563)
		self:addCondition(infSkills)
	end

	if magic_skill > 0 then
		local infSkills = Condition(CONDITION_ATTRIBUTES)
		infSkills:setParameter(CONDITION_PARAM_TICKS, -1)
		infSkills:setParameter(CONDITION_PARAM_SKILL_FISHING, magic_skill)
		infSkills:setParameter(CONDITION_PARAM_SUBID, 731564)
		self:addCondition(infSkills)
	end

	if distance_skill > 0 then
		local infSkills = Condition(CONDITION_ATTRIBUTES)
		infSkills:setParameter(CONDITION_PARAM_TICKS, -1)
		infSkills:setParameter(CONDITION_PARAM_SKILL_DISTANCE, distance_skill)
		infSkills:setParameter(CONDITION_PARAM_SUBID, 731565)
		self:addCondition(infSkills)
	end

	if shield_skill > 0 then
		local infSkills = Condition(CONDITION_ATTRIBUTES)
		infSkills:setParameter(CONDITION_PARAM_TICKS, -1)
		infSkills:setParameter(CONDITION_PARAM_SKILL_SHIELD, shield_skill)
		infSkills:setParameter(CONDITION_PARAM_SUBID, 731569)
		self:addCondition(infSkills)
	end

	if mana > 0 then
		local maxMPInflu = Condition(CONDITION_ATTRIBUTES)
		maxMPInflu:setParameter(CONDITION_PARAM_TICKS, -1)
		maxMPInflu:setParameter(CONDITION_PARAM_STAT_MAXMANAPOINTS, mana)
		maxMPInflu:setParameter(CONDITION_PARAM_SUBID, 731566)
		self:addCondition(maxMPInflu)
	end

	local vocation = self:getVocation()
	local level = self:getLevel()
	if influHRegen > 0 then
		local regen_HP = (self:getMaxHealth() * influHRegen) / 100
		local regen_MP = (self:getMaxMana() * influHRegen) / 100
		local influRegen = Condition(CONDITION_REGENERATION)
		influRegen:setParameter(CONDITION_PARAM_HEALTHGAIN, regen_HP)
		influRegen:setParameter(CONDITION_PARAM_HEALTHTICKS, 1000)
		influRegen:setParameter(CONDITION_PARAM_MANAGAIN, regen_MP)
		influRegen:setParameter(CONDITION_PARAM_MANATICKS, 1000)
		influRegen:setParameter(CONDITION_PARAM_TICKS, -1)
		influRegen:setParameter(CONDITION_PARAM_SUBID, 731556)
		self:addCondition(influRegen)
	end

	if healthPlus > 0 then
		local baseHP = 200 + (vocation:getHealthGain() * level)
		local healthAdd = baseHP * (healthPlus + healthPlusLevel) / 100
		local maxHPSoulShard = Condition(CONDITION_ATTRIBUTES)
		maxHPSoulShard:setParameter(CONDITION_PARAM_TICKS, -1)
		maxHPSoulShard:setParameter(CONDITION_PARAM_STAT_MAXHITPOINTS, healthAdd)
		maxHPSoulShard:setParameter(CONDITION_PARAM_SUBID, 423554)
		self:addCondition(maxHPSoulShard)
	end

	if manaPlus > 0 then
		local baseHP = 200 + (vocation:getManaGain() * level)
		local healthAdd = manaPlus + manaPlusLevel -- baseHP * (manaPlus + manaPlusLevel) / 100
		local maxHPSoulShard = Condition(CONDITION_ATTRIBUTES)
		maxHPSoulShard:setParameter(CONDITION_PARAM_TICKS, -1)
		maxHPSoulShard:setParameter(CONDITION_PARAM_STAT_MAXMANAPOINTS, healthAdd)
		maxHPSoulShard:setParameter(CONDITION_PARAM_SUBID, 731560)
		self:addCondition(maxHPSoulShard)
	end

	if manaPlusPercent > 0 then
		local baseMana = 100 + (vocation:getManaGain() * level)
		local manaAdd = baseMana * manaPlusPercent / 100
		local maxHPSoulShard = Condition(CONDITION_ATTRIBUTES)
		maxHPSoulShard:setParameter(CONDITION_PARAM_TICKS, -1)
		maxHPSoulShard:setParameter(CONDITION_PARAM_STAT_MAXMANAPOINTS, manaAdd)
		maxHPSoulShard:setParameter(CONDITION_PARAM_SUBID, 731568)
		self:addCondition(maxHPSoulShard)
	end

	if allAttributes > 0 then
		local infSkills = Condition(CONDITION_ATTRIBUTES)
		infSkills:setParameter(CONDITION_PARAM_TICKS, -1)
		infSkills:setParameter(CONDITION_PARAM_SKILL_SHIELD, allAttributes)
		infSkills:setParameter(CONDITION_PARAM_SKILL_FISHING, allAttributes)
		infSkills:setParameter(CONDITION_PARAM_SKILL_DISTANCE, allAttributes)
		infSkills:setParameter(CONDITION_PARAM_SKILL_MELEE, allAttributes)
		infSkills:setParameter(CONDITION_PARAM_STAT_MAGICPOINTS, allAttributes)
		infSkills:setParameter(CONDITION_PARAM_SUBID, 731557)
		self:addCondition(infSkills)
	end

	if influShielding > 0 then
		local skillAdd = influShielding
		local influShieldingAdd = Condition(CONDITION_ATTRIBUTES)
		influShieldingAdd:setParameter(CONDITION_PARAM_TICKS, -1)
		influShieldingAdd:setParameter(CONDITION_PARAM_SKILL_SHIELD, skillAdd)
		influShieldingAdd:setParameter(CONDITION_PARAM_SUBID, 731562)
		self:addCondition(influShieldingAdd)
	end

	if CriticalChance > 0 then
		local CriticalChanceAdd = Condition(CONDITION_ATTRIBUTES)
		CriticalChanceAdd:setParameter(CONDITION_PARAM_TICKS, -1)
		CriticalChanceAdd:setParameter(CONDITION_PARAM_SPECIALSKILL_CRITICALHITCHANCE, CriticalChance)
		CriticalChanceAdd:setParameter(CONDITION_PARAM_SUBID, 731561)
		self:addCondition(CriticalChanceAdd)
	end

	if CriticalDamage > 0 then
		local CriticalDamageAdd = Condition(CONDITION_ATTRIBUTES)
		CriticalDamageAdd:setParameter(CONDITION_PARAM_TICKS, -1)
		CriticalDamageAdd:setParameter(CONDITION_PARAM_SPECIALSKILL_CRITICALHITAMOUNT, CriticalDamage)
		CriticalDamageAdd:setParameter(CONDITION_PARAM_SUBID, 731559)
		self:addCondition(CriticalDamageAdd)
	end


	if Manaadded > 0 then
		local maxMP = Condition(CONDITION_ATTRIBUTES)
		maxMP:setParameter(CONDITION_PARAM_TICKS, -1)
		maxMP:setParameter(CONDITION_PARAM_STAT_MAXMANAPOINTS, Manaadded)
		maxMP:setParameter(CONDITION_PARAM_SUBID, 731555)
		self:addCondition(maxMP)
	end

	if Healthadded > 0 then
		local maxHP = Condition(CONDITION_ATTRIBUTES)
		maxHP:setParameter(CONDITION_PARAM_TICKS, -1)
		maxHP:setParameter(CONDITION_PARAM_STAT_MAXHITPOINTS, Healthadded)
		maxHP:setParameter(CONDITION_PARAM_SUBID, 731554)
		self:addCondition(maxHP)
	end
	if energyShieldadded > 0 then
		local maxES = Condition(CONDITION_ATTRIBUTES)
		maxES:setParameter(CONDITION_PARAM_TICKS, -1)
		maxES:setParameter(CONDITION_PARAM_STAT_MAXENERGYSHIELD, energyShieldadded)
		maxES:setParameter(CONDITION_PARAM_SUBID, 731570)
		self:addCondition(maxES)
	end
	if healthPercent > 0 or healthPercent < 0 then
		local conditionES = Condition(CONDITION_ATTRIBUTES)
		conditionES:setParameter(CONDITION_PARAM_SUBID, 810003)
		conditionES:setParameter(CONDITION_PARAM_TICKS, -1)
		conditionES:setParameter(CONDITION_PARAM_STAT_MAXHITPOINTSPERCENT, healthPercent)
		self:addCondition(conditionES)
	end

	if energyShieldPercent > 0 then
		local conditionES = Condition(CONDITION_ATTRIBUTES)
		conditionES:setParameter(CONDITION_PARAM_SUBID, 812002)
		conditionES:setParameter(CONDITION_PARAM_STAT_MAXENERGYSHIELDPERCENT, energyShieldPercent)
		conditionES:setParameter(CONDITION_PARAM_TICKS, -1)
		conditionES:setParameter(CONDITION_PARAM_BUFF_SPELL, false)
		self:addCondition(conditionES)
	end
end

function canAttackPosition(pos_a, pos_b)
	local tile = Tile(pos_b)
	return (tile == nil
	or tile:getGround() == nil
	or tile:hasProperty(TILESTATE_NONE)
	or tile:hasProperty(TILESTATE_FLOORCHANGE_EAST)
	or tile:hasFlag(TILESTATE_FLOORCHANGE)
	or tile:hasFlag(TILESTATE_HOUSE)
	or tile:hasFlag(TILESTATE_BLOCKSOLID)
	or isItem(tile:getThing()) and not isMoveable(tile:getThing())
	or not tile:isWalkable()
	or tile:hasFlag(TILESTATE_PROTECTIONZONE)
  )
  end

  function createPath(pos_a, pos_b, steps)
	local distance = getDistanceBetween(pos_a, pos_b)
	if distance == 0 then
		return {pos_a}
	end
	local path = {}
	for i = 1, steps do
		local new_pos = {x = pos_a.x + math.floor((pos_b.x - pos_a.x) * (i/distance) + 0.5),
		y = pos_a.y + math.floor((pos_b.y - pos_a.y) * (i/distance) + 0.5),
		z = pos_a.z}
		table.insert(path, new_pos)
	end
	return path
end

function canAttackTarget(pos_a, pos_b)
	return Tile(pos_b) and pos_a:isSightClear(pos_b, true) and not Tile(pos_b):hasFlag(TILESTATE_PROTECTIONZONE)
  end

local t1mobs = { 2516, 2187, 2645, 2503, 2504, 8851, 2451, 2432, 7425, 2502, 8857, 2403, 36725, 36726, 36727,
  36728, 36729 }
local t2mobs = { 8912, 2438, 7432, 2447, 18454, 21690, 2539, 11303, 11304, 11301, 11302, 2379, 36725, 36726,
  36727, 36728, 36729 }
local t3mobs = { 2392, 2421, 7434, 8852, 8855, 2519, 2191, 2195, 2491, 2487, 2488, 2402, 36725, 36726, 36727,
  36728, 36729 }
local t4mobs = { 8910, 5741, 24742, 2477, 8889, 7382, 8927, 7388, 8854, 8850, 6433, 2385, 36725, 36726, 36727,
  36728, 36729 }
local t5mobs = { 8920, 2471, 2466, 2470, 2646, 12644, 18453, 7438, 3962, 2444, 8930, 2376, 36725, 36726, 36727,
  36728, 36729 }
local t6mobs = { 8921, 7423, 8931, 8925, 22416, 22419, 2520, 9933, 2495, 2494, 2493, 2411, 36725, 36726, 36727,
  36728, 36729 }
local t7mobs = { 36134, 25429, 9777, 9776, 9778, 22403, 22412, 22409, 22420, 22417, 6391, 2405, 36725, 36726,
  36727, 36728, 36729 }
local t8mobs = { 36137, 36136, 36111, 36110, 36109, 36138, 36112, 36108, 36107, 36106, 36105, 2418, 36725, 36726,
  36727, 36728, 36729 }


function Player:updateInspect()
	self:sendExtendedOpcode(ExtendedOPCodes.CODE_INSPECT, json.encode({reload = true}))
end

function generateBossUniqueItem(player, uniqueId, itemLvl, itemsTable)
	local itemLvl = itemLvl and tonumber(itemLvl) or 1
	local uniqueItem = BOSS_UNIQUES[uniqueId]
	if uniqueItem then
		local item = Game.createItem(uniqueItem.itemId, 1)
		if not item then
			return
		end
		local implictsSlots = #uniqueItem.implicit
		item:setImplictSlots(implictsSlots)
		item:setAttribute(ITEM_ATTRIBUTE_NAME, uniqueItem.name)
		for x = 1, implictsSlots do
			local value = math.random(uniqueItem.implicit[x].min, uniqueItem.implicit[x].max)
			item:setImplictValue(x, uniqueItem.implicit[x].id.."|".. value .."|".. 0)
		end

		for x = 1, #uniqueItem.attr do
			local value = math.random(uniqueItem.attr[x].min, uniqueItem.attr[x].max)
			item:setAttributeValue(x, uniqueItem.attr[x].id.."|".. value.."|".. 0)
		end
		
		if uniqueItem.spellId and uniqueItem.spellLevel then
			item:setCustomAttribute("spellid", uniqueItem.spellId)
			item:setCustomAttribute("spelllevel", uniqueItem.spellLevel)
		end
		if uniqueItem.attack then
			item:setAttribute(ITEM_ATTRIBUTE_ATTACK, uniqueItem.attack)
		end
		if uniqueItem.armor then
			item:setAttribute(ITEM_ATTRIBUTE_ARMOR, uniqueItem.armor)
		end
		if uniqueItem.defense then
			item:setAttribute(ITEM_ATTRIBUTE_DEFENSE, uniqueItem.defense)
		end
		local rand_quality = math.random(100)
		if rand_quality <= 5 then
			item:setQuality(math.random(8,10))
			if special_potion then
				item:setQuality(math.random(8,10))
			end
		elseif rand_quality <= 20 then
			item:setQuality(math.random(4,7))
			if special_potion then
				item:setQuality(math.random(4,7))
			end
		else
			item:setQuality(math.random(1,3))
			if special_potion then
				item:setQuality(math.random(1,3))
			end
		end
		item:setCustomAttribute("unique", uniqueId)
		item:setRarity(4)
		item:setItemLevel(itemLvl)

		return item
	end

	return nil
end

function generateUniqueItem(player, uniqueId, dropLevel, itemsTable)
	local uniqueItem = US_UNIQUES[uniqueId]
	if uniqueItem then
		local item = Game.createItem(uniqueItem.itemId, 1)
		if not item then
			return
		end
		if uniqueItem.implicit then
			local implictsSlots = #uniqueItem.implicit
			item:setImplictSlots(implictsSlots)
			for x = 1, implictsSlots do
				local value = math.random(uniqueItem.implicit[x].min, uniqueItem.implicit[x].max)
				item:setImplictValue(x, uniqueItem.implicit[x].id.."|".. value .."|".. 0)
			end
		end
	
		if uniqueItem.name then
			item:setAttribute(ITEM_ATTRIBUTE_NAME, uniqueItem.name)
		end
		
		item:setCustomAttribute("checksum", ITEM_CHECKSUM)

		if uniqueItem.attr then
			for x = 1, #uniqueItem.attr do
				local value = math.random(uniqueItem.attr[x].min, uniqueItem.attr[x].max)
				item:setAttributeValue(x, uniqueItem.attr[x].id.."|".. value.."|".. 0)
			end
		end
		
		if uniqueItem.spellId and uniqueItem.spellLevel then
			item:setCustomAttribute("spellid", uniqueItem.spellId)
			item:setCustomAttribute("spelllevel", math.random(uniqueItem.spellLevel[1], uniqueItem.spellLevel[2]))
		end
		if uniqueItem.attack then
			item:setAttribute(ITEM_ATTRIBUTE_ATTACK, uniqueItem.attack)
		end
		if uniqueItem.armor then
			item:setAttribute(ITEM_ATTRIBUTE_ARMOR, uniqueItem.armor)
		end
		if uniqueItem.defense then
			item:setAttribute(ITEM_ATTRIBUTE_DEFENSE, uniqueItem.defense)
		end
		local rand_quality = math.random(100)
		if rand_quality <= 5 then
			item:setQuality(math.random(8,10))
			if special_potion then
				item:setQuality(math.random(8,10))
			end
		elseif rand_quality <= 20 then
			item:setQuality(math.random(4,7))
			if special_potion then
				item:setQuality(math.random(4,7))
			end
		else
			item:setQuality(math.random(1,3))
			if special_potion then
				item:setQuality(math.random(1,3))
			end
		end
        if uniqueItem.crystalSlots then
          item:setCrystalSlots(uniqueItem.crystalSlots)
        end
		if uniqueItem.mirrored then
			item:setMirrored(1)
		end
		if not uniqueItem.fakeUnique then
			item:setCustomAttribute("unique", uniqueId)
		end
		item:setRarity(5)

		local itemLevel = uniqueItem.monsterLevel
		if dropLevel then
			if itemLevel > dropLevel then
				itemLevel = dropLevel
			end
		end

		if not uniqueItem.noItemLevel then
			item:setItemLevel(itemLevel)
		end
		if uniqueItem.spellUnique then
            item:setCustomAttribute("spellUnique", true)
			item:setCustomAttribute("spellUniqueId", uniqueItem.spellUniqueID)
        end
		return item
	end

	return nil
end

function generateBaseItem(player, strongBox, base, monsterLevel, magicFind)
	local item = Game.createItem(base[2], 1)
	if not item then
		print("Error: generateBaseItem - item not created id: " .. base[2])
		return nil
	end

	if not magicFind then magicFind = 0 end
	local implictsSlots = #base[3]
	item:setImplictSlots(implictsSlots)
	local rarity = base[4] or 0
	if type(rarity) == "string" then
		local rName = rarity:lower()
		if rName == "magic" or rName == "common" then
			rarity = 1
		elseif rName == "rare" or rName == "epic" then
			rarity = 3
		elseif rName == "legendary" then
			rarity = 4
		elseif rName == "unique" then
			rarity = 5
		elseif rName == "exalted" then
			rarity = 6
		else
			rarity = 0
		end
	end

	--setLootItem(player, item, 0, monsterLevel, strongBox, magicFind)
	item:setRarity(rarity)
	item:setAttribute(ITEM_ATTRIBUTE_NAME, base[1])
	item:setCustomAttribute("checksum", ITEM_CHECKSUM)

	item:addRandomCrystalSlots(monsterLevel, magicFind)
	for x = 1, implictsSlots do
		local impId = base[3][x][1]
		local value = base[3][x][2]
		item:setImplictValue(x, impId .. "|" .. value .. "|" .. (monsterLevel + 1))
	end

	return item
end

function formatItemType(itemType, item)
  local weaponType = itemType:getWeaponType()
  local slotPosition = itemType:getSlotPosition() - SLOTP_LEFT - SLOTP_RIGHT

  if CRAFT_ITEMS and CRAFT_ITEMS[itemType:getId()] then
    return 22
  end

  if weaponType == WEAPON_SHIELD then
    return 16
  elseif slotPosition == 1024 and (weaponType == WEAPON_SWORD or weaponType == WEAPON_CLUB or weaponType == WEAPON_AXE) then
    return 1
	elseif weaponType == WEAPON_SWORD or weaponType == WEAPON_CLUB or weaponType == WEAPON_AXE then
    return 2
  elseif slotPosition == 1024 and (itemType:getName():find("Bow") or itemType:getName():find("Crossbow")) and weaponType == WEAPON_DISTANCE then
    return 3
	elseif (itemType:getName():find("Bow") or itemType:getName():find("Crossbow")) and weaponType == WEAPON_DISTANCE then
    return 4
  elseif itemType:getName():find("knife") and weaponType == WEAPON_DISTANCE then
    return 5
  elseif slotPosition == 1024 and weaponType == WEAPON_WAND then
    return 6
	elseif weaponType == WEAPON_DISTANCE then
    return 7
  elseif weaponType == WEAPON_WAND then
    return 8
  elseif slotPosition == SLOTP_HEAD then
    return 9
  elseif slotPosition == SLOTP_NECKLACE then
    return 10
  elseif slotPosition == SLOTP_ARMOR then
    return 11
  elseif slotPosition == SLOTP_LEGS then
    return 12
  elseif slotPosition == SLOTP_FEET then
    return 13
  elseif slotPosition == SLOTP_RING or slotPosition == SLOTP_RING2  then
    return 14
  elseif slotPosition == SLOTP_GLOVES then
    return 15
	-- 16 shield
	elseif slotPosition == SLOTP_POTION1 then
    return 17
	elseif slotPosition == SLOTP_SPELL1 then
    return 18
  elseif slotPosition == SLOTP_SUPPORT1_1 then
    return 19
  elseif itemType:isContainer() then
    return 20
  elseif itemType:getType() == 9 then
		return 23
  elseif itemType:isUseable() then
    return 21
	elseif itemType:getColor() == 8 then
		return 24
	elseif item and item:getLootIndex() == 5 then
		return 25
	elseif item and item:getLootIndex() == 4 then
		return 27
	elseif item and item:getLootIndex() == 3 then
		return 28
  end

  return 0
end

function format_ms(ms)
	local ms_in_second = 1000
	local ms_in_minute = ms_in_second * 60
	local ms_in_hour = ms_in_minute * 60
	local ms_in_day = ms_in_hour * 24
	local ms_in_month = ms_in_day * 30
	local ms_in_year = ms_in_month * 12

	local years = math.floor(ms / ms_in_year)
	ms = ms % ms_in_year
	local months = math.floor(ms / ms_in_month)
	ms = ms % ms_in_month
	local days = math.floor(ms / ms_in_day)
	ms = ms % ms_in_day
	local hours = math.floor(ms / ms_in_hour)
	ms = ms % ms_in_hour
	local minutes = math.floor(ms / ms_in_minute)
	ms = ms % ms_in_minute
	local seconds = math.floor(ms / ms_in_second)

	local result = {}

	if years > 0 then table.insert(result, years .. " year" .. (years > 1 and "s" or "")) end
	if months > 0 then table.insert(result, months .. " month" .. (months > 1 and "s" or "")) end
	if days > 0 then table.insert(result, days .. " day" .. (days > 1 and "s" or "")) end
	if hours > 0 then table.insert(result, hours .. " hour" .. (hours > 1 and "s" or "")) end
	if minutes > 0 then table.insert(result, minutes .. " minute" .. (minutes > 1 and "s" or "")) end
	if seconds > 0 then table.insert(result, seconds .. " second" .. (seconds > 1 and "s" or "")) end

	return table.concat(result, ", ")
end

function Creature:getClientOutfit()
	local outfit = self:getOutfit()
	return {
		type = outfit.lookType ~= 0 and outfit.lookType or nil,
		typeEx = outfit.lookTypeEx ~= 0 and outfit.lookTypeEx or nil,
		head = outfit.lookHead ~= 0 and outfit.lookHead or nil,
		body = outfit.lookBody ~= 0 and outfit.lookBody or nil,
		legs = outfit.lookLegs ~= 0 and outfit.lookLegs or nil,
		feet = outfit.lookFeet ~= 0 and outfit.lookFeet or nil,
		addons = outfit.lookAddons ~= 0 and outfit.lookAddons or nil
	}
end


local tierCostMultiplayer = {
	[0] = 0,
	[1] = 1,
	[2] = 2,
	[3] = 3,
	[4] = 4,
	[5] = 7,
	[6] = 11,
	[7] = 15,
}

--[[
function calculateGoldCost(itemLevel, upgradeLevel)
  local baseCost = 125000
  local itemExponent = 1.8
  local upgradeScale = 0.2
  local upgradeExponent = 2.0

  local itemFactor = (itemLevel / 100) ^ itemExponent
  local upgradeFactor = (1 + upgradeScale * (upgradeLevel - 1)) ^ upgradeExponent

  local cost = baseCost * itemFactor * upgradeFactor
  return math.floor(cost)
end
--]]

function calculateGoldCost(itemLevel, upgradeLevel)
  local ml = (itemLevel or 1) + 10
  local goldPerKill = goldFormula(ml)

  local killsTarget =
    upgradeLevel <= 5 and (20 + upgradeLevel * 15)
    or upgradeLevel <= 10 and (80 + (upgradeLevel - 5) * 100)
    or (1250 + (upgradeLevel - 10) ^ 3 * 2550)

  return math.floor(goldPerKill * killsTarget)
end

function Item:calculateItemCost()
	local iType = getItemType(self)
	local cost = 0
	local goldMultiplier = 0
	if iType == TYPE_DEFUALT then
		local extraGold = 0
		local upgradeLevel = self:getUpgradeLevel()
		if upgradeLevel and upgradeLevel > 0 then
			extraGold = math.floor(calculateGoldCost(self:getItemLevel() or 1, upgradeLevel))
		end
		local currentAttr = self:getBonusAttributes()
		if currentAttr then
			for i = 1, #currentAttr do
				if currentAttr[i] and #currentAttr[i] > 0 then
					goldMultiplier = goldMultiplier + tierCostMultiplayer[currentAttr[i][3]]
				end
			end
		end
		cost = math.ceil(self:getItemLevel() * ((goldMultiplier * 2) + 1.0)) + extraGold
	elseif iType == TYPE_UNIQUE then
		-- can't sell unique
	elseif iType == TYPE_KEY then
		local goldMultiplier = 0
		local currentAttr = self:getDungeonModifiers()
		if currentAttr then
			for i = 1, #currentAttr do
				if currentAttr[i] and #currentAttr[i] > 0 then
					goldMultiplier = goldMultiplier + tierCostMultiplayer[currentAttr[i][3]]
				end
			end
		end
		cost = math.ceil(self:getItemLevel() * (goldMultiplier + 1.0))
	elseif iType == TYPE_SPELL then
		local minLevel, minPrice = 1, 50
		local maxLevel, maxPrice = 200, 100000
		local level = self:getCustomAttribute("level") or 1
		local exponent = math.log(maxPrice / minPrice) / math.log(maxLevel / minLevel)
		cost = math.ceil((minPrice * (level / minLevel) ^ exponent) / 10)
	elseif iType == TYPE_CRYSTAL then
		local rarity = self:getRarityId() or 0
		local costbyRarity = {5000, 10000, 15000, 50000}
		cost = 1000 + costbyRarity[rarity]
	elseif iType == TYPE_RELICT then
		local currentAttr = self:getBonusAttributes()
		if currentAttr then
			for i = 1, #currentAttr do
				if currentAttr[i] and #currentAttr[i] > 0 then
					goldMultiplier = goldMultiplier + tierCostMultiplayer[currentAttr[i][3]]
				end
			end
		end
		local rarity = self:getRarityId() or 0
		cost = math.ceil((rarity * 50) * ((goldMultiplier * 2) + 1.0))
	end

	return cost
end