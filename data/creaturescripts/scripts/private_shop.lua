local ITEM = nil
local UID = nil
local SHOP_OUTFITS = {
  [1] = 2084,
  [2] = 2080,
  [3] = 2085,
  [4] = 2086,
  [5] = 2087,
  [6] = 2088,
}

function onExtendedOpcode(player, opcode, buffer)
  if opcode == ExtendedOPCodes.CODE_PRIVATE_SHOP then
    local status, json_data =
      pcall(
      function()
        return json.decode(buffer)
      end
    )
    if not status then
      return false
    end

    if json_data.action == "lookshop" then
      LOOK_PLAYER_SHOP(player, json_data.data.player)
    end

    if json_data.action == "savesettings" then
      player:setStorageValue(727800, json_data.stype)
    end

    if json_data.action == "additem" then
      local pos = Position(json_data.pos.x, json_data.pos.y, json_data.pos.z, json_data.pos.stackpos)
      ITEM = player:getItem(pos)
      if ITEM then
	   if ITEM:bindItem() > 0 then
        SEND_INFO_(player, "Error", "The bound item cannot be sold!")
       return true
      end
        if ITEM:isContainer() then
          if ITEM:getContentDescription() == "nothing" then else
            SEND_INFO_(player, "Error", "Container need to be empty!")
            return true
          end
        end
        for slot = CONST_SLOT_HEAD, CONST_SLOT_RING2 do
          local itemslot = player:getSlotItem(slot)
          if itemslot then
            if ITEM:getRealUID() == itemslot:getRealUID() then
              SEND_INFO_(player, "Error", "You can't sell equipped item!")
              return true
            end
          end
        end
        UID = ITEM:getRealUID()
        player:setStorageValue(727540, ITEM:getRealUID())
      else
        print("ERROR #1")
      end
    end

    if json_data.action == "getoutfits" then
      GET_OUTFITS(player)
    end

    if json_data.action == "sellitem" then
      ADD_ITEM_SHOP(player, json_data.data)
    end

    if json_data.action == "closeshop" then
      CLOSE_SHOP(player)
    end

    if json_data.action == "toggleinfo" then
      GET_TOGGLE_INFO(player)
    end

    if json_data.action == "buyitem" then
      BUY_ITEM(player, json_data.data)
    end

    if json_data.action == "removeitem" then
      REMOVE_ITEM(player, json_data.slot)
    end

    if json_data.action == "checkprice" then
      CHECK_PRICE(player, json_data.slot)
    end

    if json_data.action == "onbuyitem" then
      ON_BUY_ITEM(player, json_data.data)
    end

    if json_data.action == "changeprice" then
      CHANGE_PRICE(player, json_data.data)
    end

    if json_data.action == "openshop" then
      OPEN_SHOP(player, json_data.data)
    end
  end
  return true
end

function GET_OUTFITS(player)
  local data = {
    id = {},
    owned = {}
  }
  player:setStorageValue(727801, 1)
  local x = nil
  for i = 1, #SHOP_OUTFITS do
    table.insert(data.id, i, SHOP_OUTFITS[i])
    table.insert(data.owned, i, player:getStorageValue(727800 + i))
    x = i
  end
  player:sendExtendedOpcode(ExtendedOPCodes.CODE_PRIVATE_SHOP, json.encode({action = "shopoutfits", data = data, nr = x}))
end

function CLOSE_SHOP(player)
  local condition = Condition(CONDITION_OUTFIT, CONDITIONID_COMBAT)
  local tile = Tile(player:getPosition())
  tile:removeWidget()
  condition:setTicks(0)
  condition:setOutfit({lookType = SHOP_OUTFITS[player:getStorageValue(727800)]})
  player:addCondition(condition)
  player:setShop(false)
  oldPos = player:getPosition()
  player:teleportTo(Position(1943, 1988, 7))
  player:teleportTo(oldPos)
  player:startRecording()
  local items = {
    count = {},
    item = {}
  }
  for i = 1, 40 do 
    table.insert(items.count, i, player:getStorageValue(727641 + i))
    table.insert(items.item, i, player:getStorageValue(727741 + i))
  end
  player:sendExtendedOpcode(ExtendedOPCodes.CODE_PRIVATE_SHOP, json.encode({action = "toggleshop", items = items, shop = player:isShop()}))
