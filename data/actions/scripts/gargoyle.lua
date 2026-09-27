local GARGOYLE_STONEPLATE_CD = 209

local config = {
    cooldown = 90, -- seconds
    duration = 4000, -- 4 seconds
    baseShield = 100,
    hpMultiplier = 0.25, -- 25% max HP
}

function onUse(player, item, fromPosition, target, toPosition, isHotkey)
    local now = os.time()
    local nextUse = player:getStorageValue(PlayerStorage.gargoyleActiveCd) or 0
    if now < nextUse or player:hasBuff(GARGOYLE_STONEPLATE_CD) then
        local remaining = (nextUse > now) and (nextUse - now) or 0
        player:sendTextMessage(MESSAGE_STATUS_SMALL, "Gargoyle Stoneplate is on cooldown for " .. remaining .. " seconds.")
        return false
    end

    -- Add shield
    local maxHp = player:getMaxHealth()
    local shieldAmount = config.baseShield + math.floor(maxHp * config.hpMultiplier)
    
    player:addEnergyShieldDuration(shieldAmount, config.duration, 1.0)
    
    -- Visual effects
    player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
    -- We skip size increase (25%) since it requires OTClient opcode/source changes, but shield works perfectly.
    
    player:sendTextMessage(MESSAGE_INFO_DESCR, "You activated Gargoyle Stoneplate, gaining a " .. shieldAmount .. " HP shield for 4 seconds!")

    player:setStorageValue(PlayerStorage.gargoyleActiveCd, now + config.cooldown)
    player:addBuff(GARGOYLE_STONEPLATE_CD, config.cooldown * 1000)
    return true
end
