function onSay(player, words, param)
	local time = player:getOnlineTime()
	local nowOnline = os.time() - player:getLastLoginSaved()
	player:sendTextMessage(MESSAGE_EVENT_DEFAULT, "You have played for " .. format_ms((time + nowOnline) * 1000) .. ".")
	return false
end