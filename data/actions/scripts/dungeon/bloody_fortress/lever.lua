function onUse(player, item, fromPos, item2, toPos)
local dungeon = player:getDungeon()
if dungeon then
  local instance = dungeon:getPlayerInstance(player)
  if instance then
    local instancePosition = instance:getPosition()
	if item.itemid == 10029 or item.itemid == 10030 then
	Item(item.uid):transform(item.itemid == 10029 and 10030 or 10029)
	if item.actionid == 10515 then	
		local stonePos = { x = instancePosition.x + 166, y =  instancePosition.y + 67, z = 6 }
		local stonePos2 = { x = instancePosition.x + 167, y =  instancePosition.y + 67, z = 6 }
		doRemoveItem(getTileItemById(stonePos, 23312).uid)
		doRemoveItem(getTileItemById(stonePos2, 23312).uid)
		instance:finishBonusObjective(1)
	elseif item.actionid == 10516 then		-- {x = 203, y = 67, z = 6}
		local stonePos = { x = instancePosition.x + 203, y =  instancePosition.y + 67, z = 6 }
		local stonePos2 = { x = instancePosition.x + 204, y =  instancePosition.y + 67, z = 6 }
		doRemoveItem(getTileItemById(stonePos, 23312).uid)
		doRemoveItem(getTileItemById(stonePos2, 23312).uid)
		instance:finishBonusObjective(2)
	elseif item.actionid == 10513 then
		local stonePos = { x = instancePosition.x + 188, y =  instancePosition.y + 148, z = 6 }
		local stonePos2 = { x = instancePosition.x + 189, y =  instancePosition.y + 148, z = 6 }
		doRemoveItem(getTileItemById(stonePos, 23312).uid)
		doRemoveItem(getTileItemById(stonePos2, 23312).uid)
		instance:finishBonusObjective(3)
	elseif item.actionid == 10514 then
		local stonePos = { x = instancePosition.x + 188, y =  instancePosition.y + 150, z = 6 }
		local stonePos2 = { x = instancePosition.x + 189, y =  instancePosition.y + 150, z = 6 }
		doRemoveItem(getTileItemById(stonePos, 23312).uid)
		doRemoveItem(getTileItemById(stonePos2, 23312).uid)
		instance:finishBonusObjective(4)
	elseif item.actionid == 10517 then
		local stonePos = { x = instancePosition.x + 184, y =  instancePosition.y + 47, z = 5 }
		local stonePos2 = { x = instancePosition.x + 185, y =  instancePosition.y + 47, z = 5 }
		doRemoveItem(getTileItemById(stonePos, 23312).uid)
		doRemoveItem(getTileItemById(stonePos2, 23312).uid)
		instance:finishBonusObjective(5)
	end

	player:sendTextMessage(MESSAGE_INFO_DESCR, "There are more levers.")


    end
  end
end
return true
end