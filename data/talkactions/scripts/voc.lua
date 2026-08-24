function onSay(player, words, param)
	if not player:getGroup():getAccess() then
		return true
	end
		if player:getAccountType() < ACCOUNT_TYPE_GOD then
		return false
	end
	local split = param:splitTrimmed(",")
	if not split[2] then
		player:sendCancelMessage("Insufficient parameters.")
		return false
	end
	
	local target = Player(split[1])
	if not target then
		player:sendCancelMessage("A player with that name is not online.")
		return false
	end

	local vocation = tostring(split[2])
		target:setVocation(vocation)
		target:getPosition():sendMagicEffect(50)
		local vocName = target:getVocation():getName()
		target:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You vocation changed to "..vocName.."!")
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You changed "..target:getName().." vocation to "..vocName.."!")
		if target:getGroup():getId() ~= 3 and vocName and vocName ~= "None" then
			target:setTitle(vocName, "Reggae One-10px-bordered", "#0dff00")
		end
		player:sendCurrentTalents()
	return true
end

--addEvent(function() target:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You vocation changed to "..vocName.."!") end, 1000)
--addEvent(function() player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You changed "..target:getName().." vocation to "..vocName.."!") end, 1000)