if configManager.getNumber(configKeys.INSTANCE_TYPE) ~= 0 then
	return
end

local icecastle = Dungeon()

-- Basic info
icecastle:setTitle("Ice Castle")
icecastle:setDuration(30 * 60 * 1000)
icecastle:setMapFile("ice_castle")

icecastle:setStartPosition(Position(1028, 1036, 6))
-- Boss
icecastle:setBoss("Frost Beast", Position(1028, 1027, 6))
icecastle:setKillPercent(0)

-- Requirements
icecastle:setSolo(true)

-- Challenges
-- icecastle:addChallenge(ChallengesIndex.SPECTRE_DONE)


-- Instances
icecastle:addInstance(Position(30000, 0, 0))	--  Position: 408, 1980, 5
icecastle:addInstance(Position(30000, 1000, 0))
icecastle:addInstance(Position(30000, 2000, 0))
icecastle:addInstance(Position(30000, 3000, 0))
icecastle:addInstance(Position(30000, 4000, 0))
icecastle:addInstance(Position(30000, 5000, 0))
icecastle:addInstance(Position(30000, 6000, 0))
icecastle:addInstance(Position(30000, 7000, 0))
icecastle:addInstance(Position(30000, 8000, 0))
icecastle:addInstance(Position(30000, 9000, 0))
icecastle:addInstance(Position(30000, 10000, 0))
icecastle:addInstance(Position(30000, 11000, 0))
icecastle:addInstance(Position(30000, 12000, 0))
icecastle:addInstance(Position(30000, 13000, 0))
icecastle:addInstance(Position(30000, 14000, 0))

icecastle:register()
