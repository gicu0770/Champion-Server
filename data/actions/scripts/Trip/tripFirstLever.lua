function onUse(cid, item, fromPosition, itemEx, toPosition)
	Item(item.uid):transform(item.itemid == 9825 and 9826 or 9825)
	local player = Player(cid)
	local basicPos = {x = 536, y = 1723, z = 12}
	local tpPos = {x = 537, y = 1721, z = 12}
	local tile = Tile(basicPos)
	
	if tile:getItemById(2160) then
		local kasa = tile:getItemById(2160)
		if kasa:getCount() >= 100 then
			kasa:remove(100)
			Position(basicPos):sendMagicEffect(40)
			player:teleportTo(tpPos)
			else
			doPlayerSendTextMessage(cid,19,"You need 100CC.")
		end
            doPlayerSendTextMessage(cid,19,"You spent too little money.")
	else
            doPlayerSendTextMessage(cid,19,"Put money in crystal coin 100.")
	end
	return true
end