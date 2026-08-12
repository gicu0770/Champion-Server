local mType = Game.createMonsterType("Barbarian Brutetamer")

local barbarianbrutetamer = {}
barbarianbrutetamer.description = "Barbarian Brutetamer"
barbarianbrutetamer.experience = 2000
barbarianbrutetamer.outfit = {
	lookType = 264,
    lookHealthBar = 3
}

barbarianbrutetamer.health = 80000
barbarianbrutetamer.maxHealth = 80000
barbarianbrutetamer.corpse = 27196
barbarianbrutetamer.speed = 300
barbarianbrutetamer.tier = 1
barbarianbrutetamer.monsterLevel = 20
barbarianbrutetamer.items = "titan"
barbarianbrutetamer.skull = 0
barbarianbrutetamer.bestiary = 143

barbarianbrutetamer.changeTarget = {
	interval = 4 * 1000,
	chance = 100
}

barbarianbrutetamer.flags = {
	summonable = false,
	attackable = true,
	hostile = true,
	convinceable = false,
	illusionable = false,
	pushable = false,
	canPushItems = true,
	canPushCreatures = true,
	unique = true,
	targetDistance = 3,
	staticAttackChance = 70
}

barbarianbrutetamer.attacks = {
	{
		name = "combat",
		type = COMBAT_DEATHDAMAGE,
		minDamage = -200,
		maxDamage = -200,
		range = 6,
		effect = 18,
		chance = 100,
		shootEffect = 11,
		interval = 2 * 1000
	},
}

barbarianbrutetamer.elements = {
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

barbarianbrutetamer.defenses = {
	defense = 1,
	armor = 1,
}

local SPELLS_CONFIG = {
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 50,

		damageRaw = 600,
		damageType = COMBAT_DEATHDAMAGE,
		area = BARBARIANWAVE,
		tileDistanceEffect = 32,
		stay = true,
		wave = true,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,
		multiDelay = 500,

		damageRaw = 600,
		damageType = COMBAT_DEATHDAMAGE,
		effect = 459,
		bottomEffect = false,
		center = true,
		offsetX = 3,
		offsetY = 3,
		onTarget = true,
		count = 3,
		area = BRABRIANRANDOM,
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
			monster:setMaxHealth(barbarianbrutetamer.health)
			monster:setHealth(barbarianbrutetamer.maxHealth)
			monster:registerEvent("barbarianbrutetamer_death_hp")
			monster:registerEvent("barbarianbrutetamer_death")
			mType:isAttackable(true)
			monster:setMonsterLevel(barbarianbrutetamer.monsterLevel)
			monster:setSkull(barbarianbrutetamer.skull)
			mType:tier(barbarianbrutetamer.tier)
			mType:items(barbarianbrutetamer.items)
			BOSS_MONSTER_CONFIG[id] = {
				ready = 0,
				phase = 0,
				spells = {}
			}
		end
	end
end
mType:register(barbarianbrutetamer)

local eventHealth = CreatureEvent("barbarianbrutetamer_death_hp")

function eventHealth.onHealthChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
	if not creature or not attacker then
		return primaryDamage, primaryType, secondaryDamage, secondaryType
	end
	return primaryDamage, primaryType, secondaryDamage, secondaryType
end

local eventDeath = CreatureEvent("barbarianbrutetamer_death")

function eventDeath.onDeath(creature, corpse, lasthitkiller, mostdamagekiller, lasthitunjustified, mostdamageunjustified)
	if not creature then
		return true
	end

	BOSS_MONSTER_CONFIG[creature:getId()] = nil
	return true
end

eventDeath:register()
eventHealth:register()
