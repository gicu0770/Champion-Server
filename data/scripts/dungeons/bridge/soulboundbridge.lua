if configManager.getNumber(configKeys.INSTANCE_TYPE) ~= 0 then
	return
end

local soulboundbridge = Dungeon()

-- Basic info
soulboundbridge:setTitle("Soulbound Bridge")
soulboundbridge:setDuration(30 * 60 * 1000)
soulboundbridge:setMapFile("soulboundbridge")

soulboundbridge:setStartPosition(Position(1009, 1063, 6))
-- Boss
soulboundbridge:setBoss("Soulbound Lich", Position(1227, 1056, 6))
soulboundbridge:setCompleteType(DUNGEONTYPE_OBJECTIVES)

-- Requirements
soulboundbridge:setRequiredParty(1, 4)

-- Challenges
-- soulboundbridge:addChallenge(ChallengesIndex.SPECTRE_DONE)

soulboundbridge:addBonusObjective("Kill Vampire Queen")
soulboundbridge:addBonusObjective("Kill Pheonix")
soulboundbridge:addBonusObjective("Kill Toxic Hydra")


-- Instances
soulboundbridge:addInstance(Position(22500, 0, 0))	--  Position: 408, 1980, 5
soulboundbridge:addInstance(Position(22500, 1000, 0))
soulboundbridge:addInstance(Position(22500, 2000, 0))
soulboundbridge:addInstance(Position(22500, 3000, 0))
soulboundbridge:addInstance(Position(22500, 4000, 0))
soulboundbridge:addInstance(Position(22500, 5000, 0))
soulboundbridge:addInstance(Position(22500, 6000, 0))
soulboundbridge:addInstance(Position(22500, 7000, 0))
soulboundbridge:addInstance(Position(22500, 8000, 0))
soulboundbridge:addInstance(Position(22500, 9000, 0))
soulboundbridge:addInstance(Position(22500, 10000, 0))
soulboundbridge:addInstance(Position(22500, 11000, 0))
soulboundbridge:addInstance(Position(22500, 12000, 0))
soulboundbridge:addInstance(Position(22500, 13000, 0))
soulboundbridge:addInstance(Position(22500, 14000, 0))

soulboundbridge:register()