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

	local itemType = ItemType(target.itemid)
	-- Attributes        ------------ REWORK musi wchodzic wraz z innymi
	 if item:getId() == 37120 then
		if math.random(100000) <= ATTACK_SCALING[target:getArenaScalingAttributes()].chance then
		 player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Upgrade Success!")
		 target:setArenaScalingAttributes(target:getArenaScalingAttributes() + 1)
		 player:getPosition():sendMagicEffect(50)
		 item:remove(1)
		 return true
		else
		 player:say("Upgrade failed!", TALKTYPE_MONSTER_SAY)
		 player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Upgrade failed!")
		 player:getPosition():sendMagicEffect(3)
		 item:remove(1)
		 return true
		end
	end
	if target:isArenaScalingLevel() then
		if target:getArenaScalingLevel() >= target:getTier() or target:getArenaScalingAttributes() >= target:getTier() then
			player:say("The item has reached its maximum level.", TALKTYPE_MONSTER_SAY)
			player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "The item has reached its maximum level.")
			player:getPosition():sendMagicEffect(3)
			return
		end

	 if math.random(100000) <= ATTACK_SCALING[target:getArenaScalingLevel()].chance then
		-- Attack
	if item:getId() == 37118 then
	  if itemType:getAttack() > 0 then
	  player:getPosition():sendMagicEffect(50)
	  target:setAttribute(
          ITEM_ATTRIBUTE_ATTACK,
          target:getAttribute(ITEM_ATTRIBUTE_ATTACK) + ATTACK_SCALING[target:getArenaScalingLevel()].scaling
        )
		player:say("Upgrade Success!", TALKTYPE_MONSTER_SAY)
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Upgrade Success!")
		player:getPosition():sendMagicEffect(50)
		target:setArenaScalingLevel(target:getArenaScalingLevel() + 1)
		item:remove(1)
		player:sendExtendedOpcode(105, json.encode({reload = "reload"}))
	  else
	  player:getPosition():sendMagicEffect(3)
	  player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Item must have Attack!")
 	  player:say("Item must have Attack!", TALKTYPE_MONSTER_SAY)
 	  player:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
	  end
	end
		-- Armor
	if item:getId() == 37119 then
	  if itemType:getArmor() > 0 then
		player:getPosition():sendMagicEffect(50)
		target:setAttribute(
			ITEM_ATTRIBUTE_ARMOR,
			target:getAttribute(ITEM_ATTRIBUTE_ARMOR) + ATTACK_SCALING[target:getArenaScalingLevel()].scaling
		  )
		  player:say("Upgrade Success!", TALKTYPE_MONSTER_SAY)
		  player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Upgrade Success!")
		  player:getPosition():sendMagicEffect(50)
		  target:setArenaScalingLevel(target:getArenaScalingLevel() + 1)
		  item:remove(1)
		  player:sendExtendedOpcode(105, json.encode({reload = "reload"}))
		else
		player:getPosition():sendMagicEffect(3)
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Item must have Armor!")
		player:say("Item must have Armor!", TALKTYPE_MONSTER_SAY)
		player:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
		end
	end
		-- End attack and Armor
	 else
		player:say("Upgrade failed!", TALKTYPE_MONSTER_SAY)
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Upgrade failed!")
		player:getPosition():sendMagicEffect(3)
		item:remove(1)
	 end



    end

 return true
end