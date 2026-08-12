function onUse(player, item, fromPos, item2, toPos)
local dungeon = player:getDungeon()
if dungeon then
  local instance = dungeon:getPlayerInstance(player)
  if instance then
    local instancePosition = instance:getPosition()
	if item.itemid == 1945 then
	if item.actionid == 10501 then	-- {x = 333, y = 112, z = 7}
		local stonePos = { x = instancePosition.x + 333, y =  instancePosition.y + 112, z = 7 }
		doRemoveItem(getTileItemById(stonePos, 3457).uid)
		doTransformItem(item.uid,1946)
		instance:finishBonusObjective(2)
	elseif item.actionid == 10502 then
		local stonePos = { x = instancePosition.x + 333, y =  instancePosition.y + 115, z = 7 }
		doRemoveItem(getTileItemById(stonePos, 3457).uid)
		doTransformItem(item.uid,1946)
		instance:finishBonusObjective(3)
	elseif item.actionid == 10503 then
		local stonePos = { x = instancePosition.x + 333, y =  instancePosition.y + 118, z = 7 }
		doRemoveItem(getTileItemById(stonePos, 3457).uid)
		doTransformItem(item.uid,1946)
		instance:finishBonusObjective(4)
	elseif item.actionid == 10504 then
		local stonePos = { x = instancePosition.x + 333, y =  instancePosition.y + 121, z = 7 }
		doRemoveItem(getTileItemById(stonePos, 3457).uid)
		doTransformItem(item.uid,1946)
		instance:finishBonusObjective(5)
	elseif item.actionid == 10505 then
		local stonePos = { x = instancePosition.x + 333, y =  instancePosition.y + 124, z = 7 }
		doRemoveItem(getTileItemById(stonePos, 3457).uid)
		doTransformItem(item.uid,1946)
		instance:finishBonusObjective(6)
	elseif item.actionid == 10506 then
		local stonePos = { x = instancePosition.x + 333, y =  instancePosition.y + 127, z = 7 }
		doRemoveItem(getTileItemById(stonePos, 3457).uid)
		doTransformItem(item.uid,1946)
		instance:finishBonusObjective(7)
	elseif item.actionid == 10507 then
		local stonePos = { x = instancePosition.x + 333, y =  instancePosition.y + 130, z = 7 }
		doRemoveItem(getTileItemById(stonePos, 3457).uid)
		doTransformItem(item.uid,1946)
		instance:finishBonusObjective(8)
	elseif item.actionid == 10508 then
		local stonePos = { x = instancePosition.x + 333, y =  instancePosition.y + 133, z = 7 }
		doRemoveItem(getTileItemById(stonePos, 3457).uid)
		doTransformItem(item.uid,1946)
		instance:finishBonusObjective(9)
	end
	end
	local levers = 8
	if levers == 0 then
	player:sendTextMessage(MESSAGE_INFO_DESCR, "Levers: "..levers.."")
	player:finishBonusObjective(1)
	else
	player:sendTextMessage(MESSAGE_INFO_DESCR, "There are more levers.")
	end

	
  end
end
return true
end