if configManager.getNumber(configKeys.INSTANCE_TYPE) ~= 0 then
	return
end

local firecastle_ruins = Dungeon()

-- Basic info
firecastle_ruins:setTitle("Firecastle Ruins")
firecastle_ruins:setDuration(30 * 60 * 1000)
firecastle_ruins:setMapFile("firecastle_ruins")

firecastle_ruins:setStartPosition(Position(1000, 1000, 7))
-- Boss
firecastle_ruins:setBoss("Voort", Position(1011, 1000, 7))
firecastle_ruins:setKillPercent(0)

-- Requirements
firecastle_ruins:setSolo(true)

-- Challenges
-- firecastle_ruins:addChallenge(ChallengesIndex.SPECTRE_DONE)


-- Instances
firecastle_ruins:addInstance(Position(4500, 0, 0))	--  Position: 408, 1980, 5
firecastle_ruins:addInstance(Position(4500, 1000, 0))
firecastle_ruins:addInstance(Position(4500, 2000, 0))
firecastle_ruins:addInstance(Position(4500, 3000, 0))
firecastle_ruins:addInstance(Position(4500, 4000, 0))
firecastle_ruins:addInstance(Position(4500, 5000, 0))
firecastle_ruins:addInstance(Position(4500, 6000, 0))
firecastle_ruins:addInstance(Position(4500, 7000, 0))
firecastle_ruins:addInstance(Position(4500, 8000, 0))
firecastle_ruins:addInstance(Position(4500, 9000, 0))
firecastle_ruins:addInstance(Position(4500, 10000, 0))
firecastle_ruins:addInstance(Position(4500, 11000, 0))
firecastle_ruins:addInstance(Position(4500, 12000, 0))
firecastle_ruins:addInstance(Position(4500, 13000, 0))
firecastle_ruins:addInstance(Position(4500, 14000, 0))

firecastle_ruins:register()
