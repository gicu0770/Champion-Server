function onUse(player, item, fromPosition, itemEx, toPosition)
	local points = 10
   db.query('UPDATE znote_accounts SET points=points+'.. points ..' WHERE account_id=' .. player:getAccountId() ..' LIMIT 1;')
   player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You have recived 10 premium points to your account!")
   player:getPosition():sendMagicEffect(28)
   item:remove(1)
   return true
end