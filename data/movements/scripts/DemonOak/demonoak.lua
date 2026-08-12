local config = {
	area = {x = 903, y = 502, z = 7},
	rangeArena = 7
}

function onStepIn(cid, item, pos, fromPosition)
	local player = Player(cid)
	local creatrures = Game.getSpectators(config.area, false, false, config.rangeArena, config.rangeArena, config.rangeArena, config.rangeArena)
	local monsters = {}
	for _, creature in pairs(creatrures) do
		if Monster(creature:getId()) then
			table.insert(monsters, creature:getId())
		elseif Player(creature:getId()) then
			return false
		end
	end
	for i=1, #monsters do
		Monster(monsters[i]):remove()
	end
	return true
end