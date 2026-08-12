function onStepIn(player, item, position, fromPosition)
	if player:isPlayer() then
		local dungeon = player:getDungeon()
		if dungeon then
			local instance = dungeon:getPlayerInstance(player)
			if instance then
				if instance:isBossSpawned() then
				local instancePosition = instance:getPosition()	--{x = 274, y = 284, z = 2}
				local stonePos = { x = instancePosition.x + 274, y =  instancePosition.y + 284, z = 2 }
				player:teleportTo(stonePos)
				instance:finishBonusObjective(6)
				else
				player:teleportTo(fromPosition)
				player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You haven't defeated enough monsters to fight the boss!")
				end
			end
		end
	end
	return true
end
