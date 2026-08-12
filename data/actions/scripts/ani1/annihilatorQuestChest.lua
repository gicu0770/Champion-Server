function onUse(player, item, frompos, item2, topos)
    local storage = 25003
	local storage4 = 25004
	if item.uid == 30018 then
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
			player:addItem(8302, 10)
			doPlayerSendTextMessage(player, MESSAGE_INFO_DESCR, "You have found a Orb of Honored x10.")
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
        [30015] = {id = 37780, uniqueId = 26}, -- gloves
        [30016] = {id = 37972, uniqueId = 27}, -- armor
        [30017] = {id = 37974, uniqueId = 28}, -- boots
    }

    local reward = rewards[item.uid]
    if reward then
        local backpack = player:getSlotItem(CONST_SLOT_BACKPACK)
        if not backpack then
          player:sendTooltipMessage("You don't have a backpack.")
          return true
        end
        if backpack and backpack:getEmptySlots(true) <= 0 then
          player:sendTooltipMessage("You don't have enough space in backpack.")
          return true
        end

		local uniqueItem = generateUniqueItem(player, reward.uniqueId, 20)
		player:addItemEx(uniqueItem)
        setPlayerStorageValue(player, storage, 1)
        doPlayerSendTextMessage(player, MESSAGE_INFO_DESCR, "You have found a " .. US_UNIQUES[reward.uniqueId].name .. ".")
    else
        doPlayerSendTextMessage(player, MESSAGE_INFO_DESCR, "Nothing here.")
    end

    return true
end
