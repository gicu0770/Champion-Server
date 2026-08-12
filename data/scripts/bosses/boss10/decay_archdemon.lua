local mType = Game.createMonsterType("Decay Archdemon")

local decay_archdemon = {}
decay_archdemon.description = "Decay Archdemon"
decay_archdemon.experience = 2000
decay_archdemon.outfit = {
	lookType = 2406,
    lookHealthBar = 3
}

decay_archdemon.health = 300000000
decay_archdemon.maxHealth = 300000000
decay_archdemon.corpse = 27196
decay_archdemon.speed = 250
decay_archdemon.tier = 1
decay_archdemon.monsterLevel = 120
decay_archdemon.items = "titan"
decay_archdemon.skull = 0
decay_archdemon.bestiary = 146

decay_archdemon.changeTarget = {
	interval = 4 * 1000,
	chance = 100
}

decay_archdemon.flags = {
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

decay_archdemon.attacks = {
	{
		name = "combat",
		type = COMBAT_DEATHDAMAGE,
		minDamage = -200,
		maxDamage = -200,
		range = 6,
		chance = 100,
		effect = 200,
		shootEffect = 32,
		interval = 2 * 1000
	},
}

decay_archdemon.elements = {
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

decay_archdemon.defenses = {
	defense = 1,
	armor = 1,
}

local SPELLS_CONFIG = {
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 50,

		damageRaw = 1000,
		damageType = COMBAT_PHYSICALDAMAGE,
		area = WAVE_ARCHDEMON,
		effect = 146,
		wave = true,
		stay = true,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,
		multiDelay = 50,

		damageRaw = 3000,
		damageType = COMBAT_DEATHDAMAGE,
		distanceeffect = 230,
		effect = 506,
		bottomEffect = false,
		center = true,
		stay = true,
		offsetX = 1,
		offsetY = 1,
		onTarget = true,
		count = 10,
		area = SPELL_3,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,
		multiDelay = 50,

		damageRaw = 5000,
		damageType = COMBAT_DEATHDAMAGE,
		effect = 349,
		random_size = 5,
		
		count = 30,
		area = SPELL_RANDOM_1SQM,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,
		multiDelay = 100,

		damageRaw = 5000,
		damageType = COMBAT_ENERGYDAMAGE,
		effect = 543,
		bottomEffect = true,
		center = true,
		stay = true,
		offsetX = 1,
		offsetY = 1,
		random_size = 5,
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
			monster:setMaxHealth(decay_archdemon.health)
			monster:setHealth(decay_archdemon.maxHealth)
			monster:registerEvent("decay_archdemon_death_hp")
			monster:registerEvent("decay_archdemon_death")
			mType:isAttackable(true)
			monster:setMonsterLevel(decay_archdemon.monsterLevel)
			monster:setSkull(decay_archdemon.skull)
			mType:tier(decay_archdemon.tier)
			mType:items(decay_archdemon.items)
			BOSS_MONSTER_CONFIG[id] = {
				ready = 0,
				phase = 0,
				spells = {}
			}
		end
	end
end
mType:register(decay_archdemon)

local eventHealth = CreatureEvent("decay_archdemon_death_hp")

function eventHealth.onHealthChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
	if not creature or not attacker then
		return primaryDamage, primaryType, secondaryDamage, secondaryType
	end
	return primaryDamage, primaryType, secondaryDamage, secondaryType
end

local eventDeath = CreatureEvent("decay_archdemon_death")

function eventDeath.onDeath(creature, corpse, lasthitkiller, mostdamagekiller, lasthitunjustified, mostdamageunjustified)
	if not creature then
		return true
	end

	BOSS_MONSTER_CONFIG[creature:getId()] = nil
	return true
end

eventDeath:register()
eventHealth:register()
