if configManager.getNumber(configKeys.INSTANCE_TYPE) ~= 0 then
	return
end

local venomcaves = Dungeon()

-- Basic info
venomcaves:setTitle("Venom Caves")
venomcaves:setDuration(30 * 60 * 1000)
venomcaves:setMapFile("venomcaves")

venomcaves:setStartPosition(Position(1100, 1130, 7))
-- Boss
venomcaves:setBoss("Toxic Witch", Position(1179, 1090, 8))
venomcaves:setKillPercent(70)

-- Requirements
venomcaves:setRequiredParty(1, 4)

-- Challenges
-- venomcaves:addChallenge(ChallengesIndex.SPECTRE_DONE)


-- Instances
venomcaves:addInstance(Position(19500, 0, 0))	--  Position: 408, 1980, 5
venomcaves:addInstance(Position(19500, 1000, 0))
venomcaves:addInstance(Position(19500, 2000, 0))
venomcaves:addInstance(Position(19500, 3000, 0))
venomcaves:addInstance(Position(19500, 4000, 0))
venomcaves:addInstance(Position(19500, 5000, 0))
venomcaves:addInstance(Position(19500, 6000, 0))
venomcaves:addInstance(Position(19500, 7000, 0))
venomcaves:addInstance(Position(19500, 8000, 0))
venomcaves:addInstance(Position(19500, 9000, 0))
venomcaves:addInstance(Position(19500, 10000, 0))
venomcaves:addInstance(Position(19500, 11000, 0))
venomcaves:addInstance(Position(19500, 12000, 0))
venomcaves:addInstance(Position(19500, 13000, 0))
venomcaves:addInstance(Position(19500, 14000, 0))
venomcaves:addInstance(Position(19500, 15000, 0))
venomcaves:addInstance(Position(19500, 16000, 0))
venomcaves:addInstance(Position(19500, 17000, 0))
venomcaves:addInstance(Position(19500, 18000, 0))
venomcaves:addInstance(Position(19500, 19000, 0))
venomcaves:addInstance(Position(19500, 20000, 0))

venomcaves:register()
