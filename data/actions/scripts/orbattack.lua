function onUse(player, item, fromPosition, target, toPosition, isHotkey)
if item:getId() == 0 then return end	
	if not target or not target:isItem() or not target:getType():isUpgradable() then
     return false
	end
	
	if toPosition.y <= CONST_SLOT_RING2 then
     player:sendTextMessage(MESSAGE_STATUS_WARNING, "You can't use that on equipped item!")
 	 player:say("You can't use that on equipped item!", TALKTYPE_MONSTER_SAY)
     player:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
	 player:getPosition():sendMagicEffect(3)
     return true
	end
 
	if item.itemid ~= US_CONFIG.ITEM_SCROLL_IDENTIFY and target:isUnidentified() then
	 player:say("Item is unidentified!", TALKTYPE_MONSTER_SAY)
     player:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
	 player:getPosition():sendMagicEffect(3)
     return true
	end

	if target:isCorrupted() then
	 player:say("Item is corrupted!", TALKTYPE_MONSTER_SAY)
	 player:sendTextMessage(MESSAGE_STATUS_WARNING, "You can't use that on corrupted item!")
     player:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
	 player:getPosition():sendMagicEffect(3)
	 return true
	end

	local chance = {
		[0] = 100000,
		[1] = 90000,
		[2] = 90000,
		[3] = 90000,
		[4] = 90000,
		[5] = 80000,
		[6] = 70000,
		[7] = 60000,
		[8] = 50000,
		[9] = 40000,
		[10] = 30000,
	  }
	local itemType = ItemType(target.itemid)
	-- Quality-----------------------------------------------------------------------------------------------
	if item:getId() == 37113 then -- quality
		if target:isQuality() >= 30 then
			player:say("The item has reached its maximum 30 level.", TALKTYPE_MONSTER_SAY)
			player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "The item has reached its 30 maximum level.")
			player:getPosition():sendMagicEffect(3)
			return false
		end
		if math.random(100) <= 100 - (target:isQuality() * 1) then
			player:getPosition():sendMagicEffect(291)
			target:setQuality(target:isQuality() + 1)
			--[[
			local tierAttack = target:getCustomAttribute("base_attack")
			local tierArmor = target:getCustomAttribute("base_armor")
			local tierDefense = target:getCustomAttribute("base_defense")
			setAncientItemAttackArmorDefense(player, target, tierAttack, tierArmor, tierDefense, 1)
			--]]
			local increasedAllstats = 0
			if target:isDungeonItem() then
				increasedAllstats = increasedAllstats + DUNGEON_ITEMS_STATS[target:getDungeonItem()] -- 50%
			end
			if target:isCraftBonus() then
				increasedAllstats = increasedAllstats + ((target:getCraftBonus() / 4) / 100) -- 25%
			end
			if target:getRarityId() >= 2 then
				increasedAllstats = increasedAllstats + RARITY_IMPLICT[target:getRarityId()]
			end
			if target:isQuality() then
				increasedAllstats = increasedAllstats + (target:isQuality() / 100)
			end
			if target:getArenaScalingLevel() then
				increasedAllstats = increasedAllstats + (ENCHANTMENT_ORB_ITEMS[target:getArenaScalingLevel()] / 100)
			end
			if target:getClassItem() then
				increasedAllstats = increasedAllstats + (ENCHANTMENT_ORB_ITEMS[target:getClassItem()] / 100)
			end
			target:setImplicit(increasedAllstats)
			setItemStatsPercent(player, target, increasedAllstats)

			item:remove(1)
			player:sendExtendedOpcode(105, json.encode({ reload = "reload" }))
		else
			player:getPosition():sendMagicEffect(326)
		end
	end
	-- Attributes-----------------------------------------------------------------------------------------------
	 if item:getId() == 37120 then
	  if target:getArenaScalingAttributes() < 10 then
		if math.random(100000) <= chance[target:getArenaScalingAttributes()] then
		 player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Upgrade Success!")
		 target:setArenaScalingAttributes(target:getArenaScalingAttributes() + 1)
		 player:getPosition():sendMagicEffect(50)
		 item:remove(1)
		 player:sendExtendedOpcode(105, json.encode({reload = "reload"}))
		  if player:getStorageValue(PlayerStorage.animatedTalentSkills) == -1 then
			player:getPosition():sendMagicEffect(325)
		  else
			Game.sendAnimatedText('Success!', player:getPosition(), 192, "Reggae One-20px-bordered")
		  end
		else
		 player:say("Upgrade failed!", TALKTYPE_MONSTER_SAY)
		 player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Upgrade failed!")
		 player:getPosition():sendMagicEffect(3)
		 item:remove(1)
		  if player:getStorageValue(PlayerStorage.animatedTalentSkills) == -1 then
			player:getPosition():sendMagicEffect(326)
		  else
			Game.sendAnimatedText('Failed!', player:getPosition(), 192, "Reggae One-20px-bordered")
		  end
		end
	 else
	  player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Item have maximum Attributes Enhantment Level!")
	 end
	end

	local stats_upgrade = 0
	--------------------------------------------------------------------------------------------------------------
	if item:getId() == 37118 then -- attack
		if itemType:getAttack() > 0 then
			if target:isArenaScalingLevel() then
				if target:getArenaScalingLevel() >= 10 then
					player:say("The item has reached its maximum level.", TALKTYPE_MONSTER_SAY)
					player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "The item has reached its maximum level.")
					player:getPosition():sendMagicEffect(3)
					return false
				end
			end
			if math.random(100000) <= chance[target:getArenaScalingLevel()] then
				player:getPosition():sendMagicEffect(291)
				--[[
				stats_upgrade = (target:getTier() * (target:getArenaScalingLevel() + 1))
				stats_upgrade = math.floor(stats_upgrade * 1.50)
				if stats_upgrade < 1 then
					stats_upgrade = 1
				end
				target:setAttribute(
					ITEM_ATTRIBUTE_ATTACK,
					target:getAttribute(ITEM_ATTRIBUTE_ATTACK) + stats_upgrade
				  )
				  --]]
				  player:say("Upgrade Success!", TALKTYPE_MONSTER_SAY)
				  player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Upgrade Success!")
				  player:getPosition():sendMagicEffect(291)
				  target:setArenaScalingLevel(target:getArenaScalingLevel() + 1)
				  local increasedAllstats = 0
				  if target:isDungeonItem() then
					  increasedAllstats = increasedAllstats + DUNGEON_ITEMS_STATS[target:getDungeonItem()] -- 50%
				  end
				  if target:isCraftBonus() then
					  increasedAllstats = increasedAllstats + ((target:getCraftBonus() / 4) / 100) -- 25%
				  end
				  if target:getRarityId() >= 2 then
					  increasedAllstats = increasedAllstats + RARITY_IMPLICT[target:getRarityId()]
				  end
				  if target:isQuality() then
					  increasedAllstats = increasedAllstats + (target:isQuality() / 100)
				  end
				  if target:getArenaScalingLevel() then
					  increasedAllstats = increasedAllstats + (ENCHANTMENT_ORB_ITEMS[target:getArenaScalingLevel()] / 100)
				  end
				  target:setImplicit(increasedAllstats)
				  setItemStatsPercent(player, target, increasedAllstats)
				  item:remove(1)
				  player:sendExtendedOpcode(105, json.encode({reload = "reload"}))
				  if player:getStorageValue(PlayerStorage.animatedTalentSkills) == -1 then
					player:getPosition():sendMagicEffect(325)
				  else
					Game.sendAnimatedText('Success!', player:getPosition(), 192, "Reggae One-20px-bordered")
				  end
				else
				 player:say("Upgrade failed!", TALKTYPE_MONSTER_SAY)
				 player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Upgrade failed!")
				 player:getPosition():sendMagicEffect(3)
				 item:remove(1)
				  if player:getStorageValue(PlayerStorage.animatedTalentSkills) == -1 then
					player:getPosition():sendMagicEffect(326)
				  else
					Game.sendAnimatedText('Failed!', player:getPosition(), 192, "Reggae One-20px-bordered")
				  end
			end	
		else
			player:getPosition():sendMagicEffect(3)
			player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Item must have Attack!")
			player:say("Item must have Attack!", TALKTYPE_MONSTER_SAY)
			player:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
		end
	end
	if item:getId() == 37119 then
		if itemType:getArmor() > 0 then
			if target:isArenaScalingLevel() then
				if target:getArenaScalingLevel() >= 10 then
					player:say("The item has reached its maximum level.", TALKTYPE_MONSTER_SAY)
					player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "The item has reached its maximum level.")
					player:getPosition():sendMagicEffect(3)
					return false
				end
			end
			if math.random(100000) <= chance[target:getArenaScalingLevel()] then
				player:getPosition():sendMagicEffect(291)
				--[[
				stats_upgrade = (target:getTier() * (target:getArenaScalingLevel() + 1))
				stats_upgrade = math.floor(stats_upgrade * 1.50)
				if stats_upgrade < 1 then
					stats_upgrade = 1
				end
				target:setAttribute(
					ITEM_ATTRIBUTE_ARMOR,
					target:getAttribute(ITEM_ATTRIBUTE_ARMOR) + stats_upgrade
				  )
				  --]]
				 player:say("Upgrade Success!", TALKTYPE_MONSTER_SAY)
				 player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Upgrade Success!")
				 player:getPosition():sendMagicEffect(291)
				 target:setArenaScalingLevel(target:getArenaScalingLevel() + 1)
				 local increasedAllstats = 0
				 if target:isDungeonItem() then
					 increasedAllstats = increasedAllstats + DUNGEON_ITEMS_STATS[target:getDungeonItem()] -- 50%
				 end
				 if target:isCraftBonus() then
					 increasedAllstats = increasedAllstats + ((target:getCraftBonus() / 4) / 100) -- 25%
				 end
				 if target:getRarityId() >= 2 then
					 increasedAllstats = increasedAllstats + RARITY_IMPLICT[target:getRarityId()]
				 end
				 if target:isQuality() then
					 increasedAllstats = increasedAllstats + (target:isQuality() / 100)
				 end
				 if target:getArenaScalingLevel() then
					 increasedAllstats = increasedAllstats + (ENCHANTMENT_ORB_ITEMS[target:getArenaScalingLevel()] / 100)
				 end
				 target:setImplicit(increasedAllstats)
				 setItemStatsPercent(player, target, increasedAllstats)
				 item:remove(1)
				 player:sendExtendedOpcode(105, json.encode({reload = "reload"}))
				  if player:getStorageValue(PlayerStorage.animatedTalentSkills) == -1 then
					player:getPosition():sendMagicEffect(325)
				  else
					Game.sendAnimatedText('Success!', player:getPosition(), 192, "Reggae One-20px-bordered")
				  end
				else
				 player:say("Upgrade failed!", TALKTYPE_MONSTER_SAY)
				 player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Upgrade failed!")
				 player:getPosition():sendMagicEffect(3)
				 item:remove(1)
				  if player:getStorageValue(PlayerStorage.animatedTalentSkills) == -1 then
					player:getPosition():sendMagicEffect(326)
				  else
					Game.sendAnimatedText('Failed!', player:getPosition(), 192, "Reggae One-20px-bordered")
				  end
			end	
		else
			player:getPosition():sendMagicEffect(3)
			player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Item must have Armor!")
			player:say("Item must have Armor!", TALKTYPE_MONSTER_SAY)
			player:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
		end
	end

	if item:getId() == 37114 then
		if itemType:getDefense() > 0 then
			if target:isArenaScalingLevel() then
				if target:getArenaScalingLevel() >= 10 then
					player:say("The item has reached its maximum level.", TALKTYPE_MONSTER_SAY)
					player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "The item has reached its maximum level.")
					player:getPosition():sendMagicEffect(3)
					return false
				end
			end
			if math.random(100000) <= chance[target:getArenaScalingLevel()] then
				player:getPosition():sendMagicEffect(291)
				--[[
				stats_upgrade = (target:getTier() * (target:getArenaScalingLevel() + 1))
				stats_upgrade = math.floor(stats_upgrade * 1.50)
				if stats_upgrade < 1 then
					stats_upgrade = 1
				end
				target:setAttribute(
					ITEM_ATTRIBUTE_DEFENSE,
					target:getAttribute(ITEM_ATTRIBUTE_DEFENSE) + stats_upgrade
				  )
				  --]]
				 player:say("Upgrade Success!", TALKTYPE_MONSTER_SAY)
				 player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Upgrade Success!")
				 player:getPosition():sendMagicEffect(291)
				 target:setArenaScalingLevel(target:getArenaScalingLevel() + 1)
				 item:remove(1)
				 player:sendExtendedOpcode(105, json.encode({reload = "reload"}))
				  if player:getStorageValue(PlayerStorage.animatedTalentSkills) == -1 then
					player:getPosition():sendMagicEffect(325)
				  else
					Game.sendAnimatedText('Success!', player:getPosition(), 192, "Reggae One-20px-bordered")
				  end
				else
				 player:say("Upgrade failed!", TALKTYPE_MONSTER_SAY)
				 player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Upgrade failed!")
				 player:getPosition():sendMagicEffect(3)
				 item:remove(1)
				  if player:getStorageValue(PlayerStorage.animatedTalentSkills) == -1 then
					player:getPosition():sendMagicEffect(326)
				  else
					Game.sendAnimatedText('Failed!', player:getPosition(), 192, "Reggae One-20px-bordered")
				  end
			end	
		else
			player:getPosition():sendMagicEffect(3)
			player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Item must have Armor!")
			player:say("Item must have Armor!", TALKTYPE_MONSTER_SAY)
			player:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
		end
	end

	if item:getId() == 33950 then
		if target:isSoulShard() then
			player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Item have Soul Shard!")
			return false
		end
		if target:isEmptySlotItem() then
			player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Item have Empty Slot!")
		else
			if math.random(100000) <= 75000 then
				player:say("Item added Empty Slot!", TALKTYPE_MONSTER_SAY)
				player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Item added Empty Slot!")
				player:getPosition():sendMagicEffect(291)
				target:setEmptySlotItem(1)
				item:remove(1)
				 if player:getStorageValue(PlayerStorage.animatedTalentSkills) == -1 then
					player:getPosition():sendMagicEffect(325)
				  else
					Game.sendAnimatedText('Success!', player:getPosition(), 192, "Reggae One-20px-bordered")
				  end
			else
				player:say("Upgrade failed!", TALKTYPE_MONSTER_SAY)
				player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Upgrade failed!")
				player:getPosition():sendMagicEffect(3)
				item:remove(1)
				  if player:getStorageValue(PlayerStorage.animatedTalentSkills) == -1 then
					player:getPosition():sendMagicEffect(326)
				  else
					Game.sendAnimatedText('Failed!', player:getPosition(), 192, "Reggae One-20px-bordered")
				  end
			end
		end
	end

 return true
end