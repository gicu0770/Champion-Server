function onSay(player, words, param)
	if not player:getGroup():getAccess() then
		return true
	end
	if player:getAccountType() < ACCOUNT_TYPE_GOD then
		return false
	end

	local params = param:split(",")
	local monsterLevel = tonumber(params[2])
	local itemId = tonumber(params[1])
	if not monsterLevel or not itemId then return end

	for i = 1, #SERVER_BASE_ITEMS[monsterLevel] do
		if SERVER_BASE_ITEMS[monsterLevel][i][2] == itemId then
			randBase = SERVER_BASE_ITEMS[monsterLevel][i]
			break
		end
	end

	local baseItem = generateBaseItem(player, 0, randBase, monsterLevel, 0)
	if baseItem then
		player:addItemEx(baseItem)
		player:sendTextMessage(MESSAGE_INFO_DESCR, "You have received a base item.")
	else
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Invalid base item id.")
	end

	return true
end