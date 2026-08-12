local config = {
	teleportRoom = {x = 1667, y = 270, z = 10},
	area = {x = 1667, y = 259, z = 10},
	posKickQuestDone = {x = 711, y = 1034, z = 7}, --only if you want kick after done quest
	rangeArena = 17,
	bossName = "librarian",
	enterText = "You entered the area of the Librarian Boss, there is no way out of this place until you kill him!.",
	monstersPos = {{x = 1667, y = 258, z = 10}}
}

function onStepIn(cid, item, pos, fromPosition)
	local player = Player(cid)
	if not player then
		Creature(cid):teleportTo(fromPosition)
		return true
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
	Game.createMonster(config.bossName, config.monstersPos[1])
	player:sendTextMessage(MESSAGE_EVENT_ADVANCE, config.enterText)
	Position(player:getPosition()):sendMagicEffect(CONST_ME_TELEPORT)
	player:teleportTo(config.teleportRoom)
	Position(player:getPosition()):sendMagicEffect(CONST_ME_TELEPORT)
	return true
end