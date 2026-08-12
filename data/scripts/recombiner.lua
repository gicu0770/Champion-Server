local ACTION = 1
local ACTIONS = {
  ADD_ITEM = 1,
  UPDATE_ITEM = 2,
  COMBAINE = 3,
  CLEAR_DATA = 4,
  REMOVE_ITEM = 5,

  MERGE_MULTIPLE = 6,
}

local TYPE_ALL = 0
local TYPE_DEFUALT = 1
local TYPE_UNIQUE = 2
local TYPE_KEY = 3
local TYPE_SPELL = 4
local TYPE_CRYSTAL = 5
local TYPE_RELICT = 6
local TYPE_RECIPE = 7

local RECOMB_CONFIG = {
  [TYPE_CRYSTAL] = {
    rarityMax = 3,
    checkRarity = true,
    checkCrystal = true,
    checkItemId = true,
  },

  [TYPE_RELICT] = {
    rarityMax = 3,
    checkRarity = true,
    checkItemId = true,
    saveMods = true,
  },

  [TYPE_RECIPE] = {
    rarityMax = false,
    checkRarity = false,
    checkCrystal = false,
    checkItemId = false,
    isRecipe = true,
  },
}

local RECOMB_ITEM_RECIPES = {
  { items = {11229, 11199, 29559}, result = 38724, itemlevel = 2950, rarity = 5, keyTier = 132, questStart = 29 }, -- Soulbound
  { items = {34300, 5914, 34447}, result = 38725, itemlevel = 2950, rarity = 5, keyTier = 132, questStart = 28 }, -- Gravebound
  { items = {5895, 29802, 11223}, result = 38726, itemlevel = 2950, rarity = 5, keyTier = 132, questStart = 27 }, -- Liberator
  { items = {22532, 5809, 34292}, result = 38728, itemlevel = 2950, rarity = 5, keyTier = 132, questStart = 26 }, -- Eldritch
  { items = {15546, 31543, 31540}, result = 38727, itemlevel = 2950, rarity = 5, keyTier = 132 }, -- Goblin King
}

local RECOMB_ITEMS_BY_ID = {}
for _, data in ipairs(RECOMB_ITEM_RECIPES) do
  for i = 1, #data.items do
    RECOMB_ITEMS_BY_ID[data.items[i]] = data
  end
end

function isRecipeItem(itemId)
  return RECOMB_ITEMS_BY_ID[itemId] ~= nil
end

local LoginEvent = CreatureEvent("RecombLoginEvent")
function LoginEvent.onLogin(player)
  player:registerEvent("RecombExtendedEvent")

  for i = 1, 3 do
    player:setStorageValue(PlayerStorage.recomb + i, -1)
  end

  local depotLocker = player:getDepotChest(1, true)
  if depotLocker then
    depotLocker:setCustomAttribute("pid", player:getId())
  end
  return true
end

local ExtendedEvent = CreatureEvent("RecombExtendedEvent")
function ExtendedEvent.onExtendedOpcode(player, opcode, buffer)
  if opcode ~= ExtendedOPCodes.CODE_ROCOMBOBULATOR then
    return false
  end

  local status, data = pcall(function()
    return json.decode(buffer)
  end)

  if not status then
    return false
  end

  if data[ACTION] == ACTIONS.ADD_ITEM then
    local pos = Position(data[2])
    local id = data[3]
    if not id then
      for i = 1, 3 do
        if player:getStorageValue(PlayerStorage.recomb + i) == -1 then
          id = i
          break
        end
      end
      if not id then
        return
      end
    end
  
    local item = player:getItem(pos)
    if item then
      player:addItemToRecomb(id, item)
    end
  elseif data[ACTION] == ACTIONS.COMBAINE then
    player:combaineItems()
  elseif data[ACTION] == ACTIONS.REMOVE_ITEM then
    local id = data[2]
    player:setStorageValue(PlayerStorage.recomb + id, -1)
    player:sendExtendedOpcode(ExtendedOPCodes.CODE_ROCOMBOBULATOR, json.encode({ACTIONS.REMOVE_ITEM, id}))
  elseif data[ACTION] == ACTIONS.MERGE_MULTIPLE then
    local itemUids = data[2]
    player:mergeMultipleCrystals(itemUids)
  end
end

