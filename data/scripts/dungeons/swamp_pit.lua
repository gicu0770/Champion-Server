if configManager.getNumber(configKeys.INSTANCE_TYPE) ~= 0 then
	return
end

local dungeonSwamp = Dungeon()

-- Basic info
dungeonSwamp:setTitle("Swamp Pit")
dungeonSwamp:setDuration(30 * 60 * 1000)
dungeonSwamp:setMapFile("swamp_pit")

dungeonSwamp:setStartPosition(Position(1063, 1019, 7))

-- Boss
dungeonSwamp:setBoss("Toxic Hydra", Position(1063, 1182, 8))
dungeonSwamp:setKillPercent(70)

-- Requirements
dungeonSwamp:setRequiredParty(1, 4)

-- Challenges
dungeonSwamp:addChallenge(ChallengesIndex.SWAMP_PIT_FUSION)

--- Instances
dungeonSwamp:addInstance(Position(15000, 0, 0))
dungeonSwamp:addInstance(Position(15000, 1000, 0))
dungeonSwamp:addInstance(Position(15000, 2000, 0))
dungeonSwamp:addInstance(Position(15000, 3000, 0))
dungeonSwamp:addInstance(Position(15000, 4000, 0))
dungeonSwamp:addInstance(Position(15000, 5000, 0))
dungeonSwamp:addInstance(Position(15000, 6000, 0))
dungeonSwamp:addInstance(Position(15000, 7000, 0))
dungeonSwamp:addInstance(Position(15000, 8000, 0))
dungeonSwamp:addInstance(Position(15000, 9000, 0))
dungeonSwamp:addInstance(Position(15000, 10000, 0))
dungeonSwamp:addInstance(Position(15000, 11000, 0))
dungeonSwamp:addInstance(Position(15000, 12000, 0))
dungeonSwamp:addInstance(Position(15000, 13000, 0))
dungeonSwamp:addInstance(Position(15000, 14000, 0))
dungeonSwamp:addInstance(Position(15000, 15000, 0))
dungeonSwamp:addInstance(Position(15000, 16000, 0))
dungeonSwamp:addInstance(Position(15000, 17000, 0))
dungeonSwamp:addInstance(Position(15000, 18000, 0))
dungeonSwamp:addInstance(Position(15000, 19000, 0))
dungeonSwamp:addInstance(Position(15000, 20000, 0))

dungeonSwamp:register()