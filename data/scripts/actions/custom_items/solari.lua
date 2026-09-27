local SOLARI_CD = 212

local solari = Action()

function solari.onUse(player, item, fromPosition, target, toPosition, isHotkey)
    local now = os.time()
    local cdKey = PlayerStorage.solariCooldown
    local nextUse = player:getStorageValue(cdKey)
    if (nextUse and nextUse > now) or player:hasBuff(SOLARI_CD) then
        local remaining = (nextUse and nextUse > now) and (nextUse - now) or 0
        player:sendTextMessage(MESSAGE_STATUS_SMALL, "Locket of the Iron Solari is on cooldown for " .. remaining .. " seconds.")
        return true
    end

    -- 90 seconds cooldown
    player:setStorageValue(cdKey, now + 90)
    player:addBuff(SOLARI_CD, 90000)

    local shieldDuration = 3500 -- 3.5 seconds
    local shieldAmount = 250 + math.floor(player:getLevel() * 5)
    local centerPos = player:getPosition()
    local radius = 5

    -- Grant shield to the caster
    player:addEnergyShieldDuration(shieldAmount, shieldDuration, 1.0)
    player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
    player:getPosition():sendMagicEffect(CONST_ME_HOLYDAMAGE)

    -- Grant shield to nearby party members / allies within radius
    local spectators = Game.getSpectators(centerPos, false, true, radius, radius, radius, radius)
    local alliesShielded = 0
    for _, spec in ipairs(spectators) do
        if spec:isPlayer() and spec:getId() ~= player:getId() then
            local isAlly = false
            if player:getParty() and spec:getParty() and player:getParty() == spec:getParty() then
                isAlly = true
            elseif not player:getParty() then
                isAlly = true
            end

            if isAlly then
                spec:addEnergyShieldDuration(shieldAmount, shieldDuration, 1.0)
                spec:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
                spec:getPosition():sendMagicEffect(CONST_ME_HOLYDAMAGE)
                spec:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, string.format("[Locket of the Iron Solari] You received a %d HP Energy Shield from %s!", shieldAmount, player:getName()))
                alliesShielded = alliesShielded + 1
            end
        end
    end

    player:sendTextMessage(MESSAGE_INFO_DESCR, string.format("[Locket of the Iron Solari] Devotion activated! You granted a %d HP Energy Shield to yourself and %d allies for 3.5 seconds (Cooldown: 90s).", shieldAmount, alliesShielded))
    return true
end

solari:id(11261)
solari:allowFarUse(true)
solari:register()
