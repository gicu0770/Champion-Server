local mType = Game.createMonsterType("test1")

local test1 = {}
test1.description = "test1"
test1.experience = 2000
test1.outfit = {
	lookType = 936,
	lookHealthBar = 3
}

test1.health = 90000
test1.maxHealth = 90000
test1.race = "boss"
test1.corpse = 27196
test1.speed = 300
test1.monsterLevel = 60
test1.skull = SKULL_WHITE
test1.tier = 1
test1.items = "dungeonboss"

test1.changeTarget = {
	interval = 4 * 1000,
	chance = 50
}

test1.flags = {
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

test1.attacks = {
	{
		name = "combat",
		type = COMBAT_PHYSICALDAMAGE,
		minDamage = -200,
		maxDamage = -200,
		range = 4,
		effect = 9,
		shootEffect = 15,
		interval = 6 * 1000,
	},
	{
		name = "combat",
		type = COMBAT_PHYSICALDAMAGE,
		minDamage = -200,
		maxDamage = -200,
		range = 1,
		effect = 1,
		interval = 2 * 1000
	},
}

test1.elements = {
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

local SPELLS_CONFIG = {
	{
		interval = 1000,
		exhaust = 500,
		startTime = 200,

		damageRaw = 150,
		damageType = COMBAT_PHYSICALDAMAGE,
		area = LINE_1,
		effect = 0,
		stay = true,

		tileEffect = 411,
		onHit = {
			{CONDITION_PARALYZE, 3000, function(condition, target)
					local speedReduction = target and target:getBaseSpeed() * 0.80 or 50
					speedReduction = math.ceil(speedReduction)
					condition:setParameter(CONDITION_PARAM_SPEED, -speedReduction)
				end
			},
			{CONDITION_STUN, 2000},
			{CONDITION_SPELLGROUPCOOLDOWN, 5000},
			{
				function(target, boss)
					if target and boss then
						target:addFear(boss, 2500, 200)
						target:addBuff(BOSS_HEALING_REDUCTION)
					end
				end
			},
		},
	},
}

test1.defenses = {
	defense = 1,
	armor = 1,
}

function mType.onThink(monster, interval)
	local mid = monster:getId()
	print(json.encode(mid))
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
			monster:registerEvent("test1_death_hp")
			monster:registerEvent("test1_death")
			mType:isAttackable(true)
			monster:setMonsterLevel(60)
			mType:tier(test1.tier)
			mType:items(test1.items)
			BOSS_MONSTER_CONFIG[id] = {
				ready = 0,
				phase = 0,
				spells = {}
			}
		end
	end
end

mType:register(test1)

local eventHealth = CreatureEvent("test1_death_hp")

function eventHealth.onHealthChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
	if not creature or not attacker then
		return primaryDamage, primaryType, secondaryDamage, secondaryType
	end
	return primaryDamage, primaryType, secondaryDamage, secondaryType
end

local eventDeath = CreatureEvent("test1_death")

function eventDeath.onDeath(creature, corpse, lasthitkiller, mostdamagekiller, lasthitunjustified, mostdamageunjustified)
	if not creature then
		return true
	end

	BOSS_MONSTER_CONFIG[creature:getId()] = nil
	return true
end

eventDeath:register()
eventHealth:register()
