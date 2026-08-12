local mType = Game.createMonsterType("Undead King")

local undead_king = {}
undead_king.description = "Undead King"
undead_king.experience = 2000
undead_king.outfit = {
	lookType = 2394,
    lookHealthBar = 3
}

undead_king.health = 1000000
undead_king.maxHealth = 1000000
undead_king.race = "boss"
undead_king.corpse = 27196
undead_king.speed = 350
undead_king.monsterLevel = 70
undead_king.skull = 0
undead_king.tier = 1
undead_king.items = "dungeonboss"
undead_king.zone = 39
undead_king.bestiary = 102

undead_king.changeTarget = {
	interval = 4 * 1000,
	chance = 100
}

undead_king.flags = {
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

undead_king.attacks = {
	{
		name = "combat",
		type = COMBAT_PHYSICALDAMAGE,
		minDamage = -200,
		maxDamage = -200,
		range = 6,
		effect = 1,
		chance = 100,
		shootEffect = 27,
		interval = 2 * 1000
	},
}

undead_king.elements = {
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

undead_king.defenses = {
	defense = 1,
	armor = 1,
}

local SPELLS_CONFIG = {
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,
		damageRaw = 3500,
		damageType = COMBAT_DEATHDAMAGE,
		area = SPELL_PENTAGRAM,
		effect = 200,
		stay = true,
		wave = true,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 50,
		damageRaw = 500,
		damageType = COMBAT_PHYSICALDAMAGE,
		area = WAVE_NETHERBANEE,
		effect = 242,
		stay = true,
		wave = true,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 75,
		damageRaw = 3500,
		damageType = COMBAT_PHYSICALDAMAGE,
		area = SPELL_AURA,
		effect = 242,
		stay = true,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,
		multiDelay = 100,
		damageRaw = 3500,
		damageType = COMBAT_DEATHDAMAGE,
		effect = 506,
		tileDistanceEffect = 230,
		bottomEffect = false,
		center = true,
		offsetX = 1,
		offsetY = 1,
		onTarget = true,
		
		count = 10,
		area = SPELL_3,
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
			monster:registerEvent("undead_king_death_hp")
			monster:registerEvent("undead_king_death")
			mType:isAttackable(true)
			monster:setSkull(undead_king.skull)
			monster:setMonsterLevel(undead_king.monsterLevel)
			mType:tier(undead_king.tier)
			mType:items(undead_king.items)
			BOSS_MONSTER_CONFIG[id] = {
				ready = 0,
				phase = 0,
				spells = {}
			}
		end
	end
end
mType:register(undead_king)

local eventHealth = CreatureEvent("undead_king_death_hp")

function eventHealth.onHealthChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
	if not creature or not attacker then
		return primaryDamage, primaryType, secondaryDamage, secondaryType
	end
	return primaryDamage, primaryType, secondaryDamage, secondaryType
end

local eventDeath = CreatureEvent("undead_king_death")

function eventDeath.onDeath(creature, corpse, lasthitkiller, mostdamagekiller, lasthitunjustified, mostdamageunjustified)
	if not creature then
		return true
	end

	BOSS_MONSTER_CONFIG[creature:getId()] = nil
	return true
end

eventDeath:register()
eventHealth:register()
