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

	if player:getName() == "Abuser" or player:getName() == "Gicu" then

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
		local rarity = split[3] and tonumber(split[3]) or nil
		local upgradeLevel = split[4] and tonumber(split[4]) or nil
		local quality = split[5] and tonumber(split[5]) or nil
		
		for i = 1, count do
		
			local result = player:addItem(itemType:getId())
		if not result:getType():isUpgradable() and not result:getType():canHaveItemLevel() then
		 return false
		end
			if result then
				if rarity then
					result:setRarity(rarity)
				end
				if upgradeLevel then
					result:setUpgradeLevel(upgradeLevel)
				end
				
				if isInArray(TIER_1_IDS, result:getId()) then
					result:setTier(1)
				elseif isInArray(TIER_2_IDS, result:getId()) then
					result:setTier(2)
				elseif isInArray(TIER_3_IDS, result:getId()) then
					result:setTier(3)
				elseif isInArray(TIER_4_IDS, result:getId()) then
					result:setTier(4)
				elseif isInArray(TIER_5_IDS, result:getId()) then
					result:setTier(5)
				elseif isInArray(TIER_6_IDS, result:getId()) then
					result:setTier(6)
				elseif isInArray(TIER_7_IDS, result:getId()) then
					result:setTier(7)
				elseif isInArray(TIER_8_IDS, result:getId()) then
					result:setTier(8)
				end
			if result:getTier() then
			 local tierAttack = 30 + (result:getTier()*20)
			 local tierArmor = (result:getTier()*20) - 5
			 local tierDefense = 10 + (result:getTier()*20)
			 setAncientItemAttackArmorDefense(player, result, tierAttack, tierArmor, tierDefense, 1)
			 local tierItemLevel = 20 + (result:getTier()*50)
			 result:setItemLevel(tierItemLevel)	
			 local slots = result:getMaxAttributes()
			 for i = 1, slots do
			 result:rollAttribute()
			end
			 if quality then
				result:setQuality(quality)
			 end
			end
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
		end
	return false
end
