function onUse(cid, item, fromPosition, itemEx, toPosition)
	Item(item.uid):transform(item.itemid == 1945 and 1946 or 1945)
	local player = Player(cid)
	local basicPos = {x = 1365, y = 644, z = 15}
	local banshePos = {x = 1362, y = 643, z = 15}
	
	local tile = Tile(basicPos)
	
	if tile:getItemById(2125) then
		local kasa = tile:getItemById(2125)
		if kasa:getCount() >= 1 then
			kasa:remove(1)
			Position(basicPos):sendMagicEffect(40)
			Game.createMonster("Banshee", banshePos)
			Game.createMonster("Banshee", banshePos)
			Game.createMonster("Banshee", banshePos)
			Game.createMonster("Banshee", banshePos)
			Game.createMonster("Banshee", banshePos)
			return Game.createItem(2366, 1, basicPos)
		end
            doPlayerSendTextMessage(cid,MESSAGE_INFO_DESCR,"You spent Crystal Amulet and obtain Roc Feather.")
	else
            doPlayerSendTextMessage(cid,MESSAGE_INFO_DESCR,"Put Crystal Amulet.")
	end
	return true
end