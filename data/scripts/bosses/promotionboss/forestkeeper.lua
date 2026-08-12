local mType = Game.createMonsterType("Forest Keeper")

local forestkeeper = {}
forestkeeper.description = "Forest Keeper"
forestkeeper.experience = 2000
forestkeeper.outfit = {
	lookType = 2395,
    lookHealthBar = 3
}

forestkeeper.health = 8000000
forestkeeper.maxHealth = 8000000
forestkeeper.race = "boss"
forestkeeper.corpse = 27196
forestkeeper.speed = 250
forestkeeper.monsterLevel = 65
forestkeeper.skull = 0
forestkeeper.tier = 1
forestkeeper.items = "dungeonboss"
forestkeeper.bestiary = 128

forestkeeper.changeTarget = {
	interval = 4 * 1000,
	chance = 100
}

forestkeeper.flags = {
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

forestkeeper.attacks = {
	{
		name = "combat",
		type = COMBAT_EARTHDAMAGE,
		minDamage = -200,
		maxDamage = -200,
		range = 5,
		effect = 384,
		shootEffect = 166,
		interval = 2 * 1000
	},
}

forestkeeper.elements = {
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

forestkeeper.defenses = {
	defense = 1,
	armor = 1,
}

local SPELLS_CONFIG = {
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 150,
		damageRaw = 2500,
		damageType = COMBAT_PHYSICALDAMAGE,
		area = URNA,
		effect = 62,
		wave = true,
		stay = true,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 75,
		damageRaw = 500,
		damageType = COMBAT_EARTHDAMAGE,
		area = SPELL_FALALEFT,
		effect = 400,
		wave = true,
		stay = true,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,
		multiDelay = 200,
		damageRaw = 2500,
		damageType = COMBAT_EARTHDAMAGE,
		effect = 509,
		onTarget = true,		
		count = 10,
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
			monster:registerEvent("forestkeeper_death_hp")
			monster:registerEvent("forestkeeper_death")
			mType:isAttackable(true)
			monster:setSkull(forestkeeper.skull)
			monster:setMonsterLevel(forestkeeper.monsterLevel)
			mType:tier(forestkeeper.tier)
			mType:items(forestkeeper.items)
			BOSS_MONSTER_CONFIG[id] = {
				ready = 0,
				phase = 0,
				spells = {}
			}
		end
	end
end
mType:register(forestkeeper)

local eventHealth = CreatureEvent("forestkeeper_death_hp")

function eventHealth.onHealthChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
	if not creature or not attacker then
		return primaryDamage, primaryType, secondaryDamage, secondaryType
	end
	return primaryDamage, primaryType, secondaryDamage, secondaryType
end

local eventDeath = CreatureEvent("forestkeeper_death")

function eventDeath.onDeath(creature, corpse, lasthitkiller, mostdamagekiller, lasthitunjustified, mostdamageunjustified)
	if not creature then
		return true
	end

	BOSS_MONSTER_CONFIG[creature:getId()] = nil
	return true
end

eventDeath:register()
eventHealth:register()
