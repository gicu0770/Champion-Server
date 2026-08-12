if configManager.getNumber(configKeys.INSTANCE_TYPE) ~= 0 then
	return
end

local prismatic_voidflare = Dungeon()

-- Basic info
prismatic_voidflare:setTitle("Voidflare Arena")
prismatic_voidflare:setDuration(30 * 60 * 1000)
prismatic_voidflare:setMapFile("voidflarearena")

prismatic_voidflare:setStartPosition(Position(1056, 1067, 5))
-- Boss
prismatic_voidflare:setBoss("Voidflare Wisp", Position(1056, 1051, 5))
prismatic_voidflare:setKillPercent(0)

-- Requirements
prismatic_voidflare:setSolo(true)

-- Challenges
-- prismatic_voidflare:addChallenge(ChallengesIndex.SPECTRE_DONE)


-- Instances
prismatic_voidflare:addInstance(Position(14000, 0, 0))	--  Position: 408, 1980, 5
prismatic_voidflare:addInstance(Position(14000, 1000, 0))
prismatic_voidflare:addInstance(Position(14000, 2000, 0))
prismatic_voidflare:addInstance(Position(14000, 3000, 0))
prismatic_voidflare:addInstance(Position(14000, 4000, 0))
prismatic_voidflare:addInstance(Position(14000, 5000, 0))
prismatic_voidflare:addInstance(Position(14000, 6000, 0))
prismatic_voidflare:addInstance(Position(14000, 7000, 0))
prismatic_voidflare:addInstance(Position(14000, 8000, 0))
prismatic_voidflare:addInstance(Position(14000, 9000, 0))
prismatic_voidflare:addInstance(Position(14000, 10000, 0))
prismatic_voidflare:addInstance(Position(14000, 11000, 0))
prismatic_voidflare:addInstance(Position(14000, 12000, 0))
prismatic_voidflare:addInstance(Position(14000, 13000, 0))
prismatic_voidflare:addInstance(Position(14000, 14000, 0))

prismatic_voidflare:register()
