if configManager.getNumber(configKeys.INSTANCE_TYPE) ~= 0 then
	return
end

local etherealSeraph = Dungeon()

-- Basic info
etherealSeraph:setTitle("Celestial Ascent")
etherealSeraph:setDuration(30 * 60 * 1000)
etherealSeraph:setMapFile("holy")

etherealSeraph:setStartPosition(Position(1044, 1093, 5))
-- Boss
etherealSeraph:setBoss("Ethereal Seraph", Position(1021, 986, 6))
etherealSeraph:setKillPercent(70)

-- Requirements
etherealSeraph:setRequiredParty(1, 4)

-- Challenges
-- etherealSeraph:addChallenge(ChallengesIndex.SPECTRE_DONE)


-- Instances
etherealSeraph:addInstance(Position(25000, 0, 0))	--  Position: 408, 1980, 5
etherealSeraph:addInstance(Position(25000, 1000, 0))
etherealSeraph:addInstance(Position(25000, 2000, 0))
etherealSeraph:addInstance(Position(25000, 3000, 0))
etherealSeraph:addInstance(Position(25000, 4000, 0))
etherealSeraph:addInstance(Position(25000, 5000, 0))
etherealSeraph:addInstance(Position(25000, 6000, 0))
etherealSeraph:addInstance(Position(25000, 7000, 0))
etherealSeraph:addInstance(Position(25000, 8000, 0))
etherealSeraph:addInstance(Position(25000, 9000, 0))
etherealSeraph:addInstance(Position(25000, 10000, 0))
etherealSeraph:addInstance(Position(25000, 11000, 0))
etherealSeraph:addInstance(Position(25000, 12000, 0))
etherealSeraph:addInstance(Position(25000, 13000, 0))
etherealSeraph:addInstance(Position(25000, 14000, 0))
etherealSeraph:addInstance(Position(25000, 15000, 0))
etherealSeraph:addInstance(Position(25000, 16000, 0))
etherealSeraph:addInstance(Position(25000, 17000, 0))
etherealSeraph:addInstance(Position(25000, 18000, 0))
etherealSeraph:addInstance(Position(25000, 19000, 0))
etherealSeraph:addInstance(Position(25000, 20000, 0))

etherealSeraph:register()
