function onSay(player, words, param)
	if player:isPlayer() then
		local dungeon = player:getDungeon()
		if dungeon then
			local instance = dungeon:getPlayerInstance(player)
			if instance then
					dungeon:onPlayerLeave(player, true)
				--local posEND = Position(714, 1029, 10)
				player:teleportTo(player:getTown():getTemplePosition())
			end
		end
	end
	return true
end
