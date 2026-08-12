local specialSkills = {
  [SPECIALSKILL_CRITICALHITCHANCE] = "cc",
  [SPECIALSKILL_CRITICALHITAMOUNT] = "ca",
  [SPECIALSKILL_LIFELEECHCHANCE] = "lc",
  [SPECIALSKILL_LIFELEECHAMOUNT] = "la",
  [SPECIALSKILL_MANALEECHCHANCE] = "mc",
  [SPECIALSKILL_MANALEECHAMOUNT] = "ma"
}

local skills = {
  [SKILL_FIST] = "fist",
  [SKILL_MELEE] = "melee",
  [SKILL_DISTANCE] = "dist",
  [SKILL_SHIELD] = "shield",
  [SKILL_FISHING] = "fish"
}

local stats = {
  [STAT_MAGICPOINTS] = "mag",
  [STAT_MAXHITPOINTS] = "maxhp",
  [STAT_MAXMANAPOINTS] = "maxmp"
}

local statsPercent = {
  [STAT_MAXHITPOINTS] = "maxhp_p",
  [STAT_MAXMANAPOINTS] = "maxmp_p"
}

local combatTypeNames = {
  [COMBAT_PHYSICALDAMAGE] = "Physical",
  [COMBAT_ENERGYDAMAGE] = "Energy",
  [COMBAT_EARTHDAMAGE] = "Earth",
  [COMBAT_FIREDAMAGE] = "Fire",
  [COMBAT_LIFEDRAIN] = "Lifedrain",
  [COMBAT_MANADRAIN] = "Manadrain",
  [COMBAT_HEALING] = "Healing",
  [COMBAT_DROWNDAMAGE] = "Drown",
  [COMBAT_ICEDAMAGE] = "Ice",
  [COMBAT_HOLYDAMAGE] = "Holy",
  [COMBAT_DEATHDAMAGE] = "Death"
}

local combatShortNames = {
  [COMBAT_PHYSICALDAMAGE] = "a_phys",
  [COMBAT_ENERGYDAMAGE] = "a_ene",
  [COMBAT_EARTHDAMAGE] = "a_earth",
  [COMBAT_FIREDAMAGE] = "a_fire",
  [COMBAT_LIFEDRAIN] = "a_ldrain",
  [COMBAT_MANADRAIN] = "a_mdrain",
  [COMBAT_HEALING] = "a_heal",
  [COMBAT_DROWNDAMAGE] = "a_drown",
  [COMBAT_ICEDAMAGE] = "a_ice",
  [COMBAT_HOLYDAMAGE] = "a_holy",
  [COMBAT_DEATHDAMAGE] = "a_death"
}

function onExtendedOpcode(player, opcode, buffer)
  if opcode == ExtendedOPCodes.CODE_TOOLTIP then
    local status, data =
        pcall(
          function()
            return json.decode(buffer)
          end
        )
    if not status or not data then
      return
    end

    local slot = nil
    local target = nil
    local item = nil
    local slot = nil

    if data[1] == "link" then
      if type(data[2]) == "string" then
        local item = Game.createItem(data[2], 1, nil, false)
        if item then
          builtdItemTooltip(item, player)
          item:remove()
        end
        return
      end
      local item = Game.getRealUniqueItem(data[2])
      if item then
        if not checkAndSendSpellItem(item, player, false) then
          builtdItemTooltip(item, player)
        end
      end
      return
    elseif data[1] == "sid" then
      local item = Game.createItem(data[2], 1, nil, false)
      if item then
        builtdItemTooltip(item, player)
        item:remove()
      end
      return
    elseif data[1] == "market" then
      item = Game.getMarketBox():getItemByMarketId(data[2])
    elseif data[1] == "trade" then
      if data[3] == "self" then
        target = player
      else
        local partner = Player(player:getStorageValue(87363))
        if not partner then
          return true
        end
        target = partner
      end
      if not target then
        return
      end

      local storage = target:getTradeStorage()
      local items = storage:getItems()
      for i = 1, #items do
        if items[i]:getCustomAttribute("tradeId") == data[2] then
          item = items[i]
          break
        end
      end
    else
      local pos = Position(data[1], data[2], data[3], data[4])
      if data[5] == nil then
        item = player:getItem(pos)
      else
        if pos then
          local tile = Tile(pos)
          if tile then
            item = tile:getTopDownItem()
          end
        end
      end
    end

    if item then
      if not checkAndSendSpellItem(item, player, true) then
        builtdItemTooltip(item, player, false, slot, target)
      end
    end
  end
