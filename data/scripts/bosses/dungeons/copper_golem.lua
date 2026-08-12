local mType = Game.createMonsterType("Copper Golem")

local copper_golem = {}
copper_golem.description = "Copper Golem"
copper_golem.experience = 2000
copper_golem.outfit = {
	lookType = 2376,
    lookHealthBar = 3
}

copper_golem.health = 50000
copper_golem.maxHealth = 50000
copper_golem.race = "boss"
copper_golem.corpse = 27196
copper_golem.speed = 350
copper_golem.monsterLevel = 30
-- copper_golem.script = "copper_golem.lua"
copper_golem.skull = 0
copper_golem.tier = 1
copper_golem.items = "dungeonboss"
copper_golem.bestiary = 132

copper_golem.changeTarget = {
	interval = 4 * 1000,
	chance = 100
}

copper_golem.flags = {
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

copper_golem.attacks = {
	{
		name = "combat",
		type = COMBAT_HOLYDAMAGE,
		minDamage = -200,
		maxDamage = -200,
		range = 6,
		chance = 100,
		shootEffect = 38,
		interval = 2 * 1000
	},
}

copper_golem.elements = {
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

copper_golem.defenses = {
	defense = 1,
	armor = 1,
}

local SPELLS_CONFIG = {
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 75,
		damageRaw = 1000,
		damageType = COMBAT_PHYSICALDAMAGE,
		area = SPELL_PENTAGRAM,
		effect = 239,
		stay = true,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 75,
		damageRaw = 1000,
		damageType = COMBAT_HOLYDAMAGE,
		area = SPELL_WAVE_1,
		effect = 422,
		stay = true,
		wave = true,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,
		multiDelay = 50,
		damageRaw = 1000,
		damageType = COMBAT_HOLYDAMAGE,
		effect = 491,
		onTarget = true,

		count = 10,
		area = SPELL_RANDOM_1SQM,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 200,
		multiDelay = 500,

		damageRaw = 5000,
		damageType = COMBAT_HOLYDAMAGE,
		effect = 421,
		bottomEffect = false,
		center = true,
		offsetX = 2,
		offsetY = 2,
		onTarget = true,
		count = 2,
		area = COPPER_HOLY,
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
			monster:registerEvent("copper_golem_death_hp")
			monster:registerEvent("copper_golem_death")
			mType:isAttackable(true)
			monster:setSkull(0)
			monster:setMonsterLevel(30)
			mType:tier(copper_golem.tier)
			mType:items(copper_golem.items)
			BOSS_MONSTER_CONFIG[id] = {
				ready = 0,
				phase = 0,
				spells = {}
			}
		end
	end
end
mType:register(copper_golem)

local eventHealth = CreatureEvent("copper_golem_death_hp")

function eventHealth.onHealthChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
	if not creature or not attacker then
		return primaryDamage, primaryType, secondaryDamage, secondaryType
	end
	return primaryDamage, primaryType, secondaryDamage, secondaryType
end

local eventDeath = CreatureEvent("copper_golem_death")

function eventDeath.onDeath(creature, corpse, lasthitkiller, mostdamagekiller, lasthitunjustified, mostdamageunjustified)
	if not creature then
		return true
	end

	BOSS_MONSTER_CONFIG[creature:getId()] = nil
	return true
end

eventDeath:register()
eventHealth:register()
