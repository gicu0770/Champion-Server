function onSay(player, words, param)
if player:getStorageValue(PlayerStorage.moreInfoMonster) == 1 then
	player:sendTextMessage(MESSAGE_INFO_DESCR,"More Monster Info OFF\nIf you click on moster see more details.")
	player:setStorageValue(PlayerStorage.moreInfoMonster, -1)
	player:openChannel(17)
	else
	player:sendTextMessage(MESSAGE_INFO_DESCR,"More Monster Info ON\nIf you click on moster see more details.")
	player:setStorageValue(PlayerStorage.moreInfoMonster, 1)
	player:openChannel(17)
end
	return false
end