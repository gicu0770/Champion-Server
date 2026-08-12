local mType = Game.createMonsterType("Sandfang")

local Sandfang = {}
Sandfang.description = "Sandfang"
Sandfang.experience = 2000
Sandfang.outfit = {
	lookType = 986,
    lookHealthBar = 2
}

Sandfang.health = 1300000
Sandfang.maxHealth = 1300000
Sandfang.corpse = 27196
Sandfang.speed = 300
Sandfang.tier = 1
Sandfang.monsterLevel = 50
Sandfang.items = "titan"
Sandfang.skull = 0
Sandfang.zone = 19
Sandfang.bestiary = 48

Sandfang.changeTarget = {
	interval = 4 * 1000,
	chance = 100
}

Sandfang.flags = {
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

Sandfang.attacks = {
	{
		name = "combat",
		type = COMBAT_EARTHDAMAGE,
		minDamage = -200,
		maxDamage = -200,
		range = 6,
		effect = 21,
		chance = 100,
		shootEffect = 15,
		interval = 2 * 1000
	},
}

Sandfang.elements = {
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

Sandfang.defenses = {
	defense = 1,
	armor = 1,
}

local SPELLS_CONFIG = {
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,

		damageRaw = 2500,
		damageType = COMBAT_PHYSICALDAMAGE,
		area = SPELL_CROSS_1,
		effect = 139,
		stay = true,
		wave = true,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,

		damageRaw = 2500,
		damageType = COMBAT_EARTHDAMAGE,
		area = RIFT_RANDOM,
		effect = 249,
		stay = true,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,
		multiDelay = 300,

		damageRaw = 2500,
		damageType = COMBAT_EARTHDAMAGE,
		effect = 249,
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
			monster:setMaxHealth(Sandfang.health)
			monster:setHealth(Sandfang.maxHealth)
			monster:registerEvent("Sandfang_death_hp")
			monster:registerEvent("Sandfang_death")
			mType:isAttackable(true)
			monster:setMonsterLevel(Sandfang.monsterLevel)
			monster:setSkull(Sandfang.skull)
			mType:tier(Sandfang.tier)
			mType:items(Sandfang.items)
			BOSS_MONSTER_CONFIG[id] = {
				ready = 0,
				phase = 0,
				spells = {}
			}
		end
	end
end
mType:register(Sandfang)

local eventHealth = CreatureEvent("Sandfang_death_hp")

function eventHealth.onHealthChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
	if not creature or not attacker then
		return primaryDamage, primaryType, secondaryDamage, secondaryType
	end
	return primaryDamage, primaryType, secondaryDamage, secondaryType
end

local eventDeath = CreatureEvent("Sandfang_death")

function eventDeath.onDeath(creature, corpse, lasthitkiller, mostdamagekiller, lasthitunjustified, mostdamageunjustified)
	if not creature then
		return true
	end

	BOSS_MONSTER_CONFIG[creature:getId()] = nil
	return true
end

eventDeath:register()
eventHealth:register()
