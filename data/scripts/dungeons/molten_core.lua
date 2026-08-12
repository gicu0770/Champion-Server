if configManager.getNumber(configKeys.INSTANCE_TYPE) ~= 0 then
	return
end

local molten_core = Dungeon()

-- Basic info
molten_core:setTitle("Molten Core")
molten_core:setDuration(30 * 60 * 1000)
molten_core:setMapFile("molten_core")

molten_core:setStartPosition(Position(1000, 1000, 7))
-- Boss
molten_core:setBoss("Emberlord", Position(1000, 993, 7))
molten_core:setKillPercent(0)

-- Requirements
molten_core:setSolo(true)
-- Challenges
-- molten_core:addChallenge(ChallengesIndex.SPECTRE_DONE)


-- Instances
molten_core:addInstance(Position(2500, 0, 0))	--  Position: 408, 1980, 5
molten_core:addInstance(Position(2500, 1000, 0))
molten_core:addInstance(Position(2500, 2000, 0))
molten_core:addInstance(Position(2500, 3000, 0))
molten_core:addInstance(Position(2500, 4000, 0))
molten_core:addInstance(Position(2500, 5000, 0))
molten_core:addInstance(Position(2500, 6000, 0))
molten_core:addInstance(Position(2500, 7000, 0))
molten_core:addInstance(Position(2500, 8000, 0))
molten_core:addInstance(Position(2500, 9000, 0))
molten_core:addInstance(Position(2500, 10000, 0))
molten_core:addInstance(Position(2500, 11000, 0))
molten_core:addInstance(Position(2500, 12000, 0))
molten_core:addInstance(Position(2500, 13000, 0))
molten_core:addInstance(Position(2500, 14000, 0))

molten_core:register()
