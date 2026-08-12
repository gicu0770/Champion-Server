local mType = Game.createMonsterType("Frogy")

local Frogy = {}
Frogy.description = "Frogy"
Frogy.experience = 2000
Frogy.outfit = {
	lookType = 977,
    lookHealthBar = 2
}

Frogy.health = 1000
Frogy.maxHealth = 1000
Frogy.corpse = 27196
Frogy.speed = 300
Frogy.tier = 1
Frogy.monsterLevel = 65
Frogy.items = "champion"
Frogy.skull = 27
Frogy.bestiary = 156

Frogy.changeTarget = {
	interval = 4 * 1000,
	chance = 100
}

Frogy.flags = {
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

Frogy.attacks = {
	{
		name = "combat",
		type = COMBAT_EARTHDAMAGE,
		minDamage = -200,
		maxDamage = -200,
		range = 6,
		chance = 100,
		shootEffect = 99,
		interval = 2 * 1000
	},
}

Frogy.elements = {
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

Frogy.defenses = {
	defense = 1,
	armor = 1,
}

local SPELLS_CONFIG = {
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,

		damageRaw = 2000,
		damageType = COMBAT_ENERGYDAMAGE,
		area = FROGGY,
		effect = 109,
		stay = true,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,
		multiDelay = 200,

		damageRaw = 800,
		damageType = COMBAT_ENERGYDAMAGE,
		effect = 109,
		onTarget = true,
		count = 5,
		area = SPELL_RANDOM_1SQM,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,
		damageRaw = 2000,
		damageType = COMBAT_EARTHDAMAGE,
		effect = 267,
		area = URNA,
		stay = true,
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
			monster:setMaxHealth(Frogy.health)
			monster:setHealth(Frogy.maxHealth)
			monster:registerEvent("Frogy_death_hp")
			monster:registerEvent("Frogy_death")
			mType:isAttackable(true)
			monster:setMonsterLevel(Frogy.monsterLevel)
			monster:setSkull(Frogy.skull)
			mType:tier(Frogy.tier)
			mType:items(Frogy.items)
			BOSS_MONSTER_CONFIG[id] = {
				ready = 0,
				phase = 0,
				spells = {}
			}
		end
	end
end
mType:register(Frogy)

local eventHealth = CreatureEvent("Frogy_death_hp")

function eventHealth.onHealthChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
	if not creature or not attacker then
		return primaryDamage, primaryType, secondaryDamage, secondaryType
	end
	return primaryDamage, primaryType, secondaryDamage, secondaryType
end

local eventDeath = CreatureEvent("Frogy_death")

function eventDeath.onDeath(creature, corpse, lasthitkiller, mostdamagekiller, lasthitunjustified, mostdamageunjustified)
	if not creature then
		return true
	end

	BOSS_MONSTER_CONFIG[creature:getId()] = nil
	return true
end

eventDeath:register()
eventHealth:register()
