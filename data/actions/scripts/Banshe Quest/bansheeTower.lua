local function reset(p)
    doTransformItem(getTileItemById(p, 1946).uid, 1945)
    doCreateItem(1355, 1, {x=1170, y=714, z=6}) --Item's ID AND Position that you want to remove
    doSendMagicEffect({x=1170, y=714, z=6}, 5) --Item's Position and magic effect for the item that's going to be removed.
end

function onUse(cid, item, fromPosition, itemEx, toPosition)
  
        if item.itemid == 1946 then
            doPlayerSendCancel(cid, "Please wait until the timer resets")
        elseif item.itemid == 1945 then
            doRemoveItem (getTileItemById({x= 1170, y=714, z=6}, 1355).uid) --Same item's ID AND Position that you want to remove
            doSendMagicEffect({x= 1170, y=714, z=6}, 5)
            doTransformItem(item.uid, 1946)
            doPlayerSendTextMessage(cid,19,"Hear noise from above.") --A message that the player gets informing him that something has happened.
            addEvent(reset, 1 * 10 * 1000, toPosition) --Timer for the item to be created again.
        else
        stopEvent(event)
        reset(toPosition)
        end
    return true
end