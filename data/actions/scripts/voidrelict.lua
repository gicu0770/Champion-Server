function onUse(player, item, fromPosition, itemEx, toPosition)
	local itemId = 5881
	if player:getItemCount(itemId) >= 100 then
		local item = player:getSlotItem(CONST_SLOT_BACKPACK)
		if not item then
			player:sendTooltipMessage("You don't have a backpack.")
			return false
		end
		if item and item:getEmptySlots(true) <= 0 then
			player:sendTooltipMessage("You don't have enough space in backpack.")
			return false
		end

		local relict = Game.createItem(38418, 1)
		if not relict then
			player:sendTooltipMessage("Error while creating item.")
			return false
		end

		relict:setCustomAttribute("void", 0)

		if player:addItemEx(relict) then
			player:removeItem(itemId, 100)
			player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
		else
			relict:remove()
			player:sendTooltipMessage("You don't have enough space in backpack.")
			return false
		end
		
	else
		player:sendTooltipMessage("You need at least 100 Fragments.")
	end

	return true
end