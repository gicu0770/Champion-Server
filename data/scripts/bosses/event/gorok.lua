local mType = Game.createMonsterType("Gorok")

local Gorok = {}
Gorok.description = "Gorok"
Gorok.experience = 2000
Gorok.outfit = {
	lookType = 2474,
    lookHealthBar = 2
}

Gorok.health = 1000
Gorok.maxHealth = 1000
Gorok.corpse = 27196
Gorok.speed = 300
Gorok.tier = 1
Gorok.monsterLevel = 95
Gorok.items = "champion"
Gorok.skull = 0
Gorok.bestiary = 160

Gorok.changeTarget = {
	interval = 4 * 1000,
	chance = 100
}

Gorok.flags = {
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

Gorok.attacks = {
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

Gorok.elements = {
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

Gorok.defenses = {
	defense = 1,
	armor = 1,
}

local SPELLS_CONFIG = {
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 75,

		damageRaw = 1000,
		damageType = COMBAT_FIREDAMAGE,
		area = WAVE_NETHERBANEE,
		effect = 448,
		stay = true,
		wave = true,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,

		damageRaw = 3000,
		damageType = COMBAT_EARTHDAMAGE,
		area = TWIST3,
		effect = 21,
		stay = true,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,
		multiDelay = 50,

		damageRaw = 3000,
		damageType = COMBAT_EARTHDAMAGE,
		effect = 509,
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
			monster:setMaxHealth(Gorok.health)
			monster:setHealth(Gorok.maxHealth)
			monster:registerEvent("Gorok_death_hp")
			monster:registerEvent("Gorok_death")
			mType:isAttackable(true)
			monster:setMonsterLevel(Gorok.monsterLevel)
			monster:setSkull(Gorok.skull)
			mType:tier(Gorok.tier)
			mType:items(Gorok.items)
			BOSS_MONSTER_CONFIG[id] = {
				ready = 0,
				phase = 0,
				spells = {}
			}
		end
	end
end
mType:register(Gorok)

local eventHealth = CreatureEvent("Gorok_death_hp")

function eventHealth.onHealthChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
	if not creature or not attacker then
		return primaryDamage, primaryType, secondaryDamage, secondaryType
	end
	return primaryDamage, primaryType, secondaryDamage, secondaryType
end

local eventDeath = CreatureEvent("Gorok_death")

function eventDeath.onDeath(creature, corpse, lasthitkiller, mostdamagekiller, lasthitunjustified, mostdamageunjustified)
	if not creature then
		return true
	end

	BOSS_MONSTER_CONFIG[creature:getId()] = nil
	return true
end

eventDeath:register()
eventHealth:register()