end

function GET_TOGGLE_INFO(player)
  local items = {
    count = {},
    item = {}
  }
  for i = 1, 40 do 
    table.insert(items.count, i, player:getStorageValue(727641 + i))
    table.insert(items.item, i, player:getStorageValue(727741 + i))
  end
  player:sendExtendedOpcode(ExtendedOPCodes.CODE_PRIVATE_SHOP, json.encode({action = "toggleshop", items = items, shop = player:isShop()}))
end

function BUY_ITEM(player, data)
  local target = Player(data.target)
  local xITEM = target:getStoreInbox():getItemUID(target:getStorageValue(727541+data.slot))
  local price = target:getStorageValue(727591 + data.slot) 
  local vc = target:getStorageValue(727691 + data.slot)

  if not target:isShop() then         
    SEND_INFO_(player, "Error", "Unexpected Error try again!")
    player:sendExtendedOpcode(ExtendedOPCodes.CODE_PRIVATE_SHOP, json.encode({action = "hidewindow"}))
    return
  end

  if vc == data.vc then
    if price == data.cost then
      if xITEM then

        if vc == 1 then
          if not player:removeTotalMoney(price) then
            SEND_INFO_(player, "Error", "You don't have enough money!")
            return
          end
          target:setBankBalance(target:getBankBalance() + price)
        else
          if getPoints(player) >= price then
            db.query("UPDATE `znote_accounts` SET `points` = '"..getPoints(player)-price.."' WHERE `account_id` = ".. player:getAccountId() .. ";")
            db.query("UPDATE `znote_accounts` SET `points` = '"..getPoints(target)+price.."' WHERE `account_id` = ".. target:getAccountId() .. ";")
            local escapeTitle = db.escapeString("Private Shop Buy")
            local aid = player:getAccountId()
            local escapePrice = db.escapeString(price)
            local escapeCount = db.escapeString(xITEM:getCount())
            local escapeTarget = db.escapeString(data.target)
            db.asyncQuery(
              "INSERT INTO `shop_history` VALUES (NULL, '" ..
                aid .. "', '" .. player:getGuid() .. "', NOW(), " .. escapeTitle .. ", " .. escapePrice .. ", " .. escapeCount .. ", " .. escapeTarget .. ")"
            )
            local escapeTitle = db.escapeString("Private Shop Sell")
            local aid = target:getAccountId()
            local escapePrice = db.escapeString(price)
            local escapeCount = db.escapeString(xITEM:getCount())
            local escapeTarget = db.escapeString(player:getName())
            db.asyncQuery(
              "INSERT INTO `shop_history` VALUES (NULL, '" ..
                aid .. "', '" .. target:getGuid() .. "', NOW(), " .. escapeTitle .. ", " .. escapePrice .. ", " .. escapeCount .. ", " .. escapeTarget .. ")"
            )
          else
            SEND_INFO_(player, "Error", "You don't have enough points!")
            return
          end
        end
      else
        SEND_INFO_(player, "Error", "Unexpected Error try again!")
        player:sendExtendedOpcode(ExtendedOPCodes.CODE_PRIVATE_SHOP, json.encode({action = "hidewindow"}))
        return
      end
    else
      SEND_INFO_(player, "Error", "Unexpected Error try again!")
      player:sendExtendedOpcode(ExtendedOPCodes.CODE_PRIVATE_SHOP, json.encode({action = "hidewindow"}))
      return
    end
    
    xITEM:moveTo(player:getInbox(), target:getStorageValue(727641+data.slot), INDEX_WHEREEVER, FLAG_NOLIMIT)
    target:setStorageValue(727541 + data.slot, -1) -- UID
    target:setStorageValue(727591 + data.slot, -1) -- COST
    target:setStorageValue(727641 + data.slot, -1) -- COUNT
    target:setStorageValue(727691 + data.slot, -1) -- V / C
    target:setStorageValue(727741 + data.slot, -1) -- CLIENTID
    player:sendExtendedOpcode(ExtendedOPCodes.CODE_PRIVATE_SHOP, json.encode({action = "itembought"}))
    local items = {
      count = {},
      item = {}
    }
    for i = 1, 40 do 
      table.insert(items.count, i, target:getStorageValue(727641 + i))
      table.insert(items.item, i, target:getStorageValue(727741 + i))
    end
    target:sendExtendedOpcode(ExtendedOPCodes.CODE_PRIVATE_SHOP, json.encode({action = "toggleshop", items = items, shop = target:isShop()}))
  end
