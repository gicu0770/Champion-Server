function onStepIn(cid, item, position, fromPosition)
	Game.createItem(5543, 1, Position(1394, 102, 11))
	doCreatureSay(cid, "You hear a rumbling from far away.", TALKTYPE_MONSTER_SAY)
	if item.itemid == 426 then
        doTransformItem(item.uid,item.itemid-1)
    else
    end
	return true
end

function onStepOut(cid, item)
	Tile(Position(1394, 102, 11)):getItemById(5543):remove()
	--doCreatureSay(cid, "The final lever won't budge... yet.", TALKTYPE_MONSTER_SAY)
	--doRemoveItem(getThingfromPos(stonepos).uid, 1)
	if item.itemid == 425 then
        doTransformItem(item.uid,item.itemid+1)
    else
        
    end
	return true
end