local mType = Game.createMonsterType("Soulbound Lich")

local soulbound_lich = {}
soulbound_lich.description = "Soulbound Lich"
soulbound_lich.experience = 2000
soulbound_lich.outfit = {
	lookType = 2811,
    lookHealthBar = 3
}

soulbound_lich.health = 30000
soulbound_lich.maxHealth = 30000
soulbound_lich.race = "boss"
soulbound_lich.corpse = 27196
soulbound_lich.speed = 300
soulbound_lich.skull = 0
soulbound_lich.tier = 1
soulbound_lich.items = "dungeonboss"
soulbound_lich.zone = 52
soulbound_lich.bestiary = 152

soulbound_lich.changeTarget = {
	interval = 4 * 1000,
	chance = 100
}

soulbound_lich.flags = {
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

soulbound_lich.attacks = {
	{
		name = "combat",
		type = COMBAT_ENERGYDAMAGE,
		minDamage = -200,
		maxDamage = -200,
		range = 6,
		chance = 100,
		shootEffect = 258,
		interval = 2 * 1000
	},
}

soulbound_lich.elements = {
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

soulbound_lich.defenses = {
	defense = 1,
	armor = 1,
}

local SPELLS_CONFIG = {
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 75,
		damageRaw = 1000,
		damageType = COMBAT_ENERGYDAMAGE,
		area = SPELL_PENTAGRAM,
		effect = 192,
		wave = true,
		stay = true,
		onHit = {
        {
                function(target, boss)
                    if target and boss then
                      local globalCd = Condition(CONDITION_SPELLGROUPCOOLDOWN)
                      globalCd:setParameter(CONDITION_PARAM_TICKS, 3000)
                      globalCd:setParameter(CONDITION_PARAM_SUBID, 1)
                      target:addCondition(globalCd)
					  target:addBuff(SILENCE)
                    end
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
		damageType = COMBAT_ICEDAMAGE,
		effect = 536,
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
		multiDelay = 100,

		damageRaw = 5000,
		damageType = COMBAT_ENERGYDAMAGE,
		tileDistanceEffect = 258,
		bottomEffect = false,
		center = true,
		offsetX = 1,
		offsetY = 1,
		random_size = 5,
		count = 10,
		area = SPELL_3,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,
		multiDelay = 100,

		damageRaw = 1000,
		damageType = COMBAT_ENERGYDAMAGE,
		effect = 543,
		bottomEffect = false,
		center = true,
		offsetX = 1,
		offsetY = 1,
		onTarget = true,
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
			monster:registerEvent("soulbound_lich_death_hp")
			monster:registerEvent("soulbound_lich_death")
			mType:isAttackable(true)
			monster:setSkull(0)
			monster:setMonsterLevel(25)
			mType:tier(soulbound_lich.tier)
			mType:items(soulbound_lich.items)
			BOSS_MONSTER_CONFIG[id] = {
				ready = 0,
				phase = 0,
				spells = {}
			}
		end
	end
end
mType:register(soulbound_lich)

local eventHealth = CreatureEvent("soulbound_lich_death_hp")

function eventHealth.onHealthChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
	if not creature or not attacker then
		return primaryDamage, primaryType, secondaryDamage, secondaryType
	end
	return primaryDamage, primaryType, secondaryDamage, secondaryType
end

local eventDeath = CreatureEvent("soulbound_lich_death")

function eventDeath.onDeath(creature, corpse, lasthitkiller, mostdamagekiller, lasthitunjustified, mostdamageunjustified)
	if not creature then
		return true
	end

	BOSS_MONSTER_CONFIG[creature:getId()] = nil
	return true
end

eventDeath:register()
eventHealth:register()
