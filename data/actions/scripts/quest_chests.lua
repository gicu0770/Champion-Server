function onUse(player, item, fromPosition, target, toPosition, isHotkey)
   -----------------------------------------------------------------------------------
   -- Local Variables --
   -----------------------------------------------------------------------------------
   local questChest = item:getUniqueId()
   -----------------------------------------------------------------------------------
   -- Check if player has already opened box --
   -----------------------------------------------------------------------------------
   if player:getStorageValue(questChest) == 1 then
       player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "The chest is empty.")
       return true
   end
   -----------------------------------------------------------------------------------
   -- Check if player meets level requirment
   -----------------------------------------------------------------------------------
   local playerLevel = player:getLevel()
   local minLevel = questChests[questChest].minLevel
   if (questChests[questChest].minLevel) - 1 >= playerLevel then
       player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You need to be level "..minLevel.." to open this chest.")
       return true
   end
   -----------------------------------------------------------------------------------
 
   -- Give rewward if player has not yet opened box --
 
   -----------------------------------------------------------------------------------
   for i = 1, #questChests[questChest].items do
       local rewardType = questChests[questChest].items[i].type
       -----------------------------------------------------------------------------------
       -- Item Type Reward --
       -----------------------------------------------------------------------------------
       if rewardType == "item" then
           local item = questChests[questChest].items[i].item
           local count = questChests[questChest].items[i].count
		   local itemLevel = questChests[questChest].items[i].itemLevel
           local createItem = player:addItem(item, count)
		   
		   	if createItem:getType():isUpgradable() then
				createItem:setCustomAttribute("unidentified", true)
				createItem:setItemLevel(math.random(questChests[questChest].items[i].miniLvl, questChests[questChest].items[i].maxiLvl))
				createItem:setClassItem(0)
				
				local ancientTotalChance = 140000 * configManager.getNumber(configKeys.RATE_LOOT)
				local primalTotalChance = 7000 * configManager.getNumber(configKeys.RATE_LOOT)
				local eternalTotalChance = 2500 * configManager.getNumber(configKeys.RATE_LOOT)
				local randAncient = math.random(100000)
				local globalLoot = 0
				local globalLootActive = math.max(getEternalStorage(GlobalStorageKeys.globalLOOTtime) - os.time(), 0)
				if globalLootActive > 0 then
					globalLoot = globalLoot + 0.5
				end
				if player:getStorageValue(PlayerStorage.lootBoostShop) >= os.time() then
					globalLoot = globalLoot + 0.25
				end
				local uniqueChance = ancientTotalChance + (ancientTotalChance * globalLoot)
				local primalChance = primalTotalChance + (primalTotalChance * globalLoot)
				local eternalChance = eternalTotalChance + (eternalTotalChance * globalLoot)
				if randAncient <= eternalChance then
					createItem:setItemLevel(createItem:getItemLevel() + (math.ceil(createItem:getItemLevel() * 0.10))) 
					createItem:setCustomAttribute("eternal", "Eternal")
					setItemStatsPercent(player, createItem, 0.10)
				elseif randAncient <= primalChance then
					createItem:setItemLevel(createItem:getItemLevel() + (math.ceil(createItem:getItemLevel() * 0.07)))
					item:setCustomAttribute("primal_ancient", "Primal Ancient")
					setItemStatsPercent(player, createItem, 0.07)
				elseif randAncient <= uniqueChance then
					createItem:setItemLevel(createItem:getItemLevel() + (math.ceil(createItem:getItemLevel() * 0.04)))
					createItem:setCustomAttribute("ancient", "Ancient")
					setItemStatsPercent(player, createItem, 0.04)
				end	
				if createItem:identify(player, createItem, nil) then
				 else
				 player:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
				end		
				createItem:unidentify()
		
			end

           player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You earned ["..count.."x] "..capAll(getItemName(item)))
       end
       -----------------------------------------------------------------------------------
       -- Experience Type Reward --
       -----------------------------------------------------------------------------------
       if rewardType == "experience" then
           local amount = questChests[questChest].items[i].amount
           player:addExperience(amount)
           player:say(amount.." EXP gained!", TALKTYPE_MONSTER_SAY)
           player:getPosition():sendMagicEffect(CONST_ME_STUN)
           player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You gained "..amount.." experience points.")
       end
	   -----------------------------------------------------------------------------------
       -- Secret Quest Type Reward --
       -----------------------------------------------------------------------------------
       if rewardType == "secretQuest" then
           local amount = questChests[questChest].items[i].amount
		   local stor = player:getStorageValue(PlayerStorage.questPassive)
           player:setStorageValue(PlayerStorage.questPassive, stor + 1)
           player:getPosition():sendMagicEffect(CONST_ME_STUN)
		   player:sendExtendedOpcode(71, json.encode({text = "You find {Secret Quest}! You character enchantment increased!", color = "#f7ef8a"}))
           player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You find Secret Quest! You character enchantment increased!")
       end
	 if rewardType == "money" then
           local count = questChests[questChest].items[i].count
	    player:setBankBalance(player:getBankBalance() + count)
           player:say(count.." Gold!", TALKTYPE_MONSTER_SAY)
           player:getPosition():sendMagicEffect(CONST_ME_STUN)
           player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You find "..count.." gold.")
       end
       -----------------------------------------------------------------------------------
       -- Outfit Type Reward --
       -----------------------------------------------------------------------------------   
       if rewardType == "outfit" then
           local outfitName = questChests[questChest].items[i].name
           local maleOutfit = questChests[questChest].items[i].maleId
           local femaleOutfit = questChests[questChest].items[i].femaleId
           if player:getSex() == 0 then
               player:addOutfit(femaleOutfit)
           else
               player:addOutfit(maleOutfit)
           end
           player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You gained the "..outfitName.." outfit.")
       end
       -----------------------------------------------------------------------------------
       -- Wings Type Reward --
       ----------------------------------------------------------------------------------- 
	   if rewardType == "wings" then
	   local wings = questChests[questChest].items[i].amount
	   if player:hasWings(wings) then
	   player:sendTextMessage(MESSAGE_EVENT_ADVANCE,"You already have this wings.")
		return false
		end
		player:addWings(wings)
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE,"You obtain Devil Wings.")
	   end
	   -----------------------------------------------------------------------------------
       -- Aura Type Reward --
       ----------------------------------------------------------------------------------- 
	   if rewardType == "aura" then
	   local aura = questChests[questChest].items[i].amount
	    if player:hasAura(aura) then
	    player:sendTextMessage(MESSAGE_EVENT_ADVANCE,"You already have this aura.")
		return false
		end
		player:addAura(aura)
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE,"You obtain Shack Aura.")
	   end
	   -----------------------------------------------------------------------------------
       -- Item Special Type Reward --
       -----------------------------------------------------------------------------------
       if rewardType == "specialitem" then
           local item = questChests[questChest].items[i].item
           local count = questChests[questChest].items[i].count
           local createItem = player:addItem(item, count)
		   createItem:setbindItem(player:getAccountId())
           player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You earned ["..count.."x] "..capAll(getItemName(item)))
       end
       -----------------------------------------------------------------------------------
       -- Addon Type Reward --
       -----------------------------------------------------------------------------------   
       if rewardType == "addon" then
           local outfitName = questChests[questChest].items[i].outfit
           local addon = questChests[questChest].items[i].addonNumber
           local maleAddon = questChests[questChest].items[i].maleId
           local femaleAddon = questChests[questChest].items[i].femaleId
           if player:getSex() == 0 then
               player:addOutfitAddon(femaleAddon, addon)
           else
               player:addOutfitAddon(maleAddon, addon)
           end
           if addon == 1 then
               player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You gained the first "..outfitName.." outfit addon.")
           elseif addon == 2 then
               player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You gained the second "..outfitName.." outfit addon.")
           elseif addon == 3 then
               player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You gained the third "..outfitName.." outfit addon.")
           end
       end
       -----------------------------------------------------------------------------------
       -- Mount Type Reward --
       -----------------------------------------------------------------------------------
       if rewardType == "mount" then
           local mountName = questChests[questChest].items[i].mountName
           local mountId = questChests[questChest].items[i].mountId
           player:addMount(mountId)
           player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You have unlocked the "..mountName.." mount.")
       end
   end
   -----------------------------------------------------------------------------------
   -- Add in any cooldowns/storages --
   -----------------------------------------------------------------------------------
   player:setStorageValue(questChest, 1)
   return true
end