function onStepIn(cid, item, pos, fromPosition)
    -------------------------------------------------------	T9 acc
    if item.actionid == 27591 then
        local player = Player(cid)
        if not player then
            Creature(cid):teleportTo(fromPosition)
            return true
        end
        if player:getLevel() <= 1300 then
            player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Requires a level 1300+")
           player:teleportTo(fromPosition)
        return false
        end
--        if getParagonLevel(player) < 50 then
--            player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Requires a Paragon Level 50+")
--            player:teleportTo(fromPosition)
--        return false
--        end
        if player:getStorageValue(PlayerStorage.t9access2) <= 1 then
            Position(player:getPosition()):sendMagicEffect(CONST_ME_POFF)
            player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You don't have access. You have to complete a quest for Vengeful Guardian [Galactic Underworld]")
            player:teleportTo(fromPosition)
        return false
        end
    end
    -------------------------------------------------------	T10 set
    if item.actionid == 27593 then
        local player = Player(cid)
        if not player then
            Creature(cid):teleportTo(fromPosition)
            return true
        end
--        if player:getLevel() <= 1499 then
--            player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Requires a level 1500+")
--            player:teleportTo(fromPosition)
--        return false
--        end
        if getParagonLevel(player) < 50 then
            player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Requires a Paragon Level 50+")
            player:teleportTo(fromPosition)
        return false
        end
        if player:getStorageValue(PlayerStorage.t10access) <= 1 then
            Position(player:getPosition()):sendMagicEffect(CONST_ME_POFF)
            player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You don't have access. You have to complete a quest for Spirit of Smoke [Cloud Place]")
            player:teleportTo(fromPosition)
        return false
        end
    end    
    -------------------------------------------------------	T10 acc
    if item.actionid == 27594 then
        local player = Player(cid)
        if not player then
            Creature(cid):teleportTo(fromPosition)
            return true
        end
--        if player:getLevel() <= 1499 then
--            player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Requires a level 1500+")
--            player:teleportTo(fromPosition)
--        return false
--        end
        if getParagonLevel(player) < 50 then
            player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Requires a Paragon Level 50+")
            player:teleportTo(fromPosition)
        return false
        end
        if player:getStorageValue(PlayerStorage.t10access2) <= 1 then
            Position(player:getPosition()):sendMagicEffect(CONST_ME_POFF)
            player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You don't have access. You have to complete a quest for Blood Vampire [Dark Blood]")
            player:teleportTo(fromPosition)
        return false
        end
    end   
        return true
    end