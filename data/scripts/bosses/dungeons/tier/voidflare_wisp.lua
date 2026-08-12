local mType = Game.createMonsterType("Voidflare Wisp")

local voidflare_wisp = {}
voidflare_wisp.description = "Voidflare Wisp"
voidflare_wisp.experience = 2000
voidflare_wisp.outfit = {
	lookType = 2209,
    lookHealthBar = 3
}

voidflare_wisp.health = 500 * 1000000000
voidflare_wisp.maxHealth = 500 * 1000000000
voidflare_wisp.race = "boss"
voidflare_wisp.corpse = 27196
voidflare_wisp.speed = 350
voidflare_wisp.monsterLevel = 900
voidflare_wisp.skull = 0
voidflare_wisp.tier = 1
voidflare_wisp.tierDungeon = 91
voidflare_wisp.items = "dungeonboss"
voidflare_wisp.bestiary = 136

voidflare_wisp.changeTarget = {
	interval = 4 * 1000,
	chance = 100
}

voidflare_wisp.flags = {
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

voidflare_wisp.attacks = {
	{
		name = "combat",
		type = COMBAT_ENERGYDAMAGE,
		minDamage = -200,
		maxDamage = -200,
		range = 6,
		chance = 100,
		shootEffect = 206,
		interval = 2 * 1000
	},
}

voidflare_wisp.elements = {
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

voidflare_wisp.defenses = {
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
		damageType = COMBAT_ENERGYDAMAGE,
		effect = 189,
		onTarget = true,
		bottomEffect = false,
		center = true,
		offsetX = 2,
		offsetY = 2,
		random_size = 5,
		
		count = 10,
		area = SPELL_RANDOM_3SQM,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,
		multiDelay = 100,
		damageRaw = 3500,
		damageType = COMBAT_ENERGYDAMAGE,
		effect = 192,
		onTarget = true,
		count = 10,
		area = SPELL_RANDOM_1SQM,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 50,
		damageRaw = 1000,
		damageType = COMBAT_ENERGYDAMAGE,
		area = WAVE_NETHERBANEE,
		tileDistanceEffect = 252,
		stay = true,
		wave = true,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 75,
		damageRaw = 1500,
		damageType = COMBAT_ENERGYDAMAGE,
		area = SPELL_PENTAGRAM,
		effect = 192,
		stay = true,
		wave = true,
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
			monster:registerEvent("voidflare_wisp_death_hp")
			monster:registerEvent("voidflare_wisp_death")
			mType:isAttackable(true)
			monster:setSkull(voidflare_wisp.skull)
			monster:setMonsterLevel(voidflare_wisp.monsterLevel)
			mType:tier(voidflare_wisp.tier)
			monster:setStorageValue(PlayerStorage.keyTier , voidflare_wisp.tierDungeon)
			mType:items(voidflare_wisp.items)
			BOSS_MONSTER_CONFIG[id] = {
				ready = 0,
				phase = 0,
				spells = {}
			}
		end
	end
end
mType:register(voidflare_wisp)

local eventHealth = CreatureEvent("voidflare_wisp_death_hp")

function eventHealth.onHealthChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
	if not creature or not attacker then
		return primaryDamage, primaryType, secondaryDamage, secondaryType
	end
	return primaryDamage, primaryType, secondaryDamage, secondaryType
end

local eventDeath = CreatureEvent("voidflare_wisp_death")

function eventDeath.onDeath(creature, corpse, lasthitkiller, mostdamagekiller, lasthitunjustified, mostdamageunjustified)
	if not creature then
		return true
	end

	BOSS_MONSTER_CONFIG[creature:getId()] = nil
	return true
end

eventDeath:register()
eventHealth:register()
