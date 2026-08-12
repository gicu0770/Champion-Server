-- banshee chests

function onUse(cid, item, frompos, item2, topos)

local miniLvl = 70
local maxiLvl = 70
	local createItem = nil
   	if item.uid == 30019 then
   		queststatus = getPlayerStorageValue(cid,PlayerStorage.mythicQuest)
		if cid:isKnight() or cid:isPaladin() then
			if queststatus == -1 then
				doPlayerSendTextMessage(cid,MESSAGE_EVENT_ADVANCE,"You have found a T1 Heavy Shield.")
				createItem = cid:addItem(26431, 1)
				setPlayerStorageValue(cid,PlayerStorage.mythicQuest,1)
			else
				doPlayerSendTextMessage(cid,MESSAGE_EVENT_ADVANCE,"The chest is empty.")
			end
		else
		doPlayerSendTextMessage(cid,MESSAGE_EVENT_ADVANCE,"Shield for Knights and Paladins.")
		end
   	elseif item.uid == 30020 then
   		queststatus = getPlayerStorageValue(cid,PlayerStorage.mythicQuest)
		if cid:isShadow() or cid:isArcher() then
			if queststatus == -1 then
				doPlayerSendTextMessage(cid,MESSAGE_EVENT_ADVANCE,"You have found a T1 Light Shield.")
				createItem = cid:addItem(26499, 1)
				setPlayerStorageValue(cid,PlayerStorage.mythicQuest,1)
			else
				doPlayerSendTextMessage(cid,MESSAGE_EVENT_ADVANCE,"The chest is empty.")
			end
		else
		doPlayerSendTextMessage(cid,MESSAGE_EVENT_ADVANCE,"Shield for Shadows and Archers.")
		end
   	elseif item.uid == 30021 then
   		queststatus = getPlayerStorageValue(cid,PlayerStorage.mythicQuest)
		if cid:isSorcerer() or cid:isDruid() then
			if queststatus == -1 then
				doPlayerSendTextMessage(cid,MESSAGE_EVENT_ADVANCE,"You have found a T1 Magic Shield.")
				createItem = cid:addItem(23771, 1)
				setPlayerStorageValue(cid,PlayerStorage.mythicQuest,1)
			else
				doPlayerSendTextMessage(cid,MESSAGE_EVENT_ADVANCE,"The chest is empty.")
			end
		else
		doPlayerSendTextMessage(cid,MESSAGE_EVENT_ADVANCE,"Shield for Sorcerers and Druids.")
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
