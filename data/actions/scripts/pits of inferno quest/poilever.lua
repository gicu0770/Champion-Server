local stonepos = {x=1326, y=93, z=11, stackpos=1} -- Stone pos
doSendMagicEffect({x=1326, y=93, z=11}, 5) --Item's Position and magic effect for the item that's going to be removed.
function onUse(cid, item, fromPos, item2, toPos)
    if item.itemid == 1945 then
	doRemoveItem(getThingfromPos(stonepos).uid, 1)
        doTransformItem(item.uid,1946)
        addEvent(onTimer12, 1*60*1000) --15minutes
    end
return true
end

function onTimer12() --creates wall back
    doTransformItem(getThingfromPos({x=1324, y=97, z=11, stackpos=1}).uid, 1945)--lever pos
	doCreateItem(1304,1,{x=1326, y=93, z=11})-- Stone pos
            doSendMagicEffect({x=1326, y=93, z=11}, 5)
end