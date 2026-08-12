local config = {
	pPos = {x = 802, y = 726, z = 9},
	storages = {226325, 226325, 226325},
	tpPos = {x = 802, y = 726, z = 9},
	monstersPos = {{x = 807, y = 721, z = 9}}
}

function checkArea()
	local creatrures = Game.getSpectators({x = 806, y = 721, z = 9}, false, false, 6, 6, 6, 6)
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


	if player:getStorageValue(226325) > 0 then	         -------------------STORAGER
	Position(player:getPosition()):sendMagicEffect(CONST_ME_POFF)
	player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You've already done this quest!")
	player:teleportTo({x = 798, y = 713, z = 7})         ----------------------------TP jesli juz masz wykonany quest
	return false
	end
	
local creatrures = Game.getSpectators({x = 806, y = 721, z = 9}, false, false, 6, 6, 6, 6)
	
	for _, creature in pairs(creatrures) do
		if Player(creature:getId()) then
			Position(player:getPosition()):sendMagicEffect(CONST_ME_POFF)
			player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Somebody is inside!")
			player:teleportTo(fromPosition)
			return false
		end
	end
	checkArea()
	Game.createMonster("Varomirr", config.monstersPos[1])
	player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Kill the Varomirr before you go for your reward!")
	Position(player:getPosition()):sendMagicEffect(CONST_ME_TELEPORT)
	player:teleportTo(config.tpPos)
	Position(player:getPosition()):sendMagicEffect(CONST_ME_TELEPORT)
	return true
end