function onUse(player, item, fromPosition, target, toPosition, isHotkey)
if item:getId() == 0 then return end	
	if not target or not target:isItem() or not target:getType():isUpgradable() then
     return false
	end
	
	if toPosition.y <= CONST_SLOT_RING2 then
     player:sendTextMessage(MESSAGE_STATUS_WARNING, "You can't use that on equipped item!")
 	 player:say("You can't use that on equipped item!", TALKTYPE_MONSTER_SAY)
     player:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
	 player:getPosition():sendMagicEffect(3)
     return true
	end
 
	if item.itemid ~= US_CONFIG.ITEM_SCROLL_IDENTIFY and target:isUnidentified() then
	 player:say("Item is unidentified!", TALKTYPE_MONSTER_SAY)
     player:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
	 player:getPosition():sendMagicEffect(3)
     return true
	end

	if target:isCorrupted() then
	 player:say("Item is corrupted!", TALKTYPE_MONSTER_SAY)
	 player:sendTextMessage(MESSAGE_STATUS_WARNING, "You can't use that on corrupted item!")
     player:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
	 player:getPosition():sendMagicEffect(3)
	 return true
	end

	if target:getRarity().name == "Divine" then
		player:say("Item is Divine!", TALKTYPE_MONSTER_SAY)
		player:sendTextMessage(MESSAGE_STATUS_WARNING, "You can't use that on Divine item!")
		player:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
		player:getPosition():sendMagicEffect(3)
		return true
	end



	item:remove(1)
	target:setRarity(7)
	player:say("Item has become "..target:getRarity().name.."", TALKTYPE_MONSTER_SAY)
	player:sendExtendedOpcode(105, json.encode({reload = "reload"}))
 return true
end