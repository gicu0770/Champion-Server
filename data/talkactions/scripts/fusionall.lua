function onSay(player, words, param)
	if not player:getGroup():getAccess() and player:getAccountType() < ACCOUNT_TYPE_GOD then
		return true
	end

	if not RECOMB_ITEM_RECIPES or #RECOMB_ITEM_RECIPES == 0 then
		player:sendCancelMessage("No Fusion Altar recipes found.")
		return false
	end

	param = param and param:lower():trim() or ""

	-- If parameter is "mats", "materials", or "ingredients", spawn all required ingredients
	if param == "mats" or param == "materials" or param == "ingredients" or param == "skladniki" then
		local backpack = Game.createItem(1988, 1)
		if not backpack then
			player:sendCancelMessage("Failed to create backpack.")
			return false
		end

		local totalMatsCount = 0
		local currentBag = backpack
		local itemsInCurrentBag = 0

		for _, recipe in ipairs(RECOMB_ITEM_RECIPES) do
			if recipe.items then
				for _, matId in ipairs(recipe.items) do
					local matItem = Game.createItem(matId, 1)
					if matItem then
						matItem:setCustomAttribute("checksum", ITEM_CHECKSUM)
						if itemsInCurrentBag >= 19 then
							local nextBag = Game.createItem(1988, 1)
							if nextBag then
								currentBag:addItemEx(nextBag, INDEX_WHEREEVER, FLAG_NOLIMIT)
								currentBag = nextBag
								itemsInCurrentBag = 0
							end
						end

						if currentBag:addItemEx(matItem, INDEX_WHEREEVER, FLAG_NOLIMIT) ~= RETURNVALUE_NOERROR then
							player:addItemEx(matItem)
						end
						itemsInCurrentBag = itemsInCurrentBag + 1
						totalMatsCount = totalMatsCount + 1
					end
				end
			end
		end

		if player:addItemEx(backpack) ~= RETURNVALUE_NOERROR then
			backpack:moveTo(player:getPosition())
			player:sendTextMessage(MESSAGE_INFO_DESCR, string.format("Backpack with %d Fusion Altar ingredients dropped on the ground.", totalMatsCount))
		else
			player:sendTextMessage(MESSAGE_INFO_DESCR, string.format("You received a backpack with %d ingredients for all Fusion Altar recipes.", totalMatsCount))
		end

		player:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)
		return false
	end

	-- Default: Generate all crafted recipe result items with full stats, implicits, level and passives
	local backpack = Game.createItem(1988, 1)
	if not backpack then
		player:sendCancelMessage("Failed to create backpack.")
		return false
	end

	local count = 0
	local currentBag = backpack
	local itemsInCurrentBag = 0

	for _, recipeData in ipairs(RECOMB_ITEM_RECIPES) do
		local item = generateRecipeResultItem(recipeData)
		if item then
			-- If current backpack is nearing full capacity (19 slots), nest a new backpack
			if itemsInCurrentBag >= 19 then
				local nextBag = Game.createItem(1988, 1)
				if nextBag then
					currentBag:addItemEx(nextBag, INDEX_WHEREEVER, FLAG_NOLIMIT)
					currentBag = nextBag
					itemsInCurrentBag = 0
				end
			end

			if currentBag:addItemEx(item, INDEX_WHEREEVER, FLAG_NOLIMIT) ~= RETURNVALUE_NOERROR then
				player:addItemEx(item)
			end
			itemsInCurrentBag = itemsInCurrentBag + 1
			count = count + 1
		end
	end

	if player:addItemEx(backpack) ~= RETURNVALUE_NOERROR then
		backpack:moveTo(player:getPosition())
		player:sendTextMessage(MESSAGE_INFO_DESCR, string.format("Backpack with %d Fusion Altar items dropped on the ground.", count))
	else
		player:sendTextMessage(MESSAGE_INFO_DESCR, string.format("You received a backpack with all %d Fusion Altar recipe items (with implicits & passives).", count))
	end

	player:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)
	return false
end
