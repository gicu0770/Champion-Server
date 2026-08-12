if configManager.getNumber(configKeys.INSTANCE_TYPE) ~= 0 then
	return
end

local eldritchbridge = Dungeon()

-- Basic info
eldritchbridge:setTitle("Eldritch Bridge")
eldritchbridge:setDuration(30 * 60 * 1000)
eldritchbridge:setMapFile("eldritchbridge")

eldritchbridge:setStartPosition(Position(1028, 1074, 6))
-- Boss
eldritchbridge:setBoss("Eldritch Reaver", Position(1246, 1067, 6))
eldritchbridge:setCompleteType(DUNGEONTYPE_OBJECTIVES)

-- Requirements
eldritchbridge:setRequiredParty(1, 4)

-- Challenges
eldritchbridge:addObjective("Kill Sand Colossus")
eldritchbridge:addObjective("Kill Toxic Witch")
eldritchbridge:addObjective("Kill Molten Abyss")

-- Instances
eldritchbridge:addInstance(Position(23500, 0, 0))	--  Position: 408, 1980, 5
eldritchbridge:addInstance(Position(23500, 1000, 0))
eldritchbridge:addInstance(Position(23500, 2000, 0))
eldritchbridge:addInstance(Position(23500, 3000, 0))
eldritchbridge:addInstance(Position(23500, 4000, 0))
eldritchbridge:addInstance(Position(23500, 5000, 0))
eldritchbridge:addInstance(Position(23500, 6000, 0))
eldritchbridge:addInstance(Position(23500, 7000, 0))
eldritchbridge:addInstance(Position(23500, 8000, 0))
eldritchbridge:addInstance(Position(23500, 9000, 0))
eldritchbridge:addInstance(Position(23500, 10000, 0))
eldritchbridge:addInstance(Position(23500, 11000, 0))
eldritchbridge:addInstance(Position(23500, 12000, 0))
eldritchbridge:addInstance(Position(23500, 13000, 0))
eldritchbridge:addInstance(Position(23500, 14000, 0))

eldritchbridge:register()