local StatutsPositions = {{x = 1427, y = 615, z = 14},  {x = 1433, y = 615, z = 14}}

function onStepIn(cid, item, pos, fromPosition)
	local player = Player(cid)

	if not player then
		return true
	end
	
	Position(StatutsPositions[1]):sendDistanceEffect(player:getPosition(), 4)
	Position(StatutsPositions[2]):sendDistanceEffect(player:getPosition(), 4)
	doTargetCombatHealth(0, cid, COMBAT_FIREDAMAGE, -200, -575, CONST_ME_FIREATTACK)
	doTargetCombatHealth(0, cid, COMBAT_FIREDAMAGE, -200, -575, CONST_ME_FIREATTACK)
	return true
end