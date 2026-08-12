local pos = {
	[20025] = {x = 1371, y = 114, z = 11, stackpos=1},
	[20026] = {x = 1373, y = 114, z = 11, stackpos=1},
	[20027] = {x = 1375, y = 114, z = 11, stackpos=1},
	[20028] = {x = 1377, y = 114, z = 11, stackpos=1}
}

local function doRemoveFirewalls(fwPos)
        local tile = Position(fwPos):getTile()
        if tile then
                local thing = tile:getItemById(6289)
                if thing and thing:isItem() then
                        thing:remove()
                end
        end
end

function onUse(cid, item, fromPosition, itemEx, toPosition)
	if(item.itemid == 1945) then
		--doRemoveFirewalls(pos[item.uid])

		doRemoveItem(getThingfromPos(pos[item.uid]).uid, 1)
		print(getThingfromPos(pos[item.uid]).uid)
		Position(pos[item.uid]):sendMagicEffect(CONST_ME_FIREAREA)
	else
		Game.createItem(6289, 1, pos[item.uid])
		Position(pos[item.uid]):sendMagicEffect(CONST_ME_FIREAREA)
	end
	Item(item.uid):transform(item.itemid == 1945 and 1946 or 1945)
	return true
end
