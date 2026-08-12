-- banshee chests

function onUse(cid, item, frompos, item2, topos)

local miniLvl = 70
local maxiLvl = 70
	local createItem = nil
   	if item.uid == 26317 then
   		queststatus = getPlayerStorageValue(cid,PlayerStorage.questBoots)
   		if queststatus == -1 then
   			doPlayerSendTextMessage(cid,MESSAGE_EVENT_ADVANCE,"You have found a T1 Light Boots.")
			createItem = cid:addItem(26498, 1)
   			setPlayerStorageValue(cid,PlayerStorage.questBoots,1)
   		else
   			doPlayerSendTextMessage(cid,MESSAGE_EVENT_ADVANCE,"The chest is empty.")
   		end
   	elseif item.uid == 26318 then
   		queststatus = getPlayerStorageValue(cid,PlayerStorage.questBoots)
   		if queststatus == -1 then
   			doPlayerSendTextMessage(cid,MESSAGE_EVENT_ADVANCE,"You have found a T1 Magic Boots.")
			createItem = cid:addItem(26461, 1)
   			setPlayerStorageValue(cid,PlayerStorage.questBoots,1)
   		else
   			doPlayerSendTextMessage(cid,MESSAGE_EVENT_ADVANCE,"The chest is empty.")
   		end
   	elseif item.uid == 26319 then
   		queststatus = getPlayerStorageValue(cid,PlayerStorage.questBoots)
   		if queststatus == -1 then
   			doPlayerSendTextMessage(cid,MESSAGE_EVENT_ADVANCE,"You have found a T1 Heavy Boots.")
			createItem = cid:addItem(26430, 1)
   			setPlayerStorageValue(cid,PlayerStorage.questBoots,1)
   		else
   			doPlayerSendTextMessage(cid,MESSAGE_EVENT_ADVANCE,"The chest is empty.")
   		end
	else
		return false
   	end
	
if createItem then
 createItem:setQuestItem(1)
 setLootItem(cid, createItem, 1, 7000, 4000, 2000)
end	

   	return true
end
