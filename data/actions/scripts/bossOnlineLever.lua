function onUse(cid, item, fromPosition, itemEx, toPosition)
	if item.itemid == 9825 or item.itemid == 9826 then
	Item(item.uid):transform(item.itemid == 9825 and 9826 or 9825)
	local player = Player(cid)
	local basicPos = Position(760, 1000, 9) -- kapliczka gdzie sie kladzie item
	local easyTeleport = Position(1594,220,7)
	local mediumTeleport = Position(1471,168,7)
	local hardTeleport = Position(1527,223,7)
	local expertTeleport = Position(1598,165,7)
	local masterTeleport = Position(1532,175,7)
	
	local easyArena, easyRange, easyBossPos = Position(1595,226,7), 14, Position(1598,220,7)
	local mediumArena,mediumRange, mediumBossPos = Position(1472,168,7), 14, Position(1467,168,7)
	local hardArena, hardRange, hardBossPos = Position(1531,226,7), 14, Position(1536,222,7)
	local expertArena,expertRange, expertBossPos = Position(1593,171,7), 14, Position(1590,164,7)
	local masterArena, masterRange, masterBossPos = Position(1532,172,7), 14, Position(1532,169,7)

	local tile = Tile(basicPos)
	local thing = tile:getTopVisibleThing(player)
	if cid:getLevel() < 150 then
	doPlayerSendTextMessage(cid,MESSAGE_INFO_DESCR,"You need 150 Level+ to summon bosses!")
	return false
	end
	if thing:getId() == 29721 then



-------------------------CHECK ARENA	

	--if thing:getAttribute(ITEM_ATTRIBUTE_NAME) == "Easy Boss Scroll" or thing:getAttribute(ITEM_ATTRIBUTE_NAME) == "Low Boss Scroll" then
	if thing:getName():find("Easy") then
	local creatrures = Game.getSpectators(easyArena, false, false, easyRange, easyRange, easyRange, easyRange)
	for _, creature in pairs(creatrures) do
		if Player(creature:getId()) then
			Position(player:getPosition()):sendMagicEffect(CONST_ME_POFF)
			player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Somebody is inside! EASY ARENA")
			return false
		end
	end	
	--elseif thing:getAttribute(ITEM_ATTRIBUTE_NAME) == "Medium Boss Scroll" then
	elseif thing:getName():find("Medium") then
	local creatrures = Game.getSpectators(mediumArena, false, false, mediumRange, mediumRange, mediumRange, mediumRange)
	for _, creature in pairs(creatrures) do
		if Player(creature:getId()) then
			Position(player:getPosition()):sendMagicEffect(CONST_ME_POFF)
			player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Somebody is inside! MEDIUM ARENA")
			return false
		end
	end	
	--elseif thing:getAttribute(ITEM_ATTRIBUTE_NAME) == "Hard Boss Scroll" or thing:getAttribute(ITEM_ATTRIBUTE_NAME) == "High Boss Scroll" then
	elseif thing:getName():find("Hard") then
	local creatrures = Game.getSpectators(hardArena, false, false, hardRange, hardRange, hardRange, hardRange)
	for _, creature in pairs(creatrures) do
		if Player(creature:getId()) then
			Position(player:getPosition()):sendMagicEffect(CONST_ME_POFF)
			player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Somebody is inside! HARD ARENA")
			return false
		end
	end	
	--elseif thing:getAttribute(ITEM_ATTRIBUTE_NAME) == "Expert Boss Scroll" then
	elseif thing:getName():find("Expert") then
	local creatrures = Game.getSpectators(expertArena, false, false, expertRange, expertRange, expertRange, expertRange)
	for _, creature in pairs(creatrures) do
		if Player(creature:getId()) then
			Position(player:getPosition()):sendMagicEffect(CONST_ME_POFF)
			player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Somebody is inside! EXPERT ARENA")
			return false
		end
	end	
	--elseif thing:getAttribute(ITEM_ATTRIBUTE_NAME) == "Master Boss Scroll" then
	elseif thing:getName():find("Master") then
	local creatrures = Game.getSpectators(masterArena, false, false, masterRange, masterRange, masterRange, masterRange)
	for _, creature in pairs(creatrures) do
		if Player(creature:getId()) then
			Position(player:getPosition()):sendMagicEffect(CONST_ME_POFF)
			player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Somebody is inside! MASTER ARENA")
			return false
		end
	end	
