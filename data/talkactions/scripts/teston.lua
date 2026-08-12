function onSay(player, words, param)
	if not player:getGroup():getAccess() then
		return true
	end

	if player:getAccountType() < ACCOUNT_TYPE_GOD then
		return false
	end
	player:setStorageValue(PlayerStorage.testRate, param)
	player:sendTextMessage(MESSAGE_INFO_DESCR,"Test ON exp x"..param..", loot 100% drop, legendary+, Upgrade material 100% and tickets.")
	return false
end