function onUse(player, item, fromPos, item2, toPos)
local dungeon = player:getDungeon()
if dungeon then
  local instance = dungeon:getPlayerInstance(player)
  if instance then
    local instancePosition = instance:getPosition()
	if item.itemid == 9826 then
	local levers = 0
		if item.actionid == 10521 then
			local stonePos = { x = instancePosition.x + 390, y =  instancePosition.y + 338, z = 2 }
			local stonePos2 = { x = instancePosition.x + 391, y =  instancePosition.y + 338, z = 2 }
			local stonePos3 = { x = instancePosition.x + 392, y =  instancePosition.y + 338, z = 2 }
			doRemoveItem(getTileItemById(stonePos, 23315).uid)
			doRemoveItem(getTileItemById(stonePos2, 23315).uid)
			doRemoveItem(getTileItemById(stonePos3, 23315).uid)
			doTransformItem(item.uid,9825)
			instance:finishBonusObjective(1)
		elseif item.actionid == 10522 then
			local stonePos = { x = instancePosition.x + 390, y =  instancePosition.y + 345, z = 2 }
			local stonePos2 = { x = instancePosition.x + 391, y =  instancePosition.y + 345, z = 2 }
			local stonePos3 = { x = instancePosition.x + 392, y =  instancePosition.y + 345, z = 2 }
			doRemoveItem(getTileItemById(stonePos, 23315).uid)
			doRemoveItem(getTileItemById(stonePos2, 23315).uid)
			doRemoveItem(getTileItemById(stonePos3, 23315).uid)
			doTransformItem(item.uid,9825)
			instance:finishBonusObjective(2)
		elseif item.actionid == 10523 then
			local stonePos = { x = instancePosition.x + 384, y =  instancePosition.y + 341, z = 2 }
			local stonePos2 = { x = instancePosition.x + 384, y =  instancePosition.y + 342, z = 2 }
			local stonePos3 = { x = instancePosition.x + 384, y =  instancePosition.y + 343, z = 2 }
			local stonePos4 = { x = instancePosition.x + 397, y =  instancePosition.y + 341, z = 2 }
			local stonePos5 = { x = instancePosition.x + 397, y =  instancePosition.y + 342, z = 2 }
			local stonePos6 = { x = instancePosition.x + 397, y =  instancePosition.y + 343, z = 2 }
			doRemoveItem(getTileItemById(stonePos, 23316).uid)
			doRemoveItem(getTileItemById(stonePos2, 23316).uid)
			doRemoveItem(getTileItemById(stonePos3, 23316).uid)
			doRemoveItem(getTileItemById(stonePos4, 23316).uid)
			doRemoveItem(getTileItemById(stonePos5, 23316).uid)
			doRemoveItem(getTileItemById(stonePos6, 23316).uid)
			doTransformItem(item.uid,9825)
			instance:finishBonusObjective(3)
		elseif item.actionid == 10524 then
			local stonePos = { x = instancePosition.x + 383, y =  instancePosition.y + 342, z = 3 }
			local stonePos2 = { x = instancePosition.x + 397, y =  instancePosition.y + 342, z = 3 }
			doRemoveItem(getTileItemById(stonePos, 23316).uid)
			doRemoveItem(getTileItemById(stonePos2, 23316).uid)
			doTransformItem(item.uid,9825)
			instance:finishBonusObjective(4)
		elseif item.actionid == 10525 then
			local stonePos = { x = instancePosition.x + 390, y =  instancePosition.y + 345, z = 1 }
			local stonePos2 = { x = instancePosition.x + 391, y =  instancePosition.y + 345, z = 1 }
			doRemoveItem(getTileItemById(stonePos, 23312).uid)
			doRemoveItem(getTileItemById(stonePos2, 23312).uid)
			doTransformItem(item.uid,9825)
			instance:finishBonusObjective(5)
		elseif item.actionid == 10526 then
			local stonePos = { x = instancePosition.x + 390, y =  instancePosition.y + 330, z = 3 }
			local stonePos2 = { x = instancePosition.x + 391, y =  instancePosition.y + 330, z = 3 }
			doRemoveItem(getTileItemById(stonePos, 23312).uid)
			doRemoveItem(getTileItemById(stonePos2, 23312).uid)
			doTransformItem(item.uid,9825)
			instance:finishBonusObjective(6)
		end
	end
	player:sendTextMessage(MESSAGE_INFO_DESCR, "There are more levers.")
	
  end
end
return true
end