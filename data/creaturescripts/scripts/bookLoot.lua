local extra_lootT = {
	{hasName = "draken abomination", items = {	-- Nazwa Moba
		{id = 25378, count = 1, chance = 2000},	-- Jaki item i ile %
		{id = 24124, count = 1, chance = 2000}
	}},
	{hasName = "draken elite", items = {
		{id = 25378, count = 1, chance = 2000},
		{id = 24124, count = 1, chance = 2000}
	}},
	{hasName = "rage spearman", items = {
		{id = 25377, count = 1, chance = 3000}, 
		{id = 24849, count = 1, chance = 3000}, 
		{id = 8299, count = 1, chance = 3000} 
	}},
}

function Container:addExtraLootT(c, t)
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
		
		if math.random(0, 30000) <= t.items[i].chance then
			self:addItem(t.items[i].id, count)
			local pos = self:getPosition()
			Game.sendAnimatedText('Craft Item!', pos, 350) --210
			--self:getPosition():sendMagicEffect(CONST_ME_HOLYAREA)
			self:getPosition():sendMagicEffect(57)
			self:getPosition():sendMagicEffect(56)
		end
	end
end

function onDeath(creature, corpse, killer, mostDamage, unjustified, mostDamage_unjustified)
	if not creature:isMonster() then return true end
	if corpse and corpse:isContainer() or not corpse.itemid == 0 then
	--creature:say("Craft Item!", TALKTYPE_MONSTER_SAY)
		for i = 1, #extra_lootT do
			corpse:addExtraLootT(creature, extra_lootT[i])
		end
	end
	return true
end