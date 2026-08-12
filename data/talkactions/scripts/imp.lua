function onSay(player, words, param)
	if not player:getGroup():getAccess() then
		return true
	end
	if player:getAccountType() < ACCOUNT_TYPE_GOD then
		return false
	end
	local position = player:getPosition()
	position:getNextPosition(player:getDirection())
	local split = param:split(",")
	local tile = Tile(position)
	if not tile then
		player:sendCancelMessage("Object not found.")
		return false
	end

	local thing = tile:getTopVisibleThing(player)
	if not thing then
		player:sendCancelMessage("Thing not found.")
		return false
	end

	if thing:isItem() then
		if thing == tile:getGround() then
			player:sendCancelMessage("test.")
			return false
		end
		local a = false
		if tonumber(split[3]) == 1 then
			a = true
		end

		thing:setImplictValue(tonumber(split[1]), tonumber(split[2]) .. "|" .. tonumber(split[3]) .. "|" .. tonumber(split[4]))

		thing:getPosition():sendMagicEffect(50)
		player:sendTextMessage(MESSAGE_INFO_DESCR,"Item set Implict 1 Slot ID i, 2 ID imp, 3 value, 4 Itemlevel")
	end
	return true
end

