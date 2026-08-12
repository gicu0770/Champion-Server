if configManager.getNumber(configKeys.INSTANCE_TYPE) ~= 0 then
	return
end

local goldenvault = Dungeon()

-- Basic info
goldenvault:setTitle("Golden Vault")
goldenvault:setDuration(30 * 60 * 1000)
goldenvault:setMapFile("goldenvault")

goldenvault:setStartPosition(Position(1008, 1037, 7))
-- Boss
goldenvault:setBoss("Golden Hoarder", Position(1205, 1177, 7))
goldenvault:setKillPercent(70)

-- Requirements
goldenvault:setRequiredParty(1, 4)

-- Challenges
-- goldenvault:addChallenge(ChallengesIndex.SPECTRE_DONE)


-- Instances
goldenvault:addInstance(Position(24500, 0, 0))	--  Position: 408, 1980, 5
goldenvault:addInstance(Position(24500, 1000, 0))
goldenvault:addInstance(Position(24500, 2000, 0))
goldenvault:addInstance(Position(24500, 3000, 0))
goldenvault:addInstance(Position(24500, 4000, 0))
goldenvault:addInstance(Position(24500, 5000, 0))
goldenvault:addInstance(Position(24500, 6000, 0))
goldenvault:addInstance(Position(24500, 7000, 0))
goldenvault:addInstance(Position(24500, 8000, 0))
goldenvault:addInstance(Position(24500, 9000, 0))
goldenvault:addInstance(Position(24500, 10000, 0))
goldenvault:addInstance(Position(24500, 11000, 0))
goldenvault:addInstance(Position(24500, 12000, 0))
goldenvault:addInstance(Position(24500, 13000, 0))
goldenvault:addInstance(Position(24500, 14000, 0))

goldenvault:register()