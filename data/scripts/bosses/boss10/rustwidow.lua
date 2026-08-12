local mType = Game.createMonsterType("Rustwidow")

local rustwidow = {}
rustwidow.description = "Rustwidow"
rustwidow.experience = 2000
rustwidow.outfit = {
	lookType = 2653,
    lookHealthBar = 3
}

rustwidow.health = 25000000000
rustwidow.maxHealth = 25000000000
rustwidow.corpse = 27196
rustwidow.speed = 350
rustwidow.tier = 1
rustwidow.monsterLevel = 700
rustwidow.items = "titan"
rustwidow.skull = 0
rustwidow.bestiary = 149

rustwidow.changeTarget = {
	interval = 4 * 1000,
	chance = 100
}

rustwidow.flags = {
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

rustwidow.attacks = {
	{
		name = "combat",
		type = COMBAT_PHYSICALDAMAGE,
		minDamage = -200,
		maxDamage = -200,
		range = 6,
		effect = 1,
		chance = 100,
		shootEffect = 25,
		interval = 2 * 1000
	},
}

rustwidow.elements = {
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

rustwidow.defenses = {
	defense = 1,
	armor = 1,
}

local SPELLS_CONFIG = {
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,
		multiDelay = 500,

		damageRaw = 1000,
		damageType = COMBAT_EARTHDAMAGE,
		effect = 540,
		bottomEffect = false,
		center = true,
		offsetX = 1,
		offsetY = 1,
		onTarget = true,
		stay = true,
		jump_position = true,
		count = 3,
		area = SPELL_RANDOM_3SQM,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 200,

		damageRaw = 1000,
		damageType = COMBAT_PHYSICALDAMAGE,
		area = RUSTWIDOW,
		effect = 281,
		bottomEffect = true,
		center = true,
		offsetX = 4,
		offsetY = 4,
		stay = true,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,
		multiDelay = 100,

		damageRaw = 5000,
		damageType = COMBAT_EARTHDAMAGE,
		effect = 268,
		bottomEffect = false,
		center = true,
		stay = true,
		offsetX = 1,
		offsetY = 1,
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
			monster:setMaxHealth(rustwidow.health)
			monster:setHealth(rustwidow.maxHealth)
			monster:registerEvent("rustwidow_death_hp")
			monster:registerEvent("rustwidow_death")
			mType:isAttackable(true)
			monster:setMonsterLevel(rustwidow.monsterLevel)
			monster:setSkull(rustwidow.skull)
			mType:tier(rustwidow.tier)
			mType:items(rustwidow.items)
			BOSS_MONSTER_CONFIG[id] = {
				ready = 0,
				phase = 0,
				spells = {}
			}
		end
	end
end
mType:register(rustwidow)

local eventHealth = CreatureEvent("rustwidow_death_hp")

function eventHealth.onHealthChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
	if not creature or not attacker then
		return primaryDamage, primaryType, secondaryDamage, secondaryType
	end
	return primaryDamage, primaryType, secondaryDamage, secondaryType
end

local eventDeath = CreatureEvent("rustwidow_death")

function eventDeath.onDeath(creature, corpse, lasthitkiller, mostdamagekiller, lasthitunjustified, mostdamageunjustified)
	if not creature then
		return true
	end

	BOSS_MONSTER_CONFIG[creature:getId()] = nil
	return true
end

eventDeath:register()
eventHealth:register()
