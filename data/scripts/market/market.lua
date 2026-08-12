if configManager.getNumber(configKeys.INSTANCE_TYPE) ~= 0 then
	return
end

local blockedIds = {
	[2594] = true,
	[14404] = true,
	[23524] = true,
	[14405] = true,
	[2148] = true,
	[2160] = true,
	[2152] = true,
}
local fee = 0.05

local MARKET_ITEM_ATTRIBUTES = {}
local TEMP_MARKET_TOOLTIP = {}
local TEMP_MARKET_TOOLTIP_ID = {}
MARKET_ITEM_TOOLTIP = {}

local ActionEvent = Action()
function ActionEvent.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	player:openMarket()
	return true
end

local LoginEvent = CreatureEvent("MarketLogin")
function LoginEvent.onLogin(player)
  player:registerEvent("MarketOP")
	player:setStorageValue(727541, 0)

	-- return bugged items
	-- local storage = player:getTempStorage()
	-- local inbox = player:getInbox()
	-- if storage then
	-- 	local items = storage:getItems()
	-- 	if items then
	-- 		for _, item in ipairs(items) do
	-- 			item:moveTo(inbox, item:getCount(), INDEX_WHEREEVER, FLAG_NOLIMIT)
	-- 			player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Your item '".. item:getName() .. "' was returned to inbox.")
	-- 		end
	-- 	end
	-- end
  return true
end

function loadMarketTooltips()
	local items = Game.getMarketItems()
	for marketId, item in pairs(items) do
		MARKET_ITEM_TOOLTIP[marketId] = getItemTooltipData(item, false)
		item:remove()
	end

	print(">> Loaded market items tooltip")
end

function lastMarketAddItemCheck(resultId, playerId, price, currency, amount, pos, uid, clientId)
	local player = Player(playerId)
	if not player or player:isRemoved() then
		return
	end

	amount = math.min(amount, 100)

	local count = result.getDataInt(resultId, "count")
	local offerLimit = 50
	result.free(resultId)
	if not count or count >= offerLimit then
		player:sendExtendedOpcode(ExtendedOPCodes.CODE_MARKET, json.encode({2, "Active offers limit is ".. offerLimit}))
		return
	end

	local totalPrice = price*amount
	local item = player:getItem(pos)
	if not player:checkItem(item, player:getStorageValue(727540)) then
		return
	end

	if uid ~= item:getRealUID() then
		player:sendExtendedOpcode(ExtendedOPCodes.CODE_MARKET, json.encode({2, "[M02] Something went wrong, try again!"}))
		return
	end

	local clientItemId = item:getType():getClientId()
	if clientId ~= clientItemId then
		player:sendExtendedOpcode(ExtendedOPCodes.CODE_MARKET, json.encode({2, "[M01] Something went wrong, try again!"}))
		return
	end

	local currentCount = item:getCount()
	if currentCount < amount then
		player:sendExtendedOpcode(ExtendedOPCodes.CODE_MARKET, json.encode({2, "Not enough items! You have " .. currentCount .. " but tried to add " .. amount .. "."}))
		return
	end

	local feetopay = math.ceil(totalPrice*fee)
	if currency == 2 then
		feetopay = math.ceil(totalPrice * 1000)
	end

	if not player:removeTotalMoney(feetopay) then
		player:sendExtendedOpcode(ExtendedOPCodes.CODE_MARKET, json.encode({2, "You don't have enough money for fee!"}))
		return
	end

	local uid = item:getRealUID()
	if uid > 0 then
		TEMP_MARKET_TOOLTIP[uid] = getItemTooltipData(item, false)
		local attributesTables = {}
		local quality = item:getQuality()
		local slotsMax = item:getMaxAttributes()
		for i = 1, slotsMax do
			local enchant = item:getBonusAttribute(i)
			if enchant and #enchant > 0 then
				local attrId = enchant[1]
				local value = enchant[2]
				local tier = enchant[3]
				local attr = US_ENCHANTMENTS[attrId]
				local haveValue = not attr.noValue
				if haveValue then
					haveValue = not attr.noQuality
				end
				if attributesTables[attrId] ~= nil then
					if quality and haveValue then
						attributesTables[attrId][1] = attributesTables[attrId][1] + math.floor((value * (1 + quality / 100)))
					else
						attributesTables[attrId][1] = attributesTables[attrId][1] + value
					end
				else
					if quality and haveValue then
						value = math.floor((value * (1 + quality / 100)))
					end
					attributesTables[attrId] = { value, tier }
				end
			end
		end

		local slotsMaxImplict = item:getImplictSlots()
		for i = 1, slotsMaxImplict do
			local enchant = item:getImplictBonusAttribute(i)
			if enchant and #enchant > 0 then
				local attrId = enchant[1]
				local value = enchant[2]
				local tier = enchant[3]
				local attr = US_ENCHANTMENTS[attrId]
				local haveValue = not attr.noValue
				if haveValue then
					haveValue = not attr.noQuality
				end
				if attributesTables[attrId] ~= nil then
					if quality and haveValue then
						attributesTables[attrId][1] = attributesTables[attrId][1] + math.floor((value * (1 + quality / 100)))
					else
						attributesTables[attrId][1] = attributesTables[attrId][1] + value
					end
				else
					if quality and haveValue then
						value = math.floor((value * (1 + quality / 100)))
					end
					attributesTables[attrId] = { value, tier }
				end
			end
		end

		MARKET_ITEM_ATTRIBUTES[uid] = attributesTables
	else
		uid = item:getId()
		TEMP_MARKET_TOOLTIP_ID[uid] = getItemTooltipData(item, false)
	end

	item:moveTo(player:getTempStorage(), amount, INDEX_WHEREEVER, FLAG_NOLIMIT)
	local marketId = player:addItemToMarket(item, amount, currency, formatItemType(item:getType(), item), price)
	if marketId then
		marketFillAttributeTable(marketId, uid)
	end
