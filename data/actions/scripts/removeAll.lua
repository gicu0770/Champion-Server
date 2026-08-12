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
	
local bonuses = target:getBonusAttributes()
if bonuses then
 for i = 1, #bonuses do
  target:removeCustomAttribute("Slot" .. i)
 end
 item:remove(1)
 player:sendTextMessage(MESSAGE_INFO_DESCR, "Successfuly removed all attributes.")
 player:say("Remove all attributes!", TALKTYPE_MONSTER_SAY)
 player:getPosition():sendMagicEffect(5)
 player:sendExtendedOpcode(105, json.encode({reload = "reload"}))
 else
 player:sendTextMessage(MESSAGE_INFO_DESCR, "Item dont have attributes.")
 player:say("Item dont have attributes!", TALKTYPE_MONSTER_SAY)
end

 return true
end