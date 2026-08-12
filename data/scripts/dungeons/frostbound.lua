if configManager.getNumber(configKeys.INSTANCE_TYPE) ~= 0 then
	return
end

local frostbound = Dungeon()

-- Basic info
frostbound:setTitle("Frostbound")
frostbound:setDuration(30 * 60 * 1000)
frostbound:setMapFile("frostbound")

frostbound:setStartPosition(Position(1000, 1000, 7))
-- Boss
frostbound:setBoss("Icelord", Position(1000, 993, 7))
frostbound:setKillPercent(0)

-- Requirements
frostbound:setSolo(true)

-- Challenges
-- frostbound:addChallenge(ChallengesIndex.SPECTRE_DONE)


-- Instances
frostbound:addInstance(Position(4000, 0, 0))	--  Position: 408, 1980, 5
frostbound:addInstance(Position(4000, 1000, 0))
frostbound:addInstance(Position(4000, 2000, 0))
frostbound:addInstance(Position(4000, 3000, 0))
frostbound:addInstance(Position(4000, 4000, 0))
frostbound:addInstance(Position(4000, 5000, 0))
frostbound:addInstance(Position(4000, 6000, 0))
frostbound:addInstance(Position(4000, 7000, 0))
frostbound:addInstance(Position(4000, 8000, 0))
frostbound:addInstance(Position(4000, 9000, 0))
frostbound:addInstance(Position(4000, 10000, 0))
frostbound:addInstance(Position(4000, 11000, 0))
frostbound:addInstance(Position(4000, 12000, 0))
frostbound:addInstance(Position(4000, 13000, 0))
frostbound:addInstance(Position(4000, 14000, 0))

frostbound:register()
