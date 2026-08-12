local mType = Game.createMonsterType("Ascended Voort")

local Ascended_Voort = {}
Ascended_Voort.description = "Ascended Voort"
Ascended_Voort.experience = 2000
Ascended_Voort.outfit = {
	lookType = 2834,
    lookHealthBar = 3
}

Ascended_Voort.health = 200000000
Ascended_Voort.maxHealth = 200000000
Ascended_Voort.corpse = 27196
Ascended_Voort.speed = 300
-- Ascended_Voort.script = "Ascended_Voort.lua"
Ascended_Voort.skull = 0
Ascended_Voort.tier = 1
Ascended_Voort.items = "champion"
Ascended_Voort.bestiary = 131

Ascended_Voort.changeTarget = {
	interval = 4 * 1000,
	chance = 100
}

Ascended_Voort.flags = {
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

Ascended_Voort.attacks = {
	{
		name = "combat",
		type = COMBAT_FIREDAMAGE,
		minDamage = -200,
		maxDamage = -200,
		range = 5,
		chance = 100,
		shootEffect = 205,
		interval = 2 * 1000
	},
}

Ascended_Voort.elements = {
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

Ascended_Voort.defenses = {
	defense = 1,
	armor = 1,
}

local SPELLS_CONFIG = {
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,
		damageRaw = 4500,
		damageType = COMBAT_PHYSICALDAMAGE,
		area = URNA,
		effect = 447,
		stay = true,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,
		damageRaw = 4500,
		damageType = COMBAT_FIREDAMAGE,
		area = SPELL_PENTAGRAM,
		effect = 448,
		stay = true,
		wave = true,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,
		damageRaw = 1500,
		damageType = COMBAT_FIREDAMAGE,
		area = HYDRA_2XWAVE,
		effect = 220,
		wave = true,
		stay = true,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 150,
		multiDelay = 300,

		damageRaw = 1000,
		damageType = COMBAT_PHYSICALDAMAGE,
		effect = 520,
		bottomEffect = false,
		center = true,
		offsetX = 3,
		offsetY = 3,
		onTarget = true,
		stay = true,
		jump_position = true,
		count = 3,
		area = VOORT_JUMP,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,

		damageRaw = 1000,
		damageType = COMBAT_PHYSICALDAMAGE,
		area = VOORT_SMALLUE,
		effect = 564,
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
		multiDelay = 150,

		damageRaw = 5000,
		damageType = COMBAT_FIREDAMAGE,
		effect = 488,
		bottomEffect = false,
		center = true,
		stay = true,
		offsetX = 3,
		offsetY = 3,
		random_size = 5,
		count = 15,
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
			monster:registerEvent("Ascended_Voort_death_hp")
			monster:registerEvent("Ascended_Voort_death")
			monster:registerEvent("SpellHealthChangeEvent")
			monster:registerEvent("UpgradeSystemHealth")
			monster:registerEvent("UpgradeSystemMana")
			monster:registerEvent("UpgradeSystemKill")
			monster:registerEvent("EliteAffixHP")
			monster:registerEvent("EliteAffixMANA")
			monster:registerEvent("UpgradeSystemDeath")
			monster:registerEvent("TaskDeath")
			mType:isAttackable(true)
			monster:setSkull(15)
			monster:setMonsterLevel(120)
			mType:tier(Ascended_Voort.tier)
			mType:items(Ascended_Voort.items)
			BOSS_MONSTER_CONFIG[id] = {
				ready = 0,
				phase = 0,
				spells = {}
			}
		end
	end
end
mType:register(Ascended_Voort)

local eventHealth = CreatureEvent("Ascended_Voort_death_hp")

function eventHealth.onHealthChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
	if not creature or not attacker then
		return primaryDamage, primaryType, secondaryDamage, secondaryType
	end
	return primaryDamage, primaryType, secondaryDamage, secondaryType
end

local eventDeath = CreatureEvent("Ascended_Voort_death")

function eventDeath.onDeath(creature, corpse, lasthitkiller, mostdamagekiller, lasthitunjustified, mostdamageunjustified)
	if not creature then
		return true
	end

	BOSS_MONSTER_CONFIG[creature:getId()] = nil
	return true
end

eventDeath:register()
eventHealth:register()