end

function ON_BUY_ITEM(player, data)
  local target = Player(data.target)
  local datas = {}
  local xITEM = target:getStoreInbox():getItemUID(target:getStorageValue(727541+data.slot))
  if not target:isShop() then         
    SEND_INFO_(player, "Error", "Try again!")
    player:sendExtendedOpcode(ExtendedOPCodes.CODE_PRIVATE_SHOP, json.encode({action = "hidewindow"}))
    return
  end
  if xITEM then
	
    datas.item = xITEM:getName()
    datas.cost = target:getStorageValue(727591 + data.slot) 
    datas.vc = target:getStorageValue(727691 + data.slot)
    datas.slot = data.slot
    player:sendExtendedOpcode(ExtendedOPCodes.CODE_PRIVATE_SHOP, json.encode({action = "onbuyitem", data = datas}))
  end
end

function OPEN_SHOP(player, data)
  if player:getStorageValue(727800) == -1 then
    player:setStorageValue(727801, 1)
    player:setStorageValue(727800, 1)
  end
  if getDistanceBetween(player:getPosition(), Position(762, 1353, 7)) >= 10 then -- 762, y = 1353, z = 7
    SEND_INFO_(player, "Error", "You can't open shop here.")
    return false
  end
  local spectators = Tile(player:getPosition()):getCreatures()
  for _, playerx in pairs(spectators) do
      if playerx:isShop() then
        SEND_INFO_(player, "Error", "This place is already taken!")
        return false
      end
  end

  db.query("UPDATE `znote_accounts` SET `shopname` = '"..data.shopname.."' WHERE `account_id` = ".. player:getAccountId() .. ";")
  db.query("UPDATE `znote_accounts` SET `color` = '"..data.color.."' WHERE `account_id` = ".. player:getAccountId() .. ";")
  local tile = Tile(player:getPosition())
  if not tile then 
    SEND_INFO_(player, "Error", "You can't open shop here.")
    return false
  end
  local datax = {
    data.shopname, 
    data.color,
    player:getName(),
  }
  tile:setWidget(2, datax)
  local condition = Condition(CONDITION_OUTFIT, CONDITIONID_COMBAT)
  condition:setTicks(-1)
  condition:setOutfit({lookType = SHOP_OUTFITS[player:getStorageValue(727800)]})
  player:addCondition(condition)
  player:setShop(true)
  oldPos = player:getPosition()
  player:teleportTo(Position(1943, 1988, 7))
  player:teleportTo(oldPos)
  player:stopRecording()
  local items = {
    count = {},
    item = {}
  }
  for i = 1, 40 do 
    table.insert(items.count, i, player:getStorageValue(727641 + i))
    table.insert(items.item, i, player:getStorageValue(727741 + i))
  end
  local info = {
    data.shopname,
    data.color
  }
  player:sendExtendedOpcode(ExtendedOPCodes.CODE_PRIVATE_SHOP, json.encode({action = "toggleshop", items = items, shop = player:isShop(), info = info}))
end

function ADD_ITEM_SHOP(player, data)
  local xITEM = player:getItem(player:getStorageValue(727540))
  if xITEM then
