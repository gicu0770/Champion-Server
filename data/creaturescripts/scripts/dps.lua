DPS_STORAGE = PlayerStorage.dpsStorage
PLAYER_DPS = {}
PLAYER_EVENTS = {}

function ReadDPS(pid, cid)
    local player = Player(pid)
    local target = Monster(cid)
    if player and target then
        PLAYER_DPS[pid] = PLAYER_DPS[pid] * -1
        if PLAYER_DPS[pid] > player:getStorageValue(DPS_STORAGE) then
            player:setStorageValue(DPS_STORAGE, PLAYER_DPS[pid] / 10000000)
            target:say(string.format("New Record! DPS: %s", formatDamage(PLAYER_DPS[pid])), TALKTYPE_MONSTER_SAY, false, player, target:getPosition())
            player:sendTextMessage(MESSAGE_INFO_DESCR, "New Record! Damage dealt: " .. formatDamage(PLAYER_DPS[pid]) .. "")
        else
            target:say(string.format("DPS: %s", formatDamage(PLAYER_DPS[pid])), TALKTYPE_MONSTER_SAY, false, player, target:getPosition())
            player:sendTextMessage(MESSAGE_INFO_DESCR, "Damage dealt: " .. formatDamage(PLAYER_DPS[pid]) .. "")
        end
        PLAYER_DPS[pid] = 0
        PLAYER_EVENTS[pid] = nil
    end
end

function onHealthChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
    if not creature then return primaryDamage, primaryType, secondaryDamage, secondaryType end
    if not attacker then return primaryDamage, primaryType, secondaryDamage, secondaryType end

    if creature:isMonster() and attacker:isPlayer() then
        if creature:getName() == "Dummy DPS" or creature:getName() == "Dummy Armored" or creature:getName() == "Dummy Boss" then
            local damage = primaryDamage + secondaryDamage
            local pid = attacker:getId()
            local cid = creature:getId()
            if not PLAYER_DPS[pid] then PLAYER_DPS[pid] = 0 end
            PLAYER_DPS[pid] = PLAYER_DPS[pid] + damage
            if not PLAYER_EVENTS[pid] then
                PLAYER_EVENTS[pid] = addEvent(ReadDPS, 5000, pid, cid)
            end
        end
    end

    return primaryDamage, primaryType, secondaryDamage, secondaryType
end