function onUse(player, item, fromPosition, itemEx, toPosition)

   for _, fragment in ipairs(BOSS_FRAGMENTS_SPECIAL) do
       if item:getId() == fragment.id then
           if player:getItemCount(fragment.id) >= fragment.count then
                local backpack = player:getSlotItem(CONST_SLOT_BACKPACK)
                if not backpack then
                    player:sendTooltipMessage("You don't have a backpack.")
                    return false
                end
                if backpack and backpack:getEmptySlots(true) <= 0 then
                    player:sendTooltipMessage("You don't have enough space in backpack.")
                    return false
                end
               local key = Game.createItem(fragment.reward, 1) -- player:addItem(fragment.reward, 1, INDEX_WHEREEVER, FLAG_NOLIMIT)
               local countF = fragment.count
               key:setRarity(5)
               key:setCustomAttribute("DungeonKey", true)
               if fragment.fragmentSetitemLevel then
                countF = player:getItemCount(fragment.id)
                key:setItemLevel(countF)
               elseif fragment.itemLevel then
                key:setItemLevel(fragment.itemLevel)
               else
                key:setItemLevel(250)
               end
               if fragment.tier then
                local fragmentTier = fragment.tier
                local playerTier = player:getDungeonTier()
                if fragment.overtier and playerTier > fragment.tier then
                    fragmentTier = playerTier
                end
                key:setCustomAttribute("keytier", fragmentTier)
                key:setItemLevel(getMonsterLevelByKeyTier(fragmentTier))
               end
               if key then
                player:addItemEx(key)
               end
               player:sendTextMessage(MESSAGE_EVENT_ADVANCE, fragment.message)
               player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, fragment.message)
               player:getPosition():sendMagicEffect(50)
               player:removeItem(fragment.id, countF)
           else
               player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You need at least 100 of this Fragment to exchange for a Key.")
               player:getPosition():sendMagicEffect(CONST_ME_POFF)
           end
           return true
       end
   end

   return false
end