local mType = Game.createMonsterType("Hellflayer")

local Hellflayer = {}
Hellflayer.description = "Hellflayer"
Hellflayer.experience = 2000
Hellflayer.outfit = {
	lookType = 856,
    lookHealthBar = 2
}

Hellflayer.health = 3500000
Hellflayer.maxHealth = 3500000
Hellflayer.corpse = 27196
Hellflayer.speed = 300
Hellflayer.tier = 1
Hellflayer.monsterLevel = 58
Hellflayer.items = "titan"
Hellflayer.skull = 0
Hellflayer.zone = 22
Hellflayer.bestiary = 55

Hellflayer.changeTarget = {
	interval = 4 * 1000,
	chance = 100
}

Hellflayer.flags = {
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

Hellflayer.attacks = {
	{
		name = "combat",
		type = COMBAT_EARTHDAMAGE,
		minDamage = -200,
		maxDamage = -200,
		range = 6,
		effect = 21,
		chance = 100,
		shootEffect = 166,
		interval = 2 * 1000
	},
}

Hellflayer.elements = {
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

Hellflayer.defenses = {
	defense = 1,
	armor = 1,
}

local SPELLS_CONFIG = {
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,
		damageRaw = 2500,
		damageType = COMBAT_EARTHDAMAGE,
		area = URNA,
		effect = 62,
		wave = true,
		stay = true,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,

		damageRaw = 3000,
		damageType = COMBAT_EARTHDAMAGE,
		area = SPELL_HELLFLAYER,
		effect = 222,
		stay = true,
		wave = true,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,
		multiDelay = 200,

		damageRaw = 3000,
		damageType = COMBAT_EARTHDAMAGE,
		effect = 55,
		onTarget = true,

		count = 10,
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
			monster:setMaxHealth(Hellflayer.health)
			monster:setHealth(Hellflayer.maxHealth)
			monster:registerEvent("Hellflayer_death_hp")
			monster:registerEvent("Hellflayer_death")
			mType:isAttackable(true)
			monster:setMonsterLevel(Hellflayer.monsterLevel)
			monster:setSkull(Hellflayer.skull)
			mType:tier(Hellflayer.tier)
			mType:items(Hellflayer.items)
			BOSS_MONSTER_CONFIG[id] = {
				ready = 0,
				phase = 0,
				spells = {}
			}
		end
	end
end
mType:register(Hellflayer)

local eventHealth = CreatureEvent("Hellflayer_death_hp")

function eventHealth.onHealthChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
	if not creature or not attacker then
		return primaryDamage, primaryType, secondaryDamage, secondaryType
	end
	return primaryDamage, primaryType, secondaryDamage, secondaryType
end

local eventDeath = CreatureEvent("Hellflayer_death")

function eventDeath.onDeath(creature, corpse, lasthitkiller, mostdamagekiller, lasthitunjustified, mostdamageunjustified)
	if not creature then
		return true
	end

	BOSS_MONSTER_CONFIG[creature:getId()] = nil
	return true
end

eventDeath:register()
eventHealth:register()
