local mType = Game.createMonsterType("Vampire Queen")

local boss = {}
boss.description = "Vampire Queen"
boss.experience = 2000
boss.outfit = {
	lookType = 2490,
    lookHealthBar = 3
}

boss.health = 30000
boss.maxHealth = 30000
boss.race = "boss"
boss.corpse = 27196
boss.speed = 350
-- boss.script = "boss.lua"
boss.skull = 0
boss.tier = 1
boss.items = "dungeonboss"
boss.zone = 36
boss.bestiary = 90

boss.changeTarget = {
	interval = 4 * 1000,
	chance = 100
}

boss.flags = {
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

boss.attacks = {
	{
		name = "combat",
		type = COMBAT_PHYSICALDAMAGE,
		minDamage = -200,
		maxDamage = -200,
		range = 6,
		chance = 100,
		effect = 437,
		interval = 2 * 1000
	},
}

boss.elements = {
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

boss.defenses = {
	defense = 1,
	armor = 1,
}

local SPELLS_CONFIG = {
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 50,
		damageRaw = 1500,
		damageType = COMBAT_PHYSICALDAMAGE,
		area = VAMPIRE_CHAIN,
		effect = 499,
		bottomEffect = false,
		center = true,
		offsetX = 4,
		offsetY = 4,
		stay = true,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 50,
		damageRaw = 500,
		damageType = COMBAT_PHYSICALDAMAGE,
		area = SPELL_WAVE_1,
		effect = 178,
		stay = true,
		wave = true,

	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,
		multiDelay = 500,

		damageRaw = 1000,
		damageType = COMBAT_PHYSICALDAMAGE,
		effect = 544,
		bottomEffect = true,
		center = true,
		offsetX = 3,
		offsetY = 3,
		onTarget = true,
		stay = true,
		jump_position = true,
		count = 3,
		area = VAMPIRE_JUMP,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,
		multiDelay = 100,

		damageRaw = 2750,
		damageType = COMBAT_DEATHDAMAGE,
		effect = 146,
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
			monster:registerEvent("VampireQueen_death_hp")
			monster:registerEvent("VampireQueen_death")
			mType:isAttackable(true)
			monster:setSkull(0)
			monster:setMonsterLevel(25)
			mType:tier(boss.tier)
			mType:items(boss.items)
			BOSS_MONSTER_CONFIG[id] = {
				ready = 0,
				phase = 0,
				spells = {}
			}
		end
	end
end
mType:register(boss)

local eventHealth = CreatureEvent("VampireQueen_death_hp")

function eventHealth.onHealthChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
	if not creature or not attacker then
		return primaryDamage, primaryType, secondaryDamage, secondaryType
	end
	return primaryDamage, primaryType, secondaryDamage, secondaryType
end

local eventDeath = CreatureEvent("VampireQueen_death")

function eventDeath.onDeath(creature, corpse, lasthitkiller, mostdamagekiller, lasthitunjustified, mostdamageunjustified)
	if not creature then
		return true
	end

	BOSS_MONSTER_CONFIG[creature:getId()] = nil
	return true
end

eventDeath:register()
eventHealth:register()
