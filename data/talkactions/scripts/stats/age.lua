function onSay(player, words, param)
	local time = os.time() - player:getFirstLogin() 
	player:sendTextMessage(MESSAGE_EVENT_DEFAULT, "Your character was created " .. format_ms(time * 1000) .. " ago.")
	return false
end