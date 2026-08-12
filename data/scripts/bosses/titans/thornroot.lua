local mType = Game.createMonsterType("Thornroot")

local Thornroot = {}
Thornroot.description = "Thornroot"
Thornroot.experience = 2000
Thornroot.outfit = {
	lookType = 2410,
    lookHealthBar = 2
}

Thornroot.health = 180000000
Thornroot.maxHealth = 180000000
Thornroot.corpse = 27196
Thornroot.speed = 300
Thornroot.tier = 1
Thornroot.monsterLevel = 97
Thornroot.items = "titan"
Thornroot.skull = 0
Thornroot.zone = 34
Thornroot.bestiary = 83

Thornroot.changeTarget = {
	interval = 4 * 1000,
	chance = 100
}

Thornroot.flags = {
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

Thornroot.attacks = {
	{
		name = "combat",
		type = COMBAT_PHYSICALDAMAGE,
		minDamage = -200,
		maxDamage = -200,
		chance = 100,
		range = 6,
		shootEffect = 243,
		interval = 2 * 1000
	},
}

Thornroot.elements = {
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

Thornroot.defenses = {
	defense = 1,
	armor = 1,
}

local SPELLS_CONFIG = {
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 200,
		multiDelay = 200,

		damageRaw = 600,
		damageType = COMBAT_EARTHDAMAGE,
		effect = 540,
		bottomEffect = false,
		center = true,
		offsetX = 1,
		offsetY = 1,
		onTarget = true,
		count = 5,
		area = SPELL_3,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,
		multiDelay = 150,

		damageRaw = 5000,
		damageType = COMBAT_EARTHDAMAGE,
		effect = 619,
		bottomEffect = false,
		center = true,
		offsetX = 6,
		offsetY = 6,
		random_size = 6,
		count = 6,
		area = SPELL_3,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,

		damageRaw = 400,
		damageType = COMBAT_PHYSICALDAMAGE,
		area = THORNROOTDOUBLEUE,
		effect = 682,
		bottomEffect = false,
		center = true,
		offsetX = 4,
		offsetY = 4,
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
			monster:setMaxHealth(Thornroot.health)
			monster:setHealth(Thornroot.maxHealth)
			monster:registerEvent("Thornroot_death_hp")
			monster:registerEvent("Thornroot_death")
			monster:setMonsterLevel(Thornroot.monsterLevel)
			monster:setSkull(Thornroot.skull)
			mType:tier(Thornroot.tier)
			mType:items(Thornroot.items)
			BOSS_MONSTER_CONFIG[id] = {
				ready = 0,
				phase = 0,
				spells = {}
			}
		end
	end
end
mType:register(Thornroot)

local eventHealth = CreatureEvent("Thornroot_death_hp")
function eventHealth.onHealthChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
	if not creature or not attacker then
		return primaryDamage, primaryType, secondaryDamage, secondaryType
	end
	return primaryDamage, primaryType, secondaryDamage, secondaryType
end

local eventDeath = CreatureEvent("Thornroot_death")
function eventDeath.onDeath(creature, corpse, lasthitkiller, mostdamagekiller, lasthitunjustified, mostdamageunjustified)
	if not creature then
		return true
	end

	BOSS_MONSTER_CONFIG[creature:getId()] = nil
	return true
end

eventDeath:register()
eventHealth:register()
