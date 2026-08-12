function onLogin(player)
	local lastLogout = player:getLastLogout()
	local offlineTime = lastLogout ~= 0 and math.min(os.time() - lastLogout, 86400 * 21) or 0
	local offlineTrainingSkill = player:getOfflineTrainingSkill()
	if offlineTrainingSkill == -1 then
		player:addOfflineTrainingTime(offlineTime * 1000)
		return true
	end

	player:setOfflineTrainingSkill(-1)

	if offlineTime < 600 then
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You must be logged out for more than 10 minutes to start offline training.")
		return true
	end
	local trainingTime = math.max(0, math.min(offlineTime, math.min(43200, player:getOfflineTrainingTime() / 1000)))
--	trainingTime = (trainingTime * 60) * 60
	player:removeOfflineTrainingTime(trainingTime * 1000)

	local remainder = offlineTime - trainingTime
	if remainder > 0 then
		player:addOfflineTrainingTime(remainder * 1000)
	end

	if trainingTime < 60 then
		return true
	end

	local text = "During your absence you trained for"
	local hours = math.floor(trainingTime / 3600)
	if hours > 1 then
		text = string.format("%s %d hours", text, hours)
	elseif hours == 1 then
		text = string.format("%s 1 hour", text)
	end

	local minutes = math.floor((trainingTime % 3600) / 60)
	if minutes ~= 0 then
		if hours ~= 0 then
			text = string.format("%s and", text)
		end

		if minutes > 1 then
			text = string.format("%s %d minutes", text, minutes)
		else
			text = string.format("%s 1 minute", text)
		end
	end

	text = string.format("%s.", text)
	player:sendTextMessage(MESSAGE_EVENT_ADVANCE, text)

	local vocation = player:getVocation()
	local promotion = vocation:getPromotion()
	local topVocation = not promotion and vocation or promotion
 
	local updateSkills = false
	if table.contains({SKILL_MELEE, SKILL_DISTANCE, SKILL_FISHING}, offlineTrainingSkill) then
		local modifier = topVocation:getAttackSpeed() / 1000
		updateSkills = player:addOfflineTrainingTries(offlineTrainingSkill, (trainingTime / modifier) / (offlineTrainingSkill == SKILL_DISTANCE and 4 or 2))
		player:addOfflineTrainingTries(SKILL_SHIELD, trainingTime / 4)
	elseif offlineTrainingSkill == SKILL_MAGLEVEL then
		local gainTicks = topVocation:getManaGainTicks() * 2
		if gainTicks == 0 then
			gainTicks = 1
		end
		updateSkills = player:addOfflineTrainingTries(SKILL_MAGLEVEL, trainingTime * (vocation:getManaGainAmount() / gainTicks))
		player:addOfflineTrainingTries(SKILL_SHIELD, trainingTime / 4)
--[[
	elseif offlineTrainingSkill == SKILL_SHIELD then
		local golLevel = player:getLevel() / 10
		local gold = math.ceil(trainingTime + ((trainingTime * golLevel) / 100))
		local fossile = math.ceil(gold / 1000)
		local bag = Game.createItem(28901, 1)
		local inbox = player:getInbox()
		player:setBankBalance(player:getBankBalance() + gold) 
		bag:addItem(24850,fossile)
		inbox:addItemEx(bag, INDEX_WHEREEVER, FLAG_NOLIMIT)
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "While you are away, your character has gained:\nGold "..gold.." Level Bonus: "..golLevel.."%\nCrystal Fossil +"..fossile.." Level Bonus: "..golLevel.."%\nCheck your depot inbox!")		
	elseif offlineTrainingSkill == 20 then 
		local golLevel = player:getLevel() / 10
		local gold = math.ceil(trainingTime + ((trainingTime * golLevel) / 100))
		local fossile = math.ceil(gold / 4000)
		player:setBankBalance(player:getBankBalance() + gold)
		local level = player:getLevel()
		local bag = Game.createItem(28901, 1)
		local inbox = player:getInbox()
		if level >= 1 and level <= 149 then
		bag:addItem(5902,fossile)
		elseif level >= 150 and level <= 200 then
		bag:addItem(26157,fossile)
		bag:addItem(36631,fossile)
		elseif level >= 201 and level <= 300 then
		bag:addItem(25378,fossile)
		bag:addItem(26812,fossile)
		bag:addItem(31367,fossile)
		
		bag:addItem(36629,fossile)
		bag:addItem(26809,fossile)
		bag:addItem(31291,fossile)
		elseif level >= 301 and level <= 500 then
		bag:addItem(25376,fossile)
		bag:addItem(26810,fossile)
		bag:addItem(31290,fossile)
		
		bag:addItem(36630,fossile)
		bag:addItem(26811,fossile)
		bag:addItem(31289,fossile)
		elseif level >= 501 and level <= 700 then
		bag:addItem(33293,fossile)
		bag:addItem(36142,fossile)
		bag:addItem(36141,fossile)
		
		bag:addItem(35962,fossile)
		bag:addItem(34387,fossile)
		bag:addItem(33446,fossile)
		elseif level >= 701 and level <= 900 then
		bag:addItem(27681,fossile)
		bag:addItem(31281,fossile)
		bag:addItem(32357,fossile)
		
		bag:addItem(35493,fossile)
		bag:addItem(29170,fossile)
		bag:addItem(34371,fossile)
		elseif level >= 901 and level <= 1100 then
		bag:addItem(35966,fossile)
		bag:addItem(33403,fossile)
		bag:addItem(34346,fossile)
		
		bag:addItem(35501,fossile)
		bag:addItem(33303,fossile)
		bag:addItem(35502,fossile)
		elseif level >= 1101 and level <= 1300 then
		bag:addItem(34299,fossile)
		bag:addItem(32599,fossile)
		bag:addItem(32604,fossile)
		
		bag:addItem(34386,fossile)
		bag:addItem(32356,fossile)
		bag:addItem(29688,fossile)
		elseif level >= 1301 then
		bag:addItem(18424,fossile)
		bag:addItem(18425,fossile)
		bag:addItem(26789,fossile)
		
		bag:addItem(34311,fossile)
		bag:addItem(12638,fossile)
		bag:addItem(10571,fossile)
		end
		inbox:addItemEx(bag, INDEX_WHEREEVER, FLAG_NOLIMIT)
		player:addItem(24850,fossile)
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "While you are away, your character has gained:\nGold "..gold.." Level Bonus: "..golLevel.."%\nUpgrade Materials +"..fossile.." Level Bonus: "..golLevel.."%\nCheck your depot inbox!")		
		--]]
	end

	return true
end
