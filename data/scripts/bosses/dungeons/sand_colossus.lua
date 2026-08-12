local mType = Game.createMonsterType("Sand Colossus")

local sand_colossus = {}
sand_colossus.description = "Sand Colossus"
sand_colossus.experience = 2000
sand_colossus.outfit = {
	lookType = 2613,
    lookHealthBar = 3
}

sand_colossus.health = 500000
sand_colossus.maxHealth = 500000
sand_colossus.race = "boss"
sand_colossus.corpse = 27196
sand_colossus.speed = 350
sand_colossus.monsterLevel = 800
sand_colossus.skull = 0
sand_colossus.tier = 1
sand_colossus.items = "dungeonboss"
sand_colossus.bestiary = 144

sand_colossus.changeTarget = {
	interval = 4 * 1000,
	chance = 100
}

sand_colossus.flags = {
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

sand_colossus.attacks = {
	{
		name = "combat",
		type = COMBAT_HOLYDAMAGE,
		minDamage = -200,
		maxDamage = -200,
		range = 6,
		effect = 49,
		shootEffect = 215,
		interval = 2 * 1000
	},
}

sand_colossus.elements = {
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

sand_colossus.defenses = {
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
		area = SPELL_PENTAGRAM,
		effect = 490,
		wave = true,
		stay = true,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,
		multiDelay = 100,

		damageRaw = 5000,
		damageType = COMBAT_PHYSICALDAMAGE,
		effect = 573,
		bottomEffect = false,
		center = true,
		offsetX = 2,
		offsetY = 2,
		onTarget = true,
		count = 10,
		area = SPELL_3,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 50,
		damageRaw = 500,
		damageType = COMBAT_HOLYDAMAGE,
		area = ETHEREAL_CROSS,
		effect = 582,
		stay = true,
		wave = true,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 300,
		multiDelay = 500,

		damageRaw = 1000,
		damageType = COMBAT_PHYSICALDAMAGE,
		effect = 464,
		bottomEffect = false,
		center = true,
		offsetX = 3,
		offsetY = 3,
		onTarget = true,
		stay = true,
		jump_position = true,
		count = 3,
		area = VOORT_SMALLUE,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,
		multiDelay = 100,
		damageRaw = 3500,
		damageType = COMBAT_HOLYDAMAGE,
		effect = 182,
		random_size = 5,
		count = 25,
		area = SPELL_RANDOM_1SQM,
	}
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
			monster:registerEvent("sand_colossus_death_hp")
			monster:registerEvent("sand_colossus_death")
			mType:isAttackable(true)
			monster:setSkull(sand_colossus.skull)
			monster:setMonsterLevel(sand_colossus.monsterLevel)
			mType:tier(sand_colossus.tier)
			mType:items(sand_colossus.items)
			BOSS_MONSTER_CONFIG[id] = {
				ready = 0,
				phase = 0,
				spells = {}
			}
		end
	end
end
mType:register(sand_colossus)

local eventHealth = CreatureEvent("sand_colossus_death_hp")

function eventHealth.onHealthChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
	if not creature or not attacker then
		return primaryDamage, primaryType, secondaryDamage, secondaryType
	end
	return primaryDamage, primaryType, secondaryDamage, secondaryType
end

local eventDeath = CreatureEvent("sand_colossus_death")

function eventDeath.onDeath(creature, corpse, lasthitkiller, mostdamagekiller, lasthitunjustified, mostdamageunjustified)
	if not creature then
		return true
	end

	BOSS_MONSTER_CONFIG[creature:getId()] = nil
	return true
end

eventDeath:register()
eventHealth:register()
