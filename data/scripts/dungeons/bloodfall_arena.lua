if configManager.getNumber(configKeys.INSTANCE_TYPE) ~= 0 then
	return
end

local bloodfall_arena = Dungeon()

-- Basic info
bloodfall_arena:setTitle("Bloodfall Arena")
bloodfall_arena:setDuration(30 * 60 * 1000)
bloodfall_arena:setMapFile("bloodfall")

bloodfall_arena:setStartPosition(Position(1000, 999, 7))  
-- Boss
bloodfall_arena:setBoss("Blood Fury", Position(1002, 991, 7)) 
bloodfall_arena:setKillPercent(0)

-- Requirements
bloodfall_arena:setSolo(true)

-- Challenges
-- bloodfall_arena:addChallenge(ChallengesIndex.SPECTRE_DONE)


-- Instances
bloodfall_arena:addInstance(Position(18500, 0, 0))	--  Position: 408, 1980, 5
bloodfall_arena:addInstance(Position(18500, 1000, 0))
bloodfall_arena:addInstance(Position(18500, 2000, 0))
bloodfall_arena:addInstance(Position(18500, 3000, 0))
bloodfall_arena:addInstance(Position(18500, 4000, 0))
bloodfall_arena:addInstance(Position(18500, 5000, 0))
bloodfall_arena:addInstance(Position(18500, 6000, 0))
bloodfall_arena:addInstance(Position(18500, 7000, 0))
bloodfall_arena:addInstance(Position(18500, 8000, 0))
bloodfall_arena:addInstance(Position(18500, 9000, 0))
bloodfall_arena:addInstance(Position(18500, 10000, 0))
bloodfall_arena:addInstance(Position(18500, 11000, 0))
bloodfall_arena:addInstance(Position(18500, 12000, 0))
bloodfall_arena:addInstance(Position(18500, 13000, 0))
bloodfall_arena:addInstance(Position(18500, 14000, 0))

bloodfall_arena:register()
