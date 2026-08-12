function onUse(player, item, fromPos, item2, toPos)
local dungeon = player:getDungeon()
if dungeon then
  local instance = dungeon:getPlayerInstance(player)
  if instance then
    local instancePosition = instance:getPosition()
	if item.itemid == 9825 or item.itemid == 9826 then
	Item(item.uid):transform(item.itemid == 9825 and 9826 or 9825)
	local levers = 0
		if item.actionid == 10527 then	-- {x = 333, y = 112, z = 7}
			local stonePos = { x = instancePosition.x + 237, y =  instancePosition.y + 317, z = 6 }
			doRemoveItem(getTileItemById(stonePos, 12854).uid)
			
			instance:finishBonusObjective(1)
		elseif item.actionid == 10528 then	-- {x = 333, y = 112, z = 7}
			local stonePos = { x = instancePosition.x + 236, y =  instancePosition.y + 317, z = 6 }
			doRemoveItem(getTileItemById(stonePos, 12858).uid)
			
			instance:finishBonusObjective(2)
		elseif item.actionid == 10529 then	-- {x = 333, y = 112, z = 7}
			local stonePos = { x = instancePosition.x + 274, y =  instancePosition.y + 281, z = 5 }
			doRemoveItem(getTileItemById(stonePos, 21874).uid)
			
			instance:finishBonusObjective(4)
		elseif item.actionid == 10530 then	-- {x = 333, y = 112, z = 7}
			local stonePos = { x = instancePosition.x + 274, y =  instancePosition.y + 280, z = 5 }
			doRemoveItem(getTileItemById(stonePos, 21873).uid)
			
			instance:finishBonusObjective(5)
		end
	end
	player:sendTextMessage(MESSAGE_INFO_DESCR, "There are more levers.")
	
  end
end
return true
end