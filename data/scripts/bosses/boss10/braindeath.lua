local mType = Game.createMonsterType("Braindeath")

local braindeath = {}
braindeath.description = "Braindeath"
braindeath.experience = 2000
braindeath.outfit = {
	lookType = 256,
    lookHealthBar = 3
}

braindeath.health = 12000000
braindeath.maxHealth = 12000000
braindeath.corpse = 27196
braindeath.speed = 230
braindeath.tier = 1
braindeath.monsterLevel = 75
braindeath.items = "titan"
braindeath.skull = 0
braindeath.bestiary = 145

braindeath.changeTarget = {
	interval = 4 * 1000,
	chance = 100
}

braindeath.flags = {
	summonable = false,
	attackable = true,
	hostile = true,
	convinceable = false,
	illusionable = false,
	pushable = false,
	canPushItems = true,
	canPushCreatures = true,
	unique = true,
	targetDistance = 2,
	staticAttackChance = 70
}

braindeath.attacks = {
	{
		name = "combat",
		type = COMBAT_DEATHDAMAGE,
		minDamage = -200,
		maxDamage = -200,
		range = 6,
		effect = 39,
		chance = 100,
		shootEffect = 32,
		interval = 2 * 1000
	},
}

braindeath.elements = {
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

braindeath.defenses = {
	defense = 1,
	armor = 1,
}

local SPELLS_CONFIG = {
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 200,
		damageRaw = 4500,
		damageType = COMBAT_EARTHDAMAGE,
		area = BRAINDEATHDOUBLE,
		effect = 281,
		bottomEffect = false,
		center = true,
		offsetX = 4,
		offsetY = 4,
		stay = true,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,
		multiDelay = 100,

		damageRaw = 2750,
		damageType = COMBAT_DEATHDAMAGE,
		effect = 349,
		onTarget = true,

		count = 10,
		area = SPELL_RANDOM_1SQM,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,
		damageRaw = 1500,
		damageType = COMBAT_DEATHDAMAGE,
		area = HYDRA_2XWAVE,
		tileDistanceEffect = 269,
		wave = true,
		stay = true,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,

		damageRaw = 1000,
		damageType = COMBAT_DEATHDAMAGE,
		area = VOORT_SMALLUE,
		effect = 625,
		center = true,
		offsetX = 3,
		offsetY = 3,
		stay = true,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,
		multiDelay = 250,

		damageRaw = 5000,
		damageType = COMBAT_EARTHDAMAGE,
		effect = 619,
		bottomEffect = false,
		center = true,
		offsetX = 6,
		offsetY = 6,
		random_size = 6,
		count = 10,
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
			monster:setMaxHealth(braindeath.health)
			monster:setHealth(braindeath.maxHealth)
			monster:registerEvent("braindeath_death_hp")
			monster:registerEvent("braindeath_death")
			mType:isAttackable(true)
			monster:setMonsterLevel(braindeath.monsterLevel)
			monster:setSkull(braindeath.skull)
			mType:tier(braindeath.tier)
			mType:items(braindeath.items)
			BOSS_MONSTER_CONFIG[id] = {
				ready = 0,
				phase = 0,
				spells = {}
			}
		end
	end
end
mType:register(braindeath)

local eventHealth = CreatureEvent("braindeath_death_hp")

function eventHealth.onHealthChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
	if not creature or not attacker then
		return primaryDamage, primaryType, secondaryDamage, secondaryType
	end
	return primaryDamage, primaryType, secondaryDamage, secondaryType
end

local eventDeath = CreatureEvent("braindeath_death")

function eventDeath.onDeath(creature, corpse, lasthitkiller, mostdamagekiller, lasthitunjustified, mostdamageunjustified)
	if not creature then
		return true
	end

	BOSS_MONSTER_CONFIG[creature:getId()] = nil
	return true
end

eventDeath:register()
eventHealth:register()
