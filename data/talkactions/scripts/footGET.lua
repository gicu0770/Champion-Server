
function onSay(player, words, param)
	if not player:getGroup():getAccess() then
		return true
	end

	if player:getAccountType() < ACCOUNT_TYPE_GOD then
		return false
	end

	for i = 1, 50 do
		player:setStorageValue(PlayerStorage.footPrints + i, 1)
	end
	player:sendTextMessage(MESSAGE_INFO_DESCR,"Added all footprints")
	
return false
end