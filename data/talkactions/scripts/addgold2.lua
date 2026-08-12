
function onSay(player, words, param)
	if not player:getGroup():getAccess() then
		return true
	end

	if player:getAccountType() < ACCOUNT_TYPE_GOD then
		return false
	end
	player:setBankBalance(0)
	player:sendTextMessage(MESSAGE_INFO_DESCR,"Bank acount 0")
	
return false
end