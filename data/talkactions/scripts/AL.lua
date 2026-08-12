
function onSay(player, words, param)
	if not player:getGroup():getAccess() then
		return true
	end

	if player:getAccountType() < ACCOUNT_TYPE_GOD then
		return false
	end
	local split = param:splitTrimmed(",")
	if not split[2] then
		player:sendCancelMessage("Insufficient parameters.")
		return false
	end

	local target = Player(split[1])
	if not target then
		player:sendCancelMessage("A player with that name is not online.")
		return false
	end
	target:setStorageValue(PlayerStorage.autolootrarity, os.time() + 60)
	target:setStorageValue(PlayerStorage.autolootindifity, os.time() + 60)
	target:sendTextMessage(MESSAGE_INFO_DESCR,"Added 60s auto indifity items.")
	
return false
end