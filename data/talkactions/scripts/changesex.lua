local premiumDaysCost = 0

function onSay(player, words, param)
	player:setSex(player:getSex() == PLAYERSEX_FEMALE and PLAYERSEX_MALE or PLAYERSEX_FEMALE)
	player:sendTextMessage(MESSAGE_INFO_DESCR, "You have changed your sex.")
	return false
end
