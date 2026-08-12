ENCHANT_INFO = {}
FORGE_CONFIG = {
  POWDER = {
    [1] = PlayerStorage.forgePowder1,
    [2] = PlayerStorage.forgePowder2,
    [3] = PlayerStorage.forgePowder3,
    [4] = PlayerStorage.forgePowder4,
    [5] = PlayerStorage.forgePowder5,
  },
  
  ORBS = {
    802012,
    802008,
    802011,
    802014,
    802004,
    802001,
    802000,
  },

  BOOKS = {
    [1] = 802009,
    [2] = 802010,
    [3] = 802013,
  },

  potencialTier = {
    [1] = 10,
    [2] = 10,
    [3] = 10,
    [4] = 10,
    [5] = 10
  },

  tierAmount = {15,13,12,10,8}
}

local LoginEvent = CreatureEvent("ForegeLogin")
function LoginEvent.onLogin(player)
  player:registerEvent("ForgeExtendedOpcode")

  local item = player:getSlotItem(CONST_SLOT_FORGE)
  player:sendPowder(0, true)
  player:sendOrb(0, true)
  player:sendBook(0, true)
  player:onItemMoveForge(item, CONST_SLOT_FORGE, item ~= nil)
  return true
end

local ExtendedEvent = CreatureEvent("ForgeExtendedOpcode")
function ExtendedEvent.onExtendedOpcode(player, opcode, buffer)
  if opcode ~= ExtendedOPCodes.CODE_FORGE then return false end
  local status, data = pcall(function() return json.decode(buffer) end)
  if not status then return false end

  local item = player:getSlotItem(CONST_SLOT_FORGE)
  if not item then
    player:sendTooltipMessage("Forge: No Item found")
    return false
  end

  if item:isUnique() then
    player:sendTooltipMessage("Forge: You cant forge unique items")
    return false
  end

  if data[1] == 1 then
    item:addNewAttribute(player, data[2], data[3])
  elseif data[1] == 2 then
    item:upgradeAttributeTier(player, data[2], data[3])
  elseif data[1] == 3 then
    item:useOrb(player, data[2], data[3])
  end

  return true
end

function Item:addNewAttribute(player, attr, book)
  local tier = 1
  if attr < 1 then player:sendTooltipMessage("Forge: Invalid Values") return false end

  if self:checkForDuplicateAttributes(attr) then 
    player:sendTooltipMessage("Forge: Attribute already exists") 
    return false 
  end
  local removePotencial = generateRandomPotencial(1, FORGE_CONFIG.potencialTier[tier], book)
  if self:checkInvalidValues(player, attr, tier, FORGE_CONFIG.tierAmount[tier], book) then return false end
  local slot = self:getEmptyAttributeSlot()
  if not slot then player:sendTooltipMessage("Forge: This item have no empty slots") return false end

  local value = generateRandomAttributeValue(attr, tier, self)
  self:setAttributeValue(slot, attr.."|"..value.."|"..tier)
  player:removePowder(tier, FORGE_CONFIG.tierAmount[tier])
  if book == 1 then
    player:removeBook(book)
  else
    book = 0
  end

  self:setNewForgePotencial(removePotencial)
  local powder = {tier, FORGE_CONFIG.tierAmount[tier]}
  local outcome = "+"..US_ENCHANTMENTS[attr].name .. " (T".. tier ..")"
  player:onItemMoveForge(self, CONST_SLOT_FORGE, true, outcome, removePotencial, powder, 0, book)
end

function Item:checkForDuplicateAttributes(attr)
  local currentAttr = self:getBonusAttributes()
  for i = 1, #currentAttr do
    if currentAttr[i][1] == attr then return true end
  end
  return false
end

