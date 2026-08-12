if configManager.getNumber(configKeys.INSTANCE_TYPE) ~= 0 then
	return
end

local amethystpeaks = Dungeon()

-- Basic info
amethystpeaks:setTitle("Amethyst Peaks")
amethystpeaks:setDuration(30 * 60 * 1000)
amethystpeaks:setMapFile("amethyst_peaks")

amethystpeaks:setStartPosition(Position(1033, 1054, 6))
-- Boss
amethystpeaks:setBoss("Thunderlord", Position(1032, 1035, 6))
amethystpeaks:setKillPercent(0)

-- Requirements
amethystpeaks:setSolo(true)

-- Challenges
-- amethystpeaks:addChallenge(ChallengesIndex.SPECTRE_DONE)


-- Instances
amethystpeaks:addInstance(Position(31000, 0, 0))	--  Position: 408, 1980, 5
amethystpeaks:addInstance(Position(31000, 1000, 0))
amethystpeaks:addInstance(Position(31000, 2000, 0))
amethystpeaks:addInstance(Position(31000, 3000, 0))
amethystpeaks:addInstance(Position(31000, 4000, 0))
amethystpeaks:addInstance(Position(31000, 5000, 0))
amethystpeaks:addInstance(Position(31000, 6000, 0))
amethystpeaks:addInstance(Position(31000, 7000, 0))
amethystpeaks:addInstance(Position(31000, 8000, 0))
amethystpeaks:addInstance(Position(31000, 9000, 0))
amethystpeaks:addInstance(Position(31000, 10000, 0))
amethystpeaks:addInstance(Position(31000, 11000, 0))
amethystpeaks:addInstance(Position(31000, 12000, 0))
amethystpeaks:addInstance(Position(31000, 13000, 0))
amethystpeaks:addInstance(Position(31000, 14000, 0))

amethystpeaks:register()
