if configManager.getNumber(configKeys.INSTANCE_TYPE) ~= 0 then
	return
end

local liberatorbridge = Dungeon()

-- Basic info
liberatorbridge:setTitle("Liberator Bridge")
liberatorbridge:setDuration(30 * 60 * 1000)
liberatorbridge:setMapFile("liberatorbridge")

liberatorbridge:setStartPosition(Position(1091, 1053, 6))
-- Boss
liberatorbridge:setBoss("Minotaur Liberator", Position(1309, 1046, 6))
liberatorbridge:setCompleteType(DUNGEONTYPE_OBJECTIVES)

-- Requirements
liberatorbridge:setRequiredParty(1, 4)

-- Challenges
-- liberatorbridge:addChallenge(ChallengesIndex.SPECTRE_DONE)
liberatorbridge:addBonusObjective("Kill Tidal Overlord")
liberatorbridge:addBonusObjective("Kill Fleshrend")
liberatorbridge:addBonusObjective("Kill Arbaziloth")

-- Instances
liberatorbridge:addInstance(Position(21500, 0, 0))	--  Position: 408, 1980, 5
liberatorbridge:addInstance(Position(21500, 1000, 0))
liberatorbridge:addInstance(Position(21500, 2000, 0))
liberatorbridge:addInstance(Position(21500, 3000, 0))
liberatorbridge:addInstance(Position(21500, 4000, 0))
liberatorbridge:addInstance(Position(21500, 5000, 0))
liberatorbridge:addInstance(Position(21500, 6000, 0))
liberatorbridge:addInstance(Position(21500, 7000, 0))
liberatorbridge:addInstance(Position(21500, 8000, 0))
liberatorbridge:addInstance(Position(21500, 9000, 0))
liberatorbridge:addInstance(Position(21500, 10000, 0))
liberatorbridge:addInstance(Position(21500, 11000, 0))
liberatorbridge:addInstance(Position(21500, 12000, 0))
liberatorbridge:addInstance(Position(21500, 13000, 0))
liberatorbridge:addInstance(Position(21500, 14000, 0))

liberatorbridge:register()