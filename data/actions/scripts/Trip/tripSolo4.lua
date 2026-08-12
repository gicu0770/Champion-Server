local removePos = Position(814, 1651, 12)
local createPos1 = Position(812, 1651, 12) -- za plecami
local createPos2 = Position(819, 1651, 12) -- koniec rooma
local bossPos =  Position(814, 1651, 12)

local playerPosition = {
	{x = 813, y = 1651, z = 12}
}


local function resetTRIP(p)
    doTransformItem(getTileItemById(p, 9826).uid, 9825)
end

function onUse(cid, item, fromPosition, itemEx, toPosition)
local players = {}
for _, position in ipairs(playerPosition) do
			local topPlayer = Tile(position):getTopCreature()
			if not topPlayer or not topPlayer:isPlayer() then
				cid:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
				return false
			end
			players[#players + 1] = topPlayer
		end


        if item.itemid == 9826 then
            doPlayerSendCancel(cid, "Please wait until the timer resets")
        elseif item.itemid == 9825 then
		--ttt:teleportTo(Position(809, 1646, 12))
            doRemoveItem (getTileItemById(removePos, 3377).uid) --Same item's ID AND Position that you want to remove
		doCreateItem(3377, 1, createPos1)
		doCreateItem(3377, 1, createPos2)
		Game.createMonster("Shadow Demon", bossPos)
            doSendMagicEffect(removePos, 5)
            doTransformItem(item.uid, 9826)
            doPlayerSendTextMessage(cid,19,"Hear noise from above.") --A message that the player gets informing him that something has happened.
            addEvent(resetTRIP, 5 * 60 * 1000, toPosition) --Timer for the item to be created again.
        else
        stopEvent(event)
        resetTRIP(toPosition)
        end
    return true
end