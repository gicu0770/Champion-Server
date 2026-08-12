local mType = Game.createMonsterType("Deepclaw")

local deepclaw = {}
deepclaw.description = "Deepclaw"
deepclaw.experience = 2000
deepclaw.outfit = {
	lookType = 2355,
    lookHealthBar = 3
}

deepclaw.health = 50000000000
deepclaw.maxHealth = 50000000000
deepclaw.corpse = 27196
deepclaw.speed = 350
deepclaw.monsterLevel = 850
deepclaw.skull = 0
deepclaw.tier = 1
deepclaw.items = "titan"
deepclaw.zone = 42
deepclaw.bestiary = 114

deepclaw.changeTarget = {
	interval = 4 * 1000,
	chance = 100
}

deepclaw.flags = {
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

deepclaw.attacks = {
	{
		name = "combat",
		type = COMBAT_ICEDAMAGE,
		minDamage = -200,
		maxDamage = -200,
		range = 6,
		chance = 1000,
		shootEffect = 29,
		interval = 2 * 1000
	},
}

deepclaw.elements = {
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

deepclaw.defenses = {
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
		effect = 538,
		bottomEffect = true,
		center = true,
		stay = true,
		offsetX = 1,
		offsetY = 1,
		random_size = 6,
		count = 10,
		area = SPELL_3,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 200,

		damageRaw = 1000,
		damageType = COMBAT_ICEDAMAGE,
		area = DEEPCLAW,
		effect = 568,
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
		multiDelay = 300,

		damageRaw = 1000,
		damageType = COMBAT_ICEDAMAGE,
		effect = 534,
		bottomEffect = true,
		center = true,
		offsetX = 1,
		offsetY = 1,
		onTarget = true,
		stay = true,
		count = 5,
		area = SPELL_RANDOM_3SQM,
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
			monster:registerEvent("deepclaw_death_hp")
			monster:registerEvent("deepclaw_death")
			mType:isAttackable(true)
			monster:setSkull(deepclaw.skull)
			monster:setMonsterLevel(deepclaw.monsterLevel)
			mType:tier(deepclaw.tier)
			mType:items(deepclaw.items)
			BOSS_MONSTER_CONFIG[id] = {
				ready = 0,
				phase = 0,
				spells = {}
			}
		end
	end
end
mType:register(deepclaw)

local eventHealth = CreatureEvent("deepclaw_death_hp")

function eventHealth.onHealthChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
	if not creature or not attacker then
		return primaryDamage, primaryType, secondaryDamage, secondaryType
	end
	return primaryDamage, primaryType, secondaryDamage, secondaryType
end

local eventDeath = CreatureEvent("deepclaw_death")

function eventDeath.onDeath(creature, corpse, lasthitkiller, mostdamagekiller, lasthitunjustified, mostdamageunjustified)
	if not creature then
		return true
	end

	BOSS_MONSTER_CONFIG[creature:getId()] = nil
	return true
end

eventDeath:register()
eventHealth:register()
