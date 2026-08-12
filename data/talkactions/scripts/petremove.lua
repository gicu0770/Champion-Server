function onSay(player, words, param)
	RemovePets(player)
	player:getPosition():sendMagicEffect(50)
	player:sendTextMessage(MESSAGE_INFO_DESCR,"Pet Recall")
	return false
end