end

function checkAndSendSpellItem(item, player, floor)
  local name = item:getSpellName()
  local SPELL = SPELLS[name]
  if SPELL then
    local parent = item:getParent()
    local holder = player
    if parent:isPlayer() then
      holder = parent
    end

    local infoToSend = SPELL.getInfo(holder, item)
    infoToSend.name = name
    infoToSend.itemid = item:getType():getClientId()
    infoToSend.floor = floor
    player:sendExtendedOpcode(ExtendedOPCodes.CODE_SPELLTOOLTIP, json.encode(infoToSend))
    return true
  end
  return false
end

function builtdItemTooltip(item, player, table, slot, target)
  if item then
    local uid = item:getRealUID()
    local itemType = item:getType()
    local item_data = {
      uid = uid,
      clientId = itemType:getClientId(),
      serverId = item:getId(),
    }
    if item:getName() == "" then
      item_data.itemName = "UNKNOW ITEM"
      item_data.desc = "Please add this item to items.xml\n ClientID: " ..
      itemType:getClientId() .. "\nServerID: " .. itemType:getId()
    else
      item_data.itemName = item:getName()
    end
    item_data.itemArticle = item:getAttribute(ITEM_ATTRIBUTE_ARTICLE)

    if item:isQuality() then
      item_data.quality = item:isQuality()
    end

    item_data.tier = item:getTier()

 


    local itemType = ItemType(item:getId())



    if item:isFlask() then
      item_data.flask = item:getFlask()
    end


    if slot then
      if target then
        item_data.vc = target:getStorageValue(727691 + slot)
        item_data.price = target:getStorageValue(727591 + slot)
      end
    end
    if item:getId() == 0 then return end

    if itemType:getDescription():len() > 0 then
      item_data.desc = itemType:getDescription()
    end

    if item:getType():isUpgradable() or item:getType():canHaveItemLevel() then


      local itemLevelTotal = item:getItemLevel()
      name_config_vocation = {
        [1] = "Knights and Paladins",
        [2] = "Druids and Sorcerers",
        [3] = "Archers and Shadows",
        [4] = "All"
      }
      name_config_dungoen = {
        [1] = "Dungeon Normal",
        [2] = "Dungeon Hard",
        [3] = "Dungeon Expert",
        [4] = "Dungeon Master",
        [5] = "Dungeon Torment",
        [6] = "Dungeon Hell",
        [7] = "RAID Normal",
        [8] = "RAID Hard",
        [9] = "RAID Expert",
        [10] = "RAID Master",
        [11] = "RAID Torment",
        [12] = "RAID Hell"
      }
      local namess = nil
      if item:isVocationReq() then
        namess = name_config_vocation[item:getVocationReq()]
      end

      local itemReductionLevel = 0
      local slotsMax = item:getMaxAttributes()
      local totalAtrBonus = 0
      for i = 1, slotsMax do
        local enchant = item:getBonusAttribute(i)
        if enchant and enchant[1] == 65 then
          itemReductionLevel = enchant[2]
        end
      end
      local skill_name = 0
      local skill_level = 0
      local skill_all = 0
      if item:getCustomAttribute("spellid") then
        skill_name = GLOBAL_SPELL_NUMBER[item:getCustomAttribute("spellid")]
        skill_level = item:getCustomAttribute("spelllevel")
      end

      if item:getCustomAttribute("spelllevelall") then
        skill_all = item:getCustomAttribute("spelllevelall")
      end
      local itemReq = item:getLevelReq() - itemReductionLevel
      local enchValue = ENCHANTMENT_ORB_ITEMS[item:getArenaScalingLevel()]
      item_data.itemLevel = {
        itemLevel = item:getItemLevel(),
        itemReqArmor = namess,
        itemDungeon = dungDifficulty,
        itemReq = itemReq,
        skill_name = skill_name,
        skill_level = skill_level,
        skill_all = skill_all,
        itemPoziom = itemLevelTotal,
        itemClass = item:getClassItem(),
        itemClassLevel = item:getFusionLevel(),
        itemEnchantmentLevel = item:getArenaScalingLevel(),
        itemEnchantmentValue = enchValue,
      }
    else
      item_data.itemLevel = {
        itemLevel = 0,
        itemReqArmor = 0,

        itemReq = 0,
        skill_name = 0,
        skill_level = 0,
        skill_all = 0,
        itemPoziom = 0,
        itemClass = 0,
        itemClassLevel = 0,
        itemEnchantmentLevel = 0,
        itemEnchantmentValue = 0,
      }
    end

    local implicit = {}

    if itemType:getElementType() ~= COMBAT_NONE and itemType:getElementType() ~= nil then
      implicit.eleDmg = "Attack +" .. itemType:getElementDamage() .. " " .. combatTypeNames[itemType:getElementType()]
    end

    local allprot = itemType:getAbsorbPercent(0)
    if allprot == 0 then
      local eleprot = itemType:getAbsorbPercent(COMBAT_ENERGYDAMAGE)
      if eleprot ~= 0 then
        for i = 0, COMBAT_COUNT - 1 do
          local combatType = bit.lshift(1, i)
          if not isInArray({ COMBAT_UNDEFINEDDAMAGE, COMBAT_PHYSICALDAMAGE, COMBAT_LIFEDRAIN, COMBAT_MANADRAIN,
                COMBAT_HEALING, COMBAT_DROWNDAMAGE }, combatType) then
            if eleprot ~= itemType:getAbsorbPercent(i) then
              eleprot = 0
              break
            end
          end
        end
      end
      if eleprot == 0 then
        for i = 0, COMBAT_COUNT - 1 do
          if itemType:getAbsorbPercent(i) ~= 0 then
            local combatType = bit.lshift(1, i)
            if combatType ~= COMBAT_UNDEFINEDDAMAGE then
              implicit[combatShortNames[combatType]] = itemType:getAbsorbPercent(i)
            end
          end
        end
      else
        implicit.a_ele = eleprot
      end
    else
      implicit.a_all = allprot
    end

    for key, value in pairs(specialSkills) do
      local s = itemType:getSpecialSkill(key)
      if s and s >= 1 then
        implicit[value] = s
      end
    end

    for key, value in pairs(skills) do
      local s = itemType:getSkill(key)
      if s and s >= 1 then
        implicit[value] = s
      end
    end

    for key, value in pairs(stats) do
      local s = itemType:getStat(key)
      if s and s >= 1 then
        implicit[value] = s
      end
    end

    for key, value in pairs(statsPercent) do
      local s = itemType:getStatPercent(key)
      if s and s >= 1 then
        implicit[value] = s - 100
      end
    end

    local healthGain = itemType:getHealthGain()
    if healthGain and healthGain > 0 then
      implicit.hpgain = healthGain
    end

    local healthTicks = itemType:getHealthTicks()
    if healthTicks and healthTicks > 0 then
      implicit.hpticks = healthTicks
    end

    local manaGain = itemType:getManaGain()
    if manaGain and manaGain > 0 then
      implicit.mpgain = manaGain
    end

    local manaTicks = itemType:getManaTicks()
    if manaTicks and manaTicks > 0 then
      implicit.mpticks = manaTicks
    end

    local speed = itemType:getSpeed()
    if speed and speed > 0 then
      implicit.speed = speed / 2
    end

    if item:isContainer() then
      implicit.cap = "Capacity " .. item:getCapacity()
    end

    if next(implicit) ~= nil then
      item_data.imp = implicit
    end
    local rarityFix = item:getRarityId()
    if item:getCustomAttribute("Exa") then
      rarityFix = 6
    end
    item_data.rarityId = rarityFix
    if item:getType():isUpgradable() then
      local ancientValues = 0
      if item:isAncient() then
        ancientValues = ancientValues + ANCIENT_ATTRIBUTES[1]
      elseif item:isPrimal_Ancient() then
        ancientValues = ancientValues + ANCIENT_ATTRIBUTES[2]
      elseif item:isEternal() then
        ancientValues = ancientValues + ANCIENT_ATTRIBUTES[3]
      end
      local dungeonValues = 0
      if item:isDungeonItem() then
        dungeonValues = dungeonValues + DUNGEON_ITEMS_ATTRIBUTES_INCREASED[item:getDungeonItem()]
      end
      local rarityBonus = 0 -- RARITY_ATTRIBUTES_INCREASED[item:getRarityId()]
      local tierBonus = item:getTier() * 10
      local craftB = 0 -- math.ceil(item:getCraftBonus() / 2)
      local orbsUpgrade = 0
      if item:isArenaScalingAttributes() then
          orbsUpgrade = orbsUpgrade + (item:getArenaScalingAttributes() * 10)
      end
      local nonTier = 0

      local totalAttributesOK = 0 
      item_data.totalAttributes = {
        rarity = rarityBonus,
        forgePotencial = item:getForgePotencial(),
        dungeon = dungeonValues,
        ancient = ancientValues,
        tier = tierBonus,
        craftBonus = craftB,
        endless = 0,
        total = totalAttributesOK,
        implicitTotal = (item:getImplicit() * 100),
        nonTier = nonTier,
        orbsUpgrade = orbsUpgrade,
        itemEnchantmentAttributes = item:getArenaScalingAttributes(),
        attack = item:getCustomAttribute("base_attack"),
        armor = item:getCustomAttribute("base_armor"),
        defense = item:getCustomAttribute("base_defense"),
        basic_melee = item:getCustomAttribute("basic_melee"),
        basic_magic = item:getCustomAttribute("basic_magic"),
        basic_distance = item:getCustomAttribute("basic_distance"),
        basic_health = item:getCustomAttribute("basic_health"),
        basic_mana = item:getCustomAttribute("basic_mana"),
        basic_cc = item:getCustomAttribute("basic_cc"),
        basic_ca = item:getCustomAttribute("basic_ca"),
        basic_dodge = item:getCustomAttribute("basic_dodge"),
        basic_avoid = item:getCustomAttribute("basic_avoid"),
        basic_cooldown = item:getCustomAttribute("basic_cooldown"),
        basic_endurance = item:getCustomAttribute("basic_endurance"),
        basic_block = item:getCustomAttribute("basic_block"),
        basic_vitality = item:getCustomAttribute("basic_vitality"),
      }
      if item:isAncient() then
        item_data.ancientName = "Ancient"
      end
      if item:isPrimal_Ancient() then
        item_data.primalancientName = "Primal Ancient"
      end
      if item:isEternal() then
        item_data.eternalName = "Eternal"
      end
      if item:isUnidentified() then
        item_data.unidentified = true
      else
        item_data.uLevel = item:getUpgradeLevel()
        if item:isMirrored() then
          item_data.mirrored = item:isMirrored()
        end
        if item:isUnique() then
          item_data.uniqueName = item:getUniqueName()
        end
        ---Attybuty
        item_data.implict = {}
        item_data.maximplict = item:getImplictSlots()
        local implictSlots = item:getImplictSlots()
        if implictSlots then
          for i = implictSlots, 1, -1 do
            local enchant = item:getImplictBonusAttribute(i)
            if enchant then
              local attr = US_ENCHANTMENTS[enchant[1]]
              item_data.implict[i] = attr.format(enchant[2])
            else
              item_data.implict[i] = "Empty Slot"
            end
          end
        end
        item_data.implictDesc = {}
        for i = implictSlots, 1, -1 do
          local imDesc = item:getImplictBonusAttribute(i)
          if imDesc then
            local attrImp = US_ENCHANTMENTS[imDesc[1]]
            item_data.implictDesc[i] = attrImp.desc
          else
            item_data.implictDesc[i] = ""
          end
        end

        item_data.maxAttr = item:getMaxAttributes()

        local maxSlotss = item:getMaxAttributes()
        if item:isCorrupted() then
          maxSlotss = maxSlotss + 1
        end
        item_data.attr = {}
        item_data.attrTier = {}
        item_data.attrExalted = {}
        for i = maxSlotss, 1, -1 do
          local enchant = item:getBonusAttribute(i)
          if enchant then
            local attr = US_ENCHANTMENTS[enchant[1]]
            item_data.attr[i] = attr.format(enchant[2])
            item_data.attrTier[i] = enchant[3]
            item_data.attrExalted[i] = enchant[4]
          else
            item_data.attr[i] = "Empty Slot"
            item_data.attrTier[i] = 0
            item_data.attrExalted[i] = 0
          end
        end
        item_data.attr1 = {}
        for i = maxSlotss, 1, -1 do
          local enchant1 = item:getBonusAttribute(i)
          if enchant1 then
            local unique = item:getUnique()
            if unique then
              HPMPmin = math.ceil(US_UNIQUES[unique].attr[i].min)
              HPMPmax = math.ceil(US_UNIQUES[unique].attr[i].max)
            else
              HPMPmin = math.ceil(REDUCTION_ATTR_VALUES[enchant1[1]][enchant1[3]][1])
              HPMPmax = math.ceil(REDUCTION_ATTR_VALUES[enchant1[1]][enchant1[3]][2])
            end
            local slot = ItemType(item:getId()):getSlotPosition()
            if (slot == 1072) then
              HPMPmin = math.ceil(HPMPmin * 2)
              HPMPmax = math.ceil(HPMPmax * 2)
            end
            item_data.attr1[i] = { jeden = HPMPmin, dwa = HPMPmax }
          else
            item_data.attr1[i] = "0"
          end
        end
        item_data.attr2 = {}
        for i = maxSlotss, 1, -1 do
          local enchant2 = item:getBonusAttribute(i)
          if enchant2 then
            local attr2 = US_ENCHANTMENTS[enchant2[1]]
            item_data.attr2[i] = attr2.desc
          else
            item_data.attr2[i] = ""
          end
        end


        ----Atrybuty
      end
    end
    item_data.stackable = itemType:isStackable()
    item_data.itemType = formatItemType(itemType, item)
    if itemType:getArmor() > 0 then
      if item:getAttribute(ITEM_ATTRIBUTE_ARMOR) > 0 then
        item_data.armor = item:getAttribute(ITEM_ATTRIBUTE_ARMOR)
      else
        item_data.armor = itemType:getArmor()
      end
    elseif itemType:getShootRange() > 1 then
      if item:getAttribute(ITEM_ATTRIBUTE_ATTACK) > 0 then
        item_data.attack = item:getAttribute(ITEM_ATTRIBUTE_ATTACK)
      else
        item_data.attack = itemType:getAttack()
      end
      if item:getAttribute(ITEM_ATTRIBUTE_HITCHANCE) > 0 then
        item_data.hitChance = item:getAttribute(ITEM_ATTRIBUTE_HITCHANCE)
      else
        item_data.hitChance = itemType:getHitChance()
      end
      item_data.shootRange = itemType:getShootRange()
    elseif itemType:getAttack() > 0 then
      if item:getAttribute(ITEM_ATTRIBUTE_ATTACK) > 0 then
        item_data.attack = item:getAttribute(ITEM_ATTRIBUTE_ATTACK)
      else
        item_data.attack = itemType:getAttack()
      end
      if item:getAttribute(ITEM_ATTRIBUTE_DEFENSE) > 0 then
        item_data.defense = item:getAttribute(ITEM_ATTRIBUTE_DEFENSE)
      else
        item_data.defense = itemType:getDefense()
      end
      if item:getAttribute(ITEM_ATTRIBUTE_EXTRADEFENSE) > 0 then
        item_data.extraDefense = item:getAttribute(ITEM_ATTRIBUTE_EXTRADEFENSE)
      else
        item_data.extraDefense = itemType:getExtraDefense()
      end
    elseif itemType:getDefense() > 0 then
      if item:getAttribute(ITEM_ATTRIBUTE_DEFENSE) > 0 then
        item_data.defense = item:getAttribute(ITEM_ATTRIBUTE_DEFENSE)
      else
        item_data.defense = itemType:getDefense()
      end
      if item:getAttribute(ITEM_ATTRIBUTE_EXTRADEFENSE) > 0 then
        item_data.extraDefense = item:getAttribute(ITEM_ATTRIBUTE_EXTRADEFENSE)
      else
        item_data.extraDefense = itemType:getExtraDefense()
      end
    end

    item_data.weight = item:getWeight()
    if table then
      return item_data
    else
      player:sendExtendedOpcode(ExtendedOPCodes.CODE_TOOLTIP, json.encode({ action = "new", data = item_data }))
    end
  end
