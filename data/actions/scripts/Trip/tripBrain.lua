function onUse(cid, item, fromPosition, itemEx, toPosition)
	Item(item.uid):transform(item.itemid == 9825 and 9826 or 9825)
	local player = Player(cid)
	local basicPos = {x = 586, y = 1612, z = 12}
	local tpPos = {x = 588, y = 1614, z = 12}
	local tile = Tile(basicPos)
	
	if tile:getItemById(5808) then
		local kasa = tile:getItemById(5808)
		if kasa:getCount() >= 1 then
			kasa:remove(1)
			Position(basicPos):sendMagicEffect(40)
			player:teleportTo(tpPos)
			else
			doPlayerSendTextMessage(cid,19,"You need Orshabaal's brain.")
		end
            doPlayerSendTextMessage(cid,19,"You spent Orshabaal's brain.")
	else
            doPlayerSendTextMessage(cid,19,"Put Orshabaal's brain.")
	end
	return true
end