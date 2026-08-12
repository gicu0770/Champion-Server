local mType = Game.createMonsterType("Yeti")

local Yeti = {}
Yeti.description = "Yeti"
Yeti.experience = 2000
Yeti.outfit = {
	lookType = 2411,
    lookHealthBar = 2
}

Yeti.health = 50000000
Yeti.maxHealth = 50000000
Yeti.corpse = 27196
Yeti.speed = 300
Yeti.tier = 1
Yeti.monsterLevel = 82
Yeti.items = "titan"
Yeti.skull = 0
Yeti.zone = 30
Yeti.bestiary = 73

Yeti.changeTarget = {
	interval = 4 * 1000,
	chance = 100
}

Yeti.flags = {
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

Yeti.attacks = {
	{
		name = "combat",
		type = COMBAT_ICEDAMAGE,
		minDamage = -200,
		maxDamage = -200,
		range = 6,
		chance = 100,
		shootEffect = 29,
		interval = 2 * 1000
	},
}

Yeti.elements = {
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

Yeti.defenses = {
	defense = 1,
	armor = 1,
}

local SPELLS_CONFIG = {
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,
		multiDelay = 100,

		damageRaw = 4500,
		damageType = COMBAT_ICEDAMAGE,
		effect = 407,
		onTarget = true,
		count = 10,
		area = SPELL_RANDOM_1SQM,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 75,

		damageRaw = 3000,
		damageType = COMBAT_ICEDAMAGE,
		area = SPELL_HELLFLAYER,
		effect = 475,
		stay = true,
		wave = true,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,
		damageRaw = 4500,
		damageType = COMBAT_ICEDAMAGE,
		area = URNA,
		effect = 177,
		stay = true,
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
			monster:setMaxHealth(Yeti.health)
			monster:setHealth(Yeti.maxHealth)
			monster:registerEvent("Yeti_death_hp")
			monster:registerEvent("Yeti_death")
			monster:setMonsterLevel(Yeti.monsterLevel)
			monster:setSkull(Yeti.skull)
			mType:tier(Yeti.tier)
			mType:items(Yeti.items)
			BOSS_MONSTER_CONFIG[id] = {
				ready = 0,
				phase = 0,
				spells = {}
			}
		end
	end
end
mType:register(Yeti)

local eventHealth = CreatureEvent("Yeti_death_hp")
function eventHealth.onHealthChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
	if not creature or not attacker then
		return primaryDamage, primaryType, secondaryDamage, secondaryType
	end
	return primaryDamage, primaryType, secondaryDamage, secondaryType
end

local eventDeath = CreatureEvent("Yeti_death")
function eventDeath.onDeath(creature, corpse, lasthitkiller, mostdamagekiller, lasthitunjustified, mostdamageunjustified)
	if not creature then
		return true
	end

	BOSS_MONSTER_CONFIG[creature:getId()] = nil
	return true
end

eventDeath:register()
eventHealth:register()
