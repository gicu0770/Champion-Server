if configManager.getNumber(configKeys.INSTANCE_TYPE) ~= 0 then
	return
end

local bonebound_arena = Dungeon()

-- Basic info
bonebound_arena:setTitle("Bonebound Arena")
bonebound_arena:setDuration(30 * 60 * 1000)
bonebound_arena:setMapFile("boneboundarena")

bonebound_arena:setStartPosition(Position(1050, 1056, 6))
-- Boss
bonebound_arena:setBoss("Bonebound Stalker", Position(1050, 1040, 6))
bonebound_arena:setKillPercent(0)

-- Requirements
bonebound_arena:setSolo(true)

-- Challenges
-- bonebound_arena:addChallenge(ChallengesIndex.SPECTRE_DONE)


-- Instances
bonebound_arena:addInstance(Position(13000, 0, 0))	--  Position: 408, 1980, 5
bonebound_arena:addInstance(Position(13000, 1000, 0))
bonebound_arena:addInstance(Position(13000, 2000, 0))
bonebound_arena:addInstance(Position(13000, 3000, 0))
bonebound_arena:addInstance(Position(13000, 4000, 0))
bonebound_arena:addInstance(Position(13000, 5000, 0))
bonebound_arena:addInstance(Position(13000, 6000, 0))
bonebound_arena:addInstance(Position(13000, 7000, 0))
bonebound_arena:addInstance(Position(13000, 8000, 0))
bonebound_arena:addInstance(Position(13000, 9000, 0))
bonebound_arena:addInstance(Position(13000, 10000, 0))
bonebound_arena:addInstance(Position(13000, 11000, 0))
bonebound_arena:addInstance(Position(13000, 12000, 0))
bonebound_arena:addInstance(Position(13000, 13000, 0))
bonebound_arena:addInstance(Position(13000, 14000, 0))

bonebound_arena:register()
