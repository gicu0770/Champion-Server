local mType = Game.createMonsterType("Voort")

local voort = {}
voort.description = "Voort"
voort.experience = 2000
voort.outfit = {
	lookType = 2244,
    lookHealthBar = 3
}

voort.health = 1000000000
voort.maxHealth = 1000000000
voort.race = "boss"
voort.corpse = 27196
voort.speed = 350
-- voort.script = "voort.lua"
voort.skull = 0
voort.tier = 1
voort.tierDungeon = 1
voort.items = "dungeonboss"
voort.bestiary = 131

voort.changeTarget = {
	interval = 4 * 1000,
	chance = 100
}

voort.flags = {
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

voort.attacks = {
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

voort.elements = {
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

voort.defenses = {
	defense = 1,
	armor = 1,
}

local SPELLS_CONFIG = {
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 200,
		damageRaw = 4500,
		damageType = COMBAT_FIREDAMAGE,
		area = VOORTFIRE_UE,
		effect = 629,
		bottomEffect = false,
		center = true,
		offsetX = 5,
		offsetY = 5,
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
		tileDistanceEffect = 251,
		wave = true,
		stay = true,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 250,
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
		multiDelay = 250,

		damageRaw = 5000,
		damageType = COMBAT_FIREDAMAGE,
		effect = 616,
		bottomEffect = false,
		center = true,
		offsetX = 6,
		offsetY = 6,
		random_size = 6,
		count = 6,
		area = VOORTMETEOR,
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
			monster:registerEvent("voort_death_hp")
			monster:registerEvent("voort_death")
			monster:registerEvent("SpellHealthChangeEvent")
			monster:registerEvent("UpgradeSystemHealth")
			monster:registerEvent("UpgradeSystemMana")
			monster:registerEvent("UpgradeSystemKill")
			monster:registerEvent("EliteAffixHP")
			monster:registerEvent("EliteAffixMANA")
			monster:registerEvent("UpgradeSystemDeath")
			monster:registerEvent("TaskDeath")
			mType:isAttackable(true)
			monster:setSkull(0)
			monster:setMonsterLevel(100)
			monster:setStorageValue(PlayerStorage.keyTier , voort.tierDungeon)
			mType:tier(voort.tier)
			mType:items(voort.items)
			BOSS_MONSTER_CONFIG[id] = {
				ready = 0,
				phase = 0,
				spells = {}
			}
		end
	end
end
mType:register(voort)

local eventHealth = CreatureEvent("voort_death_hp")

function eventHealth.onHealthChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
	if not creature or not attacker then
		return primaryDamage, primaryType, secondaryDamage, secondaryType
	end
	return primaryDamage, primaryType, secondaryDamage, secondaryType
end

local eventDeath = CreatureEvent("voort_death")

function eventDeath.onDeath(creature, corpse, lasthitkiller, mostdamagekiller, lasthitunjustified, mostdamageunjustified)
	if not creature then
		return true
	end

	BOSS_MONSTER_CONFIG[creature:getId()] = nil
	return true
end

eventDeath:register()
eventHealth:register()
