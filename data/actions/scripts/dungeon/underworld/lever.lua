function onUse(player, item, fromPos, item2, toPos)

local dungeon = player:getDungeon()
if dungeon then
  local instance = dungeon:getPlayerInstance(player)
  if instance then
    local instancePosition = instance:getPosition()

	if item.itemid == 9825 or item.itemid == 9826 then
	Item(item.uid):transform(item.itemid == 9825 and 9826 or 9825)
		local stonePos = { x = instancePosition.x + 36, y =  instancePosition.y + 13, z = 7 }
		doRemoveItem(getTileItemById(stonePos, 5152).uid)
		
		player:finishBonusObjective(1)
	end
	
	
  end
end
return true
end