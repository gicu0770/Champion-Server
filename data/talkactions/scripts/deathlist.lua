local function getArticle(str)
	return str:find("[AaEeIiOoUuYy]") == 1 and "an" or "a"
end

local function getMonthDayEnding(day)
	if day == "01" or day == "21" or day == "31" then
		return "st"
	elseif day == "02" or day == "22" then
		return "nd"
	elseif day == "03" or day == "23" then
		return "rd"
	else
		return "th"
	end
end

local function getMonthString(m)
	return os.date("%B", os.time{year = 1970, month = m, day = 1})
end

function onSay(player, words, param)
	local targetName = param
	if not targetName or targetName == "" then
		targetName = player:getName()
	end

	local resultId = db.storeQuery("SELECT `id`, `name` FROM `players` WHERE `name` = " .. db.escapeString(targetName))
	if resultId ~= false then
		local targetGUID = result.getNumber(resultId, "id")
		targetName = result.getString(resultId, "name")
		result.free(resultId)
		local str = ""
		local breakline = ""

		local deathQuery = db.storeQuery("SELECT `time`, `level`, `killed_by`, `is_player`, `lost_items` FROM `player_deaths` WHERE `player_id` = " .. targetGUID .. " ORDER BY `time` DESC LIMIT 20")
		if deathQuery ~= false then
			repeat
				if str ~= "" then
					breakline = "\n----------------------------------------\n"
				end
				local date = os.date("*t", result.getNumber(deathQuery, "time"))

				local article = ""
				local killed_by = result.getString(deathQuery, "killed_by")
				local is_player = result.getNumber(deathQuery, "is_player")
				local typeTag = is_player == 1 and "[PvP]" or "[PvM]"
				if is_player == 0 then
					article = getArticle(killed_by) .. " "
					killed_by = string.lower(killed_by)
				end

				if date.day < 10 then date.day = "0" .. date.day end
				if date.hour < 10 then date.hour = "0" .. date.hour end
				if date.min < 10 then date.min = "0" .. date.min end
				if date.sec < 10 then date.sec = "0" .. date.sec end

				local deathInfo = string.format("%s %s%s %s %s:%s:%s - Level %d by %s%s %s",
					typeTag,
					date.day, getMonthDayEnding(date.day), getMonthString(date.month),
					date.year, date.hour, date.min,
					result.getNumber(deathQuery, "level"),
					article, killed_by, date.sec and "" or "")

				local lostItemsStr = result.getString(deathQuery, "lost_items")
				local itemsListText = ""
				if lostItemsStr and lostItemsStr ~= "" then
					local ok, itemsTable = pcall(function() return json.decode(lostItemsStr) end)
					if ok and type(itemsTable) == "table" and #itemsTable > 0 then
						for _, it in ipairs(itemsTable) do
							local countText = (it.count and it.count > 1) and (it.count .. "x ") or ""
							local statusText = it.status == "destroyed" and "[DESTROYED]" or "[CORPSE]"
							local srcText = it.source == "slot" and (" (" .. (it.slotName or "Slot") .. ")") or " (Backpack)"
							itemsListText = itemsListText .. "\n  * " .. countText .. (it.name or "Item") .. srcText .. " -> " .. statusText
						end
					end
				end

				if itemsListText == "" then
					itemsListText = "\n  * No items lost."
				end

				str = str .. breakline .. deathInfo .. itemsListText
			until not result.next(deathQuery)
			result.free(deathQuery)
		end

		if str == "" then
			str = "No deaths recorded."
		end
		player:popupFYI("Deathlist for player " .. targetName .. ":\n\n" .. str)
	else
		player:sendCancelMessage("A player with that name does not exist.")
	end
	return false
end
