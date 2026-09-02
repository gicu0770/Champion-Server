local rarity_change_on_level = {
	[5] = 1,
	[20] = 2,
	[40] = 3,
	[60] = 4,
}

local affixes = {
  [1] = {
    name = "Elite",
    skull = 7,
    hpMultiplier = 1.5,
    dmgMultiplier = 1.15,
    clones = 2,
    weight = 50, -- Większa szansa na Elite
    lootChance = 1.20 -- 20% wiecej gold i exp
  },
  [2] = {
    name = "Champion",
    skull = 8,
    hpMultiplier = 2.5,
    dmgMultiplier = 2.0,
    clones = 0,
    weight = 50, -- Mniejsza szansa na Champion
    lootChance = 4.00 -- 3 x wiecej gold i exp
  }
}

local PLAYERS_COLLECTION_EVENTS = {}
function Player:onBrowseField(position)
	return true
end

function Player:onWalk(fromPosition, toPosition)
	self:showFootprint(fromPosition, toPosition)
	return false
end

function Player:onHouseWalk(house, enter)
	self:walkHouse(house, enter)
	return true
end

local get_mod_time = function(filePath)
	if package.config:sub(1,1) == '\\' then
		return 1000
	end
	local p = io.popen('stat -c %Y "' .. filePath .. '" 2>/dev/null')
	if p then
		local val = tonumber(p:read("*a"))
		p:close()
		if val then return val end
	end
	return 1000
end

