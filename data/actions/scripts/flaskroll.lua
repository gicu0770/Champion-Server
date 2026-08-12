function onUse(player, item, fromPosition, target, toPosition, isHotkey)
if item:getId() == 0 then return end	
	if not target or not target:isItem() then
     return false
	end
	if not target:isFlask() then
		player:sendTextMessage(MESSAGE_INFO_DESCR, "Consumable item for Flask only!")
	end
	if item:getId() == 10577 then
		if target:isFlaskAttribute() then
			target:setFlaskAttribute(math.random(1, 5))
			player:sendTextMessage(MESSAGE_INFO_DESCR, "Flask roll new random attribute!")
			item:remove(1)
			player:sendExtendedOpcode(105, json.encode({ reload = "reload" }))
			return false
		end
		if not target:isFlaskAttribute() then
			target:setFlaskAttribute(math.random(1, 5))
			player:sendTextMessage(MESSAGE_INFO_DESCR, "Flask got new random attribute!")
			item:remove(1)
			player:sendExtendedOpcode(105, json.encode({ reload = "reload" }))
		else
			player:sendTextMessage(MESSAGE_STATUS_WARNING, "Your Flask already has the attribute!")
			player:say("Your Flask already has the attribute!", TALKTYPE_MONSTER_SAY)
			player:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			player:getPosition():sendMagicEffect(3)
			return false
		end
	end

	if item:getId() == 37117 then
		if target:isQuality() >= 30 then
			player:say("The item has reached its maximum 30 level.", TALKTYPE_MONSTER_SAY)
			player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "The item has reached its 30 maximum level.")
			player:getPosition():sendMagicEffect(3)
			return false
		end
		if math.random(100000) <= 100000 then
			player:getPosition():sendMagicEffect(291)
			target:setQuality(target:isQuality() + 1)
			player:sendExtendedOpcode(105, json.encode({ reload = "reload" }))
		else
			player:getPosition():sendMagicEffect(326)
		end
	end

 return true
end