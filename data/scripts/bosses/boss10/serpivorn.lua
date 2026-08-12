local mType = Game.createMonsterType("Serpivorn")

local serpivorn = {}
serpivorn.description = "Serpivorn"
serpivorn.experience = 2000
serpivorn.outfit = {
	lookType = 1979,
    lookHealthBar = 3
}

serpivorn.health = 100000000
serpivorn.maxHealth = 100000000
serpivorn.corpse = 27196
serpivorn.speed = 300
serpivorn.tier = 1
serpivorn.monsterLevel = 85
serpivorn.items = "titan"
serpivorn.skull = 0
serpivorn.bestiary = 150

serpivorn.changeTarget = {
	interval = 4 * 1000,
	chance = 100
}

serpivorn.flags = {
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

serpivorn.attacks = {
	{
		name = "combat",
		type = COMBAT_EARTHDAMAGE,
		minDamage = -200,
		maxDamage = -200,
		range = 6,
		effect = 21,
		chance = 100,
		shootEffect = 165,
		interval = 2 * 1000
	},
}

serpivorn.elements = {
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

serpivorn.defenses = {
	defense = 1,
	armor = 1,
}

local SPELLS_CONFIG = {
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 75,

		damageRaw = 3500,
		damageType = COMBAT_EARTHDAMAGE,
		area = SEANOWAVE,
		effect = 21,
		stay = true,
		wave = true,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,
		multiDelay = 100,

		damageRaw = 5000,
		damageType = COMBAT_EARTHDAMAGE,
		effect = 540,
		bottomEffect = true,
		center = true,
		stay = true,
		offsetX = 1,
		offsetY = 1,
		random_size = 5,
		count = 10,
		area = SPELL_3,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,
		multiDelay = 100,

		damageRaw = 3500,
		damageType = COMBAT_EARTHDAMAGE,
		effect = 47,
		onTarget = true,
		
		count = 10,
		area = SPELL_RANDOM_1SQM,
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
			monster:setMaxHealth(serpivorn.health)
			monster:setHealth(serpivorn.maxHealth)
			monster:registerEvent("serpivorn_death_hp")
			monster:registerEvent("serpivorn_death")
			mType:isAttackable(true)
			monster:setMonsterLevel(serpivorn.monsterLevel)
			monster:setSkull(serpivorn.skull)
			mType:tier(serpivorn.tier)
			mType:items(serpivorn.items)
			BOSS_MONSTER_CONFIG[id] = {
				ready = 0,
				phase = 0,
				spells = {}
			}
		end
	end
end
mType:register(serpivorn)

local eventHealth = CreatureEvent("serpivorn_death_hp")

function eventHealth.onHealthChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
	if not creature or not attacker then
		return primaryDamage, primaryType, secondaryDamage, secondaryType
	end
	return primaryDamage, primaryType, secondaryDamage, secondaryType
end

local eventDeath = CreatureEvent("serpivorn_death")

function eventDeath.onDeath(creature, corpse, lasthitkiller, mostdamagekiller, lasthitunjustified, mostdamageunjustified)
	if not creature then
		return true
	end

	BOSS_MONSTER_CONFIG[creature:getId()] = nil
	return true
end

eventDeath:register()
eventHealth:register()
