if configManager.getNumber(configKeys.INSTANCE_TYPE) ~= 0 then
	return
end

local wildwood = Dungeon()

-- Basic info
wildwood:setTitle("Wildwood")
wildwood:setDuration(30 * 60 * 1000)
wildwood:setMapFile("wildwood")

wildwood:setStartPosition(Position(1000, 1000, 7))
-- Boss
wildwood:setBoss("Naturlord", Position(1000, 993, 7))
wildwood:setKillPercent(0)

-- Requirements
wildwood:setSolo(true)

-- Challenges
-- wildwood:addChallenge(ChallengesIndex.SPECTRE_DONE)


-- Instances
wildwood:addInstance(Position(3500, 0, 0))	--  Position: 408, 1980, 5
wildwood:addInstance(Position(3500, 1000, 0))
wildwood:addInstance(Position(3500, 2000, 0))
wildwood:addInstance(Position(3500, 3000, 0))
wildwood:addInstance(Position(3500, 4000, 0))
wildwood:addInstance(Position(3500, 5000, 0))
wildwood:addInstance(Position(3500, 6000, 0))
wildwood:addInstance(Position(3500, 7000, 0))
wildwood:addInstance(Position(3500, 8000, 0))
wildwood:addInstance(Position(3500, 9000, 0))
wildwood:addInstance(Position(3500, 10000, 0))
wildwood:addInstance(Position(3500, 11000, 0))
wildwood:addInstance(Position(3500, 12000, 0))
wildwood:addInstance(Position(3500, 13000, 0))
wildwood:addInstance(Position(3500, 14000, 0))

wildwood:register()
