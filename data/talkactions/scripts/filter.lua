function onSay(player, words, param)
	local affixName = tostring(param)
	local affixId = 0
	for i = 1, #US_ENCHANTMENTS do
		if US_ENCHANTMENTS[i].name == affixName then
			affixName = US_ENCHANTMENTS[i].name
			affixId = i
			break
		end
	end
	if affixName == "none" then
	--	player:sendTextMessage(MESSAGE_INFO_DESCR, "Wrong affix name.")
		player:sendTooltipMessage("Filter: Wrong affix name.")
		return false
	end

	player:setStorageValue(PlayerStorage.filter, affixId)
	player:sendTooltipMessage("Filter: Mark items with "..affixName.." affix.")
	return false
end
