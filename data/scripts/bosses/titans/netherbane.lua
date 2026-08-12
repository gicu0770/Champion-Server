local mType = Game.createMonsterType("Netherbane")

local netherbane = {}
netherbane.description = "Netherbane"
netherbane.experience = 2000
netherbane.outfit = {
	lookType = 1962,
    lookHealthBar = 2
}

netherbane.health = 250000
netherbane.maxHealth = 250000
netherbane.corpse = 27196
netherbane.speed = 300
netherbane.tier = 1
netherbane.monsterLevel = 29
netherbane.items = "titan"
netherbane.skull = 0
netherbane.zone = 10
netherbane.bestiary = 27

netherbane.changeTarget = {
	interval = 4 * 1000,
	chance = 100
}

netherbane.flags = {
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

netherbane.attacks = {
	{
		name = "combat",
		type = COMBAT_ENERGYDAMAGE,
		minDamage = -200,
		maxDamage = -200,
		chance = 100,
		range = 6,
		effect = 48,
		shootEffect = 204,
		interval = 2 * 1000
	},
}

netherbane.elements = {
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

netherbane.defenses = {
	defense = 1,
	armor = 1,
}

local SPELLS_CONFIG = {
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 50,

		damageRaw = 1000,
		damageType = COMBAT_ENERGYDAMAGE,
		area = WAVE_NETHERBANEE,
		effect = 109,
		stay = true,
		wave = true,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,

		damageRaw = 2750,
		damageType = COMBAT_DEATHDAMAGE,
		effect = 200,
		area = NETHER_BOMBB,
		stay = true,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,
		multiDelay = 200,

		damageRaw = 2500,
		damageType = COMBAT_ENERGYDAMAGE,
		effect = 109,
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
			monster:setMaxHealth(netherbane.health)
			monster:setHealth(netherbane.maxHealth)
			monster:registerEvent("netherbane_death_hp")
			monster:registerEvent("netherbane_death")
			mType:isAttackable(true)
			monster:setMonsterLevel(netherbane.monsterLevel)
			monster:setSkull(netherbane.skull)
			mType:tier(netherbane.tier)
			mType:items(netherbane.items)
			BOSS_MONSTER_CONFIG[id] = {
				ready = 0,
				phase = 0,
				spells = {}
			}
		end
	end
end
mType:register(netherbane)

local eventHealth = CreatureEvent("netherbane_death_hp")

function eventHealth.onHealthChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
	if not creature or not attacker then
		return primaryDamage, primaryType, secondaryDamage, secondaryType
	end
	return primaryDamage, primaryType, secondaryDamage, secondaryType
end

local eventDeath = CreatureEvent("netherbane_death")

function eventDeath.onDeath(creature, corpse, lasthitkiller, mostdamagekiller, lasthitunjustified, mostdamageunjustified)
	if not creature then
		return true
	end

	BOSS_MONSTER_CONFIG[creature:getId()] = nil
	return true
end

eventDeath:register()
eventHealth:register()
