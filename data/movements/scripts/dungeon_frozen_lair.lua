function onStepIn(player, item, position, fromPosition)
	if player:isPlayer() then
		local dungeon = player:getDungeon()
		if dungeon then
			local instance = dungeon:getPlayerInstance(player)
			if instance then
			local instancePosition = instance:getPosition()
				if item.actionid == 43101 then
				local stonePos = { x = instancePosition.x + 455, y =  instancePosition.y + 287, z = 3 }
				player:teleportTo(stonePos)
				elseif item.actionid == 43102 then
				local stonePos = { x = instancePosition.x + 433, y =  instancePosition.y + 286, z = 3 }
				player:teleportTo(stonePos)
				elseif item.actionid == 43103 then
				local stonePos = { x = instancePosition.x + 432, y =  instancePosition.y + 276, z = 5 }
				player:teleportTo(stonePos)
				elseif item.actionid == 43104 then	-- 	{x = 535, y = 459, z = 2}
				local stonePos = { x = instancePosition.x + 535, y =  instancePosition.y + 459, z = 2 }
				player:teleportTo(stonePos)
				elseif item.actionid == 43105 then
				local stonePos = { x = instancePosition.x + 1070, y =  instancePosition.y + 1051, z = 8 }
				player:teleportTo(stonePos)
				elseif item.actionid == 43106 then
				local stonePos = { x = instancePosition.x + 1177, y =  instancePosition.y + 1051, z = 8 }
				player:teleportTo(stonePos)
				elseif item.actionid == 43107 then
				local stonePos = { x = instancePosition.x + 1123, y =  instancePosition.y + 1051, z = 8 }
				player:teleportTo(stonePos)
				elseif item.actionid == 43108 then
				local stonePos = { x = instancePosition.x + 1086, y =  instancePosition.y + 1001, z = 9 }
				player:teleportTo(stonePos)
				elseif item.actionid == 43109 then
				local stonePos = { x = instancePosition.x + 1130, y =  instancePosition.y + 968, z = 10 }
				player:teleportTo(stonePos)
				
				
				elseif item.actionid == 43110 then
				local stonePos = { x = instancePosition.x + 1195, y =  instancePosition.y + 1123, z = 4 }
				player:teleportTo(stonePos)
				elseif item.actionid == 43111 then
				local stonePos = { x = instancePosition.x + 1055, y =  instancePosition.y + 1129, z = 5 }
				player:teleportTo(stonePos)
				elseif item.actionid == 43112 then
				local stonePos = { x = instancePosition.x + 873, y =  instancePosition.y + 1082, z = 4 }
				player:teleportTo(stonePos)
				elseif item.actionid == 43113 then
				local stonePos = { x = instancePosition.x + 917, y =  instancePosition.y + 1042, z = 5 }
				player:teleportTo(stonePos)
				elseif item.actionid == 43114 then
				local stonePos = { x = instancePosition.x + 892, y =  instancePosition.y + 887, z = 4 }
				player:teleportTo(stonePos)
				elseif item.actionid == 43115 then
				local stonePos = { x = instancePosition.x + 1010, y =  instancePosition.y + 903, z = 5 }
				player:teleportTo(stonePos)
				elseif item.actionid == 43116 then
				local stonePos = { x = instancePosition.x + 1122, y =  instancePosition.y + 897, z = 4 }
				player:teleportTo(stonePos)
				elseif item.actionid == 43117 then
				local stonePos = { x = instancePosition.x + 1039, y =  instancePosition.y + 977, z = 5 }
				player:teleportTo(stonePos)
				
				elseif item.actionid == 43118 then
				local stonePos = { x = instancePosition.x + 910, y =  instancePosition.y + 766, z = 5 }
				player:teleportTo(stonePos)
				elseif item.actionid == 43119 then
				local stonePos = { x = instancePosition.x + 1170, y =  instancePosition.y + 798, z = 5 }
				player:teleportTo(stonePos)
				elseif item.actionid == 43120 then
				local stonePos = { x = instancePosition.x + 792, y =  instancePosition.y + 1176, z = 5 }
				player:teleportTo(stonePos)
				elseif item.actionid == 43121 then
				local stonePos = { x = instancePosition.x + 1128, y =  instancePosition.y + 1225, z = 5 }
				player:teleportTo(stonePos)
				
				-- raid 4
				elseif item.actionid == 43122 then
				local stonePos = { x = instancePosition.x + 984, y =  instancePosition.y + 1027, z = 4}
				player:teleportTo(stonePos)
				elseif item.actionid == 43123 then
				local stonePos = { x = instancePosition.x + 998, y =  instancePosition.y + 992, z = 5 }
				player:teleportTo(stonePos)
				elseif item.actionid == 43124 then
				local stonePos = { x = instancePosition.x + 1015, y =  instancePosition.y + 1035, z = 6 }
				player:teleportTo(stonePos)
				elseif item.actionid == 43125 then
				local stonePos = { x = instancePosition.x + 983, y =  instancePosition.y + 1035, z = 7 }
				player:teleportTo(stonePos)
				elseif item.actionid == 43126 then
				local stonePos = { x = instancePosition.x + 881, y =  instancePosition.y + 1154, z = 6 }
				player:teleportTo(stonePos)
				-- t9 lava fortress
				elseif item.actionid == 43127 then
				local stonePos = { x = instancePosition.x + 1058, y =  instancePosition.y + 1030, z = 13 }
				player:teleportTo(stonePos)
				elseif item.actionid == 43128 then
				local stonePos = { x = instancePosition.x + 1028, y =  instancePosition.y + 1011, z = 13 }
				player:teleportTo(stonePos)
				elseif item.actionid == 43129 then
				local stonePos = { x = instancePosition.x + 1087, y =  instancePosition.y + 1010, z = 13 }
				player:teleportTo(stonePos)
				elseif item.actionid == 43130 then
				local stonePos = { x = instancePosition.x + 1058, y =  instancePosition.y + 989, z = 13 }
				player:teleportTo(stonePos)
				elseif item.actionid == 43131 then
				local stonePos = { x = instancePosition.x + 1059, y =  instancePosition.y + 1010, z = 12 }
				player:teleportTo(stonePos)
				-- t9 toad island
				elseif item.actionid == 43132 then
				local stonePos = { x = instancePosition.x + 907, y =  instancePosition.y + 980, z = 10 }
				player:teleportTo(stonePos)
				-- t10 toad island
				elseif item.actionid == 43133 then
				local stonePos = { x = instancePosition.x + 888, y =  instancePosition.y + 1141, z = 7 }
				player:teleportTo(stonePos)
				elseif item.actionid == 43134 then
				local stonePos = { x = instancePosition.x + 889, y =  instancePosition.y + 739, z = 7 }
				player:teleportTo(stonePos)	
				-- t10 lava anomalie
				elseif item.actionid == 43135 then
				local stonePos = { x = instancePosition.x + 1028, y =  instancePosition.y + 997, z = 8 } -- {x = 1028, y = 997, z = 8}
				player:teleportTo(stonePos)
				elseif item.actionid == 43136 then
				local stonePos = { x = instancePosition.x + 1021, y =  instancePosition.y + 1075, z = 7 } -- {x = 1021, y = 1075, z = 7}
				player:teleportTo(stonePos)
				elseif item.actionid == 43137 then
				local stonePos = { x = instancePosition.x + 1021, y =  instancePosition.y + 983, z = 7 } -- {x = 1021, y = 983, z = 7}
				player:teleportTo(stonePos)

				-- raid 5
				elseif item.actionid == 43138 then
				local stonePos = { x = instancePosition.x + 1032, y =  instancePosition.y + 1015, z = 6}
				player:teleportTo(stonePos)
				elseif item.actionid == 43139 then
				local stonePos = { x = instancePosition.x + 1060, y =  instancePosition.y + 934, z = 7 }
				player:teleportTo(stonePos)
				elseif item.actionid == 43140 then
				local stonePos = { x = instancePosition.x + 1109, y =  instancePosition.y + 1010, z = 6 }
				player:teleportTo(stonePos)
				elseif item.actionid == 43141 then
				local stonePos = { x = instancePosition.x + 1061, y =  instancePosition.y + 1097, z = 7 }
				player:teleportTo(stonePos)
				elseif item.actionid == 43142 then
				local stonePos = { x = instancePosition.x + 1109, y =  instancePosition.y + 1039, z = 6 }
				player:teleportTo(stonePos)
				elseif item.actionid == 43143 then
				local stonePos = { x = instancePosition.x + 907, y =  instancePosition.y + 963, z = 1 }
				player:teleportTo(stonePos)
				elseif item.actionid == 43144 then
				local stonePos = { x = instancePosition.x + 931, y =  instancePosition.y + 895, z = 2 }
				player:teleportTo(stonePos)
				elseif item.actionid == 43145 then
				local stonePos = { x = instancePosition.x + 1169, y =  instancePosition.y + 964, z = 1 }
				player:teleportTo(stonePos)
				elseif item.actionid == 43146 then
				local stonePos = { x = instancePosition.x + 1140, y =  instancePosition.y + 895, z = 2 }
				player:teleportTo(stonePos)
				elseif item.actionid == 43147 then
				local stonePos = { x = instancePosition.x + 1036, y =  instancePosition.y + 939, z = 2 }
				player:teleportTo(stonePos)




				end
				
				
			end
		end
	end
	return true
end
