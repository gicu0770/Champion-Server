-- With Rookgaard

--[[
local firstItems = {2050, 2382} -- torch and club

function onLogin(player)
	if player:getLastLoginSaved() <= 0 then
		for i = 1, #firstItems do
			player:addItem(firstItems[i], 1)
		end
		player:addItem(player:getSex() == 0 and 2651 or 2650, 1) -- coat
		player:addItem(ITEM_BAG, 1)
		player:addItem(2674, 1) -- red apple
	end
	return true
end
]]--

-- Without Rookgaard
local config = {
	[1] = { -- Sorcerer
		eq = {
			{26435, 1, 53, 1, CONST_SLOT_HEAD},
			{26436, 1, 53, 1, CONST_SLOT_ARMOR},
			{26437, 1, 53, 1, CONST_SLOT_LEGS},
			{26438, 1, 53, 1, CONST_SLOT_FEET},
		},
		items = {
			{2190, 1, 90, 10, CONST_SLOT_LEFT, 19, 20}, -- wooden rod
		},
	},
	[2] = { -- Druid
		eq = {
			{26435, 1, 53, 1, CONST_SLOT_HEAD},
			{26436, 1, 53, 1, CONST_SLOT_ARMOR},
			{26437, 1, 53, 1, CONST_SLOT_LEGS},
			{26438, 1, 53, 1, CONST_SLOT_FEET},
		},
		items = {
			{2190, 1, 90, 10, CONST_SLOT_LEFT, 19, 20}, -- wooden rod
		},
	},
	[3] = { -- Archer
		eq = {
			{26435, 1, 53, 1, CONST_SLOT_HEAD},
			{26436, 1, 53, 1, CONST_SLOT_ARMOR},
			{26437, 1, 53, 1, CONST_SLOT_LEGS},
			{26438, 1, 53, 1, CONST_SLOT_FEET},
		},
		items = {
			{2456, 1, 91, 10, CONST_SLOT_LEFT, 19, 20},  -- bow
		},
	},
	[4] = { -- Knight
		eq = {
			{26435, 1, 53, 1, CONST_SLOT_HEAD},
			{26436, 1, 53, 1, CONST_SLOT_ARMOR},
			{26437, 1, 53, 1, CONST_SLOT_LEGS},
			{26438, 1, 53, 1, CONST_SLOT_FEET},
		},
		items = {
			{26618, 1, 89, 10, CONST_SLOT_LEFT, 19, 20}, -- bronze axe
		},
	},
	[17] = { -- Paladin
		eq = {
			{26435, 1, 53, 1, CONST_SLOT_HEAD},
			{26436, 1, 53, 1, CONST_SLOT_ARMOR},
			{26437, 1, 53, 1, CONST_SLOT_LEGS},
			{26438, 1, 53, 1, CONST_SLOT_FEET},
		},
		items = {
			{26618, 1, 89, 10, CONST_SLOT_LEFT, 19, 20}, -- bronze axe
		},
	},
	[21] = { -- Shadow
		eq = {
			{26435, 1, 53, 1, CONST_SLOT_HEAD},
			{26436, 1, 53, 1, CONST_SLOT_ARMOR},
			{26437, 1, 53, 1, CONST_SLOT_LEGS},
			{26438, 1, 53, 1, CONST_SLOT_FEET},
		},
		items = {
			{13828, 1, 91, 6, CONST_SLOT_RIGHT, 19, 10}, -- throwing knife
			{13828, 1, 91, 6, CONST_SLOT_LEFT, 19, 10}, -- throwing knife
		},
	},
}

function onLogin(player)
	local CriticalDamageconditionStart = Condition(CONDITION_ATTRIBUTES)
	CriticalDamageconditionStart:setParameter(CONDITION_PARAM_SPECIALSKILL_CRITICALHITAMOUNT, 50)
	CriticalDamageconditionStart:setParameter(CONDITION_PARAM_TICKS, -1)
	CriticalDamageconditionStart:setParameter(CONDITION_PARAM_SUBID, 32490)
	player:addCondition(CriticalDamageconditionStart)
	
	local targetVocation = config[player:getVocation():getId()]
	if not targetVocation then
		return true
	end

	if player:getLastLoginSaved() ~= 0 then
		return true
	end
	local backpack = player:addItem(1988)
	if not backpack then
		return true
	end
	--[[
	for i = 1, #targetVocation.eq do
		local result = player:addItem(targetVocation.eq[i][1], targetVocation.eq[i][2], false, 1, targetVocation.eq[i][5])
		result:setItemLevel(1)
		result:setRarity(0)
		if targetVocation.eq[i][3] then
			result:setImplictSlots(1)
			result:setImplictValue(1, targetVocation.eq[i][3].."|".. targetVocation.eq[i][4] .."|".. 1)
		end
	end
	--]]

	for i = 1, #targetVocation.items do
		local result = player:addItem(targetVocation.items[i][1], targetVocation.items[i][2], false, 1, targetVocation.items[i][5])
		result:setItemLevel(1)
		result:setRarity(0)
		if targetVocation.items[i][3] then
			result:setImplictSlots(2)
			result:setImplictValue(1, targetVocation.items[i][6].."|".. targetVocation.items[i][7] .."|".. 1)
			result:setImplictValue(2, targetVocation.items[i][3].."|".. targetVocation.items[i][4] .."|".. 1)
		end
	end
	local potion = player:addItem(7618,1, false, 1, CONST_SLOT_POTION1)
	potion:setRarity(0)
	potion:setItemLevel(1)
	potion:setCustomAttribute("potionHealth", 120)

	local firstRune = 1987
	if player:isSorcerer() then
		firstRune = 37372 -- Fire Lance -- 1987 -- fireball 37372,
	elseif player:isDruid() then
		firstRune = 38110 -- Stoning -- 37344 -- earth bolt
	elseif player:isArcher() then
		firstRune = 37320 -- aimed shot
	elseif player:isKnight() then
		firstRune = 38113 -- heavy Strike -- 37333 -- leap slam
	elseif player:isPaladin() then
		firstRune = 38106 -- Sacred Lance -- 37310 -- smite
	elseif player:isShadow() then
		firstRune = 37343 -- death strike
	end

	local firstRuneAdded = player:addItem(firstRune,1, false, 1, CONST_SLOT_SPELL1)
	firstRuneAdded:setRarity(0)
	firstRuneAdded:setCustomAttribute("level", 1)
	firstRuneAdded:setCustomAttribute("exp", expForLevelSpell(1))
	player:startTask(1)
	return true
end
