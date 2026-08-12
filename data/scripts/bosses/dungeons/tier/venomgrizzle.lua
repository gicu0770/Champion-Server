local mType = Game.createMonsterType("Venomgrizzle")

local venomgrizzle = {}
venomgrizzle.description = "Venomgrizzle"
venomgrizzle.experience = 2000
venomgrizzle.outfit = {
	lookType = 2365,
    lookHealthBar = 3
}

venomgrizzle.health = 500000
venomgrizzle.maxHealth = 500000
venomgrizzle.race = "boss"
venomgrizzle.corpse = 27196
venomgrizzle.speed = 350
venomgrizzle.monsterLevel = 265
venomgrizzle.skull = 0
venomgrizzle.tier = 1
venomgrizzle.tierDungeon = 21
venomgrizzle.items = "dungeonboss"
venomgrizzle.bestiary = 135

venomgrizzle.changeTarget = {
	interval = 4 * 1000,
	chance = 100
}

venomgrizzle.flags = {
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

venomgrizzle.attacks = {
	{
		name = "combat",
		type = COMBAT_EARTHDAMAGE,
		minDamage = -200,
		maxDamage = -200,
		range = 6,
		effect = 17,
		shootEffect = 165,
		interval = 2 * 1000
	},
}

venomgrizzle.elements = {
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

venomgrizzle.defenses = {
	defense = 1,
	armor = 1,
}

local SPELLS_CONFIG = {
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 75,
		damageRaw = 2500,
		damageType = COMBAT_EARTHDAMAGE,
		area = VENOMGRIZZLE,
		effect = 267,
		wave = true,
		stay = true,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,
		multiDelay = 100,
		damageRaw = 1000,
		damageType = COMBAT_EARTHDAMAGE,
		effect = 268,
		distanceeffect = 149,
		onTarget = true,
		bottomEffect = false,
		center = true,
		offsetX = 1,
		offsetY = 1,
		random_size = 5,
		
		count = 10,
		area = SPELL_RANDOM_3SQM,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 75,
		damageRaw = 500,
		damageType = COMBAT_PHYSICALDAMAGE,
		area = VENOMGRIZZLEUE,
		effect = 62,
		stay = true,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 200,
		multiDelay = 100,
		damageRaw = 1000,
		damageType = COMBAT_EARTHDAMAGE,
		effect = 540,
		onTarget = true,
		bottomEffect = false,
		center = true,
		offsetX = 1,
		offsetY = 1,
		onTarget = true,
		stay = true,
		count = 5,
		area = SPELL_RANDOM_3SQM,
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
			monster:registerEvent("venomgrizzle_death_hp")
			monster:registerEvent("venomgrizzle_death")
			mType:isAttackable(true)
			monster:setSkull(venomgrizzle.skull)
			monster:setMonsterLevel(venomgrizzle.monsterLevel)
			mType:tier(venomgrizzle.tier)
			monster:setStorageValue(PlayerStorage.keyTier , venomgrizzle.tierDungeon)
			mType:items(venomgrizzle.items)
			BOSS_MONSTER_CONFIG[id] = {
				ready = 0,
				phase = 0,
				spells = {}
			}
		end
	end
end
mType:register(venomgrizzle)

local eventHealth = CreatureEvent("venomgrizzle_death_hp")

function eventHealth.onHealthChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
	if not creature or not attacker then
		return primaryDamage, primaryType, secondaryDamage, secondaryType
	end
	return primaryDamage, primaryType, secondaryDamage, secondaryType
end

local eventDeath = CreatureEvent("venomgrizzle_death")

function eventDeath.onDeath(creature, corpse, lasthitkiller, mostdamagekiller, lasthitunjustified, mostdamageunjustified)
	if not creature then
		return true
	end

	BOSS_MONSTER_CONFIG[creature:getId()] = nil
	return true
end

eventDeath:register()
eventHealth:register()
