if configManager.getNumber(configKeys.INSTANCE_TYPE) ~= 0 then
	return
end

local otherworld = Dungeon()

-- Basic info
otherworld:setTitle("Otherworld")
otherworld:setDuration(30 * 60 * 1000)
otherworld:setMapFile("otherworld")

otherworld:setStartPosition(Position(1000, 1000, 7))
-- Boss
otherworld:setBoss("Voidlord", Position(1000, 993, 7))
otherworld:setKillPercent(0)

-- Requirements
otherworld:setSolo(true)

-- Challenges
-- otherworld:addChallenge(ChallengesIndex.SPECTRE_DONE)


-- Instances
otherworld:addInstance(Position(3000, 0, 0))	--  Position: 408, 1980, 5
otherworld:addInstance(Position(3000, 1000, 0))
otherworld:addInstance(Position(3000, 2000, 0))
otherworld:addInstance(Position(3000, 3000, 0))
otherworld:addInstance(Position(3000, 4000, 0))
otherworld:addInstance(Position(3000, 5000, 0))
otherworld:addInstance(Position(3000, 6000, 0))
otherworld:addInstance(Position(3000, 7000, 0))
otherworld:addInstance(Position(3000, 8000, 0))
otherworld:addInstance(Position(3000, 9000, 0))
otherworld:addInstance(Position(3000, 10000, 0))
otherworld:addInstance(Position(3000, 11000, 0))
otherworld:addInstance(Position(3000, 12000, 0))
otherworld:addInstance(Position(3000, 13000, 0))
otherworld:addInstance(Position(3000, 14000, 0))

otherworld:register()
