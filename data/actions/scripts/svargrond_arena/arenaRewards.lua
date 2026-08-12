

--function onUse(player, item, frompos, item2, topos)	-- banshee chests
--   	if item.uid == 30000 then
--   		local queststatus = getPlayerStorageValue(player,25000)
 --  		if queststatus == -1 then
 --  			doPlayerSendTextMessage(player,MESSAGE_EVENT_ADVANCE,"You have found 10x Fabric Orb and Condensed Energy.")
--			player:addItem(36631, 10)
--			player:addItem(26157, 10)
--   			setPlayerStorageValue(player,25000,1)	
 --  		else
--   			doPlayerSendTextMessage(player,MESSAGE_EVENT_ADVANCE,"The chest is empty.")
--   		end
--	end
--   	return false
--end




function onUse(cid, item, frompos, item2, topos)

local miniLvl = 90
local maxiLvl = 100
local sto = 26300

   	if item.uid == 26300 then
   		queststatus = getPlayerStorageValue(cid,sto)
   		if queststatus == -1 then
   			doPlayerSendTextMessage(cid,MESSAGE_EVENT_ADVANCE,"You have found a galaxy wand.")
		
			local bag = cid:addItem(7343)
			bag:addItem(26805, 5)
			bag:addItem(26806, 5)
			bag:addItem(26807, 5)
			local createItem = cid:addItem(26551, 1)
   			setPlayerStorageValue(cid,sto,1)
		   
		   	if createItem:getType():isUpgradable() then
				createItem:setCustomAttribute("unidentified", true)
				createItem:setItemLevel(math.random(miniLvl, maxiLvl))
			end
			
			
   		else
   			doPlayerSendTextMessage(cid,MESSAGE_EVENT_ADVANCE,"The chest is empty.")
   		end
   	elseif item.uid == 26301 then
   		queststatus = getPlayerStorageValue(cid,sto)
   		if queststatus == -1 then
   			doPlayerSendTextMessage(cid,MESSAGE_EVENT_ADVANCE,"You have found a bloody galaxy wand.")
			local bag = cid:addItem(7343)
			bag:addItem(26805, 5)
			bag:addItem(26806, 5)
			bag:addItem(26807, 5)
			local createItem = cid:addItem(26631, 1)
   			setPlayerStorageValue(cid,sto,1)
			if createItem:getType():isUpgradable() then
				createItem:setCustomAttribute("unidentified", true)
				createItem:setItemLevel(math.random(miniLvl, maxiLvl))
			end
   		else
   			doPlayerSendTextMessage(cid,MESSAGE_EVENT_ADVANCE,"The chest is empty.")
   		end
   	elseif item.uid == 26302 then
   		queststatus = getPlayerStorageValue(cid,sto)
   		if queststatus == -1 then
   			doPlayerSendTextMessage(cid,MESSAGE_EVENT_ADVANCE,"You have found a cheetah bow.")
						local bag = cid:addItem(7343)
			bag:addItem(26805, 5)
			bag:addItem(26806, 5)
			bag:addItem(26807, 5)
			local createItem = cid:addItem(22418, 1)
   			setPlayerStorageValue(cid,sto,1)
			if createItem:getType():isUpgradable() then
				createItem:setCustomAttribute("unidentified", true)
				createItem:setItemLevel(math.random(miniLvl, maxiLvl))
			end
   		else
   			doPlayerSendTextMessage(cid,MESSAGE_EVENT_ADVANCE,"The chest is empty.")
   		end
   	elseif item.uid == 26303 then
   		queststatus = getPlayerStorageValue(cid,sto)
   		if queststatus == -1 then
   			doPlayerSendTextMessage(cid,MESSAGE_EVENT_ADVANCE,"You have found a cheetah crossbow.")
						local bag = cid:addItem(7343)
			bag:addItem(26805, 5)
			bag:addItem(26806, 5)
			bag:addItem(26807, 5)
			local createItem = cid:addItem(22421, 1)
   			setPlayerStorageValue(cid,sto,1)
			if createItem:getType():isUpgradable() then
				createItem:setCustomAttribute("unidentified", true)
				createItem:setItemLevel(math.random(miniLvl, maxiLvl))
			end
   		else
   			doPlayerSendTextMessage(cid,MESSAGE_EVENT_ADVANCE,"The chest is empty.")
   		end
   	elseif item.uid == 26304 then
   		queststatus = getPlayerStorageValue(cid,sto)
   		if queststatus == -1 then
   			doPlayerSendTextMessage(cid,MESSAGE_EVENT_ADVANCE,"You have found a octo sword.")
						local bag = cid:addItem(7343)
			bag:addItem(26805, 5)
			bag:addItem(26806, 5)
			bag:addItem(26807, 5)
			local createItem = cid:addItem(26418, 1)
   			setPlayerStorageValue(cid,sto,1)
			if createItem:getType():isUpgradable() then
				createItem:setCustomAttribute("unidentified", true)
				createItem:setItemLevel(math.random(miniLvl, maxiLvl))
			end
   		else
   			doPlayerSendTextMessage(cid,MESSAGE_EVENT_ADVANCE,"The chest is empty.")
   		end
   	elseif item.uid == 26305 then
   		queststatus = getPlayerStorageValue(cid,sto)
   		if queststatus == -1 then
   			doPlayerSendTextMessage(cid,MESSAGE_EVENT_ADVANCE,"You have found a octo mace.")
						local bag = cid:addItem(7343)
			bag:addItem(26805, 5)
			bag:addItem(26806, 5)
			bag:addItem(26807, 5)
			local createItem = cid:addItem(26419, 1)
   			setPlayerStorageValue(cid,sto,1)
			if createItem:getType():isUpgradable() then
				createItem:setCustomAttribute("unidentified", true)
				createItem:setItemLevel(math.random(miniLvl, maxiLvl))
			end
   		else
   			doPlayerSendTextMessage(cid,MESSAGE_EVENT_ADVANCE,"The chest is empty.")
   		end
   	elseif item.uid == 26306 then
   		queststatus = getPlayerStorageValue(cid,sto)
   		if queststatus == -1 then
   			doPlayerSendTextMessage(cid,MESSAGE_EVENT_ADVANCE,"You have found a octo axe.")
						local bag = cid:addItem(7343)
			bag:addItem(26805, 5)
			bag:addItem(26806, 5)
			bag:addItem(26807, 5)
			local createItem = cid:addItem(26420, 1)
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
