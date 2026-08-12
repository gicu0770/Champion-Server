function onUse(player, item, fromPos, item2, toPos)
local dungeon = player:getDungeon()
if dungeon then
  local instance = dungeon:getPlayerInstance(player)
  if instance then
    local instancePosition = instance:getPosition()
	if item.itemid == 9825 or item.itemid == 9826 then
	Item(item.uid):transform(item.itemid == 9825 and 9826 or 9825)
	local levers = 0
		if item.actionid == 10550 then	-- {x = 1277, y = 1022, z = 5}
			local stonePos = { x = instancePosition.x + 1277, y =  instancePosition.y + 1022, z = 5 }
			local stonePos2 = { x = instancePosition.x + 1278, y =  instancePosition.y + 1022, z = 5 }
			doRemoveItem(getTileItemById(stonePos, 17867).uid)
			doRemoveItem(getTileItemById(stonePos2, 21646).uid)
			
			instance:finishBonusObjective(1)
		elseif item.actionid == 10551 then	-- {x = 1277, y = 1021, z = 5}
			local stonePos = { x = instancePosition.x + 1277, y =  instancePosition.y + 1021, z = 5 }
			local stonePos2 = { x = instancePosition.x + 1278, y =  instancePosition.y + 1021, z = 5 }
			doRemoveItem(getTileItemById(stonePos, 21646).uid)
			doRemoveItem(getTileItemById(stonePos2, 17867).uid)
			
			instance:finishBonusObjective(2)
		elseif item.actionid == 10552 then	-- {x = 1277, y = 1022, z = 5}
			local stonePos = { x = instancePosition.x + 1277, y =  instancePosition.y + 1020, z = 5 }
			local stonePos2 = { x = instancePosition.x + 1278, y =  instancePosition.y + 1020, z = 5 }
			doRemoveItem(getTileItemById(stonePos, 17867).uid)
			doRemoveItem(getTileItemById(stonePos2, 21646).uid)
			
			instance:finishBonusObjective(3)
		elseif item.actionid == 10553 then	-- {x = 1277, y = 1021, z = 5}
			local stonePos = { x = instancePosition.x + 1277, y =  instancePosition.y + 1019, z = 5 }
			local stonePos2 = { x = instancePosition.x + 1278, y =  instancePosition.y + 1019, z = 5 }
			doRemoveItem(getTileItemById(stonePos, 21646).uid)
			doRemoveItem(getTileItemById(stonePos2, 17867).uid)
			
			instance:finishBonusObjective(4)			
			
			
		end
	end
	player:sendTextMessage(MESSAGE_INFO_DESCR, "There are more levers.")
	
  end
end
return true
end