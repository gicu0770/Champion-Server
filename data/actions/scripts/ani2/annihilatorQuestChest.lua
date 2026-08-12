function onUse(player, item, frompos, item2, topos)
    local storage = 25005
	local storage4 = 25006
	if item.uid == 30023 then
		if getPlayerStorageValue(player, storage4) < 0 then
            local backpack = player:getSlotItem(CONST_SLOT_BACKPACK)
            if not backpack then
              player:sendTooltipMessage("You don't have a backpack.")
              return false
            end
            if backpack and backpack:getEmptySlots(true) <= 0 then
              player:sendTooltipMessage("You don't have enough space in backpack.")
              return false
            end
			player:addItem(37118, 20)
			doPlayerSendTextMessage(player, MESSAGE_INFO_DESCR, "You have found a Orb of Chance x20.")
			setPlayerStorageValue(player, storage4, 1)
		else
			doPlayerSendTextMessage(player, MESSAGE_INFO_DESCR, "The chest is empty.")
		end
	end
    if getPlayerStorageValue(player, storage) > 0 then
        doPlayerSendTextMessage(player, MESSAGE_INFO_DESCR, "The chest is empty.")
        return true
    end

    local rewards = {
        [30020] = {id = 15413, uniqueId = 29}, -- shield
        [30021] = {id = 32341, uniqueId = 30}, -- mask helmet
        [30022] = {id = 18407, uniqueId = 31}, -- amulet
    }
    -- 15413 shield
    -- 32341 mask helmet
    -- 18407 amulet
    local reward = rewards[item.uid]
    if reward then
		local uniqueItem = generateUniqueItem(player, reward.uniqueId, 50)
        local backpack = player:getSlotItem(CONST_SLOT_BACKPACK)
        if not backpack then
          player:sendTooltipMessage("You don't have a backpack.")
          return false
        end
        if backpack and backpack:getEmptySlots(true) <= 0 then
          player:sendTooltipMessage("You don't have enough space in backpack.")
          return false
        end
		player:addItemEx(uniqueItem)
        setPlayerStorageValue(player, storage, 1)
        doPlayerSendTextMessage(player, MESSAGE_INFO_DESCR, "You have found a " .. US_UNIQUES[reward.uniqueId].name .. ".")
    else
        doPlayerSendTextMessage(player, MESSAGE_INFO_DESCR, "Nothing here.")
    end

    return true
end
