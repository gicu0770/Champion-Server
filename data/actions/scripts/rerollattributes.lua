function onUse(player, item, fromPosition, target, toPosition, isHotkey)
    if item:getId() == 0 then return end
    if not target or not target:isItem() then
        return false
    end
    if toPosition.y <= CONST_SLOT_POTION2 then
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

    if item.itemid == US_CONFIG[1][ITEM_ORB_OR_PERFECTION] then -- LOSOWANIE ALL ATRYBUTOW		MAX
        local bonuses = target:getBonusAttributes()
        if bonuses then
            for i = 1, #bonuses do
                local values = bonuses[i]
                local attr = US_ENCHANTMENTS[values[1]]
                local ilvlMAX = attr.VALUES_PER_LEVELMAX
                if target:isCorrupted() then
                    ilvlMAX = attr.VALUES_PER_LEVELMAX
                end
                if target:getRarityId() == 7 then
                    ilvlMAX = attr.VALUES_PER_LEVELMAX
                end
                if REDUCTION_ATTR_VALUES[values[1]] then
                    if target:getTier() == 0 then
                        HPMPmax = math.ceil(REDUCTION_ATTR_VALUES[values[1]][1] / 2)
                    else
                        HPMPmax = REDUCTION_ATTR_VALUES[values[1]][target:getTier()]
                    end
                    ilvlMAX = HPMPmax
                end
            --    if target:getRarityId() == 2 then ilvlMAX = ilvlMAX * 2 end

                local ancientValues = 0
                local dungeonValues = 0
                local craftValues = 0
                local endless = 0
                if target:isDungeonItem() then
                    dungeonValues = dungeonValues + DUNGEON_ITEMS_ATTRIBUTES_INCREASED[target:getDungeonItem()]
                end
                if enableEndless then
                    if target:isEndlessItem() then
                        endless = 250
                    end
                end
                if target:isAncient() then
                    ancientValues = ancientValues + ANCIENT_ATTRIBUTES[1]
                elseif target:isPrimal_Ancient() then
                    ancientValues = ancientValues + ANCIENT_ATTRIBUTES[2]
                elseif target:isEternal() then
                    ancientValues = ancientValues + ANCIENT_ATTRIBUTES[3]
                end
                if target:isCraftBonus() then
                    craftValues = math.ceil(target:getCraftBonus() / 2)
                end
                local scaling = 0
                if target:isArenaScalingLevel() then
                    scaling = scaling + (target:getArenaScalingAttributes() * 10)
                end
                local nonTier = 0
                if target:getVocationReq() == 0 then
                    nonTier = target:getTier() * 5
                end
                local totalAttributeIncreased = target:isQuality() + (target:getTier() * 10) -- + ancientValues +dungeonValues + craftValues + endless + scaling + nonTier + RARITY_ATTRIBUTES_INCREASED[target:getRarityId()]
                local totalAttributeIncreasedEND = ilvlMAX + ((ilvlMAX * totalAttributeIncreased) / 100)
                local endV = math.ceil(totalAttributeIncreasedEND)
                for k, v in pairs(CAP_ATTRIBUTES) do
                    if values[1] == k then
                        if endV >= CAP_ATTRIBUTES[k].perItem then
                            endV = CAP_ATTRIBUTES[k].perItem
                        end
                    end
                end
                if endV <= 0 then endV = 1 end
                target:setAttributeValue(i, values[1] .. "|" .. endV)
                player:sendExtendedOpcode(105, json.encode({ reload = "reload" }))
            end

            --  player:say("Attribute values ​​have changed!", TALKTYPE_MONSTER_SAY)
            player:getPosition():sendMagicEffect(5)
            item:remove(1)
            player:sendExtendedOpcode(105, json.encode({ reload = "reload" }))
        else
            player:say("Item has no attributes!", TALKTYPE_MONSTER_SAY)
            player:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
        end
    elseif item.itemid == US_CONFIG[1][ITEM_PERFECT_FAITH_CRYSTAL] then -- LOSOWANIE ALL ATRYBUTOW		MAX
        local bonuses = target:getBonusAttributes()
        if bonuses then
            for i = 1, #bonuses do
                local values = bonuses[i]
                local attr = US_ENCHANTMENTS[values[1]]
                local ilvlMAX = math.random(attr.VALUES_PER_LEVEL, attr.VALUES_PER_LEVELMAX)
                if target:isCorrupted() then
                    ilvlMAX = attr.VALUES_PER_LEVELMAX
                end
                if target:getRarityId() == 7 then
                    ilvlMAX = attr.VALUES_PER_LEVELMAX
                end
                local HPMPmin = 0
                local HPMPmax = 0
                if REDUCTION_ATTR_VALUES[values[1]] then
                    if target:getTier() >= 0 then
                      HPMPmin = math.ceil(REDUCTION_ATTR_VALUES[values[1]][values[3]][1])
                      HPMPmax = math.ceil(REDUCTION_ATTR_VALUES[values[1]][values[3]][2])
                    end
                    if target:getRarityId() == 7 then
                      HPMPmin = HPMPmax
                    end
                  end
            --    if target:getRarityId() == 2 then ilvlMAX = ilvlMAX * 2 HPMPmin = HPMPmin * 2 HPMPmax = HPMPmax * 2 end
                local ancientValues = 0
                local dungeonValues = 0
                local craftValues = 0
                local endless = 0
                if target:isDungeonItem() then
                    dungeonValues = dungeonValues + DUNGEON_ITEMS_ATTRIBUTES_INCREASED[target:getDungeonItem()]
                end
                if enableEndless then
                    if target:isEndlessItem() then
                        endless = 250
                    end
                end
                if target:isAncient() then
                    ancientValues = ancientValues + ANCIENT_ATTRIBUTES[1]
                elseif target:isPrimal_Ancient() then
                    ancientValues = ancientValues + ANCIENT_ATTRIBUTES[2]
                elseif target:isEternal() then
                    ancientValues = ancientValues + ANCIENT_ATTRIBUTES[3]
                end
                if target:isCraftBonus() then
                    craftValues = math.ceil(target:getCraftBonus() / 2)
                end
                local scaling = 0
                if target:isArenaScalingLevel() then
                    scaling = scaling + (target:getArenaScalingAttributes() * 10)
                end
                local nonTier = 0
                if target:getVocationReq() == 0 then
                    nonTier = target:getTier() * 5
                end

                local totalAttributeIncreased = target:isQuality() + (target:getTier() * 10) -- + ancientValues + dungeonValues + craftValues + endless + scaling + nonTier + RARITY_ATTRIBUTES_INCREASED[target:getRarityId()]
                local totalAttributeIncreasedEND = ilvlMAX + ((ilvlMAX * totalAttributeIncreased) / 100)
                local minV = HPMPmin + ((HPMPmin * totalAttributeIncreased) / 100)
                local maxV = HPMPmax + ((HPMPmax * totalAttributeIncreased) / 100)
                local endV = math.ceil(totalAttributeIncreasedEND)
                if minV > 0 then
                    endV = math.random(minV, maxV)
                end

                for k, v in pairs(CAP_ATTRIBUTES) do
                    if values[1] == k then
                        if endV >= CAP_ATTRIBUTES[k].perItem then
                            endV = CAP_ATTRIBUTES[k].perItem
                        end
                    end
                end
                if endV <= 0 then endV = 1 end
                target:setAttributeValue(i, values[1] .. "|" .. endV)
                print(i)
                print(values[1] .. "|" .. endV)
                player:sendExtendedOpcode(105, json.encode({ reload = "reload" }))
            end
            player:say("Attribute values have changed!", TALKTYPE_MONSTER_SAY)
            player:getPosition():sendMagicEffect(5)
            item:remove(1)
            player:sendExtendedOpcode(105, json.encode({ reload = "reload" }))
        else
            player:say("Item has no attributes!", TALKTYPE_MONSTER_SAY)
            player:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
        end
    end

    return true
end
