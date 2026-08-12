local mType = Game.createMonsterType("Ancient Scarab")

local ancientscarab = {}
ancientscarab.description = "Ancient Scarab"
ancientscarab.experience = 2000
ancientscarab.outfit = {
	lookType = 79,
    lookHealthBar = 3
}

ancientscarab.health = 1200000
ancientscarab.maxHealth = 1200000
ancientscarab.corpse = 27196
ancientscarab.speed = 300
ancientscarab.tier = 1
ancientscarab.monsterLevel = 40
ancientscarab.items = "titan"
ancientscarab.skull = 0
ancientscarab.bestiary = 141

ancientscarab.changeTarget = {
	interval = 4 * 1000,
	chance = 100
}

ancientscarab.flags = {
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

ancientscarab.attacks = {
	{
		name = "combat",
		type = COMBAT_EARTHDAMAGE,
		minDamage = -200,
		maxDamage = -200,
		range = 6,
		effect = 9,
		chance = 100,
		shootEffect = 15,
		interval = 2 * 1000
	},
}

ancientscarab.elements = {
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

ancientscarab.defenses = {
	defense = 1,
	armor = 1,
}

local SPELLS_CONFIG = {
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 75,

		damageRaw = 1200,
		damageType = COMBAT_EARTHDAMAGE,
		area = SPELL_WAVE_1,
		effect = 461,
		stay = true,
		wave = true,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 200,
		multiDelay = 500,

		damageRaw = 1200,
		damageType = COMBAT_EARTHDAMAGE,
		effect = 47,
		onTarget = true,
		count = 5,
		area = SCARAB_RANDOM_UE,
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
			monster:setMaxHealth(ancientscarab.health)
			monster:setHealth(ancientscarab.maxHealth)
			monster:registerEvent("ancientscarab_death_hp")
			monster:registerEvent("ancientscarab_death")
			mType:isAttackable(true)
			monster:setMonsterLevel(ancientscarab.monsterLevel)
			monster:setSkull(ancientscarab.skull)
			mType:tier(ancientscarab.tier)
			mType:items(ancientscarab.items)
			BOSS_MONSTER_CONFIG[id] = {
				ready = 0,
				phase = 0,
				spells = {}
			}
		end
	end
end
mType:register(ancientscarab)

local eventHealth = CreatureEvent("ancientscarab_death_hp")

function eventHealth.onHealthChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
	if not creature or not attacker then
		return primaryDamage, primaryType, secondaryDamage, secondaryType
	end
	return primaryDamage, primaryType, secondaryDamage, secondaryType
end

local eventDeath = CreatureEvent("ancientscarab_death")

function eventDeath.onDeath(creature, corpse, lasthitkiller, mostdamagekiller, lasthitunjustified, mostdamageunjustified)
	if not creature then
		return true
	end

	BOSS_MONSTER_CONFIG[creature:getId()] = nil
	return true
end

eventDeath:register()
eventHealth:register()
