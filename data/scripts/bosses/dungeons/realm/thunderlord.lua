local mType = Game.createMonsterType("Thunderlord")

local thunderlord = {}
thunderlord.description = "Thunderlord"
thunderlord.experience = 2000
thunderlord.outfit = {
	lookType = 2364,
    lookHealthBar = 3
}

thunderlord.health = 250000
thunderlord.maxHealth = 250000
thunderlord.race = "boss"
thunderlord.corpse = 27196
thunderlord.speed = 300
thunderlord.monsterLevel = 250
thunderlord.skull = 0
thunderlord.tier = 1
thunderlord.items = "uberboss"
thunderlord.bestiary = 140

thunderlord.changeTarget = {
	interval = 4 * 1000,
	chance = 100
}

thunderlord.flags = {
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

thunderlord.attacks = {
	{
		name = "combat",
		type = COMBAT_ENERGYDAMAGE,
		minDamage = -200,
		maxDamage = -200,
		range = 6,
		chance = 100,
		shootEffect = 206,
		interval = 2 * 1000
	},
}

thunderlord.elements = {
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

thunderlord.defenses = {
	defense = 1,
	armor = 1,
}

local SPELLS_CONFIG = {
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 50,
		damageRaw = 2000,
		damageType = COMBAT_ENERGYDAMAGE,
		area = WAVE_NETHERBANEE,
		effect = 48,
		tileDistanceEffect = 216,
		stay = true,
		wave = true,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,
		damageRaw = 2000,
		damageType = COMBAT_ENERGYDAMAGE,
		area = URNA,
		effect = 192,
		stay = true,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,
		multiDelay = 100,

		damageRaw = 5000,
		damageType = COMBAT_ENERGYDAMAGE,
		effect = 274,
		bottomEffect = false,
		center = true,
		offsetX = 2,
		offsetY = 2,
		random_size = 5,
		count = 10,
		area = SPELL_3,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,
		multiDelay = 50,
		damageRaw = 2000,
		damageType = COMBAT_ENERGYDAMAGE,
		effect = 192,
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
			monster:registerEvent("thunderlord_death_hp")
			monster:registerEvent("thunderlord_death")
			mType:isAttackable(true)
			monster:setSkull(thunderlord.skull)
			monster:setMonsterLevel(thunderlord.monsterLevel)
			mType:tier(thunderlord.tier)
			mType:items(thunderlord.items)
			BOSS_MONSTER_CONFIG[id] = {
				ready = 0,
				phase = 0,
				spells = {}
			}
		end
	end
end
mType:register(thunderlord)

local eventHealth = CreatureEvent("thunderlord_death_hp")

function eventHealth.onHealthChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
	if not creature or not attacker then
		return primaryDamage, primaryType, secondaryDamage, secondaryType
	end
	return primaryDamage, primaryType, secondaryDamage, secondaryType
end

local eventDeath = CreatureEvent("thunderlord_death")

function eventDeath.onDeath(creature, corpse, lasthitkiller, mostdamagekiller, lasthitunjustified, mostdamageunjustified)
	if not creature then
		return true
	end

	BOSS_MONSTER_CONFIG[creature:getId()] = nil
	return true
end

eventDeath:register()
eventHealth:register()
