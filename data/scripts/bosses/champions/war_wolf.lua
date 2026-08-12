local mType = Game.createMonsterType("War Wolf")

local warwolf = {}
warwolf.description = "War Wolf"
warwolf.experience = 2000
warwolf.outfit = {
	lookType = 3,
    lookHealthBar = 2
}

warwolf.health = 2500
warwolf.maxHealth = 2500
warwolf.corpse = 27196
warwolf.speed = 300
warwolf.tier = 1
warwolf.monsterLevel = 5
warwolf.items = "champion"
warwolf.skull = 27
warwolf.bestiary = 162

warwolf.changeTarget = {
	interval = 4 * 1000,
	chance = 100
}

warwolf.flags = {
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

warwolf.attacks = {
	{
		name = "combat",
		type = COMBAT_PHYSICALDAMAGE,
		minDamage = -200,
		maxDamage = -200,
		range = 2,
		effect = 437,
		interval = 2 * 1000
	},
}

warwolf.elements = {
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

warwolf.defenses = {
	defense = 1,
	armor = 1,
}

local SPELLS_CONFIG = {
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,

		damageRaw = 200,
		damageType = COMBAT_PHYSICALDAMAGE,
		area = AROUND,
		effect = 685,
		bottomEffect = false,
		center = true,
		offsetX = 2,
		offsetY = 2,
		stay = true,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,

		damageRaw = 200,
		damageType = COMBAT_PHYSICALDAMAGE,
		area = LINE_2,
		effect = 1,
		stay = true,
		wave = true,
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
			monster:setMaxHealth(warwolf.health)
			monster:setHealth(warwolf.maxHealth)
			monster:registerEvent("warwolf_death_hp")
			monster:registerEvent("warwolf_death")
			mType:isAttackable(true)
			monster:setMonsterLevel(warwolf.monsterLevel)
			monster:setSkull(warwolf.skull)
			mType:tier(warwolf.tier)
			mType:items(warwolf.items)
			BOSS_MONSTER_CONFIG[id] = {
				ready = 0,
				phase = 0,
				spells = {}
			}
		end
	end
end
mType:register(warwolf)

local eventHealth = CreatureEvent("warwolf_death_hp")

function eventHealth.onHealthChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
	if not creature or not attacker then
		return primaryDamage, primaryType, secondaryDamage, secondaryType
	end
	return primaryDamage, primaryType, secondaryDamage, secondaryType
end

local eventDeath = CreatureEvent("warwolf_death")

function eventDeath.onDeath(creature, corpse, lasthitkiller, mostdamagekiller, lasthitunjustified, mostdamageunjustified)
	if not creature then
		return true
	end

	BOSS_MONSTER_CONFIG[creature:getId()] = nil
	return true
end

eventDeath:register()
eventHealth:register()
