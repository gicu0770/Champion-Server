function onExtendedOpcode(player, opcode, buffer)
	if opcode == ExtendedOPCodes.CODE_DEATHS then
		local status, json_data = pcall(function()
			return json.decode(buffer)
		end)
		if not status or not json_data then
			return false
		end

		local action = json_data.action
		if action == "fetch" then
			local playerGuid = player:getGuid()
			local resultId = db.storeQuery("SELECT `time`, `level`, `killed_by`, `is_player`, `mostdamage_by`, `mostdamage_is_player`, `unjustified`, `lost_items` FROM `player_deaths` WHERE `player_id` = " .. playerGuid .. " ORDER BY `time` DESC LIMIT 20")

			local deathsList = {}
			if resultId ~= false then
				repeat
					local timeVal = result.getNumber(resultId, "time")
					local levelVal = result.getNumber(resultId, "level")
					local killedBy = result.getString(resultId, "killed_by")
					local isPlayer = result.getNumber(resultId, "is_player")
					local mostDamageBy = result.getString(resultId, "mostdamage_by")
					local mostDamageIsPlayer = result.getNumber(resultId, "mostdamage_is_player")
					local unjustified = result.getNumber(resultId, "unjustified")
					local lostItemsStr = result.getString(resultId, "lost_items")

					local lostItems = {}
					if lostItemsStr and lostItemsStr ~= "" then
						local ok, decoded = pcall(function() return json.decode(lostItemsStr) end)
						if ok and type(decoded) == "table" then
							lostItems = decoded
							for _, it in ipairs(lostItems) do
								if not it.clientId and it.id then
									local itType = ItemType(it.id)
									if itType then
										it.clientId = itType:getClientId()
									end
								end
							end
						end
					end

					table.insert(deathsList, {
						time = timeVal,
						level = levelVal,
						killedBy = killedBy,
						isPlayer = isPlayer,
						mostDamageBy = mostDamageBy,
						mostDamageIsPlayer = mostDamageIsPlayer,
						unjustified = unjustified,
						lostItems = lostItems
					})
				until not result.next(resultId)
				result.free(resultId)
			end

			player:sendExtendedOpcode(ExtendedOPCodes.CODE_DEATHS, json.encode({
				action = "list",
				deaths = deathsList
			}))
		end
	end
	return true
end
