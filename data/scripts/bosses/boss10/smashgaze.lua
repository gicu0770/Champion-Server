local mType = Game.createMonsterType("Smashgaze")

local smashgaze = {}
smashgaze.description = "Smashgaze"
smashgaze.experience = 2000
smashgaze.outfit = {
	lookType = 1072,
    lookHealthBar = 3
}

smashgaze.health = 30000000
smashgaze.maxHealth = 30000000
smashgaze.corpse = 27196
smashgaze.speed = 300
smashgaze.tier = 1
smashgaze.monsterLevel = 95
smashgaze.items = "titan"
smashgaze.skull = 0
smashgaze.bestiary = 151

smashgaze.changeTarget = {
	interval = 4 * 1000,
	chance = 100
}

smashgaze.flags = {
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

smashgaze.attacks = {
	{
		name = "combat",
		type = COMBAT_PHYSICALDAMAGE,
		minDamage = -200,
		maxDamage = -200,
		range = 6,
		chance = 100,
		effect = 1,
		shootEffect = 154,
		interval = 2 * 1000
	},
}

smashgaze.elements = {
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

smashgaze.defenses = {
	defense = 1,
	armor = 1,
}

local SPELLS_CONFIG = {
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,

		damageRaw = 5000,
		damageType = COMBAT_PHYSICALDAMAGE,
		area = SPELL_PENTAGRAM,
		effect = 411,
		stay = true,
		wave = true,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,
		multiDelay = 100,

		damageRaw = 5000,
		damageType = COMBAT_DEATHDAMAGE,
		effect = 341,
		random_size = 6,
		count = 10,
		area = SPELL_3,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,
		multiDelay = 50,

		damageRaw = 5000,
		damageType = COMBAT_POISONDAMAGE,
		effect = 400,
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
			monster:setMaxHealth(smashgaze.health)
			monster:setHealth(smashgaze.maxHealth)
			monster:registerEvent("smashgaze_death_hp")
			monster:registerEvent("smashgaze_death")
			mType:isAttackable(true)
			monster:setMonsterLevel(smashgaze.monsterLevel)
			monster:setSkull(smashgaze.skull)
			mType:tier(smashgaze.tier)
			mType:items(smashgaze.items)
			BOSS_MONSTER_CONFIG[id] = {
				ready = 0,
				phase = 0,
				spells = {}
			}
		end
	end
end
mType:register(smashgaze)

local eventHealth = CreatureEvent("smashgaze_death_hp")

function eventHealth.onHealthChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
	if not creature or not attacker then
		return primaryDamage, primaryType, secondaryDamage, secondaryType
	end
	return primaryDamage, primaryType, secondaryDamage, secondaryType
end

local eventDeath = CreatureEvent("smashgaze_death")

function eventDeath.onDeath(creature, corpse, lasthitkiller, mostdamagekiller, lasthitunjustified, mostdamageunjustified)
	if not creature then
		return true
	end

	BOSS_MONSTER_CONFIG[creature:getId()] = nil
	return true
end

eventDeath:register()
eventHealth:register()
