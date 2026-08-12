function onSay(player, words, param)
	if not player:getGroup():getAccess() then
		return true
	end

	if player:getAccountType() < ACCOUNT_TYPE_GOD then
		return false
	end
	local split = param:splitTrimmed(",")
	if not split[2] then
		player:sendCancelMessage("Insufficient parameters.")
		return false
	end
	local target = Player(split[1])
	if not target then
		player:sendCancelMessage("A player with that name is not online.")
		return false
	end
	local czas = target:getStorageValue(PlayerStorage.expBoostShop) - os.time()
	local czas2 = target:getStorageValue(PlayerStorage.goldBoostShop) - os.time()
	local czas3 = target:getStorageValue(PlayerStorage.lootBoostShop) - os.time()
	local czas4 = target:getStorageValue(PlayerStorage.skillBoostShop) - os.time()
	local g2 = target:getStorageValue(PlayerStorage.expBoostShop)
	local g3 = target:getStorageValue(PlayerStorage.goldBoostShop)
	local g4 = target:getStorageValue(PlayerStorage.lootBoostShop)
	local g5 = target:getStorageValue(PlayerStorage.skillBoostShop)
	local cur = math.max(g2 - os.time(), 0)
	local cur2 = math.max(g3 - os.time(), 0) 
	local cur3 = math.max(g4 - os.time(), 0)
	local cur4 = math.max(g5 - os.time(), 0)
	local godziny = tonumber(split[2]) * 3600
	local tim = os.time() + godziny
	if cur > 0 then	
	target:setStorageValue(PlayerStorage.expBoostShop, tim + czas)
	elseif cur == 0 then
	target:setStorageValue(PlayerStorage.expBoostShop, tim)
	end
	
	if cur2 > 0 then	
	target:setStorageValue(PlayerStorage.goldBoostShop, tim + czas)
	elseif cur2 == 0 then
	target:setStorageValue(PlayerStorage.goldBoostShop, tim)
	end
	
	if cur3 > 0 then	
	target:setStorageValue(PlayerStorage.lootBoostShop, tim + czas)
	elseif cur3 == 0 then
	target:setStorageValue(PlayerStorage.lootBoostShop, tim)
	end
	
	if cur4 > 0 then	
	target:setStorageValue(PlayerStorage.skillBoostShop, tim + czas)
	elseif cur4 == 0 then
	target:setStorageValue(PlayerStorage.skillBoostShop, tim)
	end
	
	
	local buffMessage = string.format("Player %s activated {All GLOBAL BOOST} by {"..split[2].."h}!", target:getName(), buffName)
	target:sendExtendedOpcode(71, json.encode({text = buffMessage, color = "#f7ef8a"}))	
	target:addBuff(BUFF_EXP_BOOST)
	target:addBuff(STORE_GOLD_BOOST)
	target:addBuff(STORE_LOOT_BOOST)
	target:addBuff(STORE_SKILL_BOOST)
	player:sendTextMessage(MESSAGE_INFO_DESCR, "You global boost.")
	return false
end
