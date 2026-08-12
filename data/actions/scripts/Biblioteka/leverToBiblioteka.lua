function onUse(cid, item, fromPosition, itemEx, toPosition)
	local player = Player(cid)
	Item(item.uid):transform(item.itemid == 1945 and 1946 or 1945)
	local tile = Tile({x = 1539, y = 341, z = 8})
	
	
	local feather = tile:getItemById(11367)
	local chance = 65
	
	if feather then
		feather:remove()
		if math.random(1, 100) <= chance then
			player:teleportTo({x = 1539, y = 340, z = 8})
			Position({x = 1539, y = 341, z = 8}):sendMagicEffect(4)
			Position({x = 1539, y = 340, z = 8}):sendMagicEffect(CONST_ME_TELEPORT)
		else
			Position({x = 1539, y = 341, z = 8}):sendMagicEffect(3)
            doPlayerSendTextMessage(cid,19,"This time it failed. Find and put new ones in here 'undead heart'.")
		end
	else
            doPlayerSendTextMessage(cid,19,"Find some heart...")
		return Position({x = 1539, y = 341, z = 8}):sendMagicEffect(3)
	end
	return true
end