--   if xITEM:bindItem() > 0 then
--    SEND_INFO_(player, "Error", "The bound item cannot be sold!")
--    return true
--   end
    if xITEM:isContainer() then
      if xITEM:getContentDescription() == "nothing" then else
        SEND_INFO_(player, "Error", "Container need to be empty!")
        return true
      end
    end
    for slot = CONST_SLOT_HEAD, CONST_SLOT_RING2 do
      local itemslot = player:getSlotItem(slot)
      if itemslot then
        if xITEM:getRealUID() == itemslot:getRealUID() then
          SEND_INFO_(player, "Error", "You can't sell equipped item!")
          return true
        end
      end
    end
    xITEM:moveTo(player:getStoreInbox(), data.count, INDEX_WHEREEVER, FLAG_NOLIMIT)

    player:setStorageValue(727541 + data.slot, xITEM:getRealUID()) -- UID
    player:setStorageValue(727591 + data.slot, data.cost) -- COST
    player:setStorageValue(727641 + data.slot, data.count) -- COUNT
    player:setStorageValue(727691 + data.slot, data.vc) -- V / C
    player:setStorageValue(727741 + data.slot, xITEM:getType():getClientId()) -- CLIENTID

    player:sendExtendedOpcode(ExtendedOPCodes.CODE_PRIVATE_SHOP, json.encode({action = "confirmprice"}))
  else
    print("ERROR #2")
  end
end

function REMOVE_ITEM(player, slot)
  local xITEM = player:getStoreInbox():getItemUID(player:getStorageValue(727541+slot))
  if xITEM then
    xITEM:moveTo(player:getInbox(), player:getStorageValue(727641+slot), INDEX_WHEREEVER, FLAG_NOLIMIT)
    player:setStorageValue(727541 + slot, -1) -- UID
    player:setStorageValue(727591 + slot, -1) -- COST
    player:setStorageValue(727641 + slot, -1) -- COUNT
    player:setStorageValue(727691 + slot, -1) -- V / C
    player:setStorageValue(727741 + slot, -1) -- CLIENTID
    player:sendExtendedOpcode(ExtendedOPCodes.CODE_PRIVATE_SHOP, json.encode({action = "removeitem", removeitem = slot}))
  else
    print("ERROR #3")
  end
end

function CHECK_PRICE(player, slot)
  local data = {}
  data.cost = player:getStorageValue(727591 + slot) 
  data.vc = player:getStorageValue(727691 + slot)
  data.slot = slot
  player:sendExtendedOpcode(ExtendedOPCodes.CODE_PRIVATE_SHOP, json.encode({action = "changeprice", data = data}))
end

function CHANGE_PRICE(player, data)
  player:setStorageValue(727591 + data.slot, data.cost) -- COST
  player:setStorageValue(727691 + data.slot, data.vc) -- V / C
end

function LOOK_PLAYER_SHOP(player, target)
  if player:getName() == target then
    local items = {
      count = {},
      item = {}
    }
    for i = 1, 40 do 
      table.insert(items.count, i, player:getStorageValue(727641 + i))
      table.insert(items.item, i, player:getStorageValue(727741 + i))
    end
    player:sendExtendedOpcode(ExtendedOPCodes.CODE_PRIVATE_SHOP, json.encode({action = "toggleshop", items = items, shop = player:isShop()}))
    return
  end
  local targetp = Player(target)
  if not targetp then return end
  local items = {
    count = {},
    item = {}
  }
  for i = 1, 40 do 
    table.insert(items.count, i, targetp:getStorageValue(727641 + i))
    table.insert(items.item, i, targetp:getStorageValue(727741 + i))
  end

  local resultId = db.storeQuery("SELECT `shopname` FROM `znote_accounts` WHERE `account_id` = " .. targetp:getAccountId())
	local shopname = nil
	if resultId then
		shopname = result.getDataString(resultId, "shopname")           
		result.free(resultId)
	end
  player:sendExtendedOpcode(ExtendedOPCodes.CODE_PRIVATE_SHOP, json.encode({action = "showshop", data = items, target = target, shopname = shopname}))
end

function ModuleChecker()
    return true
end