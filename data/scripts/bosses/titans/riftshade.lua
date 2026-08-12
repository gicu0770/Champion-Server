local mType = Game.createMonsterType("Riftshade")

local Riftshade = {}
Riftshade.description = "Riftshade"
Riftshade.experience = 2000
Riftshade.outfit = {
	lookType = 879,
    lookHealthBar = 2
}

Riftshade.health = 22000000
Riftshade.maxHealth = 22000000
Riftshade.corpse = 27196
Riftshade.speed = 300
Riftshade.tier = 1
Riftshade.monsterLevel = 72
Riftshade.items = "titan"
Riftshade.skull = 0
Riftshade.zone = 27
Riftshade.bestiary = 66

Riftshade.changeTarget = {
	interval = 4 * 1000,
	chance = 100
}

Riftshade.flags = {
	summonable = false,
	attackable = true,
	hostile = true,
	convinceable = false,
	illusionable = false,
	pushable = false,
	canPushItems = true,
	canPushCreatures = true,
	unique = true,
	targetDistance = 2,
	staticAttackChance = 70
}

Riftshade.attacks = {
	{
		name = "combat",
		type = COMBAT_ENERGYDAMAGE,
		minDamage = -200,
		maxDamage = -200,
		range = 6,
		effect = 11,
		chance = 100,
		shootEffect = 36,
		interval = 2 * 1000
	},
}

Riftshade.elements = {
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

Riftshade.defenses = {
	defense = 1,
	armor = 1,
}

local SPELLS_CONFIG = {
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 75,

		damageRaw = 4000,
		damageType = COMBAT_ENERGYDAMAGE,
		area = RIFTSHADE,
		effect = 5,
		stay = true,
		wave = true,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,
		multiDelay = 100,

		damageRaw = 4000,
		damageType = COMBAT_ENERGYDAMAGE,
		effect = 109,
		onTarget = true,

		count = 5,
		area = SPELL_RANDOM_BLOCK,
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
			monster:setMaxHealth(Riftshade.health)
			monster:setHealth(Riftshade.maxHealth)
			monster:registerEvent("Riftshade_death_hp")
			monster:registerEvent("Riftshade_death")
			monster:setMonsterLevel(Riftshade.monsterLevel)
			monster:setSkull(Riftshade.skull)
			mType:tier(Riftshade.tier)
			mType:items(Riftshade.items)
			BOSS_MONSTER_CONFIG[id] = {
				ready = 0,
				phase = 0,
				spells = {}
			}
		end
	end
end
mType:register(Riftshade)

local eventHealth = CreatureEvent("Riftshade_death_hp")
function eventHealth.onHealthChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
	if not creature or not attacker then
		return primaryDamage, primaryType, secondaryDamage, secondaryType
	end
	return primaryDamage, primaryType, secondaryDamage, secondaryType
end

local eventDeath = CreatureEvent("Riftshade_death")
function eventDeath.onDeath(creature, corpse, lasthitkiller, mostdamagekiller, lasthitunjustified, mostdamageunjustified)
	if not creature then
		return true
	end

	BOSS_MONSTER_CONFIG[creature:getId()] = nil
	return true
end

eventDeath:register()
eventHealth:register()
