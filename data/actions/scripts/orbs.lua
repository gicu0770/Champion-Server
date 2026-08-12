TYPE_ALL = 0
TYPE_DEFUALT = 1
TYPE_UNIQUE = 2
TYPE_KEY = 3
TYPE_SPELL = 4
TYPE_CRYSTAL = 5
TYPE_RELICT = 6

-- itemTypes = {
-- 	[0] = "None",
-- 	[1] = "Two-Handed Melee",
-- 	[2] = "One-Handed Melee",
-- 	[3] = "Two-Handed Bow",
-- 	[4] = "One-Handed Bow",
-- 	[5] = "Throwing Knife",
-- 	[6] = "Two-Handed Wand",
-- 	[7] = "Distance",
-- 	[8] = "One-Handed Wand",
-- 	[9] = "Helmet",
-- 	[10] = "Necklace",
-- 	[11] = "Armor",
-- 	[12] = "Legs",
-- 	[13] = "Boots",
-- 	[14] = "Ring",
-- 	[15] = "Gloves",
-- 	[16] = "Shield",
-- 	[17] = "Potion",
-- 	[18] = "Spell Rune",
-- 	[19] = "Support Rune",
-- 	[20] = "Backpack",
-- 	[21] = "Usable",
-- 	[22] = "Craft Material",
-- 	[23] = "Dungeon Key",
-- 	[24] = "Store Item"
-- }

local blockedIds = {
  [2092] = true, [2087] = true, [2089] = true, [2088] = true,
  [22605] = true, [22606] = true, [22604] = true, [22607] = true
}

