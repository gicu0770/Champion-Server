function onSay(player, words, param)
	if not player:getGroup():getAccess() then
		return true
	end

	if player:getAccountType() < ACCOUNT_TYPE_GOD then
		return false
	end

	local target = Player(param)
	if not target then
		player:sendCancelMessage("A player with that name could not be found.")
		return false
	end

	player:sendTextMessage(MESSAGE_INFO_DESCR, "You added shader to player "..target:getName()..".")
	target:sendTextMessage(MESSAGE_INFO_DESCR, "You obtain shader.")
	target:addShader(2)
	
	return false
end