function Item:useOrb(player, orb, book)
  if book and FORGE_CONFIG.BOOKS[book] then
    local bookCount = player:getStorageValue(FORGE_CONFIG.BOOKS[book])
    if bookCount <= 0 then
      player:sendTooltipMessage("Forge: You dont have enough books")
      return true
    end
  end

  if orb and FORGE_CONFIG.ORBS[orb] then
    local orbCount = player:getStorageValue(FORGE_CONFIG.ORBS[orb])
    if orbCount <= 0 then
      player:sendTooltipMessage("Forge: You dont have enough orbs")
      return true
    end
  end

  if orb == 0 and self:getForgePotencial() <= 0 then
    player:sendTooltipMessage("Forge: You item dont have forge potencial!")
    return false
  end

  local removeBook = false
  local outcome = ""
  if orb == 1 then -- Orb Of Discovery
    for i = 1, 4 do
      local slot = self:getEmptyAttributeSlot()
      if not slot then break end
      local attr = self:randomizeAttribute()
      if attr then 
        local value = generateRandomAttributeValue(attr, 1, self)
        self:setAttributeValue(slot, attr.."|"..value.."|1")
        outcome = outcome .. "+" .. US_ENCHANTMENTS[attr].name .. "||"
      end
    end
  elseif orb == 2 then -- Orb of Removal
    local slots = {}
    for i = 1, 4 do
      local attr = self:getCustomAttribute("Slot" .. i)
      if attr and attr ~= "" then
        table.insert(slots, i)
      end
    end

    local slot = slots[math.random(1, #slots)]
    local attr = self:getBonusAttribute(slot)
    outcome = "-".. US_ENCHANTMENTS[attr[1]].name .. " (T".. attr[3] ..")"
    self:setAttributeValue(slot, "")
    if book == 1 then
      removeBook = true
    end
  elseif orb == 3 then -- Orb of Refinement
    local currentAttr = self:getBonusAttributes()
    for i = 1, #currentAttr do
      local attr = currentAttr[i][1]
      if attr then
        local valueRoll = nil
        local tier = currentAttr[i][3]
        local slot = ItemType(self:getId()):getSlotPosition()
        if book == 3 then
          valueRoll = currentAttr[i][2]
          if (slot == 1072) then
            valueRoll = math.floor(valueRoll / TWO_HANDED_MULTIPLIER)
          end
        end

        local value = generateRandomAttributeValue(attr, tier, self, valueRoll)
        self:setAttributeValue(i, attr.."|"..value.."|"..tier)
      end
    end
    outcome = "All attributes rerolled"
    if book == 1 or book == 3 then
      removeBook = true
    end
  elseif orb == 4 then -- Orb of Shaping
    local implictSlots = self:getImplictSlots()
    if not implictSlots or implictSlots == 0 then
      player:sendTooltipMessage("Forge: This item have no implicts to reroll")
      return false
    end

    local base_item = nil
    local itemId = self:getId()
    for i = 1, implictSlots do
      local currentImplict = self:getImplictBonusAttribute(i)
      local attr = currentImplict[1]
      local valueRoll
      local monsterLevel = currentImplict[3]
      if not base_item then
        for x = monsterLevel, 1, -1 do
          if BASE_ITEMS[x] then
            for j = 1, #BASE_ITEMS[x] do
              if BASE_ITEMS[x][j][2] == itemId then
                base_item = BASE_ITEMS[x][j]
                break
              end
            end
          end
          if base_item then
            break
          end
        end
      end
    
      if base_item and base_item[3][i] then
        local slot = ItemType(self:getId()):getSlotPosition()
        if book == 3 then
          valueRoll = currentImplict[2]
          if (slot == 1072) then
            valueRoll = math.floor(valueRoll / TWO_HANDED_MULTIPLIER)
          end
        end

        if base_item[3][i] then
          local value = generateRandomImplictBaseValue(self, base_item[3][i][2], monsterLevel, valueRoll)
          if base_item[3][i][1] >= 89 and base_item[3][i][1] <= 91 then
            value = value + math.random(2, 6)
          end
          if base_item[3][i][1] == 8 then
            value = value + 10
          end
          if (slot == 1072) then
            value = math.floor(value * TWO_HANDED_MULTIPLIER)
          end
          self:setImplictValue(i, base_item[3][i][1].."|".. value .."|".. monsterLevel)
        end

      end
    end

    if book == 1 or book == 3 then
      removeBook = true
    end
    outcome = "Implict attributes rerolled"
  elseif orb == 5 then -- Orb Of Spellweaver
    local randomNum = math.random(1, #GLOBAL_SPELL_NUMBER)
    self:setCustomAttribute("spellid", randomNum)
    self:setCustomAttribute("spelllevel", math.random(1, 3))
    if book == 1 then
      removeBook = true
    end
    outcome = "+"..GLOBAL_SPELL_NUMBER[randomNum] .. " (Lvl " .. self:getCustomAttribute("spelllevel") .. ")"
  elseif orb == 6 then -- Orb of Seal
    if self:getCustomAttribute("sealed") then
      player:sendTooltipMessage("Forge: This item is already sealed.")
      return false
    end

    if self:getEmptyAttributeSlot() then
      player:sendTooltipMessage("Forge: This item have empty slots.")
      return false
    end

    self:setCustomAttribute("sealed", 1)
    local randomNum = math.random(1, 4)
    local attr = self:getBonusAttribute(randomNum)
    self:setAttributeValue(randomNum, "")
    self:setAttributeValue(5, attr[1].."|"..attr[2].."|"..attr[3])
    outcome = "Attribute sealed: " .. US_ENCHANTMENTS[attr[1]].name.. " (T".. attr[3] ..")"
    if book == 1 then
      removeBook = true
    end
  elseif orb == 7 then -- mirror
    local item = self:clone()
    item:setCustomAttribute("mirrored", 1)
    item:setForgePotencial(0)
    if not item:moveTo(player) then
      player:sendTooltipMessage("Forge: You have no room to use this item.")
      item:remove()
      return false
    end
    outcome = "Item mirrored"
  end

  if removeBook then
    player:removeBook(book)
  else
    book = 0
  end

  player:removeOrb(orb)
  player:onItemMoveForge(self, CONST_SLOT_FORGE, true, outcome, 0, {}, orb, book)
end

function Item:upgradeAttributeTier(player, slot, book)
  local attr = self:getBonusAttribute(slot)
  local tier = attr[3]+1
  local highRollSteps = nil

  local removePotencial = generateRandomPotencial(1, FORGE_CONFIG.potencialTier[tier], book)
  if self:checkInvalidValues(player, attr[1], tier, FORGE_CONFIG.tierAmount[tier], book) then return false end

  local criticalTier = tier
  if criticalTier < 5 and 1 == math.random(1, 6) then
    criticalTier = criticalTier + 1
  end

  if book == 2 then
    attr[1] = self:randomizeAttribute(attr[1])
  elseif book == 3 then
    local slot = ItemType(self:getId()):getSlotPosition()
    local valueRoll = attr[2]
    if (slot == 1072) then
      valueRoll = math.floor(valueRoll / TWO_HANDED_MULTIPLIER)
    end

    local precentRoll = valueRoll / REDUCTION_ATTR_VALUES[attr[1]][criticalTier-1][2]
    highRollSteps = math.ceil(precentRoll * (REDUCTION_ATTR_VALUES[attr[1]][criticalTier][2]))
  end

  local value = generateRandomAttributeValue(attr[1], criticalTier, self, highRollSteps)
  self:setAttributeValue(slot, attr[1].."|"..value.."|"..criticalTier)
  self:setNewForgePotencial(removePotencial)
  player:removePowder(tier, FORGE_CONFIG.tierAmount[tier])
  player:removeBook(book)
  local powder = {tier, FORGE_CONFIG.tierAmount[tier]}
  local outcome = US_ENCHANTMENTS[attr[1]].name .. " (T".. criticalTier ..")"
  player:onItemMoveForge(self, CONST_SLOT_FORGE, true, outcome, removePotencial, powder, 0, book)
end

function generateRandomPotencial(min, max, book)
  math.randomseed(os.time())
  if book == 1 and math.random(1, 4) == 1 then
    return 0
  end
  return math.random(min,max)
end

function Player:onItemMoveForge(item, slot, equip, outcome, removePotencial, powder, orb, book)
  if not equip or not item then 
    self:sendExtendedOpcode(ExtendedOPCodes.CODE_FORGE, json.encode({ 2 }))
    return true 
  end

  if item:getRealUID() <= 0 then
    return false
  end

  local currentAttr = item:getBonusAttributes()
  if not currentAttr then
    return false
  end

  local itemType = TRANSLATE_ITEM_TYPES[item:getItemType()]
  local potential = item:getForgePotencial()
  local itemLevel = item:getItemLevel()

  local value = item:getCustomAttribute("spelllevel") or 0
  local text = "All Level Spells"
  if value > 0 then
    text = GLOBAL_SPELL_NUMBER[item:getCustomAttribute("spellid")]
  elseif item:getCustomAttribute("spelllevelall") then
    value = item:getCustomAttribute("spelllevelall")
  end
  
  local sealedSpell = {text, value}

  if not itemType then itemType = 0 end
  if not potential then potential = 0 end
  if not itemLevel then itemLevel = 0 end
  if not sealedSpell then sealedSpell = {} end
  if not outcome then outcome = false end
  if not removePotencial then removePotencial = 0 end
  if not powder then powder = {} end
  if not orb then orb = 0 end
  if not book then book = 0 end

  self:sendExtendedOpcode(ExtendedOPCodes.CODE_FORGE, json.encode({ 1, currentAttr, itemType, potential, itemLevel, sealedSpell, outcome, removePotencial, powder, orb, book }))

  return true
end

function Player:removePowder(tier, amount)
  local storage = FORGE_CONFIG.POWDER[tier]
  local tierAmount = {15,13,12,10,8}
  local powder = self:getStorageValue(storage)
  self:setStorageValue(storage, powder - tierAmount[tier])
  self:sendPowder(tier)
  return true
end

function Item:setNewForgePotencial(removePotencial)
  local itemPotencial = self:getForgePotencial()
  local summary = itemPotencial - removePotencial
  if summary < 0 then summary = 0 end
  self:setForgePotencial(summary)
end

function Player:sendPowder(id, all)
  if all then
    local powder = {}
    for i = 1, #FORGE_CONFIG.POWDER do
      powder[i] = self:getStorageValue(FORGE_CONFIG.POWDER[i])
      if powder[i] < 0 then 
        powder[i] = 0 
        self:setStorageValue(FORGE_CONFIG.POWDER[i], 0)
      end
    end
    self:sendExtendedOpcode(ExtendedOPCodes.CODE_FORGE, json.encode({ 4, powder }))
  else
    self:sendExtendedOpcode(ExtendedOPCodes.CODE_FORGE, json.encode({ 4, self:getStorageValue(FORGE_CONFIG.POWDER[id]), id }))
  end
end

function Player:sendOrb(id, all)
  if all then
    local orbs = {}
    for i = 1, #FORGE_CONFIG.ORBS do
      orbs[i] = self:getStorageValue(FORGE_CONFIG.ORBS[i])
      if orbs[i] < 0 then 
        orbs[i] = 0 
        self:setStorageValue(FORGE_CONFIG.ORBS[i], 0)
      end
    end
    self:sendExtendedOpcode(ExtendedOPCodes.CODE_FORGE, json.encode({ 5, orbs }))
  else
    self:sendExtendedOpcode(ExtendedOPCodes.CODE_FORGE, json.encode({ 5, self:getStorageValue(FORGE_CONFIG.ORBS[id]), id }))
  end
end

function Player:sendBook(id, all)
  if all then
    local books = {}
    for i = 1, #FORGE_CONFIG.BOOKS do
      books[i] = self:getStorageValue(FORGE_CONFIG.BOOKS[i])
      if books[i] < 0 then 
        books[i] = 0 
        self:setStorageValue(FORGE_CONFIG.BOOKS[i], 0)
      end
    end
    self:sendExtendedOpcode(ExtendedOPCodes.CODE_FORGE, json.encode({ 6, books }))
  else
    self:sendExtendedOpcode(ExtendedOPCodes.CODE_FORGE, json.encode({ 6, self:getStorageValue(FORGE_CONFIG.BOOKS[id]), id }))
  end
end

function Player:removeOrb(orb)
  if not FORGE_CONFIG.ORBS[orb] then return end
  local orbCount = self:getStorageValue(FORGE_CONFIG.ORBS[orb])
  self:setStorageValue(FORGE_CONFIG.ORBS[orb], orbCount-1)
  self:sendOrb(orb)
end

function Player:removeBook(book)
  if not FORGE_CONFIG.BOOKS[book] then return end
  local bookCount = self:getStorageValue(FORGE_CONFIG.BOOKS[book])
  self:setStorageValue(FORGE_CONFIG.BOOKS[book], bookCount-1)
  self:sendBook(book)
end

function Item:checkInvalidValues(player, attr, tier, powder, book)
  local forgePotencial = self:getForgePotencial()
  local level = player:getLevel()
  local itemLevel = self:getItemLevel()
  local amount = player:getStorageValue(FORGE_CONFIG.POWDER[tier])

  local powderLeft = amount - powder
  if powderLeft < 0 then
    player:sendTooltipMessage("Forge: You dont have enough powder")
    return true
  end

  if FORGE_CONFIG.BOOKS[book] then
    local bookCount = player:getStorageValue(FORGE_CONFIG.BOOKS[book])
    if bookCount <= 0 then
      player:sendTooltipMessage("Forge: You dont have enough books")
      return true
    end
  end

  if itemLevel <= 15 and tier >= 3 then player:sendTooltipMessage("Forge: This item can only reach affix Tier 2.") return true end -- lvl 300
  if itemLevel <= 25 and tier >= 4 then player:sendTooltipMessage("Forge: This item can only reach affix Tier 3.") return true end -- lvl 700
  if itemLevel <= 35 and tier >= 5 then player:sendTooltipMessage("Forge: This item can only reach affix Tier 4.") return true end -- lvl 900

  if tier > 5 then player:sendTooltipMessage("Forge: Max Tier reached") return true end

  local attribute = US_ENCHANTMENTS[attr]
  if not attribute then player:sendTooltipMessage("Forge: Invalid attribute type ".. attr) return true end

  if bit.band(self:getItemType(), attribute.itemType) == 0 then
    player:sendTooltipMessage("Forge: Invalid item type for this attribute")
    return true
  end

  if attribute.minLevel and attribute.minLevel > level then
    player:sendTooltipMessage("Forge: You need level ".. attribute.minLevel .." for this attribute")
    return true
  end

  if not REDUCTION_ATTR_VALUES[attr] then player:sendTooltipMessage("Forge: Invalid attribute type ".. attr) return true end
  if forgePotencial <= 0 then player:sendTooltipMessage("Forge: You item dont have forge potencial!") return true end
  return false
end

LoginEvent:type("login")
LoginEvent:register()
ExtendedEvent:type("extendedopcode")
ExtendedEvent:register()