end

function marketFillAttributeTable(marketId, uid)
	if TEMP_MARKET_TOOLTIP_ID[uid] then
		MARKET_ITEM_TOOLTIP[marketId] = TEMP_MARKET_TOOLTIP_ID[uid]
		TEMP_MARKET_TOOLTIP_ID[uid] = nil
	elseif TEMP_MARKET_TOOLTIP[uid] then
		MARKET_ITEM_TOOLTIP[marketId] = TEMP_MARKET_TOOLTIP[uid]
		TEMP_MARKET_TOOLTIP[uid] = nil
	end

	local attributesTables = MARKET_ITEM_ATTRIBUTES[uid]
	if not attributesTables then
		return
	end

	local insertQuery = "INSERT INTO `market_attributes` (`marketId`, `attrId`, `value`, `tier`) VALUES "
	local values = {}
	for attrId, data in pairs(attributesTables) do
		local value = data[1]
		local tier = data[2]
		table.insert(values, string.format("(%d, %d, %d, %d)", marketId, attrId, value, tier))
	end

	if #values > 0 then
		insertQuery = insertQuery .. table.concat(values, ", ")
		db.asyncQuery(insertQuery)
	end

	MARKET_ITEM_ATTRIBUTES[uid] = nil
end


local ExtendedEvent = CreatureEvent("MarketOP")
function ExtendedEvent.onExtendedOpcode(player, opcode, buffer)
	if opcode == ExtendedOPCodes.CODE_MARKET then
	  local status, data =
		pcall(
      function()
        return json.decode(buffer)
      end
	  )

	  if not status then
      return false
	  end

	  if data[1] == 1 then -- check item before addItemToMarket
      local pos = Position(data[2])
      local item = player:getItem(pos)

			if not player:checkItem(item, nil, pos) then
				return true
			end

			local itemType = item:getType()
			local rarity = item:getRarityId()
			if rarity == 0 then
				rarity = item:getColor()
			end
			player:sendExtendedOpcode(ExtendedOPCodes.CODE_MARKET, json.encode({1, itemType:getClientId(), item:getCount(), item:getName(), item:getRealUID(), formatItemType(itemType, item), rarity}))
			player:setStorageValue(727540, item:getRealUID())
      return true
		elseif data[1] == 2 then -- addItemToMarket
			local pos = Position(data[2])
			local price = data[3]
			local currency = data[4]
			local count = data[5]
			local uid = data[6]
			local clientId = data[7]

			-- if currency == 2 then
			-- 	player:sendExtendedOpcode(ExtendedOPCodes.CODE_MARKET, json.encode({2, "Gems currency is disabled!"}))
			-- 	return false
			-- end
			
			if not count or not currency or not price then
				player:sendExtendedOpcode(ExtendedOPCodes.CODE_MARKET, json.encode({2, "[M3] Something went wrong, try again."}))
				return false
			end
			count = math.min(count, 100)

			local length = tostring(price):len()
			if length > 15 then
				player:sendExtendedOpcode(ExtendedOPCodes.CODE_MARKET, json.encode({2, "Max price is 999,999,999,999,999"}))
				return false
			end

			local playerId = player:getId()
			db.asyncStoreQuery("SELECT count(*) as `count` FROM `market_offers` WHERE `account_id` = " .. player:getAccountId(), lastMarketAddItemCheck, playerId, price, currency, count, pos, uid, clientId)
			return true
		elseif data[1] == 3 then -- cancel offer
			local marketId = data[2]
			if not marketId then
				player:sendExtendedOpcode(ExtendedOPCodes.CODE_MARKET, json.encode({2, "[M4] Something went wrong, try again."}))
				return false
			end

			player:cancelMarketOffer(marketId)
			return true
		elseif data[1] == 4 then -- buy item
			local marketId = data[2]
			local count = data[3]
			if not count then
				count = 1
			end

			if not marketId or not count then
				player:sendExtendedOpcode(ExtendedOPCodes.CODE_MARKET, json.encode({2, "[M5] Something went wrong, try again."}))
				return false
			end

			player:buyMarketOffer(marketId, count)
		elseif data[1] == 5 then -- get history
			if player:getStorageValue(727541) == 1 then
				return
			end

			player:setStorageValue(727541, 1)
			db.asyncStoreQuery("SELECT `amount`, `date`, `price`, `type`, `name`, `currency`, `rarity` FROM `market_history` WHERE `account_id` = " .. player:getAccountId() .. " ORDER BY `date` DESC LIMIT 30", sendMarketHistory, player:getId())
		end
 	end

	return true
