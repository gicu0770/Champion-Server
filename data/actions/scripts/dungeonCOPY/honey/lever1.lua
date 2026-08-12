function onUse(player, item, fromPos, item2, toPos)
local dungeon = player:getDungeon()
if dungeon then
  local instance = dungeon:getPlayerInstance(player)
  if instance then
    local instancePosition = instance:getPosition()
	if item.itemid == 9825 then
	local levers = 0
		if item.actionid == 10537 then	-- {x = 1051, y = 986, z = 6}
			local stonePos = { x = instancePosition.x + 1051, y =  instancePosition.y + 986, z = 6 }
			doRemoveItem(getTileItemById(stonePos, 14756).uid)
			doCreateItem(14753, 1, stonePos)
			doTransformItem(item.uid,9826)
			instance:finishBonusObjective(1)
		elseif item.actionid == 10538 then	-- {x = 1055, y = 981, z = 6}
			local stonePos = { x = instancePosition.x + 1055, y =  instancePosition.y + 981, z = 6 }
			doRemoveItem(getTileItemById(stonePos, 14756).uid)
			doCreateItem(14753, 1, stonePos)
			doTransformItem(item.uid,9826)
			instance:finishBonusObjective(2)
		elseif item.actionid == 10539 then	-- {x = 1055, y = 980, z = 6}
			local stonePos = { x = instancePosition.x + 1055, y =  instancePosition.y + 980, z = 6 }
			doRemoveItem(getTileItemById(stonePos, 14756).uid)
			doCreateItem(14753, 1, stonePos)
			doTransformItem(item.uid,9826)
			instance:finishBonusObjective(3)
		elseif item.actionid == 10540 then	-- {x = 1009, y = 957, z = 6}
			local stonePos = { x = instancePosition.x + 1008, y =  instancePosition.y + 957, z = 6 }
			local stonePos2 = { x = instancePosition.x + 1009, y =  instancePosition.y + 957, z = 6 }
			doRemoveItem(getTileItemById(stonePos, 14756).uid)
			doRemoveItem(getTileItemById(stonePos2, 14756).uid)
			doCreateItem(14753, 1, stonePos)
			doCreateItem(14753, 1, stonePos2)
			doTransformItem(item.uid,9826)
			instance:finishBonusObjective(4)
		end
	end
	player:sendTextMessage(MESSAGE_INFO_DESCR, "There are more levers.")
	
  end
end
return true
end