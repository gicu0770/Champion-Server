local mType = Game.createMonsterType("Grimdelver")

local Grimdelver = {}
Grimdelver.description = "Grimdelver"
Grimdelver.experience = 2000
Grimdelver.outfit = {
	lookType = 2477,
    lookHealthBar = 2
}

Grimdelver.health = 5000000
Grimdelver.maxHealth = 5000000
Grimdelver.corpse = 27196
Grimdelver.speed = 300
Grimdelver.tier = 1
Grimdelver.monsterLevel = 67
Grimdelver.items = "titan"
Grimdelver.skull = 0
Grimdelver.zone = 25
Grimdelver.bestiary = 62

Grimdelver.changeTarget = {
	interval = 4 * 1000,
	chance = 100
}

Grimdelver.flags = {
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

Grimdelver.attacks = {
	{
		name = "combat",
		type = COMBAT_PHYSICALDAMAGE,
		minDamage = -200,
		maxDamage = -200,
		range = 6,
		chance = 100,
		shootEffect = 27,
		interval = 2 * 1000
	},
}

Grimdelver.elements = {
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

Grimdelver.defenses = {
	defense = 1,
	armor = 1,
}

local SPELLS_CONFIG = {
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 75,

		damageRaw = 3500,
		damageType = COMBAT_PHYSICALDAMAGE,
		area = GRIMDELVER,
		effect = 338,
		stay = true,
		wave = true,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,

		damageRaw = 3500,
		damageType = COMBAT_PHYSICALDAMAGE,
		area = GRIMDELVERUE,
		effect = 338,
		stay = true,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,
		multiDelay = 200,

		damageRaw = 3000,
		damageType = COMBAT_EARTHDAMAGE,
		effect = 511,
		onTarget = true,

		count = 5,
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
			monster:setMaxHealth(Grimdelver.health)
			monster:setHealth(Grimdelver.maxHealth)
			monster:registerEvent("Grimdelver_death_hp")
			monster:registerEvent("Grimdelver_death")
			mType:isAttackable(true)
			monster:setMonsterLevel(Grimdelver.monsterLevel)
			monster:setSkull(Grimdelver.skull)
			mType:tier(Grimdelver.tier)
			mType:items(Grimdelver.items)
			BOSS_MONSTER_CONFIG[id] = {
				ready = 0,
				phase = 0,
				spells = {}
			}
		end
	end
end
mType:register(Grimdelver)

local eventHealth = CreatureEvent("Grimdelver_death_hp")

function eventHealth.onHealthChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
	if not creature or not attacker then
		return primaryDamage, primaryType, secondaryDamage, secondaryType
	end
	return primaryDamage, primaryType, secondaryDamage, secondaryType
end

local eventDeath = CreatureEvent("Grimdelver_death")

function eventDeath.onDeath(creature, corpse, lasthitkiller, mostdamagekiller, lasthitunjustified, mostdamageunjustified)
	if not creature then
		return true
	end

	BOSS_MONSTER_CONFIG[creature:getId()] = nil
	return true
end

eventDeath:register()
eventHealth:register()
