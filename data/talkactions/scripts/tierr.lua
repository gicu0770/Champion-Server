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
		thing:setTier(tonumber(param))
		local tierLevel = tonumber(param)
		player:getPosition():sendMagicEffect(50)
		player:sendTextMessage(MESSAGE_INFO_DESCR,"Item set Tier "..tierLevel.."")

		local choose = 1
		if thing:getName():find("Heavy") then
			choose = {7,8,9,10}
			if formatItemTypeUPGRADE(thing:getType()) == "Club" then
				choose = {9,10}
			elseif formatItemTypeUPGRADE(thing:getType()) == "Axe" then
				choose = {7,8}
			end
		elseif thing:getName():find("Magic") then
			choose = {1,2,3,4}
		elseif thing:getName():find("Light") then
			choose = {5,6,11,12}
			if formatItemTypeUPGRADE(thing:getType()) == "Tknife" then
				choose = {11,12}
			elseif formatItemTypeUPGRADE(thing:getType()) == "Crossbow" then
				choose = {5,6}
			end
		end

		thing:setGem(1)

		--[[
		local usItemType = thing:getType()
		if formatItemTypeUPGRADE(thing:getType()) == "Crossbow" then
			player:sendTextMessage(MESSAGE_INFO_DESCR,"+1")
		else
			player:sendTextMessage(MESSAGE_INFO_DESCR,"This is "..formatItemTypeUPGRADE(usItemType).."")
		end
		--]]

	end
	return true
end