function Player:addItemToRecomb(id, item)
  local uid = item:getRealUID()
  if not uid or uid == 0 or item:isContainer() then
    self:sendTooltipMessage("Item cant be upgraded")
    return
  end

  local categoryType = getItemType(item)
  local isRecipe = isRecipeItem(item:getId())
  if isRecipe then
    categoryType = TYPE_RECIPE
  end

  if not categoryType then
    self:sendTooltipMessage("This Item is not upgradable.")
    return
  end

  local config = RECOMB_CONFIG[categoryType]
  if not config then
    self:sendTooltipMessage("You can't recombine this item.")
    return
  end

  local itemId = item:getId()
  local crystalData
  if config.checkCrystal then
    crystalData = CRYSTAL_DATA_FROM_ID[itemId]
    if not crystalData then
      self:sendTooltipMessage("Something went wrong, try again! ERROR #6")
      return
    end
  end

  local rarity = item:getRarityId()
  if config.rarityMax and config.rarityMax ~= false and rarity > config.rarityMax then
    self:sendTooltipMessage("Max Rarity reached!")
    return
  end

  -- Skip corrupted/mirrored checks for recipe items
  if not isRecipe then
    if item:isCorrupted() then
      self:sendTooltipMessage("Sorry, this item is corrupted and can't be modified!")
      return
    end

    if item:isMirrored() then
      self:sendTooltipMessage("Sorry, this item is mirrored and can't be modified!")
      return
    end
  end

  local uid = item:getRealUID()
  local mods = {}

  local count = 1
  
  -- For recipe items, track which item IDs have been added
  local recipeItemIds = {itemId}
  
  for i = 1, 3 do
    if i == id then
      goto continue
    end
  
    local otherItemUID = self:getStorageValue(PlayerStorage.recomb + i)
    if otherItemUID == -1 then
      goto continue
    end

    if otherItemUID == uid then
      self:sendTooltipMessage("You have already selected this item")
      return
    end

    local otherItem = Game.getRealUniqueItem(otherItemUID)
    if not otherItem then
      self:sendTooltipMessage("Something went wrong, try again. ERROR #1")
      return
    end

    -- Check if the other item is the same category type
    local otherCategoryType = getItemType(otherItem)
    local otherIsRecipeItem = isRecipeItem(otherItem:getId())
    if otherIsRecipeItem then
      otherCategoryType = TYPE_RECIPE
    end

    if categoryType ~= otherCategoryType then
      self:sendTooltipMessage("Wrong Item Type, all items needs to be same category.")
      return
    end

    -- For recipe items, check if we're adding a duplicate item ID
    if categoryType == TYPE_RECIPE then
      local otherItemId = otherItem:getId()
      for _, existingId in ipairs(recipeItemIds) do
        if existingId == otherItemId then
          self:sendTooltipMessage("You can't add duplicate items to this recipe.")
          return
        end
      end
      table.insert(recipeItemIds, otherItemId)
    end

    if config.checkRarity then
      local otherRarity = otherItem:getRarityId()
      if rarity ~= -1 and rarity ~= otherRarity then
        self:sendTooltipMessage("Wrong Rarity, all items needs to be same rarity")
        return
      end
    end

    if config.checkItemId then
      local otherItemId = otherItem:getId()
      if otherItemId ~= itemId then
        self:sendTooltipMessage("Wrong Item Type, all items needs to be same item type.")
        return
      end
    end

    if config.saveMods then
      local bonuses = otherItem:getBonusAttributes()
      if bonuses then
        for _, bonus in ipairs(bonuses) do
          table.insert(mods, bonus)
        end
      end
    end

    count = count + 1
    ::continue::
  end

  local bonuses = item:getBonusAttributes()
  if bonuses then
    for _, bonus in ipairs(bonuses) do
      table.insert(mods, bonus)
    end
  end

  local itemType = item:getType()
  local colorItem = item:getColor()
  if colorItem > 0 then
    rarity = colorItem
  end
  local dataToSend = {
    i = itemType:getClientId(),
    u = uid,
    r = rarity,
    c = count,
  }

  if isRecipe then
    dataToSend.res = { RECOMB_ITEMS_BY_ID[itemId].result, RECOMB_ITEMS_BY_ID[itemId].itemlevel, RECOMB_ITEMS_BY_ID[itemId].rarity, RECOMB_ITEMS_BY_ID[itemId].keyTier}
  end

  if categoryType == TYPE_CRYSTAL then
    dataToSend.cd = crystalData
  elseif categoryType == TYPE_RELICT then
    local relictData = BOSS_DROPS_BY_ID[item:getId()]
    dataToSend.rd = relictData.imps
    dataToSend.wi = relictData.weight
    dataToSend.mods = mods
  end

  self:setStorageValue(PlayerStorage.recomb + id, uid)
  self:sendExtendedOpcode(ExtendedOPCodes.CODE_ROCOMBOBULATOR, json.encode({ACTIONS.UPDATE_ITEM, id, dataToSend}))
