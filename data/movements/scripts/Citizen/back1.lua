local tpTo = {x = 604, y = 1095, z = 5} -- Place to teleport the player to
local AID = 32001 -- ActionID

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