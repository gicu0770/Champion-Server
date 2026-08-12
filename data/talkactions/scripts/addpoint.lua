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

	local count = 1
	if split[2] then
		count = tonumber(split[2])
	end

	player:sendTextMessage(MESSAGE_INFO_DESCR, "You added points to player "..target:getName()..".")
	target:sendTextMessage(MESSAGE_INFO_DESCR, "You obtain points.")
	target:addStatsPoints(count)
	
	return false
end
