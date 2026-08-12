local mType = Game.createMonsterType("Animated Feather")

local animatedfeather = {}
animatedfeather.description = "Animated Feather"
animatedfeather.experience = 2000
animatedfeather.outfit = {
	lookType = 1027,
    lookHealthBar = 3
}

animatedfeather.health = 2500000
animatedfeather.maxHealth = 2500000
animatedfeather.corpse = 27196
animatedfeather.speed = 300
animatedfeather.tier = 1
animatedfeather.monsterLevel = 50
animatedfeather.items = "titan"
animatedfeather.skull = 0
animatedfeather.bestiary = 142

animatedfeather.changeTarget = {
	interval = 4 * 1000,
	chance = 100
}

animatedfeather.flags = {
	summonable = false,
	attackable = true,
	hostile = true,
	convinceable = false,
	illusionable = false,
	pushable = false,
	canPushItems = true,
	canPushCreatures = true,
	unique = true,
	targetDistance = 2,
	staticAttackChance = 70
}

animatedfeather.attacks = {
	{
		name = "combat",
		type = COMBAT_ENERGYDAMAGE,
		minDamage = -200,
		maxDamage = -200,
		range = 6,
		effect = 48,
		chance = 100,
		shootEffect = 98,
		interval = 2 * 1000
	},
}

animatedfeather.elements = {
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

animatedfeather.defenses = {
	defense = 1,
	armor = 1,
}

local SPELLS_CONFIG = {
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,

		damageRaw = 1500,
		damageType = COMBAT_ENERGYDAMAGE,
		area = SPELL_TRIPLE_WAVE,
		effect = 192,
		stay = true,
		wave = true,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,

		damageRaw = 1500,
		damageType = COMBAT_ICEDAMAGE,
		area = SPELL_WAVE_1,
		effect = 245,
		stay = true,
		wave = true,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 200,
		multiDelay = 300,

		damageRaw = 1500,
		damageType = COMBAT_HOLYDAMAGE,
		effect = 491,
		onTarget = true,
		count = 3,
		area = ANIMATED_FEATHER_UE,
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
			monster:setMaxHealth(animatedfeather.health)
			monster:setHealth(animatedfeather.maxHealth)
			monster:registerEvent("animatedfeather_death_hp")
			monster:registerEvent("animatedfeather_death")
			mType:isAttackable(true)
			monster:setMonsterLevel(animatedfeather.monsterLevel)
			monster:setSkull(animatedfeather.skull)
			mType:tier(animatedfeather.tier)
			mType:items(animatedfeather.items)
			BOSS_MONSTER_CONFIG[id] = {
				ready = 0,
				phase = 0,
				spells = {}
			}
		end
	end
end
mType:register(animatedfeather)

local eventHealth = CreatureEvent("animatedfeather_death_hp")

function eventHealth.onHealthChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
	if not creature or not attacker then
		return primaryDamage, primaryType, secondaryDamage, secondaryType
	end
	return primaryDamage, primaryType, secondaryDamage, secondaryType
end

local eventDeath = CreatureEvent("animatedfeather_death")

function eventDeath.onDeath(creature, corpse, lasthitkiller, mostdamagekiller, lasthitunjustified, mostdamageunjustified)
	if not creature then
		return true
	end

	BOSS_MONSTER_CONFIG[creature:getId()] = nil
	return true
end

eventDeath:register()
eventHealth:register()
