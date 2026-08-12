if configManager.getNumber(configKeys.INSTANCE_TYPE) ~= 0 then
	return
end

local venom_grave = Dungeon()

-- Basic info
venom_grave:setTitle("Venom Grave")
venom_grave:setDuration(30 * 60 * 1000)
venom_grave:setMapFile("venomgrizzlearena")

venom_grave:setStartPosition(Position(1046, 1055, 7))
-- Boss
venom_grave:setBoss("Venomgrizzle", Position(1046, 1041, 7))
venom_grave:setKillPercent(0)

-- Requirements
venom_grave:setSolo(true)

-- Challenges
-- venom_grave:addChallenge(ChallengesIndex.SPECTRE_DONE)


-- Instances
venom_grave:addInstance(Position(11000, 0, 0))	--  Position: 408, 1980, 5
venom_grave:addInstance(Position(11000, 1000, 0))
venom_grave:addInstance(Position(11000, 2000, 0))
venom_grave:addInstance(Position(11000, 3000, 0))
venom_grave:addInstance(Position(11000, 4000, 0))
venom_grave:addInstance(Position(11000, 5000, 0))
venom_grave:addInstance(Position(11000, 6000, 0))
venom_grave:addInstance(Position(11000, 7000, 0))
venom_grave:addInstance(Position(11000, 8000, 0))
venom_grave:addInstance(Position(11000, 9000, 0))
venom_grave:addInstance(Position(11000, 10000, 0))
venom_grave:addInstance(Position(11000, 11000, 0))
venom_grave:addInstance(Position(11000, 12000, 0))
venom_grave:addInstance(Position(11000, 13000, 0))
venom_grave:addInstance(Position(11000, 14000, 0))

venom_grave:register()