end

function Player:combaineItems()
  local backpack = self:getSlotItem(CONST_SLOT_BACKPACK)
  if not backpack then
    self:sendTooltipMessage("You don't have a backpack.")
    return
  end
  if backpack and backpack:getEmptySlots(true) <= 0 then
    self:sendTooltipMessage("You don't have enough space in backpack.")
    return
  end

  local items = {}
  local finalId, finalRarity, categoryType, config
  local itemLevel = 0
  for i = 1, 3 do
    local tempItem = Game.getRealUniqueItem(self:getStorageValue(PlayerStorage.recomb + i))
    if not tempItem then
      self:sendTooltipMessage("Something went wrong, try again! ERROR #2")
      self:setStorageValue(PlayerStorage.recomb + i, -1)
      self:sendExtendedOpcode(ExtendedOPCodes.CODE_ROCOMBOBULATOR, json.encode({ACTIONS.REMOVE_ITEM, i}))
      return
    end

    local relictBox = self:getSlotItem(CONST_SLOT_RELICT_BOX)
    local container = tempItem:getParent()
    if container and container == relictBox then
      self:sendTooltipMessage("You cannot recombine items from Relict Box.")
      self:setStorageValue(PlayerStorage.recomb + i, -1)
      self:sendExtendedOpcode(ExtendedOPCodes.CODE_ROCOMBOBULATOR, json.encode({ACTIONS.REMOVE_ITEM, i}))
      return
    end

    local parent = tempItem:getTopParent()
    if parent ~= self then
      local pid = 0
      if parent:isItem() then
        pid = parent:getCustomAttribute("pid") or 0
      end

      if pid ~= self:getId() then
        self:sendTooltipMessage("Something went wrong, try again! ERROR #3")
        self:setStorageValue(PlayerStorage.recomb + i, -1)
        self:sendExtendedOpcode(ExtendedOPCodes.CODE_ROCOMBOBULATOR, json.encode({ACTIONS.REMOVE_ITEM, i}))
        return
      end
    end

    local id = tempItem:getId()
    local rarity = tempItem:getRarityId()
    if not categoryType then
      categoryType = getItemType(tempItem)
      local isRecipe = isRecipeItem(tempItem:getId())
      if isRecipe then
        categoryType = TYPE_RECIPE
      end
    end

    itemLevel = itemLevel + (tempItem:getItemLevel() or 0)

    if categoryType ~= TYPE_RECIPE then
      for _, data in ipairs(items) do
        if data.id ~= id or data.rarity ~= rarity then
          self:sendTooltipMessage("Something went wrong, try again! ERROR #11")
          return
        end
      end
    end

    items[i] = {
      item = tempItem,
      id = id,
      rarity = rarity
    }

    finalId = id
    finalRarity = rarity
  end

  itemLevel = math.ceil(itemLevel / 3)

  if not categoryType then
    self:sendTooltipMessage("This Item is not upgradable.")
    return
  end

  local config = RECOMB_CONFIG[categoryType]
  if not config then
    self:sendTooltipMessage("You can't recombine this item.")
    return
  end
  local newItem = Game.createItem(finalId, 1)
  if not newItem then
    self:sendTooltipMessage("Something went wrong, try again! ERROR #4")
    newItem:remove()
    return
  end

  if categoryType == TYPE_CRYSTAL then
    local crystalData = CRYSTAL_DATA_FROM_ID[finalId]
    if not crystalData or not crystalData[1] or not crystalData[2] or not crystalData[2][finalRarity+1] then
      self:sendTooltipMessage("Something went wrong, try again! ERROR #5")
      newItem:remove()
      return
    end

    newItem:setRarity(finalRarity+1)
    newItem:setCustomAttribute("crystal", true)
    newItem:setCustomAttribute("slots", 1)
    newItem:setAttributeValue(1, ""..crystalData[1].."|"..crystalData[2][finalRarity+1].."|0|0")
  elseif categoryType == TYPE_RECIPE then
    -- Handle recipe items
    -- Collect all item IDs from the slots
    local itemIds = {}
    for _, data in ipairs(items) do
      table.insert(itemIds, data.id)
    end
    table.sort(itemIds)
    
    -- Find matching recipe
    local recipeData = nil
    for _, recipe in ipairs(RECOMB_ITEM_RECIPES) do
      local recipeItems = {}
      for _, itemId in ipairs(recipe.items) do
        table.insert(recipeItems, itemId)
      end
      table.sort(recipeItems)
      
      -- Check if all items match
      local matches = true
      if #recipeItems == #itemIds then
        for i = 1, #recipeItems do
          if recipeItems[i] ~= itemIds[i] then
            matches = false
            break
          end
        end
        if matches then
          recipeData = recipe
          break
        end
      end
    end
    
    if not recipeData then
      self:sendTooltipMessage("Recipe not found! ERROR #9")
      newItem:remove()
      return
    end

    newItem:remove()

    local resultItem = Game.createItem(recipeData.result, 1)
    if not resultItem then
      self:sendTooltipMessage("Failed to create recipe result! ERROR #10")
      return
    end

    for _, data in ipairs(items) do
      data.item:remove()
    end
    resultItem:setCustomAttribute("keytier", recipeData.keyTier)
    resultItem:setItemLevel(recipeData.itemlevel)
    resultItem:setCustomAttribute("DungeonKey", true)
    resultItem:setRarity(recipeData.rarity or 0)
    self:addItemEx(resultItem)
    if recipeData.questStart then
      if not self:completedQuest(recipeData.questStart) then
        self:startQuest(recipeData.questStart)
      end
    end


    for i = 1, 3 do
      self:setStorageValue(PlayerStorage.recomb + i, -1)
    end
    self:sendExtendedOpcode(ExtendedOPCodes.CODE_ROCOMBOBULATOR, json.encode({ACTIONS.CLEAR_DATA}))
    self:sendTooltipMessage("Recipe completed successfully!")
    return
  elseif categoryType == TYPE_RELICT then
    local dataItem = BOSS_DROPS_BY_ID[finalId]
    if not dataItem then
      self:sendTooltipMessage("Something went wrong, try again! ERROR #7")
      newItem:remove()
      return
    end

    local mods = {}
    for i = 1, 3 do
      local tempItemData = items[i]
      if tempItemData then
        local tempItem = tempItemData.item
        if not tempItem then
          self:sendTooltipMessage("Something went wrong, try again! ERROR #8")
          newItem:remove()
          return
        end

        local bonuses = tempItem:getBonusAttributes()
        if bonuses then
          for _, bonus in ipairs(bonuses) do   
            table.insert(mods, bonus)
          end
        end
      end
    end

    for i = #mods, 2, -1 do
      local j = math.random(1, i)
      mods[i], mods[j] = mods[j], mods[i]
    end

    finalRarity = finalRarity + 1
    newItem:setRarity(finalRarity)
    newItem:setModifiersSlots(finalRarity)
    newItem:setCustomAttribute("relict", true)
    newItem:setItemLevel(itemLevel)

    if dataItem.forceType then
      newItem:setCustomAttribute("forceType", dataItem.forceType)
    end

    if dataItem.imps and dataItem.imps[1] then
      newItem:setImplictSlots(#dataItem.imps[1])
      for x = 1, #dataItem.imps[1] do
        newItem:setImplictValue(x, dataItem.imps[1][x].."|".. dataItem.imps[2][x][finalRarity] .."|".. 0)
      end
    end

    local addedMods = 0
    local index = 1
    local sameMods = {}
    for i = 1, #mods do
      if addedMods >= finalRarity then
        break
      end

      local randomMod = mods[i]
      if randomMod and not sameMods[randomMod[1]] then
        addedMods = addedMods + 1
        sameMods[randomMod[1]] = true
        newItem:setAttributeValue(index, randomMod[1].."|"..randomMod[2].."|"..randomMod[3].."|"..randomMod[4])
        index = index + 1
      end
    end

    local modsLeft = finalRarity - addedMods
    for _ = 1, modsLeft do
      local attr = newItem:randomizeAttribute()
      if not attr then
        break
      end

      local slot = newItem:getLastSlot() + 1
      local tier = getTierAttribute(newItem, 1.0)
      local value = generateRandomAttributeValue(attr, tier, newItem)
      newItem:setAttributeValue(slot, attr.."|"..value.."|"..tier)
    end
  end

  for _, data in ipairs(items) do
    data.item:remove()
  end

  self:addItemEx(newItem)
  for i = 1, 3 do
    self:setStorageValue(PlayerStorage.recomb + i, -1)
  end
  self:sendExtendedOpcode(ExtendedOPCodes.CODE_ROCOMBOBULATOR, json.encode({ACTIONS.CLEAR_DATA}))
end

function Player:mergeMultipleCrystals(itemUids)
  local storeInbox = self:getSlotItem(CONST_SLOT_STORE_INBOX)
  if not storeInbox then
    self:sendTooltipMessage("Store inbox not found.")
    return
  end

  local inbox = self:getInbox()
  if not inbox then
    self:sendTooltipMessage("No Inbox found.")
    return
  end

  local crystalBag = storeInbox:getItemById(38390)
  if not crystalBag then
    self:sendTooltipMessage("Crystal bag not found.")
    return
  end

  local numItems = #itemUids
  local numSets = math.floor(numItems / 3)

  if numSets == 0 then
    self:sendTooltipMessage("Not enough items to merge. Need at least 3 items.")
    return
  end

  local mergedCount = 0
  for setIndex = 0, numSets - 1 do
    local startIdx = setIndex * 3 + 1
    local items = {}
    local allValid = true
    local itemId, rarity

    for i = startIdx, startIdx + 2 do
      local uid = itemUids[i]
      if not uid then
        allValid = false
        break
      end
   
      local item = Game.getRealUniqueItem(uid)
      if not item then
        allValid = false
        break
      end
  
      -- Verify item is in special storage
      local parent = item:getParent()
      if not parent or parent ~= crystalBag then
        allValid = false
        break
      end
   
      local currentItemId = item:getId()
      local currentRarity = item:getRarityId()
   
      -- Check if it's a crystal
      if not item:getCustomAttribute("crystal") then
        allValid = false
        break
      end
  
      -- First item in set - store reference values
      if #items == 0 then
        itemId = currentItemId
        rarity = currentRarity
      else
        -- Validate all items in set match
        if currentItemId ~= itemId or currentRarity ~= rarity then
          allValid = false
          break
        end
      end
 
      table.insert(items, {
        item = item,
        id = currentItemId,
        rarity = currentRarity
      })
    end

    if not allValid or #items ~= 3 then
      self:sendTooltipMessage("Failed to merge set " .. (setIndex + 1) .. ". All 3 items must be crystals with matching ID and rarity.")
      goto continue
    end

    -- Check if we can upgrade (max rarity is 4 for crystals)
    if rarity >= 4 then
      self:sendTooltipMessage("Set " .. (setIndex + 1) .. " has reached max rarity (4).")
      goto continue
    end
    
    -- Get crystal data
    local crystalData = CRYSTAL_DATA_FROM_ID[itemId]
    if not crystalData or not crystalData[1] or not crystalData[2] or not crystalData[2][rarity + 1] then
      self:sendTooltipMessage("Failed to get crystal data for set " .. (setIndex + 1) .. ".")
      goto continue
    end
    
    -- Create the merged crystal item
    local newItem = Game.createItem(itemId, 1)
    if not newItem then
      self:sendTooltipMessage("Failed to create merged item for set " .. (setIndex + 1) .. ".")
      goto continue
    end
    
    -- Set crystal properties with upgraded rarity
    newItem:setRarity(rarity + 1)
    newItem:setCustomAttribute("crystal", true)
    newItem:setCustomAttribute("slots", 1)
    newItem:setAttributeValue(1, "" .. crystalData[1] .. "|" .. crystalData[2][rarity + 1] .. "|0|0")
    
    -- Remove the 3 original items
    for _, data in ipairs(items) do
      data.item:remove()
    end
    
    -- Add the merged item to crystal bag
    crystalBag:addItemEx(newItem)
    mergedCount = mergedCount + 1
    
    ::continue::
  end
  
  if mergedCount > 0 then
    self:sendTooltipMessage("Successfully merged " .. mergedCount .. " sets of crystals.")
  else
    self:sendTooltipMessage("No crystals were merged.")
  end

  self:sendExtendedOpcode(ExtendedOPCodes.CODE_ROCOMBOBULATOR, json.encode({ACTIONS.MERGE_MULTIPLE}))
end

LoginEvent:type("login")
LoginEvent:register()
ExtendedEvent:type("extendedopcode")
ExtendedEvent:register()