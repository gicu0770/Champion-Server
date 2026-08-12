local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
local shopModule = ShopModule:new()
NpcSystem.parseParameters(npcHandler)

function onCreatureAppear(cid)              npcHandler:onCreatureAppear(cid)            end
function onCreatureDisappear(cid)           npcHandler:onCreatureDisappear(cid)         end
function onThink()                          npcHandler:onThink()                        end

function onPlayerSellMultiple(cid, items)
  npcHandler:onPlayerSellMultiple(cid, items)
end

function onAddFocus(cid)
  npcHandler:addFocus(cid)
  shopModule.requestTrade(cid, "trade", nil, {module = shopModule})
  return true
end

local RANDOM_TYPES = {
  [37833] = 1,
  [37832] = 2,
  [37838] = 3,
  [37837] = 5,
  [37840] = 6,
  [37839] = 8, 
  [37827] = 9,
  [37835] = 10,
  [37828] = 11,
  [37829] = 12,
  [37830] = 13,
  [37836] = 14,
  [37834] = 15,
  [37831] = 16,
  [7636] = 17,
}

function onCreatureSay(cid, type, msg)
	if getDistanceBetween(getThingPos(cid), Creature(getNpcCid()):getPosition()) >= 4 then
		return false
	end

  if not cid:isShopping() then
    shopModule.requestTrade(cid:getId(), "trade", nil, {module = shopModule})
  end
  npcHandler:onCreatureSay(cid, type, msg)
end

