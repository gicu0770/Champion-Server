local mType = Game.createMonsterType("Lava Golem")

local lavaGolem = {}
lavaGolem.description = "Lava Golem"
lavaGolem.experience = 2000
lavaGolem.outfit = {
	lookType = 491,
    lookHealthBar = 2
}

lavaGolem.health = 70000
lavaGolem.maxHealth = 70000
lavaGolem.corpse = 27196
lavaGolem.speed = 300
lavaGolem.tier = 1
lavaGolem.monsterLevel = 23
lavaGolem.items = "titan"
lavaGolem.skull = 0
lavaGolem.zone = 7
lavaGolem.bestiary = 20

lavaGolem.changeTarget = {
	interval = 4 * 1000,
	chance = 100
}

lavaGolem.flags = {
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

lavaGolem.attacks = {
	{
		name = "combat",
		type = COMBAT_FIREDAMAGE,
		minDamage = -200,
		maxDamage = -200,
		range = 6,
		effect = 448,
		chance = 100,
		shootEffect = 74,
		interval = 2 * 1000
	},
}

lavaGolem.elements = {
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

lavaGolem.defenses = {
	defense = 1,
	armor = 1,
}

local SPELLS_CONFIG = {
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,

		damageRaw = 500,
		damageType = COMBAT_FIREDAMAGE,
		area = LINE_1,
		effect = 7,
		stay = true,
		wave = true,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,

		damageRaw = 500,
		damageType = COMBAT_PHYSICALDAMAGE,
		area = AROUND,
		effect = 569,
		bottomEffect = true,
		center = true,
		offsetX = 3,
		offsetY = 3,
		stay = true,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,
		multiDelay = 200,

		damageRaw = 2500,
		damageType = COMBAT_FIREDAMAGE,
		effect = 97,
		onTarget = true,
		count = 3,
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
			monster:setMaxHealth(lavaGolem.health)
			monster:setHealth(lavaGolem.maxHealth)
			monster:registerEvent("LavaGolem_death_hp")
			monster:registerEvent("LavaGolem_death")
			mType:isAttackable(true)
			monster:setMonsterLevel(lavaGolem.monsterLevel)
			monster:setSkull(lavaGolem.skull)
			mType:tier(lavaGolem.tier)
			mType:items(lavaGolem.items)
			BOSS_MONSTER_CONFIG[id] = {
				ready = 0,
				phase = 0,
				spells = {}
			}
		end
	end
end
mType:register(lavaGolem)

local eventHealth = CreatureEvent("LavaGolem_death_hp")

function eventHealth.onHealthChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
	if not creature or not attacker then
		return primaryDamage, primaryType, secondaryDamage, secondaryType
	end
	return primaryDamage, primaryType, secondaryDamage, secondaryType
end

local eventDeath = CreatureEvent("LavaGolem_death")

function eventDeath.onDeath(creature, corpse, lasthitkiller, mostdamagekiller, lasthitunjustified, mostdamageunjustified)
	if not creature then
		return true
	end

	BOSS_MONSTER_CONFIG[creature:getId()] = nil
	return true
end

eventDeath:register()
eventHealth:register()
