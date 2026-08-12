local mType = Game.createMonsterType("Molten Abyss")

local molten_abyss = {}
molten_abyss.description = "Molten Abyss"
molten_abyss.experience = 2000
molten_abyss.outfit = {
	lookType = 2559,
    lookHealthBar = 3
}

molten_abyss.health = 50000
molten_abyss.maxHealth = 50000
molten_abyss.race = "boss"
molten_abyss.corpse = 27196
molten_abyss.speed = 350
molten_abyss.monsterLevel = 800
molten_abyss.skull = 0
molten_abyss.tier = 1
molten_abyss.items = "dungeonboss"
molten_abyss.bestiary = 145

molten_abyss.changeTarget = {
	interval = 4 * 1000,
	chance = 100
}

molten_abyss.flags = {
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

molten_abyss.attacks = {
	{
		name = "combat",
		type = COMBAT_PHYSICALDAMAGE,
		minDamage = -200,
		maxDamage = -200,
		range = 6,
		chance = 100,
		effect = 438,
		interval = 2 * 1000
	},
}

molten_abyss.elements = {
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

molten_abyss.defenses = {
	defense = 1,
	armor = 1,
}

local SPELLS_CONFIG = {
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 50,
		damageRaw = 2000,
		damageType = COMBAT_PHYSICALDAMAGE,
		area = MOLTEN_ABYSS,
		effect = 564,
		bottomEffect = false,
		center = true,
		offsetX = 4,
		offsetY = 4,
		stay = true,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 75,
		damageRaw = 2500,
		damageType = COMBAT_PHYSICALDAMAGE,
		area = BIG_LINIE,
		effect = 570,
		onTarget = false,
		wave = true,
		stay = true,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,
		multiDelay = 100,

		damageRaw = 2750,
		damageType = COMBAT_FIREDAMAGE,
		effect = 219,
		bottomEffect = true,
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
		startTime = 100,
		multiDelay = 100,
		damageRaw = 1000,
		damageType = COMBAT_FIREDAMAGE,
		effect = 541,
		bottomEffect = false,
		center = true,
		offsetX = 1,
		offsetY = 1,
		onTarget = true,
		count = 10,
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
			monster:registerEvent("molten_abyss_death_hp")
			monster:registerEvent("molten_abyss_death")
			mType:isAttackable(true)
			monster:setSkull(molten_abyss.skull)
			monster:setMonsterLevel(molten_abyss.monsterLevel)
			mType:tier(molten_abyss.tier)
			mType:items(molten_abyss.items)
			BOSS_MONSTER_CONFIG[id] = {
				ready = 0,
				phase = 0,
				spells = {}
			}
		end
	end
end
mType:register(molten_abyss)

local eventHealth = CreatureEvent("molten_abyss_death_hp")

function eventHealth.onHealthChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
	if not creature or not attacker then
		return primaryDamage, primaryType, secondaryDamage, secondaryType
	end
	return primaryDamage, primaryType, secondaryDamage, secondaryType
end

local eventDeath = CreatureEvent("molten_abyss_death")

function eventDeath.onDeath(creature, corpse, lasthitkiller, mostdamagekiller, lasthitunjustified, mostdamageunjustified)
	if not creature then
		return true
	end

	BOSS_MONSTER_CONFIG[creature:getId()] = nil
	return true
end

eventDeath:register()
eventHealth:register()
