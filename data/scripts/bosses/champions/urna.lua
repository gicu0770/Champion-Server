local mType = Game.createMonsterType("Urna")

local Urna = {}
Urna.description = "Urna"
Urna.experience = 2000
Urna.outfit = {
	lookType = 617,
    lookHealthBar = 2
}

Urna.health = 1000
Urna.maxHealth = 1000
Urna.corpse = 27196
Urna.speed = 300
Urna.tier = 1
Urna.monsterLevel = 35
Urna.items = "champion"
Urna.skull = 27
Urna.bestiary = 161

Urna.changeTarget = {
	interval = 4 * 1000,
	chance = 100
}

Urna.flags = {
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

Urna.attacks = {
	{
		name = "combat",
		type = COMBAT_EARTHDAMAGE,
		minDamage = -200,
		maxDamage = -200,
		range = 6,
		effect = 9,
		chance = 100,
		shootEffect = 166,
		interval = 2 * 1000
	},
}

Urna.elements = {
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

Urna.defenses = {
	defense = 1,
	armor = 1,
}

local SPELLS_CONFIG = {
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 50,

		damageRaw = 800,
		damageType = COMBAT_EARTHDAMAGE,
		area = BARBARIANWAVE,
		effect = 222,
		stay = true,
		wave = true,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,
		multiDelay = 200,

		damageRaw = 800,
		damageType = COMBAT_EARTHDAMAGE,
		effect = 55,
		onTarget = true,
		count = 5,
		area = SPELL_RANDOM_1SQM,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,

		damageRaw = 400,
		damageType = COMBAT_EARTHDAMAGE,
		area = VAMPIRE_CHAIN,
		effect = 514,
		bottomEffect = false,
		center = true,
		offsetX = 3,
		offsetY = 3,
		stay = true,
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
			monster:setMaxHealth(Urna.health)
			monster:setHealth(Urna.maxHealth)
			monster:registerEvent("Urna_death_hp")
			monster:registerEvent("Urna_death")
			mType:isAttackable(true)
			monster:setMonsterLevel(Urna.monsterLevel)
			monster:setSkull(Urna.skull)
			mType:tier(Urna.tier)
			mType:items(Urna.items)
			BOSS_MONSTER_CONFIG[id] = {
				ready = 0,
				phase = 0,
				spells = {}
			}
		end
	end
end
mType:register(Urna)

local eventHealth = CreatureEvent("Urna_death_hp")
function eventHealth.onHealthChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
	if not creature or not attacker then
		return primaryDamage, primaryType, secondaryDamage, secondaryType
	end
	return primaryDamage, primaryType, secondaryDamage, secondaryType
end

local eventDeath = CreatureEvent("Urna_death")
function eventDeath.onDeath(creature, corpse, lasthitkiller, mostdamagekiller, lasthitunjustified, mostdamageunjustified)
	if not creature then
		return true
	end

	BOSS_MONSTER_CONFIG[creature:getId()] = nil
	return true
end

eventDeath:register()
eventHealth:register()
