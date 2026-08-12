-- banshee chests

function onUse(cid, item, frompos, item2, topos)

local miniLvl = 70
local maxiLvl = 70
	local createItem = nil
   	if item.uid == 30022 then
   		queststatus = getPlayerStorageValue(cid,PlayerStorage.mythicQuestAcc1)
   		if queststatus == -1 then
   			doPlayerSendTextMessage(cid,MESSAGE_EVENT_ADVANCE,"You have found a T1 Gloves.")
			 createItem = cid:addItem(5875, 1)
   			setPlayerStorageValue(cid,PlayerStorage.mythicQuestAcc1,1)
   		else
   			doPlayerSendTextMessage(cid,MESSAGE_EVENT_ADVANCE,"The chest is empty.")
   		end
   	end
   	if item.uid == 30023 then
   		queststatus = getPlayerStorageValue(cid,PlayerStorage.mythicQuestAcc2)
   		if queststatus == -1 then
   			doPlayerSendTextMessage(cid,MESSAGE_EVENT_ADVANCE,"You have found a T1 Amulet.")
			 createItem = cid:addItem(26833, 1)
   			setPlayerStorageValue(cid,PlayerStorage.mythicQuestAcc2,1)
   		else
   			doPlayerSendTextMessage(cid,MESSAGE_EVENT_ADVANCE,"The chest is empty.")
   		end
   	end
   	if item.uid == 30024 then
   		queststatus = getPlayerStorageValue(cid,PlayerStorage.mythicQuestAcc3)
   		if queststatus == -1 then
   			doPlayerSendTextMessage(cid,MESSAGE_EVENT_ADVANCE,"You have found a T1 Belt.")
			 createItem = cid:addItem(12448, 1)
   			setPlayerStorageValue(cid,PlayerStorage.mythicQuestAcc3,1)
   		else
   			doPlayerSendTextMessage(cid,MESSAGE_EVENT_ADVANCE,"The chest is empty.")
   		end
   	end
if createItem then
 createItem:setQuestItem(1)
 setLootItem(cid, createItem, 1, 7000, 4000, 2000)
end	
   	return false
end
