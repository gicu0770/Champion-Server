-- When player kills a Zombie in Zombie Arena
function onKill(player, target, lastHit)

    -- Has the event started?
    if not zombieArena:isStarted() then
        return false
    end

    -- Was the killer a player?
    if player:isPlayer() then

        -- Is the player doing the event?
        if not zombieArena:isPlayerOnEvent(player) then
            return false
        end
       
        -- Was the monster killed a zombie?
        if target:getName() == zombieArena.config.monster then
            zombieArena:onKill(player)
            return true
        end

        return false
    end
end