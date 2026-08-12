if configManager.getNumber(configKeys.INSTANCE_TYPE) ~= 0 then
	return
end

local lostsanctum = Dungeon()

-- Basic info
lostsanctum:setTitle("Lost Sanctum")
lostsanctum:setDuration(30 * 60 * 1000)
lostsanctum:setMapFile("lostsanctum")

lostsanctum:setStartPosition(Position(1200, 1132, 6))
-- Boss
lostsanctum:setBoss("Sand Colossus", Position(1205, 986, 7))  
lostsanctum:setKillPercent(70)

-- Requirements
lostsanctum:setRequiredParty(1, 4)

-- Challenges
-- lostsanctum:addChallenge(ChallengesIndex.SPECTRE_DONE)


-- Instances
lostsanctum:addInstance(Position(17500, 0, 0))	--  Position: 408, 1980, 5
lostsanctum:addInstance(Position(17500, 1000, 0))
lostsanctum:addInstance(Position(17500, 2000, 0))
lostsanctum:addInstance(Position(17500, 3000, 0))
lostsanctum:addInstance(Position(17500, 4000, 0))
lostsanctum:addInstance(Position(17500, 5000, 0))
lostsanctum:addInstance(Position(17500, 6000, 0))
lostsanctum:addInstance(Position(17500, 7000, 0))
lostsanctum:addInstance(Position(17500, 8000, 0))
lostsanctum:addInstance(Position(17500, 9000, 0))
lostsanctum:addInstance(Position(17500, 10000, 0))
lostsanctum:addInstance(Position(17500, 11000, 0))
lostsanctum:addInstance(Position(17500, 12000, 0))
lostsanctum:addInstance(Position(17500, 13000, 0))
lostsanctum:addInstance(Position(17500, 14000, 0))
lostsanctum:addInstance(Position(17500, 15000, 0))
lostsanctum:addInstance(Position(17500, 16000, 0))
lostsanctum:addInstance(Position(17500, 17000, 0))
lostsanctum:addInstance(Position(17500, 18000, 0))
lostsanctum:addInstance(Position(17500, 19000, 0))
lostsanctum:addInstance(Position(17500, 20000, 0))

lostsanctum:register()
