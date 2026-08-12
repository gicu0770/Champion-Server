local mType = Game.createMonsterType("Pheonix")

local boss = {}
boss.description = "Pheonix"
boss.experience = 2000
boss.outfit = {
	lookType = 982,
    lookHealthBar = 3
}

boss.health = 50000
boss.maxHealth = 50000
boss.race = "boss"
boss.corpse = 27196
boss.speed = 350
boss.monsterLevel = 35
boss.skull = SKULL_WHITE
boss.tier = 1
boss.items = "dungeonboss"
boss.zone = 37
boss.bestiary = 94

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
		type = COMBAT_FIREDAMAGE,
		minDamage = -200,
		maxDamage = -200,
		range = 6,
		chance = 100,
		shootEffect = 205,
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
		interval = 2000,
		exhaust = 1000,
		startTime = 75,
		damageRaw = 1000,
		damageType = COMBAT_FIREDAMAGE,
		area = SPELL_PENTAGRAM,
		effect = 448,
		wave = true,
		stay = true,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 75,
		damageRaw = 1000,
		damageType = COMBAT_FIREDAMAGE,
		area = GRANDMASTERFALA,
		effect = 220,
		stay = true
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,
		multiDelay = 100,

		damageRaw = 2750,
		damageType = COMBAT_FIREDAMAGE,
		effect = 410,
		bottomEffect = false,
		center = true,
		offsetX = 1,
		offsetY = 1,
		random_size = 5,
		count = 15,
		area = SPELL_3,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,
		multiDelay = 200,
		damageRaw = 1000,
		damageType = COMBAT_FIREDAMAGE,
		effect = 488,
		bottomEffect = false,
		center = true,
		offsetX = 3,
		offsetY = 3,
		onTarget = true,
		stay = true,
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
			monster:registerEvent("Pheonix_death_hp")
			monster:registerEvent("Pheonix_death")
			mType:isAttackable(true)
			monster:setSkull(0)

			monster:setMonsterLevel(boss.monsterLevel)
			mType:tier(boss.tier)
			mType:items(boss.items)
			BOSS_MONSTER_CONFIG[id] = {
				ready = 0,
				phase = 0,
				spells = {},
			}
		end
	end
end
mType:register(boss)

local eventHealth = CreatureEvent("Pheonix_death_hp")

function eventHealth.onHealthChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
	if not creature or not attacker then
		return primaryDamage, primaryType, secondaryDamage, secondaryType
	end
	return primaryDamage, primaryType, secondaryDamage, secondaryType
end

local eventDeath = CreatureEvent("Pheonix_death")

function eventDeath.onDeath(creature, corpse, lasthitkiller, mostdamagekiller, lasthitunjustified, mostdamageunjustified)
	if not creature then
		return true
	end

	BOSS_MONSTER_CONFIG[creature:getId()] = nil
	return true
end

eventDeath:register()
eventHealth:register()
