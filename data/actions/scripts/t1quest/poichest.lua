-- banshee chests

function onUse(cid, item, frompos, item2, topos)

local miniLvl = 70
local maxiLvl = 70
	local createItem = nil
   	if item.uid == 30003 then
   		queststatus = getPlayerStorageValue(cid,25001)
		if cid:isSorcerer() or cid:isDruid() then
			if queststatus == -1 then
				doPlayerSendTextMessage(cid,MESSAGE_EVENT_ADVANCE,"You have found a T1 Magic Wand.")
				createItem = cid:addItem(26462, 1)
				setPlayerStorageValue(cid,25001,1)	
			else
				doPlayerSendTextMessage(cid,MESSAGE_EVENT_ADVANCE,"The chest is empty.")
			end
		else
		doPlayerSendTextMessage(cid,MESSAGE_EVENT_ADVANCE,"Weapon for Sorcerer and Druids.")
		end
   	elseif item.uid == 30004 then
   		queststatus = getPlayerStorageValue(cid,25001)
		if cid:isSorcerer() or cid:isDruid() then
			if queststatus == -1 then
				doPlayerSendTextMessage(cid,MESSAGE_EVENT_ADVANCE,"You have found a T1 Magic Aoe Wand.")
				createItem = cid:addItem(26538, 1)
				setPlayerStorageValue(cid,25001,1)
			else
				doPlayerSendTextMessage(cid,MESSAGE_EVENT_ADVANCE,"The chest is empty.")
			end
		else
		doPlayerSendTextMessage(cid,MESSAGE_EVENT_ADVANCE,"Weapon for Sorcerer and Druids.")
		end
   	elseif item.uid == 30005 then
   		queststatus = getPlayerStorageValue(cid,25001)
		if cid:isArcher() then
			if queststatus == -1 then
				doPlayerSendTextMessage(cid,MESSAGE_EVENT_ADVANCE,"You have found a T1 Light Crossbow.")
				createItem = cid:addItem(25523, 1)
				setPlayerStorageValue(cid,25001,1)
			else
				doPlayerSendTextMessage(cid,MESSAGE_EVENT_ADVANCE,"The chest is empty.")
			end
		else
		doPlayerSendTextMessage(cid,MESSAGE_EVENT_ADVANCE,"Weapon for Archers.")
		end
   	elseif item.uid == 30006 then
   		queststatus = getPlayerStorageValue(cid,25001)
		if cid:isShadow() or cid:isArcher() then
			if queststatus == -1 then
				doPlayerSendTextMessage(cid,MESSAGE_EVENT_ADVANCE,"You have found a T1 Light Bow.")
				createItem = cid:addItem(26502, 1)
				setPlayerStorageValue(cid,25001,1)
			else
				doPlayerSendTextMessage(cid,MESSAGE_EVENT_ADVANCE,"The chest is empty.")
			end
		else
		doPlayerSendTextMessage(cid,MESSAGE_EVENT_ADVANCE,"Weapon for Archers and Shadows.")
		end
   	elseif item.uid == 30007 then
   		queststatus = getPlayerStorageValue(cid,25001)
		if cid:isPaladin() then
			if queststatus == -1 then
				doPlayerSendTextMessage(cid,MESSAGE_EVENT_ADVANCE,"You have found a T1 Heavy Mace.")
				createItem = cid:addItem(26432, 1)
				setPlayerStorageValue(cid,25001,1)
			else
				doPlayerSendTextMessage(cid,MESSAGE_EVENT_ADVANCE,"The chest is empty.")
			end
		else
		doPlayerSendTextMessage(cid,MESSAGE_EVENT_ADVANCE,"Weapon for Paladins.")
		end
   	elseif item.uid == 30008 then
   		queststatus = getPlayerStorageValue(cid,25001)
		if cid:isKnight() or cid:isPaladin() then
			if queststatus == -1 then
				doPlayerSendTextMessage(cid,MESSAGE_EVENT_ADVANCE,"You have found a T1 Heavy Sword.")
				createItem = cid:addItem(26433, 1)
				setPlayerStorageValue(cid,25001,1)
			else
				doPlayerSendTextMessage(cid,MESSAGE_EVENT_ADVANCE,"The chest is empty.")
			end
		else
		doPlayerSendTextMessage(cid,MESSAGE_EVENT_ADVANCE,"Weapon for Knights and Paladins.")
		end
   	elseif item.uid == 30009 then
   		queststatus = getPlayerStorageValue(cid,25001)
		if cid:isKnight() then
			if queststatus == -1 then
				doPlayerSendTextMessage(cid,MESSAGE_EVENT_ADVANCE,"You have found a T1 Heavy Axe.")
				createItem = cid:addItem(26534, 1)
				setPlayerStorageValue(cid,25001,1)
			else
				doPlayerSendTextMessage(cid,MESSAGE_EVENT_ADVANCE,"The chest is empty.")
			end
		else
		doPlayerSendTextMessage(cid,MESSAGE_EVENT_ADVANCE,"Weapon for Knights.")
		end
	elseif item.uid == 30018 then
   		queststatus = getPlayerStorageValue(cid,25001)
		if cid:isShadow() then
			if queststatus == -1 then
				doPlayerSendTextMessage(cid,MESSAGE_EVENT_ADVANCE,"You have found a T1 Light Knife.")
				createItem = cid:addItem(36675, 1)
				setPlayerStorageValue(cid,25001,1)
			else
				doPlayerSendTextMessage(cid,MESSAGE_EVENT_ADVANCE,"The chest is empty.")
			end
		else
		doPlayerSendTextMessage(cid,MESSAGE_EVENT_ADVANCE,"Weapon for Shadows.")
		end

	else
		
   	end
	
	if createItem then
		createItem:setQuestItem(1)
		setLootItem(cid, createItem, 1, 7000, 4000, 2000)
	end


	if cid:getStorageValue(PlayerStorage.promotionStorage) ~= 1 then
		cid:setStorageValue(PlayerStorage.rebornNeed1, 1)
		cid:setStorageValue(PlayerStorage.promotionStorage, 1)
		cid:setStorageValue(PlayerStorage.reborn, 0)
		cid:addStatsPoints(5)
		local vocId = cid:getVocation():getId()
		if vocId == 17 or vocId == 21 then
			cid:setVocation(vocId + 1)
		else
			cid:setVocation(vocId + 4)
		end
		cid:sendExtendedOpcode(ExtendedOPCodes.CODE_DUNGEONS, json.encode({action = "challenge", data = "First Promotion"}))
	end

   	return true
end
