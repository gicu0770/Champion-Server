function onSay(player, words, param)
	local monsterType = MonsterType(param)
	if not monsterType then
		player:sendCancelMessage("Can't find monster.")
		return false
	end

	player:registerEvent('loot')
	local title = "Loot Checker"
    local message = "Loots of "..string.gsub(" "..string.lower(param), "%W%l", string.upper):sub(2)..":"
	local lootBlockList = monsterType:getLoot()
	table.sort(lootBlockList, function(a, b) return ItemType(a.itemId):getName() < ItemType(b.itemId):getName() end)

	local window = ModalWindow(1001, title, message, message2)
	local check, sum = {}, 1
	for _, loot in pairs(lootBlockList) do
		local status = ''
		if player:getLootItem(lootBlockList[sum].itemId) then
			status = '*'
		end
		if not table.contains(check, ItemType(lootBlockList[sum].itemId):getName()) then
			table.insert(check, ItemType(lootBlockList[sum].itemId):getName())
			local backvinculo
			if result.getNumber(resultId, 'cont_id') and result.getNumber(resultId, 'cont_id') > 0 then
			backvinculo = '| '..ItemType(result.getNumber(resultId, 'cont_id')):getName()..''
			else
			backvinculo = ''
			end
			
			if lootBlockList[sum].chance * configManager.getNumber(configKeys.RATE_LOOT) >= 100000 then
			window:addChoice(sum, "".. string.gsub(" "..status..""..ItemType(lootBlockList[sum].itemId):getName(), "%W%l", string.upper):sub(2, 21) .." (Max: "..lootBlockList[sum].maxCount..") "..(lootBlockList[sum].chance/1000).."% "..string.gsub(" "..string.lower(backvinculo), "%W%l", string.upper):sub(2).."")
			else
			window:addChoice(sum, "".. string.gsub(" "..status..""..ItemType(lootBlockList[sum].itemId):getName(), "%W%l", string.upper):sub(2, 21) .." (Max: "..lootBlockList[sum].maxCount..") "..(lootBlockList[sum].chance*configManager.getNumber(configKeys.RATE_LOOT)/1000).."% "..string.gsub(" "..string.lower(backvinculo), "%W%l", string.upper):sub(2).."")
			end
			
		end
		sum = sum + 1
	end
	window:addButton(100, "Exit")

	window:sendToPlayer(player)
	return false
end