end
-------------------------CHECK ARENA
	if not thing:getName():find(""..player:getName().."") then
	doPlayerSendTextMessage(player,MESSAGE_INFO_DESCR,"This is not yours scroll!")
	return false
	end
	if thing:getName():find("Easy Boss Scroll") then
		if player:getLevel() >= 50 then
		local creatrures = Game.getSpectators(easyArena, false, false, easyRange, easyRange, easyRange, easyRange)
		local monsters = {}
		for _, creature in pairs(creatrures) do
			if Monster(creature:getId()) then
				table.insert(monsters, creature:getId())
			elseif Player(creature:getId()) then
				return false
			end
		end
		for i=1, #monsters do
			Monster(monsters[i]):remove()
		end
	
			Position(basicPos):sendMagicEffect(40)
			local boss = Game.createMonster("White Fox", easyBossPos)
			boss:registerEvent("BossKICK")
			player:teleportTo(easyTeleport)
			doPlayerSendTextMessage(player,MESSAGE_INFO_DESCR,"You summoned White Fox! You have 30min to kill him!")
		else
			doPlayerSendTextMessage(player,MESSAGE_INFO_DESCR,"You need 50 Level or higher!")
		end
	elseif thing:getName():find("Medium Boss Scroll") then
		if player:getLevel() >= 100 then
		local creatrures = Game.getSpectators(mediumArena, false, false, mediumRange, mediumRange, mediumRange, mediumRange)
		local monsters = {}
		for _, creature in pairs(creatrures) do
			if Monster(creature:getId()) then
				table.insert(monsters, creature:getId())
			elseif Player(creature:getId()) then
				return false
			end
		end
		for i=1, #monsters do
			Monster(monsters[i]):remove()
		end
			Position(basicPos):sendMagicEffect(40)
			local boss = Game.createMonster("Undead Angler", mediumBossPos)
			boss:registerEvent("BossKICK")
			player:teleportTo(mediumTeleport)
			doPlayerSendTextMessage(player,MESSAGE_INFO_DESCR,"You summoned Undead Angler! You have 30min to kill him!")
		else
			doPlayerSendTextMessage(player,MESSAGE_INFO_DESCR,"You need 100 Level or higher!")
		end
	elseif thing:getName():find("Hard Boss Scroll") then
		if player:getLevel() >= 150 then
		local creatrures = Game.getSpectators(hardArena, false, false, hardRange, hardRange, hardRange, hardRange)
		local monsters = {}
		for _, creature in pairs(creatrures) do
			if Monster(creature:getId()) then
				table.insert(monsters, creature:getId())
			elseif Player(creature:getId()) then
				return false
			end
		end
		for i=1, #monsters do
			Monster(monsters[i]):remove()
		end
			Position(basicPos):sendMagicEffect(40)
			local boss = Game.createMonster("Bloody Tentacles", hardBossPos)
			boss:registerEvent("BossKICK")
			player:teleportTo(hardTeleport)
			doPlayerSendTextMessage(player,MESSAGE_INFO_DESCR,"You summoned Bloody Tentacles! You have 30min to kill him!")
		else
			doPlayerSendTextMessage(player,MESSAGE_INFO_DESCR,"You need 150 Level or higher!")
		end
	elseif thing:getName():find("Expert Boss Scroll") then
		if player:getLevel() >= 200 then
		local creatrures = Game.getSpectators(expertArena, false, false, expertRange, expertRange, expertRange, expertRange)
		local monsters = {}
		for _, creature in pairs(creatrures) do
			if Monster(creature:getId()) then
				table.insert(monsters, creature:getId())
			elseif Player(creature:getId()) then
				return false
			end
		end
		for i=1, #monsters do
			Monster(monsters[i]):remove()
		end
			Position(basicPos):sendMagicEffect(40)
			local boss = Game.createMonster("Electric Nightmare", expertBossPos)
			boss:registerEvent("BossKICK")
			player:teleportTo(expertTeleport)
			doPlayerSendTextMessage(player,MESSAGE_INFO_DESCR,"You summoned Electric Nightmare! You have 30min to kill him!")
		else
			doPlayerSendTextMessage(player,MESSAGE_INFO_DESCR,"You need 200 Level or higher!")
		end
	elseif thing:getName():find("Master Boss Scroll") then
		if player:getLevel() >= 250 then
		local creatrures = Game.getSpectators(masterArena, false, false, masterRange, masterRange, masterRange, masterRange)
		local monsters = {}
		for _, creature in pairs(creatrures) do
			if Monster(creature:getId()) then
				table.insert(monsters, creature:getId())
			elseif Player(creature:getId()) then
				return false
			end
		end
		for i=1, #monsters do
			Monster(monsters[i]):remove()
		end
			Position(basicPos):sendMagicEffect(40)
			local boss = Game.createMonster("Gorn", masterBossPos)
			boss:registerEvent("BossKICK")
			player:teleportTo(masterTeleport)
			doPlayerSendTextMessage(player,MESSAGE_INFO_DESCR,"You summoned Gorn! You have 30min to kill him!")
		else
			doPlayerSendTextMessage(player,MESSAGE_INFO_DESCR,"You need 250 Level or higher!")
		end
	else
            doPlayerSendTextMessage(player,MESSAGE_INFO_DESCR,"Put the scroll on the shrine.")
			return false
	end		
	else
	doPlayerSendTextMessage(player,MESSAGE_INFO_DESCR,"Put the scroll on the shrine.")
	return false
	end
		local kasa = tile:getItemById(29721)	
		kasa:remove(1)	
else
	return false
	end
	return true
end