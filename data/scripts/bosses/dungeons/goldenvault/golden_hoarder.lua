local mType = Game.createMonsterType("Golden Hoarder")

local golden_hoarder = {}
golden_hoarder.description = "Golden Hoarder"
golden_hoarder.experience = 2000
golden_hoarder.outfit = {
	lookType = 2665,
    lookHealthBar = 3
}

golden_hoarder.health = 30000
golden_hoarder.maxHealth = 30000
golden_hoarder.race = "boss"
golden_hoarder.corpse = 27196
golden_hoarder.speed = 300
golden_hoarder.skull = 0
golden_hoarder.tier = 1
golden_hoarder.items = "dungeonboss"
golden_hoarder.zone = 36
golden_hoarder.bestiary = 90

golden_hoarder.changeTarget = {
	interval = 4 * 1000,
	chance = 100
}

golden_hoarder.flags = {
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

golden_hoarder.attacks = {
	{
		name = "combat",
		type = COMBAT_PHYSICALDAMAGE,
		minDamage = -200,
		maxDamage = -200,
		range = 6,
		chance = 100,
		shootEffect = 209,
		interval = 2 * 1000
	},
}

golden_hoarder.elements = {
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

golden_hoarder.defenses = {
	defense = 1,
	armor = 1,
}

local SPELLS_CONFIG = {
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,
		damageRaw = 2000,
		damageType = COMBAT_PHYSICALDAMAGE,
		area = SPELL_WAVE_1,
		effect = 405,
		tileDistanceEffect = 209,
		wave = true,
		stay = true,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 200,

		damageRaw = 1000,
		damageType = COMBAT_HOLYDAMAGE,
		area = GOLDEN_HOARDER,
		effect = 278,
		bottomEffect = true,
		center = true,
		offsetX = 4,
		offsetY = 4,
		stay = true,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,
		multiDelay = 300,

		damageRaw = 1000,
		damageType = COMBAT_HOLYDAMAGE,
		effect = 449,
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
			monster:registerEvent("golden_hoarder_death_hp")
			monster:registerEvent("golden_hoarder_death")
			mType:isAttackable(true)
			monster:setSkull(0)
			monster:setMonsterLevel(25)
			mType:tier(golden_hoarder.tier)
			mType:items(golden_hoarder.items)
			BOSS_MONSTER_CONFIG[id] = {
				ready = 0,
				phase = 0,
				spells = {}
			}
		end
	end
end
mType:register(golden_hoarder)

local eventHealth = CreatureEvent("golden_hoarder_death_hp")

function eventHealth.onHealthChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
	if not creature or not attacker then
		return primaryDamage, primaryType, secondaryDamage, secondaryType
	end
	return primaryDamage, primaryType, secondaryDamage, secondaryType
end

local eventDeath = CreatureEvent("golden_hoarder_death")

function eventDeath.onDeath(creature, corpse, lasthitkiller, mostdamagekiller, lasthitunjustified, mostdamageunjustified)
	if not creature then
		return true
	end

	BOSS_MONSTER_CONFIG[creature:getId()] = nil
	return true
end

eventDeath:register()
eventHealth:register()
