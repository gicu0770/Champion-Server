if configManager.getNumber(configKeys.INSTANCE_TYPE) ~= 0 then
	return
end

local infernodepths = Dungeon()

-- Basic info
infernodepths:setTitle("Inferno Depths")
infernodepths:setDuration(30 * 60 * 1000)
infernodepths:setMapFile("infernodepths")

infernodepths:setStartPosition(Position(1041, 1074, 4))
-- Boss
infernodepths:setBoss("Molten Abyss", Position(1267, 1060, 5))
infernodepths:setKillPercent(70)

-- Requirements
infernodepths:setRequiredParty(1, 4)

-- Challenges
-- infernodepths:addChallenge(ChallengesIndex.SPECTRE_DONE)


-- Instances
infernodepths:addInstance(Position(16500, 0, 0))	--  Position: 408, 1980, 5
infernodepths:addInstance(Position(16500, 1000, 0))
infernodepths:addInstance(Position(16500, 2000, 0))
infernodepths:addInstance(Position(16500, 3000, 0))
infernodepths:addInstance(Position(16500, 4000, 0))
infernodepths:addInstance(Position(16500, 5000, 0))
infernodepths:addInstance(Position(16500, 6000, 0))
infernodepths:addInstance(Position(16500, 7000, 0))
infernodepths:addInstance(Position(16500, 8000, 0))
infernodepths:addInstance(Position(16500, 9000, 0))
infernodepths:addInstance(Position(16500, 10000, 0))
infernodepths:addInstance(Position(16500, 11000, 0))
infernodepths:addInstance(Position(16500, 12000, 0))
infernodepths:addInstance(Position(16500, 13000, 0))
infernodepths:addInstance(Position(16500, 14000, 0))
infernodepths:addInstance(Position(16500, 15000, 0))
infernodepths:addInstance(Position(16500, 16000, 0))
infernodepths:addInstance(Position(16500, 17000, 0))
infernodepths:addInstance(Position(16500, 18000, 0))
infernodepths:addInstance(Position(16500, 19000, 0))
infernodepths:addInstance(Position(16500, 20000, 0))

infernodepths:register()
