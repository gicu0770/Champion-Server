function onStepIn(cid, item, pos, fromPosition)
    -- Queen Lair
    if item.actionid == 27567 then
        local player = Player(cid)
        if not player then
            Creature(cid):teleportTo(fromPosition)
            return true
        end
        if player:getStorageValue(PlayerStorage.dungeonUnlocked1) < 0 then
            player:sendExtendedOpcode(71, json.encode({ text = "You have been granted access to the {Queen Lair} dungeons.", color = "#f7ef8a" }))
            player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "You have been granted access to the [ Queen Lair ] dungeons.")
            Position(player:getPosition()):sendMagicEffect(50)
            player:setStorageValue(PlayerStorage.dungeonUnlocked1, 1)
        else
            player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "You have access to the [ Queen Lair ] dungeons.")
        end
    end
    -- Flame Cave
    if item.actionid == 27568 then
        local player = Player(cid)
        if not player then
            Creature(cid):teleportTo(fromPosition)
            return true
        end
        if player:getStorageValue(PlayerStorage.dungeonUnlocked2) < 0 then
            player:sendExtendedOpcode(71, json.encode({ text = "You have been granted access to the {Flame Cave} dungeons.", color = "#f7ef8a" }))
            player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "You have been granted access to the [ Flame Cave ] dungeons.")
            Position(player:getPosition()):sendMagicEffect(50)
            player:setStorageValue(PlayerStorage.dungeonUnlocked2, 1)
        else
            player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "You have access to the [ Flame Cave ] dungeons.")
        end
    end
    -- Swamp Pit
    if item.actionid == 27569 then
        local player = Player(cid)
        if not player then
            Creature(cid):teleportTo(fromPosition)
            return true
        end
        if player:getStorageValue(PlayerStorage.dungeonUnlocked3) < 0 then
            player:sendExtendedOpcode(71, json.encode({ text = "You have been granted access to the {Swamp Pit} dungeons.", color = "#f7ef8a" }))
            player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "You have been granted access to the [ Swamp Pit ] dungeons.")
            Position(player:getPosition()):sendMagicEffect(50)
            player:setStorageValue(PlayerStorage.dungeonUnlocked3, 1)
        else
            player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "You have access to the [ Swamp Pit ] dungeons.")
        end
    end
    -- Undead Cave
    if item.actionid == 27570 then
        local player = Player(cid)
        if not player then
            Creature(cid):teleportTo(fromPosition)
            return true
        end
        if player:getStorageValue(PlayerStorage.dungeonUnlocked4) < 0 then
            player:sendExtendedOpcode(71, json.encode({ text = "You have been granted access to the {Undead Cave} dungeons.", color = "#f7ef8a" }))
            player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "You have been granted access to the [ Undead Cave ] dungeons.")
            Position(player:getPosition()):sendMagicEffect(50)
            player:setStorageValue(PlayerStorage.dungeonUnlocked4, 1)
        else
            player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "You have access to the [ Undead Cave ] dungeons.")
        end
    end
    return true
end
