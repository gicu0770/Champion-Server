function onUse(player, item, fromPos, item2, toPos)

local dungeon = player:getDungeon()
if dungeon then
  local instance = dungeon:getPlayerInstance(player)
  if instance then
    local instancePosition = instance:getPosition()

	if item.itemid == 9825 then
		local stonePos = { x = instancePosition.x + 36, y =  instancePosition.y + 13, z = 7 }
		doRemoveItem(getTileItemById(stonePos, 5152).uid)
		doTransformItem(item.uid,9826)
		player:finishBonusObjective(1)
	end
	
	
  end
end
return true
end