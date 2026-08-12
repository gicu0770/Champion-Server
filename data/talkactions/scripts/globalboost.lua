function onSay(player, words, param)
	if not player:getGroup():getAccess() then
		return true
	end

	if player:getAccountType() < ACCOUNT_TYPE_GOD then
		return false
	end

	local godziny = tonumber(param)
	local currentTime = godziny * 3600000
	for _, targetPlayer in ipairs(Game.getPlayers()) do
		local buffMessage = string.format("Player %s activated {All GLOBAL BOOST} for {"..param.."}!", player:getName())
		targetPlayer:sendExtendedOpcode(71, json.encode({text = buffMessage, color = "#f7ef8a"}))
	end
	addGlobalBuff(BUFF_GLOBAL_EXP, currentTime)
	addGlobalBuff(BUFF_GLOBAL_GOLD, currentTime)
	addGlobalBuff(BUFF_GLOBAL_LOOT, currentTime)

	return false
end
