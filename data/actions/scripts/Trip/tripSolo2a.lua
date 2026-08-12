local createPos = Position(814, 1643, 12)
local removePos1 = Position(812, 1643, 12) -- za plecami
local removePos2 = Position(819, 1643, 12) -- koniec rooma
local removeFire = Position(824, 1646, 12) -- koniec rooma

local function resetTRIP(p)
    doTransformItem(getTileItemById(p, 9826).uid, 9825)
end

local function resetFIRE(p)
    doCreateItem(6289, 1, removeFire) --Item's ID AND Position that you want to remove
end

function onUse(cid, item, fromPosition, itemEx, toPosition)
        if item.itemid == 9826 then
            doPlayerSendCancel(cid, "Please wait until the timer resets")
        elseif item.itemid == 9825 then
            doRemoveItem (getTileItemById(removePos1, 3377).uid) --Same item's ID AND Position that you want to remove
		doRemoveItem (getTileItemById(removePos2, 3377).uid)
		doRemoveItem (getTileItemById(removeFire, 6289).uid) -- fire wall
		doCreateItem(3377, 1, createPos)
            doSendMagicEffect(removePos1, 5)
            doTransformItem(item.uid, 9826)
            doPlayerSendTextMessage(cid,19,"Hear noise from above.") --A message that the player gets informing him that something has happened.
            addEvent(resetTRIP, 5 * 60 * 1000, toPosition) --Timer for the item to be created again.
		addEvent(resetFIRE, 15 * 60 * 1000, toPosition) --Timer for the item to be created again.
        else
        stopEvent(event)
        resetTRIP(toPosition)
        end
    return true
end