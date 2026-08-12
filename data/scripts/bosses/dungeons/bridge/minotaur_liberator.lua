local mType = Game.createMonsterType("Minotaur Liberator")

local minotaur_liberator = {}
minotaur_liberator.description = "Minotaur Liberator"
minotaur_liberator.experience = 2000
minotaur_liberator.outfit = {
	lookType = 2699,
    lookHealthBar = 3
}

minotaur_liberator.health = 30000
minotaur_liberator.maxHealth = 30000
minotaur_liberator.race = "boss"
minotaur_liberator.corpse = 27196
minotaur_liberator.speed = 300
-- minotaur_liberator.script = "minotaur_liberator.lua"
minotaur_liberator.skull = 0
minotaur_liberator.tier = 1
minotaur_liberator.items = "dungeonboss"
minotaur_liberator.zone = 54
minotaur_liberator.bestiary = 154

minotaur_liberator.changeTarget = {
	interval = 4 * 1000,
	chance = 100
}

minotaur_liberator.flags = {
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

minotaur_liberator.attacks = {
	{
		name = "combat",
		type = COMBAT_PHYSICALDAMAGE,
		minDamage = -200,
		maxDamage = -200,
		range = 6,
		chance = 100,
		effect = 1,
		shootEffect = 219,
		interval = 2 * 1000
	},
}

minotaur_liberator.elements = {
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

minotaur_liberator.defenses = {
	defense = 1,
	armor = 1,
}

local SPELLS_CONFIG = {
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 75,
		damageRaw = 1500,
		damageType = COMBAT_PHYSICALDAMAGE,
		area = BLOODY_CHAIN,
		effect = 179,
		stay = true,
        onHit = {
		    {CONDITION_STUN, 2000},
            {CONDITION_PARALYZE, 3000, function(condition, target)
                    local speedReduction = target and target:getBaseSpeed() * 0.80 or 50
                    speedReduction = math.ceil(speedReduction)
                    condition:setParameter(CONDITION_PARAM_SPEED, -speedReduction)
					target:addBuff(BOSS_SLOWING)
                end
            },
        },
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 200,
		multiDelay = 500,

		damageRaw = 1000,
		damageType = COMBAT_PHYSICALDAMAGE,
		effect = 520,
		bottomEffect = false,
		center = true,
		offsetX = 3,
		offsetY = 3,
		onTarget = true,
		stay = true,
		jump_position = true,
		count = 5,
		area = LIBARATOR,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,
		multiDelay = 50,

		damageRaw = 4000,
		damageType = COMBAT_PHYSICALDAMAGE,
		effect = 197,
		bottomEffect = false,
		center = true,
		offsetX = 2,
		offsetY = 2,
		onTarget = true,

		count = 5,
		area = SPELL_3,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,
		multiDelay = 50,

		damageRaw = 2750,
		damageType = COMBAT_PHYSICALDAMAGE,
		effect = 447,
		onTarget = true,
		count = 10,
		area = SPELL_RANDOM_1SQM,
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
			monster:registerEvent("minotaur_liberator_death_hp")
			monster:registerEvent("minotaur_liberator_death")
			mType:isAttackable(true)
			monster:setSkull(0)
			monster:setMonsterLevel(25)
			mType:tier(minotaur_liberator.tier)
			mType:items(minotaur_liberator.items)
			BOSS_MONSTER_CONFIG[id] = {
				ready = 0,
				phase = 0,
				spells = {}
			}
		end
	end
end
mType:register(minotaur_liberator)

local eventHealth = CreatureEvent("minotaur_liberator_death_hp")

function eventHealth.onHealthChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
	if not creature or not attacker then
		return primaryDamage, primaryType, secondaryDamage, secondaryType
	end
	return primaryDamage, primaryType, secondaryDamage, secondaryType
end

local eventDeath = CreatureEvent("minotaur_liberator_death")

function eventDeath.onDeath(creature, corpse, lasthitkiller, mostdamagekiller, lasthitunjustified, mostdamageunjustified)
	if not creature then
		return true
	end

	BOSS_MONSTER_CONFIG[creature:getId()] = nil
	return true
end

eventDeath:register()
eventHealth:register()
