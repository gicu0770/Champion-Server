local config = {
	[28810] = Position(1367, 95, 9),
	[28811] = Position(1381, 104, 9),
	[28812] = Position(1384, 88, 9),
	[28813] = Position(1395, 77, 9),
	[28814] = Position(1380, 98, 9),
	[28815] = Position(1394, 104, 9),
	[28816] = Position(1398, 77, 9),
	[28817] = Position(1396, 70, 9),
	[28818] = Position(1395, 99, 9)
}

function onStepIn(cid, item, position, fromPosition)
	local player = Player(cid)
	if not player then
		return true
	end
	
	local targetTile = config[item.actionid]
	if not targetTile then
		return true
	end
	
	player:teleportTo(targetTile)
	return true
end
