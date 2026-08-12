local mType = Game.createMonsterType("Behemoth")

local behemoth = {}
behemoth.description = "Behemoth"
behemoth.experience = 2000
behemoth.outfit = {
	lookType = 55,
    lookHealthBar = 2
}

behemoth.health = 30000
behemoth.maxHealth = 30000
behemoth.corpse = 27196
behemoth.speed = 300
behemoth.tier = 1
behemoth.monsterLevel = 15
behemoth.items = "champion"
behemoth.skull = 27
behemoth.bestiary = 153

behemoth.changeTarget = {
	interval = 4 * 1000,
	chance = 100
}

behemoth.flags = {
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

behemoth.attacks = {
	{
		name = "combat",
		type = COMBAT_PHYSICALDAMAGE,
		minDamage = -200,
		maxDamage = -200,
		range = 6,
		chance = 100,
		shootEffect = 229,
		interval = 2 * 1000
	},
}

behemoth.elements = {
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

behemoth.defenses = {
	defense = 1,
	armor = 1,
}

local SPELLS_CONFIG = {
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,

		damageRaw = 400,
		damageType = COMBAT_PHYSICALDAMAGE,
		area = VAMPIRE_CHAIN,
		effect = 682,
		bottomEffect = false,
		center = true,
		offsetX = 4,
		offsetY = 4,
		stay = true,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 50,

		damageRaw = 400,
		damageType = COMBAT_PHYSICALDAMAGE,
		area = BEHEWAVE,
		tileDistanceEffect = 229,
		stay = true,
		wave = true,
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
			monster:setMaxHealth(behemoth.health)
			monster:setHealth(behemoth.maxHealth)
			monster:registerEvent("behemoth_death_hp")
			monster:registerEvent("behemoth_death")
			mType:isAttackable(true)
			monster:setMonsterLevel(behemoth.monsterLevel)
			monster:setSkull(behemoth.skull)
			mType:tier(behemoth.tier)
			mType:items(behemoth.items)
			BOSS_MONSTER_CONFIG[id] = {
				ready = 0,
				phase = 0,
				spells = {}
			}
		end
	end
end
mType:register(behemoth)

local eventHealth = CreatureEvent("behemoth_death_hp")

function eventHealth.onHealthChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
	if not creature or not attacker then
		return primaryDamage, primaryType, secondaryDamage, secondaryType
	end
	return primaryDamage, primaryType, secondaryDamage, secondaryType
end

local eventDeath = CreatureEvent("behemoth_death")

function eventDeath.onDeath(creature, corpse, lasthitkiller, mostdamagekiller, lasthitunjustified, mostdamageunjustified)
	if not creature then
		return true
	end

	BOSS_MONSTER_CONFIG[creature:getId()] = nil
	return true
end

eventDeath:register()
eventHealth:register()
