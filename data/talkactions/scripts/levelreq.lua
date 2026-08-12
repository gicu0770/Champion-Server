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

	if thing:isItem() then
		if thing == tile:getGround() then
			player:sendCancelMessage("test.")
			return false
		end
	--	thing:setLevelReq(tonumber(param))
		local levelReqConfig = {
	[1] = 100,
	[2] = 150,
	[3] = 200,
	[4] = 400,
	[5] = 600,
	[6] = 800,
	[7] = 1000,
	[8] = 1200
	}
		thing:setTier(tonumber(param))
		thing:setLevelReq(levelReqConfig[tonumber(param)])
		local tierLevel = tonumber(param)
		player:getPosition():sendMagicEffect(50)
		player:sendTextMessage(MESSAGE_INFO_DESCR,"Item set Level req "..tierLevel.."")
	end
	return true
end
