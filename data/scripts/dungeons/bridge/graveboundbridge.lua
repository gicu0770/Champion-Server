if configManager.getNumber(configKeys.INSTANCE_TYPE) ~= 0 then
	return
end

local graveboundbridge = Dungeon()

-- Basic info
graveboundbridge:setTitle("Gravebound Bridge")
graveboundbridge:setDuration(30 * 60 * 1000)
graveboundbridge:setMapFile("graveboundbridge")

graveboundbridge:setStartPosition(Position(1019, 1036, 6))
-- Boss
graveboundbridge:setBoss("Grave Spearlord", Position(1237, 1029, 6))
graveboundbridge:setCompleteType(DUNGEONTYPE_OBJECTIVES)

-- Requirements
graveboundbridge:setRequiredParty(1, 4)

-- Challenges
-- graveboundbridge:addChallenge(ChallengesIndex.SPECTRE_DONE)
graveboundbridge:addObjective("Kill Undead King")
graveboundbridge:addObjective("Kill Ethereal Seraph")
graveboundbridge:addObjective("Kill Glacier Warlord")

-- Instances
graveboundbridge:addInstance(Position(20500, 0, 0))	--  Position: 408, 1980, 5
graveboundbridge:addInstance(Position(20500, 1000, 0))
graveboundbridge:addInstance(Position(20500, 2000, 0))
graveboundbridge:addInstance(Position(20500, 3000, 0))
graveboundbridge:addInstance(Position(20500, 4000, 0))
graveboundbridge:addInstance(Position(20500, 5000, 0))
graveboundbridge:addInstance(Position(20500, 6000, 0))
graveboundbridge:addInstance(Position(20500, 7000, 0))
graveboundbridge:addInstance(Position(20500, 8000, 0))
graveboundbridge:addInstance(Position(20500, 9000, 0))
graveboundbridge:addInstance(Position(20500, 10000, 0))
graveboundbridge:addInstance(Position(20500, 11000, 0))
graveboundbridge:addInstance(Position(20500, 12000, 0))
graveboundbridge:addInstance(Position(20500, 13000, 0))
graveboundbridge:addInstance(Position(20500, 14000, 0))

graveboundbridge:register()