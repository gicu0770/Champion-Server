
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
	local WAYPOINTS_STORAGE = 41875
	for i = 1, #WAYPOINTS do
	 local sto = target:getStorageValue(WAYPOINTS_STORAGE)
	 target:setStorageValue(WAYPOINTS_STORAGE+i,1)
	end
--	local points = 10000
--	db.query('UPDATE znote_accounts SET points=points+'.. points ..' WHERE account_id=' .. target:getAccountId() ..' LIMIT 1;')
	player:sendTextMessage(MESSAGE_INFO_DESCR,"Added all waypints to you.")
	
return false
end