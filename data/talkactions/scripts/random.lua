local function isBadTileOEN(tile)
	return (tile == nil 
	or tile:getGround() == nil 
	or tile:hasProperty(TILESTATE_NONE) 
	or tile:hasProperty(TILESTATE_FLOORCHANGE_EAST) 
	or tile:hasFlag(TILESTATE_FLOORCHANGE)
	or tile:hasFlag(TILESTATE_HOUSE)
	or tile:hasFlag(TILESTATE_BLOCKSOLID)
	or isItem(tile:getThing()) and not isMoveable(tile:getThing()) 
	or tile:getTopCreature() 
	or not tile:isWalkable()
	or tile:hasFlag(TILESTATE_PROTECTIONZONE)
	)
end
function onSay(player, words, param)
	if not player:getGroup():getAccess() then
		return true
	end
	local tile = Tile(player:getPosition())
	if isBadTileOEN(tile) then
		player:sendTextMessage(MESSAGE_INFO_DESCR, "Title TRUE.")
	else
		player:sendTextMessage(MESSAGE_INFO_DESCR, "Tile FALSE.")
	end


	return false
end
