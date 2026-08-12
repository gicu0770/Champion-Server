function onUse(cid, item, fromPosition, itemEx, toPosition)
	local player = Player(cid)
	Item(item.uid):transform(item.itemid == 1945 and 1946 or 1945)
	local tile = Tile({x = 1409, y = 613, z = 13})
	
	
	local feather = tile:getItemById(2366)
	local chance = 65
	
	if feather then
		feather:remove()
		if math.random(1, 100) <= chance then
			player:teleportTo({x = 1412, y = 614, z = 13})
			Position({x = 1409, y = 613, z = 13}):sendMagicEffect(4)
			Position({x = 1412, y = 614, z = 13}):sendMagicEffect(CONST_ME_TELEPORT)
		else
			Position({x = 1409, y = 613, z = 13}):sendMagicEffect(3)
            doPlayerSendTextMessage(cid,19,"This time it failed. Find and put new ones in here 'roc feather'.")
		end
	else
            doPlayerSendTextMessage(cid,19,"Find some feather...")
		return Position({x = 1409, y = 613, z = 13}):sendMagicEffect(3)
	end
	return true
end