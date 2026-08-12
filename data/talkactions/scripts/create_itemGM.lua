local invalidIds = {
	1,
	2,
	3,
	4,
	5,
	6,
	7,
	10,
	11,
	13,
	14,
	15,
	19,
	21,
	26,
	27,
	28,
	35,
	43
}

function onSay(player, words, param)
	if not player:getGroup():getAccess() then
		return true
	end

	if player:getAccountType() < ACCOUNT_TYPE_GOD then
		return false
	end

	logCommand(player, words, param)

	local split = param:split(",")

	local itemType = ItemType(split[1])
	if itemType:getId() == 0 then
		itemType = ItemType(tonumber(split[1]))
		if not tonumber(split[1]) or itemType:getId() == 0 then
			player:sendCancelMessage("There is no item with that id or name.")
			return false
		end
	end

	if table.contains(invalidIds, itemType:getId()) then
		return false
	end

	local count = tonumber(split[2])
	if count then
		if itemType:isStackable() then
			count = math.min(10000, math.max(1, count))
		elseif not itemType:isFluidContainer() then
			count = math.min(100, math.max(1, count))
		else
			count = math.max(0, count)
		end
	else
		if not itemType:isFluidContainer() then
			count = 1
		else
			count = 0
		end
	end

	local created = false
	if itemType:isFluidContainer() then
		local result = player:addItem(itemType:getId(), count)
		if result then
			created = true
		end
	else
		local rarity = split[3] and tonumber(split[3]) or 0
		local upgradeLevel = split[4] and tonumber(split[4]) or 0
		local quality = split[5] and tonumber(split[5]) or 0
		local ancient = split[6] and tonumber(split[6]) or 0
		local dungeon = split[7] and tonumber(split[7]) or 0
		local fusion = split[8] and tonumber(split[8]) or 0
		local influenced = split[9] and tonumber(split[9]) or 0
		local soulshard = split[10] and tonumber(split[10]) or 0
		local soulshardlevel = split[11] and tonumber(split[11]) or 0
		local craft = split[12] and tonumber(split[12]) or 0
		
		-- /ii item, count, rarity(1-7), upgradeLevel(0-15), quality(0-50), ancient(0-3), dungeon(0-6), fusion(0-10), influenced(0,6), soulsahrd(0,9), soulshardlevel(0,5) craft(0-100)
		
		for i = 1, count do
			local result = player:addItem(itemType:getId())
			if result then
				
				setLootItemGM(player, result, rarity, upgradeLevel, quality, ancient, dungeon, fusion, influenced, soulshard, soulshardlevel, craft)

				if not itemType:isStackable() then
					if type(result) == "table" then
						for _, item in ipairs(result) do
							item:decay()
						end
					else
						result:decay()
					end
				end
				created = true
			end
		end
	end

	if created then
		player:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)
	end
	return false
end
