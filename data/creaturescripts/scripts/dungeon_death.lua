function onPrepareDeath(player, corpse, killer, mostDamageKiller, lastHitUnjustified, mostDamageUnjustified)
    local dungeon = player:getDungeon()
    if dungeon then
        player:addDeath();
        player:addBuff(RESTART_IMMORTAL, 5000)
        local startPosition = dungeon:getStartPosition()
        local instance = dungeon:getPlayerInstance(player)
        if instance then
            if colleftInfo[player:getId()].attributesItems[207] then -- Resurrection
                if player:getBuff(RESURRECTION) then
                else
                    player:addHealth(player:getMaxHealth())
                    player:addMana(player:getMaxMana())
                    player:addEnergyShield(player:getMaxEnergyShield())
                    player:getPosition():sendMagicEffect(421)
                    player:addBuff(RESURRECTION, 3*60000)
                    player:addBuff(BOSS_IMMORTAL)
                    player:stopAllDots()
                    player:sendTextMessage(MESSAGE_INFO_DESCR, "You have been revived!")
                    return false
                end
            end
            local lives = instance:getLives()
            if lives > 0 then
                local instancePosition = instance:getPosition()
                local TPstonePos = { x = startPosition.x + instancePosition.x, y = startPosition.y + instancePosition.y, z = startPosition.z + instancePosition.z }
                instance:setLives(lives - 1)
                player:setHealth(player:getMaxHealth())
                player:addMana(player:getMaxMana())
                player:setEnergyShield(player:getMaxEnergyShield())
                player:stopAllDots()
                local currentLevel = player:getLevel()
                local baseLevelsToLose = 1
                if currentLevel >= 41 then
                    baseLevelsToLose = 3
                elseif currentLevel >= 21 then
                    baseLevelsToLose = 2
                else
                    baseLevelsToLose = 1
                end

                -- Check BLESS_ULTRA protection
                local hasBlessUltra = false
                local buffCheck = player:getBuff(BLESS_ULTRA)
                if buffCheck then
                    hasBlessUltra = true
                    if buffCheck.stacks and buffCheck.stacks > 1 then
                        player:setBuffStacks(BLESS_ULTRA, buffCheck.stacks - 1)
                    else
                        player:removeBuff(BLESS_ULTRA)
                    end
                    player:sendTextMessage(MESSAGE_INFO_DESCR, "Your Bless Ultra protected you from 1 level loss!")
                end

                local levelsToLose = baseLevelsToLose
                if hasBlessUltra then
                    levelsToLose = math.max(0, levelsToLose - 1)
                end

                local targetLevel = math.max(1, currentLevel - levelsToLose)
                local targetExp = getExpForLevel(targetLevel)
                local currentExp = player:getExperience()
                local expToLose = currentExp - targetExp

                if expToLose > 0 then
                    player:removeExperience(expToLose, true, true)
                end
                player:teleportTo(TPstonePos)

                lives = instance:getLives()
                player:sendExtendedOpcode(ExtendedOPCodes.CODE_DUNGEONS, json.encode({action = "lives", data = lives}))
                local party = player:getParty()
                if party then
                    local members = party:getMembers() 
                    for i = 1, #members do
                        members[i]:sendExtendedOpcode(ExtendedOPCodes.CODE_DUNGEONS, json.encode({action = "lives", data = lives}))
                        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Group have " .. lives.. " lives left.")
                    end
                    local leader = party:getLeader()
                    if leader then
                        leader:sendExtendedOpcode(ExtendedOPCodes.CODE_DUNGEONS, json.encode({action = "lives", data = lives}))
                        leader:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Group have " .. lives .. " lives left.")
                    end
                else
                    player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "You have " .. lives .. " lives left.")
                end
                return false
            end
        end
    end
    return true
end