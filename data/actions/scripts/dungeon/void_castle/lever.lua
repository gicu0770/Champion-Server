function onUse(player, item, fromPos, item2, toPos)
local dungeon = player:getDungeon()
if dungeon then
  local instance = dungeon:getPlayerInstance(player)
  if instance then
    local instancePosition = instance:getPosition()
	if item.itemid == 1945 or item.itemid == 1946 then
	Item(item.uid):transform(item.itemid == 1945 and 1946 or 1945)
	if item.actionid == 10509 then	
		local stonePos = { x = instancePosition.x + 237, y =  instancePosition.y + 319, z = 5 }	
		doRemoveItem(getTileItemById(stonePos, 12383).uid)
		
		instance:finishBonusObjective(1)
	elseif item.actionid == 10510 then
		local stonePos = { x = instancePosition.x + 237, y =  instancePosition.y + 320, z = 5 }	
		doRemoveItem(getTileItemById(stonePos, 12383).uid)
		
		instance:finishBonusObjective(2)
	elseif item.actionid == 10511 then
		local stonePos = { x = instancePosition.x + 241, y =  instancePosition.y + 323, z = 5 }
		doRemoveItem(getTileItemById(stonePos, 12383).uid)
		
		instance:finishBonusObjective(3)
	elseif item.actionid == 10512 then
		local stonePos = { x = instancePosition.x + 242, y =  instancePosition.y + 323, z = 5 }
		doRemoveItem(getTileItemById(stonePos, 12383).uid)
		
		instance:finishBonusObjective(4)
	end

	player:sendTextMessage(MESSAGE_INFO_DESCR, "There are more levers.")


    end
  end
end
return true
end