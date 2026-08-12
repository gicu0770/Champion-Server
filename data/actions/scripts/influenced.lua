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

	local influenced = item:getInfluenced()
	if target:getInfluenced() == 0 then
		local random_influ = math.random(1,15)
		local chance = 70000
		if influenced >= 17 then chance = 80000 end
		if math.random(100000) <= chance then
			if math.random(100000) <= 250 then random_influ = math.random(17,25) end
			if not influenced then influenced = random_influ end
			target:setInfluenced(influenced)
			player:say("Influenced upgrade successful!", TALKTYPE_MONSTER_SAY)
			item:remove(1)
			player:getPosition():sendMagicEffect(12)
			player:sendExtendedOpcode(105, json.encode({ reload = "reload" }))
			player:getPosition():sendMagicEffect(325)
		else
			player:sendTextMessage(MESSAGE_INFO_DESCR, "Influenced upgrade failed!")
			item:remove(1)
			player:getPosition():sendMagicEffect(167)
			player:getPosition():sendMagicEffect(326)
		end
	else
		player:sendTextMessage(MESSAGE_INFO_DESCR, "Item is Influenced!")
		player:getPosition():sendMagicEffect(3)
		return true
	end

	return true
end