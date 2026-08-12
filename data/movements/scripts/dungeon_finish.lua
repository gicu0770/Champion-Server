function onStepIn(player, item, position, fromPosition)
	if player:isPlayer() then
		local dungeon = player:getDungeon()
		if dungeon then
			local instance = dungeon:getPlayerInstance(player)
			if instance then
				if not instance:isBossSpawned() or instance:getBoss() then
					dungeon:onPlayerLeave(player, false)
				else
					dungeon:onPlayerLeave(player, true)
				end
				DUNGEON_TP = {
					["Molten Core"] = {position = Position(837, 922, 7), storage = 801115},
					["Otherworld"] = {position = Position(1007, 900, 7), storage = 801116},
					["Wildwood"] = {position = Position(826, 1204, 7), storage = 801117},
					["Frostbound"] = {position = Position(274, 1271, 7), storage = 801118},
					["Firecastle Ruins"] = {position = Position(398, 835, 7), storage = 801119},
					["Bonebound Arena"] = {position = Position(1018, 1629, 7), storage = 801120}, -- linemap
					["Bloodfall Arena"] = {position = Position(674, 1024, 7), storage = 801121},
				}
				if DUNGEON_TP[dungeon:getTitle()] and player:getStorageValue(DUNGEON_TP[dungeon:getTitle()].storage) < 0 then
					player:teleportTo(DUNGEON_TP[dungeon:getTitle()].position)
					player:setStorageValue(DUNGEON_TP[dungeon:getTitle()].storage, 1)
				elseif DUNGEON_TP[dungeon:getTitle()] and player:getStorageValue(DUNGEON_TP[dungeon:getTitle()].storage) > 0 then
					player:teleportTo(DUNGEON_TP[dungeon:getTitle()].position)
				else
					player:teleportTo(Position(672, 1023, 7))
				end
			--	player:teleportTo(Position(692, 1025, 7))

			end
		end
	end
	return true
end
