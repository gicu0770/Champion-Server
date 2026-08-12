function onUse(player, item, fromPos, item2, toPos)
local dungeon = player:getDungeon()
if dungeon then
  local instance = dungeon:getPlayerInstance(player)
  if instance then
    local instancePosition = instance:getPosition()
	if item.itemid == 32213 then
		if item.actionid == 10583 then -- radi 1
			local stonePos = { x = instancePosition.x + 1112, y =  instancePosition.y + 1124, z = 5 }
			doRemoveItem(getTileItemById(stonePos, 9532).uid)
			instance:finishBonusObjective(1)
		elseif item.actionid == 10559 then
			local stonePos = { x = instancePosition.x + 1133, y =  instancePosition.y + 1124, z = 5 }
			doRemoveItem(getTileItemById(stonePos, 9532).uid)
			instance:finishBonusObjective(2)
		elseif item.actionid == 10560 then
			local stonePos = { x = instancePosition.x + 1146, y =  instancePosition.y + 1104, z = 5 }
			doRemoveItem(getTileItemById(stonePos, 9533).uid)
			instance:finishBonusObjective(3)
		elseif item.actionid == 10561 then
			local stonePos = { x = instancePosition.x + 1111, y =  instancePosition.y + 1113, z = 7 }
			doRemoveItem(getTileItemById(stonePos, 9533).uid)
			instance:finishBonusObjective(4)
		end
	end
	


	
	player:sendTextMessage(MESSAGE_INFO_DESCR, "Something happened near you.")
	
  end
end
return true
end