if configManager.getNumber(configKeys.INSTANCE_TYPE) ~= 0 then
	return
end

local underwater = Dungeon()

-- Basic info
underwater:setTitle("Underwater")
underwater:setDuration(30 * 60 * 1000)
underwater:setMapFile("underwater")

underwater:setStartPosition(Position(1097, 1045, 6))
-- Boss
underwater:setBoss("Tidal Overlord", Position(1090, 1086, 7))
underwater:setKillPercent(70)

-- Requirements
underwater:setRequiredParty(1, 4)

-- Challenges
-- underwater:addChallenge(ChallengesIndex.SPECTRE_DONE)


-- Instances
underwater:addInstance(Position(18000, 0, 0))	--  Position: 408, 1980, 5
underwater:addInstance(Position(18000, 1000, 0))
underwater:addInstance(Position(18000, 2000, 0))
underwater:addInstance(Position(18000, 3000, 0))
underwater:addInstance(Position(18000, 4000, 0))
underwater:addInstance(Position(18000, 5000, 0))
underwater:addInstance(Position(18000, 6000, 0))
underwater:addInstance(Position(18000, 7000, 0))
underwater:addInstance(Position(18000, 8000, 0))
underwater:addInstance(Position(18000, 9000, 0))
underwater:addInstance(Position(18000, 10000, 0))
underwater:addInstance(Position(18000, 11000, 0))
underwater:addInstance(Position(18000, 12000, 0))
underwater:addInstance(Position(18000, 13000, 0))
underwater:addInstance(Position(18000, 14000, 0))
underwater:addInstance(Position(18000, 15000, 0))
underwater:addInstance(Position(18000, 16000, 0))
underwater:addInstance(Position(18000, 17000, 0))
underwater:addInstance(Position(18000, 18000, 0))
underwater:addInstance(Position(18000, 19000, 0))
underwater:addInstance(Position(18000, 20000, 0))

underwater:register()
