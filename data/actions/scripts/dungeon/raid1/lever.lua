function onUse(player, item, fromPos, item2, toPos)
	local dungeon = player:getDungeon()
	if dungeon then
		local instance = dungeon:getPlayerInstance(player)
		if instance then
			local instancePosition = instance:getPosition()
			if item.itemid == 32213 then
				if item.actionid == 10558 then -- radi 1
					local stonePos = { x = instancePosition.x + 1112, y = instancePosition.y + 1124, z = 5 }
					doRemoveItem(getTileItemById(stonePos, 9532).uid)
					instance:finishBonusObjective(1)
				elseif item.actionid == 10559 then
					local stonePos = { x = instancePosition.x + 1133, y = instancePosition.y + 1124, z = 5 }
					doRemoveItem(getTileItemById(stonePos, 9532).uid)
					instance:finishBonusObjective(2)
				elseif item.actionid == 10560 then
					local stonePos = { x = instancePosition.x + 1146, y = instancePosition.y + 1104, z = 5 }
					doRemoveItem(getTileItemById(stonePos, 9533).uid)
					instance:finishBonusObjective(3)
				elseif item.actionid == 10561 then
					local stonePos = { x = instancePosition.x + 1111, y = instancePosition.y + 1113, z = 7 }
					doRemoveItem(getTileItemById(stonePos, 9533).uid)
					instance:finishBonusObjective(4)
				end
			end

			if item.itemid == 1945 or item.itemid == 1946 and item.actionid >= 10562 and item.actionid <= 10566 then
				Item(item.uid):transform(item.itemid == 1945 and 1946 or 1945)
				if item.actionid == 10562 then -- raid 2
					local stonePos = { x = instancePosition.x + 1076, y = instancePosition.y + 1007, z = 9 }
					doRemoveItem(getTileItemById(stonePos, 22952).uid)
					instance:finishBonusObjective(1)
				elseif item.actionid == 10563 then
					local stonePos = { x = instancePosition.x + 1078, y = instancePosition.y + 1006, z = 9 }
					doRemoveItem(getTileItemById(stonePos, 22952).uid)
					instance:finishBonusObjective(2)
				elseif item.actionid == 10564 then
					local stonePos = { x = instancePosition.x + 1080, y = instancePosition.y + 1007, z = 9 }
					doRemoveItem(getTileItemById(stonePos, 22952).uid)
					instance:finishBonusObjective(3)
				elseif item.actionid == 10565 then
					local stonePos = { x = instancePosition.x + 1082, y = instancePosition.y + 1006, z = 9 }
					doRemoveItem(getTileItemById(stonePos, 22952).uid)
					instance:finishBonusObjective(4)
				elseif item.actionid == 10566 then
					local stonePos = { x = instancePosition.x + 1084, y = instancePosition.y + 1007, z = 9 }
					doRemoveItem(getTileItemById(stonePos, 22952).uid)
					instance:finishBonusObjective(5)
				end
			end

			if item.itemid == 1945 or item.itemid == 1946 and item.actionid >= 10574 and item.actionid <= 10577 then
				Item(item.uid):transform(item.itemid == 1945 and 1946 or 1945)
				if item.actionid == 10574 then -- t9 toad island
					local stonePos = { x = instancePosition.x + 821, y = instancePosition.y + 1031, z = 11 }
					doRemoveItem(getTileItemById(stonePos, 1353).uid)
					instance:finishBonusObjective(1)
				elseif item.actionid == 10575 then
					local stonePos = { x = instancePosition.x + 984, y = instancePosition.y + 1029, z = 11 }
					doRemoveItem(getTileItemById(stonePos, 1353).uid)
					instance:finishBonusObjective(2)
				elseif item.actionid == 10576 then
					local stonePos = { x = instancePosition.x + 976, y = instancePosition.y + 916, z = 11 }
					doRemoveItem(getTileItemById(stonePos, 1353).uid)
					instance:finishBonusObjective(3)
				elseif item.actionid == 10577 then
					local stonePos = { x = instancePosition.x + 836, y = instancePosition.y + 921, z = 11 }
					doRemoveItem(getTileItemById(stonePos, 1353).uid)
					instance:finishBonusObjective(4)
				end
			end

			if item.itemid == 23496 or item.itemid == 23500 and item.actionid >= 10574 and item.actionid <= 10577 then
				Item(item.uid):transform(item.itemid == 23496 and 23500 or 23496)
				if item.actionid == 10583 then -- t9 toad island
					local stonePos = { x = instancePosition.x + 1037, y = instancePosition.y + 979, z = 3 }
					doRemoveItem(getTileItemById(stonePos, 1544).uid)
					instance:finishBonusObjective(1)
				elseif item.actionid == 10584 then
					local stonePos = { x = instancePosition.x + 1037, y = instancePosition.y + 978, z = 3 }
					doRemoveItem(getTileItemById(stonePos, 1544).uid)
					instance:finishBonusObjective(2)
				elseif item.actionid == 10585 then
					local stonePos = { x = instancePosition.x + 1037, y = instancePosition.y + 977, z = 3 }
					doRemoveItem(getTileItemById(stonePos, 1544).uid)
					instance:finishBonusObjective(3)
				end
			end

			player:sendTextMessage(MESSAGE_INFO_DESCR, "Something happened near you.")
		end
	end
	return true
end
