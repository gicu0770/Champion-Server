function onSay(player, words, param)
	if not player:getGroup():getAccess() then
		return true
	end

	if player:getAccountType() < ACCOUNT_TYPE_GOD then
		return false
	end
	local target = Player(param)
	if not target then
		player:sendCancelMessage("A player with that name is not online.")
		return false
	end
	local descopop = "***Stats***"
	local value = 0
	for i = CHARSTAT_FIRST, CHARSTAT_LAST do
	 value = value + target:getCharacterStat(i)
	end
	local stats = target:getStatsPoints()
	local statsTotal = target:getStatsPoints() + value
	local paragonLevel = target:getStorageValue(PlayerStorage.paragonLevel)
	local totaladdedtocharacter = statsTotal - target:getStorageValue(PlayerStorage.paragonLevel) - 115
	descopop = string.format("%s\nStats Actived: %s", descopop, stats)
	descopop = string.format("%s\n No added: %s", descopop, value)
	descopop = string.format("%s\n Total Stats: %s", descopop, statsTotal)
	descopop = string.format("%s\nParagon Level: %s", descopop, paragonLevel)
	descopop = string.format("%s\nAdded Points to chaarcter: %s", descopop, totaladdedtocharacter)
	player:popupFYI(descopop)
	return false
end