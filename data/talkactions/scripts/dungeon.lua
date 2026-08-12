function onSay(player, words, param)
	if not player:getGroup():getAccess() then
		return true
	end

	if player:getAccountType() < ACCOUNT_TYPE_GOD then
		return false
	end

	local split = param:splitTrimmed(",")
	if not split[2] then
		player:sendCancelMessage("Insufficient parameters.")
		return false
	end

	local target = Player(split[1])
	if not target then
		player:sendCancelMessage("A player with that name is not online.")
		return false
	end

	player:sendTextMessage(MESSAGE_INFO_DESCR, "You added dungeon difficulty to player "..target:getName()..".")
	target:sendTextMessage(MESSAGE_INFO_DESCR, "You obtain difficulty.")

	for i = 1, 30 do
		target:setStorageValue(PlayerStorage.dungeonsDifficulty + i, 6)
	end
	
	return false
end
