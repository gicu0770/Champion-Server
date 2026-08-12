local mType = Game.createMonsterType("Elder Beholder")

local elderbeholder = {}
elderbeholder.description = "Elder Beholder"
elderbeholder.experience = 2000
elderbeholder.outfit = {
	lookType = 108,
    lookHealthBar = 3
}

elderbeholder.health = 40000
elderbeholder.maxHealth = 40000
elderbeholder.corpse = 27196
elderbeholder.speed = 300
elderbeholder.tier = 1
elderbeholder.monsterLevel = 15
elderbeholder.items = "titan"
elderbeholder.skull = 0
elderbeholder.bestiary = 147

elderbeholder.changeTarget = {
	interval = 4 * 1000,
	chance = 100
}

elderbeholder.flags = {
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

elderbeholder.attacks = {
	{
		name = "combat",
		type = COMBAT_FIREDAMAGE,
		minDamage = -200,
		maxDamage = -200,
		range = 6,
		effect = 107,
		chance = 100,
		shootEffect = 205,
		interval = 2 * 1000
	},
}

elderbeholder.elements = {
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

elderbeholder.defenses = {
	defense = 1,
	armor = 1,
}

local SPELLS_CONFIG = {
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 50,

		damageRaw = 400,
		damageType = COMBAT_EARTHDAMAGE,
		area = ELDER_BEHOLDER,
		effect = 55,
		stay = true,
		wave = true,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,

		damageRaw = 400,
		damageType = COMBAT_PHYSICALDAMAGE,
		area = ELDER_BEHOLDERAROUND,
		effect = 588,
		bottomEffect = false,
		center = true,
		offsetX = 3,
		offsetY = 3,
		onTarget = true,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,

		damageRaw = 400,
		damageType = COMBAT_DEATHDAMAGE,
		area = ELDER_BEHOLDERAROUND2,
		effect = 652,
		bottomEffect = false,
		center = true,
		offsetX = 6,
		offsetY = 6,
		onTarget = true,
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
			monster:setMaxHealth(elderbeholder.health)
			monster:setHealth(elderbeholder.maxHealth)
			monster:registerEvent("elderbeholder_death_hp")
			monster:registerEvent("elderbeholder_death")
			mType:isAttackable(true)
			monster:setMonsterLevel(elderbeholder.monsterLevel)
			monster:setSkull(elderbeholder.skull)
			mType:tier(elderbeholder.tier)
			mType:items(elderbeholder.items)
			BOSS_MONSTER_CONFIG[id] = {
				ready = 0,
				phase = 0,
				spells = {}
			}
		end
	end
end
mType:register(elderbeholder)

local eventHealth = CreatureEvent("elderbeholder_death_hp")

function eventHealth.onHealthChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
	if not creature or not attacker then
		return primaryDamage, primaryType, secondaryDamage, secondaryType
	end
	return primaryDamage, primaryType, secondaryDamage, secondaryType
end

local eventDeath = CreatureEvent("elderbeholder_death")

function eventDeath.onDeath(creature, corpse, lasthitkiller, mostdamagekiller, lasthitunjustified, mostdamageunjustified)
	if not creature then
		return true
	end

	BOSS_MONSTER_CONFIG[creature:getId()] = nil
	return true
end

eventDeath:register()
eventHealth:register()
