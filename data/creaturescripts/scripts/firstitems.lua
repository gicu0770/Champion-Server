local config = {
	[1] = { -- Mage
		items = {
			{26637, 1}, -- wooden rod
		},
		spells = {
			{1987, 1, CONST_SLOT_SPELL1}, -- spell1
			{37306, 1, CONST_SLOT_SPELL2}, -- spell2
			{37307, 1, CONST_SLOT_SPELL3}, -- spell3
		}
	},
	[2] = { -- Guard
		items = {
			{36666, 1}, -- sword
		},
		spells = {
			{37308, 1, CONST_SLOT_SPELL1}, -- Colossal Grasp
			{37309, 1, CONST_SLOT_SPELL2}, -- Ground Slam
			{37310, 1, CONST_SLOT_SPELL3}, -- Colossus Rampage
		}
	},
	[3] = { -- Hunter
		items = {
			{2456, 1}, -- bow
		},
		spells = {
			{37311, 1, CONST_SLOT_SPELL1}, -- Rapid Fire
			{37312, 1, CONST_SLOT_SPELL2}, -- Arrow Volley
			{37313, 1, CONST_SLOT_SPELL3}, -- Arrow Rain
		},
	},
	[4] = { -- Assassin
		items = {
			{36666, 1}, -- sword
		},
		spells = {
			{37314, 1, CONST_SLOT_SPELL1}, -- Shadowstep
			{37315, 1, CONST_SLOT_SPELL2}, -- Blade Fan
			{37316, 1, CONST_SLOT_SPELL3}, -- Death Mark
		},
	},
	[5] = { -- Cleric
		items = {
			{26637, 1}, -- wooden rod
		},
		spells = {
			{37317, 1, CONST_SLOT_SPELL1}, -- Heal
			{37318, 1, CONST_SLOT_SPELL2}, -- Holy Smite
			{37319, 1, CONST_SLOT_SPELL3}, -- Divine Judgement
		},
	},
	[6] = { -- Spellblade
		items = {
			{2390, 1}, -- spellblade sword (range 2)
		},
		spells = {
			{37320, 1, CONST_SLOT_SPELL1}, -- Arcane Cleave
			{37321, 1, CONST_SLOT_SPELL2}, -- Arcane Aura
			{37322, 1, CONST_SLOT_SPELL3}, -- Arcane Strike
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
		if item then
			item:setRarity(0)
			item:setCustomAttribute("level", 0)
			item:setCustomAttribute("startingSpell", 1)
		end
	end

	player:setStorageValue(PlayerStorage.maxSpellLevelReached, math.max(1, player:getLevel()))
	player:addItem(7618, 1, true, 1, CONST_SLOT_POTION1)
	player:addItem(1988, 1, true, 1, CONST_SLOT_BACKPACK)
	player:startTask(1)
	return true
end
