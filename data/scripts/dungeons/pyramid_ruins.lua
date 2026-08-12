if configManager.getNumber(configKeys.INSTANCE_TYPE) ~= 0 then
	return
end

local pyramidruins = Dungeon()

-- Basic info
pyramidruins:setTitle("Pyramid Ruins")
pyramidruins:setDuration(30 * 60 * 1000)
pyramidruins:setMapFile("pyramid_ruins")

pyramidruins:setStartPosition(Position(1035, 1062, 7))
-- Boss
pyramidruins:setBoss("Copper Golem", Position(1035, 1035, 7))
pyramidruins:setKillPercent(0)

-- Requirements
pyramidruins:setSolo(true)

-- Challenges
-- pyramidruins:addChallenge(ChallengesIndex.SPECTRE_DONE)


-- Instances
pyramidruins:addInstance(Position(28000, 0, 0))	--  Position: 408, 1980, 5
pyramidruins:addInstance(Position(28000, 1000, 0))
pyramidruins:addInstance(Position(28000, 2000, 0))
pyramidruins:addInstance(Position(28000, 3000, 0))
pyramidruins:addInstance(Position(28000, 4000, 0))
pyramidruins:addInstance(Position(28000, 5000, 0))
pyramidruins:addInstance(Position(28000, 6000, 0))
pyramidruins:addInstance(Position(28000, 7000, 0))
pyramidruins:addInstance(Position(28000, 8000, 0))
pyramidruins:addInstance(Position(28000, 9000, 0))
pyramidruins:addInstance(Position(28000, 10000, 0))
pyramidruins:addInstance(Position(28000, 11000, 0))
pyramidruins:addInstance(Position(28000, 12000, 0))
pyramidruins:addInstance(Position(28000, 13000, 0))
pyramidruins:addInstance(Position(28000, 14000, 0))

pyramidruins:register()
