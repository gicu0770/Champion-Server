local mType = Game.createMonsterType("Seano")

local Seano = {}
Seano.description = "Seano"
Seano.experience = 2000
Seano.outfit = {
	lookType = 1210,
    lookHealthBar = 2
}

Seano.health = 1000
Seano.maxHealth = 1000
Seano.corpse = 27196
Seano.speed = 300
Seano.tier = 1
Seano.monsterLevel = 85
Seano.items = "champion"
Seano.skull = 27
Seano.bestiary = 158

Seano.changeTarget = {
	interval = 4 * 1000,
	chance = 100
}

Seano.flags = {
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

Seano.attacks = {
	{
		name = "combat",
		type = COMBAT_ICEDAMAGE,
		minDamage = -200,
		maxDamage = -200,
		range = 6,
		chance = 100,
		shootEffect = 168,
		interval = 2 * 1000
	},
}

Seano.elements = {
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

Seano.defenses = {
	defense = 1,
	armor = 1,
}

local SPELLS_CONFIG = {
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,
		multiDelay = 200,

		damageRaw = 600,
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
		startTime = 100,

		damageRaw = 400,
		damageType = COMBAT_ICEDAMAGE,
		area = VOORTMETEOR,
		effect = 536,
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
		damageType = COMBAT_ICEDAMAGE,
		area = RUSTWIDOW,
		effect = 694,
		bottomEffect = false,
		center = true,
		offsetX = 5,
		offsetY = 5,
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
			monster:setMaxHealth(Seano.health)
			monster:setHealth(Seano.maxHealth)
			monster:registerEvent("Seano_death_hp")
			monster:registerEvent("Seano_death")
			mType:isAttackable(true)
			monster:setMonsterLevel(Seano.monsterLevel)
			monster:setSkull(Seano.skull)
			mType:tier(Seano.tier)
			mType:items(Seano.items)
			BOSS_MONSTER_CONFIG[id] = {
				ready = 0,
				phase = 0,
				spells = {}
			}
		end
	end
end
mType:register(Seano)

local eventHealth = CreatureEvent("Seano_death_hp")

function eventHealth.onHealthChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
	if not creature or not attacker then
		return primaryDamage, primaryType, secondaryDamage, secondaryType
	end
	return primaryDamage, primaryType, secondaryDamage, secondaryType
end

local eventDeath = CreatureEvent("Seano_death")

function eventDeath.onDeath(creature, corpse, lasthitkiller, mostdamagekiller, lasthitunjustified, mostdamageunjustified)
	if not creature then
		return true
	end

	BOSS_MONSTER_CONFIG[creature:getId()] = nil
	return true
end

eventDeath:register()
eventHealth:register()
