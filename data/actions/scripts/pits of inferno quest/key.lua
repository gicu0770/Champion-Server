function onUse(player, item, fromPosition, target, toPosition, isHotkey)
    if item.uid == 56397 then --key test--
        if player:getStorageValue(56397) == -1 then
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You have found a bone key in a corpse.")
            local key = player:addItem(2092)
            key:setActionId(3700)
            player:setStorageValue(56397, 1)
        else
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "The body is empty.")
        end
    end
    return true
end