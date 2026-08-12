local mType = Game.createMonsterType("Twistgrove")

local Twistgrove = {}
Twistgrove.description = "Twistgrove"
Twistgrove.experience = 2000
Twistgrove.outfit = {
	lookType = 2360,
    lookHealthBar = 2
}

Twistgrove.health = 1000
Twistgrove.maxHealth = 1000
Twistgrove.corpse = 27196
Twistgrove.speed = 300
Twistgrove.tier = 1
Twistgrove.monsterLevel = 95
Twistgrove.items = "champion"
Twistgrove.skull = 27
Twistgrove.bestiary = 160

Twistgrove.changeTarget = {
	interval = 4 * 1000,
	chance = 100
}

Twistgrove.flags = {
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

Twistgrove.attacks = {
	{
		name = "combat",
		type = COMBAT_EARTHDAMAGE,
		minDamage = -200,
		maxDamage = -200,
		range = 6,
		effect = 9,
		chance = 100,
		shootEffect = 15,
		interval = 2 * 1000
	},
}

Twistgrove.elements = {
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

Twistgrove.defenses = {
	defense = 1,
	armor = 1,
}

local SPELLS_CONFIG = {
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,
		multiDelay = 200,

		damageRaw = 600,
		damageType = COMBAT_FIREDAMAGE,
		effect = 642,
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

		damageRaw = 400,
		damageType = COMBAT_EARTHDAMAGE,
		area = VOORTMETEOR,
		effect = 514,
		bottomEffect = false,
		center = true,
		offsetX = 3,
		offsetY = 3,
		onTarget = true,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,

		damageRaw = 400,
		damageType = COMBAT_FIREDAMAGE,
		area = RUSTWIDOW,
		effect = 629,
		bottomEffect = false,
		center = true,
		offsetX = 5,
		offsetY = 5,
		onTarget = true,
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
			monster:setMaxHealth(Twistgrove.health)
			monster:setHealth(Twistgrove.maxHealth)
			monster:registerEvent("Twistgrove_death_hp")
			monster:registerEvent("Twistgrove_death")
			mType:isAttackable(true)
			monster:setMonsterLevel(Twistgrove.monsterLevel)
			monster:setSkull(Twistgrove.skull)
			mType:tier(Twistgrove.tier)
			mType:items(Twistgrove.items)
			BOSS_MONSTER_CONFIG[id] = {
				ready = 0,
				phase = 0,
				spells = {}
			}
		end
	end
end
mType:register(Twistgrove)

local eventHealth = CreatureEvent("Twistgrove_death_hp")

function eventHealth.onHealthChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
	if not creature or not attacker then
		return primaryDamage, primaryType, secondaryDamage, secondaryType
	end
	return primaryDamage, primaryType, secondaryDamage, secondaryType
end

local eventDeath = CreatureEvent("Twistgrove_death")

function eventDeath.onDeath(creature, corpse, lasthitkiller, mostdamagekiller, lasthitunjustified, mostdamageunjustified)
	if not creature then
		return true
	end

	BOSS_MONSTER_CONFIG[creature:getId()] = nil
	return true
end

eventDeath:register()
eventHealth:register()
