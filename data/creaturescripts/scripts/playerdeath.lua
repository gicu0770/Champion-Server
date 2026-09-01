local deathListEnabled = true
local maxDeathRecords = 5
-- Edited wypadanie przedmiotów
function onDeath(player, corpse, killer, mostDamageKiller, lastHitUnjustified, mostDamageUnjustified)
	local playerId = player:getId()
	if nextUseStaminaTime[playerId] then
		nextUseStaminaTime[playerId] = nil
	end

	player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You are dead.")
	if not deathListEnabled then
		return
	end
	local currentLevel = player:getLevel()
	local baseLevelsToLose = 1
	if currentLevel >= 41 then
		baseLevelsToLose = 3
	elseif currentLevel >= 21 then
		baseLevelsToLose = 2
	else
		baseLevelsToLose = 1
	end

	-- Check BLESS_ULTRA protection
	local hasBlessUltra = false
	local buffCheck = player:getBuff(BLESS_ULTRA)
	if buffCheck then
		hasBlessUltra = true
		if buffCheck.stacks and buffCheck.stacks > 1 then
			player:setBuffStacks(BLESS_ULTRA, buffCheck.stacks - 1)
		else
			player:removeBuff(BLESS_ULTRA)
		end
		player:sendTextMessage(MESSAGE_INFO_DESCR, "Your Bless Ultra protected you from 1 level loss!")
	end

	local levelsToLose = baseLevelsToLose
	if hasBlessUltra then
		levelsToLose = math.max(0, levelsToLose - 1)
	end

	local targetLevel = math.max(1, currentLevel - levelsToLose)
	local targetExp = getExpForLevel(targetLevel)
	local currentExp = player:getExperience()
	local expToLose = currentExp - targetExp

	if expToLose > 0 then
		player:removeExperience(expToLose, true, true)
	end
	player:stopAllDots()
	player:addBuff(RESTART_IMMORTAL, 5000)
	player:addDeath();

	local byPlayer = 0
	local killerName
	if killer then
		if killer:isPlayer() then
			byPlayer = 1
		else
			local master = killer:getMaster()
			if master and master ~= killer and master:isPlayer() then
				killer = master
				byPlayer = 1
			end
		end
		killerName = killer:getName()
	else
		killerName = "field item"
	end

	local byPlayerMostDamage = 0
	local mostDamageKillerName
	if mostDamageKiller then
		if mostDamageKiller:isPlayer() then
			byPlayerMostDamage = 1
		else
			local master = mostDamageKiller:getMaster()
			if master and master ~= mostDamageKiller and master:isPlayer() then
				mostDamageKiller = master
				byPlayerMostDamage = 1
			end
		end
		mostDamageName = mostDamageKiller:getName()
	else
		mostDamageName = "field item"
	end

	local maxDeathRecords = 20

	local lostItems = {}

	if not player:hasFlag(PlayerFlag_NotGenerateLoot) then
		local SLOT_NAMES = {
			[CONST_SLOT_HEAD] = "Helmet",
			[CONST_SLOT_NECKLACE] = "Amulet",
			[CONST_SLOT_BACKPACK] = "Backpack",
			[CONST_SLOT_ARMOR] = "Armor",
			[CONST_SLOT_RIGHT] = "Right Hand",
			[CONST_SLOT_LEFT] = "Left Hand",
			[CONST_SLOT_LEGS] = "Legs",
			[CONST_SLOT_FEET] = "Boots",
			[CONST_SLOT_RING] = "Ring",
			[CONST_SLOT_RING2] = "Ring 2",
			[CONST_SLOT_GLOVES] = "Gloves",
		}

		-- 1. Utrata zawartości plecaka (dla każdego typu śmierci: PvP oraz PvM - całość trafia do corpse)
		local backpack = player:getSlotItem(CONST_SLOT_BACKPACK)
		if backpack and backpack:isContainer() then
			local backpackItems = backpack:getItems(false)
			for _, item in ipairs(backpackItems) do
				local itId = item:getId()
				local itClientId = item:getType():getClientId()
				local itCount = item:getCount()
				local itName = item:getName()
				table.insert(lostItems, {
					id = itId,
					clientId = itClientId,
					count = itCount,
					name = itName,
					source = "backpack",
					slotName = "Backpack",
					status = "corpse"
				})
				if corpse and corpse:isContainer() then
					if not item:moveTo(corpse) then
						item:moveTo(corpse:getPosition())
					end
				elseif corpse then
					item:moveTo(corpse:getPosition())
				end
			end
		end

		-- 2. Utrata przedmiotów ze slotów ekwipunku: WYŁĄCZNIE przy śmierci PvP (od gracza)
		if byPlayer == 1 then
			local DROPPABLE_SLOTS = {
				CONST_SLOT_HEAD,      -- Hełm
				CONST_SLOT_ARMOR,     -- Zbroja
				CONST_SLOT_LEGS,      -- Spodnie
				CONST_SLOT_FEET,      -- Buty
				CONST_SLOT_NECKLACE,  -- Amulet
				CONST_SLOT_RING,      -- Pierścień 1
				CONST_SLOT_RING2,     -- Pierścień 2
				CONST_SLOT_GLOVES,    -- Rękawice
			}

			local equipped = {}
			for _, slot in ipairs(DROPPABLE_SLOTS) do
				local item = player:getSlotItem(slot)
				if item then
					table.insert(equipped, { item = item, slot = slot })
				end
			end

			-- Losowe tasowanie ubranych przedmiotów
			for i = #equipped, 2, -1 do
				local j = math.random(i)
				equipped[i], equipped[j] = equipped[j], equipped[i]
			end

			local dropChances = { 100, 70, 40, 20 }
			local droppedItems = {}
			for i = 1, math.min(#equipped, #dropChances) do
				if math.random(1, 100) <= dropChances[i] then
					table.insert(droppedItems, equipped[i])
				end
			end

			-- 3. Przenoszenie lub niszczenie wylosowanych przedmiotów ze slotów
			local totalDropped = #droppedItems
			for i, dropData in ipairs(droppedItems) do
				local item = dropData.item
				local itId = item:getId()
				local itClientId = item:getType():getClientId()
				local itCount = item:getCount()
				local itName = item:getName()
				local slotName = SLOT_NAMES[dropData.slot] or "Slot"
				local isDestroyed = false

				-- Jeśli wypadnie więcej niż 1 przedmiot: przedmioty od 2. wzwyż mają 50% szans na zniszczenie
				if totalDropped > 1 and i > 1 and math.random(1, 100) <= 50 then
					isDestroyed = true
					item:remove()
				else
					if corpse and corpse:isContainer() then
						if not item:moveTo(corpse) then
							item:moveTo(corpse:getPosition())
						end
					elseif corpse then
						item:moveTo(corpse:getPosition())
					end
				end

				table.insert(lostItems, {
					id = itId,
					clientId = itClientId,
					count = itCount,
					name = itName,
					source = "slot",
					slotName = slotName,
					status = isDestroyed and "destroyed" or "corpse"
				})
			end
		end

		player:setCollectionInfo()
	end

	local playerGuid = player:getGuid()
	local lostItemsJson = json.encode(lostItems)
	db.query("INSERT INTO `player_deaths` (`player_id`, `time`, `level`, `killed_by`, `is_player`, `mostdamage_by`, `mostdamage_is_player`, `unjustified`, `mostdamage_unjustified`, `lost_items`) VALUES (" .. playerGuid .. ", " .. os.time() .. ", " .. player:getLevel() .. ", " .. db.escapeString(killerName) .. ", " .. byPlayer .. ", " .. db.escapeString(mostDamageName) .. ", " .. byPlayerMostDamage .. ", " .. (lastHitUnjustified and 1 or 0) .. ", " .. (mostDamageUnjustified and 1 or 0) .. ", " .. db.escapeString(lostItemsJson) .. ")")
	
	local resultId = db.storeQuery("SELECT `player_id` FROM `player_deaths` WHERE `player_id` = " .. playerGuid)
	local deathRecords = 0
	local tmpResultId = resultId
	while tmpResultId ~= false do
		tmpResultId = result.next(resultId)
		deathRecords = deathRecords + 1
	end

	if resultId ~= false then
		result.free(resultId)
	end

	local limit = deathRecords - maxDeathRecords
	if limit > 0 then
		db.asyncQuery("DELETE FROM `player_deaths` WHERE `player_id` = " .. playerGuid .. " ORDER BY `time` LIMIT " .. limit)
	end

	if byPlayer == 1 then
		local targetGuild = player:getGuild()
		targetGuild = targetGuild and targetGuild:getId() or 0
		if targetGuild ~= 0 then
			local killerGuild = killer:getGuild()
			killerGuild = killerGuild and killerGuild:getId() or 0
			if killerGuild ~= 0 and targetGuild ~= killerGuild and isInWar(playerId, killer:getId()) then
				local warId = false
				resultId = db.storeQuery("SELECT `id` FROM `guild_wars` WHERE `status` = 1 AND ((`guild1` = " .. killerGuild .. " AND `guild2` = " .. targetGuild .. ") OR (`guild1` = " .. targetGuild .. " AND `guild2` = " .. killerGuild .. "))")
				if resultId ~= false then
					warId = result.getNumber(resultId, "id")
					result.free(resultId)
				end

				if warId ~= false then
					db.asyncQuery("INSERT INTO `guildwar_kills` (`killer`, `target`, `killerguild`, `targetguild`, `time`, `warid`) VALUES (" .. db.escapeString(killerName) .. ", " .. db.escapeString(player:getName()) .. ", " .. killerGuild .. ", " .. targetGuild .. ", " .. os.time() .. ", " .. warId .. ")")
				end
			end
		end
	end
end
