function onUse(player, item, fromPosition, itemEx, toPosition)
	local rewards = {
		[10586] = {storage = PlayerStorage.dailyBoosty},
	}

	local config = rewards[item.actionid]
	if not config then
		return false
	end

	local COOLDOWN_SECONDS = 24 * 60 * 60 -- 24 * 60 * 60 -- 24 godziny
	local currentTime = os.time()
	local lastReward = player:getStorageValue(config.storage)
	if lastReward == -1 then lastReward = 0 end

	local timePassed = currentTime - lastReward
	if timePassed < COOLDOWN_SECONDS then
		local remaining = COOLDOWN_SECONDS - timePassed
		local hours = math.floor(remaining / 3600)
		local minutes = math.floor((remaining % 3600) / 60)
		local seconds = remaining % 60

		local timeText = ""
		if hours > 0 then
			timeText = string.format("%d hour%s and %d minute%s", hours, hours ~= 1 and "s" or "", minutes, minutes ~= 1 and "s" or "")
		elseif minutes > 0 then
			timeText = string.format("%d minute%s and %d second%s", minutes, minutes ~= 1 and "s" or "", seconds, seconds ~= 1 and "s" or "")
		else
			timeText = string.format("%d second%s", seconds, seconds ~= 1 and "s" or "")
		end

		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_ORANGE, string.format("You already claimed your reward! Please wait %s.", timeText))
		return false
	end
	player:setStorageValue(config.storage, currentTime)
	selfSay("You received your daily reward!", player)
	selfBoostAll(player)
	return true
end