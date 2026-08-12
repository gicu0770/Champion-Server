function onSay(player, words, param)
	if not player:getGroup():getAccess() then
		return true
	end

	local target = Creature(param)
	local tagertPlayer = Player(param)
	if tagertPlayer then
		player:teleportTo(tagertPlayer:getPosition())
	elseif target then
		player:teleportTo(target:getPosition())
	else
		player:sendCancelMessage("Creature not found.")
	end
	return false
end
