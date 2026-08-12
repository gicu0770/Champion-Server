local mType = Game.createMonsterType("Toxic Hydra")

local toxic_hydra = {}
toxic_hydra.description = "Toxic Hydra"
toxic_hydra.experience = 2000
toxic_hydra.outfit = {
	lookType = 121,
    lookHealthBar = 3
}

toxic_hydra.health = 15000
toxic_hydra.maxHealth = 15000
toxic_hydra.race = "boss"
toxic_hydra.corpse = 27196
toxic_hydra.speed = 350
toxic_hydra.monsterLevel = 55
toxic_hydra.skull = 3
toxic_hydra.tier = 1
toxic_hydra.items = "dungeonboss"
toxic_hydra.zone = 38
toxic_hydra.bestiary = 98

toxic_hydra.changeTarget = {
	interval = 4 * 1000,
	chance = 100
}

toxic_hydra.flags = {
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

toxic_hydra.attacks = {
	{
		name = "combat",
		type = COMBAT_EARTHDAMAGE,
		minDamage = -200,
		maxDamage = -200,
		range = 6,
		chance = 100,
		effect = 21,
		shootEffect = 166,
		interval = 2 * 1000
	},
}

toxic_hydra.elements = {
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

toxic_hydra.defenses = {
	defense = 1,
	armor = 1,
}

local SPELLS_CONFIG = {
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,
		damageRaw = 1500,
		damageType = COMBAT_EARTHDAMAGE,
		area = HYDRA_2XWAVE,
		effect = 267,
		wave = true,
		stay = true,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,
		multiDelay = 100,

		damageRaw = 5000,
		damageType = COMBAT_EARTHDAMAGE,
		effect = 400,
		bottomEffect = false,
		center = true,
		offsetX = 1,
		offsetY = 1,
		random_size = 5,
		count = 10,
		area = SPELL_RANDOM_2,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,
		multiDelay = 100,

		damageRaw = 1000,
		damageType = COMBAT_EARTHDAMAGE,
		effect = 268,
		bottomEffect = false,
		center = true,
		offsetX = 1,
		offsetY = 1,
		onTarget = true,
		count = 5,
		area = SPELL_3,
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
			monster:registerEvent("Toxic_Hydra_death_hp")
			monster:registerEvent("Toxic_Hydra_death")
			mType:isAttackable(true)
			monster:setSkull(toxic_hydra.skull)
			monster:setMonsterLevel(toxic_hydra.monsterLevel)
			mType:tier(toxic_hydra.tier)
			mType:items(toxic_hydra.items)
			BOSS_MONSTER_CONFIG[id] = {
				ready = 0,
				phase = 0,
				spells = {}
			}
		end
	end
end
mType:register(toxic_hydra)

local eventHealth = CreatureEvent("Toxic_Hydra_death_hp")

function eventHealth.onHealthChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
	if not creature or not attacker then
		return primaryDamage, primaryType, secondaryDamage, secondaryType
	end
	return primaryDamage, primaryType, secondaryDamage, secondaryType
end

local eventDeath = CreatureEvent("Toxic_Hydra_death")

function eventDeath.onDeath(creature, corpse, lasthitkiller, mostdamagekiller, lasthitunjustified, mostdamageunjustified)
	if not creature then
		return true
	end

	BOSS_MONSTER_CONFIG[creature:getId()] = nil
	return true
end

eventDeath:register()
eventHealth:register()
