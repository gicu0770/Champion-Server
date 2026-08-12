local mType = Game.createMonsterType("Holy Protector")

local holy_protector = {}
holy_protector.description = "Holy Protector"
holy_protector.experience = 2000
holy_protector.outfit = {
	lookType = 2401,
    lookHealthBar = 3
}

holy_protector.health = 50000
holy_protector.maxHealth = 50000
holy_protector.race = "boss"
holy_protector.corpse = 27196
holy_protector.speed = 300
holy_protector.monsterLevel = 250
holy_protector.skull = 0
holy_protector.tier = 1
holy_protector.items = "uberboss"
holy_protector.bestiary = 139

holy_protector.changeTarget = {
	interval = 4 * 1000,
	chance = 100
}

holy_protector.flags = {
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

holy_protector.attacks = {
	{
		name = "combat",
		type = COMBAT_HOLYDAMAGE,
		minDamage = -200,
		maxDamage = -200,
		range = 6,
		chance = 100,
		shootEffect = 215,
		interval = 2 * 1000
	},
}

holy_protector.elements = {
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

holy_protector.defenses = {
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
		damageType = COMBAT_HOLYDAMAGE,
		effect = 449,
		bottomEffect = false,
		center = true,
		offsetX = 2,
		offsetY = 2,
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
		damageType = COMBAT_HOLYDAMAGE,
		effect = 500,
		bottomEffect = false,
		center = true,
		offsetX = 2,
		offsetY = 2,
		onTarget = true,
		count = 5,
		area = SPELL_3,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 50,
		damageRaw = 2000,
		damageType = COMBAT_HOLYDAMAGE,
		area = SPELL_FALALEFT,
		effect = 491,
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
			monster:registerEvent("holy_protector_death_hp")
			monster:registerEvent("holy_protector_death")
			mType:isAttackable(true)
			monster:setSkull(holy_protector.skull)
			monster:setMonsterLevel(holy_protector.monsterLevel)
			mType:tier(holy_protector.tier)
			mType:items(holy_protector.items)
			BOSS_MONSTER_CONFIG[id] = {
				ready = 0,
				phase = 0,
				spells = {}
			}
		end
	end
end
mType:register(holy_protector)

local eventHealth = CreatureEvent("holy_protector_death_hp")

function eventHealth.onHealthChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
	if not creature or not attacker then
		return primaryDamage, primaryType, secondaryDamage, secondaryType
	end
	return primaryDamage, primaryType, secondaryDamage, secondaryType
end

local eventDeath = CreatureEvent("holy_protector_death")

function eventDeath.onDeath(creature, corpse, lasthitkiller, mostdamagekiller, lasthitunjustified, mostdamageunjustified)
	if not creature then
		return true
	end

	BOSS_MONSTER_CONFIG[creature:getId()] = nil
	return true
end

eventDeath:register()
eventHealth:register()
