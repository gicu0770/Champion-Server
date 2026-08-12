function onStepIn(cid, item, pos, fromPosition)
	-------------------------------------------------------	T6 Frozen SET
	if item.actionid == 30304 then
		local player = Player(cid)
		if not player then
			Creature(cid):teleportTo(fromPosition)
			return true
		end
		--	if player:getLevel() <= 899 then
		--		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Requires a level 900+")
		--		player:teleportTo(fromPosition)
		--	return false
		--	end
		if player:getStorageValue(PlayerStorage.frozenQuest) <= 1 then
			Position(player:getPosition()):sendMagicEffect(CONST_ME_POFF)
			player:sendTextMessage(MESSAGE_EVENT_ADVANCE,
				"You don't have access. You have to complete a quest for Frozen Giant!")
			player:teleportTo(fromPosition)
			return false
		end
		if player:getStorageValue(PlayerStorage.frozenQuest) == 2 then
			Position(player:getPosition()):sendMagicEffect(CONST_ME_TELEPORT)
			player:teleportTo({ x = 1802, y = 407, z = 8 })
			return false
		end
	end
	-----------------------------------------------------------------------------------------------	T6 OGRY ACCESORIES
	if item.actionid == 27554 then
		local player = Player(cid)
		if not player then
			Creature(cid):teleportTo(fromPosition)
			return true
		end
--		if player:getLevel() <= 899 then
--			player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Requires a level 900+")
--			player:teleportTo(fromPosition)
--			return false
--		end
		if player:getStorageValue(PlayerStorage.feralQuest) <= 1 then
			Position(player:getPosition()):sendMagicEffect(CONST_ME_POFF)
			player:sendTextMessage(MESSAGE_EVENT_ADVANCE,
				"You don't have access. You have to complete a quest for Tuzrog!")
			player:teleportTo(fromPosition)
			return false
		end
		if player:getStorageValue(PlayerStorage.feralQuest) == 2 then
			Position(player:getPosition()):sendMagicEffect(CONST_ME_TELEPORT)
			return false
		end
	end
	-----------------------------------------------------------------------------------------------	T7 SET/ACCESORIES
	if item.actionid == 27555 then
		local player = Player(cid)
		if not player then
			Creature(cid):teleportTo(fromPosition)
			return true
		end
--		if player:getLevel() <= 1099 then
--			player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Requires a level 1100+")
--			player:teleportTo(fromPosition)
--			return false
--		end
		if player:getStorageValue(PlayerStorage.darkForeiQuest) <= 1 then
			Position(player:getPosition()):sendMagicEffect(CONST_ME_POFF)
			player:sendTextMessage(MESSAGE_EVENT_ADVANCE,
				"You don't have access. You have to complete a quest for Ragmuth!")
			player:teleportTo(fromPosition)
			return false
		end
		if player:getStorageValue(PlayerStorage.darkForeiQuest) == 2 then
			Position(player:getPosition()):sendMagicEffect(CONST_ME_TELEPORT)
			player:teleportTo({ x = 944, y = 1670, z = 6 })
			return false
		end
	end
	if item.actionid == 27556 then
		local player = Player(cid)
		if not player then
			Creature(cid):teleportTo(fromPosition)
			return true
		end
		Position(player:getPosition()):sendMagicEffect(CONST_ME_TELEPORT)
		player:teleportTo({ x = 783, y = 981, z = 7 })
		return false
	end

	----------------------------------------------	T8 access SET portal	27558
	if item.actionid == 27563 or item.actionid == 27558 then
		local player = Player(cid)
		if not player then
			Creature(cid):teleportTo(fromPosition)
			return true
		end
--		if player:getLevel() <= 1299 then
--			player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Requires a level 1300+")
--			player:teleportTo(fromPosition)
--			return false
--		end
		Position(player:getPosition()):sendMagicEffect(CONST_ME_TELEPORT)
		return false
	end
	----------------------------------------------	T8 ACCESORIES
	if item.actionid == 27560 then
		local player = Player(cid)
		if not player then
			Creature(cid):teleportTo(fromPosition)
			return true
		end
--		if player:getLevel() <= 1299 then
--			player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Requires a level 1300+")
--			player:teleportTo(fromPosition)
--			return false
--		end
		if player:getStorageValue(PlayerStorage.t8accAskara) <= 1 then
			Position(player:getPosition()):sendMagicEffect(CONST_ME_POFF)
			player:sendTextMessage(MESSAGE_EVENT_ADVANCE,
				"You don't have access. You have to complete a quest for Ludwig!")
			player:teleportTo(fromPosition)
			return false
		end
		if player:getStorageValue(PlayerStorage.t8accAskara) == 2 then
			Position(player:getPosition()):sendMagicEffect(CONST_ME_TELEPORT)
			return false
		end
	end
	----------------------------------------------	T8 SET
	if item.actionid == 27559 then
		local player = Player(cid)
		if not player then
			Creature(cid):teleportTo(fromPosition)
			return true
		end
--		if player:getLevel() <= 1299 then
--			player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Requires a level 1300+")
--			player:teleportTo(fromPosition)
--			return false
--		end
		if player:getStorageValue(PlayerStorage.t8accHell) <= 1 then
			Position(player:getPosition()):sendMagicEffect(CONST_ME_POFF)
			player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You don't have access. You have to complete a quest for Gwyn!")
			player:teleportTo(fromPosition)
			return false
		end
		if player:getStorageValue(PlayerStorage.t8accHell) == 2 then
			Position(player:getPosition()):sendMagicEffect(CONST_ME_TELEPORT)
			return false
		end
	end

	----------------------------------------------	T7 1200 exp
	if item.actionid == 27564 then
		local player = Player(cid)
		if not player then
			Creature(cid):teleportTo(fromPosition)
			return true
		end
--		if player:getLevel() <= 1199 then
--			player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Requires a level 1200+")
--			player:teleportTo(fromPosition)
--			return false
--		end
		if player:getStorageValue(PlayerStorage.t7access) <= 1 then
			Position(player:getPosition()):sendMagicEffect(CONST_ME_POFF)
			player:sendTextMessage(MESSAGE_EVENT_ADVANCE,
				"You don't have access. You have to complete a quest for Heaven Demon!")
			player:teleportTo(fromPosition)
			return false
		end
	end
	----------------------------------------------	T9 exp
	if item.actionid == 27565 then
		local player = Player(cid)
		if not player then
			Creature(cid):teleportTo(fromPosition)
			return true
		end
--		if player:getLevel() <= 1499 then
--			player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Requires a level 1500+")
--			player:teleportTo(fromPosition)
--			return false
--		end
--		if getParagonLevel(player) < 50 then
--			player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Requires a Paragon Level 50+")
--			player:teleportTo(fromPosition)
--			return false
--		end
		if player:getLevel() < 1300 then
			player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Requires a Paragon Level 1300+")
			player:teleportTo(fromPosition)
			return false
		end
		if player:getStorageValue(PlayerStorage.t9access) <= 1 then
			Position(player:getPosition()):sendMagicEffect(CONST_ME_POFF)
			player:sendTextMessage(MESSAGE_EVENT_ADVANCE,
				"You don't have access. You have to complete a quest for Varhmiel [Djinn Fortress!]")
			player:teleportTo(fromPosition)
			return false
		end
	end

	return true
end
