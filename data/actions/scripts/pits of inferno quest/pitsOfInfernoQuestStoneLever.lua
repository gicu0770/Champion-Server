local stonepos = {x =1389, y =63, z =10, stackpos=1} -- Stone pos
function onTimer20() --creates wall back
    doTransformItem(getThingfromPos({x=1390, y=49, z=10, stackpos=1}).uid, 1945)--lever pos
	doCreateItem(1304,1,{x =1389, y =63, z =10})-- Stone pos
    doSendMagicEffect({x =1389, y =63, z =10}, 7)
end

function onUse(cid, item, fromPos, item2, toPos)
    if item.itemid == 1945 then
	doSendMagicEffect({x =1389, y =63, z =10}, 7)
	doRemoveItem(getThingfromPos(stonepos).uid, 1)
    doTransformItem(item.uid,1946)
    addEvent(onTimer20, 3*60*1000) --15minutes
    end
return true
end