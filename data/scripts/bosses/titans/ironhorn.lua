local mType = Game.createMonsterType("Ironhorn")

local Ironhorn = {}
Ironhorn.description = "Ironhorn"
Ironhorn.experience = 2000
Ironhorn.outfit = {
	lookType = 12,
    lookHealthBar = 2
}

Ironhorn.health = 500000
Ironhorn.maxHealth = 500000
Ironhorn.corpse = 27196
Ironhorn.speed = 300
Ironhorn.tier = 1
Ironhorn.monsterLevel = 38
Ironhorn.items = "titan"
Ironhorn.skull = 0
Ironhorn.zone = 14
Ironhorn.bestiary = 37

Ironhorn.changeTarget = {
	interval = 4 * 1000,
	chance = 100
}

Ironhorn.flags = {
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

Ironhorn.attacks = {
	{
		name = "combat",
		type = COMBAT_PHYSICALDAMAGE,
		minDamage = -200,
		maxDamage = -200,
		range = 6,
		chance = 100,
		shootEffect = 219,
		interval = 2 * 1000
	},
}

Ironhorn.elements = {
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

Ironhorn.defenses = {
	defense = 1,
	armor = 1,
}

local SPELLS_CONFIG = {
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,

		damageRaw = 1500,
		damageType = COMBAT_PHYSICALDAMAGE,
		area = IRONHORN,
		effect = 408,
		stay = true,
		wave = true,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,
		multiDelay = 300,

		damageRaw = 1500,
		damageType = COMBAT_PHYSICALDAMAGE,
		effect = 396,
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
			monster:setMaxHealth(Ironhorn.health)
			monster:setHealth(Ironhorn.maxHealth)
			monster:registerEvent("Ironhorn_death_hp")
			monster:registerEvent("Ironhorn_death")
			mType:isAttackable(true)
			monster:setMonsterLevel(Ironhorn.monsterLevel)
			monster:setSkull(Ironhorn.skull)
			mType:tier(Ironhorn.tier)
			mType:items(Ironhorn.items)
			BOSS_MONSTER_CONFIG[id] = {
				ready = 0,
				phase = 0,
				spells = {}
			}
		end
	end
end
mType:register(Ironhorn)

local eventHealth = CreatureEvent("Ironhorn_death_hp")

function eventHealth.onHealthChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
	if not creature or not attacker then
		return primaryDamage, primaryType, secondaryDamage, secondaryType
	end
	return primaryDamage, primaryType, secondaryDamage, secondaryType
end

local eventDeath = CreatureEvent("Ironhorn_death")

function eventDeath.onDeath(creature, corpse, lasthitkiller, mostdamagekiller, lasthitunjustified, mostdamageunjustified)
	if not creature then
		return true
	end

--	Game.broadcastMessage("Ironhorn has been defeated!", MESSAGE_STATUS_WARNING)
	BOSS_MONSTER_CONFIG[creature:getId()] = nil
	return true
end

eventDeath:register()
eventHealth:register()
