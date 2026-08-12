local mType = Game.createMonsterType("Boa")

local Boa = {}
Boa.description = "Boa"
Boa.experience = 2000
Boa.outfit = {
	lookType = 1008,
    lookHealthBar = 2
}

Boa.health = 1000
Boa.maxHealth = 1000
Boa.corpse = 27196
Boa.speed = 300
Boa.tier = 1
Boa.monsterLevel = 75
Boa.items = "champion"
Boa.skull = 27
Boa.bestiary = 154

Boa.changeTarget = {
	interval = 4 * 1000,
	chance = 100
}

Boa.flags = {
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

Boa.attacks = {
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

Boa.elements = {
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

Boa.defenses = {
	defense = 1,
	armor = 1,
}

local SPELLS_CONFIG = {
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 75,

		damageRaw = 2500,
		damageType = COMBAT_PHYSICALDAMAGE,
		area = BOA,
		tileDistanceEffect = 200,
		stay = true,
		wave = true,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,
		multiDelay = 200,

		damageRaw = 800,
		damageType = COMBAT_PHYSICALDAMAGE,
		effect = 118,
		bottomEffect = false,
		center = true,
		offsetX = 1,
		offsetY = 1,
		onTarget = true,
		count = 5,
		area = SPELL_3,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,

		damageRaw = 2500,
		damageType = COMBAT_PHYSICALDAMAGE,
		effect = 686,
		area = DEEPCLAW,
		bottomEffect = false,
		center = true,
		offsetX = 4,
		offsetY = 4,
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
			monster:setMaxHealth(Boa.health)
			monster:setHealth(Boa.maxHealth)
			monster:registerEvent("Boa_death_hp")
			monster:registerEvent("Boa_death")
			mType:isAttackable(true)
			monster:setMonsterLevel(Boa.monsterLevel)
			monster:setSkull(Boa.skull)
			mType:tier(Boa.tier)
			mType:items(Boa.items)
			BOSS_MONSTER_CONFIG[id] = {
				ready = 0,
				phase = 0,
				spells = {}
			}
		end
	end
end
mType:register(Boa)

local eventHealth = CreatureEvent("Boa_death_hp")

function eventHealth.onHealthChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
	if not creature or not attacker then
		return primaryDamage, primaryType, secondaryDamage, secondaryType
	end
	return primaryDamage, primaryType, secondaryDamage, secondaryType
end

local eventDeath = CreatureEvent("Boa_death")

function eventDeath.onDeath(creature, corpse, lasthitkiller, mostdamagekiller, lasthitunjustified, mostdamageunjustified)
	if not creature then
		return true
	end

	BOSS_MONSTER_CONFIG[creature:getId()] = nil
	return true
end

eventDeath:register()
eventHealth:register()
