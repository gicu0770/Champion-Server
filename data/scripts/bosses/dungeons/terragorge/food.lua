local mType = Game.createMonsterType("Food")

local food = {}
food.description = "Food"
food.outfit = {
	lookTypeEx = 5417,
  lookHealthBar = 1
}

food.health = 1000
food.maxHealth = 1000
food.speed = 0

food.flags = {
	summonable = false,
	attackable = false,
	hostile = false,
	convinceable = false,
	illusionable = false,
	pushable = true,
	canPushItems = true,
	canPushCreatures = true,
	unique = true,
}

food.elements = {
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

food.defenses = {
	defense = 1,
	armor = 1,
}


function mType.onThink(monster, interval)
end

function mType.onAppear(monster, creature)
end
mType:register(food)
