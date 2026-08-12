local mType = Game.createMonsterType("Glacier Warlord")

local glacier_warlord = {}
glacier_warlord.description = "Glacier Warlord"
glacier_warlord.experience = 2000
glacier_warlord.outfit = {
	lookType = 2362,
    lookHealthBar = 3
}

glacier_warlord.health = 1000000
glacier_warlord.maxHealth = 1000000
glacier_warlord.race = "boss"
glacier_warlord.corpse = 27196
glacier_warlord.speed = 350
glacier_warlord.monsterLevel = 90
glacier_warlord.skull = 0
glacier_warlord.tier = 1
glacier_warlord.items = "dungeonboss"
glacier_warlord.zone = 41
glacier_warlord.bestiary = 110

glacier_warlord.changeTarget = {
	interval = 4 * 1000,
	chance = 100
}

glacier_warlord.flags = {
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

glacier_warlord.attacks = {
	{
		name = "combat",
		type = COMBAT_ICEDAMAGE,
		minDamage = -200,
		maxDamage = -200,
		range = 6,
		effect = 532,
		chance = 100,
		interval = 2 * 1000
	},
}

glacier_warlord.elements = {
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

glacier_warlord.defenses = {
	defense = 1,
	armor = 1,
}

local SPELLS_CONFIG = {
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 200,
		damageRaw = 3500,
		damageType = COMBAT_ICEDAMAGE,
		area = SPELL_DROP,
		effect = 523,
		stay = true,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,
		multiDelay = 100,

		damageRaw = 1000,
		damageType = COMBAT_ICEDAMAGE,
		effect = 534,
		bottomEffect = true,
		center = true,
		offsetX = 1,
		offsetY = 1,
		onTarget = true,
		stay = true,
		count = 5,
		area = SPELL_RANDOM_3SQM,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,
		multiDelay = 100,

		damageRaw = 2750,
		damageType = COMBAT_ICEDAMAGE,
		effect = 528,
		onTarget = true,
		count = 10,
		area = SPELL_RANDOM_1SQM,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,
		multiDelay = 100,

		damageRaw = 5000,
		damageType = COMBAT_ICEDAMAGE,
		effect = 452,
		bottomEffect = false,
		center = true,
		offsetX = 2,
		offsetY = 2,
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
			monster:registerEvent("glacier_warlord_death_hp")
			monster:registerEvent("glacier_warlord_death")
			mType:isAttackable(true)
			monster:setSkull(glacier_warlord.skull)
			monster:setMonsterLevel(glacier_warlord.monsterLevel)
			mType:tier(glacier_warlord.tier)
			mType:items(glacier_warlord.items)
			BOSS_MONSTER_CONFIG[id] = {
				ready = 0,
				phase = 0,
				spells = {}
			}
		end
	end
end
mType:register(glacier_warlord)

local eventHealth = CreatureEvent("glacier_warlord_death_hp")

function eventHealth.onHealthChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
	if not creature or not attacker then
		return primaryDamage, primaryType, secondaryDamage, secondaryType
	end
	return primaryDamage, primaryType, secondaryDamage, secondaryType
end

local eventDeath = CreatureEvent("glacier_warlord_death")

function eventDeath.onDeath(creature, corpse, lasthitkiller, mostdamagekiller, lasthitunjustified, mostdamageunjustified)
	if not creature then
		return true
	end

	BOSS_MONSTER_CONFIG[creature:getId()] = nil
	return true
end

eventDeath:register()
eventHealth:register()