local ORBS = {
  [31109] = { -- Orb of Spellbound
    [TYPE_ALL] = {
      func = function(item, target, orb)
        return spellBound(item, target, orb)
      end,
    },
  },
  [37148] = { -- Orb of Lesser Rune
    [TYPE_SPELL] = {
      func = function(item, player)
        return addExpToItem(item, {exp = 12000}, player)
      end
    }
  },
  [37140] = { -- Orb of Greater Rune
    [TYPE_SPELL] = {
      func = function(item, player)
        return addExpToItem(item, {exp = 50000}, player)
      end
    }
  },
  [37154] = { -- Orb of Perfect Rune
    [TYPE_SPELL] = {
      func = function(item, player)
        return addExpToItem(item, {exp = 175000}, player)
      end
    }
  },

  [37112] = {
    [TYPE_DEFUALT] = {
      func = function(item) return rerollModifiers(item, {onlyAboveTier = 6}) end,
    },
  },
  [37120] = { -- Orb of Seal
    [TYPE_DEFUALT] = {
      func = function(item) return sealRandomModifier(item, {minMods = 4}) end,
    },
  },
  [37113] = { -- Orb Of Lock
    [TYPE_KEY] = {
      func = function(item) return increaseDungeonTier(item, {minLevel = 124, maxLevel = 180, plus = math.random(1, 55)}) end,
    },
  },
  --[[
  [37113] = { -- Orb Of Quality
    [37949] = {
      func = function(item, player) return increaseQuality(item, {plus = 1, minQuality = 0, maxQuality = 50, removeAmount = 5}, player) end,
    },
    [TYPE_ALL] = {
      func = function(item) return increaseQuality(item, {plus = 1, minQuality = 0, maxQuality = 20}) end,
    },
    [TYPE_KEY] = {
      func = function(item) return increaseMonsterLevel(item, {plus = 1, minLevel = 0, maxLevel = 15}) end,
    },
  },
  --]]


  [37131] = { -- Orb of Tar Quality "Increases the Quality of Weapons and Shields by up to 30%."
    [TYPE_ALL] = {
      func = function(item) return increaseQuality(item, {plus = 1, minQuality = 0, maxQuality = 30, itemType = {1, 2, 3, 4, 5, 6, 7, 8, 16}}) end,
    },
  },
  [37135] = { -- Orb of Thunder Quality "Increases the Quality of Boots, Amulet and Gloves by up to 30%."
    [TYPE_ALL] = {
      func = function(item) return increaseQuality(item, {plus = 1, minQuality = 0, maxQuality = 30, itemType = {13, 10, 15}}) end,
    },
  },
  [37125] = { -- Orb of Golden Quality "Increases the Quality of Rings and Helmet by up to 30%."
    [TYPE_ALL] = {
      func = function(item) return increaseQuality(item, {plus = 1, minQuality = 0, maxQuality = 30, itemType = {14, 9}}) end,
    },
  },
  [37141] = { -- Orb of Iced Quality "Increases the Quality of Armor, Legs by up to 30%."
    [TYPE_ALL] = {
      func = function(item) return increaseQuality(item, {plus = 1, minQuality = 0, maxQuality = 30, itemType = {11, 12}}) end,
    },
  },

  [38496] = { -- Quality Weapon Shard "Increases the Quality of Weapons, Gloves and Shields by 1% up to 20%."
    [TYPE_ALL] = {
      func = function(item) return increaseQuality(item, {plus = 1, minQuality = 0, maxQuality = 20, itemType = {1, 2, 3, 4, 5, 6, 7, 8, 15, 16}}) end,
    },
  },
  [38422] = { -- Quality Armor Shard "Increases the Quality of Helmet, Armor, Legs and Boots by 1% up to 20%."
    [TYPE_ALL] = {
      func = function(item) return increaseQuality(item, {plus = 1, minQuality = 0, maxQuality = 20, itemType = {9,11,12,13}}) end,
    },
  },
  [38431] = { -- Quality Accessories Shard "Increases the Quality of Potions, Rings and Amulet by 1% up to 20%."
    [TYPE_ALL] = {
      func = function(item) return increaseQuality(item, {plus = 1, minQuality = 0, maxQuality = 20, itemType = {17,10,14}}) end,
    },
  },
  [38425] = { -- Quality Spell Shard "Increases the Quality of Spells Rune by 1% up to 20%."
    [TYPE_ALL] = {
      func = function(item) return increaseQuality(item, {plus = 1, minQuality = 0, maxQuality = 20, itemType = {18,19}}) end,
    },
  },
  [38423] = { -- Quality Relict Shard "Increases the Quality of Relicts by 1% up to 20%."
    [TYPE_ALL] = {
      func = function(item) return increaseQuality(item, {plus = 1, minQuality = 0, maxQuality = 20, itemType = {27}}) end,
    },
  },

  -- itemTypes = {
-- 	[0] = "None",
-- 	[1] = "Two-Handed Melee",
-- 	[2] = "One-Handed Melee",
-- 	[3] = "Two-Handed Bow",
-- 	[4] = "One-Handed Bow",
-- 	[5] = "Throwing Knife",
-- 	[6] = "Two-Handed Wand",
-- 	[7] = "Distance",
-- 	[8] = "One-Handed Wand",
-- 	[9] = "Helmet",
-- 	[10] = "Necklace",
-- 	[11] = "Armor",
-- 	[12] = "Legs",
-- 	[13] = "Boots",
-- 	[14] = "Ring",
-- 	[15] = "Gloves",
-- 	[16] = "Shield",
-- 	[17] = "Potion",
-- 	[18] = "Spell Rune",
-- 	[19] = "Support Rune",
-- 	[20] = "Backpack",
-- 	[21] = "Usable",
-- 	[22] = "Craft Material",
-- 	[23] = "Dungeon Key",
-- 	[24] = "Store Item"
-- }

  [38742] = { -- Orb of Alternation
    [TYPE_DEFUALT] = {
      func = function(item)
        return addOrSwapSpecialMod69_70_71(item)
      end,
    },
  },

  [36959] = { -- Mirror
    [TYPE_ALL] = {
      func = function(item, player)
        return mirrorItem(item, player)
      end
    }
  },

  [37109] = { -- orb of scouring
    [TYPE_DEFUALT] = {
      func = function(item) return removeAllMods(item) end,
    },
  },

  [0] = { -- Orb of Perfect Rune Spell/Support
    [TYPE_SPELL] = {
      func = function(item) 
        return changeRarity(item, {plus = 1, needs = 3})
      end
    }
  },

  [0] = { -- Orb of Greater Rune
    [TYPE_SPELL] = {
      func = function(item) 
        return changeRarity(item, {plus = 1, needs = 2})
      end
    }
  },

  [0] = { -- Orb of Lesser Rune
    [TYPE_SPELL] = {
      func = function(item) 
        return changeRarity(item, {plus = 1, needs = 1})
      end
    }
  },

  [37122] = {
    [TYPE_DEFUALT] = {
      func = function(item) 
        return increaseCrystalSlots(item, {plus = 1, max = 6})
      end
    },
    [TYPE_UNIQUE] = {
      func = function(item) 
        return increaseCrystalSlots(item, {plus = 1, max = 6})
      end
    },
    [TYPE_SPELL] = {
      func = function(item) 
        if item:getType():getSlotPosition() ~= 8240 then
          return false, "You can't use this orb on this item."
        end
        return increaseCrystalSlots(item, {plus = 1, max = 6})
      end
    },
  },

  [37121] = { -- Orb of Void
    [TYPE_DEFUALT] = {
      func = function(item) return rerollTiers(item, 5.0) end,
    },
    [TYPE_KEY] = {
      func = function(item) return rerollDungeonTiers(item, {multiplier = 5.0}) end,
    },
  },

  [37117] = { -- Orb of Spellweaver
    [TYPE_DEFUALT] = {
      func = function(item) return rollSpellLevelAll(item) end -- rollSpellLevel(item) end
    },
    [TYPE_UNIQUE] = {
      func = function(item) return rollSpellLevelAll(item) end -- rollSpellLevel(item) end
    },
  },
  
  
  -- [0] = { -- transform item
  --   [TYPE_DEFUALT] = {
  --     func = function(item) return transfromToOtherItem(item)end
  --   },
  -- },
  --[[
Stary Corruption
  [18422] = { -- Orb of corrupted
    [TYPE_DEFUALT] = {
      func = function(item)
        local random = math.random(1, 5)
        if random == 1 then
          return true, "Nothing happend."
        elseif random == 2 then
          return increaseQuality(item, {plus = math.random(-15, 40)})
        elseif random == 3 then
          return addNewRandomModifier(item, {force = true})
        elseif random == 4 then
          return rerollModsAndTiers(item, {multiplier = (math.random(0, 2500) / 100)})
        elseif random == 5 then
          return addRandomImplict(item)
        end
      end,

      extraFunc = function(item)
        item:setCorrupted(true)
      end
    },
    [TYPE_UNIQUE] = {
      func = function(item)
        local random = math.random(1, 5)
        if random == 1 then
          return true, "Nothing happend."
        elseif random == 2 then
          return increaseQuality(item, {plus = math.random(-15, 40)})
        elseif random == 3 then
          return rerollUniqueValues(item)
        elseif random == 4 then
          return addRandomImplict(item)
        elseif random == 5 then
          return transfromToOtherItem(item, true)
        end
      end,

      extraFunc = function(item)
        item:setCorrupted(true)
      end
    },
    [TYPE_KEY] = {
      func = function(item)
        local random = math.random(1, 5)
        if random == 1 then
          return true, "Nothing happend."
        elseif random == 2 then
          return increaseMonsterLevel(item, {plus = math.random(-15, 40)})
        elseif random == 3 then
          return addNewRandomDungModifier(item, {force = true})
        elseif random == 4 then
          return rerollDungeonModsAndTiers(item, {multiplier = (math.random(0, 2500) / 100)})
        elseif random == 5 then
          return transformToOtherKey(item)
        end
      end,

      extraFunc = function(item)
        item:setCorrupted(true)
      end
    },
  },
    --]]
  [18422] = { -- Orb of corrupted
    [TYPE_DEFUALT] = {
      func = function(item)
        local random = math.random(1, 6)
        if random == 1 then
          return increaseQuality(item, {plus = math.random(1, 35)})
        elseif random == 2 then
          return addNewRandomModifier(item, {force = true})
        elseif random == 3 then
          return addRandomImplict(item)
        elseif random == 4 then
          local upgradeLevel = item:getUpgradeLevel() or 0
          return item:setUpgradeLevel(upgradeLevel + math.random(1,3))
        elseif random == 5 then
          return increaseCrystalSlots(item, {plus = 1, max = 7})
        elseif random == 6 then
          return rollSpellLevelAll(item, true) -- return rollSpellLevel(item, true)
        end
      end,
      extraFunc = function(item)
        item:setCorrupted(true)
      end
    },
    [TYPE_UNIQUE] = {
      func = function(item)
        local random = math.random(1, 4)
        if random == 1 then
          return increaseQuality(item, {plus = math.random(1, 35)})
        elseif random == 2 then
          return addRandomImplict(item)
--        elseif random == 3 then
--          return transfromToOtherItem(item, true)
        elseif random == 3 then
          return increaseCrystalSlots(item, {plus = 1, max = 7})
        elseif random == 4 then
          return rollSpellLevelAll(item, true) -- return rollSpellLevel(item, true)
        end
      end,
      extraFunc = function(item)
        item:setCorrupted(true)
      end
    },
    [TYPE_KEY] = {
      func = function(item)
        local random = math.random(1, 3)
        if random == 1 then
          return increaseMonsterLevel(item, {plus = math.random(100, 250)})
        elseif random == 2 then
          return addNewRandomDungModifier(item, {force = true})
        elseif random == 3 then
          return transformToOtherKey(item)
        end
      end,
      extraFunc = function(item)
        item:setCorrupted(true)
      end
    },
  },
  [38751] = { -- Orb of Mystic / Rerolls all item modifiers and tiers
    [TYPE_RELICT] = {
      func = function(item) return rerollModsAndTiers(item, {multiplier = 5.0}) end,
    },
  },

  [37118] = { -- Orb of Chance / Rerolls all item modifiers and tiers
    [TYPE_DEFUALT] = {
      func = function(item) return rerollModsAndTiers(item, {multiplier = 5.0}) end,
    },
    [TYPE_KEY] = {
      func = function(item) return rerollDungeonModsAndTiers(item, {multiplier = 5.0}) end,
    },
  },
  [8302] = { -- Orb of Honored added new slots max 6   
    [TYPE_DEFUALT] = {
      func = function(item) return addNewRandomModifier(item, {maxSlots = 6}) end,
    },
    [TYPE_KEY] = {
      func = function(item) return addNewRandomDungModifier(item, {maxSlots = 6}) end,
    },
  },

  [8303] = { -- Orb of Enchantment added new slots max 3
    [TYPE_DEFUALT] = {
      func = function(item) return addNewRandomModifier(item, {maxSlots = 3}) end,
    },
    [TYPE_KEY] = {
      func = function(item) return addNewRandomDungModifier(item, {maxSlots = 3}) end,
    },
  },

  [37114] = { -- Orb of Removal 
    [TYPE_DEFUALT] = {
      func = function(item) return removeRandomMod(item) end,
    },
  --  [TYPE_KEY] = {
  --    func = function(item) return removeRandomDungMod(item) end,
  --  }
  },


  [38265] = { -- Orb of Lownest
    [TYPE_DEFUALT] = {
      func = function(item) return removeLowestTierMod(item) end,
    },
  },
  [38738] = { -- Orb of Begin
    [TYPE_DEFUALT] = {
      func = function(item) return removeFirstMod(item) end,
    },
  },

  [37116] = { -- Orb of Shaping
    [TYPE_DEFUALT] = {
      func = function(item) return rerollImplictsValues(item) end,
    },
    [TYPE_UNIQUE] = {
      func = function(item) return rerollImplictsUniqueValues(item) end,
    },
  },

  [37115] = { -- Orb of Refinement
    [TYPE_DEFUALT] = {
      func = function(item) return rerollModifiersValues(item) end,
    },
    [TYPE_UNIQUE] = {
      func = function(item) return rerollModifiersUniqueValues(item) end,
    },
    [TYPE_KEY] = {
      func = function(item) return rerollModifiersDungValues(item) end,
    },
  },

  [37119] = { -- Orb of Arcana
    [TYPE_DEFUALT] = {
      func = function(item) return addNewRandomModifier(item, {max = 6}) end,
    },
    [TYPE_KEY] = {
      func = function(item) return addNewRandomDungModifier(item, {max = 6}) end,
    },
  },
}

