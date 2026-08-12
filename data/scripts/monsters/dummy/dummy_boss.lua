local mType = Game.createMonsterType("Dummy Boss")

local DummyBoss = {}
DummyBoss.description = "Dummy Boss"
DummyBoss.outfit = {
	lookType = 2014,
	lookHealthBar = 3
}

DummyBoss.health = 70000000000000000
DummyBoss.maxHealth = 70000000000000000
DummyBoss.speed = 0
DummyBoss.race = "boss"
DummyBoss.monsterLevel = 100
DummyBoss.items = "dummy"

DummyBoss.flags = {
	summonable = false,
	attackable = true,
	hostile = true,
	convinceable = false,
	illusionable = false,
	pushable = false,
	canPushItems = true,
	canPushCreatures = true,
}

DummyBoss.defenses = {
	defense = 500,
	armor = 500,
}

DummyBoss.attacks = {
	{
		name = "combat",
		type = COMBAT_PHYSICALDAMAGE,
		minDamage = -495,
		maxDamage = -495,
		interval = 2 * 1000,
		range = 1,
	},
}

function mType.onAppear(monster, creature)
	if monster and creature then
		local id = monster:getId()
		if id == creature:getId() then
      monster:setMaxHealth(DummyBoss.health)
      monster:setHealth(DummyBoss.health)
			monster:setMonsterLevel(100)
			monster:registerEvent("DummyHealthDrain")
			-- monster:registerEvent("copper_golem_death")
		end
	end
end
mType:register(DummyBoss)
