function onSay(player, words, param)
	if not player:getGroup():getAccess() then
		return true
	end
		if player:getAccountType() < ACCOUNT_TYPE_GOD then
		return false
	end
	local position = player:getPosition()
	position:getNextPosition(player:getDirection())

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
	local split = param:split(",")

	if thing:isItem() then
		if thing == tile:getGround() then
			player:sendCancelMessage("test.")
			return false
		end
		thing:setSoulShard(tonumber(split[1]))
		thing:setSoulShardLevel(tonumber(split[2]))
		thing:setCustomAttribute("elemental_empower",tonumber(split[3]))
		local tierLevel = tonumber(split[1])
		player:getPosition():sendMagicEffect(50)
		player:sendTextMessage(MESSAGE_INFO_DESCR,"Item set Soul "..tierLevel.."")
	end
	return true
end
