local mType = Game.createMonsterType("Viliaan")

local Viliaan = {}
Viliaan.description = "Viliaan"
Viliaan.experience = 2000
Viliaan.outfit = {
	lookType = 2807,
    lookHealthBar = 2
}

Viliaan.health = 1000
Viliaan.maxHealth = 1000
Viliaan.corpse = 27196
Viliaan.speed = 300
Viliaan.tier = 1
Viliaan.monsterLevel = 95
Viliaan.items = "champion"
Viliaan.skull = 0
Viliaan.bestiary = 160

Viliaan.changeTarget = {
	interval = 4 * 1000,
	chance = 100
}

Viliaan.flags = {
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

Viliaan.attacks = {
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

Viliaan.elements = {
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

Viliaan.defenses = {
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
			monster:setMaxHealth(Viliaan.health)
			monster:setHealth(Viliaan.maxHealth)
			monster:registerEvent("Viliaan_death_hp")
			monster:registerEvent("Viliaan_death")
			mType:isAttackable(true)
			monster:setMonsterLevel(Viliaan.monsterLevel)
			monster:setSkull(Viliaan.skull)
			mType:tier(Viliaan.tier)
			mType:items(Viliaan.items)
			BOSS_MONSTER_CONFIG[id] = {
				ready = 0,
				phase = 0,
				spells = {}
			}
		end
	end
end
mType:register(Viliaan)

local eventHealth = CreatureEvent("Viliaan_death_hp")

function eventHealth.onHealthChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
	if not creature or not attacker then
		return primaryDamage, primaryType, secondaryDamage, secondaryType
	end
	return primaryDamage, primaryType, secondaryDamage, secondaryType
end

local eventDeath = CreatureEvent("Viliaan_death")

function eventDeath.onDeath(creature, corpse, lasthitkiller, mostdamagekiller, lasthitunjustified, mostdamageunjustified)
	if not creature then
		return true
	end

	BOSS_MONSTER_CONFIG[creature:getId()] = nil
	return true
end

eventDeath:register()
eventHealth:register()
