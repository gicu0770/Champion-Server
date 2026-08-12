local config = {
	pPos = {x = 1430, y = 620, z = 14},
	tpPos = {x = 1430, y = 620, z = 14},
	monstersPos = {{x = 1428, y = 615, z = 14},{x = 1430, y = 615, z = 14}, {x = 1432, y = 615, z = 14}}
}

local function checkArea()
	local creatrures = Game.getSpectators({x = 1430, y = 616, z = 14}, false, false, 5, 5, 5, 5)
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
	return false
end

function onStepIn(cid, item, pos, fromPosition)
	local player = Player(cid)

	if not player then
		Creature(cid):teleportTo(fromPosition)
		return true
	end


	
local creatrures = Game.getSpectators({x = 1430, y = 616, z = 14}, false, false, 7, 7, 7, 7)
	
	for _, creature in pairs(creatrures) do
		if Player(creature:getId()) then
			Position(player:getPosition()):sendMagicEffect(CONST_ME_POFF)
			player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Somebody is inside!")
			player:teleportTo(fromPosition)
			return false
		end
	end
	checkArea()
	Game.createMonster("Demon", config.monstersPos[1])
	Game.createMonster("Warlock", config.monstersPos[2])
	Game.createMonster("Warlock", config.monstersPos[3])
	player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Kill the Sorcerers before you go for your reward!")
	Position(player:getPosition()):sendMagicEffect(CONST_ME_TELEPORT)
	player:teleportTo(config.tpPos)
	Position(player:getPosition()):sendMagicEffect(CONST_ME_TELEPORT)
	return true
end