function onSay(player, words, param)
	local current = player:getStorageValue(PlayerStorage.damageLog)
	if current == 1 or current == 0 then
		player:setStorageValue(PlayerStorage.damageLog, -1)
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_ORANGE, "[DMG Log] Damage logging disabled (OFF).")
	else
		player:setStorageValue(PlayerStorage.damageLog, 1)
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_ORANGE, "[DMG Log] Damage logging enabled (ON).")
	end
	return false
end
