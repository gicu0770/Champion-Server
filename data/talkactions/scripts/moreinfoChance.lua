function onSay(player, words, param)
if player:getStorageValue(PlayerStorage.moreInfoChances) == 1 then
	player:sendTextMessage(MESSAGE_INFO_DESCR,"More Info about Chances OFF")
	player:setStorageValue(PlayerStorage.moreInfoChances, -1)
	player:openChannel(17)
	else
	player:sendTextMessage(MESSAGE_INFO_DESCR,"More Info about Chances ON")
	player:setStorageValue(PlayerStorage.moreInfoChances, 1)
	player:openChannel(17)
end
	return false
end