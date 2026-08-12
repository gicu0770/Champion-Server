local mType = Game.createMonsterType("Bilbo")

local Bilbo = {}
Bilbo.description = "Bilbo"
Bilbo.experience = 2000
Bilbo.outfit = {
	lookType = 2643,
    lookHealthBar = 2
}

Bilbo.health = 1000
Bilbo.maxHealth = 1000
Bilbo.corpse = 27196
Bilbo.speed = 300
Bilbo.tier = 1
Bilbo.monsterLevel = 95
Bilbo.items = "champion"
Bilbo.skull = 0
Bilbo.bestiary = 160

Bilbo.changeTarget = {
	interval = 4 * 1000,
	chance = 100
}

Bilbo.flags = {
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

Bilbo.attacks = {
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

Bilbo.elements = {
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

Bilbo.defenses = {
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
			monster:setMaxHealth(Bilbo.health)
			monster:setHealth(Bilbo.maxHealth)
			monster:registerEvent("Bilbo_death_hp")
			monster:registerEvent("Bilbo_death")
			mType:isAttackable(true)
			monster:setMonsterLevel(Bilbo.monsterLevel)
			monster:setSkull(Bilbo.skull)
			mType:tier(Bilbo.tier)
			mType:items(Bilbo.items)
			BOSS_MONSTER_CONFIG[id] = {
				ready = 0,
				phase = 0,
				spells = {}
			}
		end
	end
end
mType:register(Bilbo)

local eventHealth = CreatureEvent("Bilbo_death_hp")

function eventHealth.onHealthChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
	if not creature or not attacker then
		return primaryDamage, primaryType, secondaryDamage, secondaryType
	end
	return primaryDamage, primaryType, secondaryDamage, secondaryType
end

local eventDeath = CreatureEvent("Bilbo_death")

function eventDeath.onDeath(creature, corpse, lasthitkiller, mostdamagekiller, lasthitunjustified, mostdamageunjustified)
	if not creature then
		return true
	end

	BOSS_MONSTER_CONFIG[creature:getId()] = nil
	return true
end

eventDeath:register()
eventHealth:register()
