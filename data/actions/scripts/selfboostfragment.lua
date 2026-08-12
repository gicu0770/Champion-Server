function onUse(player, item, fromPosition, itemEx, toPosition)
	local rewards = {
		[38541] = {name = "LOOT", buffID = SELF_LOOT_BOOST},
		[38542] = {name = "GOLD", buffID = SELF_GOLD_BOOST},
		[38543] = {name = "EXP", buffID = BUFF_EXP_BOOST},
	}
	local itemId = item:getId()
	local config = rewards[itemId]
	if not config then
		return false
	end
	if player:getItemCount(itemId) >= 500 then
		selfBoost(player, config.buffID, config.name)
		player:removeItem(itemId, 500)
	else
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_ORANGE, "You need collect 500 fragments.")
	end
	return true
end