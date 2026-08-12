local mType = Game.createMonsterType("Blackfang Archer")

local blackfang_archer = {}
blackfang_archer.description = "Blackfang Archer"
blackfang_archer.experience = 2000
blackfang_archer.outfit = {
	lookType = 2404,
    lookHealthBar = 3
}

blackfang_archer.health = 500000
blackfang_archer.maxHealth = 500000
blackfang_archer.race = "boss"
blackfang_archer.corpse = 27196
blackfang_archer.speed = 300
blackfang_archer.monsterLevel = 60
-- blackfang_archer.script = "blackfang_archer.lua"
blackfang_archer.skull = SKULL_WHITE
blackfang_archer.tier = 1
blackfang_archer.items = "uberboss"
blackfang_archer.bestiary = 137

blackfang_archer.changeTarget = {
	interval = 4 * 1000,
	chance = 100
}

blackfang_archer.flags = {
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

blackfang_archer.attacks = {
	{
		name = "combat",
		type = COMBAT_PHYSICALDAMAGE,
		minDamage = -200,
		maxDamage = -200,
		range = 6,
		chance = 100,
		shootEffect = 201,
		interval = 2 * 1000
	},
}

blackfang_archer.elements = {
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

blackfang_archer.defenses = {
	defense = 1,
	armor = 1,
}

local SPELLS_CONFIG = {
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 75,
		damageRaw = 2000,
		damageType = COMBAT_PHYSICALDAMAGE,
		area = BLACKFANGARCHER,
		effect = 63,
		stay = true,
		tileDistanceEffect = 102,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 75,
		damageRaw = 2000,
		damageType = COMBAT_PHYSICALDAMAGE,
		area = SPELL_WAVE_1,
		effect = 3,
		tileDistanceEffect = 102,
		wave = true,
		stay = true,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,
		multiDelay = 50,
		damageRaw = 2000,
		damageType = COMBAT_PHYSICALDAMAGE,
		effect = 498,
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
			monster:registerEvent("blackfang_archer_death_hp")
			monster:registerEvent("blackfang_archer_death")
			mType:isAttackable(true)
			monster:setSkull(0)
			monster:setMonsterLevel(blackfang_archer.monsterLevel)
			mType:tier(blackfang_archer.tier)
			mType:items(blackfang_archer.items)
			BOSS_MONSTER_CONFIG[id] = {
				ready = 0,
				phase = 0,
				spells = {}
			}
		end
	end
end
mType:register(blackfang_archer)

local eventHealth = CreatureEvent("blackfang_archer_death_hp")

function eventHealth.onHealthChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
	if not creature or not attacker then
		return primaryDamage, primaryType, secondaryDamage, secondaryType
	end
	return primaryDamage, primaryType, secondaryDamage, secondaryType
end

local eventDeath = CreatureEvent("blackfang_archer_death")

function eventDeath.onDeath(creature, corpse, lasthitkiller, mostdamagekiller, lasthitunjustified, mostdamageunjustified)
	if not creature then
		return true
	end

	BOSS_MONSTER_CONFIG[creature:getId()] = nil
	return true
end

eventDeath:register()
eventHealth:register()
