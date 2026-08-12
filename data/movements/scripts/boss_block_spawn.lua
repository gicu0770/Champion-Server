function onStepIn(player, item, position, fromPosition)
	if player:isPlayer() then
		player:teleportTo(fromPosition)
	end
	return true
end
