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
                local level = player:getLevel()
                local lost = 0.20
                local buffsToCheck = { BLESS_ULTRA, BLESS_PLUS, BLESS }
                for i = 1, #buffsToCheck do
                    local buffCheck = player:getBuff(buffsToCheck[i])
                    if buffCheck then
                        if buffsToCheck[i] == BLESS_ULTRA then
                            lost = 0.02
                        elseif buffsToCheck[i] == BLESS_PLUS then
                            lost = 0.06
                        elseif buffsToCheck[i] == BLESS then
                            lost = 0.10
                        end

                        if buffCheck.stacks and buffCheck.stacks > 1 then
                            player:setBuffStacks(buffsToCheck[i], buffCheck.stacks - 1)
                        else
                            player:removeBuff(buffsToCheck[i])
                        end
                        break
                    end
                end
                local dif = (getExpForLevel(level) - getExpForLevel(level - 1)) * lost
                local currentExp = player:getExperience() - getExpForLevel(level)
                if currentExp < dif then
                    dif = currentExp
                end

                player:removeExperience(dif, true, false)
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