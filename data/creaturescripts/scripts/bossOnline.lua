local extra_loot5 = {
	{hasName = "white fox", items = { -- Monster Name
		{id = 26555, count = 1, chance = 100000, effect = 50}, -- upgrade crystal
		{id = 36979, count = 1, chance = 100000, effect = 50}, -- soul shard upgrade
		{id = 36981, count = 1, chance = 100000, effect = 50}, -- soul shard remover
		{id = 24850, count = 15, chance = 100000, effect = 50}
	}},
	{hasName = "undead angler", items = { -- Monster Name
		{id = 26555, count = 3, chance = 100000, effect = 50}, -- upgrade crystal
		{id = 36979, count = 3, chance = 100000, effect = 50}, -- soul shard upgrade
		{id = 36981, count = 3, chance = 100000, effect = 50}, -- soul shard remover
		{id = 24850, count = 30, chance = 100000, effect = 50}
	}},
	{hasName = "bloody tentacles", items = { -- Monster Name
		{id = 26555, count = 4, chance = 100000, effect = 50}, -- upgrade crystal
		{id = 36979, count = 4, chance = 100000, effect = 50}, -- soul shard upgrade
		{id = 36981, count = 4, chance = 100000, effect = 50}, -- soul shard remover
		{id = 24850, count = 50, chance = 100000, effect = 50}
	}},	
	{hasName = "electric nightmare", items = { -- Monster Name
		{id = 26555, count = 6, chance = 100000, effect = 50}, -- upgrade crystal
		{id = 36979, count = 6, chance = 100000, effect = 50}, -- soul shard upgrade
		{id = 36981, count = 6, chance = 100000, effect = 50}, -- soul shard remover
		{id = 24850, count = 60, chance = 100000, effect = 50}
	}},	
	{hasName = "gorn", items = { -- Monster Name
		{id = 26555, count = 10, chance = 100000, effect = 50}, -- upgrade crystal
		{id = 36979, count = 10, chance = 100000, effect = 50}, -- soul shard upgrade
		{id = 36981, count = 10, chance = 100000, effect = 50}, -- soul shard remover
		{id = 24850, count = 100, chance = 100000, effect = 50}
	}},	
	
	
}


function Container:addExtraLoot2(c, t)
	if t.hasName then
		local cn = c:getName():lower()
		local cm = t.hasName:lower()
		if not cn:match(cm) then
			return true
		end
	end
	
	for i = 1, #t.items do
		local count = 1
		if t.items[i].count then
			if t.items[i].countMax then
				count = math.random(t.items[i].count, t.items[i].countMax)
			else
				count = t.items[i].count
			end
		else
			if t.items[i].countMax then
				count = math.random(1, t.items[i].countMax)
			end
		end
		
		if math.random(0, 100000) <= t.items[i].chance then
			self:addItem(t.items[i].id, count)
			self:getPosition():sendMagicEffect(t.items[i].effect)
		end
	end
end

function onDeath(creature, corpse, killer, mostDamage, unjustified, mostDamage_unjustified)
	if not creature:isMonster() then return true end
	if corpse and corpse:isContainer() or not corpse.itemid == 0 then
		for i = 1, #extra_loot5 do
			corpse:addExtraLoot2(creature, extra_loot5[i])
		end
		local amount = (killer:getExperience() * 0.3) / 100
		killer:addExperience(amount, true)
		local paragonLevel = killer:getStorageValue(PlayerStorage.paragonLevel)
		if killer:getLevel() >= 1500 then
		amount = amount / 10
		 killer:paragonUP(amount, false)
		end
		local gold = killer:getLevel() * 500
		killer:setBankBalance(killer:getBankBalance() + gold)
		if killer:getLevel() >= 1500 then
		killer:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Gold +"..gold.." and Paragon EXP +"..amount.."")
		else
		killer:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Gold +"..gold.." and EXP +"..amount.."")
		end
	end
	return true
end