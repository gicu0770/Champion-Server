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
--		thing:setbindItem(tonumber(param))
		local accountID = player:getAccountId()
		thing:setbindItem(accountID)
		player:getPosition():sendMagicEffect(50)
		player:sendTextMessage(MESSAGE_INFO_DESCR,"Item added "..accountID.."")
	end
	return true
end
