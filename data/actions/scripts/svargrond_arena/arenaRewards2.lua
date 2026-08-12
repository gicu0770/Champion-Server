-- banshee chests

function onUse(cid, item, frompos, item2, topos)

local miniLvl = 120
local maxiLvl = 130
local sto = 26301

   	if item.uid == 26307 then
   		queststatus = getPlayerStorageValue(cid,sto)
   		if queststatus == -1 then
   			doPlayerSendTextMessage(cid,MESSAGE_EVENT_ADVANCE,"You have found a forest shield.")
			local bag = cid:addItem(7343)
			bag:addItem(26805, 10)
			bag:addItem(26806, 10)
			bag:addItem(26807, 10)

			local createItem = cid:addItem(26732, 1)
   			setPlayerStorageValue(cid,sto,1)
		   
		   	if createItem:getType():isUpgradable() then
				createItem:setCustomAttribute("unidentified", true)
				createItem:setItemLevel(math.random(miniLvl, maxiLvl))
			end
			
			
   		else
   			doPlayerSendTextMessage(cid,MESSAGE_EVENT_ADVANCE,"The chest is empty.")
   		end
   	elseif item.uid == 26308 then
   		queststatus = getPlayerStorageValue(cid,sto)
   		if queststatus == -1 then
   			doPlayerSendTextMessage(cid,MESSAGE_EVENT_ADVANCE,"You have found a crown shield.")
						local bag = cid:addItem(7343)
			bag:addItem(26805, 10)
			bag:addItem(26806, 10)
			bag:addItem(26807, 10)
			local createItem = cid:addItem(26829, 1)
   			setPlayerStorageValue(cid,sto,1)
			if createItem:getType():isUpgradable() then
				createItem:setCustomAttribute("unidentified", true)
				createItem:setItemLevel(math.random(miniLvl, maxiLvl))
			end
   		else
   			doPlayerSendTextMessage(cid,MESSAGE_EVENT_ADVANCE,"The chest is empty.")
   		end
   	elseif item.uid == 26309 then
   		queststatus = getPlayerStorageValue(cid,sto)
   		if queststatus == -1 then
   			doPlayerSendTextMessage(cid,MESSAGE_EVENT_ADVANCE,"You have found a heavy shield.")
						local bag = cid:addItem(7343)
			bag:addItem(26805, 10)
			bag:addItem(26806, 10)
			bag:addItem(26807, 10)
			local createItem = cid:addItem(26480, 1)
   			setPlayerStorageValue(cid,sto,1)
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
