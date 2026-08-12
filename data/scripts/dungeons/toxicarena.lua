if configManager.getNumber(configKeys.INSTANCE_TYPE) ~= 0 then
	return
end

local firecastle_ruins = Dungeon()

-- Basic info
firecastle_ruins:setTitle("Toxic Arena")
firecastle_ruins:setDuration(30 * 60 * 1000)
firecastle_ruins:setMapFile("toxicarena")

firecastle_ruins:setStartPosition(Position(1000, 1010, 3))
-- Boss
firecastle_ruins:setBoss("Forest Keeper", Position(1000, 1000, 3))
firecastle_ruins:setKillPercent(0)

-- Requirements
firecastle_ruins:setSolo(true)

-- Challenges
-- firecastle_ruins:addChallenge(ChallengesIndex.SPECTRE_DONE)


-- Instances
firecastle_ruins:addInstance(Position(5500, 0, 0))	--  Position: 408, 1980, 5
firecastle_ruins:addInstance(Position(5500, 1000, 0))
firecastle_ruins:addInstance(Position(5500, 2000, 0))
firecastle_ruins:addInstance(Position(5500, 3000, 0))
firecastle_ruins:addInstance(Position(5500, 4000, 0))
firecastle_ruins:addInstance(Position(5500, 5000, 0))
firecastle_ruins:addInstance(Position(5500, 6000, 0))
firecastle_ruins:addInstance(Position(5500, 7000, 0))
firecastle_ruins:addInstance(Position(5500, 8000, 0))
firecastle_ruins:addInstance(Position(5500, 9000, 0))
firecastle_ruins:addInstance(Position(5500, 10000, 0))
firecastle_ruins:addInstance(Position(5500, 11000, 0))
firecastle_ruins:addInstance(Position(5500, 12000, 0))
firecastle_ruins:addInstance(Position(5500, 13000, 0))
firecastle_ruins:addInstance(Position(5500, 14000, 0))

firecastle_ruins:register()
