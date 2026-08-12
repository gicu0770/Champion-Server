local mType = Game.createMonsterType("Rotburrow")

local Rotburrow = {}
Rotburrow.description = "Rotburrow"
Rotburrow.experience = 2000
Rotburrow.outfit = {
	lookType = 2060,
    lookHealthBar = 2
}

Rotburrow.health = 650000
Rotburrow.maxHealth = 650000
Rotburrow.corpse = 27196
Rotburrow.speed = 300
Rotburrow.tier = 1
Rotburrow.monsterLevel = 40
Rotburrow.items = "titan"
Rotburrow.skull = 0
Rotburrow.zone = 16
Rotburrow.bestiary = 41

Rotburrow.changeTarget = {
	interval = 4 * 1000,
	chance = 100
}

Rotburrow.flags = {
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

Rotburrow.attacks = {
	{
		name = "combat",
		type = COMBAT_EARTHDAMAGE,
		minDamage = -200,
		maxDamage = -200,
		range = 6,
		chance = 100,
		effect = 21,
		shootEffect = 148,
		interval = 2 * 1000
	},
}

Rotburrow.elements = {
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

Rotburrow.defenses = {
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
		area = ROTBURROW,
		effect = 62,
		stay = true,
		wave = true,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,
		multiDelay = 200,

		damageRaw = 2000,
		damageType = COMBAT_EARTHDAMAGE,
		effect = 196,
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
			monster:setMaxHealth(Rotburrow.health)
			monster:setHealth(Rotburrow.maxHealth)
			monster:registerEvent("Rotburrow_death_hp")
			monster:registerEvent("Rotburrow_death")
			mType:isAttackable(true)
			monster:setMonsterLevel(Rotburrow.monsterLevel)
			monster:setSkull(Rotburrow.skull)
			mType:tier(Rotburrow.tier)
			mType:items(Rotburrow.items)
			BOSS_MONSTER_CONFIG[id] = {
				ready = 0,
				phase = 0,
				spells = {}
			}
		end
	end
end
mType:register(Rotburrow)

local eventHealth = CreatureEvent("Rotburrow_death_hp")

function eventHealth.onHealthChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
	if not creature or not attacker then
		return primaryDamage, primaryType, secondaryDamage, secondaryType
	end
	return primaryDamage, primaryType, secondaryDamage, secondaryType
end

local eventDeath = CreatureEvent("Rotburrow_death")

function eventDeath.onDeath(creature, corpse, lasthitkiller, mostdamagekiller, lasthitunjustified, mostdamageunjustified)
	if not creature then
		return true
	end

--	Game.broadcastMessage("Rotburrow has been defeated!", MESSAGE_STATUS_WARNING)
	BOSS_MONSTER_CONFIG[creature:getId()] = nil
	return true
end

eventDeath:register()
eventHealth:register()
