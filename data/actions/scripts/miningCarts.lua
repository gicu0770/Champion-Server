local startPos = {}

local function findfreespot()
	for i = 0, 9 do
		for x = 0, 4 do
			local tmpPos = {x = startPos.x + (i * 21), y = startPos.y + (x * 18), z = 5}
			local t = Tile(tmpPos)
			if t ~= nil then
				if(not t:getTopCreature()) then
					return tmpPos
				end
			end
		end
	end
	return false
end

function onUse(player, item, fromPosition, target, toPosition, isHotkey)
	-- Tu ustawiasz pozycje X Y do szukania pozycji TP gracza, teleport powrotny ustawiasz na RME mapie
	if item.actionid == 10567 then 		-- mining level 100
		if player:getLevel() >= 100 then
			startPos = {x = 25, y = 1299}
		else
			player:sendTextMessage(MESSAGE_INFO_DESCR, "Requires level 100 or higher!")
		end
	elseif item.actionid == 10568 then	-- mining level 200
		if player:getLevel() >= 200 then
			startPos = {x = 25, y = 1392}
		else
			player:sendTextMessage(MESSAGE_INFO_DESCR, "Requires level 200 or higher!")
		end
	elseif item.actionid == 10569 then	-- mining level 300
		if player:getLevel() >= 300 then
			startPos = {x = 25, y = 1484}
		else
			player:sendTextMessage(MESSAGE_INFO_DESCR, "Requires level 300 or higher!")
		end
	elseif item.actionid == 10573 then	-- mining level 400
		if player:getLevel() >= 400 then
			startPos = {x = 25, y = 1576}
		else
			player:sendTextMessage(MESSAGE_INFO_DESCR, "Requires level 400 or higher!")
		end
	end
	local slot = findfreespot()
	if(slot) then
		player:teleportTo(slot)
	else
		player:sendTextMessage(MESSAGE_INFO_DESCR, "No available free mining slots.")
	end

 return true
end