end

function buildItemTypeTooltip(itemType, count)
  if itemType then
    local item_data = {
      id = itemType:getClientId(),
      count = count
    }

    if itemType:getDescription():len() > 0 then
      item_data.desc = itemType:getDescription()
    end

    local implicit = {}

    if itemType:getElementType() ~= COMBAT_NONE then
      implicit.eleDmg = "Attack +" .. itemType:getElementDamage() .. " " .. combatTypeNames[itemType:getElementType()]
    end

    local allprot = itemType:getAbsorbPercent(0)
    if allprot == 0 then
      local eleprot = itemType:getAbsorbPercent(COMBAT_ENERGYDAMAGE)
      if eleprot ~= 0 then
        for i = 0, COMBAT_COUNT - 1 do
          local combatType = bit.lshift(1, i)
          if not isInArray({ COMBAT_UNDEFINEDDAMAGE, COMBAT_PHYSICALDAMAGE, COMBAT_LIFEDRAIN, COMBAT_MANADRAIN,
                COMBAT_HEALING, COMBAT_DROWNDAMAGE }, combatType) then
            if eleprot ~= itemType:getAbsorbPercent(i) then
              eleprot = 0
              break
            end
          end
        end
      end
      if eleprot == 0 then
        for i = 0, COMBAT_COUNT - 1 do
          if itemType:getAbsorbPercent(i) ~= 0 then
            local combatType = bit.lshift(1, i)
            if combatType ~= COMBAT_UNDEFINEDDAMAGE then
              implicit[combatShortNames[combatType]] = itemType:getAbsorbPercent(i)
            end
          end
        end
      else
        implicit.a_ele = eleprot
      end
    else
      implicit.a_all = allprot
    end

    for key, value in pairs(specialSkills) do
      local s = itemType:getSpecialSkill(key)
      if s and s >= 1 then
        implicit[value] = s
      end
    end

    for key, value in pairs(skills) do
      local s = itemType:getSkill(key)
      if s and s >= 1 then
        implicit[value] = s
      end
    end

    for key, value in pairs(stats) do
      local s = itemType:getStat(key)
      if s and s >= 1 then
        implicit[value] = s
      end
    end

    for key, value in pairs(statsPercent) do
      local s = itemType:getStatPercent(key)
      if s and s >= 1 then
        implicit[value] = s - 100
      end
    end

    local healthGain = itemType:getHealthGain()
    if healthGain and healthGain > 0 then
      implicit.hpgain = healthGain
    end

    local healthTicks = itemType:getHealthTicks()
    if healthTicks and healthTicks > 0 then
      implicit.hpticks = healthTicks
    end

    local manaGain = itemType:getManaGain()
    if manaGain and manaGain > 0 then
      implicit.mpgain = manaGain
    end

    local manaTicks = itemType:getManaTicks()
    if manaTicks and manaTicks > 0 then
      implicit.mpticks = manaTicks
    end

    if itemType:getSpeed() >= 1 then
      implicit.speed = itemType:getSpeed() / 2
    end

    if itemType:isContainer() then
      implicit.cap = "Capacity " .. itemType:getCapacity()
    end

    if next(implicit) ~= nil then
      item_data.imp = implicit
    end

    item_data.itemType = formatItemType(itemType, item)
    if itemType:getArmor() > 0 then
      item_data.armor = itemType:getArmor()
    elseif itemType:getShootRange() > 1 then
      item_data.attack = itemType:getAttack()
      item_data.hitChance = itemType:getHitChance()
      item_data.shootRange = itemType:getShootRange()
    elseif itemType:getAttack() > 0 then
      item_data.attack = itemType:getAttack()
      item_data.defense = itemType:getDefense()
      item_data.extraDefense = itemType:getExtraDefense()
    elseif itemType:getDefense() > 0 then
      item_data.defense = itemType:getDefense()
      item_data.extraDefense = itemType:getExtraDefense()
    end

    item_data.weight = itemType:getWeight(item_data.count)
    return item_data
  end
  return nil
