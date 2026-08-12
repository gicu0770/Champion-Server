local mType = Game.createMonsterType("Eldritch Reaver")

local eldritch_reaver = {}
eldritch_reaver.description = "Eldritch Reaver"
eldritch_reaver.experience = 2000
eldritch_reaver.outfit = {
	lookType = 2687,
    lookHealthBar = 3
}

eldritch_reaver.health = 30000
eldritch_reaver.maxHealth = 30000
eldritch_reaver.race = "boss"
eldritch_reaver.corpse = 27196
eldritch_reaver.speed = 300
-- eldritch_reaver.script = "eldritch_reaver.lua"
eldritch_reaver.skull = 0
eldritch_reaver.tier = 1
eldritch_reaver.items = "dungeonboss"
eldritch_reaver.zone = 55
eldritch_reaver.bestiary = 155

eldritch_reaver.changeTarget = {
	interval = 4 * 1000,
	chance = 100
}

eldritch_reaver.flags = {
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

eldritch_reaver.attacks = {
	{
		name = "combat",
		type = COMBAT_ENERGYDAMAGE,
		minDamage = -200,
		maxDamage = -200,
		range = 6,
		chance = 100,
		shootEffect = 252,
		interval = 2 * 1000
	},
}

eldritch_reaver.elements = {
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

eldritch_reaver.defenses = {
	defense = 1,
	armor = 1,
}

local SPELLS_CONFIG = {
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 75,
		damageRaw = 1500,
		damageType = COMBAT_ENERGYDAMAGE,
		area = HYDRA_2XWAVE,
		effect = 572,
		wave = true,
		stay = true,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,
		multiDelay = 100,

		damageRaw = 5000,
		damageType = COMBAT_ENERGYDAMAGE,
		effect = 274,
		bottomEffect = false,
		center = true,
		offsetX = 2,
		offsetY = 2,
		random_size = 5,
		count = 10,
		area = SPELL_3,
		onHit = {
				{CONDITION_PARALYZE, 3000, function(condition, target)
						local speedReduction = target and target:getBaseSpeed() * 0.99 or 50
						speedReduction = math.ceil(speedReduction)
						condition:setParameter(CONDITION_PARAM_SPEED, -speedReduction)
						target:addBuff(BOSS_SLOWING)
					end
				},
				{
					function(target, boss)
						if target and boss then
							target:addFear(boss, 2500, 150)
							target:addBuff(FEAR)
						end
					end
				},
			},
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
			monster:registerEvent("eldritch_reaver_death_hp")
			monster:registerEvent("eldritch_reaver_death")
			mType:isAttackable(true)
			monster:setSkull(0)
			monster:setMonsterLevel(25)
			mType:tier(eldritch_reaver.tier)
			mType:items(eldritch_reaver.items)
			BOSS_MONSTER_CONFIG[id] = {
				ready = 0,
				phase = 0,
				spells = {}
			}
		end
	end
end
mType:register(eldritch_reaver)

local eventHealth = CreatureEvent("eldritch_reaver_death_hp")

function eventHealth.onHealthChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
	if not creature or not attacker then
		return primaryDamage, primaryType, secondaryDamage, secondaryType
	end
	return primaryDamage, primaryType, secondaryDamage, secondaryType
end

local eventDeath = CreatureEvent("eldritch_reaver_death")

function eventDeath.onDeath(creature, corpse, lasthitkiller, mostdamagekiller, lasthitunjustified, mostdamageunjustified)
	if not creature then
		return true
	end

	BOSS_MONSTER_CONFIG[creature:getId()] = nil
	return true
end

eventDeath:register()
eventHealth:register()
