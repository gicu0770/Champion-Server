if configManager.getNumber(configKeys.INSTANCE_TYPE) ~= 0 then
	return
end

local flame_cave = Dungeon()

-- Basic info
flame_cave:setTitle("Flame Cave")
flame_cave:setDuration(30 * 60 * 1000)
flame_cave:setMapFile("flame_cave")

flame_cave:setStartPosition(Position(981, 1080, 7))

-- Boss
flame_cave:setBoss("Pheonix", Position(1092, 1073, 8))
flame_cave:setKillPercent(70)

flame_cave:addChallenge(ChallengesIndex.FLAME_CAVE)

-- Requirements
flame_cave:setRequiredParty(1, 4)

--- Instances
flame_cave:addInstance(Position(10000, 0, 0))
flame_cave:addInstance(Position(10000, 1000, 0))
flame_cave:addInstance(Position(10000, 2000, 0))
flame_cave:addInstance(Position(10000, 3000, 0))
flame_cave:addInstance(Position(10000, 4000, 0))
flame_cave:addInstance(Position(10000, 5000, 0))
flame_cave:addInstance(Position(10000, 6000, 0))
flame_cave:addInstance(Position(10000, 7000, 0))
flame_cave:addInstance(Position(10000, 8000, 0))
flame_cave:addInstance(Position(10000, 9000, 0))
flame_cave:addInstance(Position(10000, 10000, 0))
flame_cave:addInstance(Position(10000, 11000, 0))
flame_cave:addInstance(Position(10000, 12000, 0))
flame_cave:addInstance(Position(10000, 13000, 0))
flame_cave:addInstance(Position(10000, 14000, 0))
flame_cave:addInstance(Position(10000, 15000, 0))
flame_cave:addInstance(Position(10000, 16000, 0))
flame_cave:addInstance(Position(10000, 17000, 0))
flame_cave:addInstance(Position(10000, 18000, 0))
flame_cave:addInstance(Position(10000, 19000, 0))
flame_cave:addInstance(Position(10000, 20000, 0))

flame_cave:register()
