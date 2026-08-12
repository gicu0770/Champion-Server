function onUse(player, item, fromPosition, itemEx, toPosition)
if item.itemid == 8671 and item.actionid >= 10554 and item.actionid <= 10557 then
--	Item(item.uid):transform(item.itemid == 9825 and 9826 or 9825)


	local mainItem = Position(670, 1034, 6) -- Główny item
	local rightItem = Position(671, 1034, 6) -- prawy item
	
	if item.actionid == 10555 then
	mainItem = Position(673, 1034, 6)
	rightItem = Position(674, 1034, 6)
	elseif item.actionid == 10556 then
	mainItem = Position(676, 1034, 6)
	rightItem = Position(677, 1034, 6)
	elseif item.actionid == 10557 then
	mainItem = Position(679, 1034, 6)
	rightItem = Position(680, 1034, 6)
	end


	local tilemain = Tile(mainItem)
--	local tileleft = Tile(leftItem)
	local tileright = Tile(rightItem)
	local thingM = tilemain:getTopVisibleThing(player)
--	local thingL = tileleft:getTopVisibleThing(player)
	local thingR = tileright:getTopVisibleThing(player)
if thingM:getId() == 0 then return end
-- if thingL:getId() == 0 then return end
if thingR:getId() == 0 then return end

if thingM:isItem() and thingR:isItem() then -- and thingL:isItem()
	local itemType = ItemType(thingM:getId())
--  if thingM:isUnidentified() then
--	 player:say("Item is unidentified!", TALKTYPE_MONSTER_SAY)
--     player:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
--     return true
--   end	
  if thingM:isCorrupted() then
     player:sendTextMessage(MESSAGE_STATUS_WARNING, "Sorry, this item is corrupted and can't be modified!")
     player:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
    return true
  end
   if thingM:getClassItemLevel() <= 9 then
	if thingM:getClassItem() == thingR:getClassItem() then	--	thingM:getClassItem() == thingL:getClassItem() and
	 if thingM:getId() == thingR:getId() then	--	thingM:getId() == thingL:getId() and 
	 local attack_added = 0
	  if itemType:getAttack() > 0 then
		attack_added = thingM:getTier() * (thingM:getClassItemLevel()+1) + 1
	   thingM:setAttribute(ITEM_ATTRIBUTE_ATTACK, thingM:getAttribute(ITEM_ATTRIBUTE_ATTACK) + attack_added)
	  end
	  if itemType:getArmor() > 0 then
		attack_added = (thingM:getTier() * (thingM:getClassItemLevel()+1)) * 3 + 1
	   thingM:setAttribute(ITEM_ATTRIBUTE_ARMOR, thingM:getAttribute(ITEM_ATTRIBUTE_ARMOR) + attack_added )
	  end
	  if formatItemTypeUPGRADE(itemType) == "Shield" then
		attack_added = (thingM:getTier() * (thingM:getClassItemLevel()+1)) * 4 + 1
	   thingM:setAttribute(ITEM_ATTRIBUTE_DEFENSE, thingM:getAttribute(ITEM_ATTRIBUTE_DEFENSE) + attack_added )
	  end
	   player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You "..thingM:getName().." successful upgraded!")
	   thingM:getPosition():sendMagicEffect(50)
	   thingR:remove()
	--   thingL:remove()
	   thingM:setClassItemLevel(thingM:getClassItemLevel()+1)
	   thingM:setClassItem(thingM:getClassItem()+1)
	   local attack_fusion = thingM:getFusionLevel()
	   attack_fusion = attack_fusion + attack_added
	   thingM:setFusionLevel(attack_fusion)
	   player:sendExtendedOpcode(105, json.encode({reload = "reload"}))
	 else
	  player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Right item is other must be same Item!")
	 end
	else
	 player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Right item have other Fusion Tier!")
	end
   else
    player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Maximum Class upgrade level!")
   end
   
end

end
	return true
end