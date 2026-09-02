function onStartup()
	db.query("UPDATE `players` SET `posx` = 675, `posy` = 1040, `posz` = 7")
	db.query("TRUNCATE TABLE `players_online`")
	db.asyncQuery("DELETE FROM `guild_wars` WHERE `status` = 0")
	db.asyncQuery("DELETE FROM `players` WHERE `deletion` != 0 AND `deletion` < " .. os.time())
	db.asyncQuery("DELETE FROM `ip_bans` WHERE `expires_at` != 0 AND `expires_at` <= " .. os.time())

	-- Move expired bans to ban history
	local resultId = db.storeQuery("SELECT * FROM `account_bans` WHERE `expires_at` != 0 AND `expires_at` <= " .. os.time())
	if resultId ~= false then
		repeat
			local accountId = result.getNumber(resultId, "account_id")
			db.asyncQuery("INSERT INTO `account_ban_history` (`account_id`, `reason`, `banned_at`, `expired_at`, `banned_by`) VALUES (" .. accountId .. ", " .. db.escapeString(result.getString(resultId, "reason")) .. ", " .. result.getNumber(resultId, "banned_at") .. ", " .. result.getNumber(resultId, "expires_at") .. ", " .. result.getNumber(resultId, "banned_by") .. ")")
			db.asyncQuery("DELETE FROM `account_bans` WHERE `account_id` = " .. accountId)
		until not result.next(resultId)
		result.free(resultId)
	end

	-- Check house auctions
	-- local resultId = db.storeQuery("SELECT `id`, `highest_bidder`, `last_bid`, (SELECT `balance` FROM `players` WHERE `players`.`id` = `highest_bidder`) AS `balance` FROM `houses` WHERE `owner` = 0 AND `bid_end` != 0 AND `bid_end` < " .. os.time())
	-- if resultId ~= false then
	-- 	repeat
	-- 		local house = House(result.getNumber(resultId, "id"))
	-- 		if house then
	-- 			local highestBidder = result.getNumber(resultId, "highest_bidder")
	-- 			local balance = result.getNumber(resultId, "balance")
	-- 			local lastBid = result.getNumber(resultId, "last_bid")
	-- 			if balance >= lastBid then
	-- 				db.query("UPDATE `players` SET `balance` = " .. (balance - lastBid) .. " WHERE `id` = " .. highestBidder)
	-- 				house:setOwnerGuid(highestBidder)
	-- 			end
	-- 			db.asyncQuery("UPDATE `houses` SET `last_bid` = 0, `bid_end` = 0, `highest_bidder` = 0, `bid` = 0 WHERE `id` = " .. house:getId())
	-- 		end
	-- 	until not result.next(resultId)
	-- 	result.free(resultId)
	-- end

	-- store towns in database
	db.query("TRUNCATE TABLE `towns`")
	for i, town in ipairs(Game.getTowns()) do
		local position = town:getTemplePosition()
		db.query("INSERT INTO `towns` (`id`, `name`, `posx`, `posy`, `posz`) VALUES (" .. town:getId() .. ", " .. db.escapeString(town:getName()) .. ", " .. position.x .. ", " .. position.y .. ", " .. position.z .. ")")
	end

local ani1Item1 = generateUniqueItem(player, 26, 20)
ani1Item1:moveTo(Position(503, 462, 9), 1, INDEX_WHEREEVER, FLAG_NOLIMIT)
local ani1Item2 = generateUniqueItem(player, 27, 20)
ani1Item2:moveTo(Position(505, 462, 9), 1, INDEX_WHEREEVER, FLAG_NOLIMIT)
local ani1Item3 = generateUniqueItem(player, 28, 20)
ani1Item3:moveTo(Position(507, 462, 9), 1, INDEX_WHEREEVER, FLAG_NOLIMIT)

local ani2Item1 = generateUniqueItem(player, 29, 50)
ani2Item1:moveTo(Position(1243, 554, 9), 1, INDEX_WHEREEVER, FLAG_NOLIMIT)
local ani2Item2 = generateUniqueItem(player, 30, 50)
ani2Item2:moveTo(Position(1245, 554, 9), 1, INDEX_WHEREEVER, FLAG_NOLIMIT)
local ani2Item3 = generateUniqueItem(player, 31, 50)
ani2Item3:moveTo(Position(1247, 554, 9), 1, INDEX_WHEREEVER, FLAG_NOLIMIT)

--	local shrineC = Game.createItem(1945, -1, Position(1333, 1466, 7))
--	shrineC:setActionId(27543)
--	Game.createItem(1485, -1, Position(1333, 1465, 7))
--	Game.createNpc("Leona", Position(1392, 1131, 7))
	
--	Game.createItem(35249, -1, Position(711, 1034, 7))
--	Game.createItem(35250, -1, Position(711, 1035, 7))
--	Game.createItem(35251, -1, Position(712, 1034, 7))	
--	Game.createItem(35252, -1, Position(712, 1035, 7))
--	Game.createNpc("Dungeon Master", Position(1000, 1013, 7))
--	Game.createNpc("Tobi", Position(1188, 979, 7))

-- Game.createNpc("[Travel] Groog", Position(970, 2001, 6))

-- Game.createItem(18490, -1, Position(674, 1034, 8)) -- melee
-- Game.createItem(18491, -1, Position(674, 1035, 8)) -- distance
-- Game.createItem(18492, -1, Position(674, 1036, 8)) -- magic power

--	local trainingPortal = Game.createItem(1387, -1, Position(677, 1038, 7)) -- trainers
--	trainingPortal:setActionId(27546)


 local teleportBack = Game.createItem(31100, -1, Position(691, 1033, 7))
 teleportBack:setActionId(5623)

	--	CursedChestsLoad()
	loadBuffs()
	Game.createNpc("Jonny", Position(673, 1040, 7))


	if configManager.getNumber(configKeys.INSTANCE_TYPE) == 0 then
		AddWidgets()
		placeHighScoreClones()
	end

end