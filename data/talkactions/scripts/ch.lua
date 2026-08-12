function onSay(player, words, param)
	if not player:getGroup():getAccess() then
		return true
	end

	-- player:teleportTo(Position(711,1034,7))
--	player:getTown():getTemplePosition()
	local pos = player:getPosition()
	pos.z = 7 + ((param-1) * 16)
	player:teleportTo(pos)
	return false
end
