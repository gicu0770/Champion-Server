local mType = Game.createMonsterType("Arbaziloth")

local arbaziloth = {}
arbaziloth.description = "Arbaziloth"
arbaziloth.experience = 2000
arbaziloth.outfit = {
	lookType = 2403,
    lookHealthBar = 3
}

arbaziloth.health = 500000
arbaziloth.maxHealth = 500000
arbaziloth.race = "boss"
arbaziloth.corpse = 27196
arbaziloth.speed = 350
arbaziloth.monsterLevel = 80
arbaziloth.skull = 0
arbaziloth.tier = 1
arbaziloth.items = "dungeonboss"
arbaziloth.zone = 44
arbaziloth.bestiary = 122

arbaziloth.changeTarget = {
	interval = 4 * 1000,
	chance = 100
}

arbaziloth.flags = {
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

arbaziloth.attacks = {
	{
		name = "combat",
		type = COMBAT_DEATHDAMAGE,
		minDamage = -200,
		maxDamage = -200,
		range = 6,
		chance = 100,
		shootEffect = 32,
		interval = 2 * 1000
	},
}

arbaziloth.elements = {
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

arbaziloth.defenses = {
	defense = 1,
	armor = 1,
}

local SPELLS_CONFIG = {
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 50,
		damageRaw = 4000,
		damageType = COMBAT_ENERGYDAMAGE,
		area = RIFTSHADE,
		effect = 572,
		stay = true,
		wave = true,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 75,
		damageRaw = 4000,
		damageType = COMBAT_ENERGYDAMAGE,
		effect = 571,
		area = SPELL_PENTAGRAM,
		wave = true,
		stay = true,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,
		multiDelay = 50,

		damageRaw = 2750,
		damageType = COMBAT_ENERGYDAMAGE,
		effect = 192,
		onTarget = true,
		count = 10,
		area = SPELL_RANDOM_1SQM,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,
		multiDelay = 100,

		damageRaw = 1000,
		damageType = COMBAT_ENERGYDAMAGE,
		effect = 543,
		bottomEffect = false,
		center = true,
		offsetX = 1,
		offsetY = 1,
		onTarget = true,
		stay = true,
		count = 5,
		area = SPELL_RANDOM_3SQM,
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
			monster:registerEvent("arbaziloth_death_hp")
			monster:registerEvent("arbaziloth_death")
			mType:isAttackable(true)
			monster:setSkull(arbaziloth.skull)
			monster:setMonsterLevel(arbaziloth.monsterLevel)
			mType:tier(arbaziloth.tier)
			mType:items(arbaziloth.items)
			BOSS_MONSTER_CONFIG[id] = {
				ready = 0,
				phase = 0,
				spells = {}
			}
		end
	end
end
mType:register(arbaziloth)

local eventHealth = CreatureEvent("arbaziloth_death_hp")

function eventHealth.onHealthChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
	if not creature or not attacker then
		return primaryDamage, primaryType, secondaryDamage, secondaryType
	end
	return primaryDamage, primaryType, secondaryDamage, secondaryType
end

local eventDeath = CreatureEvent("arbaziloth_death")

function eventDeath.onDeath(creature, corpse, lasthitkiller, mostdamagekiller, lasthitunjustified, mostdamageunjustified)
	if not creature then
		return true
	end

	BOSS_MONSTER_CONFIG[creature:getId()] = nil
	return true
end

eventDeath:register()
eventHealth:register()
