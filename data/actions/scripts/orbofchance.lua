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
	if item:getId() == 8302 then -- add spell enhantment
		if not target:getCustomAttribute("spellid") then
			if math.random(100) <= 33 then
				local randomNum = math.random(1, #GLOBAL_SPELL_NUMBER)
				target:setCustomAttribute("spellid", randomNum)
				target:setCustomAttribute("spelllevel", math.random(1, 3))
				player:sendExtendedOpcode(105, json.encode({ reload = "reload" }))
				player:getPosition():sendMagicEffect(325)
				item:remove(1)
			else
				player:getPosition():sendMagicEffect(326)
				item:remove(1)
			end
		else
			player:say("The item has Spell Enhantment.", TALKTYPE_MONSTER_SAY)
			player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "The item has Spell Enhantment.")
			player:getPosition():sendMagicEffect(3)
			return false
		end
	end

	if item:getId() == 37109 then -- increase spell level
		if target:getCustomAttribute("spellid") then
			if target:getCustomAttribute("spelllevel") >= 5 then
				player:say("The item has reached its maximum 5 level.", TALKTYPE_MONSTER_SAY)
				player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "The item has reached its maximum 5 level.")
				player:getPosition():sendMagicEffect(3)
				return false
			end
		end
		if math.random(100000) <= 15000 then
			target:setCustomAttribute("spellid", target:getCustomAttribute("spellid"))
			target:setCustomAttribute("spelllevel", target:getCustomAttribute("spelllevel") + 1)
			item:remove(1)
			player:getPosition():sendMagicEffect(291)
			player:sendExtendedOpcode(105, json.encode({ reload = "reload" }))
		elseif target:getCustomAttribute("spelllevel") >= 2 then
			target:setCustomAttribute("spelllevel", target:getCustomAttribute("spelllevel") - 1)
			player:sendExtendedOpcode(105, json.encode({ reload = "reload" }))
			item:remove(1)
			player:getPosition():sendMagicEffect(326)
			return false
		else
			player:say("Nothing happened.", TALKTYPE_MONSTER_SAY)
			player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Nothing happened.")
			player:getPosition():sendMagicEffect(3)
			return false
		end
	end

--[[
	local bonuses = target:getBonusAttributes()
	if bonuses then -- and target:getRarityId() == 1 then
		for i = 1, #bonuses do
			target:removeCustomAttribute("Slot" .. i)
		end
		item:remove(1)
		target:setHighRarityItem(3)
		-- target:setLegendaryItem(1)
		local tier = target:getTier()
		setLootItem(player, target, tier, 3500, 1700, 800)
		player:say("Item has become " .. target:getRarity().name .. "", TALKTYPE_MONSTER_SAY)
		player:getPosition():sendMagicEffect(5)
		player:sendExtendedOpcode(105, json.encode({ reload = "reload" }))
	else
		player:sendTextMessage(MESSAGE_STATUS_WARNING, "Item must be Common!")
		player:say("Item must be Common!", TALKTYPE_MONSTER_SAY)
		player:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
	end
	--]]

	return true
end