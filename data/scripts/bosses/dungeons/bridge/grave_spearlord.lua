local mType = Game.createMonsterType("Grave Spearlord")

local grave_spearlord = {}
grave_spearlord.description = "Grave Spearlord"
grave_spearlord.experience = 2000
grave_spearlord.outfit = {
	lookType = 2810,
    lookHealthBar = 3
}

grave_spearlord.health = 30000
grave_spearlord.maxHealth = 30000
grave_spearlord.race = "boss"
grave_spearlord.corpse = 27196
grave_spearlord.speed = 300
-- grave_spearlord.script = "grave_spearlord.lua"
grave_spearlord.skull = 0
grave_spearlord.tier = 1
grave_spearlord.items = "dungeonboss"
grave_spearlord.zone = 53
grave_spearlord.bestiary = 153

grave_spearlord.changeTarget = {
	interval = 4 * 1000,
	chance = 100
}

grave_spearlord.flags = {
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

grave_spearlord.attacks = {
	{
		name = "combat",
		type = COMBAT_EARTHDAMAGE,
		minDamage = -200,
		maxDamage = -200,
		range = 6,
		chance = 100,
		shootEffect = 257,
		interval = 2 * 1000
	},
}

grave_spearlord.elements = {
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

grave_spearlord.defenses = {
	defense = 1,
	armor = 1,
}

local SPELLS_CONFIG = {
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 75,
		damageRaw = 2000,
		damageType = COMBAT_EARTHDAMAGE,
		area = BLACKFANGARCHER,
		effect = 267,
		stay = true,
		tileDistanceEffect = 257,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,
		damageRaw = 1000,
		damageType = COMBAT_PHYSICALDAMAGE,
		area = GRAVE_SPEARLORD,
		effect = 280,
		bottomEffect = true,
		center = true,
		offsetX = 4,
		offsetY = 4,
		stay = true,
		        onHit = {
            {
                function(target, boss)
                    if target and boss then
                        boss:addBuff(BOSS_IMMORTAL)
                    end
                end
            },
	},
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,
		multiDelay = 50,

		damageRaw = 2750,
		damageType = COMBAT_EARTHDAMAGE,
		tileDistanceEffect = 257,
		bottomEffect = false,
		center = true,
		offsetX = 1,
		offsetY = 1,
		random_size = 5,
		count = 15,
		area = SPELL_3,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,
		multiDelay = 200,
		damageRaw = 1000,
		damageType = COMBAT_EARTHDAMAGE,
		effect = 540,
		tileDistanceEffect = 257,
		bottomEffect = false,
		center = true,
		offsetX = 1,
		offsetY = 1,
		onTarget = true,
		stay = true,
		count = 10,
		area = SPELL_3,
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
			monster:registerEvent("grave_spearlord_death_hp")
			monster:registerEvent("grave_spearlord_death")
			mType:isAttackable(true)
			monster:setSkull(0)
			monster:setMonsterLevel(25)
			mType:tier(grave_spearlord.tier)
			mType:items(grave_spearlord.items)
			BOSS_MONSTER_CONFIG[id] = {
				ready = 0,
				phase = 0,
				spells = {}
			}
		end
	end
end
mType:register(grave_spearlord)

local eventHealth = CreatureEvent("grave_spearlord_death_hp")

function eventHealth.onHealthChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
	if not creature or not attacker then
		return primaryDamage, primaryType, secondaryDamage, secondaryType
	end
	return primaryDamage, primaryType, secondaryDamage, secondaryType
end

local eventDeath = CreatureEvent("grave_spearlord_death")

function eventDeath.onDeath(creature, corpse, lasthitkiller, mostdamagekiller, lasthitunjustified, mostdamageunjustified)
	if not creature then
		return true
	end

	BOSS_MONSTER_CONFIG[creature:getId()] = nil
	return true
end

eventDeath:register()
eventHealth:register()
