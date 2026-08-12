function onSay(player, words, param)
	local deaths = player:getDeaths()
	local message = "You have died " .. deaths .. " times."
	player:sendTextMessage(MESSAGE_EVENT_DEFAULT, message)
	return false
end