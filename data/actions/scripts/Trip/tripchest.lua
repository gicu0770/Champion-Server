-- banshee chests

function onUse(cid, item, frompos, item2, topos)

local miniLvl = 170
local maxiLvl = 180

   	if item.uid == 8776 then
   		queststatus = getPlayerStorageValue(cid,25005)
   		if queststatus == -1 then
   			doPlayerSendTextMessage(cid,MESSAGE_EVENT_ADVANCE,"You have found a wizard wand.")

			local createItem = cid:addItem(26544, 1)
   			setPlayerStorageValue(cid,25005,1)
		   
		   	if createItem:getType():isUpgradable() then
				createItem:setCustomAttribute("unidentified", true)
				createItem:setItemLevel(math.random(miniLvl, maxiLvl))
			end
			
			
   		else
   			doPlayerSendTextMessage(cid,MESSAGE_EVENT_ADVANCE,"The chest is empty.")
   		end
   	elseif item.uid == 8777 then
   		queststatus = getPlayerStorageValue(cid,25005)
   		if queststatus == -1 then
   			doPlayerSendTextMessage(cid,MESSAGE_EVENT_ADVANCE,"You have found a bloody wizard wand.")
			local createItem = cid:addItem(26468, 1)
   			setPlayerStorageValue(cid,25005,1)
			if createItem:getType():isUpgradable() then
				createItem:setCustomAttribute("unidentified", true)
				createItem:setItemLevel(math.random(miniLvl, maxiLvl))
			end
   		else
   			doPlayerSendTextMessage(cid,MESSAGE_EVENT_ADVANCE,"The chest is empty.")
   		end
   	elseif item.uid == 8778 then
   		queststatus = getPlayerStorageValue(cid,25005)
   		if queststatus == -1 then
   			doPlayerSendTextMessage(cid,MESSAGE_EVENT_ADVANCE,"You have found a guardian bow.")
			local createItem = cid:addItem(8856, 1)
   			setPlayerStorageValue(cid,25005,1)
			if createItem:getType():isUpgradable() then
				createItem:setCustomAttribute("unidentified", true)
				createItem:setItemLevel(math.random(miniLvl, maxiLvl))
			end
   		else
   			doPlayerSendTextMessage(cid,MESSAGE_EVENT_ADVANCE,"The chest is empty.")
   		end
   	elseif item.uid == 8779 then
   		queststatus = getPlayerStorageValue(cid,25005)
   		if queststatus == -1 then
   			doPlayerSendTextMessage(cid,MESSAGE_EVENT_ADVANCE,"You have found a guaridan crossbow.")
			local createItem = cid:addItem(15644, 1)
   			setPlayerStorageValue(cid,25005,1)
			if createItem:getType():isUpgradable() then
				createItem:setCustomAttribute("unidentified", true)
				createItem:setItemLevel(math.random(miniLvl, maxiLvl))
			end
   		else
   			doPlayerSendTextMessage(cid,MESSAGE_EVENT_ADVANCE,"The chest is empty.")
   		end
   	elseif item.uid == 8780 then
   		queststatus = getPlayerStorageValue(cid,25005)
   		if queststatus == -1 then
   			doPlayerSendTextMessage(cid,MESSAGE_EVENT_ADVANCE,"You have found a platinum sword.")
			local createItem = cid:addItem(26611, 1)
   			setPlayerStorageValue(cid,25005,1)
			if createItem:getType():isUpgradable() then
				createItem:setCustomAttribute("unidentified", true)
				createItem:setItemLevel(math.random(miniLvl, maxiLvl))
			end
   		else
   			doPlayerSendTextMessage(cid,MESSAGE_EVENT_ADVANCE,"The chest is empty.")
   		end
   	elseif item.uid == 8781 then
   		queststatus = getPlayerStorageValue(cid,25005)
   		if queststatus == -1 then
   			doPlayerSendTextMessage(cid,MESSAGE_EVENT_ADVANCE,"You have found a platinum axe.")
			local createItem = cid:addItem(26589, 1)
   			setPlayerStorageValue(cid,25005,1)
			if createItem:getType():isUpgradable() then
				createItem:setCustomAttribute("unidentified", true)
				createItem:setItemLevel(math.random(miniLvl, maxiLvl))
			end
   		else
   			doPlayerSendTextMessage(cid,MESSAGE_EVENT_ADVANCE,"The chest is empty.")
   		end
   	elseif item.uid == 8782 then
   		queststatus = getPlayerStorageValue(cid,25005)
   		if queststatus == -1 then
   			doPlayerSendTextMessage(cid,MESSAGE_EVENT_ADVANCE,"You have found a platinum mace.")
			local createItem = cid:addItem(26614, 1)
   			setPlayerStorageValue(cid,25005,1)
			if createItem:getType():isUpgradable() then
				createItem:setCustomAttribute("unidentified", true)
				createItem:setItemLevel(math.random(miniLvl, maxiLvl))
			end
   		else
   			doPlayerSendTextMessage(cid,MESSAGE_EVENT_ADVANCE,"The chest is empty.")
   		end

	else
		return 0
   	end

   	return 1
end
