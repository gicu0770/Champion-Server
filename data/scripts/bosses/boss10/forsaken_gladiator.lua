local mType = Game.createMonsterType("Forsaken Gladiator")

local forsaken_gladiator = {}
forsaken_gladiator.description = "Forsaken Gladiator"
forsaken_gladiator.experience = 2000
forsaken_gladiator.outfit = {
	lookType = 2001,
    lookHealthBar = 3
}

forsaken_gladiator.health = 300000000
forsaken_gladiator.maxHealth = 300000000
forsaken_gladiator.corpse = 27196
forsaken_gladiator.speed = 300
forsaken_gladiator.tier = 1
forsaken_gladiator.monsterLevel = 105
forsaken_gladiator.items = "titan"
forsaken_gladiator.skull = 7
forsaken_gladiator.bestiary = 148

forsaken_gladiator.changeTarget = {
	interval = 4 * 1000,
	chance = 100
}

forsaken_gladiator.flags = {
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

forsaken_gladiator.attacks = {
	{
		name = "combat",
		type = COMBAT_PHYSICALDAMAGE,
		minDamage = -200,
		maxDamage = -200,
		range = 6,
		chance = 100,
		shootEffect = 26,
		interval = 2 * 1000
	},
}

forsaken_gladiator.elements = {
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

forsaken_gladiator.defenses = {
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
		area = GRANDMASTERFALA,
		effect = 240,
		stay = true,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,
		multiDelay = 50,

		damageRaw = 5000,
		damageType = COMBAT_PHYSICALDAMAGE,
		tileDistanceEffect = 26,
		onTarget = true,
		
		count = 10,
		area = SPELL_RANDOM_1SQM,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,
		multiDelay = 50,

		damageRaw = 5000,
		damageType = COMBAT_PHYSICALDAMAGE,
		effect = 490,
		random_size = 5,
		
		count = 30,
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
			monster:setMaxHealth(forsaken_gladiator.health)
			monster:setHealth(forsaken_gladiator.maxHealth)
			monster:registerEvent("forsaken_gladiator_death_hp")
			monster:registerEvent("forsaken_gladiator_death")
			mType:isAttackable(true)
			monster:setMonsterLevel(forsaken_gladiator.monsterLevel)
			monster:setSkull(forsaken_gladiator.skull)
			mType:tier(forsaken_gladiator.tier)
			mType:items(forsaken_gladiator.items)
			BOSS_MONSTER_CONFIG[id] = {
				ready = 0,
				phase = 0,
				spells = {}
			}
		end
	end
end
mType:register(forsaken_gladiator)

local eventHealth = CreatureEvent("forsaken_gladiator_death_hp")

function eventHealth.onHealthChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
	if not creature or not attacker then
		return primaryDamage, primaryType, secondaryDamage, secondaryType
	end
	return primaryDamage, primaryType, secondaryDamage, secondaryType
end

local eventDeath = CreatureEvent("forsaken_gladiator_death")

function eventDeath.onDeath(creature, corpse, lasthitkiller, mostdamagekiller, lasthitunjustified, mostdamageunjustified)
	if not creature then
		return true
	end

	BOSS_MONSTER_CONFIG[creature:getId()] = nil
	return true
end

eventDeath:register()
eventHealth:register()
