local mType = Game.createMonsterType("Tidal Overlord")

local tidal_overlord = {}
tidal_overlord.description = "Tidal Overlord"
tidal_overlord.experience = 2000
tidal_overlord.outfit = {
	lookType = 1977,
    lookHealthBar = 3
}

tidal_overlord.health = 500000
tidal_overlord.maxHealth = 500000
tidal_overlord.race = "boss"
tidal_overlord.corpse = 27196
tidal_overlord.speed = 350
tidal_overlord.monsterLevel = 80
tidal_overlord.skull = 0
tidal_overlord.tier = 1
tidal_overlord.items = "dungeonboss"
tidal_overlord.zone = 42
tidal_overlord.bestiary = 114

tidal_overlord.changeTarget = {
	interval = 4 * 1000,
	chance = 100
}

tidal_overlord.flags = {
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

tidal_overlord.attacks = {
	{
		name = "combat",
		type = COMBAT_PHYSICALDAMAGE,
		minDamage = -200,
		maxDamage = -200,
		range = 6,
		chance = 1000,
		shootEffect = 271,
		interval = 2 * 1000
	},
}

tidal_overlord.elements = {
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

tidal_overlord.defenses = {
	defense = 1,
	armor = 1,
}

local SPELLS_CONFIG = {
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,

		damageRaw = 1000,
		damageType = COMBAT_ICEDAMAGE,
		area = TIDALOVERLORD,
		effect = 279,
		bottomEffect = true,
		center = true,
		offsetX = 4,
		offsetY = 4,
		stay = true,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 75,
		damageRaw = 500,
		damageType = COMBAT_PHYSICALDAMAGE,
		area = SPELL_PENTAGRAM,
		effect = 525,
		stay = true,
		wave = true,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,
		multiDelay = 100,
		damageRaw = 3500,
		damageType = COMBAT_ICEDAMAGE,
		effect = 523,
		onTarget = true,

		count = 10,
		area = SPELL_RANDOM_1SQM,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,
		multiDelay = 100,
		damageRaw = 3500,
		damageType = COMBAT_ICEDAMAGE,
		effect = 538,
		bottomEffect = false,
		center = true,
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
			monster:registerEvent("tidal_overlord_death_hp")
			monster:registerEvent("tidal_overlord_death")
			mType:isAttackable(true)
			monster:setSkull(tidal_overlord.skull)
			monster:setMonsterLevel(tidal_overlord.monsterLevel)
			mType:tier(tidal_overlord.tier)
			mType:items(tidal_overlord.items)
			BOSS_MONSTER_CONFIG[id] = {
				ready = 0,
				phase = 0,
				spells = {}
			}
		end
	end
end
mType:register(tidal_overlord)

local eventHealth = CreatureEvent("tidal_overlord_death_hp")

function eventHealth.onHealthChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
	if not creature or not attacker then
		return primaryDamage, primaryType, secondaryDamage, secondaryType
	end
	return primaryDamage, primaryType, secondaryDamage, secondaryType
end

local eventDeath = CreatureEvent("tidal_overlord_death")

function eventDeath.onDeath(creature, corpse, lasthitkiller, mostdamagekiller, lasthitunjustified, mostdamageunjustified)
	if not creature then
		return true
	end

	BOSS_MONSTER_CONFIG[creature:getId()] = nil
	return true
end

eventDeath:register()
eventHealth:register()
