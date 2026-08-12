function onUse(player, item, fromPos, item2, toPos)
local dungeon = player:getDungeon()
if dungeon then
  local instance = dungeon:getPlayerInstance(player)
  if instance then
    local instancePosition = instance:getPosition()
	if item.itemid == 10029 or item.itemid == 10030 then
	Item(item.uid):transform(item.itemid == 10029 and 10030 or 10029)
	local levers = 0
		if item.actionid == 10520 then	-- {x = 333, y = 112, z = 7}
			local stonePos = { x = instancePosition.x + 409, y =  instancePosition.y + 280, z = 4 }
			doRemoveItem(getTileItemById(stonePos, 29189).uid)
			
			instance:finishBonusObjective(2)
		end
	end
	player:sendTextMessage(MESSAGE_INFO_DESCR, "There are more levers.")
	
  end
end
return true
end