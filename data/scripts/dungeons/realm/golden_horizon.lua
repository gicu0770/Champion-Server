if configManager.getNumber(configKeys.INSTANCE_TYPE) ~= 0 then
	return
end

local goldenhorizon = Dungeon()

-- Basic info
goldenhorizon:setTitle("Golden Horizon")
goldenhorizon:setDuration(30 * 60 * 1000)
goldenhorizon:setMapFile("golden_horizon")

goldenhorizon:setStartPosition(Position(1043, 1048, 6))
-- Boss
goldenhorizon:setBoss("Holy Protector", Position(1037, 1025, 6))
goldenhorizon:setKillPercent(1)

-- Requirements
goldenhorizon:setSolo(true)

-- Challenges
-- goldenhorizon:addChallenge(ChallengesIndex.SPECTRE_DONE)


-- Instances
goldenhorizon:addInstance(Position(29000, 0, 0))	--  Position: 408, 1980, 5
goldenhorizon:addInstance(Position(29000, 1000, 0))
goldenhorizon:addInstance(Position(29000, 2000, 0))
goldenhorizon:addInstance(Position(29000, 3000, 0))
goldenhorizon:addInstance(Position(29000, 4000, 0))
goldenhorizon:addInstance(Position(29000, 5000, 0))
goldenhorizon:addInstance(Position(29000, 6000, 0))
goldenhorizon:addInstance(Position(29000, 7000, 0))
goldenhorizon:addInstance(Position(29000, 8000, 0))
goldenhorizon:addInstance(Position(29000, 9000, 0))
goldenhorizon:addInstance(Position(29000, 10000, 0))
goldenhorizon:addInstance(Position(29000, 11000, 0))
goldenhorizon:addInstance(Position(29000, 12000, 0))
goldenhorizon:addInstance(Position(29000, 13000, 0))
goldenhorizon:addInstance(Position(29000, 14000, 0))

goldenhorizon:register()
