function onSay(player, words, param)
	local kills = player:getKills()
	local message = "You have killed " .. kills .. " monsters."
	player:sendTextMessage(MESSAGE_EVENT_DEFAULT, message)
	return false
end