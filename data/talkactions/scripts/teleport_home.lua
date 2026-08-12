function onSay(player, words, param)
	if not player:getGroup():getAccess() then
		return true
	end

	-- player:teleportTo(Position(711,1034,7))
--	player:getTown():getTemplePosition()
player:teleportTo(Position(675,1040,7))
	return false
end
