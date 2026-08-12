local mType = Game.createMonsterType("Grand Master")

local grandmaster = {}
grandmaster.description = "Grand Master"
grandmaster.experience = 2000
grandmaster.outfit = {
	lookType = 1405,
    lookHealthBar = 3
}

grandmaster.health = 600000
grandmaster.maxHealth = 600000
grandmaster.corpse = 27196
grandmaster.speed = 300
grandmaster.tier = 1
grandmaster.monsterLevel = 35
grandmaster.items = "titan"
grandmaster.skull = 0
grandmaster.bestiary = 149

grandmaster.changeTarget = {
	interval = 4 * 1000,
	chance = 100
}

grandmaster.flags = {
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

grandmaster.attacks = {
	{
		name = "combat",
		type = COMBAT_PHYSICALDAMAGE,
		minDamage = -200,
		maxDamage = -200,
		range = 6,
		effect = 1,
		chance = 100,
		shootEffect = 25,
		interval = 2 * 1000
	},
}

grandmaster.elements = {
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

grandmaster.defenses = {
	defense = 1,
	armor = 1,
}

local SPELLS_CONFIG = {
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,

		damageRaw = 1000,
		damageType = COMBAT_PHYSICALDAMAGE,
		area = LINE_1,
		effect = 239,
		stay = true,
		wave = true,
	},

	{
		interval = 2000,
		exhaust = 1000,
		startTime = 200,

		damageRaw = 1000,
		damageType = COMBAT_PHYSICALDAMAGE,
		area = GRANDMASTERFALA,
		effect = 338,
		stay = true,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,
		multiDelay = 300,

		damageRaw = 1000,
		damageType = COMBAT_PHYSICALDAMAGE,
		effect = 521,
		bottomEffect = true,
		center = true,
		offsetX = 2,
		offsetY = 2,
		onTarget = true,
		stay = true,
		jump_position = true,
		count = 1,
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
			monster:setMaxHealth(grandmaster.health)
			monster:setHealth(grandmaster.maxHealth)
			monster:registerEvent("grandmaster_death_hp")
			monster:registerEvent("grandmaster_death")
			mType:isAttackable(true)
			monster:setMonsterLevel(grandmaster.monsterLevel)
			monster:setSkull(grandmaster.skull)
			mType:tier(grandmaster.tier)
			mType:items(grandmaster.items)
			BOSS_MONSTER_CONFIG[id] = {
				ready = 0,
				phase = 0,
				spells = {}
			}
		end
	end
end
mType:register(grandmaster)

local eventHealth = CreatureEvent("grandmaster_death_hp")

function eventHealth.onHealthChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
	if not creature or not attacker then
		return primaryDamage, primaryType, secondaryDamage, secondaryType
	end
	return primaryDamage, primaryType, secondaryDamage, secondaryType
end

local eventDeath = CreatureEvent("grandmaster_death")

function eventDeath.onDeath(creature, corpse, lasthitkiller, mostdamagekiller, lasthitunjustified, mostdamageunjustified)
	if not creature then
		return true
	end

	BOSS_MONSTER_CONFIG[creature:getId()] = nil
	return true
end

eventDeath:register()
eventHealth:register()
