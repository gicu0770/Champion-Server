function onUse(player, item, fromPos, item2, toPos)
local dungeon = player:getDungeon()
if dungeon then
  local instance = dungeon:getPlayerInstance(player)
  if instance then
    local instancePosition = instance:getPosition()
	if item.itemid == 9825 or item.itemid == 9826 then
	Item(item.uid):transform(item.itemid == 9825 and 9826 or 9825)
	local levers = 0
		if item.actionid == 10546 then	-- {x = 618, y = 353, z = 4}
			local stonePos = { x = instancePosition.x + 618, y =  instancePosition.y + 353, z = 4 }
			doRemoveItem(getTileItemById(stonePos, 30801).uid)
			
			instance:finishBonusObjective(1)
			
			
		elseif item.actionid == 10547 then	-- {x = 595, y = 347, z = 4}
			local stonePos = { x = instancePosition.x + 595, y =  instancePosition.y + 347, z = 4 }
			doRemoveItem(getTileItemById(stonePos, 30803).uid)
			
			instance:finishBonusObjective(2)
			
			
		elseif item.actionid == 10548 then	-- {x = 473, y = 278, z = 2}
			local stonePos = { x = instancePosition.x + 473, y =  instancePosition.y + 278, z = 2 }
			doRemoveItem(getTileItemById(stonePos, 30803).uid)
			
			instance:finishBonusObjective(3)
			
			
			
		elseif item.actionid == 10549 then	-- {x = 520, y = 403, z = 4}
			local stonePos = { x = instancePosition.x + 520, y =  instancePosition.y + 403, z = 4 }
			local stonePos2 = { x = instancePosition.x + 530, y =  instancePosition.y + 410, z = 4 }
			doRemoveItem(getTileItemById(stonePos, 30803).uid)
			doRemoveItem(getTileItemById(stonePos2, 30801).uid)
			
			instance:finishBonusObjective(7)
			
			
		end
	end
	player:sendTextMessage(MESSAGE_INFO_DESCR, "There are more levers.")
	
  end
end
return true
end