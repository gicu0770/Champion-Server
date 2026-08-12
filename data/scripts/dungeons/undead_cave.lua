if configManager.getNumber(configKeys.INSTANCE_TYPE) ~= 0 then
	return
end

local undeadKing = Dungeon()

-- Basic info
undeadKing:setTitle("Undead Cave")
undeadKing:setDuration(30 * 60 * 1000)
undeadKing:setMapFile("undead_cave")

undeadKing:setStartPosition(Position(1014, 1063, 6))
-- Boss
undeadKing:setBoss("Undead King", Position(1043, 1123, 7))
undeadKing:setKillPercent(70)

-- Requirements
undeadKing:setRequiredParty(1, 4)

-- Challenges
-- undeadKing:addChallenge(ChallengesIndex.SPECTRE_DONE)


-- Instances
undeadKing:addInstance(Position(20000, 0, 0))	--  Position: 408, 1980, 5
undeadKing:addInstance(Position(20000, 1000, 0))
undeadKing:addInstance(Position(20000, 2000, 0))
undeadKing:addInstance(Position(20000, 3000, 0))
undeadKing:addInstance(Position(20000, 4000, 0))
undeadKing:addInstance(Position(20000, 5000, 0))
undeadKing:addInstance(Position(20000, 6000, 0))
undeadKing:addInstance(Position(20000, 7000, 0))
undeadKing:addInstance(Position(20000, 8000, 0))
undeadKing:addInstance(Position(20000, 9000, 0))
undeadKing:addInstance(Position(20000, 10000, 0))
undeadKing:addInstance(Position(20000, 11000, 0))
undeadKing:addInstance(Position(20000, 12000, 0))
undeadKing:addInstance(Position(20000, 13000, 0))
undeadKing:addInstance(Position(20000, 14000, 0))
undeadKing:addInstance(Position(20000, 15000, 0))
undeadKing:addInstance(Position(20000, 16000, 0))
undeadKing:addInstance(Position(20000, 17000, 0))
undeadKing:addInstance(Position(20000, 18000, 0))
undeadKing:addInstance(Position(20000, 19000, 0))
undeadKing:addInstance(Position(20000, 20000, 0))

undeadKing:register()