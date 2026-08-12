-- When player dies in Zombie Arena
function onPrepareDeath(player, corpse, killer, mostDamageKiller, lastHitUnjustified, mostDamageUnjustified)

    -- Has the event started?
	if zombieArena:isStarted() then
    -- Did a player die?
	if player:isPlayer() then
        -- Is the player doing the event?
	if zombieArena:isPlayerOnEvent(player) then
		local hp = player:getMaxHealth()
		player:addHealth(hp)
	player:teleportTo(player:getTown():getTemplePosition())
	zombieArena:debug(player:getName() .. " got teleported to " .. player:getTown():getName() .. ".")
	zombieArena:removePlayer(player)
	zombieArena:checkArena()
	return false
	end
	end
	end

    return true
end