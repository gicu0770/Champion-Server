if configManager.getNumber(configKeys.INSTANCE_TYPE) ~= 0 then
	return
end

local infernalbridgeworks = Dungeon()

-- Basic info
infernalbridgeworks:setTitle("Infernal Bridge")
infernalbridgeworks:setDuration(30 * 60 * 1000)
infernalbridgeworks:setMapFile("infernalbridgeworks")

infernalbridgeworks:setStartPosition(Position(343, 286, 3))
-- Boss
infernalbridgeworks:setBoss("Fleshrend", Position(453, 285, 5))
infernalbridgeworks:setKillPercent(70)

-- Requirements
infernalbridgeworks:setSolo(true)

-- Challenges
-- infernalbridgeworks:addChallenge(ChallengesIndex.SPECTRE_DONE)


-- Instances
infernalbridgeworks:addInstance(Position(17000, 0, 0))	--  Position: 408, 1980, 5
infernalbridgeworks:addInstance(Position(17000, 1000, 0))
infernalbridgeworks:addInstance(Position(17000, 2000, 0))
infernalbridgeworks:addInstance(Position(17000, 3000, 0))
infernalbridgeworks:addInstance(Position(17000, 4000, 0))
infernalbridgeworks:addInstance(Position(17000, 5000, 0))
infernalbridgeworks:addInstance(Position(17000, 6000, 0))
infernalbridgeworks:addInstance(Position(17000, 7000, 0))
infernalbridgeworks:addInstance(Position(17000, 8000, 0))
infernalbridgeworks:addInstance(Position(17000, 9000, 0))
infernalbridgeworks:addInstance(Position(17000, 10000, 0))
infernalbridgeworks:addInstance(Position(17000, 11000, 0))
infernalbridgeworks:addInstance(Position(17000, 12000, 0))
infernalbridgeworks:addInstance(Position(17000, 13000, 0))
infernalbridgeworks:addInstance(Position(17000, 14000, 0))
infernalbridgeworks:addInstance(Position(17000, 15000, 0))
infernalbridgeworks:addInstance(Position(17000, 16000, 0))
infernalbridgeworks:addInstance(Position(17000, 17000, 0))
infernalbridgeworks:addInstance(Position(17000, 18000, 0))
infernalbridgeworks:addInstance(Position(17000, 19000, 0))
infernalbridgeworks:addInstance(Position(17000, 20000, 0))


infernalbridgeworks:register()
