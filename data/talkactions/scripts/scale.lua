function onSay(player, words, param)
	if not player:getGroup():getAccess() then
		return true
	end

	local split = param:splitTrimmed(" ")
	local scale = tonumber(split[1]) or 1.4
	local duration = tonumber(split[2]) or 10000 -- default 10s, pass -1 for permanent
	local anim = 300

	local target = player:getTarget() or player
	target:setScale(scale, duration, anim)

	local durText = (duration <= 0 or duration == -1) and "permanently" or string.format("for %d ms", duration)
	player:sendTextMessage(MESSAGE_INFO_DESCR, string.format("Set scale of %s to %.2fx %s.", target:getName(), scale, durText))
	return false
end
