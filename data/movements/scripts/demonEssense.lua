function onStepIn(cid, item, pos, fromPosition)
	if item.actionid == 30303 then
		local player = Player(cid)
		if not player then
			Creature(cid):teleportTo(fromPosition)
			return true
		end
		--	if player:getLevel() < 250 then
		--		player:teleportTo(fromPosition)
		--		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You need level 250!")
		--	return false
		--	end

		if player:getStorageValue(170001) <= 1 then
			Position(player:getPosition()):sendMagicEffect(CONST_ME_POFF)
			player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You cannot pass!")
			player:teleportTo(fromPosition)
			return false
		end
		if player:getStorageValue(170001) == 2 then
			Position(player:getPosition()):sendMagicEffect(CONST_ME_TELEPORT)
			player:teleportTo({ x = 456, y = 1526, z = 5 })
			return false
		end
	end
	return true
end
