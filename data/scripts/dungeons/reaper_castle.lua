if configManager.getNumber(configKeys.INSTANCE_TYPE) ~= 0 then
	return
end

local reaper_castle = Dungeon()

-- Basic info
reaper_castle:setTitle("Reaper Castle")
reaper_castle:setDuration(30 * 60 * 1000)
reaper_castle:setMapFile("reaperarena")

reaper_castle:setStartPosition(Position(1027, 1043, 6))
-- Boss
reaper_castle:setBoss("Reaper Shade", Position(1027, 1030, 6))
reaper_castle:setKillPercent(0)

-- Requirements
reaper_castle:setSolo(true)

-- Challenges
-- reaper_castle:addChallenge(ChallengesIndex.SPECTRE_DONE)


-- Instances
reaper_castle:addInstance(Position(12000, 0, 0))	--  Position: 408, 1980, 5
reaper_castle:addInstance(Position(12000, 1000, 0))
reaper_castle:addInstance(Position(12000, 2000, 0))
reaper_castle:addInstance(Position(12000, 3000, 0))
reaper_castle:addInstance(Position(12000, 4000, 0))
reaper_castle:addInstance(Position(12000, 5000, 0))
reaper_castle:addInstance(Position(12000, 6000, 0))
reaper_castle:addInstance(Position(12000, 7000, 0))
reaper_castle:addInstance(Position(12000, 8000, 0))
reaper_castle:addInstance(Position(12000, 9000, 0))
reaper_castle:addInstance(Position(12000, 10000, 0))
reaper_castle:addInstance(Position(12000, 11000, 0))
reaper_castle:addInstance(Position(12000, 12000, 0))
reaper_castle:addInstance(Position(12000, 13000, 0))
reaper_castle:addInstance(Position(12000, 14000, 0))

reaper_castle:register()
