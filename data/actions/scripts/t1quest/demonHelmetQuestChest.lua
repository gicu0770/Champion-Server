-- banshee chests

function onUse(cid, item, frompos, item2, topos)

local miniLvl = 70
local maxiLvl = 70
	local createItem = nil
   	if item.uid == 30011 then
   		queststatus = getPlayerStorageValue(cid,25002)
		if cid:isShadow() or cid:isArcher() then
			if queststatus == -1 then
				doPlayerSendTextMessage(cid,MESSAGE_EVENT_ADVANCE,"You have found a T1 Light Helmet.")
				createItem = cid:addItem(26495, 1)
				setPlayerStorageValue(cid,25002,1)
			else
				doPlayerSendTextMessage(cid,MESSAGE_EVENT_ADVANCE,"The chest is empty.")
			end
		else
		doPlayerSendTextMessage(cid,MESSAGE_EVENT_ADVANCE,"Helmet for Archers and Shadows.")
		end
   	elseif item.uid == 30012 then
   		queststatus = getPlayerStorageValue(cid,25002)
		if cid:isSorcerer() or cid:isDruid() then
			if queststatus == -1 then
				doPlayerSendTextMessage(cid,MESSAGE_EVENT_ADVANCE,"You have found a T1 Magic Helmet.")
				createItem = cid:addItem(26458, 1)
				setPlayerStorageValue(cid,25002,1)
			else
				doPlayerSendTextMessage(cid,MESSAGE_EVENT_ADVANCE,"The chest is empty.")
			end
		else
		doPlayerSendTextMessage(cid,MESSAGE_EVENT_ADVANCE,"Helmet for Sorcerers and Druids.")
		end
   	elseif item.uid == 30013 then
   		queststatus = getPlayerStorageValue(cid,25002)
		if cid:isKnight() or cid:isPaladin() then
			if queststatus == -1 then
				doPlayerSendTextMessage(cid,MESSAGE_EVENT_ADVANCE,"You have found a T1 Heavy Helmet.")
				createItem = cid:addItem(26427, 1)
				setPlayerStorageValue(cid,25002,1)
			else
				doPlayerSendTextMessage(cid,MESSAGE_EVENT_ADVANCE,"The chest is empty.")
			end
		else
		doPlayerSendTextMessage(cid,MESSAGE_EVENT_ADVANCE,"Helmet for Knights and Paladins.")
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
