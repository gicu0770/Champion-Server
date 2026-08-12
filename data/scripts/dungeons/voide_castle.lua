if configManager.getNumber(configKeys.INSTANCE_TYPE) ~= 0 then
	return
end

local voide_castle = Dungeon()

-- Basic info
voide_castle:setTitle("Void Castle")
voide_castle:setDuration(30 * 60 * 1000)
voide_castle:setMapFile("voide_castle")

voide_castle:setStartPosition(Position(231, 312, 3))
-- Boss
voide_castle:setBoss("Arbaziloth", Position(271, 261, 6))
voide_castle:setKillPercent(70)

-- Requirements
voide_castle:setSolo(true)

-- Challenges
-- voide_castle:addChallenge(ChallengesIndex.SPECTRE_DONE)


-- Instances
voide_castle:addInstance(Position(16000, 0, 0))	--  Position: 408, 1980, 5
voide_castle:addInstance(Position(16000, 1000, 0))
voide_castle:addInstance(Position(16000, 2000, 0))
voide_castle:addInstance(Position(16000, 3000, 0))
voide_castle:addInstance(Position(16000, 4000, 0))
voide_castle:addInstance(Position(16000, 5000, 0))
voide_castle:addInstance(Position(16000, 6000, 0))
voide_castle:addInstance(Position(16000, 7000, 0))
voide_castle:addInstance(Position(16000, 8000, 0))
voide_castle:addInstance(Position(16000, 9000, 0))
voide_castle:addInstance(Position(16000, 10000, 0))
voide_castle:addInstance(Position(16000, 11000, 0))
voide_castle:addInstance(Position(16000, 12000, 0))
voide_castle:addInstance(Position(16000, 13000, 0))
voide_castle:addInstance(Position(16000, 14000, 0))
voide_castle:addInstance(Position(16000, 15000, 0))
voide_castle:addInstance(Position(16000, 16000, 0))
voide_castle:addInstance(Position(16000, 17000, 0))
voide_castle:addInstance(Position(16000, 18000, 0))
voide_castle:addInstance(Position(16000, 19000, 0))
voide_castle:addInstance(Position(16000, 20000, 0))

voide_castle:register()
