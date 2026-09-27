function onSay(player, words, param)
	if not player:getGroup():getAccess() and player:getAccountType() < ACCOUNT_TYPE_GOD then
		return true
	end

	if not RECOMB_ITEM_RECIPES or #RECOMB_ITEM_RECIPES == 0 then
		player:sendCancelMessage("No Fusion Altar recipes found.")
		return false
	end

	param = param and param:lower():trim() or ""

	local EVIL_BACKPACK_ID = 38508

	-- If parameter is "mats", "materials", "ingredients", or "skladniki", spawn all required ingredients in a single Evil Backpack
	if param == "mats" or param == "materials" or param == "ingredients" or param == "skladniki" then
		local backpack = Game.createItem(EVIL_BACKPACK_ID, 1)
		if not backpack then
			player:sendCancelMessage("Failed to create Evil Backpack.")
			return false
		end

		local orderedMats = {}
		local addedMatIds = {}

		-- Collect all unique ingredients required across recipes
		for _, recipe in ipairs(RECOMB_ITEM_RECIPES) do
			if recipe.items then
				for _, matId in ipairs(recipe.items) do
					if not addedMatIds[matId] then
						addedMatIds[matId] = true
						-- If an intermediate recipe exists for this ingredient, use its generated stats/implicits
						local matItem = nil
						for _, rec in ipairs(RECOMB_ITEM_RECIPES) do
							if rec.result == matId then
								matItem = generateRecipeResultItem(rec)
								break
							end
						end
						if not matItem then
							matItem = Game.createItem(matId, 1)
							if matItem then
								matItem:setCustomAttribute("checksum", ITEM_CHECKSUM)
							end
						end
						if matItem then
							table.insert(orderedMats, matItem)
						end
					end
				end
			end
		end

		-- Insert in reverse order so first collected ingredient appears in slot 0
		for i = #orderedMats, 1, -1 do
			local it = orderedMats[i]
			if backpack:addItemEx(it, INDEX_WHEREEVER, FLAG_NOLIMIT) ~= RETURNVALUE_NOERROR then
				player:addItemEx(it)
			end
		end

		if player:addItemEx(backpack) ~= RETURNVALUE_NOERROR then
			backpack:moveTo(player:getPosition())
			player:sendTextMessage(MESSAGE_INFO_DESCR, string.format("Evil Backpack with %d Fusion Altar ingredients dropped on the ground.", #orderedMats))
		else
			player:sendTextMessage(MESSAGE_INFO_DESCR, string.format("You received an Evil Backpack with %d unique Fusion Altar ingredients.", #orderedMats))
		end

		player:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)
		return false
	end

	-- Default /fusionall:
	-- Creates ONE single Evil Backpack containing:
	-- 1. Gotowe legendarne przedmioty (Ready Legendary items with full stats, implicits & passives)
	-- 2. Skladniki (Crafting ingredients / intermediate recipe items not in BASE_ITEMS)
	-- 3. Bazowe przedmioty wypadajace z mobow (Base items from BASE_ITEMS with implicits)

	local backpack = Game.createItem(EVIL_BACKPACK_ID, 1)
	if not backpack then
		player:sendCancelMessage("Failed to create Evil Backpack.")
		return false
	end

	local orderedItems = {}

	-- 1. Gotowe legendarne przedmioty (rarity >= 4)
	for _, recipeData in ipairs(RECOMB_ITEM_RECIPES) do
		if recipeData.rarity and recipeData.rarity >= 4 then
			local item = generateRecipeResultItem(recipeData)
			if item then
				table.insert(orderedItems, item)
			end
		end
	end

	-- Track base item IDs from BASE_ITEMS
	local baseItemIds = {}
	if BASE_ITEMS then
		for _, items in pairs(BASE_ITEMS) do
			for _, baseData in ipairs(items) do
				baseItemIds[baseData[2]] = true
			end
		end
	end

	-- 2. Skladniki i komponenty posrednie z receptur (ktore nie sa w BASE_ITEMS)
	local addedIngredientIds = {}
	for _, recipeData in ipairs(RECOMB_ITEM_RECIPES) do
		if (not recipeData.rarity or recipeData.rarity < 4) and not baseItemIds[recipeData.result] then
			if not addedIngredientIds[recipeData.result] then
				addedIngredientIds[recipeData.result] = true
				local item = generateRecipeResultItem(recipeData)
				if item then
					table.insert(orderedItems, item)
				end
			end
		end
	end

	-- Pozostale surowe skladniki (np. Spellbook 2175, Platinum Coin 2152 itp.)
	for _, recipeData in ipairs(RECOMB_ITEM_RECIPES) do
		if recipeData.items then
			for _, matId in ipairs(recipeData.items) do
				if not baseItemIds[matId] and not addedIngredientIds[matId] then
					addedIngredientIds[matId] = true
					local matItem = Game.createItem(matId, 1)
					if matItem then
						matItem:setCustomAttribute("checksum", ITEM_CHECKSUM)
						table.insert(orderedItems, matItem)
					end
				end
			end
		end
	end

	-- 3. Bazowe przedmioty wypadajace z mobow (BASE_ITEMS uporzadkowane wg tieru poziomu)
	if BASE_ITEMS then
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
						table.insert(orderedItems, item)
					end
				end
			end
		end
	end

	-- TFS Container::internalAddThing pushes to the front (itemlist.push_front),
	-- so we insert in reverse order to ensure orderedItems[1] is at visual slot 0.
	for i = #orderedItems, 1, -1 do
		local item = orderedItems[i]
		if backpack:addItemEx(item, INDEX_WHEREEVER, FLAG_NOLIMIT) ~= RETURNVALUE_NOERROR then
			player:addItemEx(item)
		end
	end

	if player:addItemEx(backpack) ~= RETURNVALUE_NOERROR then
		backpack:moveTo(player:getPosition())
		player:sendTextMessage(MESSAGE_INFO_DESCR, string.format("Evil Backpack with %d Fusion Altar & Base items dropped on the ground.", #orderedItems))
	else
		player:sendTextMessage(MESSAGE_INFO_DESCR, string.format("You received an Evil Backpack with %d items (Legendaries, Ingredients & Base Items).", #orderedItems))
	end

	player:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)
	return false
end
