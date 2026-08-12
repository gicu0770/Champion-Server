-- banshee chests

function onUse(cid, item, frompos, item2, topos)

local miniLvl = 70
local maxiLvl = 70
	local createItem = nil
   	if item.uid == 30000 then
   		queststatus = getPlayerStorageValue(cid,25000)
		if cid:isShadow() or cid:isArcher() then
			if queststatus == -1 then
				doPlayerSendTextMessage(cid,MESSAGE_EVENT_ADVANCE,"You have found a T1 Light Armor.")

				createItem = cid:addItem(26496, 1)
				setPlayerStorageValue(cid,25000,1)
			else
				doPlayerSendTextMessage(cid,MESSAGE_EVENT_ADVANCE,"The chest is empty.")
			end
		else
		doPlayerSendTextMessage(cid,MESSAGE_EVENT_ADVANCE,"Armor for Shadows and Archers.")
		end
   	elseif item.uid == 30001 then
   		queststatus = getPlayerStorageValue(cid,25000)
		if cid:isKnight() or cid:isPaladin() then
			if queststatus == -1 then
				doPlayerSendTextMessage(cid,MESSAGE_EVENT_ADVANCE,"You have found a T1 Heavy Armor.")
				createItem = cid:addItem(26428, 1)
				setPlayerStorageValue(cid,25000,1)
			else
				doPlayerSendTextMessage(cid,MESSAGE_EVENT_ADVANCE,"The chest is empty.")
			end
		else
		doPlayerSendTextMessage(cid,MESSAGE_EVENT_ADVANCE,"Armor for Knights and Paladins.")
		end
   	elseif item.uid == 30002 then
   		queststatus = getPlayerStorageValue(cid,25000)
		if cid:isSorcerer() or cid:isDruid() then
   		if queststatus == -1 then
   			doPlayerSendTextMessage(cid,MESSAGE_EVENT_ADVANCE,"You have found a T1 Magic Armor.")
			createItem = cid:addItem(26459, 1)
   			setPlayerStorageValue(cid,25000,1)
   		else
   			doPlayerSendTextMessage(cid,MESSAGE_EVENT_ADVANCE,"The chest is empty.")
   		end
		else
		doPlayerSendTextMessage(cid,MESSAGE_EVENT_ADVANCE,"Armor for Druids and Sorcerers.")
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
