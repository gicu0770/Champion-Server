local mType = Game.createMonsterType("Ethereal Seraph")

local ethereal_seraph = {}
ethereal_seraph.description = "Ethereal Seraph"
ethereal_seraph.experience = 2000
ethereal_seraph.outfit = {
	lookType = 2363,
    lookHealthBar = 3
}

ethereal_seraph.health = 500000
ethereal_seraph.maxHealth = 500000
ethereal_seraph.race = "boss"
ethereal_seraph.corpse = 27196
ethereal_seraph.speed = 350
ethereal_seraph.monsterLevel = 80
ethereal_seraph.skull = 0
ethereal_seraph.tier = 1
ethereal_seraph.items = "dungeonboss"
ethereal_seraph.zone = 40
ethereal_seraph.bestiary = 106

ethereal_seraph.changeTarget = {
	interval = 4 * 1000,
	chance = 100
}

ethereal_seraph.flags = {
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

ethereal_seraph.attacks = {
	{
		name = "combat",
		type = COMBAT_HOLYDAMAGE,
		minDamage = -200,
		maxDamage = -200,
		range = 6,
		effect = 49,
		shootEffect = 215,
		interval = 2 * 1000
	},
}

ethereal_seraph.elements = {
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

ethereal_seraph.defenses = {
	defense = 1,
	armor = 1,
}

local SPELLS_CONFIG = {
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,
		damageRaw = 2500,
		damageType = COMBAT_HOLYDAMAGE,
		area = SPELL_PENTAGRAM,
		effect = 182,
		wave = true,
		stay = true,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,
		multiDelay = 200,

		damageRaw = 5000,
		damageType = COMBAT_DEATHDAMAGE,
		effect = 198,
		bottomEffect = false,
		center = true,
		offsetX = 2,
		offsetY = 2,
		random_size = 4,
		count = 10,
		area = SPELL_3,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 50,
		damageRaw = 500,
		damageType = COMBAT_HOLYDAMAGE,
		area = ETHEREAL_CROSS,
		effect = 50,
		stay = true,
		wave = true,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,
		multiDelay = 100,
		damageRaw = 3500,
		damageType = COMBAT_HOLYDAMAGE,
		effect = 182,
		onTarget = true,

		count = 10,
		area = SPELL_RANDOM_1SQM,
	}
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
			monster:registerEvent("ethereal_seraph_death_hp")
			monster:registerEvent("ethereal_seraph_death")
			mType:isAttackable(true)
			monster:setSkull(ethereal_seraph.skull)
			monster:setMonsterLevel(ethereal_seraph.monsterLevel)
			mType:tier(ethereal_seraph.tier)
			mType:items(ethereal_seraph.items)
			BOSS_MONSTER_CONFIG[id] = {
				ready = 0,
				phase = 0,
				spells = {}
			}
		end
	end
end
mType:register(ethereal_seraph)

local eventHealth = CreatureEvent("ethereal_seraph_death_hp")

function eventHealth.onHealthChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
	if not creature or not attacker then
		return primaryDamage, primaryType, secondaryDamage, secondaryType
	end
	return primaryDamage, primaryType, secondaryDamage, secondaryType
end

local eventDeath = CreatureEvent("ethereal_seraph_death")

function eventDeath.onDeath(creature, corpse, lasthitkiller, mostdamagekiller, lasthitunjustified, mostdamageunjustified)
	if not creature then
		return true
	end

	BOSS_MONSTER_CONFIG[creature:getId()] = nil
	return true
end

eventDeath:register()
eventHealth:register()
