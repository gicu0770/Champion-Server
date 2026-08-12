local mType = Game.createMonsterType("Fleshrend")

local fleshrend = {}
fleshrend.description = "Fleshrend"
fleshrend.experience = 2000
fleshrend.outfit = {
	lookType = 2366,
    lookHealthBar = 3
}

fleshrend.health = 500000
fleshrend.maxHealth = 500000
fleshrend.race = "boss"
fleshrend.corpse = 27196
fleshrend.speed = 350
fleshrend.monsterLevel = 80
fleshrend.skull = 0
fleshrend.tier = 1
fleshrend.items = "dungeonboss"
fleshrend.zone = 43
fleshrend.bestiary = 118

fleshrend.changeTarget = {
	interval = 4 * 1000,
	chance = 100
}

fleshrend.flags = {
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

fleshrend.attacks = {
	{
		name = "combat",
		type = COMBAT_PHYSICALDAMAGE,
		minDamage = -200,
		maxDamage = -200,
		range = 6,
		chance = 100,
		effect = 94,
		shootEffect = 219,
		interval = 2 * 1000
	},
}

fleshrend.elements = {
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

fleshrend.defenses = {
	defense = 1,
	armor = 1,
}

local SPELLS_CONFIG = {
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 75,
		damageRaw = 2500,
		damageType = COMBAT_PHYSICALDAMAGE,
		area = SPELL_PENTAGRAM,
		effect = 176,
		wave = true,
		stay = true,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,
		multiDelay = 100,

		damageRaw = 2750,
		damageType = COMBAT_PHYSICALDAMAGE,
		effect = 437,
		onTarget = true,
		count = 10,
		area = SPELL_RANDOM_1SQM,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 75,
		damageRaw = 500,
		damageType = COMBAT_ENERGYDAMAGE,
		area = URNA,
		tileDistanceEffect = 218,
		stay = true,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,
		multiDelay = 100,

		damageRaw = 5000,
		damageType = COMBAT_PHYSICALDAMAGE,
		effect = 498,
		bottomEffect = false,
		center = true,
		offsetX = 1,
		offsetY = 1,
		random_size = 5,
		count = 10,
		area = SPELL_RANDOM_2,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,
		multiDelay = 100,

		damageRaw = 1000,
		damageType = COMBAT_PHYSICALDAMAGE,
		effect = 550,
		bottomEffect = false,
		center = true,
		offsetX = 3,
		offsetY = 3,
		onTarget = true,
		stay = true,
		count = 5,
		area = FLASHREND,
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
			monster:registerEvent("fleshrend_death_hp")
			monster:registerEvent("fleshrend_death")
			mType:isAttackable(true)
			monster:setSkull(fleshrend.skull)
			monster:setMonsterLevel(fleshrend.monsterLevel)
			mType:tier(fleshrend.tier)
			mType:items(fleshrend.items)
			BOSS_MONSTER_CONFIG[id] = {
				ready = 0,
				phase = 0,
				spells = {}
			}
		end
	end
end
mType:register(fleshrend)

local eventHealth = CreatureEvent("fleshrend_death_hp")

function eventHealth.onHealthChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
	if not creature or not attacker then
		return primaryDamage, primaryType, secondaryDamage, secondaryType
	end
	return primaryDamage, primaryType, secondaryDamage, secondaryType
end

local eventDeath = CreatureEvent("fleshrend_death")

function eventDeath.onDeath(creature, corpse, lasthitkiller, mostdamagekiller, lasthitunjustified, mostdamageunjustified)
	if not creature then
		return true
	end

	BOSS_MONSTER_CONFIG[creature:getId()] = nil
	return true
end

eventDeath:register()
eventHealth:register()
