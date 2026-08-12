local mType = Game.createMonsterType("Blightworm")

local Blightworm = {}
Blightworm.description = "Blightworm"
Blightworm.experience = 2000
Blightworm.outfit = {
	lookType = 1189,
    lookHealthBar = 3
}

Blightworm.health = 400000
Blightworm.maxHealth = 400000
Blightworm.corpse = 27196
Blightworm.speed = 300
Blightworm.tier = 1
Blightworm.monsterLevel = 30
Blightworm.items = "titan"
Blightworm.skull = 0
Blightworm.bestiary = 144

Blightworm.changeTarget = {
	interval = 4 * 1000,
	chance = 100
}

Blightworm.flags = {
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

Blightworm.attacks = {
	{
		name = "combat",
		type = COMBAT_EARTHDAMAGE,
		minDamage = -200,
		maxDamage = -200,
		range = 6,
		effect = 9,
		chance = 100,
		shootEffect = 15,
		interval = 2 * 1000
	},
}

Blightworm.elements = {
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

Blightworm.defenses = {
	defense = 1,
	armor = 1,
}

local SPELLS_CONFIG = {
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,

		damageRaw = 800,
		damageType = COMBAT_EARTHDAMAGE,
		area = SPELL_TRIPLE_WAVE,
		effect = 393,
		stay = true,
		wave = true,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,

		damageRaw = 800,
		damageType = COMBAT_EARTHDAMAGE,
		area = SPELL_SLASH_3,
		effect = 461,
		stay = true,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,
		multiDelay = 200,

		damageRaw = 600,
		damageType = COMBAT_EARTHDAMAGE,
		effect = 196,
		onTarget = true,
		count = 5,
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
			monster:setMaxHealth(Blightworm.health)
			monster:setHealth(Blightworm.maxHealth)
			monster:registerEvent("Blightworm_death_hp")
			monster:registerEvent("Blightworm_death")
			mType:isAttackable(true)
			monster:setMonsterLevel(Blightworm.monsterLevel)
			monster:setSkull(Blightworm.skull)
			mType:tier(Blightworm.tier)
			mType:items(Blightworm.items)
			BOSS_MONSTER_CONFIG[id] = {
				ready = 0,
				phase = 0,
				spells = {}
			}
		end
	end
end
mType:register(Blightworm)

local eventHealth = CreatureEvent("Blightworm_death_hp")

function eventHealth.onHealthChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
	if not creature or not attacker then
		return primaryDamage, primaryType, secondaryDamage, secondaryType
	end
	return primaryDamage, primaryType, secondaryDamage, secondaryType
end

local eventDeath = CreatureEvent("Blightworm_death")

function eventDeath.onDeath(creature, corpse, lasthitkiller, mostdamagekiller, lasthitunjustified, mostdamageunjustified)
	if not creature then
		return true
	end

	BOSS_MONSTER_CONFIG[creature:getId()] = nil
	return true
end

eventDeath:register()
eventHealth:register()
