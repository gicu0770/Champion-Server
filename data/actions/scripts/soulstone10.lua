local upgradeItemPerceft = 35799
function onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if target:getId() == 0 then return end
	local itemType = ItemType(target.itemid)
	if not target then
		return false
	end
	if target:isCorrupted() then
		player:sendTextMessage(MESSAGE_STATUS_WARNING, "You can't use that on corrupted item!")
		player:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
		player:getPosition():sendMagicEffect(3)
		return true
	end

	--- Upgrade
	if item.itemid == upgradeItemPerceft then
		if not target:isSoulShard() then
			player:sendTextMessage(MESSAGE_INFO_DESCR, "Item dont have Soul Shard!")
			player:getPosition():sendMagicEffect(3)
			return false
		end
		if target:getSoulShard() == 19 then
			player:sendTextMessage(MESSAGE_INFO_DESCR, "Item have Broken Soul Shard!")
			player:getPosition():sendMagicEffect(3)
			return false
		end
		if target:getSoulShardLevel() < 5 then
			player:sendTextMessage(MESSAGE_INFO_DESCR, "Soul Shard Level only 5+!")
			player:getPosition():sendMagicEffect(3)
			return false
		end
		if target:getSoulShardLevel() >= 10 then
			player:sendTextMessage(MESSAGE_INFO_DESCR, "Soul Shard Level is max!")
			player:getPosition():sendMagicEffect(3)
			return false
		end
		if math.random(100000) <= 5000 then
			if target:getSoulShardLevel() >= 0 then
				if target:getSoulShardLevel() >= 1 then
					target:setSoulShardLevel(target:getSoulShardLevel() - 1)
				end
				item:remove(1)
				player:sendExtendedOpcode(105, json.encode({ reload = "reload" }))
				player:getPosition():sendMagicEffect(326)
				return false
			end
		elseif math.random(100000) <= 33333 then
			target:setSoulShardLevel(target:getSoulShardLevel() + 1)
			item:remove(1)
			player:sendExtendedOpcode(105, json.encode({ reload = "reload" }))
			player:getPosition():sendMagicEffect(325)
			return false
		else
			item:remove(1)
			player:sendExtendedOpcode(105, json.encode({ reload = "reload" }))
			player:getPosition():sendMagicEffect(326)
			return false
		end
	end
	return true
end