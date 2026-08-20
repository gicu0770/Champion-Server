local config = {
	[1] = { -- Mia
		items = {
			{2456, 1}, -- bow
		},
		spells = {
			{1987, 1, CONST_SLOT_SPELL1}, -- spell1
		--	{37310, 1, CONST_SLOT_SPELL2}, -- spell2
		--	{37311, 1, CONST_SLOT_SPELL3}, -- spell3
		--	{37312, 1, CONST_SLOT_SPELL4}, -- spell4
		}
	},
	[2] = { -- Gorn
		items = {
			{36666, 1}, -- sword
		},
		spells = {
		{1987, 1, CONST_SLOT_SPELL1}, -- spell1
		},
	},
	[3] = { -- Juki
		items = {
			{26637, 1}, -- wooden rod
		},
		spells = {
		{1987, 1, CONST_SLOT_SPELL1}, -- spell1
		},
	},
	[4] = { -- Limone
		items = {
			{26637, 1}, -- wooden rod
		},
		spells = {
			{1987, 1, CONST_SLOT_SPELL1}, -- spell1
		},
	},

}

function onLogin(player)
	local targetVocation = config[player:getVocation():getId()]
	if not targetVocation then
		return true
	end

	if player:getLastLoginSaved() ~= 0 then
		return true
	end

	for i = 1, #targetVocation.items do
		local item = player:addItem(targetVocation.items[i][1], targetVocation.items[i][2], true, 1, CONST_SLOT_LEFT )
		item:setTier(1)
		item:setRarity(COMMON)
	end
	for i = 1, #targetVocation.spells do
		local item = player:addItem(targetVocation.spells[i][1], targetVocation.spells[i][2], true, 1, targetVocation.spells[i][3] )
		if targetVocation.spells[i][3] then
			item:setRarity(COMMON)
				item:setRarity(0)
				item:setCustomAttribute("level", 1)
				item:setCustomAttribute("exp", expForLevelSpell(1))
		end
	end

	player:addItem(7618, 1, true, 1, CONST_SLOT_POTION1)
	player:addItem(1988, 1, true, 1, CONST_SLOT_BACKPACK)
	player:startTask(1)
	return true
end
