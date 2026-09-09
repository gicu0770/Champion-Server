function onSay(player, words, param)
	local kills = player:getKills()
	local message = "You have killed " .. kills .. " players."
	player:sendTextMessage(MESSAGE_EVENT_DEFAULT, message)
	return false
end