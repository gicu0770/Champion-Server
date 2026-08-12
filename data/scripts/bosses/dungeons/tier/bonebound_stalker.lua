local mType = Game.createMonsterType("Bonebound Stalker")

local bonebound_stalker = {}
bonebound_stalker.description = "Bonebound Stalker"
bonebound_stalker.experience = 2000
bonebound_stalker.outfit = {
	lookType = 2486,
    lookHealthBar = 3
}

bonebound_stalker.health = 500000
bonebound_stalker.maxHealth = 500000
bonebound_stalker.race = "boss"
bonebound_stalker.corpse = 27196
bonebound_stalker.speed = 350
bonebound_stalker.monsterLevel = 600
bonebound_stalker.skull = 0
bonebound_stalker.tier = 1
bonebound_stalker.tierDungeon = 51
bonebound_stalker.items = "dungeonboss"
bonebound_stalker.bestiary = 133

bonebound_stalker.changeTarget = {
	interval = 4 * 1000,
	chance = 100
}

bonebound_stalker.flags = {
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

bonebound_stalker.attacks = {
	{
		name = "combat",
		type = COMBAT_ENERGYDAMAGE,
		minDamage = -200,
		maxDamage = -200,
		range = 6,
		shootEffect = 156,
		interval = 2 * 1000
	},
}

bonebound_stalker.elements = {
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

bonebound_stalker.defenses = {
	defense = 1,
	armor = 1,
}

local SPELLS_CONFIG = {
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,
		multiDelay = 100,
		damageRaw = 1000,
		damageType = COMBAT_PHYSICALDAMAGE,
		effect = 546,
		onTarget = true,
		bottomEffect = false,
		center = true,
		offsetX = 3,
		offsetY = 3,
		random_size = 6,
		
		count = 10,
		area = SPELL_RANDOM_3SQM,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,
		multiDelay = 100,
		damageRaw = 3500,
		damageType = COMBAT_ICEDAMAGE,
		effect = 489,
		onTarget = true,
		count = 10,
		area = SPELL_RANDOM_1SQM,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 50,
		damageRaw = 500,
		damageType = COMBAT_ENERGYDAMAGE,
		area = BONEBOUND_STALKERUE,
		effect = 548,
		bottomEffect = false,
		center = true,
		offsetX = 6,
		offsetY = 6,
		stay = true,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,
		multiDelay = 100,

		damageRaw = 4000,
		damageType = COMBAT_ICEDAMAGE,
		effect = 580,
		bottomEffect = true,
		center = true,
		offsetX = 3,
		offsetY = 3,
		onTarget = true,

		count = 5,
		area = BLOOD_FURY,
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
			monster:registerEvent("bonebound_stalker_death_hp")
			monster:registerEvent("bonebound_stalker_death")
			mType:isAttackable(true)
			monster:setSkull(bonebound_stalker.skull)
			monster:setMonsterLevel(bonebound_stalker.monsterLevel)
			mType:tier(bonebound_stalker.tier)
			monster:setStorageValue(PlayerStorage.keyTier , bonebound_stalker.tierDungeon)
			mType:items(bonebound_stalker.items)
			BOSS_MONSTER_CONFIG[id] = {
				ready = 0,
				phase = 0,
				spells = {}
			}
		end
	end
end
mType:register(bonebound_stalker)

local eventHealth = CreatureEvent("bonebound_stalker_death_hp")

function eventHealth.onHealthChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
	if not creature or not attacker then
		return primaryDamage, primaryType, secondaryDamage, secondaryType
	end
	return primaryDamage, primaryType, secondaryDamage, secondaryType
end

local eventDeath = CreatureEvent("bonebound_stalker_death")

function eventDeath.onDeath(creature, corpse, lasthitkiller, mostdamagekiller, lasthitunjustified, mostdamageunjustified)
	if not creature then
		return true
	end

	BOSS_MONSTER_CONFIG[creature:getId()] = nil
	return true
end

eventDeath:register()
eventHealth:register()
