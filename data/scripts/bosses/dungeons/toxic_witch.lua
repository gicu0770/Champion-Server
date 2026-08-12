local mType = Game.createMonsterType("Toxic Witch")

local toxic_witch = {}
toxic_witch.description = "Toxic Witch"
toxic_witch.experience = 2000
toxic_witch.outfit = {
	lookType = 2790,
    lookHealthBar = 3
}

toxic_witch.health = 15000
toxic_witch.maxHealth = 15000
toxic_witch.race = "boss"
toxic_witch.corpse = 27196
toxic_witch.speed = 350
toxic_witch.monsterLevel = 55
toxic_witch.skull = 0
toxic_witch.tier = 1
toxic_witch.items = "dungeonboss"
toxic_witch.zone = 38
toxic_witch.bestiary = 98

toxic_witch.changeTarget = {
	interval = 4 * 1000,
	chance = 100
}

toxic_witch.flags = {
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

toxic_witch.attacks = {
	{
		name = "combat",
		type = COMBAT_EARTHDAMAGE,
		minDamage = -200,
		maxDamage = -200,
		range = 6,
		chance = 100,
		effect = 21,
		shootEffect = 166,
		interval = 2 * 1000
	},
}

toxic_witch.elements = {
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

toxic_witch.defenses = {
	defense = 1,
	armor = 1,
}

local SPELLS_CONFIG = {
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,
		damageRaw = 1500,
		damageType = COMBAT_EARTHDAMAGE,
		area = HYDRA_2XWAVE,
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
		bottomEffect = false,
		center = true,
		offsetX = 1,
		offsetY = 1,
		onTarget = true,
		count = 10,
		area = SPELL_RANDOM_3SQM,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,

		damageRaw = 1000,
		damageType = COMBAT_EARTHDAMAGE,
		area = RUSTWIDOW,
		effect = 281,
		bottomEffect = true,
		center = true,
		offsetX = 4,
		offsetY = 4,
		stay = true,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,
		multiDelay = 100,

		damageRaw = 5000,
		damageType = COMBAT_EARTHDAMAGE,
		effect = 540,
		bottomEffect = false,
		center = true,
		stay = true,
		offsetX = 1,
		offsetY = 1,
		random_size = 5,
		count = 20,
		area = SPELL_3,
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
			monster:registerEvent("toxic_witch_death_hp")
			monster:registerEvent("toxic_witch_death")
			mType:isAttackable(true)
			monster:setSkull(toxic_witch.skull)
			monster:setMonsterLevel(toxic_witch.monsterLevel)
			mType:tier(toxic_witch.tier)
			mType:items(toxic_witch.items)
			BOSS_MONSTER_CONFIG[id] = {
				ready = 0,
				phase = 0,
				spells = {}
			}
		end
	end
end
mType:register(toxic_witch)

local eventHealth = CreatureEvent("toxic_witch_death_hp")

function eventHealth.onHealthChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
	if not creature or not attacker then
		return primaryDamage, primaryType, secondaryDamage, secondaryType
	end
	return primaryDamage, primaryType, secondaryDamage, secondaryType
end

local eventDeath = CreatureEvent("toxic_witch_death")

function eventDeath.onDeath(creature, corpse, lasthitkiller, mostdamagekiller, lasthitunjustified, mostdamageunjustified)
	if not creature then
		return true
	end

	BOSS_MONSTER_CONFIG[creature:getId()] = nil
	return true
end

eventDeath:register()
eventHealth:register()
