local mType = Game.createMonsterType("Naturlord")

local naturlord = {}
naturlord.description = "Naturlord"
naturlord.experience = 2000
naturlord.outfit = {
	lookType = 2398,
    lookHealthBar = 3
}

naturlord.health = 30000000
naturlord.maxHealth = 30000000
naturlord.race = "boss"
naturlord.corpse = 27196
naturlord.speed = 300
naturlord.monsterLevel = 80
naturlord.skull = 0
naturlord.tier = 1
naturlord.items = "dungeonboss"
naturlord.bestiary = 130

naturlord.changeTarget = {
	interval = 4 * 1000,
	chance = 100
}

naturlord.flags = {
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

naturlord.attacks = {
	{
		name = "combat",
		type = COMBAT_EARTHDAMAGE,
		minDamage = -200,
		maxDamage = -200,
		range = 5,
		chance = 100,
		shootEffect = 166,
		interval = 2 * 1000
	},
}

naturlord.elements = {
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

naturlord.defenses = {
	defense = 1,
	armor = 1,
}

local SPELLS_CONFIG = {
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 75,

		damageRaw = 800,
		damageType = COMBAT_EARTHDAMAGE,
		area = SPELL_FALAALLPOS,
		effect = 55,
		stay = true,
		wave = true,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 75,

		damageRaw = 800,
		damageType = COMBAT_PHYSICALDAMAGE,
		area = SPELL_FALALEFT,
		effect = 45,
		stay = true,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,
		multiDelay = 200,
		damageRaw = 3500,
		damageType = COMBAT_PHYSICALDAMAGE,
		effect = 62,
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
			monster:registerEvent("naturlord_death_hp")
			monster:registerEvent("naturlord_death")
			mType:isAttackable(true)
			monster:setSkull(naturlord.skull)
			monster:setMonsterLevel(naturlord.monsterLevel)
			mType:tier(naturlord.tier)
			mType:items(naturlord.items)
			BOSS_MONSTER_CONFIG[id] = {
				ready = 0,
				phase = 0,
				spells = {}
			}
		end
	end
end
mType:register(naturlord)

local eventHealth = CreatureEvent("naturlord_death_hp")

function eventHealth.onHealthChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
	if not creature or not attacker then
		return primaryDamage, primaryType, secondaryDamage, secondaryType
	end
	return primaryDamage, primaryType, secondaryDamage, secondaryType
end

local eventDeath = CreatureEvent("naturlord_death")

function eventDeath.onDeath(creature, corpse, lasthitkiller, mostdamagekiller, lasthitunjustified, mostdamageunjustified)
	if not creature then
		return true
	end

	BOSS_MONSTER_CONFIG[creature:getId()] = nil
	return true
end

eventDeath:register()
eventHealth:register()
