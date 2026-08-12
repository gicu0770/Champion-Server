local removePos = Position(787, 1646, 12)

local function resetTRIP(p)
    doTransformItem(getTileItemById(p, 9826).uid, 9825)
    doCreateItem(3377, 1, removePos) --Item's ID AND Position that you want to remove
    doSendMagicEffect(removePos, 5) --Item's Position and magic effect for the item that's going to be removed.
end

function onUse(cid, item, fromPosition, itemEx, toPosition)
  
        if item.itemid == 9826 then
            doPlayerSendCancel(cid, "Please wait until the timer resets")
        elseif item.itemid == 9825 then
            doRemoveItem (getTileItemById(removePos, 3377).uid) --Same item's ID AND Position that you want to remove
            doSendMagicEffect(removePos, 5)
            doTransformItem(item.uid, 9826)
            doPlayerSendTextMessage(cid,19,"The gate was opened for 5 minutes!") --A message that the player gets informing him that something has happened.
            addEvent(resetTRIP, 5 * 60 * 1000, toPosition) --Timer for the item to be created again.
        else
        stopEvent(event)
        resetTRIP(toPosition)
        end
    return true
end