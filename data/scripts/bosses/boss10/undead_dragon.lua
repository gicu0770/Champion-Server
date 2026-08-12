local mType = Game.createMonsterType("Undead Dragon")

local undeaddragon = {}
undeaddragon.description = "Undead Dragon"
undeaddragon.experience = 2000
undeaddragon.outfit = {
	lookType = 1046,
    lookHealthBar = 3
}

undeaddragon.health = 6500000
undeaddragon.maxHealth = 6500000
undeaddragon.corpse = 27196
undeaddragon.speed = 300
undeaddragon.tier = 1
undeaddragon.monsterLevel = 60
undeaddragon.items = "titan"
undeaddragon.skull = 0
undeaddragon.bestiary = 152

undeaddragon.changeTarget = {
	interval = 4 * 1000,
	chance = 100
}

undeaddragon.flags = {
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

undeaddragon.attacks = {
	{
		name = "combat",
		type = COMBAT_PHYSICALDAMAGE,
		minDamage = -200,
		maxDamage = -200,
		range = 6,
		effect = 1,
		shootEffect = 200,
		interval = 2 * 1000
	},
}

undeaddragon.elements = {
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

undeaddragon.defenses = {
	defense = 1,
	armor = 1,
}

local SPELLS_CONFIG = {
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,

		damageRaw = 2000,
		damageType = COMBAT_PHYSICALDAMAGE,
		area = SPELL_PENTAGRAM,
		effect = 45,
		stay = true,
		wave = true,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 75,

		damageRaw = 2000,
		damageType = COMBAT_DEATHDAMAGE,
		area = SPELL_WAVE_1,
		effect = 188,
		stay = true,
		wave = true,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,
		multiDelay = 200,

		damageRaw = 2000,
		damageType = COMBAT_EARTHDAMAGE,
		effect = 267,
		onTarget = true,
		count = 1,
		area = UNDEADDRAGON_BALL,
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
			monster:setMaxHealth(undeaddragon.health)
			monster:setHealth(undeaddragon.maxHealth)
			monster:registerEvent("undeaddragon_death_hp")
			monster:registerEvent("undeaddragon_death")
			mType:isAttackable(true)
			monster:setMonsterLevel(undeaddragon.monsterLevel)
			monster:setSkull(undeaddragon.skull)
			mType:tier(undeaddragon.tier)
			mType:items(undeaddragon.items)
			BOSS_MONSTER_CONFIG[id] = {
				ready = 0,
				phase = 0,
				spells = {}
			}
		end
	end
end
mType:register(undeaddragon)

local eventHealth = CreatureEvent("undeaddragon_death_hp")

function eventHealth.onHealthChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
	if not creature or not attacker then
		return primaryDamage, primaryType, secondaryDamage, secondaryType
	end
	return primaryDamage, primaryType, secondaryDamage, secondaryType
end

local eventDeath = CreatureEvent("undeaddragon_death")

function eventDeath.onDeath(creature, corpse, lasthitkiller, mostdamagekiller, lasthitunjustified, mostdamageunjustified)
	if not creature then
		return true
	end

	BOSS_MONSTER_CONFIG[creature:getId()] = nil
	return true
end

eventDeath:register()
eventHealth:register()
