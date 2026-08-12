local mType = Game.createMonsterType("Frost Beast")

local frost_beast = {}
frost_beast.description = "Frost Beast"
frost_beast.experience = 2000
frost_beast.outfit = {
	lookType = 1989,
    lookHealthBar = 3
}

frost_beast.health = 100000
frost_beast.maxHealth = 100000
frost_beast.race = "boss"
frost_beast.corpse = 27196
frost_beast.speed = 300
frost_beast.monsterLevel = 40
frost_beast.skull = 0
frost_beast.tier = 1
frost_beast.items = "uberboss"
frost_beast.bestiary = 138

frost_beast.changeTarget = {
	interval = 4 * 1000,
	chance = 100
}

frost_beast.flags = {
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

frost_beast.attacks = {
	{
		name = "combat",
		type = COMBAT_ICEDAMAGE,
		minDamage = -200,
		maxDamage = -200,
		range = 6,
		chance = 100,
		shootEffect = 126,
		interval = 2 * 1000
	},
}

frost_beast.elements = {
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

frost_beast.defenses = {
	defense = 1,
	armor = 1,
}

local SPELLS_CONFIG = {
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,
		multiDelay = 100,

		damageRaw = 5000,
		damageType = COMBAT_ICEDAMAGE,
		effect = 534,
		bottomEffect = false,
		center = true,
		offsetX = 1,
		offsetY = 1,
		random_size = 5,
		count = 10,
		area = SPELL_3,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,
		multiDelay = 50,
		damageRaw = 2000,
		damageType = COMBAT_ICEDAMAGE,
		effect = 530,
		bottomEffect = false,
		center = true,
		offsetX = 3,
		offsetY = 3,
		onTarget = true,
		count = 5,
		area = SPELL_3,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 50,
		damageRaw = 2000,
		damageType = COMBAT_ICEDAMAGE,
		area = SPELL_FALALEFT,
		effect = 177,
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
			monster:registerEvent("frost_beast_death_hp")
			monster:registerEvent("frost_beast_death")
			mType:isAttackable(true)
			monster:setSkull(frost_beast.skull)
			monster:setMonsterLevel(frost_beast.monsterLevel)
			mType:tier(frost_beast.tier)
			mType:items(frost_beast.items)
			BOSS_MONSTER_CONFIG[id] = {
				ready = 0,
				phase = 0,
				spells = {}
			}
		end
	end
end
mType:register(frost_beast)

local eventHealth = CreatureEvent("frost_beast_death_hp")

function eventHealth.onHealthChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
	if not creature or not attacker then
		return primaryDamage, primaryType, secondaryDamage, secondaryType
	end
	return primaryDamage, primaryType, secondaryDamage, secondaryType
end

local eventDeath = CreatureEvent("frost_beast_death")

function eventDeath.onDeath(creature, corpse, lasthitkiller, mostdamagekiller, lasthitunjustified, mostdamageunjustified)
	if not creature then
		return true
	end

	BOSS_MONSTER_CONFIG[creature:getId()] = nil
	return true
end

eventDeath:register()
eventHealth:register()