function onBuy(cid, itemid, subType, amount, ignoreCap, inBackpacks)
  local player = Player(cid)
  if not player then
    return false
  end

  local itemType = RANDOM_TYPES[itemid]
  if not itemType then
    return false
  end


  local playerLevel = player:getLevel()
  if playerLevel > 100 then
    playerLevel = 100
  end


  math.randomseed(os.time())
  local magicFind = math.random(0, playerLevel*2)
  local item = player:getSlotItem(CONST_SLOT_BACKPACK)
  if not item then
    player:sendTooltipMessage("You don't have a backpack.")
    return false
  end
  if item and item:getEmptySlots(true) <= 0 then
    player:sendTooltipMessage("You don't have enough space in backpack.")
    return false
  end

  local minValue = playerLevel -- - 5
  if minValue < 1 then
    minValue = 1
  end

  local goldCost = math.ceil((playerLevel ^ 0.7 * 100) * 4)
  if player:getBankBalance() < goldCost then
    player:sendTooltipMessage("You don't have enough money.")
    return false
  end

  local itemLvl = math.random(minValue, playerLevel)
  if itemType == 17 then
    if not player:removeTotalMoney(goldCost) then
      player:sendTooltipMessage("You don't have enough money.")
      return false
    end

    local item = false
    local itemChoose = false
    local tier = 1
    for i = 1, #POTION_TIER_LOOT do
      if itemLvl >= POTION_TIER_LOOT[i].minlevel and itemLvl <= POTION_TIER_LOOT[i].maxlevel then
        itemChoose = POTION_TIER_LOOT[i].tierReward[math.random(#POTION_TIER_LOOT[i].tierReward)]
        tier = POTION_TIER_LOOT[i].tier
      end
    end

    if not itemChoose then
      player:sendTooltipMessage("No potion available for your level.")
      return false
    end

    item = player:addItem(itemChoose, 1, INDEX_WHEREEVER, FLAG_NOLIMIT)
    local dropLevel = itemLvl
    if itemLvl > 100 then
      dropLevel = 100
    end

    if item then
      setLootItem(player, item, 0, dropLevel, nil, 0)
      item:addRandomCrystalSlots(itemLvl, magicFind)
      local value = POTION_TIER_LOOT[tier].health
      item:setCustomAttribute("potionHealth", value)
    end

    return false
  end

  local uniqueChance = 45 + (45 * playerLevel / 100)
  if math.random(1, 100000) == uniqueChance then
    if tryToGenerateUniqueItem(player, itemLvl, itemType, nil, goldCost) then
      return false
    end
  end

  local base_item, itemLvl = findBaseItem(player, itemLvl, itemType)
  if base_item then
    if not player:removeTotalMoney(goldCost) then
      player:sendTooltipMessage("You don't have enough money.")
      return false
    end
    local item = Game.createItem(base_item[2], 1)
    if not item then
      print("Item: "..base_item[2].." not found")
      return false
    end

    if itemLvl > 46 then
      local crystalSlots = 0
      local chancePerSlot = ( itemLvl + math.random(0, itemLvl) ) * 0.07
      for _ = 1, 5 do
          if math.random(1, 100) < chancePerSlot then
            crystalSlots = crystalSlots + 1
          end
      end
      item:setCrystalSlots(crystalSlots)
    end

    local implictsSlots = #base_item[3]
    item:setImplictSlots(implictsSlots)
    if base_item[4] == 1 then
      item:setCustomAttribute("no_stat", true)
    end
    setLootItem(player, item, 0, itemLvl, 0, magicFind)
    item:setAttribute(ITEM_ATTRIBUTE_NAME, base_item[1])

    for x = 1, implictsSlots do
      local value = generateRandomImplictBaseValue(item, base_item[3][x][2], itemLvl+1)
      local bonus_range = IMPLICT_BONUS[base_item[3][x][1]] or {0, 0}
      local min = bonus_range[1]
      local max = bonus_range[2]
      value = value + math.random(min, max)
      local slot = ItemType(item:getId()):getSlotPosition()
      if (slot == 1072) then
        value = math.floor(value * TWO_HANDED_MULTIPLIER)
      end
      item:setImplictValue(x, base_item[3][x][1].."|".. value .."|".. itemLvl+1)
    end

    player:addItemEx(item)
    return false
  end
end

function tryToGenerateUniqueItem(player, itemLvl, itemType, returnId, goldCost)
  if not SERVER_UNIQUE_ITEMS_BY_TYPES[itemLvl][itemType] then
    return false
  end

  local unique_id = SERVER_UNIQUE_ITEMS_BY_TYPES[itemLvl][itemType][math.random(1, #SERVER_UNIQUE_ITEMS_BY_TYPES[itemLvl][itemType])]

  local unique_item = US_UNIQUES[unique_id]
  if unique_item then
    if not player:removeTotalMoney(goldCost) then
      player:sendTooltipMessage("You don't have enough money.")
      return false
    end
    if math.random(1, 1000) <= unique_item.chance then
      local item = generateUniqueItem(unique_id, itemLvl)
      if not item then
        return false
      end

      if returnId then
        return unique_id
      end

      player:getPosition():sendMagicEffect(169)

      player:addItemEx(item)
      return true
    end
  end

  return false
end

function findBaseItem(player, itemLvl, itemType)
  if itemLvl < 1 then
    if player then
      player:sendTooltipMessage("There are no items for your level.")
    end
    return nil
  end

  if not SERVER_BASE_ITEMS_BY_TYPES[itemLvl][itemType] then
    return findBaseItem(player, itemLvl-1, itemType)
  end

  local base_item = SERVER_BASE_ITEMS_BY_TYPES[itemLvl][itemType][math.random(1, #SERVER_BASE_ITEMS_BY_TYPES[itemLvl][itemType])]
  if base_item then
    return base_item, itemLvl
  end

  return findBaseItem(player, itemLvl-1, itemType)
end

npcHandler:addModule(shopModule)

for k, v in pairs(RANDOM_TYPES) do
  local item = ItemType(k)
  if item then
    shopModule:addBuyableItem({item:getName()}, k, 10, 1, item:getName())
  end
end


shopModule:addSellableItem({""}, 1, 1, "")

function onSellMultipleItems(cid, items)

end

npcHandler:setCallback(CALLBACK_ONSELLMULTIPLE, onSellMultipleItems)
npcHandler:setCallback(CALLBACK_ONBUY, onBuy)
npcHandler:setCallback(CALLBACK_ONADDFOCUS, onAddFocus)
npcHandler:addModule(FocusModule:new())
