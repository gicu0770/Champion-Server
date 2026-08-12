function onStepIn(cid, item, pos, fromPosition)

if item.actionid == 27550 then
	local player = Player(cid)
	if not player then
		Creature(cid):teleportTo(fromPosition)
		return true
	end
				if player:getStorageValue(PlayerStorage.ogresQuest) <= 1 then
				Position(player:getPosition()):sendMagicEffect(CONST_ME_POFF)
				player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You cannot pass!")
				player:teleportTo(fromPosition)
				return false
				end
				if player:getStorageValue(PlayerStorage.ogresQuest) == 2 then
				Position(player:getPosition()):sendMagicEffect(CONST_ME_TELEPORT)
				player:teleportTo({x = 1802, y = 407, z = 8})
				return false
				end
			
	end
	return true
end