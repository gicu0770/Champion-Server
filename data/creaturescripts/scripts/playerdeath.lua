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
	local level = player:getLevel()
	local lost = 0.20

	local buffsToCheck = { BLESS_ULTRA, BLESS_PLUS, BLESS }
	for i = 1, #buffsToCheck do
		local buffCheck = player:getBuff(buffsToCheck[i])
		if buffCheck then
			if buffsToCheck[i] == BLESS_ULTRA then
				lost = 0.02
			elseif buffsToCheck[i] == BLESS_PLUS then
				lost = 0.06
			elseif buffsToCheck[i] == BLESS then
				lost = 0.10
			end

			if buffCheck.stacks and buffCheck.stacks > 1 then
				player:setBuffStacks(buffsToCheck[i], buffCheck.stacks - 1)
			else
				player:removeBuff(buffsToCheck[i])
			end
			break
		end
	end

	local dif = (getExpForLevel(level) - getExpForLevel(level - 1)) * lost
	local currentExp = player:getExperience() - getExpForLevel(level)
	if currentExp < dif then
		dif = currentExp
	end
	player:removeExperience(dif, true, false)
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

	local playerGuid = player:getGuid()
	db.query("INSERT INTO `player_deaths` (`player_id`, `time`, `level`, `killed_by`, `is_player`, `mostdamage_by`, `mostdamage_is_player`, `unjustified`, `mostdamage_unjustified`) VALUES (" .. playerGuid .. ", " .. os.time() .. ", " .. player:getLevel() .. ", " .. db.escapeString(killerName) .. ", " .. byPlayer .. ", " .. db.escapeString(mostDamageName) .. ", " .. byPlayerMostDamage .. ", " .. (lastHitUnjustified and 1 or 0) .. ", " .. (mostDamageUnjustified and 1 or 0) .. ")")
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

	if not player:hasFlag(PlayerFlag_NotGenerateLoot) then
		-- 1. Utrata zawartości plecaka (całość trafia do corpse)
		local backpack = player:getSlotItem(CONST_SLOT_BACKPACK)
		if backpack and backpack:isContainer() then
			local backpackItems = backpack:getItems(false)
			for _, item in ipairs(backpackItems) do
				if corpse and corpse:isContainer() then
					if not item:moveTo(corpse) then
						item:moveTo(corpse:getPosition())
					end
				elseif corpse then
					item:moveTo(corpse:getPosition())
				end
			end
		end

		-- 2. Utrata przedmiotów ze slotów (Hełm, Zbroja, Spodnie, Buty, Amulet, Pierścienie, Rękawice)
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

		-- 3. Przenoszenie lub niszczenie wylosowanych przedmiotów
		local totalDropped = #droppedItems
		for i, dropData in ipairs(droppedItems) do
			local item = dropData.item
			-- Jeśli wypadnie więcej niż 1 przedmiot: dodatkowe przedmioty (od 2. wzwyż) mają 50% szans na zniszczenie
			if totalDropped > 1 and i > 1 and math.random(1, 100) <= 50 then
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
		end

		player:setCollectionInfo()
	end
end
