local mType = Game.createMonsterType("Emberlord")

local emberlord = {}
emberlord.description = "Emberlord"
emberlord.experience = 2000
emberlord.outfit = {
	lookType = 2399,
    lookHealthBar = 3
}

emberlord.health = 500000
emberlord.maxHealth = 500000
emberlord.race = "boss"
emberlord.corpse = 27196
emberlord.speed = 250
emberlord.monsterLevel = 25
emberlord.skull = 0
emberlord.tier = 1
emberlord.items = "dungeonboss"
emberlord.bestiary = 126

emberlord.changeTarget = {
	interval = 4 * 1000,
	chance = 100
}

emberlord.flags = {
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

emberlord.attacks = {
	{
		name = "combat",
		type = COMBAT_FIREDAMAGE,
		minDamage = -200,
		maxDamage = -200,
		range = 5,
		chance = 100,
		shootEffect = 95,
		interval = 2 * 1000
	},
}

emberlord.elements = {
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

emberlord.defenses = {
	defense = 1,
	armor = 1,
}

local SPELLS_CONFIG = {
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,
		damageRaw = 1,
		damageType = COMBAT_FIREDAMAGE,
		area = EMBERLORD,
		effect = 448,
		stay = true
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,
		damageRaw = 1,
		damageType = COMBAT_FIREDAMAGE,
		area = SPELL_FALALEFT,
		effect = 448,
		stay = true,
		wave = true,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 150,
		multiDelay = 200,

		damageRaw = 1,
		damageType = COMBAT_PHYSICALDAMAGE,
		effect = 178,
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
			monster:registerEvent("emberlord_death_hp")
			monster:registerEvent("emberlord_death")
			mType:isAttackable(true)
			monster:setSkull(emberlord.skull)
			monster:setMonsterLevel(emberlord.monsterLevel)
			mType:tier(emberlord.tier)
			mType:items(emberlord.items)
			BOSS_MONSTER_CONFIG[id] = {
				ready = 0,
				phase = 0,
				spells = {}
			}
		end
	end
end
mType:register(emberlord)

local eventHealth = CreatureEvent("emberlord_death_hp")

function eventHealth.onHealthChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
	if not creature or not attacker then
		return primaryDamage, primaryType, secondaryDamage, secondaryType
	end
	return primaryDamage, primaryType, secondaryDamage, secondaryType
end

local eventDeath = CreatureEvent("emberlord_death")

function eventDeath.onDeath(creature, corpse, lasthitkiller, mostdamagekiller, lasthitunjustified, mostdamageunjustified)
	if not creature then
		return true
	end

	BOSS_MONSTER_CONFIG[creature:getId()] = nil
	return true
end

eventDeath:register()
eventHealth:register()
