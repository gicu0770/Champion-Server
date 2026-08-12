local mType = Game.createMonsterType("Dummy Armored")

local DummyArmored = {}
DummyArmored.description = "Dummy Armored"
DummyArmored.outfit = {
	lookType = 2014,
	lookHealthBar = 2
}

DummyArmored.health = 70000000000000000
DummyArmored.maxHealth = 70000000000000000
DummyArmored.speed = 0
DummyArmored.items = "dummy"

DummyArmored.flags = {
	summonable = false,
	attackable = true,
	hostile = true,
	convinceable = false,
	illusionable = false,
	pushable = false,
	canPushItems = true,
	canPushCreatures = true,
}

DummyArmored.defenses = {
	defense = 500,
	armor = 500,
}

DummyArmored.attacks = {
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
      monster:setMaxHealth(DummyArmored.health)
      monster:setHealth(DummyArmored.health)
			monster:setMonsterLevel(50)
			monster:registerEvent("DummyHealthDrain")
			-- monster:registerEvent("copper_golem_death")
		end
	end
end
mType:register(DummyArmored)
