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

	player:sendTextMessage(MESSAGE_INFO_DESCR, "You added Forge materials.")
	local storageValues = {802000, 802001, 802004, 802014, 802011, 802012, 802008, PlayerStorage.forgePowder5, PlayerStorage.forgePowder4, PlayerStorage.forgePowder3, PlayerStorage.forgePowder2, PlayerStorage.forgePowder1, 802009, 802010, 802013}

	for _, storage in ipairs(storageValues) do
		target:setStorageValue(storage, count)
	end
	
	return false
end
