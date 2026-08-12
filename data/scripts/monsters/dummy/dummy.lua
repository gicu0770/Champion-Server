local mType = Game.createMonsterType("Dummy DPS")

local Dummy = {}
Dummy.description = "Dummy"
Dummy.outfit = {
	lookType = 2014,
  lookHealthBar = 1
}

Dummy.health = 70000000000000000
Dummy.maxHealth = 70000000000000000
Dummy.speed = 0
Dummy.items = "dummy"

Dummy.flags = {
	summonable = false,
	attackable = true,
	hostile = true,
	convinceable = false,
	illusionable = false,
	pushable = false,
	canPushItems = true,
	canPushCreatures = true,
}

Dummy.defenses = {
	defense = 500,
	armor = 500,
}

Dummy.attacks = {
	{
		name = "combat",
		type = COMBAT_PHYSICALDAMAGE,
		minDamage = -1,
		maxDamage = -1,
		interval = 2 * 1000,
		range = 1,
	},
}

function mType.onAppear(monster, creature)
	if monster and creature then
		local id = monster:getId()
		if id == creature:getId() then
      monster:setMaxHealth(Dummy.health)
      monster:setHealth(Dummy.health)
      monster:setMonsterLevel(0)
			monster:registerEvent("DummyHealthDrain")
		end
	end
end
mType:register(Dummy)
