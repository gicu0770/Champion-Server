local questStarted = 1510
local questStorage = 65000
local rankStorage = 32150

function onDeath(creature, corpse, killer, mostDamage, unjustified, mostDamage_unjustified)
	if not creature or creature:isPlayer() or creature:getMaster() then
		return true
	end
	if killer and creature:isMonster() then
	local creatureName = creature:getName()
	local party = killer:getParty()
	if party then
    	local members = party:getMembers()
		for i = 1, #members do
			local member = members[i]
			if member:getPosition():getDistance(creature:getPosition()) <= 150 then
				if member:isQuestActive(1) then
					member:updateQuest(1, 1)
		--			member:sendTextMessage(MESSAGE_STATUS_CONSOLE_ORANGE,"[Daily Quest]: Monster Hunter kill ["..member:getStorageValue(DAILY_QUEST[1].STORAGE).."/"..DAILY_QUEST[1].POINTS.."]")
				end
				if member:isQuestActive(2) and creature:getSkull() > 6 then
					member:updateQuest(2, 1)
		--			member:sendTextMessage(MESSAGE_STATUS_CONSOLE_ORANGE,"[Daily Quest]: Monster ELITE Hunter kill ["..member:getStorageValue(DAILY_QUEST[2].STORAGE).."/"..DAILY_QUEST[2].POINTS.."]")
				end
			end
		end
		local leader = party:getLeader()
		if leader:getPosition():getDistance(creature:getPosition()) <= 150 then
			if leader:isQuestActive(1) then
				leader:updateQuest(1, 1)
		--		leader:sendTextMessage(MESSAGE_STATUS_CONSOLE_ORANGE,"[Daily Quest]: Monster Hunter kill ["..leader:getStorageValue(DAILY_QUEST[1].STORAGE).."/"..DAILY_QUEST[1].POINTS.."]")
			end
			if leader:isQuestActive(2) and creature:getSkull() > 6 then
				leader:updateQuest(2, 1)
		--		leader:sendTextMessage(MESSAGE_STATUS_CONSOLE_ORANGE,"[Daily Quest]: Monster ELITE Hunter kill ["..leader:getStorageValue(DAILY_QUEST[2].STORAGE).."/"..DAILY_QUEST[2].POINTS.."]")
			end
		end
	else
		
		if killer:isQuestActive(1) then
			killer:updateQuest(1, 1)
	--		killer:sendTextMessage(MESSAGE_STATUS_CONSOLE_ORANGE,"[Daily Quest]: Monster Hunter kill ["..killer:getStorageValue(DAILY_QUEST[1].STORAGE).."/"..DAILY_QUEST[1].POINTS.."]")
		end
		if killer:isQuestActive(2) and creature:getSkull() > 6 then
			killer:updateQuest(2, 1)
	--		killer:sendTextMessage(MESSAGE_STATUS_CONSOLE_ORANGE,"[Daily Quest]: Monster ELITE Hunter kill ["..killer:getStorageValue(DAILY_QUEST[2].STORAGE).."/"..DAILY_QUEST[2].POINTS.."]")
		end

	end
end
	return true
end