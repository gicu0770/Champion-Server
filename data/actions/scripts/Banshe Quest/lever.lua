function onUse(cid, item, fromPosition, itemEx, toPosition)
	local player = Player(cid)
	Item(item.uid):transform(item.itemid == 1945 and 1946 or 1945)
	
	local creatrures = Game.getSpectators({x = 1430, y = 616, z = 14}, false, false, 7, 7, 7, 7)
	
	for _, creature in pairs(creatrures) do
		if Monster(creature:getId()) then
			if creature:getSkull() < 100 then
				Position(player:getPosition()):sendMagicEffect(CONST_ME_POFF)
				player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Before you pull the lever, you must defeat the sorcerers.")
				return false
			end
		end
	end
	player:teleportTo({x = 1442, y = 593, z = 14})
	Position(player:getPosition()):sendMagicEffect(CONST_ME_TELEPORT)
	return true
end