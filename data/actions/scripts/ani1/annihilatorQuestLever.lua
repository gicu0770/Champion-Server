local config = {
	requiredLevel = 20,
	daily = false,
	returnPos = Position(498, 471, 7),
	centerDemonRoomPosition = Position(498, 465, 9),
	playerPositions = {
		Position(498, 462, 7),
		Position(498, 463, 7),
		Position(498, 464, 7),
		Position(498, 465, 7)
	},
	newPositions = {
		Position(498, 465, 9),
		Position(497, 465, 9),
		Position(496, 465, 9),
		Position(495, 465, 9)
	},
	demonPositions = {
		Position(499, 465, 9),
		Position(500, 465, 9),
		Position(500, 462, 9),
		Position(497, 462, 9),
		Position(492, 464, 9),
		Position(496, 468, 9),
		Position(494, 462, 9),
		Position(493, 468, 9),
		Position(499, 468, 9)
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
			Game.createMonster("Vexclaw", config.demonPositions[i])
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