-- banshee chests

function onUse(cid, item, frompos, item2, topos)

local miniLvl = 170
local maxiLvl = 180

   	if item.uid == 8783 then
   		queststatus = getPlayerStorageValue(cid,25006)
   		if queststatus == -1 then
   			doPlayerSendTextMessage(cid,MESSAGE_EVENT_ADVANCE,"You have found a platinum shield.")

			local createItem = cid:addItem(26827, 1)
   			setPlayerStorageValue(cid,25006,1)
		   
		   	if createItem:getType():isUpgradable() then
				createItem:setCustomAttribute("unidentified", true)
				createItem:setItemLevel(math.random(miniLvl, maxiLvl))
			end
			
			
   		else
   			doPlayerSendTextMessage(cid,MESSAGE_EVENT_ADVANCE,"The chest is empty.")
   		end
   	elseif item.uid == 8784 then
   		queststatus = getPlayerStorageValue(cid,25006)
   		if queststatus == -1 then
   			doPlayerSendTextMessage(cid,MESSAGE_EVENT_ADVANCE,"You have found a guardian shield.")
			local createItem = cid:addItem(26489, 1)
   			setPlayerStorageValue(cid,25006,1)
			if createItem:getType():isUpgradable() then
				createItem:setCustomAttribute("unidentified", true)
				createItem:setItemLevel(math.random(miniLvl, maxiLvl))
			end
   		else
   			doPlayerSendTextMessage(cid,MESSAGE_EVENT_ADVANCE,"The chest is empty.")
   		end
   	elseif item.uid == 8785 then
   		queststatus = getPlayerStorageValue(cid,25006)
   		if queststatus == -1 then
   			doPlayerSendTextMessage(cid,MESSAGE_EVENT_ADVANCE,"You have found a wizard shield.")
			local createItem = cid:addItem(16112, 1)
   			setPlayerStorageValue(cid,25006,1)
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