local mod_time = get_mod_time("data/upgrade_enchantments.lua") + get_mod_time("data/upgrade_system_const.lua")
ITEM_CHECKSUM = mod_time % 10000
local debug_item_fixed = true
function Player:onLoadItem(item)
	if not item then
		return
	end

	local itemType = item:getType()
	if itemType:isStackable() then
		return
	end

	local itemId = item:getId()
	if item:getCustomAttribute("recombinerItem") or (RECOMB_RECIPE_ITEM_IDS and RECOMB_RECIPE_ITEM_IDS[itemId]) then
		return
	end
	local itemName = item:getName()
	local itemLevel = item:getItemLevel() or 0
	local unique = item:getUnique()
	local corrupted = item:isCorrupted()
	local rarity = item:getRarityId()
	local checkSum = tonumber(item:getCustomAttribute("checksum") or 0)
	if checkSum == ITEM_CHECKSUM then
		return
	end

	-- local level = item:getCustomAttribute("level") or 1
	-- if level > 200 then
	-- 	local slotPosition = itemType:getSlotPosition() - SLOTP_LEFT - SLOTP_RIGHT
	-- 	local maxLevel = level
	-- 	if slotPosition == SLOTP_SUPPORT1_1 then
	-- 		maxLevel = math.min(level, 200)
	-- 	else
	-- 		maxLevel = math.min(level, 300)
	-- 	end

	-- 	item:setCustomAttribute("level", maxLevel)
	-- end

	item:setCustomAttribute("checksum", ITEM_CHECKSUM)
	if unique then
		local uniqueItem = US_UNIQUES[unique]
		if not uniqueItem then
			print("unique with id was removed " .. unique)
			return
		end

		if uniqueItem.name and uniqueItem.name ~= itemName then
			item:setAttribute(ITEM_ATTRIBUTE_NAME, uniqueItem.name)
		end

		if uniqueItem.crystalSlots and uniqueItem.crystalSlots ~= item:getCrystalSlots() then
			item:setCrystalSlots(uniqueItem.crystalSlots)
		end

		if uniqueItem.mirrored and not item:isMirrored() then
			item:setMirrored(1)
		end

		if uniqueItem.monsterLevel and uniqueItem.monsterLevel ~= itemLevel then
			item:setItemLevel(uniqueItem.monsterLevel)
		end

		if uniqueItem.attack and item:getAttribute(ITEM_ATTRIBUTE_ATTACK) ~= uniqueItem.attack then
			item:setAttribute(ITEM_ATTRIBUTE_ATTACK, uniqueItem.attack)
		end
		if uniqueItem.armor and item:getAttribute(ITEM_ATTRIBUTE_ATTACK) ~= uniqueItem.armor then
			item:setAttribute(ITEM_ATTRIBUTE_ARMOR, uniqueItem.armor)
		end
		if uniqueItem.defense and item:getAttribute(ITEM_ATTRIBUTE_ATTACK) ~= uniqueItem.defense then
			item:setAttribute(ITEM_ATTRIBUTE_DEFENSE, uniqueItem.defense)
		end

		if uniqueItem.attr then
			local reCheck = false
			local bonuses = item:getBonusAttributes()
			if not bonuses and uniqueItem.attr then
				print("uniques missing adding them back")
				for x = 1, #uniqueItem.attr do
					local value = math.random(uniqueItem.attr[x].min, uniqueItem.attr[x].max)
					item:setAttributeValue(x, uniqueItem.attr[x].id.."|".. value.."|".. 0)
				end
				reCheck = true
			end

			if not bonuses and not uniqueItem.attr then
				goto nextCheck
			end

			if reCheck then
				bonuses = item:getBonusAttributes()
				reCheck = false
			end

			if #bonuses ~= #uniqueItem.attr then
				print("mods not matching redoing them")
				for x = #bonuses, -1 do
					item:setAttributeValue(x)
				end

				for x = 1, #uniqueItem.attr do
					local value = math.random(uniqueItem.attr[x].min, uniqueItem.attr[x].max)
					item:setAttributeValue(x, uniqueItem.attr[x].id.."|".. value.."|".. 0)
				end

				reCheck = true
			end

			if reCheck then
				bonuses = item:getBonusAttributes()
				reCheck = false
			end

			for index, bonus in ipairs(bonuses) do
				local id = bonus[1]
				local value = bonus[2]
				local slot = bonus[4]
				local attr = US_ENCHANTMENTS[id]
				if not attr then
					print("MISSING ATTRIBUTE ON UNIQUE " .. id .. "-" .. value .. "-" .. itemName .. "-" .. unique)
					goto continue
				end

				if not uniqueItem.attr[index] then
					print("there is no mod with index: " .. index)
					item:setAttributeValue(slot)
				end

				if uniqueItem.attr[index] and uniqueItem.attr[index].id ~= id then
					print(id .. " should " .. uniqueItem.attr[index].id .. " on unique " .. unique)
					local value = math.random(uniqueItem.attr[index].min, uniqueItem.attr[index].max)
					item:setAttributeValue(slot, uniqueItem.attr[index].id.."|".. value.."|".. 0)
				end

				if uniqueItem.attr[index] and uniqueItem.attr[index].min > value then
					local newValue = uniqueItem.attr[index].min
					item:setAttributeValue(slot, id.."|"..newValue.."|".. 0)
					if debug_item_fixed then
						print("MODIFIER | " .. attr.name .. " on " .. itemName .. " from " .. value .. " to " .. newValue)
					end
				end

				if uniqueItem.attr[index] and uniqueItem.attr[index].max < value then
					local newValue = uniqueItem.attr[index].max
					item:setAttributeValue(slot, id.."|"..newValue.."|".. 0)
					if debug_item_fixed then
						print("MODIFIER | " .. attr.name .. " on " .. itemName .. " from " .. value .. " to " .. newValue)
					end
				end
				::continue::
			end
		end
		::nextCheck::

		local wrongImplicts = {}
		if uniqueItem.implicit then
			local reCheck = false
			local bonuses = item:getImplictBonusAttributes()
			local implictsSlots = #uniqueItem.implicit
			if not bonuses and uniqueItem.attr then
				print("uniques missing adding them back")
				item:setImplictSlots(implictsSlots)
				for x = 1, #uniqueItem.attr do
					local value = math.random(uniqueItem.attr[x].min, uniqueItem.attr[x].max)
					item:setImplictValue(x, uniqueItem.attr[x].id.."|".. value.."|".. 0)
				end
				reCheck = true
			end

			if reCheck then
				bonuses = item:getImplictBonusAttributes()
				reCheck = false
			end

			if not corrupted and #bonuses ~= #uniqueItem.implicit then
				print("mods not matching redoing them")

				item:setImplictSlots(implictsSlots)
				for x = #bonuses, -1 do
					item:setImplictValue(x)
				end

				for x = 1, #uniqueItem.implicit do
					local value = math.random(uniqueItem.implicit[x].min, uniqueItem.implicit[x].max)
					item:setImplictValue(x, uniqueItem.implicit[x].id.."|".. value.."|".. 0)
				end

				reCheck = true
			end

			if reCheck then
				bonuses = item:getImplictBonusAttributes()
				reCheck = false
			end

			for index, bonus in ipairs(bonuses) do
				local id = bonus[1]
				local value = bonus[2]
				local slot = bonus[5]
				local attr = US_ENCHANTMENTS[id]
				if not attr then
					print("MISSING ATTRIBUTE ON UNIQUE " .. id .. "-" .. value .. "-" .. itemName .. "-" .. unique)
					goto continue
				end

				if not uniqueItem.implicit[index] then
					print("there is no implcit with index: " .. index)
					if not corrupted then
						item:setImplictValue(slot)
						if debug_item_fixed then
							print("REMOVING - IMPLICT | " .. attr.name .. " on " .. itemName .. " it was removed from unique")
						end
					else
						table.insert(wrongImplicts, bonus)
					end
				end

				if uniqueItem.implicit[index] and uniqueItem.implicit[index].id ~= id then
					print(id .. " should " .. uniqueItem.implicit[index].id .. " on unique " .. unique)
					local value = math.random(uniqueItem.implicit[index].min, uniqueItem.implicit[index].max)
					item:setImplictValue(slot, uniqueItem.implicit[index].id.."|".. value.."|".. 0)
				end

				if uniqueItem.implicit[index] and uniqueItem.implicit[index].min > value then
					local newValue = uniqueItem.implicit[index].min
					item:setImplictValue(slot, id.."|"..newValue.."|".. 0)
					if debug_item_fixed then
						print("MODIFIER | " .. attr.name .. " on " .. itemName .. " from " .. value .. " to " .. newValue)
					end
				end

				if uniqueItem.implicit[index] and uniqueItem.implicit[index].max < value then
					local newValue = uniqueItem.implicit[index].max
					item:setImplictValue(slot, id.."|"..newValue.."|".. 0)
					if debug_item_fixed then
						print("MODIFIER | " .. attr.name .. " on " .. itemName .. " from " .. value .. " to " .. newValue)
					end
				end

				::continue::
			end
		end

		if #wrongImplicts > 1 and unique ~= 15 then
			print("--> Something wrong, found multiple wrong implicts on unique")
			print("--> ".. self:getName() .. " has this items")
			print(itemName .. " | " .. unique)
			print(json.encode(wrongImplicts))
		end
		return
	end

	local itemSlot = ItemType(item:getId()):getSlotPosition()
	local bonuses = item:getBonusAttributes()
	if bonuses then
		for _, bonus in ipairs(bonuses) do
			local id = bonus[1]
			local value = bonus[2]
			local tier = bonus[3]
			local slot = bonus[4]
			local attr = US_ENCHANTMENTS[id]
			if not attr then
				if debug_item_fixed then
					print("REMOVING - MODIFIER " .. id .. "-" .. value .. "-" .. tier .. " from ".. itemName .. " it was removed from game!")
				end
				item:setAttributeValue(slot)
				goto continue
			end

			if attr.noValue or item:getCustomAttribute("crystal") then
				goto continue
			end

			if not REDUCTION_ATTR_VALUES[id] then
				print("no reduce value, but should have one: " .. attr.name .. "on item " .. itemName)
				goto continue
			end

			if not REDUCTION_ATTR_VALUES[id][tier] then
				print("no reduce value for tier ".. tier ..", but should have one: " .. attr.name .. "on item " .. itemName)
				goto continue
			end

			if (itemSlot == 1072) then
				value = math.ceil(value/TWO_HANDED_MULTIPLIER)
			end

			if REDUCTION_ATTR_VALUES[id][tier][1] > value then
				local newValue = REDUCTION_ATTR_VALUES[id][tier][1]
				if (itemSlot == 1072) then
					newValue = math.floor(newValue*TWO_HANDED_MULTIPLIER)
				end
				item:setAttributeValue(slot, id.."|"..newValue.."|"..tier)
				if debug_item_fixed then
					print("MODIFIER | " .. attr.name .. " on " .. itemName .. " from " .. value .. " to " .. newValue)
				end
			end

			if REDUCTION_ATTR_VALUES[id][tier][2] < value then
				local newValue = REDUCTION_ATTR_VALUES[id][tier][2]
				if (itemSlot == 1072) then
					newValue = math.floor(newValue*TWO_HANDED_MULTIPLIER)
				end
				item:setAttributeValue(slot, id.."|"..newValue.."|"..tier)
				if debug_item_fixed then
					print("MODIFIER | " .. attr.name .. " on " .. itemName .. " from " .. value .. " to " .. newValue)
				end
			end

			::continue::
		end
	end



	local implcits = item:getImplictBonusAttributes()
	local relict = item:getCustomAttribute("relict")
	local base_item = BASE_ITEMS_BY_ID[itemId]

	-- for now skipping potions
	local wrongImplicts = {}
	if implcits and item:getItemType() ~= US_ITEM_TYPES.POTION and not relict then
		for _, bonus in ipairs(implcits) do
			local id = bonus[1]
			local value = bonus[2]
			local monsterLevel = bonus[3]
			local slot = bonus[5]
			local attr = US_ENCHANTMENTS[id]

			if not attr then
				if debug_item_fixed then
					print("REMOVING - IMPLICT " .. id .. "-" .. value .. "-" .. monsterLevel .. " from ".. itemName .. " it was removed from game!")
				end
				item:setAttributeValue(slot)
				goto continue
			end

			if attr.noValue then
				goto continue
			end

			if not base_item then
				print(itemName .. " can't find base item for this item itemid:" .. itemId)
				goto continue
			end

			if not base_item[3] then
				print(itemName .. " should't have any implcits itemid:" .. itemId)
				goto continue
			end

			local foundImplict = false
			for x = 1, #base_item[3] do
				if base_item[3][x][1] == id then
					foundImplict = true
					local bonus_range = IMPLICT_BONUS[base_item[3][x][1]] or {0, 0}
					local min = bonus_range[1]
					local max = bonus_range[2]

					local minValue = math.floor((base_item[3][x][2] * monsterLevel / 100) * 0.7) + min
					local maxValue = math.floor(base_item[3][x][2] * monsterLevel / 100) + max

					if minValue == 0 then
						minValue = 1
					end

					if maxValue == 0 then
						maxValue = 1
					end

					if (itemSlot == 1072) then
						value = math.ceil(value/TWO_HANDED_MULTIPLIER)
					end

					if minValue > value then
						local newValue = minValue
						if debug_item_fixed then
							print("IMPLICT  | " .. attr.name .. " on " .. itemName .. " from " .. value .. " to " .. newValue)
						end
						if (itemSlot == 1072) then
							newValue = math.floor(newValue*TWO_HANDED_MULTIPLIER)
						end
						item:setImplictValue(slot, id.."|"..newValue.."|"..monsterLevel)
					end

					if maxValue < value then
						local newValue = maxValue
						if (itemSlot == 1072) then
							newValue = math.floor(newValue*TWO_HANDED_MULTIPLIER)
						end
						if debug_item_fixed then
							print("IMPLICT  | " .. attr.name .. " on " .. itemName .. " from " .. value .. " to " .. newValue)
						end

						item:setImplictValue(slot, id.."|"..newValue.."|"..monsterLevel)
					end
				end
			end

			if not foundImplict then
				if not corrupted then
					item:setImplictValue(slot)
					if debug_item_fixed then
						print("REMOVING - IMPLICT | " .. attr.name .. " on " .. itemName .. " it was removed from base item config")
					end
				else
					table.insert(wrongImplicts, bonus)
				end
			end


			::continue::
		end
	end

	if #wrongImplicts > 1 then
		print("--> Something wrong, found multiple wrong implicts")
		print("--> ".. self:getName() .. " has this items")
		print(itemName .. " | " .. itemId)
		print(json.encode(wrongImplicts))
	end

	if relict then
		local relictData = BOSS_DROPS_BY_ID[itemId]
		if not relictData then
			print("Relict but no data for it found " .. itemId .. " " .. self:getName())
		else
			local swappedImplicts = false
			if not corrupted then
				if #implcits ~= #relictData.imps[1] then
					item:setImplictSlots(#relictData.imps[1])
					for x = #implcits, -1 do
						item:setImplictValue(x)
					end

					for x = 1, #relictData.imps[1] do
						item:setImplictValue(x, relictData.imps[1][x].."|".. relictData.imps[2][x][rarity].."|".. 0)
					end

					swappedImplicts = true
				end
			end
	
			if not swappedImplicts then
				for index, bonus in ipairs(implcits) do
					local id = bonus[1]
					local value = bonus[2]
					local monsterLevel = bonus[3]
					local corrupted = bonus[4]
					local slot = bonus[5]
					local attr = US_ENCHANTMENTS[id]

					if id == relictData.imps[1][index] then
						local correctValue = relictData.imps[2][index][rarity]
						if not correctValue then
							correctValue = relictData.imps[2][index][1] / 2
						end
						if value ~= correctValue then
							item:setImplictValue(index, relictData.imps[1][index].."|".. correctValue .."|".. 0)
							if debug_item_fixed then
								print("RELICT - IMPLICT | " .. itemId .. " on " .. itemName .. " redid all implicts")
							end
						end
					else
						if corrupted then
							local foundImplict = false
							for x = 1, #relictData.imps[1] do
								if relictData.imps[1][x] == id then
									if relictData.imps[2][x][rarity] and value ~= relictData.imps[2][x][rarity] then
										item:setImplictValue(index, relictData.imps[1][x].."|".. relictData.imps[2][x][rarity].."|".. 0)
										if debug_item_fixed then
											print("RELICT - IMPLICT  | " .. attr.name .. " on " .. itemName .. " from " .. value .. " to " .. relictData.imps[2][x][rarity])
										end
									end
									foundImplict = true
									break
								end
							end

							if not foundImplict then
								-- if not found fix implicit
								print("corrupted relict don't need fix")
							end
						else
							item:setImplictValue(index, relictData.imps[1][index].."|".. relictData.imps[2][index][rarity].."|".. 0)
						end
					end
				end
			end


			if itemLevel == 0 then
				itemLevel = 100
				item:setItemLevel(100)
			end

			if bonuses then
				local missingMods = rarity - #bonuses
				if missingMods > 0 then
					item:correctModifiersPlaces(0)
					for _ = 1, missingMods do
						local attr = item:randomizeAttribute()
						if not attr then
							break
						end

						local slot = item:getLastSlot() + 1
						local tier = getTierAttribute(item, 1.0)
						local value = generateRandomAttributeValue(attr, tier, item)
						item:setAttributeValue(slot, attr.."|"..value.."|"..tier)
					end
				end
			end
		end

		::continue::
	end

	local crystals = item:getBonusFromCrystals()
	if crystals then
		for _, crystal in ipairs(crystals) do
			local attrId = crystal[1]
			local value = crystal[2]
			local itemId = crystal[3]
			local rarity = crystal[4]
			local quality = crystal[5]
			local index = crystal[6]
			local serverId = Game.getItemIdByClientId(itemId)
			local crystal_data = CRYSTAL_DATA_FROM_ID[serverId]
			local needChange = false
			if not crystal_data then
				print("Removed Crystal with ".. itemId)
				item:setCrystalValue(index)
				goto continue
			end

			if crystal_data[1] ~= attrId then
				attrId = crystal_data[1]
				needChange = true
			end

			if crystal_data[2][rarity] ~= value then
				value = crystal_data[2][rarity]
				needChange = true
			end

			if CRYSTAL_ITEMTYPES[serverId] then
				local correctType = false
				local itemType = formatItemType(item:getType(), item)
				for _, iType in ipairs(CRYSTAL_ITEMTYPES[serverId]) do
					if itemType == iType then
						correctType = true
						break
					end
				end

				if not correctType then
					local crystalItem = Game.createItem(serverId, 1)
					if not crystalItem then
						print("failed to create crystal and return to player: ".. itemId .. serverId)
						goto continue
					end

					item:setCrystalValue(index)
					crystalItem:setCustomAttribute("crystal", true)
					crystalItem:setCustomAttribute("slots", 1)
					crystalItem:setAttributeValue(1, attrId .. "|" .. value .. "|0|0")
					crystalItem:setRarity(rarity)
					crystalItem:setQuality(quality)
					self:getInbox():addItemEx(crystalItem, INDEX_WHEREEVER, FLAG_NOLIMIT)
					goto continue
				end
			end

			if needChange then
				item:setCrystalValue(index, attrId.. "|" ..value.. "|" .. itemId .. "|".. rarity .. "|" .. quality)
			end

			::continue::
		end
	end

	local isCrystal = item:getCustomAttribute("crystal")
	if isCrystal then
		local crystal_data = CRYSTAL_DATA_FROM_ID[item:getId()]
		if not crystal_data then
			item:remove()
			return
		end

		local bonus = item:getBonusAttribute(1)
		if not bonus then
			return
		end

		local needChange = false
		local attrId = bonus[1]
		local value = bonus[2]
		local rarity = item:getRarityId()
		if attrId ~= crystal_data[1] then
			attrId = crystal_data[1]
			needChange = true
		end

		if value ~= crystal_data[2][rarity] then
			value = crystal_data[2][rarity]
			needChange = true
		end

		if needChange then
			item:setAttributeValue(1, attrId .. "|" .. value .. "|0|0")
		end
	end
end

function Player:onLook(thing, position, distance)
	if thing:isItem() and thing:getType():isDoor() then
		local house = Tile(position):getHouse()
		if house then
			self:sendHouseInfo(house)
			return true
		end
	end
	local description = "You see " .. thing:getDescription(distance)
	--	description = onItemUpgradeLook(self, thing, position, distance, description)
	--description = onItemSetLook(self, thing, position, distance, description)
	if self:getGroup():getAccess() then
		if thing:isItem() then
			if thing:isLegendarySoulShard() then
				description = string.format("%s\nShard is Legendery: YES", description)
			else
				description = string.format("%s\nShard is Legendery: NO", description)
			end
			if thing:getCustomAttribute("base_defense") then
				description = string.format("%s\nDefense : %s", description, thing:getCustomAttribute("base_defense"))
			end

			description = string.format("%s\nBase Level : %s", description, thing:getCustomAttribute("level"))
			description = string.format("%s\ngetFlask : %s", description, thing:getFlask())
			description = string.format("%s\ngetFlaskBonus : %s", description, thing:getFlaskBonus())
			description = string.format("%s\ngetFlaskBonus2 : %s", description, thing:getFlaskBonus2())
			description = string.format("%s\n----------\nItem ID: %d\n---------", description, thing:getId())

			local actionId = thing:getActionId()
			if actionId ~= 0 then
				description = string.format("%s, Action ID: %d", description, actionId)
			end

			local uniqueId = thing:getAttribute(ITEM_ATTRIBUTE_UNIQUEID)
			if uniqueId > 0 and uniqueId < 65536 then
				description = string.format("%s, Unique ID: %d", description, uniqueId)
			end

			local itemType = thing:getType()
			local clientId = itemType:getClientId()
			description = string.format("%s\nClient ID: %d", description, clientId)
			local transformEquipId = itemType:getTransformEquipId()
			local transformDeEquipId = itemType:getTransformDeEquipId()
			if transformEquipId ~= 0 then
				description = string.format("%s\nTransforms to: %d (onEquip)", description, transformEquipId)
			elseif transformDeEquipId ~= 0 then
				description = string.format("%s\nTransforms to: %d (onDeEquip)", description, transformDeEquipId)
			end

			local decayId = itemType:getDecayId()
			if decayId ~= -1 then
				description = string.format("%s\nDecays to: %d", description, decayId)
			end

			local realID = thing:getRealUID()
			if realID ~= -1 then
				description = string.format("%s\n getRealUID: %d", description, realID)
			end

			local uniqueId = thing:getUniqueId()
			if uniqueId and uniqueId ~= 0 then
				description = string.format("%s\n Uniqueid: %d", description, uniqueId)
			end

			local actionId = thing:getActionId()
			if actionId and actionId ~= 0 then
				description = string.format("%s\n Actionid: %d", description, actionId)
			end
		elseif thing:isCreature() then
			local str = "%s\nHealth: %d / %d"
			if thing:isPlayer() and thing:getMaxMana() > 0 then
				str = string.format("%s, Mana: %d / %d", str, thing:getMana(), thing:getMaxMana())
			end
			description = string.format(str, description, thing:getHealth(), thing:getMaxHealth()) .. "."
		end

		local position = thing:getPosition()
		description = string.format("%s\nPosition: %d, %d, %d", description, position.x, position.y, position.z)
		if thing:isCreature() then
			if thing:isPlayer() then
				description = string.format("%s\nAttack Speed : %d", description, thing:getAttackSpeed())
				local client = thing:getClient()
				description = string.format("%s\nIP: %s PING: %i FPS: %i.", description,
					Game.convertIpToString(thing:getIp()), client.ping, client.fps)
			end
		end
	end
	----Quality onLook
	if thing:isPlayer() then
		function Player.getDefenseNOWEAPON(self)
			local total = 0
			local slots = { CONST_SLOT_RIGHT }
			local item
			for i = 1, #slots do
				item = self:getSlotItem(slots[i])
				if item then
					local attackT = item:hasAttribute(ITEM_ATTRIBUTE_DEFENSE) and
					item:getAttribute(ITEM_ATTRIBUTE_DEFENSE) or item:getType():getDefense()
					total = total + attackT
				end
			end
			return total
		end

		local damageReductionPercent = (thing:getTotalArmor() / (4000 + thing:getTotalArmor())) * 100
		if damageReductionPercent >= 85 then
			damageReductionPercent = 85
		end
		local armorPlayer = thing:getTotalArmor()
		local attackPower = thing:getCharacterType()
		description = string.format("%s\nAttack: %d", description, attackPower)
		description = string.format("%s\nPhysical Defense: %d | %s%%", description, thing:getPhysicalDefense(), thing:getPhysicalDefensePercent())
		description = string.format("%s\nMagic Defense: %d | %s%%", description, thing:getMagicDefense(), thing:getMagicDefensePercent())
		description = string.format("%s\nHealth: %d\nMana: %d", description, thing:getMaxHealth(), thing:getMaxMana())
		description = string.format("%s\nSpeed: %s", description, thing:getSpeed())
	end
	if thing:isMonster() and thing:getSkull() < 100 then
		--	description = string.format("%s\nCreatureID: %d", description, thing:getId())
	--	description = string.format("%s\nStrongbox : %s", description, thing:getStorageValue(PlayerStorage.strongBoxMonsterBoss))
		if thing:getMonsterLevel() >= 105 then
			description = string.format("%s\nMonster Tier: %d", description, getKeyTierByMonsterLevel(thing:getMonsterLevel()))
		end
		description = string.format("%s\nMonster Level: %d", description, thing:getMonsterLevel())
		description = string.format("%s\nItems: %s", description, thing:getType():items())
		local str = "%s\nHealth: %s / %s"
		if thing:isPlayer() and thing:getMaxMana() > 0 then
			str = string.format("%s, Mana: %d / %d", str, shortNumbers(thing:getMana(), 2),
				shortNumbers(thing:getMaxMana(), 2))
		end
		description = string.format(str, description, shortNumbers(thing:getHealth(), 2), shortNumbers(thing:getMaxHealth(), 2)) .. ""

			local monsterLevel = thing:getMonsterLevel()
			local mType = thing:getType()
			local monsterGold = goldFormula(monsterLevel)
			local monsterExp = expFormula(monsterLevel)
			local physical_defense = 15 + (thing:getMonsterLevel() * 1) --MONSTER_CONFIG[thing:getType():tier()].physical_defense
			local magic_defense = 15 + (thing:getMonsterLevel() * 1) --MONSTER_CONFIG[thing:getType():tier()].magic_defense
			description = string.format("%s\nDamage: %d", description, damageFormula(monsterLevel))
			description = string.format("%s\nHealth: %d", description, healthFormula(monsterLevel))
			description = string.format("%s\nPhysical Defense: %d | %s%%", description, physical_defense, math.ceil((physical_defense / (100 + physical_defense)) * 100))
			description = string.format("%s\nMagic Defense: %d | %s%%", description, magic_defense, math.ceil((magic_defense / (100 + magic_defense)) * 100))

		local monsterLevel = thing:getMonsterLevel()
		local EXPO = 0

		--------EXP BOOST SHOP--------------------
		if self:getBuff(BUFF_EXP_BOOST) then
			EXPO = EXPO + 20
		end
		--------EXP SCROLL--------------------
		if self:getBuff(BUFF_EXP_SCROLL) then
			EXPO = EXPO + 30
		end
		--------EXP BOOST DAILY--------------------
		if self:getBuff(BUFF_EXP_DAILY) then
			EXPO = EXPO + 30
		end
		if self:getBuff(MONSTER_SOUL_EXP) then
			EXPO = EXPO + 25
		end
		if getGlobalBuff(BUFF_GLOBAL_EXP) then
			EXPO = EXPO + 20
		end

		monsterExp = monsterExp + ((monsterExp * EXPO) / 100)
  		if self:getSkull() == 7 then
			monsterExp = monsterExp * affixes[1].lootChance
		elseif self:getSkull() == 8 then
			monsterExp = monsterExp * affixes[2].lootChance
		end
		description = string.format("%s\nExp: %s", description, math.ceil(monsterExp))


		local globalGold = 1
		if getGlobalBuff(BUFF_GLOBAL_GOLD) then
			globalGold = globalGold + 0.2 -- 1.2
		end
		if self:hasBuff(SELF_GOLD_BOOST) then
			globalGold = globalGold + 0.2 -- 1.2
		end
		if self:hasBuff(MONSTER_SOUL_GOLD) then
			globalGold = globalGold + 0.2 -- 0.2
		end
		monsterGold = math.ceil(monsterGold * globalGold)
		description = string.format("%s\nGold: %s", description, math.ceil(monsterGold))

		if thing:getStorageValue(PlayerStorage.keyTier) >= 1 then
			description = string.format("%s\nKey Tier: %s", description, thing:getStorageValue(PlayerStorage.keyTier))
		end
		description = string.format("%s\nSpeed: %s", description, thing:getSpeed())

		eliteAffix_name = {
			[1] = "Elite",
			[2] = "Champion",
		}

		eliteAffix_desc = {
			[1] = "Health +50%, Damage +15%, Gold, EXP and Loot Chance + 20%, spawns in a pack of 3",
			[2] = "Health x2.5, Damage x2, Gold, EXP and Loot Chance x4",
		}
		local skull = thing:getSkull()
		local skullPlus = thing:getSkull() - 6
		local affixName = eliteAffix_name[skullPlus]
		local affixDesc = eliteAffix_desc[skullPlus]
		if skull >= 7 and affixName and affixDesc then
			description = string.format("%s\nBoost: %s\n%s", description, affixName, affixDesc)
		end
		local elementResist = MonsterType(thing:getName()):getElementList()
		if elementResist == nil then
			elementResist = 0
		end
		local odpornosci = elementResist[ELEMENT_ROW[2]]
		if odpornosci == nil then
			odpornosci = 0
		end
	end
	self:sendTextMessage(MESSAGE_INFO_DESCR, description)
end

function Player:onLookInBattleList(creature, distance)
	local description = "You see " .. creature:getDescription(distance)
	if self:getGroup():getAccess() then
		local str = "%s\nHealth: %d / %d"
		if creature:isPlayer() and creature:getMaxMana() > 0 then
			str = string.format("%s, Mana: %d / %d", str, creature:getMana(), creature:getMaxMana())
		end
		description = string.format(str, description, creature:getHealth(), creature:getMaxHealth()) .. "."

		local position = creature:getPosition()
		description = string.format("%s\nPosition: %d, %d, %d", description, position.x, position.y, position.z)

		if creature:isPlayer() then
			local client = thing:getClient()
			description = string.format("%s\nIP: %s PING: %i FPS: %i.", description,
				Game.convertIpToString(thing:getIp()), client.ping, client.fps)
		end
	end
	self:sendTextMessage(MESSAGE_INFO_DESCR, description)
end

function Player:onLookInTrade(partner, item, distance)
	self:sendTextMessage(MESSAGE_INFO_DESCR, "You see " .. item:getDescription(distance))
end

function Player:onLookInShop(itemType, count)
	return true
end

function Player:disableSpell(spell, target)
	if not target or not spell then return end
	SPELL_CACHE[target:getRealUID()] = nil
	local realUID = target:getRealUID()
	if spell then
		local playerId = self:getId()
		addEvent(function()
			local item = Game.getRealUniqueItem(realUID)
			if not item then return end
			item:applySupportSpells(spell:getConfig(), playerId)
		end, 100)

		if spell.disable then
			spell.disable(self, target)
		end
	end
end

function Player:checkSpellMove(item, fromCylinder, toCylinder, toPosition, fromPosition)
	if TOTALCOUNT_SUPPORTS[item:getSpellName()] then
		for i = CONST_SLOT_SPELL1, CONST_SLOT_SPELL4 do
			local spellToClear = self:getSlotItem(i)
			if spellToClear then
				local SPELL = SPELLS[spellToClear:getSpellName()]
				if SPELL then
					self:disableSpell(SPELL, item)
				end
			end
		end
	end


	if fromCylinder and not fromCylinder:isTile() then
  	if fromCylinder:isCreature() then
    	local SPELL = SPELLS[item:getSpellName()]
			if SPELL then
    		self:disableSpell(SPELL, item)
			end

			local isSupport = FROM_SUPPORT_TO_SPELL[fromPosition.y]
			if isSupport then
				local itemSlot = self:getSlotItem(isSupport)
				if itemSlot then
					local SPELL = SPELLS[itemSlot:getSpellName()]
					if SPELL then
						self:disableSpell(SPELL, itemSlot)
					end
				end
			end
  	else
    	local SPELL = SPELLS[fromCylinder:getSpellName()]
			if SPELL then
				self:disableSpell(SPELL, fromCylinder)
			end
  	end
	end

	if toCylinder and not toCylinder:isTile() then
  	if toCylinder:isCreature() then
			local isSupport = FROM_SUPPORT_TO_SPELL[toPosition.y]
			if isSupport then
				local itemSlot = self:getSlotItem(isSupport)
				if itemSlot then
					local SPELL = SPELLS[itemSlot:getSpellName()]
					if SPELL then
						self:disableSpell(SPELL, itemSlot)
					end
				end
			end

			if item and item:getSpellName() then
				for i = 1, 4 do
					local itemSlot = self:getSlotItem(11+i)
					local slot = 11+i
					if itemSlot then
						if itemSlot ~= item and itemSlot:getSpellName() == item:getSpellName() then
							self:sendTooltipMessage("You can't equip the same spell in multiple slots.")
							return false
						end
					end
				end
			end

    	local spellName = item and item:getSpellName()
			if spellName then
				local SPELL = SPELLS[spellName]
				if SPELL then
					self:disableSpell(SPELL, item)
				end
			end
			local oldSpell = self:getItem(toPosition) and self:getItem(toPosition):getSpellName()
			if oldSpell then
				local SPELL = SPELLS[oldSpell]
				if SPELL then
					self:disableSpell(SPELL, self:getItem(toPosition))
				end
			end
  	else
    	local SPELL = SPELLS[toCylinder:getSpellName()]
			if SPELL then
				self:disableSpell(SPELL, toCylinder)
			end
  	end
	end

	return true
end

function Player:updateRelictWeight()
    local relictBox = self:getSlotItem(CONST_SLOT_RELICT_BOX)
    if relictBox then
        self:sendExtendedOpcode(ExtendedOPCodes.CODE_RELICTBOX, json.encode({relictBox:getCustomAttribute("usedWeight") or 0, relictBox:getCustomAttribute("maxWeight") or 0}))
    end
end

function Player:setRelictBoxWeight(value)
	local relictBox = self:getSlotItem(CONST_SLOT_RELICT_BOX)
	if not relictBox then
		print("setRelictBoxWeight | can't find relict box.")
		return
	end

	relictBox:setCustomAttribute("maxWeight", value)
	self:updateRelictWeight()
end

function Player:addRelictBoxWeight(value)
	local relictBox = self:getSlotItem(CONST_SLOT_RELICT_BOX)
	if not relictBox then
		print("addWeight | can't find relict box.")
		return
	end

	local maxWeight = relictBox:getCustomAttribute("maxWeight") or 0
	relictBox:setCustomAttribute("maxWeight", maxWeight + value)
	self:updateRelictWeight()
end

function Player:equipRelictItem(item, equip)
	local itemId = item:getId()
	local rarity = item:getRarityId() or 1
	local relictData = BOSS_DROPS_BY_ID[itemId]
	if not relictData then
		self:sendTooltipMessage("Something went wrong, can't find relict data")
		return
	end

	if rarity < 1 then
		rarity = 1
	elseif rarity > 4 then
		rarity = 4
	end

	local relictBox = self:getSlotItem(CONST_SLOT_RELICT_BOX)
	if not relictBox then
		self:sendTooltipMessage("Something went wrong, can't find relict box")
		return
	end

	local usedWeight = relictBox:getCustomAttribute("usedWeight")
	local maxWeight = relictBox:getCustomAttribute("maxWeight")
	local newWeight

	if not maxWeight then
		relictBox:setCustomAttribute("maxWeight", 30)
		relictBox:setCustomAttribute("usedWeight", 0)
		usedWeight = 0
	end

	if equip then
		newWeight = usedWeight + relictData.weight[rarity]
		self:addPlayerModifiersFromItem(item, CONST_SLOT_RELICT_BOX)
	else
		newWeight = usedWeight - relictData.weight[rarity]
		if newWeight < 0 then
			newWeight = 0
		end
		removeOldModifiers(item, self, item:getRealUID())
	end

	relictBox:setCustomAttribute("usedWeight", newWeight)
	local cid = self:getId()
	if PLAYERS_COLLECTION_EVENTS[cid] then
		stopEvent(PLAYERS_COLLECTION_EVENTS[cid])
	end

	PLAYERS_COLLECTION_EVENTS[cid] = addEvent(function()
		PLAYERS_COLLECTION_EVENTS[cid] = nil
		local player = Player(cid)
		if player and not player:isRemoved() then
			player:setCollectionInfo()
		end
	end, 100)
	self:sendExtendedOpcode(ExtendedOPCodes.CODE_RELICTBOX, json.encode({newWeight, maxWeight}))
end

function Player:checkRelictBeforeEquip(item, equip)
	local itemId = item:getId()
	local rarity = item:getRarityId() or 1
	local relictData = BOSS_DROPS_BY_ID[itemId]
	if not relictData then
		self:sendTooltipMessage("Something went wrong, can't find relict data")
		return false
	end
	--[[
	local level = self:getLevel()
	local itemReq = item:getItemLevel()
	if itemReq and equip then
		itemReq = itemReq - 10
		if level < itemReq then
			self:sendTooltipMessage("Item requires a " .. itemReq .. " level or higher.")
			return false
		end
	end
	--]]

	local relictBox = self:getSlotItem(CONST_SLOT_RELICT_BOX)
	if not relictBox then
		self:sendTooltipMessage("Something went wrong, can't find relict box")
		return false
	end

	if equip then
		-- check if is slot empty
		local freeSpaces = relictBox:getEmptySlots(true)
		if freeSpaces <= 0 then
			self:sendTooltipMessage("No free slots in relict box")
			return false
		end
		--LIMIT 2 RELICTS WITH SAME ID
		local sameIdCount = 0
		for i = 0, relictBox:getSize() - 1 do
			local boxItem = relictBox:getItem(i)
			if boxItem and boxItem:getId() == itemId then
				sameIdCount = sameIdCount + 1
				if sameIdCount >= 3 then
					self:sendTooltipMessage("You can equip only 3 relics of the same type.")
					return false
				end
			end
		end
		-- BLOCK ONLY ONE OF SPECIAL RELICTS (38736, 38732, 38733, 38693)
		local uniqueRelicts = {
			[38601] = true,
			[38593] = true,
			[38562] = true,
			[38566] = true,
		}

		if uniqueRelicts[itemId] then
			for i = 0, relictBox:getSize() - 1 do
				local boxItem = relictBox:getItem(i)
				if boxItem and uniqueRelicts[boxItem:getId()] then
					self:sendTooltipMessage("You can equip only one UNIQUE of these relics.")
					return false
				end
			end
		end
		-- BLOCK ONLY ONE OF SPECIAL RELICTS (38736, 38732, 38733)
		local exclusiveRelicts = {
			[38736] = true,
			[38732] = true,
			[38733] = true,
			[38693] = true,
		}

		if exclusiveRelicts[itemId] then
			for i = 0, relictBox:getSize() - 1 do
				local boxItem = relictBox:getItem(i)
				if boxItem and exclusiveRelicts[boxItem:getId()] then
					self:sendTooltipMessage("You can equip only one EVENT of these relics.")
					return false
				end
			end
		end

		-- BLOCK: only ONE item with ID 38459
		if itemId == 38459 then
			for i = 0, relictBox:getSize() - 1 do
				local boxItem = relictBox:getItem(i)
				if boxItem and boxItem:getId() == 38459 then
					self:sendTooltipMessage("You can equip only one BOSS relic of this type.")
					return false
				end
			end
		end
	end

	if rarity < 1 then
		rarity = 1
	elseif rarity > 4 then
		rarity = 4
	end

	local usedWeight = relictBox:getCustomAttribute("usedWeight")
	local maxWeight = relictBox:getCustomAttribute("maxWeight")
	local newWeight

	if not maxWeight then
		relictBox:setCustomAttribute("maxWeight", 30)
		relictBox:setCustomAttribute("usedWeight", 0)
		usedWeight = 0
	end

	if equip then
		newWeight = usedWeight + relictData.weight[rarity]
		if newWeight > maxWeight then
			self:sendTooltipMessage("Max weight reached, you need " .. newWeight - maxWeight .. " more capacity to equip that relict")
			return false
		end
	end

	return true
end

function Player:onMoveItem(item, count, fromPosition, toPosition, fromCylinder, toCylinder)
	if self:getGroup():getId() < 3 then
		local isStartingSpell = (item:getCustomAttribute("startingSpell") == 1)
		local isFromSpellSlot = (fromPosition.x == CONTAINER_POSITION and fromPosition.y >= CONST_SLOT_SPELL1 and fromPosition.y <= CONST_SLOT_SPELL4)
		if isStartingSpell or (isFromSpellSlot and item:getSpellName() ~= "") then
			self:sendTooltipMessage("You cannot move champion spells.")
			return false
		end

		if toPosition.x == CONTAINER_POSITION and toPosition.y >= CONST_SLOT_SPELL1 and toPosition.y <= CONST_SLOT_SPELL4 then
			local targetSlotItem = self:getSlotItem(toPosition.y)
			if targetSlotItem and (targetSlotItem:getCustomAttribute("startingSpell") == 1 or targetSlotItem:getSpellName() ~= "") then
				self:sendTooltipMessage("You cannot replace champion spells.")
				return false
			end
		end
	end

	if toCylinder and self == toCylinder then
		local antiSpamCount = self:getStorageValue(52391)
		local timeBetween = os.time() - self:getStorageValue(52390)
		if antiSpamCount > 3 then
			if timeBetween < 5 then
				self:sendTooltipMessage("Slow Down! You have to wait ".. 5 - timeBetween .. " seconds before next try.")
				return false
			else
				self:setStorageValue(52391, 0)
			end
		else
			if timeBetween < 1 then
				self:setStorageValue(52391, antiSpamCount+1)
			else
				self:setStorageValue(52391, 0)
			end
		end
		self:setStorageValue(52390, os.time())
	end

	if fromCylinder and fromCylinder ~= self and toCylinder and toCylinder == self then
		local topParent = item:getTopParent()
		if topParent and topParent ~= self and toPosition.y <= CONST_SLOT_SUPPORT4_4  and toPosition.y ~= CONST_SLOT_BACKPACK then
			local itemSlot = self:getSlotItem(toPosition.y)
			if itemSlot and itemSlot:isLocked() then
				return false
			end
		end
	end

	if toPosition.y == CONST_SLOT_FORGE then
		return self:onItemMoveCrystal(item, slot, equip, fromPosition)
	end

	if toPosition.y <= CONST_SLOT_SUPPORT4_4 and toPosition.y ~= CONST_SLOT_BACKPACK and toPosition.y ~= CONST_SLOT_FORGE then
		self:updateInspect()
		local level = self:getLevel()
		local itemReq = item:getItemLevel()
		if item:getSpellName() ~= "" then
			itemReq = item:getCustomAttribute("level") or 0
			itemReq = math.min(itemReq, 100)
		end
		if itemReq then
			itemReq = itemReq - 10
			if level < itemReq then
				self:sendTextMessage(MESSAGE_INFO_DESCR, "Item requires a " .. itemReq .. " level or higher.")
				return false
			end
		end

		-- Block equipping more than 1 pair of boots across any equipment slots
		local itType = item:getType()
		local isBoots = itType and (bit.band(itType:getSlotPosition(), SLOTP_FEET) ~= 0 or formatItemType(itType, item) == 13)
		if isBoots then
			for slot = CONST_SLOT_HEAD, CONST_SLOT_POTION2 do
				if slot ~= toPosition.y and slot ~= CONST_SLOT_BACKPACK then
					local equippedItem = self:getSlotItem(slot)
					if equippedItem and (item:getRealUID() == 0 or equippedItem:getRealUID() ~= item:getRealUID()) then
						local eqType = equippedItem:getType()
						if eqType and (bit.band(eqType:getSlotPosition(), SLOTP_FEET) ~= 0 or formatItemType(eqType, equippedItem) == 13) then
							self:sendTooltipMessage("You can only equip one pair of boots.")
							return false
						end
					end
				end
			end
		end

		-- Block equipping duplicate Legendary items (Rarity 4)
		local itemRarity = item:getRarityId()
		if itemRarity == 4 then
			local itemId = item:getId()
			local itemName = item:getName()
			local itemUid = item:getRealUID()
			for slot = CONST_SLOT_HEAD, CONST_SLOT_RING2 do
				if slot ~= toPosition.y and slot ~= CONST_SLOT_BACKPACK then
					local equippedItem = self:getSlotItem(slot)
					if equippedItem and (itemUid == 0 or equippedItem:getRealUID() ~= itemUid) then
						if equippedItem:getRarityId() == 4 and (equippedItem:getId() == itemId or equippedItem:getName() == itemName) then
							self:sendTooltipMessage("You can only equip one " .. itemName .. " (Legendary).")
							return false
						end
					end
				end
			end
		end
	end

	if toCylinder and toCylinder:isItem() and toCylinder:isRelictBox() then
		if fromCylinder ~= toCylinder and item:getLootIndex() == 4 then
			return self:checkRelictBeforeEquip(item, true)
		end
	elseif fromCylinder and fromCylinder:isItem() and fromCylinder:isRelictBox() then
		return self:checkRelictBeforeEquip(item, false)
	end

	if not self:checkSpellMove(item, fromCylinder, toCylinder, toPosition, fromPosition) then
		return false
	end

	if item:isLocked() and toCylinder:isTile() then
		self:sendTooltipMessage("This item is locked. Unlock it first before throwing it away.")
		return false
	end


	self:updateInspect()

	-- No move if item count > 20 items
	local tile = Tile(toPosition)
	if tile and tile:getItemCount() > 10 then
		self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
		return false
	end

	if item:getActionId() == CURSED_CHESTS_AID then
		return false
	end
	if item:getActionId() == 31000 then
		return false
	end
	if item:getActionId() == 7777 then
		return false
	end
	if item:getId() == 23782 then
		return false
	end --------------------------------------

	if toPosition.x ~= CONTAINER_POSITION then
		return true
	end


		if not self:getGroup():getAccess() then
			if toPosition.y <= CONST_SLOT_POTION2 and toPosition.y ~= CONST_SLOT_BACKPACK then
				local itemType, moveItem = ItemType(item:getId())
				local weaponType = itemType:getWeaponType()
				if formatItemType(itemType, item) == "Potion" or formatItemType(itemType, item) == "Flask" then
					if self:getLevel() < POTION_CONFIG[item:getId()].level then
						self:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You cannot equip this item. You need "..POTION_CONFIG[item:getId()].level.." or higher.")
						return false
					end
				end
			end
		end
		--[[
		if toPosition.y <= CONST_SLOT_POTION2 and toPosition.y ~= CONST_SLOT_BACKPACK then
			if toPosition.y ~= CONST_SLOT_GLOVES then
				self:sendTextMessage(MESSAGE_STATUS_SMALL, Game.getReturnMessage(RETURNVALUE_CONTAINERNOTENOUGHROOM))
				return false
			end
		end
		--]]

	if item:getTopParent() == self and bit.band(toPosition.y, 0x40) == 0 then
		local itemType, moveItem = ItemType(item:getId())
		self:updateInspect()
		if moveItem then
			local parent = item:getParent()
			if parent:isContainer() and parent:getSize() == parent:getCapacity() then
				self:sendTextMessage(MESSAGE_STATUS_SMALL, Game.getReturnMessage(RETURNVALUE_CONTAINERNOTENOUGHROOM))
				return false
			else
				self:updateInspect()
				return moveItem:moveTo(parent)
			end
		end
	end

	self:updateInspect()

	return us_onMoveItem(self, item, fromPosition, toPosition)
end

function Player:onItemMoved(item, count, fromPosition, toPosition, fromCylinder, toCylinder)
	if toCylinder and toCylinder:isItem() and toCylinder:isRelictBox() then
		if fromCylinder ~= toCylinder and item:getLootIndex() == 4 then
			return self:equipRelictItem(item, true)
		end
	elseif fromCylinder and fromCylinder:isItem() and fromCylinder:isRelictBox() then
		return self:equipRelictItem(item, false)
	end
end

local function hasPendingReport(name, targetName, reportType)
	local f = io.open(string.format("data/reports/players/%s-%s-%d.txt", name, targetName, reportType), "r")
	if f then
		io.close(f)
		return true
	else
		return false
	end
end

function Player:onReportRuleViolation(targetName, reportType, reportReason, comment, translation)
	local name = self:getName()
	if hasPendingReport(name, targetName, reportType) then
		self:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Your report is being processed.")
		return
	end

	local file = io.open(string.format("data/reports/players/%s-%s-%d.txt", name, targetName, reportType), "a")
	if not file then
		self:sendTextMessage(MESSAGE_EVENT_ADVANCE,
			"There was an error when processing your report, please contact a gamemaster.")
		return
	end

	io.output(file)
	io.write("------------------------------\n")
	io.write("Reported by: " .. name .. "\n")
	io.write("Target: " .. targetName .. "\n")
	io.write("Type: " .. reportType .. "\n")
	io.write("Reason: " .. reportReason .. "\n")
	io.write("Comment: " .. comment .. "\n")
	if reportType ~= REPORT_TYPE_BOT then
		io.write("Translation: " .. translation .. "\n")
	end
	io.write("------------------------------\n")
	io.close(file)
	self:sendTextMessage(
		MESSAGE_EVENT_ADVANCE,
		string.format(
			"Thank you for reporting %s. Your report will be processed by %s team as soon as possible.",
			targetName,
			configManager.getString(configKeys.SERVER_NAME)
		)
	)
	return
end

function Player:onReportBug(message, position, category)
	if self:getAccountType() == ACCOUNT_TYPE_NORMAL then
		return false
	end

	local name = self:getName()
	local file = io.open("data/reports/bugs/" .. name .. " report.txt", "a")

	if not file then
		self:sendTextMessage(MESSAGE_EVENT_DEFAULT,
			"There was an error when processing your report, please contact a gamemaster.")
		return true
	end

	io.output(file)
	io.write("------------------------------\n")
	io.write("Name: " .. name)
	if category == BUG_CATEGORY_MAP then
		io.write(" [Map position: " .. position.x .. ", " .. position.y .. ", " .. position.z .. "]")
	end
	local playerPosition = self:getPosition()
	io.write(" [Player Position: " .. playerPosition.x .. ", " .. playerPosition.y .. ", " .. playerPosition.z .. "]\n")
	io.write("Comment: " .. message .. "\n")
	io.close(file)

	self:sendTextMessage(MESSAGE_EVENT_DEFAULT,
		"Your report has been sent to " .. configManager.getString(configKeys.SERVER_NAME) .. ".")
	return true
end

playerLastTurn = playerLastTurn or {}
function Player:onTurn(direction)
	if not self:getGroup():getAccess() or self:getAccountType() < ACCOUNT_TYPE_GOD then
		return true
	end

	local lastTurn = playerLastTurn[self:getId()]
	if self:getDirection() ~= direction and (not lastTurn or os.time() - lastTurn > 1) then
		return true
	end

	playerLastTurn[self:getId()] = os.time()
	local pos = self:getPosition()
	pos:getNextPosition(direction)
	while not Tile(pos) and pos.z < 7 do
		pos.z = pos.z + 1
	end
	self:teleportTo(pos, true)
	return true
end

function Player:onTradeRequest(target, item)
	if self:getGroup():getId() < 3 then
		if item:getCustomAttribute("startingSpell") == 1 or item:getSpellName() ~= "" then
			self:sendTooltipMessage("You cannot trade champion spells.")
			return false
		end
	end
	return true
end

function Player:onTradeAccept(target, item, targetItem)
	if item:bindItem() == 0 and targetItem:bindItem() == 0 then
	else
		self:sendTextMessage(MESSAGE_STATUS_SMALL, "This item in binding for other account!")
		return false
	end
	self:save()
	target:save()
	return true
end

local soulCondition = Condition(CONDITION_SOUL, CONDITIONID_DEFAULT)
soulCondition:setTicks(4 * 60 * 1000)
soulCondition:setParameter(CONDITION_PARAM_SOULGAIN, 1)

function calculateExp(playerLevel, monsterLevel, baseExp)
	local levelDifference = playerLevel - monsterLevel

	if levelDifference <= 0 then
		return baseExp -- pełne doświadczenie, jeśli gracz ma poziom niższy lub równy potworowi
	else
		local reductionFactor = math.max(0.1, 1 - (levelDifference * 0.025)) -- Redukcja EXP o 5% za każdy poziom przewagi
		return baseExp * reductionFactor
	end
end

function Player:onGainExperience(source, gainPrecent, rawExp)
	if not source or source:isPlayer() then
		return gainPrecent
	end

	local exp = 0
	if source:setStorageValue(PlayerStorage.endlessBoss) ~= nil then
		return 0
	end 

	local EXPO = 0
	--[[
	if source:getMonsterLevel() then
		local playerLevel = self:getLevel()
		local monsterLevel = source:getMonsterLevel()
		exp = calculateExp(playerLevel, monsterLevel, expFormula(monsterLevel)) -- expFormula(monsterLevel)
	else
		exp = 1
	end
	--]]
	exp = expFormula(source:getMonsterLevel())
	exp = math.ceil(exp * (gainPrecent/100))
	--------EXP BOOST SHOP--------------------
	if self:getBuff(BUFF_EXP_BOOST) then
		EXPO = EXPO + 20
	end
	--------EXP SCROLL--------------------
	if self:getBuff(BUFF_EXP_SCROLL) then
		EXPO = EXPO + 30
	end
	--------EXP BOOST DAILY--------------------
	if self:getBuff(BUFF_EXP_DAILY) then
		EXPO = EXPO + 30
	end
	if self:getBuff(MONSTER_SOUL_EXP) then
		EXPO = EXPO + 25
	end
	if getGlobalBuff(BUFF_GLOBAL_EXP) then
		EXPO = EXPO + 20
	end
	if source:getSkull() == 7 then
		exp = exp * affixes[1].lootChance
	elseif source:getSkull() == 8 then
		exp = exp * affixes[2].lootChance
	end


	local party = self:getParty()
  if not party or (party and not party:isSharedExperienceEnabled()) then
--		if colleftInfo[self:getId()].attributesItems[10] then
--			EXPO = EXPO + colleftInfo[self:getId()].attributesItems[10].value
--		end
	elseif (party and party:isSharedExperienceEnabled()) then
		local leader = party:getLeader()
		EXPO = EXPO - ((#party:getMembers() + 1) * 7.5)
		if leader then
--			if colleftInfo[leader:getId()].attributesItems[10] then
--				EXPO = EXPO + colleftInfo[leader:getId()].attributesItems[10].value
--			end
			for _, member in ipairs(party:getMembers()) do
--				if colleftInfo[member:getId()].attributesItems[10] then
--					EXPO = EXPO + colleftInfo[member:getId()].attributesItems[10].value
--				end
			end
		end
	end

	exp = exp + ((exp * EXPO) / 100)
	exp = math.ceil(exp)
	local party = self:getParty()
	if not party or (party and not party:isSharedExperienceEnabled()) then
		sendExp(self, exp)
	--	if self:getLevel() >= 100 then
	--		self:addExpToSpells(exp * 2)
	--	else
	--		self:addExpToSpells(exp)
	--	end
	end

	return exp
end

function expForLevelSpell(level)
  level = level + 1
  local baseExp = 50
  if level >= 50 then
		baseExp = baseExp + (level - 50)
  end

  local exp = ((baseExp * level^3) / 3 - 100 * level^2 + (850 * level) / 3 - 200) * 2

  if level >= 85 then
		local extraFactor = 1 + (level - 85) * 0.1
		exp = exp * extraFactor
  end
  return math.floor(exp/2)
end

function correctSpellExpAndRarity(spell, level)
	local rarity = 0
	if level >= 60 then
		rarity = LEGENDARY
	elseif level >= 40 then
		rarity = EPIC
	elseif level >= 20 then
		rarity = RARE
	elseif level >= 5 then
		rarity = 1
	end

	spell:setRarity(rarity)
	spell:updateSelf()
end

function levelUpSpell(spell, level, currentExp, slot, player)
	local expForNextLevel = expForLevelSpell(level + 1)
	if currentExp >= expForNextLevel then
		level = level + 1
		local uid = spell:getRealUID()
		if SPELL_CACHE[uid] and SPELL_CACHE[uid].cast then
			SPELL_CACHE[uid] = nil
			spell:applySupportSpells(SPELLS[spell:getSpellName()].getConfig())
		else
			SPELL_CACHE[uid] = nil
		end

		if rarity_change_on_level[level] then
			if spell:getRarityId() ~= 5 then
				spell:setRarity(rarity_change_on_level[level])
			end
			spell:updateSelf()
		end
		return levelUpSpell(spell, level, currentExp)
	end
  spell:setCustomAttribute("level", level)
  spell:setCustomAttribute("exp", currentExp)
end

function Item:addExpToSpell(exp, tier)
  if not self then return false end
	if tier < 0 then 
		tier = 0
	end

	local maxLevel
	local slotPosition = itemType:getSlotPosition() - SLOTP_LEFT - SLOTP_RIGHT
	if slotPosition == SLOTP_SUPPORT1_1 then
		maxLevel = 100 + (tier * 1)
		maxLevel = math.min(maxLevel, 200)
	else
		maxLevel = 100 + (tier * 2)
		maxLevel = math.min(maxLevel, 300)
	end

  local level = self:getCustomAttribute("level") or 1
  if level >= maxLevel then
    return false
  end

  local currentExp = self:getCustomAttribute("exp") or 0
  currentExp = currentExp + exp
  levelUpSpell(self, level, currentExp)
  return true
end

function Player:addExpToSpells(exp)
	local tier = self:getDungeonTier()
	if tier < 0 then
		tier = 0
	end
	local maxLevel = 100 + (tier * 2)
	maxLevel = math.min(maxLevel, 300)

	local maxLevelSupports = 100 + (tier * 1)
	maxLevelSupports = math.min(maxLevelSupports, 200)

  for slot = CONST_SLOT_SPELL1, CONST_SLOT_SPELL4 do
    local spell = self:getSlotItem(slot)
    if spell then
      local level = spell:getCustomAttribute("level") or 1
			if level < maxLevel then
				local currentExp = spell:getCustomAttribute("exp") or 0
				currentExp = currentExp + exp
				levelUpSpell(spell, level, currentExp, slot, self)
			end

			-- exp for supports
			local slotsToCheck = spell:getRarityId()
			for i = 1, slotsToCheck do
				local supportSlot = SUPPORT_SLOTS[slot][i]
				local support = self:getSlotItem(supportSlot)
				if support then
					local level = support:getCustomAttribute("level") or 1
					if level < maxLevelSupports then
						local currentExp = support:getCustomAttribute("exp") or 0
						currentExp = currentExp + exp
						levelUpSpell(support, level, currentExp, i, self)
					end
				end
			end
		end
  end
end

function Player:onLoseExperience(exp)
	return exp
end

function Player:onGainSkillTries(skill, tries)
	if APPLY_SKILL_MULTIPLIER == false then
		return tries
	end

	if skill == SKILL_MAGLEVEL then -- MASTERY
		tries = tries * configManager.getNumber(configKeys.RATE_MAGIC)
		return tries
	end
	tries = tries * configManager.getNumber(configKeys.RATE_SKILL) -- SKILLS
	return tries
end

function Player:onInventoryUpdate(item, slot, equip)
	checkItemBeforeEquip(self, item, slot, equip)
	if slot == CONST_SLOT_FORGE then
		self:onItemMoveCrystal(item, slot, equip)
	elseif slot <= CONST_SLOT_POTION2 then
		local cid = self:getId()
		if PLAYERS_COLLECTION_EVENTS[cid] then
			stopEvent(PLAYERS_COLLECTION_EVENTS[cid])
		end

		PLAYERS_COLLECTION_EVENTS[cid] = addEvent(function()
			PLAYERS_COLLECTION_EVENTS[cid] = nil
			local player = Player(cid)
			if player and not player:isRemoved() then
				player:setCollectionInfo()
			end
		end, 100)
	end
end

function Player:onBossAppear(boss)
end

function Player:onTileWidgetAppear(pos, id, data)
	self:sendExtendedOpcode(
		ExtendedOPCodes.CODE_TILEWIDGET,
		json.encode(
			{
				action = "createwidget",
				data = {
					pos = pos,
					id = id,
					msg = data
				}
			}
		)
	)
end

function Player:onMarketOfferAdd(marketId, uid)
	-- if uid and uid > 0 then
	-- 	marketFillAttributeTable(marketId, uid)
	-- end
	self:sendExtendedOpcode(ExtendedOPCodes.CODE_MARKET, json.encode({3, "Item was successfully added to the market."}))
end

function Player:onBossDisappear(boss)
	self:sendExtendedOpcode(ExtendedOPCodes.CODE_BOSSBAR, json.encode({ action = "hide" }))
end

function Player:onQueueLeave(queue)
	self:sendExtendedOpcode(ExtendedOPCodes.CODE_DUNGEONS, json.encode({ action = "queue", data = { joined = false } }))
	local dungeon = queue:getDungeon()
	local players = queue:getPlayers()
	if not players then
		return
	end

	local inQueue = queue:getPlayersNumber()
	for _, player in ipairs(players) do
		player:sendExtendedOpcode(
			ExtendedOPCodes.CODE_DUNGEONS,
			json.encode({ action = "queueUpdate",
				data = { id = dungeon:getId(), queue = inQueue, estimated = dungeon:getEstimatedQueueTime(player) } })
		)
		local party = player:getParty()
		if party then
			party:getLeader():sendExtendedOpcode(
				ExtendedOPCodes.CODE_DUNGEONS,
				json.encode({ action = "queueUpdate",
					data = { id = dungeon:getId(), queue = inQueue, estimated = dungeon:getEstimatedQueueTime(player) } })
			)
			local members = party:getMembers()
			for _, member in ipairs(members) do
				if member ~= player then
					member:sendExtendedOpcode(
						ExtendedOPCodes.CODE_DUNGEONS,
						json.encode({ action = "queueUpdate",
							data = { id = dungeon:getId(), queue = inQueue, estimated = dungeon:getEstimatedQueueTime(player) } })
					)
				end
			end
		end
	end
end

--			local monsterLoot = MonsterType(thing:getName()):getLoot()
--			descInfo = string.format("%s\n**Loot**", descInfo)
--			for i = 1, #monsterLoot do
--			local chance = ((monsterLoot[i].chance) / 1000) * configManager.getNumber(configKeys.RATE_LOOT)
--			if Game.isGlobalBuffActive(BUFF_GLOBAL_LOOT) then
--				chance = chance + (chance * 0.5)
--			end
--			if chance >= 100 then
--				chance = 100
--			end
--			local item = monsterLoot[i].itemId
--			local itemName = getItemName(item)
--			local count =  monsterLoot[i].maxCount
--			if Game.isGlobalBuffActive(BUFF_GLOBAL_GOLD) then
--				if monsterLoot[i].itemId == ITEM_CRYSTAL_COIN or monsterLoot[i].itemId == ITEM_PLATINUM_COIN or monsterLoot[i].itemId == ITEM_GOLD_COIN then
--					count = count * 2
--				end
--			end
--				descInfo = string.format("%s\n%s: Chance: %s%%, Count: %s", descInfo, itemName, chance, count)
--			end

function Player:refreshBalance()
	local balance = {
		getPlayerMoney(self)
	}
	self:sendExtendedOpcode(ExtendedOPCodes.CODE_PETS, json.encode({ balance = balance }))
end


function Player:getBossRelict()
	local reclitBox = self:getSlotItem(CONST_SLOT_RELICT_BOX)
	if not reclitBox then
		return nil
	end

	return reclitBox:getItemById(RELICT_UBER_BOSS)
end