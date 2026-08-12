if configManager.getNumber(configKeys.INSTANCE_TYPE) ~= 0 then
	return
end

local infernaltar = Dungeon()

-- Basic info
infernaltar:setTitle("Infernal Tar")
infernaltar:setDuration(30 * 60 * 1000)
infernaltar:setMapFile("infernal_tar")

infernaltar:setStartPosition(Position(1043, 1050, 6))
-- Boss
infernaltar:setBoss("Blackfang Archer", Position(1043, 1035, 6))
infernaltar:setKillPercent(0)

-- Requirements
infernaltar:setSolo(true)

-- Challenges
-- infernaltar:addChallenge(ChallengesIndex.SPECTRE_DONE)


-- Instances
infernaltar:addInstance(Position(32000, 0, 0))	--  Position: 408, 1980, 5
infernaltar:addInstance(Position(32000, 1000, 0))
infernaltar:addInstance(Position(32000, 2000, 0))
infernaltar:addInstance(Position(32000, 3000, 0))
infernaltar:addInstance(Position(32000, 4000, 0))
infernaltar:addInstance(Position(32000, 5000, 0))
infernaltar:addInstance(Position(32000, 6000, 0))
infernaltar:addInstance(Position(32000, 7000, 0))
infernaltar:addInstance(Position(32000, 8000, 0))
infernaltar:addInstance(Position(32000, 9000, 0))
infernaltar:addInstance(Position(32000, 10000, 0))
infernaltar:addInstance(Position(32000, 11000, 0))
infernaltar:addInstance(Position(32000, 12000, 0))
infernaltar:addInstance(Position(32000, 13000, 0))
infernaltar:addInstance(Position(32000, 14000, 0))

infernaltar:register()
