function onStepIn(cid, item, position, fromPosition)
	local player = Player(cid)
	if not player then
		return false
	end

	if player:getItemCount(1970) >= 1 then
		if item.uid == 20000 then
			player:teleportTo(Position(1314, 88, 10), false)
			player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
		elseif item.uid == 20001 then
			player:teleportTo(Position(1314, 84, 10), false)
			player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
		end
	else
		player:teleportTo(fromPosition)
	end
	return true
end
