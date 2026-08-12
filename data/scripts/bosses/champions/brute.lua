local mType = Game.createMonsterType("Brute")

local Brute = {}
Brute.description = "Brute"
Brute.experience = 2000
Brute.outfit = {
	lookType = 857,
    lookHealthBar = 2
}

Brute.health = 1000
Brute.maxHealth = 1000
Brute.corpse = 27196
Brute.speed = 300
Brute.tier = 1
Brute.monsterLevel = 25
Brute.items = "champion"
Brute.skull = 27
Brute.bestiary = 155

Brute.changeTarget = {
	interval = 4 * 1000,
	chance = 100
}

Brute.flags = {
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

Brute.attacks = {
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

Brute.elements = {
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

Brute.defenses = {
	defense = 1,
	armor = 1,
}

local SPELLS_CONFIG = {
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,

		damageRaw = 600,
		damageType = COMBAT_EARTHDAMAGE,
		area = BRUTECLOSE,
		effect = 249,
		stay = true,
		wave = true,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,

		damageRaw = 600,
		damageType = COMBAT_PHYSICALDAMAGE,
		area = BRUTEEXORI,
		effect = 242,
		stay = true,
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
			monster:setMaxHealth(Brute.health)
			monster:setHealth(Brute.maxHealth)
			monster:registerEvent("Brute_death_hp")
			monster:registerEvent("Brute_death")
			mType:isAttackable(true)
			monster:setMonsterLevel(Brute.monsterLevel)
			monster:setSkull(Brute.skull)
			mType:tier(Brute.tier)
			mType:items(Brute.items)
			BOSS_MONSTER_CONFIG[id] = {
				ready = 0,
				phase = 0,
				spells = {}
			}
		end
	end
end
mType:register(Brute)

local eventHealth = CreatureEvent("Brute_death_hp")

function eventHealth.onHealthChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
	if not creature or not attacker then
		return primaryDamage, primaryType, secondaryDamage, secondaryType
	end
	return primaryDamage, primaryType, secondaryDamage, secondaryType
end

local eventDeath = CreatureEvent("Brute_death")

function eventDeath.onDeath(creature, corpse, lasthitkiller, mostdamagekiller, lasthitunjustified, mostdamageunjustified)
	if not creature then
		return true
	end

	BOSS_MONSTER_CONFIG[creature:getId()] = nil
	return true
end

eventDeath:register()
eventHealth:register()
