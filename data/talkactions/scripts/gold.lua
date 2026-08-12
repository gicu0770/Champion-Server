
function onSay(player, words, param)
	if not player:getGroup():getAccess() then
		return true
	end

	if player:getAccountType() < ACCOUNT_TYPE_GOD then
		return false
	end

	local target = Player(param)
	if not target then
		player:sendCancelMessage("A player with that name is not online.")
		return false
	end
	local target = Player(param)
	local account = target:getBankBalance()
	player:sendTextMessage(MESSAGE_INFO_DESCR,""..param.." have "..account.." gold")
	
return false
end