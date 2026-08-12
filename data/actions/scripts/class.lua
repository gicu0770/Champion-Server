function onUse(player, item, fromPosition, itemEx, toPosition)
	if item.itemid == 8671 and item.actionid >= 10554 and item.actionid <= 10557 then
		--	Item(item.uid):transform(item.itemid == 9825 and 9826 or 9825)


		local mainItem = Position(670, 1034, 6) -- Główny item
		local rightItem = Position(671, 1034, 6) -- prawy item

		if item.actionid == 10555 then
			mainItem = Position(673, 1034, 6)
			rightItem = Position(674, 1034, 6)
		elseif item.actionid == 10556 then
			mainItem = Position(676, 1034, 6)
			rightItem = Position(677, 1034, 6)
		elseif item.actionid == 10557 then
			mainItem = Position(679, 1034, 6)
			rightItem = Position(680, 1034, 6)
		end


		local tilemain = Tile(mainItem)
		--	local tileleft = Tile(leftItem)
		local tileright = Tile(rightItem)
		local thingM = tilemain:getTopVisibleThing(player)
		--	local thingL = tileleft:getTopVisibleThing(player)
		local thingR = tileright:getTopVisibleThing(player)
		if thingM:getId() == 0 then return end
		-- if thingL:getId() == 0 then return end
		if thingR:getId() == 0 then return end

		if thingM:isItem() and thingR:isItem() then -- and thingL:isItem()
			local itemType = ItemType(thingM:getId())
			if thingM:isCorrupted() then
				player:sendTextMessage(MESSAGE_STATUS_WARNING, "Sorry, this item is corrupted and can't be modified!")
				player:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
				return true
			end

			if thingR:getRarityId() <= 2 then --	jesli ma 2 takie same poziomy fuzion // takei same rarity lub wyzsze
				player:sendTextMessage(MESSAGE_INFO_DESCR, "Right item have other Rarity!")
				return false
			end

			if thingM:getRarityId() >= 3 and thingR:getRarityId() >= 3 then
				if thingM:getClassItemLevel() <= 9 then
					--  if thingM:getRarityId() ~= thingR:getRarityId() then player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Right item must by same rarity!") return false end
					if thingM:getId() == thingR:getId() then --	jesli sa 2 takie same ID
						local tier_cost = {
							[0] = 100,
							[1] = 120,
							[2] = 200,
							[3] = 300,
							[4] = 400,
							[5] = 500,
							[6] = 600,
							[7] = 800,
							[8] = 1000,
							[9] = 2000,
							[10] = 3000
						}
						player:sendTextMessage(MESSAGE_INFO_DESCR, "Cost: "..tier_cost[thingM:getTier()].." you balance after merge: "..getPlayerMoney(player).."")
						if getPlayerMoney(player) >= (tier_cost[thingM:getTier()] * (thingM:getClassItemLevel() + 1)) then
							if math.random(100) < 50 then
								player:sendTextMessage(MESSAGE_INFO_DESCR, "You " .. thingM:getName() .." successful upgraded!")
								thingM:getPosition():sendMagicEffect(50)
								thingR:remove()
								thingM:setClassItemLevel(thingM:getClassItemLevel() + 1)

								thingM:setClassItem(thingM:getClassItem() + 1) -- nawjwazniejsze

								thingM:setFusionLevel(thingM:getClassItemLevel())


								local increasedAllstats = 0
								if thingM:isDungeonItem() then
									increasedAllstats = increasedAllstats + DUNGEON_ITEMS_STATS[thingM:getDungeonItem()] -- 50%
								end
								if thingM:isCraftBonus() then
									increasedAllstats = increasedAllstats + ((thingM:getCraftBonus() / 4) / 100) -- 25%
								end
								if thingM:getRarityId() >= 2 then
									increasedAllstats = increasedAllstats + RARITY_IMPLICT[thingM:getRarityId()]
								end
								if thingM:isQuality() then
									increasedAllstats = increasedAllstats + (thingM:isQuality() / 100)
								end
								if thingM:getArenaScalingLevel() then
									increasedAllstats = increasedAllstats + (ENCHANTMENT_ORB_ITEMS[thingM:getArenaScalingLevel()] / 100)
								end
								if thingM:getClassItem() then
									increasedAllstats = increasedAllstats + (ENCHANTMENT_ORB_ITEMS[thingM:getClassItem()] / 100)
								end
								thingM:setImplicit(increasedAllstats)
								setItemStatsPercent(player, thingM, increasedAllstats)


								player:sendExtendedOpcode(105, json.encode({ reload = "reload" }))
								player:removeTotalMoney(tier_cost[thingM:getTier()])
								if player:getStorageValue(PlayerStorage.animatedTalentSkills) == -1 then
									player:getPosition():sendMagicEffect(325)
								else
									Game.sendAnimatedText('Success!', player:getPosition(), 192,"Reggae One-20px-bordered")
								end
							else
								player:sendTextMessage(MESSAGE_INFO_DESCR, "FAILED")
								Game.sendAnimatedText('Failed!', player:getPosition(), 192, "Reggae One-20px-bordered")
								thingR:remove(1)
								player:getPosition():sendMagicEffect(326)
								player:removeTotalMoney(tier_cost[thingM:getTier()])
							end
						else
							player:sendTextMessage(MESSAGE_INFO_DESCR, "You don't have enough money! Cost: "..tier_cost[thingM:getTier()].."")
						end
					else
						player:sendTextMessage(MESSAGE_INFO_DESCR, "Right item is other must be same Item!")
					end
				else
					player:sendTextMessage(MESSAGE_INFO_DESCR, "Maximum Merge Upgrade Level!")
				end
			else
				player:sendTextMessage(MESSAGE_INFO_DESCR, "Merge Upgrade avaible only for items RARE+ rarity!")
			end
		end
	end
	return true
end
