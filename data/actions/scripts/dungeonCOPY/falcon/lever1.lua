function onUse(player, item, fromPos, item2, toPos)
local dungeon = player:getDungeon()
if dungeon then
  local instance = dungeon:getPlayerInstance(player)
  if instance then
    local instancePosition = instance:getPosition()
	if item.itemid == 10029 then
	local levers = 0
		if item.actionid == 10533 then	-- {x = 333, y = 112, z = 7}
			local stonePos = { x = instancePosition.x + 198, y =  instancePosition.y + 124, z = 1 }
			local stonePos2 = { x = instancePosition.x + 198, y =  instancePosition.y + 125, z = 1 }
			doRemoveItem(getTileItemById(stonePos, 8538).uid)
			doRemoveItem(getTileItemById(stonePos2, 8538).uid)
			doTransformItem(item.uid,10030)
			instance:finishBonusObjective(1)
		elseif item.actionid == 10534 then	-- {x = 333, y = 112, z = 7}
			local stonePos = { x = instancePosition.x + 332, y =  instancePosition.y + 124, z = 1 }
			local stonePos2 = { x = instancePosition.x + 332, y =  instancePosition.y + 125, z = 1 }
			doRemoveItem(getTileItemById(stonePos, 8538).uid)
			doRemoveItem(getTileItemById(stonePos2, 8538).uid)
			doTransformItem(item.uid,10030)
			instance:finishBonusObjective(2)
		elseif item.actionid == 10535 then	-- {x = 333, y = 112, z = 7}
			local stonePos = { x = instancePosition.x + 264, y =  instancePosition.y + 205, z = 1 }
			local stonePos2 = { x = instancePosition.x + 265, y =  instancePosition.y + 205, z = 1 }
			doRemoveItem(getTileItemById(stonePos, 8538).uid)
			doRemoveItem(getTileItemById(stonePos2, 8538).uid)
			doTransformItem(item.uid,10030)
			instance:finishBonusObjective(3)
		elseif item.actionid == 10536 then	-- {x = 333, y = 112, z = 7}
			local stonePos = { x = instancePosition.x + 264, y =  instancePosition.y + 235, z = 1 }
			local stonePos2 = { x = instancePosition.x + 265, y =  instancePosition.y + 235, z = 1 }
			doRemoveItem(getTileItemById(stonePos, 8538).uid)
			doRemoveItem(getTileItemById(stonePos2, 8538).uid)
			doTransformItem(item.uid,10030)
			instance:finishBonusObjective(4)
		end
	end
	player:sendTextMessage(MESSAGE_INFO_DESCR, "There are more levers.")
	
  end
end
return true
end