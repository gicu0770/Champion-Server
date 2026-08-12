local removePos = Position(641, 1644, 14)
local removePos2 = Position(642, 1644, 14)

local function resetTRIP(p)
    doTransformItem(getTileItemById(p, 9826).uid, 9825)
    doCreateItem(3417, 1, removePos) --Item's ID AND Position that you want to remove
    doCreateItem(3418, 1, removePos2)
    doSendMagicEffect(removePos, 18) --Item's Position and magic effect for the item that's going to be removed.
    doSendMagicEffect(removePos2, 18)
end

function onUse(cid, item, fromPosition, itemEx, toPosition)
	local player = Player(cid)
	local dicepos1 = Position(645, 1644, 14)
	local dicepos2 = Position(646, 1644, 14)
	local dicepos3 = Position(647, 1644, 14)
	local tile1 = Tile(dicepos1)
	local tile2 = Tile(dicepos2)
	local tile3 = Tile(dicepos3)
	
       if item.itemid == 9826 then
            doPlayerSendCancel(cid, "Please wait until the timer resets")
        elseif item.itemid == 9825 and tile1:getItemById(5795) and  tile2:getItemById(5792) and tile3:getItemById(5793) then
            doRemoveItem (getTileItemById(removePos, 3417).uid) --Same item's ID AND Position that you want to remove
		doRemoveItem (getTileItemById(removePos2, 3418).uid)
		
		doRemoveItem (getTileItemById(dicepos1, 5795).uid)
		doRemoveItem (getTileItemById(dicepos2, 5792).uid)
		doRemoveItem (getTileItemById(dicepos3, 5793).uid)
		doSendMagicEffect(dicepos1, 18)
		doSendMagicEffect(dicepos2, 18)
		doSendMagicEffect(dicepos3, 18)
											
            doSendMagicEffect(removePos, 18)
            doSendMagicEffect(removePos2, 18)
            doTransformItem(item.uid, 9826)
            doPlayerSendTextMessage(cid,19,"The wall disappeared. You have a minute to move on!") --A message that the player gets informing him that something has happened.
            addEvent(resetTRIP, 60 * 1000, toPosition) --Timer for the item to be created again.
        else
	doPlayerSendTextMessage(cid,19,"Wrong dice.")
       -- stopEvent(event)
       -- resetTRIP(toPosition)
        end

		
			

	return true
end