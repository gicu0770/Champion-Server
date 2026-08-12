local mType = Game.createMonsterType("Blood Fury")

local blood_fury = {}
blood_fury.description = "Blood Fury"
blood_fury.experience = 2000
blood_fury.outfit = {
	lookType = 2736,
    lookHealthBar = 3
}

blood_fury.health = 20000000000
blood_fury.maxHealth = 20000000000
blood_fury.race = "boss"
blood_fury.corpse = 27196
blood_fury.speed = 350
blood_fury.monsterLevel = 900
blood_fury.skull = 0
blood_fury.tier = 71
blood_fury.tierDungeon = 71
blood_fury.items = "dungeonboss"
blood_fury.bestiary = 143

blood_fury.changeTarget = {
	interval = 4 * 1000,
	chance = 100
}

blood_fury.flags = {
	summonable = false,
	attackable = true,
	hostile = true,
	convinceable = false,
	illusionable = false,
	pushable = false,
	canPushItems = true,
	canPushCreatures = true,
	unique = true,
	targetDistance = 1,
	staticAttackChance = 70
}

blood_fury.attacks = {
	{
		name = "combat",
		type = COMBAT_PHYSICALDAMAGE,
		minDamage = -200,
		maxDamage = -200,
		range = 6,
		effect = 1,
		chance = 100,
		shootEffect = 219,
		interval = 2 * 1000
	},
}

blood_fury.elements = {
	{type = COMBAT_PHYSICALDAMAGE, percent = 0},
	{type = COMBAT_ENERGYDAMAGE, percent = 0},
	{type = COMBAT_EARTHDAMAGE, percent = 0},
	{type = COMBAT_FIREDAMAGE, percent = 0},
	{type = COMBAT_LIFEDRAIN, percent = 0},
	{type = COMBAT_MANADRAIN, percent = 0},
	{type = COMBAT_DROWNDAMAGE, percent = 0},
	{type = COMBAT_ICEDAMAGE, percent = 0},
	{type = COMBAT_HOLYDAMAGE , percent = 0},
	{type = COMBAT_DEATHDAMAGE , percent = 0}
}

blood_fury.defenses = {
	defense = 1,
	armor = 1,
}

local SPELLS_CONFIG = {
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 50,
		damageRaw = 2500,
		damageType = COMBAT_PHYSICALDAMAGE,
		area = BLOODFURY_UE,
		effect = 576,
		bottomEffect = true,
		center = true,
		offsetX = 6,
		offsetY = 6,
		stay = true,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,
		multiDelay = 100,
		damageRaw = 1000,
		damageType = COMBAT_PHYSICALDAMAGE,
		effect = 399,
		bottomEffect = false,
		center = true,
		offsetX = 2,
		offsetY = 2,
		onTarget = true,
		stay = true,
		count = 10,
		area = SPELL_3,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,
		multiDelay = 100,

		damageRaw = 4000,
		damageType = COMBAT_PHYSICALDAMAGE,
		effect = 550,
		bottomEffect = true,
		center = true,
		offsetX = 3,
		offsetY = 3,
		random_size = 5,

		count = 5,
		area = BLOOD_FURY,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 75,

		damageRaw = 2750,
		damageType = COMBAT_FIREDAMAGE,
		effect = 220,
		area = BLOODY_CHAIN,
		stay = true,
	},
}

function mType.onThink(monster, interval)
	local mid = monster:getId()
	if mid == 0 then return end
	if not BOSS_MONSTER_CONFIG[mid] then
		BOSS_MONSTER_CONFIG[mid] = {
			ready = 0,
			phase = 0,
			spells = {}
		}
	end
	onThinkBoss(monster, interval, SPELLS_CONFIG, BOSS_MONSTER_CONFIG[mid])
end

function mType.onAppear(monster, creature)
	if monster and creature then
		local id = monster:getId()
		if id == creature:getId() then
			monster:registerEvent("blood_fury_death_hp")
			monster:registerEvent("blood_fury_death")
			mType:isAttackable(true)
			monster:setSkull(blood_fury.skull)
			monster:setMonsterLevel(blood_fury.monsterLevel)
			mType:tier(blood_fury.tier)
			monster:setStorageValue( PlayerStorage.keyTier ,blood_fury.tierDungeon)
			mType:items(blood_fury.items)
			BOSS_MONSTER_CONFIG[id] = {
				ready = 0,
				phase = 0,
				spells = {}
			}
		end
	end
end
mType:register(blood_fury)

local eventHealth = CreatureEvent("blood_fury_death_hp")

function eventHealth.onHealthChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
	if not creature or not attacker then
		return primaryDamage, primaryType, secondaryDamage, secondaryType
	end
	return primaryDamage, primaryType, secondaryDamage, secondaryType
end

local eventDeath = CreatureEvent("blood_fury_death")

function eventDeath.onDeath(creature, corpse, lasthitkiller, mostdamagekiller, lasthitunjustified, mostdamageunjustified)
	if not creature then
		return true
	end

	BOSS_MONSTER_CONFIG[creature:getId()] = nil
	return true
end

eventDeath:register()
eventHealth:register()
