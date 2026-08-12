function onUse(player, item, fromPosition, target, toPosition)
  if toPosition.y <= CONST_SLOT_POTION2 then
    player:sendTextMessage(MESSAGE_INFO_DESCR, "You can't use that on equipped item!")
	player:say("You can't use that on equipped item!", TALKTYPE_MONSTER_SAY)
    player:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
    return true
  end
if target:isPlayer() then return false end
local itemType = ItemType(target.itemid)
if target:isUnidentified() then	
 if item.itemid == US_CONFIG.ITEM_INFINITY then
    if target:isUnidentified() then
      if itemType then
        local weaponType = itemType:getWeaponType()
		--[[--
        if target:identify(player, itemType, weaponType) then
			player:sendExtendedOpcode(105, json.encode({reload = "reload"}))
        else
			player:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
        end 
		--]]--
		target:removeCustomAttribute("unidentified")
		player:sendExtendedOpcode(105, json.encode({reload = "reload"}))
		
      end
	   else
      player:sendTextMessage(MESSAGE_INFO_DESCR, "Not possible")
    end
 end 
end
	return true
end
