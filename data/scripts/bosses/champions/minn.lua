local mType = Game.createMonsterType("Minn")

local Minn = {}
Minn.description = "Minn"
Minn.experience = 2000
Minn.outfit = {
	lookType = 974,
    lookHealthBar = 2
}

Minn.health = 1000
Minn.maxHealth = 1000
Minn.corpse = 27196
Minn.speed = 300
Minn.tier = 1
Minn.monsterLevel = 55
Minn.items = "champion"
Minn.skull = 27
Minn.bestiary = 157

Minn.changeTarget = {
	interval = 4 * 1000,
	chance = 100
}

Minn.flags = {
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

Minn.attacks = {
	{
		name = "combat",
		type = COMBAT_PHYSICALDAMAGE,
		minDamage = -200,
		maxDamage = -200,
		range = 6,
		chance = 100,
		shootEffect = 28,
		interval = 2 * 1000
	},
}

Minn.elements = {
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

Minn.defenses = {
	defense = 1,
	armor = 1,
}

local SPELLS_CONFIG = {
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 75,

		damageRaw = 1500,
		damageType = COMBAT_ENERGYDAMAGE,
		area = MINN,
		effect = 668,
		stay = true,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,
		multiDelay = 200,

		damageRaw = 800,
		damageType = COMBAT_ENERGYDAMAGE,
		effect = 673,
		onTarget = true,
		count = 5,
		area = SPELL_RANDOM_1SQM,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 200,
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
		count = 3,
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
			monster:setMaxHealth(Minn.health)
			monster:setHealth(Minn.maxHealth)
			monster:registerEvent("Minn_death_hp")
			monster:registerEvent("Minn_death")
			mType:isAttackable(true)
			monster:setMonsterLevel(Minn.monsterLevel)
			monster:setSkull(Minn.skull)
			mType:tier(Minn.tier)
			mType:items(Minn.items)
			BOSS_MONSTER_CONFIG[id] = {
				ready = 0,
				phase = 0,
				spells = {}
			}
		end
	end
end
mType:register(Minn)

local eventHealth = CreatureEvent("Minn_death_hp")

function eventHealth.onHealthChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
	if not creature or not attacker then
		return primaryDamage, primaryType, secondaryDamage, secondaryType
	end
	return primaryDamage, primaryType, secondaryDamage, secondaryType
end

local eventDeath = CreatureEvent("Minn_death")

function eventDeath.onDeath(creature, corpse, lasthitkiller, mostdamagekiller, lasthitunjustified, mostdamageunjustified)
	if not creature then
		return true
	end

	BOSS_MONSTER_CONFIG[creature:getId()] = nil
	return true
end

eventDeath:register()
eventHealth:register()
