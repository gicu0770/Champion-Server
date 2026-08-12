local cfg = {	-- {x = 1231, y = 1135, z = 5}
	--[[
	['blunderbuss'] = {xCreate = 1016, yCreate = 1016, zCreate = 6, objective = 7, itemtoRemove = 1543},
	['imposter'] = {xCreate = 1041, yCreate = 1025, zCreate = 6, objective = 6, itemtoRemove = 1543},
	['terrible werebear'] = {xCreate = 1044, yCreate = 1012, zCreate = 6, objective = 5, itemtoRemove = 1543},
	['mellow werebear'] = {xCreate = 1034, yCreate = 1033, zCreate = 6, objective = 4, itemtoRemove = 1544},

	['droomphant'] = {xCreate = 1022, yCreate = 1055, zCreate = 5, objective = 1, itemtoRemove = 17867}, -- {x = 1022, y = 1055, z = 5}
	['fiery brain'] = {xCreate = 1022, yCreate = 1056, zCreate = 5, objective = 2, itemtoRemove = 17867}, -- {x = 1022, y = 1056, z = 5} 
	['poisonous jug'] = {xCreate = 1022, yCreate = 994, zCreate = 5, objective = 3, itemtoRemove = 17867}, -- {x = 1022, y = 994, z = 5} 
	['mocking rot'] = {xCreate = 1022, yCreate = 993, zCreate = 5, objective = 4, itemtoRemove = 17867}, -- {x = 1022, y = 993, z = 5}
	['impetuous golem'] = {xCreate = 1030, yCreate = 1030, zCreate = 8, objective = 5, itemtoRemove = 17867}, -- {x = 1030, y = 1030, z = 8} 
	['steel soul'] = {xCreate = 1030, yCreate = 1029, zCreate = 8, objective = 6, itemtoRemove = 17867}, -- {x = 1030, y = 1029, z = 8}



	['terrible rotworm'] = {xCreate = 889, yCreate = 761, zCreate = 7, objective = 1, itemtoRemove = 1544}, -- {x = 889, y = 761, z = 7} ID:1544
	['unknown energy'] = {xCreate = 889, yCreate = 760, zCreate = 7, objective = 2, itemtoRemove = 1544}, -- {x = 889, y = 760, z = 7} ID:1544
	['escaped warden'] = {xCreate = 889, yCreate = 759, zCreate = 7, objective = 3, itemtoRemove = 1544}, -- {x = 889, y = 759, z = 7} ID:1544

	['confuse golem'] = {xCreate = 907, yCreate = 992, zCreate = 10, objective = 2, itemtoRemove = 1354}, -- {x = 907, y = 992, z = 10} ID 1354
	['tree vampire'] = {xCreate = 907, yCreate = 991, zCreate = 10, objective = 4, itemtoRemove = 1354}, -- {x = 907, y = 991, z = 10} ID 1354
	['plague hydra'] = {xCreate = 907, yCreate = 990, zCreate = 10, objective = 6, itemtoRemove = 1354}, -- {x = 907, y = 990, z = 10} ID 1354
	['wild chimera'] = {xCreate = 907, yCreate = 989, zCreate = 10, objective = 8, itemtoRemove = 1354}, -- {x = 907, y = 989, z = 10} ID 1354

	['athiz'] = {xCreate = 1059, yCreate = 1044, zCreate = 12, objective = 1, itemtoRemove = 1304}, --
	['buzramas'] = {xCreate = 1059, yCreate = 1043, zCreate = 12, objective = 2, itemtoRemove = 1355}, -- {x = 1059, y = 1043, z = 12} ID:1355
	['thuzzo'] = {xCreate = 1059, yCreate = 1042, zCreate = 12, objective = 3, itemtoRemove = 1355}, -- {x = 1059, y = 1042, z = 12} ID:1355
	['vigloch'] = {xCreate = 1059, yCreate = 1041, zCreate = 12, objective = 4, itemtoRemove = 1304}, -- {x = 1059, y = 1042, z = 12} ID:1304

	['zioz'] = {xCreate = 1054, yCreate = 1085, zCreate = 4, objective = 1, itemtoRemove = 9485},
	['zhainuq'] = {xCreate = 1116, yCreate = 1142, zCreate = 4, objective = 2, itemtoRemove = 9485},
	['xasmeal'] = {xCreate = 1174, yCreate = 1126, zCreate = 4, objective = 3, itemtoRemove = 9533},

	['vraid'] = {xCreate = 1183, yCreate = 1099, zCreate = 4, objective = 4, itemtoRemove = 9485},
	['shaec'] = {xCreate = 1183, yCreate = 1097, zCreate = 4, objective = 5, itemtoRemove = 9485},
	['reax'] = {xCreate = 1183, yCreate = 1095, zCreate = 4, objective = 6, itemtoRemove = 9485},
	['qal'] = {xCreate = 1183, yCreate = 1093, zCreate = 4, objective = 7, itemtoRemove = 9485},



	['crystal guardian i'] = {xCreate = 1129, yCreate = 1053, zCreate = 3, objective = 5, itemtoRemove = 9485},
	['crystal guardian ii'] = {xCreate = 1129, yCreate = 1052, zCreate = 3, objective = 6, itemtoRemove = 9485},
	['crystal guardian iii'] = {xCreate = 1126, yCreate = 1068, zCreate = 7, objective = 7, itemtoRemove = 9485},

	['drisak'] = {xCreate = 1025, yCreate = 1023, zCreate = 4, objective = 1, itemtoRemove = 29606},
	['zalieds'] = {xCreate = 1025, yCreate = 1024, zCreate = 4, objective = 2, itemtoRemove = 29606},
	['ghod'] = {xCreate = 1025, yCreate = 1022, zCreate = 4, objective = 3, itemtoRemove = 29606},
	['ghins'] = {xCreate = 1025, yCreate = 1021, zCreate = 4, objective = 4, itemtoRemove = 29606},

	['bagmor'] = {xCreate = 1086, yCreate = 1064, zCreate = 4, objective = 1, itemtoRemove = 5421},
	['chashysh'] = {xCreate = 1090, yCreate = 1104, zCreate = 5, objective = 2, itemtoRemove = 5421},
	['gloskar'] = {xCreate = 1090, yCreate = 1070, zCreate = 6, objective = 3, itemtoRemove = 5421},
	['moshak'] = {xCreate = 1092, yCreate = 1070, zCreate = 7, objective = 4, itemtoRemove = 5421},
	['gyshor'] = {xCreate = 1090, yCreate = 1071, zCreate = 7, objective = 5, itemtoRemove = 5421},
	['jytha'] = {xCreate = 1089, yCreate = 1072, zCreate = 7, objective = 6, itemtoRemove = 5421},
	['grozis'] = {xCreate = 1089, yCreate = 1077, zCreate = 7, objective = 7, itemtoRemove = 14609},

	['griced'] = {xCreate = 1231, yCreate = 1135, zCreate = 5, objective = 5, itemtoRemove = 31400},
    ['griced'] = {xCreate = 1232, yCreate = 1135, zCreate = 5, objective = 5, itemtoRemove = 31400},	--	{x = 462, y = 451, z = 4}
	
	['kharton'] = {xCreate = 462, yCreate = 451, zCreate = 4, objective = 6, itemtoRemove = 30803},	--	{x = 462, y = 451, z = 4}
	['gimy'] = {xCreate = 468, yCreate = 449, zCreate = 4, objective = 5, itemtoRemove = 30803},	--	{x = 468, y = 449, z = 4}
	['palemo'] = {xCreate = 506, yCreate = 280, zCreate = 2, objective = 4, itemtoRemove = 30803},
	
	
	['minor'] = {xCreate = 180, yCreate = 248, zCreate = 7, objective = 2, itemtoRemove = 3515},
	['winged croo'] = {xCreate = 180, yCreate = 250, zCreate = 7, objective = 2, itemtoRemove = 3515},	--	{x = 180, y = 250, z = 7}
	
    ['spiked insectoid'] = {xCreate = 1008, yCreate = 957, zCreate = 6, objective = 1, itemtoRemove = 14756},--	{x = 1053, y = 977, z = 7}
    ['spiked insectoid'] = {xCreate = 1009, yCreate = 957, zCreate = 6, objective = 1, itemtoRemove = 14756},--	{x = 1053, y = 977, z = 7}
	
    ['max'] = {xCreate = 439, yCreate = 342, zCreate = 5, objective = 1, itemtoRemove = 29189},

    ['demonic burn'] = {xCreate = 205, yCreate = 488, zCreate = 6, objective = 1, itemtoRemove = 8538},
    ['demonic flame'] = {xCreate = 204, yCreate = 488, zCreate = 6, objective = 2, itemtoRemove = 8538},
    ['demonic fire'] = {xCreate = 203, yCreate = 488, zCreate = 6, objective = 3, itemtoRemove = 8538},
    ['demonic ignite'] = {xCreate = 202, yCreate = 488, zCreate = 6, objective = 4, itemtoRemove = 8538},
	['sand terror'] = {xCreate = 251, yCreate = 260, zCreate = 5, objective = 3, itemtoRemove = 22144},
	['freegoiz'] = {xCreate = 422, yCreate = 276, zCreate = 5, objective = 1, itemtoRemove = 12013}

--]]
	['vampire queen'] = {xCreate = 1217, yCreate = 1063, zCreate = 6, objective = 0, itemtoRemove = 9118, bridge = true},
	['pheonix'] = {xCreate = 1216, yCreate = 1063, zCreate = 6, objective = 1, itemtoRemove = 9118, bridge = true},
	['toxic hydra'] = {xCreate = 1215, yCreate = 1063, zCreate = 6, objective = 2, itemtoRemove = 9118, bridge = true},

	['undead king'] = {xCreate = 1216, yCreate = 1063, zCreate = 6, objective = 0, itemtoRemove = 9118, bridge = true},
	['ethereal seraph'] = {xCreate = 1216, yCreate = 1063, zCreate = 6, objective = 1, itemtoRemove = 9118, bridge = true},
	['glacier warlord'] = {xCreate = 1216, yCreate = 1063, zCreate = 6, objective = 2, itemtoRemove = 9118, bridge = true},

	['tidal overlord'] = {xCreate = 1216, yCreate = 1063, zCreate = 6, objective = 0, itemtoRemove = 9118, bridge = true},
	['fleshrend'] = {xCreate = 1216, yCreate = 1063, zCreate = 6, objective = 1, itemtoRemove = 9118, bridge = true},
	['arbaziloth'] = {xCreate = 1216, yCreate = 1063, zCreate = 6, objective = 2, itemtoRemove = 9118, bridge = true},

	['sand colossus'] = {xCreate = 1216, yCreate = 1063, zCreate = 6, objective = 0, itemtoRemove = 9118, bridge = true},
	['toxic witch'] = {xCreate = 1216, yCreate = 1063, zCreate = 6, objective = 1, itemtoRemove = 9118, bridge = true},
	['molten abyss'] = {xCreate = 1216, yCreate = 1063, zCreate = 6, objective = 2, itemtoRemove = 9118, bridge = true},
}

function onKill(creature, target)
    local tmp = cfg[target:getName():lower()]
    if tmp and target:isMonster() then
    local pos = target:getPosition()
	local dungeon = creature:getDungeon()
		if dungeon then
		  local instance = dungeon:getPlayerInstance(creature)
		  if instance then
			if tmp.bridge then -- Only Bridge Dungeons
				instance:finishBonusObjective(tmp.objective)
			else
				local instancePosition = instance:getPosition()
				local TPstonePos = { x = instancePosition.x + tmp.xCreate, y =  instancePosition.y + tmp.yCreate, z = tmp.zCreate }
				if Tile(TPstonePos) then
					if not Tile(TPstonePos):getItemById(tmp.itemtoRemove) then
						print("----------Dungeon: "..dungeon:getTitle().." no item to remove! ")
					end
					Tile(TPstonePos):getItemById(tmp.itemtoRemove):remove()
					instance:finishBonusObjective(tmp.objective)
				end
			end
		  end
		end
	end
    return true
end