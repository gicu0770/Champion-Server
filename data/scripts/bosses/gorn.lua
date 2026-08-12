local mType = Game.createMonsterType("Gorn")

local boss = {}
boss.description = "Gorn"
boss.experience = 2000
boss.outfit = {
	lookType = 2071,
    lookHealthBar = 3
}

boss.health = 50000
boss.maxHealth = 50000
boss.race = "boss"
boss.corpse = 27196
boss.speed = 300
boss.monsterLevel = 35
boss.skull = SKULL_WHITE
boss.tier = 1
boss.items = "worldboss"

boss.changeTarget = {
	interval = 4 * 1000,
	chance = 100
}

boss.flags = {
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

boss.attacks = {
	{
		name = "combat",
		type = COMBAT_PHYSICALDAMAGE,
		minDamage = -200,
		maxDamage = -200,
		range = 1,
		effect = 1,
		shootEffect = 27,
		interval = 2 * 1000
	},
}

boss.elements = {
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

boss.defenses = {
	defense = 1,
	armor = 1,
}

local SPELLS_CONFIG = {
	{
		interval = 3000,
		exhaust = 1500,
		startTime = 50,
		damageRaw = 470,
		damageType = COMBAT_PHYSICALDAMAGE,
		area = GORNWAVE,
		effect = 242,
		wave = true,
		stay = true,
	},
	{
		interval = 3000,
		exhaust = 1500,
		startTime = 200,
		damageRaw = 1000,
		damageType = COMBAT_PHYSICALDAMAGE,
		area = SPELL_PENTAGRAM,
		effect = 408,
		wave = true,
		stay = true,
	},
	{
		interval = 3000,
		exhaust = 1500,
		startTime = 100,
		multiDelay = 60,
		damageRaw = 1000,
		damageType = COMBAT_PHYSICALDAMAGE,
		effect = 490,
		stay = true,
		random_size = 8,
		count = 30,
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
			monster:registerEvent("Gorn_death_hp")
			monster:registerEvent("Gorn_death")
			mType:isAttackable(true)
			monster:setSkull(27)
			monster:setMonsterLevel(boss.monsterLevel)
			mType:tier(boss.tier)
			mType:items(boss.items)
			BOSS_MONSTER_CONFIG[id] = {
				ready = 0,
				phase = 0,
				spells = {}
			}
		end
	end
end
mType:register(boss)

local eventHealth = CreatureEvent("Gorn_death_hp")

function eventHealth.onHealthChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
	if not creature or not attacker then
		return primaryDamage, primaryType, secondaryDamage, secondaryType
	end
	return primaryDamage, primaryType, secondaryDamage, secondaryType
end

local eventDeath = CreatureEvent("Gorn_death")

function eventDeath.onDeath(creature, corpse, lasthitkiller, mostdamagekiller, lasthitunjustified, mostdamageunjustified)
	if not creature then
		return true
	end

	BOSS_MONSTER_CONFIG[creature:getId()] = nil
	return true
end

eventDeath:register()
eventHealth:register()
