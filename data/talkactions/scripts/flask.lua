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
	local bonus1 = tonumber(split[1]) or nil
	local bonus2 = tonumber(split[2]) or nil
	if thing:isItem() then
		if thing == tile:getGround() then
			player:sendCancelMessage("test.")
			return false
		end
		thing:setFlask(bonus2)
		thing:setFlaskBonus(bonus1)
		player:getPosition():sendMagicEffect(50)
		player:sendTextMessage(MESSAGE_INFO_DESCR,"Item set Flask Main bonus "..bonus2.." Second bonus "..bonus1.."")
	end

    return false
end