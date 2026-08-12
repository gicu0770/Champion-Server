function onSay(player, words, param)
if player:getStorageValue(PlayerStorage.moreInfo) == 1 then
	player:sendTextMessage(MESSAGE_INFO_DESCR,"More Info OFF")
	player:setStorageValue(PlayerStorage.moreInfo, -1)
	player:openChannel(17)
	else
	player:sendTextMessage(MESSAGE_INFO_DESCR,"More Info ON")
	player:setStorageValue(PlayerStorage.moreInfo, 1)
	player:openChannel(17)
end
	return false
end