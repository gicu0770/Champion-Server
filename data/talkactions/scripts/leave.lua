function onSay(player, words, param)
	if player:isPlayer() then
		if player:getStorageValue(PlayerStorage.riftBlokade) == 1 then
			player:setStorageValue(PlayerStorage.riftBlokade, -1)
			player:teleportTo(player:loadPosition(PlayerStorage.playerPosition))
			player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You back to portal position!")
			stopEvent(GoblinPortalKick)
			stopEvent(RiftPortalKick)
			return false
		end
	end
	if player:isPlayer() then
		local dungeon = player:getDungeon()
		if dungeon then
			local instance = dungeon:getPlayerInstance(player)
			if instance then
				dungeon:onPlayerLeave(player, true)
				local posEND = Position(675, 1040, 7)
				player:teleportTo(posEND)
				player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You back to town and left dungeon!")
				return false
			end
		end
	end
	player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You are not in Dungeon, Rift or Goblin Island!")	
	return false
end

