local config = {
	storages = {275400},
	teleportRoom = {x = 1054, y = 94, z = 7},
	area = {x = 1054, y = 86, z = 7},
	rangeArena = 12,
	enterText = "You entered the area kill Boss, there is no way out of this place until you kill him!.",
	monstersPos = {{x = 1054, y = 79, z = 7}}
}

local bossess = {
	[-1] = "Koon",
	[0] = "Brit",
	[1] = "Groomi",
	[2] = "Dronm",
	[3] = "Olp",
	[4] = "Borni",
	[5] = "Aron",
	[6] = "Timmi",
	[7] = "Rekto",
	[8] = "Werton",
}

function onStepIn(cid, item, pos, fromPosition)
	local player = Player(cid)
	if not player then
		Creature(cid):teleportTo(fromPosition)
		return true
	end
	
	local stoLevel = ((player:getStorageValue(PlayerStorage.darkTower) + 2) * 50) + 50
	if cid:getLevel() <= stoLevel then
	player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You need "..stoLevel.." Level to enter next floor!")
	player:teleportTo(fromPosition)
	return false
	end
-----------------
local creatruresPLAYER = Game.getSpectators(config.area, false, false, config.rangeArena, config.rangeArena, config.rangeArena, config.rangeArena)
	for _, creature in pairs(creatruresPLAYER) do
		if Player(creature:getId()) then
			Position(player:getPosition()):sendMagicEffect(CONST_ME_POFF)
			player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Somebody is inside!")
			player:teleportTo(fromPosition)
			return false
		end
	end
------------	
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
	

-------------------------------------PLAYER
	local sto = player:getStorageValue(PlayerStorage.darkTower)
	local floorTower = (sto + 2)
	if sto == 9 then
		player:teleportTo(fromPosition)
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You done all challenges!")
		return false
	end
	local monst = Game.createMonster(bossess[sto], config.monstersPos[1])
	---------------
	player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You entered the "..floorTower.." Floor of Dark Tower!")
	Position(player:getPosition()):sendMagicEffect(CONST_ME_TELEPORT)
	player:teleportTo(config.teleportRoom)
	Position(player:getPosition()):sendMagicEffect(CONST_ME_TELEPORT)
	return true
end