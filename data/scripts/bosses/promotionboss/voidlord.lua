local mType = Game.createMonsterType("Voidlord")

local voidlord = {}
voidlord.description = "Voidlord"
voidlord.experience = 2000
voidlord.outfit = {
	lookType = 2400,
    lookHealthBar = 3
}

voidlord.health = 3000000
voidlord.maxHealth = 3000000
voidlord.race = "boss"
voidlord.corpse = 27196
voidlord.speed = 250
voidlord.monsterLevel = 50
voidlord.skull = 0
voidlord.tier = 1
voidlord.items = "dungeonboss"
voidlord.bestiary = 127

voidlord.changeTarget = {
	interval = 4 * 1000,
	chance = 100
}

voidlord.flags = {
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

voidlord.attacks = {
	{
		name = "combat",
		type = COMBAT_ENERGYDAMAGE,
		minDamage = -200,
		maxDamage = -200,
		range = 5,
		chance = 100,
		shootEffect = 204,
		interval = 2 * 1000
	},
}

voidlord.elements = {
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

voidlord.defenses = {
	defense = 1,
	armor = 1,
}

local SPELLS_CONFIG = {
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,

		damageRaw = 1500,
		damageType = COMBAT_ENERGYDAMAGE,
		area = WAVE_NETHERBANEE,
		effect = 192,
		stay = true,
		wave = true,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,
		damageRaw = 1000,
		damageType = COMBAT_ENERGYDAMAGE,
		area = SPELL_FALALEFT,
		effect = 192,
		stay = true,
		wave = true,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,

		damageRaw = 2750,
		damageType = COMBAT_ENERGYDAMAGE,
		effect = 221,
		area = VOIDLORD,
		stay = true,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,
		multiDelay = 200,
		damageRaw = 3500,
		damageType = COMBAT_ENERGYDAMAGE,
		effect = 192,
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
			monster:registerEvent("voidlord_death_hp")
			monster:registerEvent("voidlord_death")
			mType:isAttackable(true)
			monster:setSkull(voidlord.skull)
			monster:setMonsterLevel(voidlord.monsterLevel)
			mType:tier(voidlord.tier)
			mType:items(voidlord.items)
			BOSS_MONSTER_CONFIG[id] = {
				ready = 0,
				phase = 0,
				spells = {}
			}
		end
	end
end
mType:register(voidlord)

local eventHealth = CreatureEvent("voidlord_death_hp")

function eventHealth.onHealthChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
	if not creature or not attacker then
		return primaryDamage, primaryType, secondaryDamage, secondaryType
	end
	return primaryDamage, primaryType, secondaryDamage, secondaryType
end

local eventDeath = CreatureEvent("voidlord_death")

function eventDeath.onDeath(creature, corpse, lasthitkiller, mostdamagekiller, lasthitunjustified, mostdamageunjustified)
	if not creature then
		return true
	end

	BOSS_MONSTER_CONFIG[creature:getId()] = nil
	return true
end

eventDeath:register()
eventHealth:register()
