local mType = Game.createMonsterType("Tuu")

local Tuu = {}
Tuu.description = "Tuu"
Tuu.experience = 2000
Tuu.outfit = {
	lookType = 881,
    lookHealthBar = 2
}

Tuu.health = 1000
Tuu.maxHealth = 1000
Tuu.corpse = 27196
Tuu.speed = 300
Tuu.tier = 1
Tuu.monsterLevel = 45
Tuu.items = "champion"
Tuu.skull = 27
Tuu.bestiary = 159

Tuu.changeTarget = {
	interval = 4 * 1000,
	chance = 100
}

Tuu.flags = {
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

Tuu.attacks = {
	{
		name = "combat",
		type = COMBAT_PHYSICALDAMAGE,
		minDamage = -200,
		maxDamage = -200,
		range = 15,
		effect = 438,
		interval = 2 * 1000
	},
}

Tuu.elements = {
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

Tuu.defenses = {
	defense = 1,
	armor = 1,
}

local SPELLS_CONFIG = {
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 50,
		damageRaw = 1000,
		damageType = COMBAT_PHYSICALDAMAGE,
		area = WAVE_NETHERBANEE,
		effect = 429,
		offsetX = 1,
		offsetY = 1,
		wave = true,
		stay = true,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,
		multiDelay = 200,

		damageRaw = 800,
		damageType = COMBAT_DEATHDAMAGE,
		effect = 438,
		onTarget = true,
		count = 5,
		area = SPELL_RANDOM_1SQM,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,

		damageRaw = 200,
		damageType = COMBAT_PHYSICALDAMAGE,
		area = AROUND,
		effect = 688,
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
			monster:setMaxHealth(Tuu.health)
			monster:setHealth(Tuu.maxHealth)
			monster:registerEvent("Tuu_death_hp")
			monster:registerEvent("Tuu_death")
			mType:isAttackable(true)
			monster:setMonsterLevel(Tuu.monsterLevel)
			monster:setSkull(Tuu.skull)
			mType:tier(Tuu.tier)
			mType:items(Tuu.items)
			BOSS_MONSTER_CONFIG[id] = {
				ready = 0,
				phase = 0,
				spells = {}
			}
		end
	end
end
mType:register(Tuu)

local eventHealth = CreatureEvent("Tuu_death_hp")

function eventHealth.onHealthChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
	if not creature or not attacker then
		return primaryDamage, primaryType, secondaryDamage, secondaryType
	end
	return primaryDamage, primaryType, secondaryDamage, secondaryType
end

local eventDeath = CreatureEvent("Tuu_death")

function eventDeath.onDeath(creature, corpse, lasthitkiller, mostdamagekiller, lasthitunjustified, mostdamageunjustified)
	if not creature then
		return true
	end

	BOSS_MONSTER_CONFIG[creature:getId()] = nil
	return true
end

eventDeath:register()
eventHealth:register()
