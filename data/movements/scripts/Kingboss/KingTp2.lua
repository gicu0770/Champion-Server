local config = {
	pPos = {x = 1301, y = 541, z = 10},
	storages = {25003},
	tpPos = {x = 1301, y = 541, z = 10},
	monstersPos = {{x = 1303, y = 554, z = 10}}
}

function checkArea()
	local creatrures = Game.getSpectators({x = 1303, y = 553, z = 10}, false, false, 13, 13, 13, 13)
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
	if player:getStorageValue(config.storages) > 0 then	
	Position(player:getPosition()):sendMagicEffect(CONST_ME_POFF)
	player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You've already done this quest!")
	player:teleportTo({x = 1408, y = 614, z = 13})
	return false
	end

	
local creatrures = Game.getSpectators({x = 1303, y = 553, z = 10}, false, false, 13, 13, 13, 13)
	
	for _, creature in pairs(creatrures) do
		if Player(creature:getId()) then
			Position(player:getPosition()):sendMagicEffect(CONST_ME_POFF)
			player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Somebody is inside!")
			player:teleportTo(fromPosition)
			return false
		end
	end
	checkArea()
	Game.createMonster("Forgotten King", config.monstersPos[1])
	player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You entered the area of the Forgotten Boss, there is no way out of this place until you kill him! When you kill him, collect special items from him and as soon as possible go to the Teleport which will appear in the center of the screen and be available for 120 seconds, otherwise you will be stuck here forever!")
	Position(player:getPosition()):sendMagicEffect(CONST_ME_TELEPORT)
	player:teleportTo(config.tpPos)
	Position(player:getPosition()):sendMagicEffect(CONST_ME_TELEPORT)
	return true
end