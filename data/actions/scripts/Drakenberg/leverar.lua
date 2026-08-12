function onUse(cid, item, fromPosition, itemEx, toPosition)
	local player = Player(cid)
	Item(item.uid):transform(item.itemid == 9825 and 9826 or 9825)
	
	local creatrures = Game.getSpectators({x = 806, y = 721, z = 9}, false, false, 6, 6, 6, 6)
	
	for _, creature in pairs(creatrures) do
		if Monster(creature:getId()) then
			if creature:getSkull() < 100 then
				Position(player:getPosition()):sendMagicEffect(CONST_ME_POFF)
				player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Before you pull the lever, you must defeat the Varomirr.")
				return false
			end
		end
	end
	player:teleportTo({x = 806, y = 715, z = 9})
	Position(player:getPosition()):sendMagicEffect(CONST_ME_TELEPORT)
	return true
end