end

function formatItemType(itemType, item)
  local weaponType = itemType:getWeaponType()

  if weaponType ~= WEAPON_SHIELD then
    local slotPosition = itemType:getSlotPosition() - SLOTP_LEFT - SLOTP_RIGHT
    if slotPosition == 1024 and weaponType == WEAPON_SWORD then
      return "Two-Handed Sword"
    elseif slotPosition == 1024 and weaponType == WEAPON_CLUB then
      return "Two-Handed Club"
    elseif slotPosition == 1024 and weaponType == WEAPON_AXE then
      return "Two-Handed Axe"
    elseif slotPosition == 1024 and itemType:getName():find("Bow") and weaponType == WEAPON_DISTANCE then
      return "Two-Handed Bow"
    elseif slotPosition == 1024 and itemType:getName():find("Crossbow") and weaponType == WEAPON_DISTANCE then
      return "Two-Handed Crossbow"
    elseif slotPosition == 1024 and itemType:getName():find("AoE") and weaponType == WEAPON_WAND then
      return "Two-Handed AoE Wand"
    elseif weaponType == WEAPON_SWORD then
      return "Sword"
    elseif weaponType == WEAPON_CLUB then
      return "Mace"
    elseif weaponType == WEAPON_AXE then
      return "Axe"
    elseif itemType:getName():find("knife") and weaponType == WEAPON_DISTANCE then
      return "Throwing Knife"
    elseif itemType:getName():find("Crossbow") and weaponType == WEAPON_DISTANCE then
      return "Crossbow"
    elseif itemType:getName():find("Bow") and weaponType == WEAPON_DISTANCE then
      return "Bow"
    elseif weaponType == WEAPON_DISTANCE then
      return "Distance"
    elseif itemType:getName():find("AoE") and weaponType == WEAPON_WAND then
      return "AoE Wand"
    elseif weaponType == WEAPON_WAND then
      return "Wand"
    elseif slotPosition == SLOTP_HEAD then
      return "Helmet"
    elseif slotPosition == SLOTP_NECKLACE then
      return "Necklace"
    elseif slotPosition == SLOTP_ARMOR then
      return "Armor"
    elseif slotPosition == SLOTP_LEGS then
      return "Legs"
    elseif slotPosition == SLOTP_FEET then
      return "Boots"
    elseif slotPosition == SLOTP_RING or slotPosition == SLOTP_RING2  then
      return "Ring"
    elseif slotPosition == SLOTP_GLOVES then
      return "Gloves"
    elseif itemType:isRune() then
      return "Rune"
    elseif itemType:isContainer() then
      return "Container"
    elseif itemType:isFluidContainer() then
      return "Potion"
    elseif itemType:isUseable() then
      return "Usable"
    end
  else
    return "Shield"
  end
  if itemType and itemType:getName():find("potion") then
    return "Potion"
  elseif itemType and itemType:getName():find("Flask") then
    return "Flask"
  end
  return "None"
end
