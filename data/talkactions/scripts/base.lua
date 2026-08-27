function onSay(player, words, param)
	if not player:getGroup():getAccess() then
		return true
	end
	if player:getAccountType() < ACCOUNT_TYPE_GOD then
		return false
	end

	if param:lower():trim() == "all" then
		local backpack = Game.createItem(1988, 1)
		if not backpack then
			player:sendCancelMessage("Failed to create backpack.")
			return false
		end

		local count = 0
		local sortedLevels = {}
		for level in pairs(BASE_ITEMS) do
			table.insert(sortedLevels, level)
		end
		table.sort(sortedLevels)

		for _, level in ipairs(sortedLevels) do
			local items = BASE_ITEMS[level]
			if items then
				for _, baseData in ipairs(items) do
					local item = generateBaseItem(player, 0, baseData, level, 0)
					if item then
						if backpack:addItemEx(item, INDEX_WHEREEVER, FLAG_NOLIMIT) ~= RETURNVALUE_NOERROR then
							player:addItemEx(item)
						end
						count = count + 1
					end
				end
			end
		end

		if player:addItemEx(backpack) ~= RETURNVALUE_NOERROR then
			backpack:moveTo(player:getPosition())
			player:sendTextMessage(MESSAGE_INFO_DESCR, string.format("Backpack with %d Base Items dropped on the ground.", count))
		else
			player:sendTextMessage(MESSAGE_INFO_DESCR, string.format("You received a backpack with all %d Base Items (with implicits).", count))
		end
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