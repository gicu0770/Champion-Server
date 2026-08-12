if configManager.getNumber(configKeys.INSTANCE_TYPE) ~= 0 then
	return
end

local glacierpass = Dungeon()

-- Basic info
glacierpass:setTitle("Glacier Pass")
glacierpass:setDuration(30 * 60 * 1000)
glacierpass:setMapFile("ice")

glacierpass:setStartPosition(Position(315, 238, 6))
-- Boss
glacierpass:setBoss("Glacier Warlord", Position(447, 232, 7))
glacierpass:setKillPercent(70)

-- Requirements
glacierpass:setRequiredParty(1, 4)

-- Challenges
-- glacierpass:addChallenge(ChallengesIndex.SPECTRE_DONE)


-- Instances
glacierpass:addInstance(Position(27000, 0, 0))	--  Position: 408, 1980, 5
glacierpass:addInstance(Position(27000, 1000, 0))
glacierpass:addInstance(Position(27000, 2000, 0))
glacierpass:addInstance(Position(27000, 3000, 0))
glacierpass:addInstance(Position(27000, 4000, 0))
glacierpass:addInstance(Position(27000, 5000, 0))
glacierpass:addInstance(Position(27000, 6000, 0))
glacierpass:addInstance(Position(27000, 7000, 0))
glacierpass:addInstance(Position(27000, 8000, 0))
glacierpass:addInstance(Position(27000, 9000, 0))
glacierpass:addInstance(Position(27000, 10000, 0))
glacierpass:addInstance(Position(27000, 11000, 0))
glacierpass:addInstance(Position(27000, 12000, 0))
glacierpass:addInstance(Position(27000, 13000, 0))
glacierpass:addInstance(Position(27000, 14000, 0))
glacierpass:addInstance(Position(27000, 15000, 0))
glacierpass:addInstance(Position(27000, 16000, 0))
glacierpass:addInstance(Position(27000, 17000, 0))
glacierpass:addInstance(Position(27000, 18000, 0))
glacierpass:addInstance(Position(27000, 19000, 0))
glacierpass:addInstance(Position(27000, 20000, 0))

glacierpass:register()
