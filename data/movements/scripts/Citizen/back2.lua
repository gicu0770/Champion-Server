local tpTo = {x = 586, y = 1111, z = 6} -- Place to teleport the player to
local AID = 32002 -- ActionID

function onStepIn(cid, item, position, fromPosition)
     if(item.actionid ~= AID) then
           return true
     end
        if(getPlayerLevel(cid) >= 0) then
		doTeleportThing(cid, tpTo)
		doSendMagicEffect(getPlayerPosition(cid), 11)
        else
                doTeleportThing(cid, fromPosition)
	end
	return true
end