-- banshee chests

function onUse(cid, item, frompos, item2, topos)

local miniLvl = 120
local maxiLvl = 130
local sto = 26302

   	if item.uid == 26310 then
   		queststatus = getPlayerStorageValue(cid,sto)
   		if queststatus == -1 then
   			doPlayerSendTextMessage(cid,MESSAGE_EVENT_ADVANCE,"You have found a forest wand.")
			local bag = cid:addItem(7343)
			bag:addItem(26805, 15)
			bag:addItem(26806, 15)
			bag:addItem(26807, 15)

			local createItem = cid:addItem(26603, 1)
   			setPlayerStorageValue(cid,sto,1)
		   
		   	if createItem:getType():isUpgradable() then
				createItem:setCustomAttribute("unidentified", true)
				createItem:setItemLevel(math.random(miniLvl, maxiLvl))
			end
			
			
   		else
   			doPlayerSendTextMessage(cid,MESSAGE_EVENT_ADVANCE,"The chest is empty.")
   		end
   	elseif item.uid == 26311 then
   		queststatus = getPlayerStorageValue(cid,sto)
   		if queststatus == -1 then
   			doPlayerSendTextMessage(cid,MESSAGE_EVENT_ADVANCE,"You have found a bloody forest wand.")
						local bag = cid:addItem(7343)
			bag:addItem(26805, 15)
			bag:addItem(26806, 15)
			bag:addItem(26807, 15)
			local createItem = cid:addItem(26607, 1)
   			setPlayerStorageValue(cid,sto,1)
			if createItem:getType():isUpgradable() then
				createItem:setCustomAttribute("unidentified", true)
				createItem:setItemLevel(math.random(miniLvl, maxiLvl))
			end
   		else
   			doPlayerSendTextMessage(cid,MESSAGE_EVENT_ADVANCE,"The chest is empty.")
   		end
   	elseif item.uid == 26312 then
   		queststatus = getPlayerStorageValue(cid,sto)
   		if queststatus == -1 then
   			doPlayerSendTextMessage(cid,MESSAGE_EVENT_ADVANCE,"You have found a crown bow.")
			local bag = cid:addItem(7343)
			bag:addItem(26805, 15)
			bag:addItem(26806, 15)
			bag:addItem(26807, 15)
			local createItem = cid:addItem(26536, 1)
   			setPlayerStorageValue(cid,sto,1)
			if createItem:getType():isUpgradable() then
				createItem:setCustomAttribute("unidentified", true)
				createItem:setItemLevel(math.random(miniLvl, maxiLvl))
			end
   		else
   			doPlayerSendTextMessage(cid,MESSAGE_EVENT_ADVANCE,"The chest is empty.")
   		end
   	elseif item.uid == 26313 then
   		queststatus = getPlayerStorageValue(cid,sto)
   		if queststatus == -1 then
   			doPlayerSendTextMessage(cid,MESSAGE_EVENT_ADVANCE,"You have found a crown crossbow.")
						local bag = cid:addItem(7343)
			bag:addItem(26805, 15)
			bag:addItem(26806, 15)
			bag:addItem(26807, 15)
			local createItem = cid:addItem(26594, 1)
   			setPlayerStorageValue(cid,sto,1)
			if createItem:getType():isUpgradable() then
				createItem:setCustomAttribute("unidentified", true)
				createItem:setItemLevel(math.random(miniLvl, maxiLvl))
			end
   		else
   			doPlayerSendTextMessage(cid,MESSAGE_EVENT_ADVANCE,"The chest is empty.")
   		end
   	elseif item.uid == 26314 then
   		queststatus = getPlayerStorageValue(cid,sto)
   		if queststatus == -1 then
   			doPlayerSendTextMessage(cid,MESSAGE_EVENT_ADVANCE,"You have found a heavy sword.")
						local bag = cid:addItem(7343)
			bag:addItem(26805, 15)
			bag:addItem(26806, 15)
			bag:addItem(26807, 15)
			local createItem = cid:addItem(26481, 1)
   			setPlayerStorageValue(cid,sto,1)
			if createItem:getType():isUpgradable() then
				createItem:setCustomAttribute("unidentified", true)
				createItem:setItemLevel(math.random(miniLvl, maxiLvl))
			end
   		else
   			doPlayerSendTextMessage(cid,MESSAGE_EVENT_ADVANCE,"The chest is empty.")
   		end
   	elseif item.uid == 26315 then
   		queststatus = getPlayerStorageValue(cid,sto)
   		if queststatus == -1 then
   			doPlayerSendTextMessage(cid,MESSAGE_EVENT_ADVANCE,"You have found a heavy mace.")
						local bag = cid:addItem(7343)
			bag:addItem(26805, 15)
			bag:addItem(26806, 15)
			bag:addItem(26807, 15)
			local createItem = cid:addItem(7431, 1)
   			setPlayerStorageValue(cid,sto,1)
			if createItem:getType():isUpgradable() then
				createItem:setCustomAttribute("unidentified", true)
				createItem:setItemLevel(math.random(miniLvl, maxiLvl))
			end
   		else
   			doPlayerSendTextMessage(cid,MESSAGE_EVENT_ADVANCE,"The chest is empty.")
   		end
   	elseif item.uid == 26316 then
   		queststatus = getPlayerStorageValue(cid,sto)
   		if queststatus == -1 then
   			doPlayerSendTextMessage(cid,MESSAGE_EVENT_ADVANCE,"You have found a heavy axe.")
						local bag = cid:addItem(7343)
			bag:addItem(26805, 15)
			bag:addItem(26806, 15)
			bag:addItem(26807, 15)
			local createItem = cid:addItem(23547, 1)
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
