function onStepIn(cid, item, pos, fromPosition)
----------------------------------------------	T9 exp
if item.actionid == 27565 then
	local player = Player(cid)
	if not player then
		Creature(cid):teleportTo(fromPosition)
		return true
	end
--	if player:getLevel() <= 1499 then
--		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Requires a level 1500+")
--		player:teleportTo(fromPosition)
--	return false
--	end
	if getParagonLevel(player) < 50 then
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Requires a Paragon Level 50+")
		player:teleportTo(fromPosition)
	return false
	end
	if player:getStorageValue(PlayerStorage.t9access) <= 1 then
		Position(player:getPosition()):sendMagicEffect(CONST_ME_POFF)
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You don't have access. You have to complete a quest for Varhmiel [Djinn Fortress!]")
		player:teleportTo(fromPosition)
	return false
	end
end

	return true
end