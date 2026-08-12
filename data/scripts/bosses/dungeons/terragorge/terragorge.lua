local mType = Game.createMonsterType("Terragorge")

local terragorge = {}
terragorge.description = "Terragorge"
terragorge.experience = 2000
terragorge.outfit = {
	lookType = 2503,
  lookHealthBar = 3
}

terragorge.health = 80000
terragorge.maxHealth = 80000
terragorge.race = "boss"
terragorge.corpse = 27196
terragorge.speed = 300
terragorge.monsterLevel = 55
terragorge.tier = 1
terragorge.items = "dungeonboss"

terragorge.changeTarget = {
	interval = 4 * 1000,
	chance = 100
}

terragorge.flags = {
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

terragorge.attacks = {
	{
		name = "combat",
		type = COMBAT_PHYSICALDAMAGE,
		minDamage = -200,
		maxDamage = -200,
		range = 1,
		chance = 100,
		effect = 411,
		interval = 2 * 1000
	},
}

terragorge.elements = {
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

terragorge.defenses = {
	defense = 1,
	armor = 1,
}

local SPELLS_CONFIG = {

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
			monster:registerEvent("terragorge_death_hp")
			monster:registerEvent("terragorge_death")
			mType:isAttackable(true)
			monster:setSkull(terragorge.skull)
			monster:setMonsterLevel(terragorge.monsterLevel)
			mType:tier(terragorge.tier)
			mType:items(terragorge.items)
			BOSS_MONSTER_CONFIG[id] = {
				ready = 0,
				phase = 0,
				spells = {}
			}
		end
	end
end
mType:register(terragorge)

local eventHealth = CreatureEvent("terragorge_death_hp")

function eventHealth.onHealthChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
	if not creature or not attacker then
		return primaryDamage, primaryType, secondaryDamage, secondaryType
	end
	return primaryDamage, primaryType, secondaryDamage, secondaryType
end

local eventDeath = CreatureEvent("terragorge_death")

function eventDeath.onDeath(creature, corpse, lasthitkiller, mostdamagekiller, lasthitunjustified, mostdamageunjustified)
	if not creature then
		return true
	end

	BOSS_MONSTER_CONFIG[creature:getId()] = nil
	return true
end

eventDeath:register()
eventHealth:register()
