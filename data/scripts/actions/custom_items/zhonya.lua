local TIME_STOP_CD = 201
local RESTART_IMMORTAL = 9

local zhonya = Action()

function zhonya.onUse(player, item, fromPosition, target, toPosition, isHotkey)
    local now = os.time()
    local cdKey = PlayerStorage.zhonyaCooldown
    local nextProc = player:getStorageValue(cdKey)
    if (nextProc and nextProc > now) or player:hasBuff(TIME_STOP_CD) then
        local remaining = (nextProc and nextProc > now) and (nextProc - now) or 0
        player:sendTextMessage(MESSAGE_STATUS_SMALL, "Zhonya's Hourglass is on cooldown for " .. remaining .. " seconds.")
        return true
    end

    -- Set cooldown to 120 seconds
    player:setStorageValue(cdKey, now + 120)
    player:addBuff(TIME_STOP_CD, 120000)

    -- Grant Immortality for 3 seconds
    player:addBuff(RESTART_IMMORTAL, 3000)

    -- Stasis: Stun player for 3 seconds
    local stun = Condition(CONDITION_STUN)
    stun:setParameter(CONDITION_PARAM_TICKS, 3000)
    player:addCondition(stun)
    player:addBuff(STUN, 3000)
    player:setProgressBar(3000, false)

    -- LoL Golden Stasis visual effect (shader) for 3 seconds
    if player.setShader then
        player:setShader("Golden", 3)
    end

    -- Visual effects
    player:getPosition():sendMagicEffect(CONST_ME_HOLYDAMAGE)
    player:getPosition():sendMagicEffect(CONST_ME_YELLOW_ENERGY_SPARK)

    player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "[Zhonya's Hourglass] Time Stop activated! You are in Stasis for 3 seconds (Cooldown: 120s).")
    return true
end

zhonya:id(24164)
zhonya:register()
