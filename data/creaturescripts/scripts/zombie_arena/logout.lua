-- When player logs out in Zombie Arena
-- This is written just in case
-- The code should never happen
function onLogout(player)
print("OK")
    -- Has the event started?
    if not zombieArena:isStarted() then
	print("OK2")
        return true
    end
print("OK3")
    -- Did a player logout?
    if player:isPlayer() then
       print("OK4")
        -- Is the player doing the event?
        if not zombieArena:isPlayerOnEvent(player) then
		print("OK5")
            return true
        end
       
        player:teleportTo(player:getTown():getTemplePosition())
		print("OK6")
        zombieArena:removePlayer(player)
    end   
    return true
end