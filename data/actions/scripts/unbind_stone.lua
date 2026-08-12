function onUse(player, item, fromPosition, itemEx, toPosition)
  if toPosition.y <= CONST_SLOT_POTION2 then
    player:sendTextMessage(MESSAGE_STATUS_WARNING, "You can't use that on equipped item!")
	player:say("You can't use that on equipped item!", TALKTYPE_MONSTER_SAY)
    player:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
    return true
  end
if itemEx:isPlayer() then return false end
	if itemEx:bindItem() >= 1 then
		itemEx:setbindItem(0)
		player:sendTextMessage(MESSAGE_INFO_DESCR, "Account binding has been removed!")
		item:remove()
		player:sendExtendedOpcode(105, json.encode({reload = "reload"}))
	end 
	return true
end
