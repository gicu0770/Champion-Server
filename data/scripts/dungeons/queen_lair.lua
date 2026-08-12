if configManager.getNumber(configKeys.INSTANCE_TYPE) ~= 0 then
	return
end

local bloodySpectres = Dungeon()

-- Basic info
bloodySpectres:setTitle("Queen Lair")
bloodySpectres:setDuration(30 * 60 * 1000)
bloodySpectres:setMapFile("queen_lair")

bloodySpectres:setStartPosition(Position(281, 169, 7))
-- Boss
bloodySpectres:setBoss("Vampire Queen", Position(247, 267, 6))
bloodySpectres:setKillPercent(70)

-- Requirements
bloodySpectres:setRequiredParty(1, 4)

-- Challenges
bloodySpectres:addChallenge(ChallengesIndex.SPECTRE_DONE)


-- Instances
bloodySpectres:addInstance(Position(5000, 0, 0))	--  Position: 408, 1980, 5
bloodySpectres:addInstance(Position(5000, 1000, 0))
bloodySpectres:addInstance(Position(5000, 2000, 0))
bloodySpectres:addInstance(Position(5000, 3000, 0))
bloodySpectres:addInstance(Position(5000, 4000, 0))
bloodySpectres:addInstance(Position(5000, 5000, 0))
bloodySpectres:addInstance(Position(5000, 6000, 0))
bloodySpectres:addInstance(Position(5000, 7000, 0))
bloodySpectres:addInstance(Position(5000, 8000, 0))
bloodySpectres:addInstance(Position(5000, 9000, 0))
bloodySpectres:addInstance(Position(5000, 10000, 0))
bloodySpectres:addInstance(Position(5000, 11000, 0))
bloodySpectres:addInstance(Position(5000, 12000, 0))
bloodySpectres:addInstance(Position(5000, 13000, 0))
bloodySpectres:addInstance(Position(5000, 14000, 0))
bloodySpectres:addInstance(Position(5000, 15000, 0))
bloodySpectres:addInstance(Position(5000, 16000, 0))
bloodySpectres:addInstance(Position(5000, 17000, 0))
bloodySpectres:addInstance(Position(5000, 18000, 0))
bloodySpectres:addInstance(Position(5000, 19000, 0))
bloodySpectres:addInstance(Position(5000, 20000, 0))

bloodySpectres:register()
