local mType = Game.createMonsterType("Reaper Shade")

local reaper_shade = {}
reaper_shade.description = "Reaper Shade"
reaper_shade.experience = 2000
reaper_shade.outfit = {
	lookType = 2491,
    lookHealthBar = 3
}

reaper_shade.health = 800 * 1000000000
reaper_shade.maxHealth = 800 * 1000000000
reaper_shade.race = "boss"
reaper_shade.corpse = 27196
reaper_shade.speed = 350
reaper_shade.monsterLevel = 2500
reaper_shade.skull = 0
reaper_shade.tier = 1
reaper_shade.tierDungeon = 121
reaper_shade.items = "dungeonboss"
reaper_shade.bestiary = 134

reaper_shade.changeTarget = {
	interval = 4 * 1000,
	chance = 100
}

reaper_shade.flags = {
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

reaper_shade.attacks = {
	{
		name = "combat",
		type = COMBAT_PHYSICALDAMAGE,
		minDamage = -200,
		maxDamage = -200,
		range = 6,
		effect = 1,
		chance = 100,
		shootEffect = 219,
		interval = 2 * 1000
	},
}

reaper_shade.elements = {
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

reaper_shade.defenses = {
	defense = 1,
	armor = 1,
}

local SPELLS_CONFIG = {
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,
		damageRaw = 2500,
		damageType = COMBAT_DEATHDAMAGE,
		area = VENOMGRIZZLEUE,
		effect = 349,
		stay = true,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 50,
		damageRaw = 2500,
		damageType = COMBAT_PHYSICALDAMAGE,
		area = WAVE_NETHERBANEE,
		effect = 366,
		stay = true,
		wave = true,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 75,

		damageRaw = 2750,
		damageType = COMBAT_PHYSICALDAMAGE,
		effect = 396,
		area = REAPER_SHADE,
		stay = true,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,
		multiDelay = 200,

		damageRaw = 1000,
		damageType = COMBAT_DEATHDAMAGE,
		effect = 506,
		distanceeffect = 230,
		bottomEffect = false,
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
			monster:registerEvent("reaper_shade_death_hp")
			monster:registerEvent("reaper_shade_death")
			mType:isAttackable(true)
			monster:setSkull(reaper_shade.skull)
			monster:setMonsterLevel(reaper_shade.monsterLevel)
			mType:tier(reaper_shade.tier)
			monster:setStorageValue(PlayerStorage.keyTier , reaper_shade.tierDungeon)
			mType:items(reaper_shade.items)
			BOSS_MONSTER_CONFIG[id] = {
				ready = 0,
				phase = 0,
				spells = {}
			}
		end
	end
end
mType:register(reaper_shade)

local eventHealth = CreatureEvent("reaper_shade_death_hp")

function eventHealth.onHealthChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
	if not creature or not attacker then
		return primaryDamage, primaryType, secondaryDamage, secondaryType
	end
	return primaryDamage, primaryType, secondaryDamage, secondaryType
end

local eventDeath = CreatureEvent("reaper_shade_death")

function eventDeath.onDeath(creature, corpse, lasthitkiller, mostdamagekiller, lasthitunjustified, mostdamageunjustified)
	if not creature then
		return true
	end

	BOSS_MONSTER_CONFIG[creature:getId()] = nil
	return true
end

eventDeath:register()
eventHealth:register()
