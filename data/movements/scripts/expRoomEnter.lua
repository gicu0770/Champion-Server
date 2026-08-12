local startPos = {}

local function findfreespot()
	for i = 0, 9 do
		for x = 0, 4 do
			local tmpPos = {x = startPos.x + (i * 22), y = startPos.y + (x * 22), z = 6}
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

function onStepIn(player, item, pos, fromPosition)
	-- Tu ustawiasz pozycje X Y do szukania pozycji TP gracza, teleport powrotny ustawiasz na RME mapie
	if item.actionid == 27567 then 		-- teleport powracajacy
		player:teleportTo(Position(143,2089,5))
		player:setStorageValue(PlayerStorage.AFKrooms, -1)
	--	player:sendTextMessage(MESSAGE_INFO_DESCR, "Your experience and gold back to normal stages.")
	elseif item.actionid == 27568 then	-- level 100
		if player:getLevel() >= 100 then
			startPos = {x = 52, y = 2143} -- pozycja T1 EQ ACC
		else
			player:sendTextMessage(MESSAGE_INFO_DESCR, "Requires level 100 or higher!")
			player:teleportTo(fromPosition)
		end
	elseif item.actionid == 27569 then	-- level 100
		if player:getLevel() >= 100 then
			startPos = {x = 52, y = 2255} -- pozycja T1 EQ ACC
		else
			player:sendTextMessage(MESSAGE_INFO_DESCR, "Requires level 100 or higher!")
			player:teleportTo(fromPosition)
		end
	elseif item.actionid == 27570 then	-- level 100
		if player:getLevel() >= 100 then
			startPos = {x = 52, y = 2367} -- pozycja T1 EQ ACC
		else
			player:sendTextMessage(MESSAGE_INFO_DESCR, "Requires level 100 or higher!")
			player:teleportTo(fromPosition)
		end
	elseif item.actionid == 27571 then	-- level 200
		if player:getLevel() >= 200 then
			startPos = {x = 52, y = 2485} -- pozycja T2 EQ
		else
			player:sendTextMessage(MESSAGE_INFO_DESCR, "Requires level 200 or higher!")
			player:teleportTo(fromPosition)
		end
	elseif item.actionid == 27572 then	-- level 200
		if player:getLevel() >= 200 then
			startPos = {x = 52, y = 2597} -- pozycja T2 ACC
		else
			player:sendTextMessage(MESSAGE_INFO_DESCR, "Requires level 200 or higher!")
			player:teleportTo(fromPosition)
		end
	elseif item.actionid == 27573 then	-- level 300
		if player:getLevel() >= 300 then
			startPos = {x = 52, y = 2709} -- pozycja T3 EQ
		else
			player:sendTextMessage(MESSAGE_INFO_DESCR, "Requires level 300 or higher!")
			player:teleportTo(fromPosition)
		end
	elseif item.actionid == 27574 then	-- level 300
		if player:getLevel() >= 300 then
			startPos = {x = 52, y = 2821} -- pozycja T3 ACC
		else
			player:sendTextMessage(MESSAGE_INFO_DESCR, "Requires level 300 or higher!")
			player:teleportTo(fromPosition)
		end
	elseif item.actionid == 27575 then	-- level 500
		if player:getLevel() >= 500 then
			startPos = {x = 52, y = 2936} -- pozycja T4 EQ
		else
			player:sendTextMessage(MESSAGE_INFO_DESCR, "Requires level 500 or higher!")
			player:teleportTo(fromPosition)
		end
	elseif item.actionid == 27576 then	-- level 500
		if player:getLevel() >= 500 then
			startPos = {x = 52, y = 3048} -- pozycja T4 ACC
		else
			player:sendTextMessage(MESSAGE_INFO_DESCR, "Requires level 500 or higher!")
			player:teleportTo(fromPosition)
		end
	elseif item.actionid == 27577 then	-- level 700
		if player:getLevel() >= 700 then
			startPos = {x = 52, y = 3162} -- pozycja T5 EQ
		else
			player:sendTextMessage(MESSAGE_INFO_DESCR, "Requires level 700 or higher!")
			player:teleportTo(fromPosition)
		end
	elseif item.actionid == 27578 then	-- level 700
		if player:getLevel() >= 700 then
			startPos = {x = 52, y = 3274} -- pozycja T5 ACC
		else
			player:sendTextMessage(MESSAGE_INFO_DESCR, "Requires level 700 or higher!")
			player:teleportTo(fromPosition)
		end
	elseif item.actionid == 27579 then	-- level 800
		if player:getLevel() >= 800 then
			startPos = {x = 52, y = 3387} -- pozycja T6 EQ
		else
			player:sendTextMessage(MESSAGE_INFO_DESCR, "Requires level 800 or higher!")
			player:teleportTo(fromPosition)
		end
	elseif item.actionid == 27580 then	-- level 800
		if player:getLevel() >= 800 then
			startPos = {x = 52, y = 3500} -- pozycja T6 ACC
		else
			player:sendTextMessage(MESSAGE_INFO_DESCR, "Requires level 800 or higher!")
			player:teleportTo(fromPosition)
		end
	elseif item.actionid == 27581 then	-- level 1100
		if player:getLevel() >= 1100 then
			startPos = {x = 52, y = 3613} -- pozycja T7 EQ
		else
			player:sendTextMessage(MESSAGE_INFO_DESCR, "Requires level 1100 or higher!")
			player:teleportTo(fromPosition)
		end
	elseif item.actionid == 27582 then	-- level 1100
		if player:getLevel() >= 1100 then
			startPos = {x = 52, y = 3727} -- pozycja T7 ACC
		else
			player:sendTextMessage(MESSAGE_INFO_DESCR, "Requires level 1100 or higher!")
			player:teleportTo(fromPosition)
		end
	elseif item.actionid == 27583 then	-- level 1300
		if player:getLevel() >= 1100 then
			startPos = {x = 52, y = 3839} -- pozycja T8 EQ
		else
			player:sendTextMessage(MESSAGE_INFO_DESCR, "Requires level 1300 or higher!")
			player:teleportTo(fromPosition)
		end
	elseif item.actionid == 27584 then	-- level 1300
		if player:getLevel() >= 1100 then
			startPos = {x = 52, y = 3952} -- pozycja T8 ACC
		else
			player:sendTextMessage(MESSAGE_INFO_DESCR, "Requires level 1300 or higher!")
			player:teleportTo(fromPosition)
		end
	elseif item.actionid == 27585 then	-- level 1500
		if player:getLevel() >= 1500 then
			startPos = {x = 53, y = 4067} -- pozycja T9 EQACC
		else
			player:sendTextMessage(MESSAGE_INFO_DESCR, "Requires level 1300 or higher!")
			player:teleportTo(fromPosition)
		end

	end
	local slot = findfreespot()
	if(slot) then
		player:teleportTo(slot)
	--	player:sendTextMessage(MESSAGE_INFO_DESCR, "Your experience and gold is reduced to 25%!")
		player:setStorageValue(PlayerStorage.AFKrooms, 1)
	else
		player:sendTextMessage(MESSAGE_INFO_DESCR, "No available free exp slots.")
		player:teleportTo(fromPosition)
	end

 return true
end