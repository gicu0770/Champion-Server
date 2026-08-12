local Vitality = { 36971, 1 }
local Armored = { 36972, 2 }
local Antimagic = { 36973, 3 }
local Healing = { 36974, 4 }
local Magical = { 36975, 5 }
local Sharp = { 36976, 6 }
local Monstrous = { 36977, 7 }
local Piercing = { 36978, 8 }
local Skilled = { 36980, 9 }
local Melee = { 37286, 10 }
local Spike = { 37284, 11 }
local Cursed = { 37295, 12 }
local Energy = { 37301, 13 }
local Blow = { 37283, 14 }
local Cast = { 37290, 15 }
local Gold = { 37282, 16 }
local EXP = { 37287, 17 }
local Shielding = { 37298, 18 }
local upgradeItem = 36979
local removalItem = 36981

local config = {
	[1] = 36971,
	[2] = 36972,
	[3] = 36973,
	[4] = 36974,
	[5] = 36975,
	[6] = 36976,
	[7] = 36977,
	[8] = 36978,
	[9] = 36980,
	[10] = 37286,
	[11] = 37284,
	[12] = 37295,
	[13] = 37301,
	[14] = 37283,
	[15] = 37290,
	[16] = 37282,
	[17] = 37287,
	[18] = 37298,
}
local configItems = {
	[1] = 1,
	[2] = 1,
	[3] = 1,
	[4] = 3,
	[5] = 2,
	[6] = 2,
	[7] = 2,
	[8] = 2,
	[9] = 3,
	[10] = 2,
	[11] = 1,
	[12] = 2,
	[13] = 3,
	[14] = 2,
	[15] = 2,
	[16] = 3,
	[17] = 1,
	[18] = 1,
}

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
	if item.itemid == upgradeItem then
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
		if target:getSoulShardLevel() >= 5 then
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

	-- removal
	if item.itemid == removalItem then
		for i = 1, #config do
			if target:getId() == config[i] then
				player:getPosition():sendMagicEffect(3)
				return false
			end
		end
		if not target:isSoulShard() then
			player:sendTextMessage(MESSAGE_INFO_DESCR, "Item dont have Soul Shard!")
			player:getPosition():sendMagicEffect(3)
			return false
		end
		local elementShard = {
			[1]= {name = "Flame"},
			[2]= {name = "Frozen"},
			[3]= {name = "Tunder"},
			[4]= {name = "Toxic"},
			[5]= {name = "Dark"},
			[6]= {name = "Bless"},
			[7]= {name = "Power"},
		}
		if math.random(100000) <= 100000 then
			local shardStatus = target:getSoulShard()
			if shardStatus == 19 then
				player:sendTextMessage(MESSAGE_INFO_DESCR,"Soul Shard has been removed successful!\nYou removed Damaged Soul Shard!")
				target:setSoulShard(false)
				target:setSoulShardLevel(false)
				player:sendExtendedOpcode(105, json.encode({ reload = "reload" }))
				player:getPosition():sendMagicEffect(325)
				return true
			end
			local createStone = player:addItem(config[target:getSoulShard()], 1)
			local shardStatusLevel = target:getSoulShardLevel()
			createStone:setSoulShard(shardStatus)
			createStone:setSoulShardLevel(shardStatusLevel)
			if target:isLegendarySoulShard() then
				createStone:setLegendarySoulShard(true)
				local name = ItemType(config[target:getSoulShard()]):getName()
				createStone:setAttribute(ITEM_ATTRIBUTE_NAME, "Legendary " .. name .. "")
			end
			if target:getCustomAttribute("elemental_empower") then
				createStone:setCustomAttribute("elemental_empower", target:getCustomAttribute("elemental_empower"))
				local name = ItemType(config[target:getSoulShard()]):getName()
				createStone:setAttribute(ITEM_ATTRIBUTE_NAME, "Legendary " .. name .. "")
				createStone:setAttribute(ITEM_ATTRIBUTE_NAME, ""..elementShard[target:getCustomAttribute("elemental_empower")].name.." " .. name .. "")
			end
			player:sendTextMessage(MESSAGE_INFO_DESCR,"Soul Shard has been removed successful!\nYou removed " ..createStone:getName() .. "+" .. shardStatusLevel .. "")
			item:remove(1)
			target:setSoulShard(false)
			target:setSoulShardLevel(false)
			if target:isLegendarySoulShard() then target:setLegendarySoulShard(false) end
			if target:getCustomAttribute("elemental_empower") then target:setCustomAttribute("elemental_empower", false) end
			player:sendExtendedOpcode(105, json.encode({ reload = "reload" }))
			player:getPosition():sendMagicEffect(325)
		else
			item:remove(1)
			--	player:say("Shard removed failed!", TALKTYPE_MONSTER_SAY)
			player:sendTextMessage(MESSAGE_INFO_DESCR, "Shard removed failed!")
			player:sendExtendedOpcode(105, json.encode({ reload = "reload" }))
			player:getPosition():sendMagicEffect(326)
		end
	end
	---
	if not target or not target:isItem() or not target:getType():isUpgradable() then
		return false
	end
	if toPosition.y <= CONST_SLOT_RING2 then
		player:sendTextMessage(MESSAGE_STATUS_WARNING, "You can't use that on equipped item!")
		player:say("You can't use that on equipped item!", TALKTYPE_MONSTER_SAY)
		player:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
		return true
	end
	if item.itemid ~= US_CONFIG.ITEM_SCROLL_IDENTIFY and target:isUnidentified() then
		player:say("Item is unidentified!", TALKTYPE_MONSTER_SAY)
		player:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
		return true
	end
	local itemSlot = 0
	if target:isSet() then
		itemSlot = 1
	elseif target:isAccessories() then
		itemSlot = 2
	end
	for i = 1, #config do
		if item.itemid == config[i] then
			if configItems[i] == itemSlot or configItems[i] == 3 then
				if not target:isSoulShard() and target:isEmptySlotItem() then
					if math.random(100000) <= 85000 then
						if item:isLegendarySoulShard() then target:setLegendarySoulShard(true) end
						target:setSoulShard(i)
						target:setSoulShardLevel(item:getSoulShardLevel())
						target:setCustomAttribute("elemental_empower", item:getCustomAttribute("elemental_empower"))
						item:remove()
						player:sendTextMessage(MESSAGE_STATUS_WARNING,"You added " .. item:getName() .. " to you " .. target:getName() .. "!")
						player:sendExtendedOpcode(105, json.encode({ reload = "reload" }))
						player:getPosition():sendMagicEffect(325)
					else
						player:sendTextMessage(MESSAGE_STATUS_WARNING, "Failed to add Soul Shard slot has been damaged!")
						target:setSoulShard(19)
						target:setSoulShardLevel(0)
						target:setCustomAttribute("elemental_empower", false)
						item:remove()
						player:sendExtendedOpcode(105, json.encode({ reload = "reload" }))
						player:getPosition():sendMagicEffect(326)
					end
				else
					player:sendTextMessage(MESSAGE_STATUS_WARNING,"You " .. target:getName() .. " have Soul Shard or dont have Empty Slot!")
				end
			else
				player:sendTextMessage(MESSAGE_STATUS_WARNING, "Soul Shard not avaible for this item!")
			end
		end
	end
	return true
end
