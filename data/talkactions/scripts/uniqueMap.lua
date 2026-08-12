function onSay(player, words, param)
	if not player:getGroup():getAccess() then
		return true
	end
	if player:getAccountType() < ACCOUNT_TYPE_GOD then
		return false
	end

local startPosEx = Position(1952, 1975, 7) -- player:getPosition()
local xOffsetex = 0
local yOffsetex = 0
local rowLength = 14 -- ile wilków w jednym rzędzie
--[[
-- Lista looktype'ów z outfits.xml (tylko type="1")
local looktypes = {
1231,1232,153,157,136,128,129,137,130,138,131,139,133,141,134,142,143,147,144,148,145,149,146,150,152,156,
463,464,465,466,472,471,2344,2345,2012,2081,2083,2015,2082,140,155,158,252,269,270,279,288,324,329,336,366,
433,513,514,542,575,578,618,620,632,635,636,664,666,683,694,696,698,732,745,749,759,845,852,874,885,900,
926,947,949,954,956,958,960,962,964,966,992,994,1013,1020,1026,1039,1052,1055,1080,1097,1106,1116,1125,
1137,1139,1141,1145,1164,1166,1167,1171,1187,1194,1197,1201,1206,1237,1993,1995,2050,2052,2054,2068,2077,
2079,2093,2272,2323,2325,2329,2331,2333,2335,2336,2341,2343,2347,2349,2351,2353,2321,2389,2390,2089,132,
151,154,253,268,273,278,289,325,328,335,367,432,512,516,541,574,577,610,619,633,634,637,665,667,684,695,
697,699,725,733,746,750,760,846,853,873,884,899,927,946,948,953,955,957,959,961,963,965,991,993,1096,1079,
1054,1051,1038,1025,1019,1012,1197,1193,1186,1170,1171,1167,1165,1163,1144,1140,1138,1136,1124,1115,1107,
1202,1205,1236,1992,1995,2049,2051,2053,2067,2076,2078,2273,2274,2284,2286,2300,2322,2324,2328,2330,2332,
2334,2337,2340,2342,2346,2348,2350,2352,2354,2384,2385,2388,2391,2430,2431,2433,2089
}

for i, looktype in ipairs(looktypes) do
    local pos = Position(startPosEx.x + xOffsetex, startPosEx.y + yOffsetex, startPosEx.z)
    local wolf = Game.createMonster("Wolf", pos)
    if wolf then
        wolf:setOutfit({lookType = looktype, lookAddons = 3})
    end
    xOffsetex = xOffsetex + 1
    if xOffsetex >= rowLength then
        xOffsetex = 0
        yOffsetex = yOffsetex + 1
    end
end


player:sendTextMessage(MESSAGE_INFO_DESCR, "Spawned " .. #looktypes .. " wolves with different outfits.")
--]]

	local startPos = Position(1952, 1970, 7) -- Pozycja początkowa
	local xOffset = 0 -- Przesunięcie poziome
	local yOffset = 0 -- Przesunięcie pionowe
	
	for i = 1, #US_UNIQUES do
		local uniqueItem = generateUniqueItem(player, i, US_UNIQUES[i].monsterLevel)
		
		if uniqueItem then
			local itemPos = Position(startPos.x + xOffset, startPos.y + yOffset, startPos.z) -- Nowa pozycja przedmiotu
			uniqueItem:moveTo(itemPos)
	
			player:sendTextMessage(MESSAGE_INFO_DESCR, "A unique item has appeared at position: " .. itemPos.x .. ", " .. itemPos.y .. ", " .. itemPos.z)
			
			xOffset = xOffset + 1 -- Przesuwamy w prawo
			if i % 14 == 0 then
				yOffset = yOffset + 1 -- Co 5 przedmiotów przesuwamy w dół
				xOffset = 0 -- Resetujemy przesunięcie w prawo
			end
		else
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Invalid unique item id.")
		end
	end
	

	return true
end


--[[
function onSay(player, words, param)
    local startPos = player:getPosition()
    local xOffset = 0

    -- Lista looktype'ów z outfits.xml (przykład, wklej tu wszystkie looktype'y które chcesz)
local looktypes = {
1231, 153, 128, 129, 130, 131, 133, 134, 143, 144, 145, 146, 152, 463, 465, 472, 2344, 2012, 2081, 2083, 2015,
132, 151, 154, 253, 268, 273, 278, 289, 325, 328, 335, 367, 432, 512, 516, 541, 574, 577, 610, 619, 633, 634, 637,
665, 667, 684, 695, 697, 699, 725, 733, 746, 750, 760, 846, 853, 873, 884, 899, 927, 946, 948, 953, 955, 957, 959,
961, 963, 965, 991, 993, 1096, 1079, 1054, 1051, 1038, 1025, 1019, 1012, 1197, 1193, 1186, 1170, 1171, 1167, 1165,
1163, 1144, 1140, 1138, 1136, 1124, 1115, 1107, 1202, 1205, 1236, 1992, 1995, 2049, 2051, 2053, 2067, 2076, 2078,
2273, 2274, 2284, 2286, 2300, 2322, 2324, 2328, 2330, 2332, 2334, 2337, 2340, 2342, 2346, 2348, 2350, 2352, 2354,
2384, 2385, 2388, 2391, 2430, 2431, 2433, 2089
}

    for i, looktype in ipairs(looktypes) do
        local pos = Position(startPos.x + xOffset, startPos.y, startPos.z)
        local wolf = Game.createMonster("Wolf", pos)
        if wolf then
            wolf:setOutfit({lookType = looktype})
        end
        xOffset = xOffset + 1
    end

    player:sendTextMessage(MESSAGE_INFO_DESCR, "Spawned " .. #looktypes .. " wolves with different outfits.")
    return false
end
--]]

