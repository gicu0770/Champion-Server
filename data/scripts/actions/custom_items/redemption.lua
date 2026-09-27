local REDEMPTION_CD = 210
local redemption = Action()

function redemption.onUse(player, item, fromPosition, target, toPosition, isHotkey)
    local now = os.time()
    local cdKey = PlayerStorage.redemptionCooldown
    local cdEnd = player:getStorageValue(cdKey)
    if cdEnd > now or player:hasBuff(REDEMPTION_CD) then
        local remaining = (cdEnd > now) and (cdEnd - now) or 0
        player:sendTextMessage(MESSAGE_STATUS_SMALL, "Redemption is on cooldown. (" .. remaining .. "s)")
        return true
    end

    -- Since Tibia client doesn't show a crosshair for equipment, we use current target or self
    local targetCreature = player:getTarget()
    local finalPos = toPosition
    
    if not toPosition or toPosition.x == 0 or toPosition.x == 65535 then
        if targetCreature then
            finalPos = targetCreature:getPosition()
        else
            finalPos = player:getPosition()
        end
    end

    -- Set cooldown to 90 seconds
    player:setStorageValue(cdKey, now + 90)
    player:addBuff(REDEMPTION_CD, 90000)

    -- Visual marker at target location immediately
    finalPos:sendMagicEffect(CONST_ME_TUTORIALARROW)
    finalPos:sendMagicEffect(CONST_ME_MAGIC_BLUE)

    player:sendTextMessage(MESSAGE_STATUS_SMALL, "Redemption beam called. It will arrive in 2.5 seconds.")

    local playerId = player:getId()
    local cx, cy, cz = finalPos.x, finalPos.y, finalPos.z
    local spellRadius = 4

    addEvent(function(pid, tx, ty, tz, rad)
        local p = Player(pid)
        local targetPos = Position(tx, ty, tz)

        -- Send effect 40 across the entire spell area of effect
        for dx = -rad, rad do
            for dy = -rad, rad do
                if (dx * dx + dy * dy) <= (rad * rad + 1) then
                    local effectPos = Position(tx + dx, ty + dy, tz)
                    effectPos:sendMagicEffect(40)
                end
            end
        end

        local spectators = Game.getSpectators(targetPos, false, false, rad, rad, rad, rad)
        if not spectators then return end

        local party
        if p then
            party = p:getParty()
        end

        for _, spec in ipairs(spectators) do
            if spec:isPlayer() then
                local healTarget = false
                if p and spec == p then
                    healTarget = true
                elseif party and party == spec:getParty() then
                    healTarget = true
                end

                if healTarget then
                    local pLvl = spec:getLevel()
                    local heal = math.floor(180 + (pLvl * 1.6))
                    local healMult = 1.0
                    local ARDENT_CENSER_BUFF = _G.ARDENT_CENSER_BUFF or 114
                    local GRIEVOUS_WOUNDS = _G.GRIEVOUS_WOUNDS or 110

                    if p then
                        local colleftInfo = _G.colleftInfo
                        local attAttrs = colleftInfo and colleftInfo[pid] and colleftInfo[pid].attributesItems
                        if attAttrs then
                            if attAttrs[65] and spec:getId() ~= pid then
                                healMult = healMult + 0.16
                            end
                            if attAttrs[67] then
                                healMult = healMult + 0.08
                                p:addBuff(ARDENT_CENSER_BUFF, 6000)
                                p:getTotalAttackSpeed()
                                if spec:getId() ~= pid then
                                    spec:addBuff(ARDENT_CENSER_BUFF, 6000)
                                    spec:getTotalAttackSpeed()
                                end
                            end
                        end
                    end

                    local specInfo = colleftInfo and colleftInfo[spec:getId()]
                    local specAttrs = specInfo and specInfo.attributesItems
                    if specAttrs then
                        if specAttrs[43] then
                            healMult = healMult + ((specAttrs[43].value or 25) / 100)
                        end
                        if specAttrs[65] then
                            healMult = healMult + 0.16
                        end
                        if specAttrs[67] then
                            healMult = healMult + 0.08
                        end
                    end
                    if spec:hasBuff(GRIEVOUS_WOUNDS) then
                        healMult = math.max(0, healMult - 0.40)
                    end

                    heal = math.max(0, math.floor(heal * healMult))
                    spec:addHealth(heal)
                    spec:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
                else
                    -- Enemy player? Standard 10% true damage for players without cap
                    local maxHp = spec:getMaxHealth()
                    local dmg = math.floor(maxHp * 0.10)
                    if dmg > 0 then
                        doTargetCombatHealth(p and pid or 0, spec, COMBAT_HOLYDAMAGE, -dmg, -dmg, CONST_ME_NONE, ORIGIN_CONDITION)
                    end
                end
            elseif spec:isMonster() then
                -- Enemy monster - cap damage to 1000
                local maxHp = spec:getMaxHealth()
                local dmg = math.floor(maxHp * 0.10)
                if dmg > 1000 then dmg = 1000 end
                if dmg > 0 then
                    doTargetCombatHealth(p and pid or 0, spec, COMBAT_HOLYDAMAGE, -dmg, -dmg, CONST_ME_NONE, ORIGIN_CONDITION)
                end
            end
        end
    end, 2500, playerId, cx, cy, cz, spellRadius)

    return true
end

redemption:id(8868)
redemption:allowFarUse(true)
redemption:register()