function addOrSwapSpecialMod69_70_71(item)
  local allowedTypes = {1,2,3,4,5,6,7,8,15,16}
  local itemType = formatItemType(item:getType(), item)

  if not table.find(allowedTypes, itemType) then
    return false, "This orb can only be used on weapons, shields or gloves."
  end

  local bonuses = item:getBonusAttributes()
  local specialMods = {68, 69, 70}

  local foundSlot = nil
  local foundMod = nil
  
  -- szukamy czy item ma któryś z modów
  if bonuses then
    local seals = item:getSealedModifiers()
    for i = 1, #specialMods do
       if seals and seals[tostring(specialMods[i])] then
         return false, "This item have sealed Added Modifier and can't be modified."
       end
    end
    for i = 1, #bonuses do
      local modId = bonuses[i][1]
      if modId == 68 or modId == 69 or modId == 70 then
        foundSlot = bonuses[i][4]
        foundMod = modId
        break
      end
    end
  end

  -- 🔁 PRZYPADEK 1: item MA już mod → zamiana (dozwolone nawet przy 6 modach)
  if foundSlot then
    local pool = {}

    for _, id in ipairs(specialMods) do
      if id ~= foundMod then
        table.insert(pool, id)
      end
    end

    local newAttr = pool[math.random(#pool)]

    local tier = getTierAttribute(item)
    local value = generateRandomAttributeValue(newAttr, tier, item)

    item:setAttributeValue(foundSlot, newAttr.."|"..value.."|"..tier)

    return true, "Replaced special modifier ("..US_ENCHANTMENTS[foundMod].name..") with ("..US_ENCHANTMENTS[newAttr].name..")."
  end

  -- ❌ BLOKADA: jeśli brak special moda i jest już max modów → stop
  if bonuses and #bonuses >= 6 then
    return false, "This item already has the maximum number of modifiers."
  end

  -- ➕ PRZYPADEK 2: brak moda → dodanie
  local attr = specialMods[math.random(#specialMods)]

  local slot = item:getLastSlot() + 1
  item:setModifiersSlots(slot)

  local tier = getTierAttribute(item)
  local value = generateRandomAttributeValue(attr, tier, item)

  item:setAttributeValue(slot, attr.."|"..value.."|"..tier)

  return true, "Added special modifier ("..attr..")."
end

function checkCanBeModified(item)
  local id = item:getId()
  if id == 37817 then
    local bonuses = item:getBonusAttributes()
    if not bonuses then
      return false
    end

    for i = 1, #bonuses do
      if bonuses[i][1] == 203 then
        return true
      end
    end
  end

  return false
end

function canUseOrb(item, toPosition)
  local canBeModified = checkCanBeModified(item)
  if toPosition and toPosition.y <= CONST_SLOT_POTION1 then
    return "You can't use that on equipped item!"
  end

  if item:isCorrupted() and not canBeModified then
    return "You can't use that on corrupted item!"
  end

  if item:isMirrored() then
    return "Sorry, this item is mirrored and can't be modified!"
  end

  return nil
end

function getItemType(item)
  if item:getCustomAttribute("DungeonKey") then
    return TYPE_KEY
  elseif item:getSpellName() ~= "" then
    return TYPE_SPELL
  elseif item:getCustomAttribute("unique") then
    return TYPE_UNIQUE
  elseif item:getType():isArmors() then
    return TYPE_DEFUALT
  elseif item:getCustomAttribute("crystal") then
    return TYPE_CRYSTAL
  elseif item:getCustomAttribute("relict") then
    return TYPE_RELICT
  end

  return nil
end

function onUse(player, item, fromPosition, target, toPosition, isHotkey)
  if not target or not target:isItem() or item:getId() == 0 then return end
  local returnText = canUseOrb(target, toPosition)
  if returnText then
    player:sendTextMessage(MESSAGE_STATUS_WARNING, returnText)
    player:getPosition():sendMagicEffect(3)
    return true
  end

  local isStackable = target:getType():isStackable()
  if isStackable then
    player:sendTextMessage(MESSAGE_STATUS_WARNING, "You can't use this orb on stackable items.")
    player:getPosition():sendMagicEffect(3)
    return true
  end

  local item_type = getItemType(target)
  if not item_type then
    player:sendTextMessage(MESSAGE_STATUS_WARNING, "This Item is not upgradable.")
    player:getPosition():sendMagicEffect(3)
    return true
  end

  local orb = ORBS[item:getId()]
  if not orb then
    print("ORBS | There is no orb with Id ".. item:getId())
    player:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
    return true
  end

  local orb_func = orb[target:getId()] or (orb[item_type] or orb[TYPE_ALL])
  if not orb_func then
    player:sendTextMessage(MESSAGE_STATUS_WARNING, "You can't use this orb on this item.")
    player:getPosition():sendMagicEffect(3)
    return true
  end

  local returnValue, text, removeAmount = orb_func.func(target, player, item)
  if not returnValue then
    player:sendTextMessage(MESSAGE_STATUS_WARNING, text)
    player:getPosition():sendMagicEffect(3)
    return true
  end
  
  if orb_func.extraFunc then
    orb_func.extraFunc(target)
  end
  
  local removeAmount = removeAmount or 1
  item:remove(removeAmount)
  target:setCorrectRarity()

  if item_type == TYPE_SPELL then
    SPELL_CACHE[target:getRealUID()] = nil
  end

  player:sendTextMessage(MESSAGE_INFO_DESCR, text)
  player:sendExtendedOpcode(106, json.encode({2}))
  return true
end

function increaseQuality(item, args, player)
  if not args then args = {} end
  local quality = item:isQuality() or 0
  if args.maxQuality and (quality >= args.maxQuality) then
    return false, "This orb can be used only when quality is lower than ".. args.maxQuality
  end
  if args.minQuality and (quality < args.minQuality) then
    return false, "This orb can be used only when quality is higher than " .. args.minQuality
  end

  if args.removeAmount and player:getItemCount(37113) < 5 then
    return false, "You need 5 orbs! This Unique Item consumes 5 orbs for 1% quality."
  end

  if args.itemType then
    if not table.find(args.itemType, formatItemType(item:getType(), item)) then
      return false, "Wrong item type, check orb description."
    end
  end

  item:setQuality(item:isQuality() + args.plus)
  return true, "Successfully increased quality by ".. args.plus, args.removeAmount
end

function increaseCrystalSlots(item, args)
  if not args then args = {} end
  local crystalsSlots = item:getCrystalSlots() or 0
  if args.max and (crystalsSlots >= args.max) then
    return false, "This item can have only ".. args.max .. " crystal slots"
  end

  item:setCrystalSlots(crystalsSlots + args.plus)
  return true, "Successfully increased crystal slots by ".. args.plus
end

function increaseMonsterLevel(item, args)
  if not args then args = {} end
  local mLvl = item:getCustomAttribute("extraKeyMonsterLevel")
  if not mLvl then
    mLvl = 0
    item:setCustomAttribute("extraKeyMonsterLevel", mLvl)
  end

  if args.minLevel and (mLvl <= args.minLevel) then
    return false, "This orb can be used only when extra monster level is lower than ".. args.maxLevel
  end

  if args.maxLevel and (mLvl >= args.maxLevel) then
    return false, "This orb can be used only when extra monster level is higher than ".. args.minLevel
  end

  item:setCustomAttribute("extraKeyMonsterLevel", mLvl + args.plus)
  item:setItemLevel(item:getItemLevel() + args.plus)
  return true, "Successfully increased extra monster level by ".. args.plus
end

function increaseDungeonTier(item, args)
  if not args then args = {} end
  local isKey = item:setCustomAttribute("DungeonKey")
  local mLvl = item:getCustomAttribute("keytier")
  if not mLvl then
    return false, "This orb can be used on Dungeon Key"
  end

  if args.minLevel and (mLvl <= args.minLevel) then
    return false, "This orb can be used only when Dungeon Tier is lower than ".. args.minLevel
  end

  if args.maxLevel and (mLvl >= args.maxLevel) then
    return false, "This orb can be used only when Dungeon Tier is lower than ".. args.maxLevel
  end
  local actualTier = mLvl + args.plus
  if actualTier >= args.maxLevel then
    actualTier = 180
  end
  item:setCustomAttribute("keytier", actualTier)
  item:setItemLevel(getMonsterLevelByKeyTier(actualTier))
  return true, "Successfully increased Dungeon Tier by ".. args.plus
end

function mirrorItem(item, player)
  local itemMirrored = item:clone()
  itemMirrored:setCustomAttribute("mirrored", 1)
  if not itemMirrored:moveTo(player) then
    itemMirrored:remove()
    return false, "You have no room in your backpack to make a copy!"
  end

  return true, "Successfully created a copy"
end

function changeRarity(item, args)
  if not args then args = {} end
  local rarity = item:getRarityId()
  if args.needs and rarity == args.needs then
    item:setRarity(rarity + args.plus)
    return true, "Successfully changed rarirty"
  end

  return false, "Failed to change rarirty don't match requirements, item needs to be a " .. RARITY_NAMES[args.needs] .. "!"
end

function addExpToItem(item, args, player)
  if not args then args = {} end
  if not item:addExpToSpell(args.exp, player:getDungeonTier()) then
    return false, "Failed to add exp to this item."
  end

  return true, "Successfully added " .. args.exp .. " exp."
end

function rerollTiers(item, multiplier)
  local bonuses = item:getBonusAttributes()
  if not bonuses then
    return false, "This item don't have any modifiers to reroll."
  end

  local seals = item:getSealedModifiers()
  if #bonuses == 1 and seals and seals[tostring(bonuses[1][1])] then
    return false, "This item don't have any modifiers."
  end

  for i = 1, #bonuses do
    local attr = bonuses[i][1]
    if seals then
      if seals[tostring(bonuses[i][1])] then
        goto continue
      end
    end

    local tier = getTierAttribute(item, multiplier)
    local value = generateRandomAttributeValue(attr, tier, item)
    item:setAttributeValue(i, attr.."|"..value.."|"..tier)
    ::continue::
  end

  return true, "Successfully rerolled all modifiers tiers"
end

function rollSpellLevel(item, max)
  local randomNum = math.random(1, #GLOBAL_SPELL_NUMBER)
  item:setCustomAttribute("spellid", randomNum)
  local rand = math.random(1, 6)
  local rand2 = math.random(2, 12)
  if max then
    rand = 6
    rand2 = 12
  end
  local slot = ItemType(item:getId()):getSlotPosition()
  if (slot == 1072) then
    item:setCustomAttribute("spelllevel", rand2)
  else
    item:setCustomAttribute("spelllevel", rand)
  end

  return true, "Successfully rerolled level of  ".. GLOBAL_SPELL_NUMBER[randomNum]
end

local function rollweightsLevel(maxLevel)
  local weights = {}
  local totalWeight = 0

  for level = 1, maxLevel do
    -- PoE style exponential falloff
    -- im większy level, tym brutalniej spada
    local weight = math.exp(-(level - 1) * 0.55)

    -- hard minimum (ultra rare rolls)
    if level >= 12 then
      weight = weight * 0.2
    end

    if level == maxLevel then
      weight = 0.001 -- ~0.1%
    end

    weights[level] = weight
    totalWeight = totalWeight + weight
  end

  local roll = math.random() * totalWeight
  local acc = 0

  for level = 1, maxLevel do
    acc = acc + weights[level]
    if roll <= acc then
      return level
    end
  end

  return 1
end

function rollSpellLevelAll(item, max)
  local level = rollweightsLevel(15)
  if max then
    level = 15
  end
  local slot = ItemType(item:getId()):getSlotPosition()
  if (slot == 1072) then
    level = level * 2
  end
  item:setCustomAttribute("spelllevelall", level)

  return true, "Successfully rolled All Spells Level +" .. level
end

function addNewRandomModifier(item, args)
  if not args then args = {} end
  local slots = item:countModifiers()
  if not args.force then
    if slots >= 6 then
      return false, "This item already has maximum modifiers."
    end
    if args.max and args.max <= slots then
      return false, "This item already has 6 or more modifiers."
    end

    if args.minSlots and (slots <= args.minSlots) then
      return false, "To use this orb your item needs minimum " .. args.minSlots .. " modifiers"
    end

    if args.maxSlots and (slots >= args.maxSlots) then
      return false, "To use this orb your item can have only or less " .. args.maxSlots .. " modifiers"
    end
  end

  local max = args.max and args.max - slots or 1
  local seals = item:getSealedModifiers()
  if seals then
    max = max - #seals
  end

  for _ = 1, max do
    local attr = item:randomizeAttribute()
    if not attr then
      print("ORBS | " .. item:getId() .. " can't find new radmon attribute")
      return false, "Something went wrong, we can't find any modifier to apply, Please report it to GM."
    end

    local slot = item:getLastSlot() + 1
    item:setModifiersSlots(slot)

    local tier
    if args.minTier then
      tier = math.random(args.minTier, 7)
    else
      tier = getTierAttribute(item, args.tierMultiplier)
    end

    local value = generateRandomAttributeValue(attr, tier, item)
    item:setAttributeValue(slot, attr.."|"..value.."|"..tier)
  end

  return true, "A new attribute has been added."
end

function addNewRandomDungModifier(item, args)
  if not args then args = {} end
  local slots = item:countDungModifiers()
  if not args.force then
    if blockedIds[item:getId()] then
      return false, "This item cannot be modified."
    end
    if args.max and args.max <= slots then
      return false, "This item already has 6 or more modifiers."
    end

    if args.minSlots and (slots <= args.minSlots) then
      return false, "To use this orb your item needs minimum " .. args.minSlots .. " modifiers"
    end

    if args.maxSlots and (slots >= args.maxSlots) then
      return false, "To use this orb your item can have only or less" .. args.maxSlots .. " modifiers"
    end
  end

  local multiplier = 1.0
  if args.multiplier then
    multiplier = multiplier + (math.random(args.multiplier[1], args.multiplier[2])/100)
  end


  local max = args.max and args.max - slots or 1
  for _ = 1, max do
    local attr = item:randomizeDungeonAttribute()
    if not attr then
      print("ORBS | " .. item:getId() .. " can't find new radmon dung attribute")
      return false, "Something went wrong, we can't find any modifier to apply, Please report it to GM."
    end

    local slot = item:getLastSlotDung() + 1
    item:setModifiersSlots(slot)

    local tier = getTierAttribute(item, args.tierMultiplier)
    local value = generateRandomDungeonAttributeValue(attr, tier)
    value = math.ceil(value * multiplier)
    item:setDungeonModifier(slot, attr.."|"..value.."|"..tier)
  end

  return true, "A new attribute has been added."
end

function rerollModsAndTiers(item, args)
  if not args then args = {} end
  local returnValue, text = rerollModifiers(item)
  if not returnValue then
    return returnValue, text
  end

  returnValue, text = rerollTiers(item, args.multiplier)
  if not returnValue then
    return returnValue, text
  end

  return true, "Rerolled all item modifiers and their tiers"
end


function rerollModifiers(item, args, perfect)
  local bonuses = item:getBonusAttributes()
  if not bonuses then
    return false, "This item don't have any modifiers to reroll."
  end

  local seals = item:getSealedModifiers()
  if #bonuses == 1 and seals and seals[tostring(bonuses[1][1])] then
    return false, "This item don't have any modifiers to reroll."
  end

  local rerolledModifier = false
  for i = 1, #bonuses do
    if args and args.onlyAboveTier > bonuses[i][3] then
      goto continue
    end


    if seals then
      if seals[tostring(bonuses[i][1])] then
        goto continue
      end
    end

    local attr = item:randomizeAttribute()
    if attr then
      local tier = bonuses[i][3]
      local value = generateRandomAttributeValue(attr, tier, item, false, perfect)
      item:setAttributeValue(bonuses[i][4], attr.."|"..value.."|"..tier)
      rerolledModifier = true
    end

    ::continue::
  end

  if not rerolledModifier then
    return false, "This item don't have any modifiers to reroll."
  end
  return true, "Rerolled all item modifiers"
end

function rerollDungeonModifiers(item)
  local bonuses = item:getDungeonModifiers()
  if not bonuses then
    return false, "This item don't have any modifiers to reroll."
  end

  for i = 1, #bonuses do
    local attr = item:randomizeDungeonAttribute()
    if attr then
      local tier = bonuses[i][3]
      local value = generateRandomDungeonAttributeValue(attr, tier)
      item:setDungeonModifier(bonuses[i][4], attr.."|"..value.."|"..tier)
    end
  end

  return true, "Rerolled all item modifiers"
end

function rerollDungeonTiers(item, args)
  local bonuses = item:getDungeonModifiers()
  if not bonuses then
    return false, "This item don't have any modifiers to reroll."
  end

  local multiplierMod = 1.0
  if args.multiplierMod then
    multiplierMod = multiplierMod + (math.random(args.multiplierMod[1], args.multiplierMod[2]) / 100)
  end

  for i = 1, #bonuses do
    local attr = bonuses[i][1]
    local tier = getTierAttribute(item, args.multiplier)
    local value = generateRandomDungeonAttributeValue(attr, tier)
    value = math.floor(value * multiplierMod)
    item:setDungeonModifier(bonuses[i][4], attr.."|"..value.."|"..tier)
  end

  return true, "Successfully rerolled all modifiers tiers"
end

function rerollDungeonModsAndTiers(item, args)
    if blockedIds[item:getId()] then
      return false, "This item cannot be modified."
    end
  local returnValue, text = rerollDungeonModifiers(item)
  if not returnValue then
    return returnValue, text
  end

  returnValue, text = rerollDungeonTiers(item, args)
  if not returnValue then
    return returnValue, text
  end

  return true, "Rerolled all item modifiers and their tiers"
end

function removeRandomMod(item)
  local bonuses = item:getBonusAttributes()
  if not bonuses then
    return false, "This item don't have any modifiers to remove."
  end

  local id = math.random(1, #bonuses)
  local attr = bonuses[id]
  local seals = item:getSealedModifiers()
  if seals and seals[tostring(attr[1])] then
    if #bonuses ~= 1 then
      return removeRandomMod(item)
    else
      return false, "This item don't have any modifiers to remove."
    end
  end
  local name = US_ENCHANTMENTS[attr[1]].name
  item:setAttributeValue(attr[4])

  bonuses = item:getBonusAttributes()
  item:setModifiersSlots(bonuses and #bonuses or 0)

  return true, "Successfully removed " .. name .. "."
end

function removeFirstMod(item)
  local bonuses = item:getBonusAttributes()
  if not bonuses or #bonuses == 0 then
    return false, "This item don't have any modifiers to replace."
  end

  local attr = bonuses[1]
  local slot = attr[4]
  local seals = item:getSealedModifiers()

  -- jeśli pierwszy mod jest sealed
  if seals and seals[tostring(attr[1])] then
    return false, "First modifier is sealed and cannot be replaced."
  end

  -- losujemy nowy atrybut
  local newAttr = item:randomizeAttribute()
  if not newAttr then
    return false, "Failed to find a new modifier."
  end

  -- losujemy tier (standardowo)
  local tier = getTierAttribute(item)
  local value = generateRandomAttributeValue(newAttr, tier, item)

  local oldName = US_ENCHANTMENTS[attr[1]].name
  local newName = US_ENCHANTMENTS[newAttr].name

  -- NADPISUJEMY ten sam slot
  item:setAttributeValue(slot, newAttr .. "|" .. value .. "|" .. tier)

  return true, "Replaced " .. oldName .. " with " .. newName .. "."
end

function removeLowestTierMod(item)
  local bonuses = item:getBonusAttributes()
  if not bonuses or #bonuses == 0 then
    return false, "This item don't have any modifiers to replace."
  end

  local seals = item:getSealedModifiers()
  local lowestTier = nil
  local lowestTierMods = {}

  -- znajdź najniższy tier (bez sealed)
  for _, attr in ipairs(bonuses) do
    local modId = tostring(attr[1])
    local tier = attr[3]

    if tier and not (seals and seals[modId]) then
      if not lowestTier or tier < lowestTier then
        lowestTier = tier
        lowestTierMods = { attr }
      elseif tier == lowestTier then
        table.insert(lowestTierMods, attr)
      end
    end
  end

  if #lowestTierMods == 0 then
    return false, "This item don't have any modifiers to replace."
  end

  -- losowy mod z najniższym tierem
  local attr = lowestTierMods[math.random(#lowestTierMods)]
  local slot = attr[4]

  -- losuj nowy atrybut
  local newAttr = item:randomizeAttribute()
  if not newAttr then
    return false, "Failed to find a new modifier."
  end

  -- losuj tier i wartość
  local tier = getTierAttribute(item)
  local value = generateRandomAttributeValue(newAttr, tier, item)

  local oldName = US_ENCHANTMENTS[attr[1]].name
  local newName = US_ENCHANTMENTS[newAttr].name

  -- NADPISZ TEN SAM SLOT
  item:setAttributeValue(slot, newAttr .. "|" .. value .. "|" .. tier)

  return true, "Replaced " .. oldName .. " (Tier " .. lowestTier .. ") with " .. newName .. "."
end

function removeAllMods(item)
  local bonuses = item:getBonusAttributes()
  if not bonuses then
    return false, "This item don't have any modifiers to remove."
  end

  local seals = item:getSealedModifiers()
  if seals and seals[tostring(bonuses[1][1])] then
    if #bonuses == 1 then
      return false, "This item don't have any modifiers to remove."
    end
  end

  for i = 1, #bonuses do
    if seals and seals[tostring(bonuses[i][1])] then
      goto continue
    end
    item:setAttributeValue(bonuses[i][4])
    ::continue::
  end

  bonuses = item:getBonusAttributes()
  item:setModifiersSlots(bonuses and #bonuses or 0)

  return true, "Successfully removed all modifiers."
end

function sealRandomModifier(item, args)
  local bonuses = item:getBonusAttributes()
  if not bonuses then
    return false, "This item don't have any modifiers to seal."
  end

  local seals = item:getSealedModifiers()
  if seals then
    return false, "Item have already sealed modifier."
  end

  if #bonuses < args.minMods then
    return false, "This item don't have enought modifiers, item needs minimal " .. args.minMods .. " modifiers."
  end

  local id = math.random(1, #bonuses)
  local attr = bonuses[id]
  local name = US_ENCHANTMENTS[attr[1]].name
  item:sealModifier(attr[1])

  return true, "Successfully sealed " .. name .. "."
end

function removeRandomDungMod(item)
  local bonuses = item:getDungeonModifiers()
  if not bonuses then
    return false, "This item don't have any modifiers to remove."
  end

  local id = math.random(1, #bonuses)
  local attr = bonuses[id]
  local name = US_DUNGEONS_MODIFIERS[attr[1]].name
  item:setDungeonModifier(attr[4])

  bonuses = item:getDungeonModifiers()
  item:setModifiersSlots(bonuses and #bonuses or 0)

  return true, "Successfully removed " .. name .. "."
end


function rerollImplictsUniqueValues(item)
  local implicts = item:getImplictBonusAttributes()
  if not implicts then
    return false, "This item don't have any modifiers."
  end

  local uniqueItem = US_UNIQUES[item:getUnique()]
  if not uniqueItem then
    return false, "Something went wrong with this item."
  end

  for i = 1, #implicts do
    if uniqueItem.implicit and uniqueItem.implicit[i] then
      local value = math.random(uniqueItem.implicit[i].min, uniqueItem.implicit[i].max)
      item:setImplictValue(i, uniqueItem.implicit[i].id.."|".. value .."|".. 0)
    else
      local attr = implicts[i][1]
      local tier = implicts[i][3]
      local value = generateRandomAttributeValue(attr, tier, item)
      item:setImplictValue(i, attr.."|".. value .."|".. tier)
    end
  end

  return true, "Successfully rerolled all implicts values"
end

function rerollImplictsValues(item, perfect)
  local implicts = item:getImplictBonusAttributes()
  if not implicts or item:getItemType() == US_ITEM_TYPES.POTION then
    return false, "This item don't have any implicts."
  end

  local itemId = item:getId()
  local base_item = BASE_ITEMS_BY_ID[itemId]

  if not base_item then
    return false, "Couldn't find the correct base to reroll implicits, please report it to a GM."
  end

  if not base_item[3] then
    return false, "This item doesn't have any base implicits."
  end

  local slot = ItemType(item:getId()):getSlotPosition()
  for i = 1, #implicts do
    for x = 1, #base_item[3] do
      if base_item[3][x][1] == implicts[i][1] then
        local value = generateRandomImplictBaseValue(item, base_item[3][x][2], implicts[i][3], nil, perfect)
        local bonus_range = IMPLICT_BONUS[base_item[3][x][1]] or {0, 0}
        local min = bonus_range[1]
        local max = bonus_range[2]
        if perfect then
          min = max
        end
        value = value + math.random(min, max)
        if (slot == 1072) then
             value = math.floor(value * TWO_HANDED_MULTIPLIER)
        end
        item:setImplictValue(implicts[i][5], base_item[3][x][1] .. "|" .. value .. "|" .. implicts[i][3])
        break
      end
    end
  end

  return true, "Successfully rerolled all implicts values."
end

function rerollModifiersValuesGM(item, perfect)
  local bonuses = item:getBonusAttributes()
  if not bonuses then
    return false, "This item don't have any modifiers."
  end

  local seals = item:getSealedModifiers()
  if #bonuses == 1 and seals and seals[tostring(bonuses[1][1])] then
    return false, "This item don't have any modifiers."
  end

  for i = 1, #bonuses do
    local attr = bonuses[i][1]
    local tier = bonuses[i][3]


    local value = generateRandomAttributeValue(attr, tier, item, false, perfect)
    item:setAttributeValue(bonuses[i][4], attr.."|"..value.."|"..tier)

    ::continue::
  end

  return true, "Successfully rerolled all modifiers values"
end

function rerollModifiersValues(item, perfect)
  local bonuses = item:getBonusAttributes()
  if not bonuses then
    return false, "This item don't have any modifiers."
  end

  local seals = item:getSealedModifiers()
  if #bonuses == 1 and seals and seals[tostring(bonuses[1][1])] then
    return false, "This item don't have any modifiers."
  end

  for i = 1, #bonuses do
    local attr = bonuses[i][1]
    local tier = bonuses[i][3]
    if seals then
      if seals[tostring(bonuses[i][1])] then
        goto continue
      end
    end

    local value = generateRandomAttributeValue(attr, tier, item, false, perfect)
    item:setAttributeValue(bonuses[i][4], attr.."|"..value.."|"..tier)

    ::continue::
  end

  return true, "Successfully rerolled all modifiers values"
end

function rerollModifiersUniqueValues(item)
  local bonuses = item:getBonusAttributes()
  if not bonuses then
    return false, "This item don't have any modifiers."
  end

  local uniqueItem = US_UNIQUES[item:getUnique()]
  if not uniqueItem then
    return false, "Something went wrong with this item."
  end

  for x = 1, #uniqueItem.attr do
    local value = math.random(uniqueItem.attr[x].min, uniqueItem.attr[x].max)
    item:setAttributeValue(x, uniqueItem.attr[x].id.."|".. value.."|".. 0)
  end

  return true, "Successfully rerolled all modifiers values"
end
--[[
function spellBound(item, player, orb)
    if blockedIds[item:getId()] then
        return false, "This item cannot be modified."
    end

    local spellbound = item:getCustomAttribute("spellUnique")
    if not spellbound then
        return false, "This item don't have any spellbound modifiers."
    end
    if spellbound then
      orb:setCustomAttribute("spellUnique", true)
      orb:setCustomAttribute("spellUniqueOrb", true)
      orb:setCustomAttribute("spellUniqueId", item:getCustomAttribute("spellUniqueId"))
    end

    return true, "Spell stored in orb.", 0
end
--]]

function spellBound(item, player, orb)
    if blockedIds[item:getId()] then
        return false, "This item cannot be modified."
    end
    local spellbound = item:getCustomAttribute("spellUnique")
  --  if not spellbound then
  --      return false, "This item don't have any spellbound modifiers."
  --  end
    -- ZAPIS SPELLA Z UNIQUE DO ORBA Item musi byc UNIQUE a cel nie ma dodanego specialnego bounda usuwane uniqat DODAJ SHIELDY
    if spellbound and not orb:getCustomAttribute("spellUniqueOrb") then
        orb:setCustomAttribute("spellUniqueOrb", true)
        orb:setCustomAttribute("spellUniqueId", item:getCustomAttribute("spellUniqueId"))
        item:remove()
        return false, "Spellbound essence stored in Seal of Spellbound!", 0
    end

    -- NAKŁADANIE SPELLA Z ORBA NA ZWYKŁĄ BROŃ
  --  local slot = ItemType(item:getId()):getSlotPosition()
  --  if slot ~= 1072 then
  --      return false, "Spellbound can only be added to two-handed weapons."
  --  end
    local itemType = formatItemType(item:getType(), item)
    if itemType < 1 or itemType > 8 then
        return false, "You can use this Seal of Spellbound only on weapons."
    end
    if orb:getCustomAttribute("spellUniqueOrb") and not item:getCustomAttribute("spellUniqueOrb") and not item:getUnique() then
        local spellId = orb:getCustomAttribute("spellUniqueId")
        if not spellId then
            return false, "Seal of Spellbound does not contain a spell."
        end
        if item:getCustomAttribute("spellUniqueOrb") then
            return false, "Item contain a spellbound."
        end

        local slotNew = item:getImplictLastSlot()
        item:setImplictSlots(slotNew+1)
        item:setImplictValue(slotNew+1, spellId .. "|1|0")
        item:setCustomAttribute("spellUniqueOrb", true)

        return true, "Spellbound essence added to "..item:getName().."."
      else
        return false, "This item doesn't have Spellbound or already has spellbound essence added."
    end

    return false, "This item doesn't have any spellbound modifiers."
end

function rerollModifiersDungValues(item)
  if blockedIds[item:getId()] then
    return false, "This item cannot be modified."
  end
  local bonuses = item:getDungeonModifiers()
  if not bonuses then
    return false, "This item don't have any modifiers."
  end

  for i = 1, #bonuses do
    local attr = bonuses[i][1]
    local tier = bonuses[i][3]
    local value = generateRandomDungeonAttributeValue(attr, tier)
    item:setDungeonModifier(bonuses[i][4], attr.."|"..value.."|"..tier)
  end

  return true, "Successfully rerolled all modifiers values"
end

function transfromToOtherItem(item, reroll)
  local itemType = item:getType()
  local itemLevel = item:getItemLevel()
  local formatedItemType = formatItemType(itemType, item)

  -- local uniqueChance = 65 + (65 * itemLevel / 100)
  -- if math.random(1, 1) == 1 then
  --   local unique_id = tryToGenerateUniqueItem(nil, itemLevel, formatedItemType, true)
  --   if unique_id then
  --     return true, "unique" .. unique_id
  --   end
  -- end

  local base_item = findBaseItem(nil, itemLevel, formatedItemType)
  if base_item then
    item:transform(base_item[2])

    local implicts = item:getImplictBonusAttributes()
    if implicts then
      for i = 1, #implicts do
        item:setImplictValue(implicts[i][5])
      end 
    end

    local implictsSlots = #base_item[3]
    item:setImplictSlots(implictsSlots)
    if base_item[4] == 1 then
      item:setCustomAttribute("no_stat", true)
    end

    item:setAttribute(ITEM_ATTRIBUTE_NAME, base_item[1])

    for x = 1, implictsSlots do
      local value = generateRandomImplictBaseValue(item, base_item[3][x][2], itemLevel+1)
      local bonus_range = IMPLICT_BONUS[base_item[3][x][1]] or {0, 0}
      local min = bonus_range[1]
      local max = bonus_range[2]
      value = value + math.random(min, max)
      local slot = ItemType(item:getId()):getSlotPosition()
      if (slot == 1072) then
        value = math.floor(value * TWO_HANDED_MULTIPLIER)
      end
      item:setImplictValue(x, base_item[3][x][1].."|".. value .."|".. itemLevel+1)
    end

    item:removeCustomAttribute("unique")
    if reroll then
      item:rollAttribute()
      item:setQuality(math.random(-20, 40))
    end

    return true, "Item transformed to ".. base_item[1] .. "."
  end

  return true, "Nothing happend."
end

function addRandomImplict(item)
  local newImplict

  while(newImplict == nil) do
    local id = math.random(1, #US_ENCHANTMENTS)
    local attr = US_ENCHANTMENTS[id]
    if attr and attr.minLevel ~= 2000 then
      newImplict = id
    end
  end

  local tier = getTierAttribute(item, 0.5)
  local value = generateRandomAttributeValue(newImplict, tier, item)
  local slot = item:getImplictLastSlot()

  item:setImplictSlots(slot+1)
  item:setImplictValue(slot+1, newImplict.."|".. value .."|".. tier .."|".. 1)

  return true, "A new implict has been added."
end

function rerollUniqueValues(item)
  local uniqueItem = US_UNIQUES[item:getUnique()]
  if not uniqueItem then
    return false, "Something went wrong with this item."
  end

  rerollImplictsUniqueValues(item)
  rerollModifiersUniqueValues(item)

  return true, "Rerolled implicts and modifiers with random multiplier for each mod."
end

function transformToOtherKey(item)
  local itemLevel = item:getItemLevel() or 0
  if not SERVER_DUNGEON_KEYS[itemLevel] then
    return true, "Nothing Happend."
  end

  local randomKey = SERVER_DUNGEON_KEYS[itemLevel][math.random(1, #SERVER_DUNGEON_KEYS[itemLevel])]
  item:transform(randomKey)

  return true, "Key transformed to " .. item:getName() .. "."
end