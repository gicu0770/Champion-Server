local stonepos = {x=851, y=438, z=11, stackpos=1}
local stonepos2 = {x=851, y=439, z=11, stackpos=1}
local itemex = nil


function onTimer21()
    doTransformItem(itemex.uid,1945)
	doCreateItem(1546,1,{x=851, y=438, z=11})
	doCreateItem(1546,1,{x=851, y=439, z=11})
end

function onUse(cid, item, fromPos, item2, toPos)
    itemex = item
    if item.itemid == 1945 then
	doRemoveItem(getThingfromPos(stonepos).uid, 1)
	doRemoveItem(getThingfromPos(stonepos).uid, 1)
	doRemoveItem(getThingfromPos(stonepos2).uid, 1)
	doRemoveItem(getThingfromPos(stonepos2).uid, 1)
    doTransformItem(item.uid,1946)
    addEvent(onTimer21, 30*1000)
    end
return true
end