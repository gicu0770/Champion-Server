local config = {
	requiredLevel = 50,
	daily = false,
	centerDemonRoomPosition = Position(1238, 557, 9),
	returnPos = Position(1245, 572, 7),
	playerPositions = {
		Position(1245, 565, 7),
		Position(1245, 566, 7),
		Position(1245, 567, 7),
		Position(1245, 568, 7)
	},
	newPositions = {
		Position(1238, 557, 9),
		Position(1237, 557, 9),
		Position(1236, 557, 9),
		Position(1235, 557, 9)
	},
	demonPositions = {
		Position(1239, 557, 9),
		Position(1240, 557, 9),
		Position(1240, 554, 9),
		Position(1237, 554, 9),
		Position(1232, 556, 9),
		Position(1236, 560, 9),
		Position(1234, 554, 9),
		Position(1233, 560, 9),
		Position(1239, 560, 9)
	}
}

local lastUseEvent = nil
function onUse(cid, item, fromPosition, itemEx, toPosition)
	local lever = Item(item.uid)
	local player = Player(cid)
	if item.itemid == 1946 then
		local players = {}
		local continue = true
		for _, positions in ipairs(config.playerPositions) do
		local playerTile = Tile(positions):getTopCreature()
			if playerTile ~= nil and playerTile:isPlayer() and playerTile:getLevel() < config.requiredLevel then
			local playername = playerTile:getName()
			player:sendTextMessage(MESSAGE_INFO_DESCR, ""..playername.." need "..config.requiredLevel.." level.")
			return false
			end
		end
		for _, positions in ipairs(config.playerPositions) do
			local playerTile = Tile(positions):getTopCreature()
--			if playerTile:getLevel() < config.requiredLevel then
--				player:sendTextMessage(MESSAGE_INFO_DESCR, "Need 150 level.")
--				return false
--			end
			players[#players+1] = playerTile
		end

		local specs = Game.getSpectators(config.centerDemonRoomPosition, false, false, 3, 3, 3, 3)
		for i = 1, #specs do
			if specs[i]:isPlayer() then
				player:sendTextMessage(MESSAGE_INFO_DESCR, "A team is already inside the quest room.")
				continue = false
				return false
			end
		end

		local specs = Game.getSpectators(config.centerDemonRoomPosition, false, false, 3, 3, 3, 3)
		for i = 1, #specs do
			if specs[i]:isMonster() then
				specs[i]:remove()
			end
		end

		if not continue then
			return true
		end

		for i = 1, #config.demonPositions do
			Game.createMonster("Grimeleech", config.demonPositions[i])
		end

		for i, tablePlayer in ipairs(players) do
			config.playerPositions[i]:sendMagicEffect(CONST_ME_POFF)
			tablePlayer:teleportTo(config.newPositions[i])
			tablePlayer:getPosition():sendMagicEffect(CONST_ME_ENERGYAREA)
			tablePlayer:setDirection(EAST)
		end

		if lastUseEvent then
			stopEvent(lastUseEvent)
			lastUseEvent = nil
		end
		lastUseEvent = addEvent(function()
			local specs = Game.getSpectators(config.centerDemonRoomPosition, false, false, 3, 3, 3, 3)
			for i = 1, #specs do
				if specs[i]:isPlayer() then
					player:sendTextMessage(MESSAGE_INFO_DESCR, "You took too long and have been kicked from quest.")
					player:teleportTo(config.returnPos)
				end
			end
		end, 1000*60*5)
		lever:transform(item.itemid - 1)
	elseif item.itemid == 1945 then
		if config.daily then
			player:sendTextMessage(MESSAGE_INFO_DESCR, Game.getReturnMessage(RETURNVALUE_NOTPOSSIBLE))
		else
			lever:transform(item.itemid + 1)
		end
	end
	return true
end