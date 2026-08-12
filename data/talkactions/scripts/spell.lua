function onSay(player, words, param)
	local text = {}
	local spells = {}
	for _, spell in ipairs(player:getInstantSpells()) do
		if spell.level ~= 0 then
	--	spell.mojstary = "stary"
			if spell.manapercent > 0 then
				spell.mana = spell.manapercent .. "%"
			end
			spells[#spells + 1] = spell
		end
	end

	table.sort(spells, function(a, b) return a.level < b.level end)

	player:sendExtendedOpcode(212, json.encode({spells = spells}))
	return false
end