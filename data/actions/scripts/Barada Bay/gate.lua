local upgGatePos = {x = 1213, y = 656, z = 10}

function onUse(cid, item, fromPosition, itemEx, toPosition)
Item(item.uid):transform(item.itemid == 9825 and 9826 or 9825)
	local player = Player(cid)
	
	local checkTile = Tile(upgGatePos)
	

	for i = 0, 1 do
		if Tile(Position(upgGatePos)+{y=i}):getItemById(9533) then
			Tile(Position(upgGatePos)+{y=i}):getPosition():sendMagicEffect(3)
			Tile(Position(upgGatePos)+{y=i}):getItemById(9533):remove()
           		doPlayerSendTextMessage(cid,19,"You opened the gate!")



		else
			if #Tile(Position(upgGatePos)+{y=i}):getCreatures() > 0 then
				for j=1, #Tile(Position(upgGatePos)+{y=i}):getCreatures() do
					Tile(Position(upgGatePos)+{y=i}):getCreatures()[j]:teleportTo(Position(upgGatePos)+{x=1,y=i})
				end
			end
			Game.createItem(9533, 1, Tile(Position(upgGatePos)+{y=i}):getPosition())
			Tile(Position(upgGatePos)+{y=i}):getPosition():sendMagicEffect(4)
           		doPlayerSendTextMessage(cid,19,"You closed the gate!")

		end
	end
	return true;
end