end

function sendMarketHistory(resultId, playerId)
	local player = Player(playerId)
	if not player or player:isRemoved() then
		return
	end

	player:setStorageValue(727541, 0)
	if not resultId then
		player:sendExtendedOpcode(ExtendedOPCodes.CODE_MARKET, json.encode({4, {}}))
		return
	end

	local dataToSend = {}
	repeat
		local data = {
			result.getDataInt(resultId, "amount"),
			result.getDataInt(resultId, "price"),
			result.getDataInt(resultId, "type"),
			result.getDataInt(resultId, "currency"),
			result.getDataInt(resultId, "rarity"),
			result.getDataInt(resultId, "date"),
			result.getDataString(resultId, "name"),
		}
		table.insert(dataToSend, data)
	until not result.next(resultId)
	result.free(resultId)

	player:sendExtendedOpcode(ExtendedOPCodes.CODE_MARKET, json.encode({4, dataToSend}))
end


function sendCoinsToPlayer(resultId, playerId)
	local player = Player(playerId)
	if not player or player:isRemoved() then
		return
	end

	local coins = result.getDataInt(resultId, "coins")
	if not coins then
		return
	end
	result.free(resultId)

	player:sendExtendedOpcode(ExtendedOPCodes.CODE_MARKET, json.encode({5, coins}))
end

function Player:getCoins()
	db.asyncStoreQuery("SELECT `coins` FROM `accounts` WHERE `id` = " .. self:getAccountId(), sendCoinsToPlayer, self:getId())
end

function Player:checkItem(item, uid, pos)
	if not item then
		self:sendExtendedOpcode(ExtendedOPCodes.CODE_MARKET, json.encode({2, "[M2] Something went wrong, try again!"}))
		return false
	end

	if blockedIds[item:getId()] then
		self:sendExtendedOpcode(ExtendedOPCodes.CODE_MARKET, json.encode({2, "Sorry, this item is on blocked list."}))
		return false
	end

	if item:isContainer() then
		if item:getContentDescription() == "nothing" then else
			self:sendExtendedOpcode(ExtendedOPCodes.CODE_MARKET, json.encode({2, "Container need to be empty!"}))
			return false
		end
	end

	if item:isLocked() then
		self:sendExtendedOpcode(ExtendedOPCodes.CODE_MARKET, json.encode({2, "This item is locked. Unlock it first before selling."}))
		return false
	end

	if pos and pos.y <= CONST_SLOT_POTION1 then
		self:sendExtendedOpcode(ExtendedOPCodes.CODE_MARKET, json.encode({2, "You can't sell equipped item!"}))
		return false
	end

	if uid then
		if not item:getRealUID() == uid then
			self:sendExtendedOpcode(ExtendedOPCodes.CODE_MARKET, json.encode({2, "[M1] Something went wrong, try again!"}))
			return false
		end
	end

	return true
end

LoginEvent:type("login")
LoginEvent:register()
ExtendedEvent:type("extendedopcode")
ExtendedEvent:register()
ActionEvent:id(ITEM_MARKET)
ActionEvent:register()