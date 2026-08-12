function onSay(player, words, param)
	if not player:getGroup():getAccess() then
		return true
	end
	if player:getAccountType() < ACCOUNT_TYPE_GOD then
		return false
	end
	local position = player:getPosition()
	position:getNextPosition(player:getDirection())

	local tile = Tile(position)
	if not tile then
		player:sendCancelMessage("Object not found.")
		return false
	end

	local thing = tile:getTopVisibleThing(player)
	if not thing then
		player:sendCancelMessage("Thing not found.")
		return false
	end

	if thing:isItem() then
		if thing == tile:getGround() then
			return false
		end
		thing:setRarity(tonumber(param))
		local itemType = ItemType(thing.itemid)
		local weaponType = itemType:getWeaponType()
	--	thing:rollAttribute(player, itemType, weaponType, true)
	--	fixItem(player, thing)

		thing:setAttribute(ITEM_ATTRIBUTE_ATTACK, thing:getAttribute(ITEM_ATTRIBUTE_ATTACK) + (9 * 8))
		player:getPosition():sendMagicEffect(50)
	end
	return true
end

function fixItem(player, item)
	if item:getId() == 0 then return end
	if player then
		if item:getType():isUpgradable() then
			local tier = item:getTier()	
			if tier == 0 then tier = 0.6 end
			local tierAttack = (tier * 40) + 10
			local tierArmor = (tier * 50) - 35
			local tierDefense = (tier	 * 60) - 30
			if tier == 7 then
				tierAttack = tierAttack + 40
				tierArmor = tierArmor + 30
				tierDefense = tierDefense + 30
			elseif tier == 8 then
				tierAttack = tierAttack + 120
				tierArmor = tierArmor + 80
				tierDefense = tierDefense + 80
			elseif tier == 9 then
				tierAttack = tierAttack + 210
				tierArmor = tierArmor + 140
				tierDefense = tierDefense + 140
			elseif tier == 10 then
				tierAttack = tierAttack + 300
				tierArmor = tierArmor + 200
				tierDefense = tierDefense + 200
			end
			local increasedAllstats = 0
			setAncientItemAttackArmorDefense(player, item, tierAttack, tierArmor, tierDefense, 1)
			if item:isDungeonItem() then
				increasedAllstats = increasedAllstats + DUNGEON_ITEMS_STATS[item:getDungeonItem()]
			end 

			if item:isCraftBonus() then
				increasedAllstats = increasedAllstats + ((item:getCraftBonus() / 4) / 100)
			end

			if item:getRarityId() >= 2 then
				increasedAllstats = increasedAllstats + RARITY_IMPLICT[item:getRarityId()]
			end

			if item:getVocationReq() == 0 then
				increasedAllstats = increasedAllstats + 0.25
			end

			

			item:setImplicit(increasedAllstats)
			setItemStatsPercent(player, item, increasedAllstats, false, 1300, 1500)
		end
	end
	return true
end