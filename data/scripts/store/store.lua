Store = {}
local STORE_DATA = {
  [1] = dofile("data/scripts/store/data/player.lua"),
  [2] = dofile("data/scripts/store/data/boosts.lua"),
  [3] = dofile("data/scripts/store/data/stash.lua"),
  [4] = dofile("data/scripts/store/data/outfits.lua"),
  [5] = dofile("data/scripts/store/data/wings.lua"),
  [6] = dofile("data/scripts/store/data/aura.lua"),
  [7] = dofile("data/scripts/store/data/shader.lua"),
  [8] = dofile("data/scripts/store/data/outlines.lua"),
  [9] = dofile("data/scripts/store/data/footprints.lua"),
  [10] = dofile("data/scripts/store/data/portals.lua"),
}

local LoginEvent = CreatureEvent("StoreLogin")
function LoginEvent.onLogin(player)
  player:registerEvent("StoreExtendedOpcode")
  return true
end

local ExtendedEvent = CreatureEvent("StoreExtendedOpcode")
function ExtendedEvent.onExtendedOpcode(player, opcode, buffer)
  if opcode ~= ExtendedOPCodes.CODE_GAMESTORE then return false end
  local status, data = pcall(function() return json.decode(buffer) end)
  if not status then return false end

  if data[1] == 1 then
    if not player:canSpendPoints() then
      player:sendStoreMessage("You cannot make purchases at this time, try again later.")
      return false
    end

    local category = data[2]
    local id = data[3]

    local store = STORE_DATA[category]
    if not store then 
      player:sendTooltipMessage("This category doesn't exist.")
      return false 
    end
    local offer = store[id]
    if not offer then
      player:sendStoreMessage("This offer doesn't exist.")
      return false
    end

    if offer.disabled then
      player:sendStoreMessage("This offer is disabled during playtests")
      return false
    end

    if player:getAccountCoins() < offer.price then
      player:sendStoreMessage("You don't have enough gems.")
      return false
    end

    if not offer.finish or not offer.finish(player, offer) then
      if offer.returnText and offer.returnText[false] then
        player:sendStoreMessage(offer.returnText[false])
      else
        player:sendStoreMessage("Something went wrong.")
      end
      return false
    end

    if offer.returnText and offer.returnText[true] then
      player:sendStoreMessage(offer.returnText[true])
    else
      player:sendStoreMessage("You have bought " .. offer.name .. " for " .. offer.price .. " gems.")
    end

    player:takeCoins(offer.price)
    local coins = player:getAccountCoins()
    player:setStorageValue(165232, coins * 10)
    player:sendExtendedOpcode(ExtendedOPCodes.CODE_GAMESTORE, json.encode({5, player:getSex(), coins}))
    if offer.price ~= 0 then
      player:addToStoreHistory(offer, player:getGuid())
    end
  elseif data[1] == 2 then
    local coins = player:getAccountCoins()
    player:sendExtendedOpcode(ExtendedOPCodes.CODE_GAMESTORE, json.encode({1, player:getSex(), coins}))
  elseif data[1] == 3 then
    local coins = player:getAccountCoins()
    player:sendExtendedOpcode(ExtendedOPCodes.CODE_GAMESTORE, json.encode({2, player:getSex(), coins}))
  elseif data[1] == 4 then
    local category = data[2]
    local store = STORE_DATA[category]
    if not store then return end
    local owned = {}
    local countOwned = {}
    for index, offer in ipairs(store) do
      if offer.check then
        local count = offer.check(player)
        if count then
          table.insert(owned, index)
          if offer.stackable then
            countOwned[index] = count
          end
        end
      end
    end

    player:sendExtendedOpcode(ExtendedOPCodes.CODE_GAMESTORE, json.encode({4, category, owned, countOwned}))
  end
end

function Player:sendStoreMessage(text)
  self:sendExtendedOpcode(ExtendedOPCodes.CODE_GAMESTORE, json.encode({3, text}))
end

function Player:addToStoreHistory(offer, target)
  local escapeTitle = db.escapeString(offer.name)
  local aid = self:getAccountId()
  local escapePrice = db.escapeString(offer.price)
  local escapeCount = db.escapeString(1)
  local escapeTarget = db.escapeString(target)
  db.asyncQuery(
    "INSERT INTO `shop_history` VALUES (NULL, '" ..
      aid .. "', '" .. self:getGuid() .. "', NOW(), " .. escapeTitle .. ", " .. escapePrice .. ", " .. escapeCount .. ", " .. escapeTarget .. ")"
  )
end

function Player:getAccountCoins()
  local points = "0.0"
  local resultId = db.storeQuery("SELECT `coins` FROM `accounts` WHERE `id` = " .. self:getAccountId())
	if resultId ~= false then
		points = result.getString(resultId, "coins")
		result.free(resultId)
	end

  return tonumber(points) or 0
end

function Player:takeCoins(coins)
  db.query("UPDATE `accounts` SET `coins` = `coins` - " .. coins ..  " WHERE `id` = " .. self:getAccountId())
end

LoginEvent:type("login")
LoginEvent:register()
ExtendedEvent:type("extendedopcode")
ExtendedEvent:register()

function generateStoreConfigForClient()
    local store_config = {}
    for i = 1, #STORE_DATA do
        if not store_config[i] then
            store_config[i] = {}
        end
        for k, v in ipairs(STORE_DATA[i]) do
            local itemId = nil
            if v.item_id then
              local item = ItemType(v.item_id)
              if not item then
                print("Error: Item not found")
              else
                itemId = item:getClientId()
              end
            end
            local offer = {
              id = k,
              name = v.name,
              tooltip = v.tooltip,
              rarity = v.rarity or nil,
              price = v.price,
              item_id = itemId or nil,
              outfit = v.outfit or nil,
              animate = v.animate or nil,
              effect = v.effect or nil,
              icon = v.icon or nil,
              configure = v.configure or nil,
              category = i,
              portal = v.portal or nil,
              disabled = v.disabled or nil,
              stackable = v.stackable or nil,
            }
            table.insert(store_config[i], offer)
        end
    end

    local file = io.open("data/scripts/store/client/store_data.lua", "w")
    if not file then
        print("Error: Can't open file")
        return false
    end

    file:write("return " .. serpent.block(store_config, {comment = false}))
    file:close()
end
generateStoreConfigForClient()

function Store:addItemToPlayer(player, offer)
  return player:getSlotItem(CONST_SLOT_STORE_INBOX):addItem(offer.item_id, 1, INDEX_WHEREEVER, FLAG_NOLIMIT)
end