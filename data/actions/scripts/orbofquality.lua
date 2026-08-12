function onUse(player, item, fromPosition, target, toPosition, isHotkey)
if item:getId() == 0 then return end	
	if not target or not target:isItem() or target:getSpellName() == "" then
		return false
	   end


	SPELL_CACHE[target:getRealUID()] = nil
	player:sendExtendedOpcode(105, json.encode({ reload = "reload", spell = true }))
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
	
	if target:isMirrored() then
     player:sendTextMessage(MESSAGE_STATUS_WARNING, "Sorry, this item is mirrored and can't be mirrored again!")
     player:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
     return true
	end
	if item:getId() == 37116 and target:isQuality() then
		if target:isQuality() >= 30 then
			player:say("The item has reached its maximum 30 level.", TALKTYPE_MONSTER_SAY)
			player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "The item has reached its maximum 30 level.")
			player:getPosition():sendMagicEffect(3)
			return false
		end
		if math.random(100000) <= 100000 then
			target:setQuality(target:isQuality() + 1)
			Game.sendAnimatedText('Success!', player:getPosition(), 192, "Reggae One-20px-bordered")
			player:getPosition():sendMagicEffect(325)
			item:remove(1)
		end
	end
	if item:getId() == 37115 then
		local random = math.random(100000)
		if not target:getCustomAttribute("empower_spellrune") then
			target:setCustomAttribute("empower_spellrune", 1)
			local name = target:getName()
			target:setAttribute(ITEM_ATTRIBUTE_NAME, "Enhanced " .. name .. "")
		else
			if target:getCustomAttribute("empower_spellrune") >= 10 then
				player:say("The item has reached its maximum 10 level.", TALKTYPE_MONSTER_SAY)
				player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "The item has reached its maximum 10 level.")
				player:getPosition():sendMagicEffect(3)
				return false
			end
			target:setCustomAttribute("empower_spellrune", target:getCustomAttribute("empower_spellrune") + 1)
			item:remove(1)
		end

	end

 return true
end