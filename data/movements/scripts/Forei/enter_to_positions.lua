local tpTo = {x = 1090, y = 1440, z = 8} -- Place to teleport the player to
local AID = 8583 -- ActionID

function onStepIn(cid, item, position, fromPosition)
     if(item.actionid ~= AID) then
           return true
     end
        if(getPlayerLevel(cid) >= 35) then
		doTeleportThing(cid, tpTo)
		doSendMagicEffect(getPlayerPosition(cid), 2)
        else
                doTeleportThing(cid, fromPosition)
            doPlayerSendTextMessage(cid,19,"You need a higher level to explore the underwater world!")
	end
	return true
end