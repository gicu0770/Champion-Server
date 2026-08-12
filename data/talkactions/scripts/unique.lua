function onSay(player, words, param)
	if not player:getGroup():getAccess() then
		return true
	end
	if player:getAccountType() < ACCOUNT_TYPE_GOD then
		return false
	end

	local params = param:split(",")
	local uniqueId = tonumber(params[1])
	if not uniqueId then return end

	local uniqueItem = generateUniqueItem(player, uniqueId, params[2])
	if uniqueItem then
		player:addItemEx(uniqueItem)
		player:sendTextMessage(MESSAGE_INFO_DESCR, "You have received a unique item.")
	else
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Invalid unique item id.")
	end

	return true
end