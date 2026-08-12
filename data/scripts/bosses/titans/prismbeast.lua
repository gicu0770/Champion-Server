local mType = Game.createMonsterType("Prism Beast")

local prismbeast = {}
prismbeast.description = "Prism Beast"
prismbeast.experience = 2000
prismbeast.outfit = {
	lookType = 2474,
    lookHealthBar = 2
}

prismbeast.health = 20000000000
prismbeast.maxHealth = 20000000000
prismbeast.corpse = 27196
prismbeast.speed = 350
prismbeast.tier = 1
prismbeast.monsterLevel = 800
prismbeast.items = "titan"
prismbeast.skull = 0
prismbeast.zone = 48
prismbeast.bestiary = 136

prismbeast.changeTarget = {
	interval = 4 * 1000,
	chance = 100
}

prismbeast.flags = {
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

prismbeast.attacks = {
	{
		name = "combat",
		type = COMBAT_ENERGYDAMAGE,
		minDamage = -200,
		maxDamage = -200,
		range = 6,
		chance = 100,
		shootEffect = 259,
		interval = 2 * 1000
	},
}

prismbeast.elements = {
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

prismbeast.defenses = {
	defense = 1,
	armor = 1,
}

local SPELLS_CONFIG = {
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,
		multiDelay = 100,
		damageRaw = 1000,
		damageType = COMBAT_ENERGYDAMAGE,
		effect = 539,
		distanceeffect = 259,
		onTarget = true,
		bottomEffect = false,
		center = true,
		offsetX = 1,
		offsetY = 1,
		random_size = 5,
		
		count = 10,
		area = SPELL_RANDOM_3SQM,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,
		multiDelay = 100,
		damageRaw = 3500,
		damageType = COMBAT_ICEDAMAGE,
		effect = 528,
		onTarget = true,
		count = 10,
		area = SPELL_RANDOM_1SQM,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,
		damageRaw = 500,
		damageType = COMBAT_ENERGYDAMAGE,
		area = BONEBOUND_STALKERUE,
		effect = 548,
		bottomEffect = false,
		center = true,
		offsetX = 6,
		offsetY = 6,
		stay = true,
	},
	{
		interval = 2000,
		exhaust = 800,
		startTime = 100,
		multiDelay = 100,

		damageRaw = 4000,
		damageType = COMBAT_ENERGYDAMAGE,
		effect = 545,
		bottomEffect = true,
		center = true,
		offsetX = 3,
		offsetY = 3,
		onTarget = true,

		count = 1,
		area = BLOOD_FURY,
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
			monster:setMaxHealth(prismbeast.health)
			monster:setHealth(prismbeast.maxHealth)
			monster:registerEvent("prismbeast_death_hp")
			monster:registerEvent("prismbeast_death")
			monster:setMonsterLevel(prismbeast.monsterLevel)
			monster:setSkull(prismbeast.skull)
			mType:tier(prismbeast.tier)
			mType:items(prismbeast.items)
			BOSS_MONSTER_CONFIG[id] = {
				ready = 0,
				phase = 0,
				spells = {}
			}
		end
	end
end
mType:register(prismbeast)

local eventHealth = CreatureEvent("prismbeast_death_hp")
function eventHealth.onHealthChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
	if not creature or not attacker then
		return primaryDamage, primaryType, secondaryDamage, secondaryType
	end
	return primaryDamage, primaryType, secondaryDamage, secondaryType
end

local eventDeath = CreatureEvent("prismbeast_death")
function eventDeath.onDeath(creature, corpse, lasthitkiller, mostdamagekiller, lasthitunjustified, mostdamageunjustified)
	if not creature then
		return true
	end

	BOSS_MONSTER_CONFIG[creature:getId()] = nil
	return true
end

eventDeath:register()
eventHealth:register()
