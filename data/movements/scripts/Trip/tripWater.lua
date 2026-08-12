function onStepIn(cid, item, pos, fromPosition)

if item.actionid == 9118 then
	local player = Player(cid)
	if not player then
		Creature(cid):teleportTo(fromPosition)
		return true
	end
	Position(player:getPosition()):sendMagicEffect(CONST_ME_POFF)
	player:teleportTo(Position( 537, 1719, 12))		
	end
	return true
end