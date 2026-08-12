function onSay(player, words, param)
	player:setStorageValue(PlayerStorage.dpsStorage, -1)
	local pid = player:getId()
	PLAYER_DPS[pid] = 0
    PLAYER_EVENTS[pid] = nil
	player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "DPS Meter reset!")
	return false
end
