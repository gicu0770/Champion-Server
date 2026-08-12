function onSay(player, words, param)
	if not player:getGroup():getAccess() then
		return true
	end
	if player:getAccountType() < ACCOUNT_TYPE_GOD then
		return false
	end
	local split = param:splitTrimmed(",")
	local effect = tonumber(split[1])
	if(effect ~= nil and effect > 0) then
		player:getPosition():sendMagicEffect(effect, false, split[2])
	end

	return false
end
