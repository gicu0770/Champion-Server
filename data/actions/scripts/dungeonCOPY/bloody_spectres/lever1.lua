function onUse(player, item, fromPos, item2, toPos)
local dungeon = player:getDungeon()
if dungeon then
  local instance = dungeon:getPlayerInstance(player)
  if instance then
    local instancePosition = instance:getPosition()
	if item.itemid == 10029 then
	local levers = 0
		if item.actionid == 10531 then	-- {x = 333, y = 112, z = 7}
			local stonePos = { x = instancePosition.x + 266, y =  instancePosition.y + 248, z = 3 }
			doRemoveItem(getTileItemById(stonePos, 9533).uid)
			doTransformItem(item.uid,10030)
			instance:finishBonusObjective(1)
		elseif item.actionid == 10532 then	-- {x = 333, y = 112, z = 7}
			local stonePos = { x = instancePosition.x + 265, y =  instancePosition.y + 248, z = 3 }
			doRemoveItem(getTileItemById(stonePos, 9533).uid)
			doTransformItem(item.uid,10030)
			instance:finishBonusObjective(2)
		end
	end
	player:sendTextMessage(MESSAGE_INFO_DESCR, "There are more levers.")
	
  end
end
return true
end