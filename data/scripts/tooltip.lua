local LoginEvent = CreatureEvent("TooltipLoginEvent")
function LoginEvent.onLogin(player)
  player:registerEvent("TooltipExtendedEvent")
  return true
end

local TYPE_TO_SLOT = {
  [1] = CONST_SLOT_LEFT,
  [2] = CONST_SLOT_LEFT,
  [3] = CONST_SLOT_LEFT,
  [4] = CONST_SLOT_LEFT,
  [5] = CONST_SLOT_LEFT,
  [6] = CONST_SLOT_LEFT,
  [7] = CONST_SLOT_LEFT,
  [8] = CONST_SLOT_LEFT,
  [9] = CONST_SLOT_HEAD,
  [10] = CONST_SLOT_NECKLACE,
  [11] = CONST_SLOT_ARMOR,
  [12] = CONST_SLOT_LEGS,
  [13] = CONST_SLOT_FEET,
  [14] = CONST_SLOT_RING,
  [15] = CONST_SLOT_GLOVES,
  [16] = CONST_SLOT_RIGHT,
  [17] = CONST_SLOT_POTION1,
  [18] = CONST_SLOT_SPELL1,
  [19] = CONST_SLOT_SUPPORT1,
  [20] = CONST_SLOT_BACKPACK,
}

local MULTIPLE_SLOTS = {
  [CONST_SLOT_LEFT] = CONST_SLOT_RIGHT,
  [CONST_SLOT_RIGHT] = CONST_SLOT_LEFT,
  [CONST_SLOT_RING] = CONST_SLOT_RING2,
}

local ExtendedEvent = CreatureEvent("TooltipExtendedEvent")
function ExtendedEvent.onExtendedOpcode(player, opcode, buffer)
  local status, data = pcall(function()
    return json.decode(buffer)
  end)

  if not status then
    return false
  end

  if opcode == 106 then
    local item = nil
    local dataToSend = {}
    if data[1] == "l" then
      local item = nil
      if not data[2][1] or data[2][1] == 0 then
        local corpse = Game.getRealUniqueItem(data[3])
        if corpse then
          item = corpse:getItemById(data[2][2])
        end
      else
        item = Game.getRealUniqueItem(data[2][1])
      end

      if item then
        local parent = item:getParent()
        if parent and parent:isItem() and parent:getName():lower():find("loot bag") then
          local backpack = player:getSlotItem(CONST_SLOT_BACKPACK)
          if not backpack then
            if data[2][1] == 0 then
              sendLootedItem(player, 0, data[3], 1, data[2][2])
            else 
              sendLootedItem(player, item:getRealUID(), data[3], 1)
            end
            player:sendTooltipMessage("You don't have a backpack.")
            return true
          end

          if item:moveTo(backpack) then
            if data[2][1] == 0 then
              sendLootedItem(player, 0, data[3], nil, data[2][2])
            else 
              sendLootedItem(player, item:getRealUID(), data[3])
            end
          else
            if data[2][1] == 0 then
              sendLootedItem(player, 0, data[3], 1, data[2][2])
            else 
              sendLootedItem(player, item:getRealUID(), data[3], 1)
            end

            player:sendTooltipMessage("You don't have enough space in your backpack.")
          end
        end
      end
    elseif data[1] == "u" then
      item = Game.getRealUniqueItem(data[2])
      if item then
        if not player:sendSpellTooltip(item) then
          dataToSend[1] = getItemTooltipData(item, false, player)

          if item:getParent() ~= player then
            local slot = TYPE_TO_SLOT[dataToSend[1].t]
            if slot then
              local item2 = player:getSlotItem(slot)
              if item2 then
                dataToSend[2] = getItemTooltipData(item2, false, player)
              end

              local otherSlot = MULTIPLE_SLOTS[slot]
              if otherSlot then
                local item3 = player:getSlotItem(otherSlot)
                if item3 then
                  if not dataToSend[2] then
                    dataToSend[2] = getItemTooltipData(item3, false, player)
                  else
                    dataToSend[3] = getItemTooltipData(item3, false, player)
                  end
                end
              end
            end
          end

          player:sendExtendedOpcode(106, json.encode({1, dataToSend}))
        end
      end
      return true
    elseif data[1] == "p" then
      local tile = Tile(data[2])
      if tile then
        item = tile:getTopDownItem()
        if item then
          if not player:sendSpellTooltip(item, true) then
            dataToSend[1] = getItemTooltipData(item, true, player)

            local slot = TYPE_TO_SLOT[dataToSend[1].t]
            if slot then
              local item2 = player:getSlotItem(slot)
              if item2 then
                dataToSend[2] = getItemTooltipData(item2, false, player)
              end

              local otherSlot = MULTIPLE_SLOTS[slot]
              if otherSlot then
                local item3 = player:getSlotItem(otherSlot)
                if item3 then
                  if not dataToSend[2] then
                    dataToSend[2] = getItemTooltipData(item3, false, player)
                  else
                    dataToSend[3] = getItemTooltipData(item3, false, player)
                  end
                end
              end
            end

            player:sendExtendedOpcode(106, json.encode({1, dataToSend}))
          end
        end
      end
    elseif data[1] == "s" then
      item = Game.createItem(data[2], 1, nil, false)
      if item then
        item:setRealUID(0)
        if not player:sendSpellTooltip(item) then
          dataToSend[1] = getItemTooltipData(item, false, player)
          item:remove()

          local slot = TYPE_TO_SLOT[dataToSend[1].t]
          if slot then
            local item2 = player:getSlotItem(slot)
            if item2 then
              dataToSend[2] = getItemTooltipData(item2, false, player)
            end

            local otherSlot = MULTIPLE_SLOTS[slot]
            if otherSlot then
              local item3 = player:getSlotItem(otherSlot)
              if item3 then
                if not dataToSend[2] then
                  dataToSend[2] = getItemTooltipData(item3, false, player)
                else
                  dataToSend[3] = getItemTooltipData(item3, false, player)
                end
              end
            end
          end

          player:sendExtendedOpcode(106, json.encode({1, dataToSend}))
        end
      end

      return true
    elseif data[1] == "m" then
      dataToSend[1] = MARKET_ITEM_TOOLTIP[data[2]]
      if dataToSend[1].t == 19 then
        local supportExtraInfo = {}
        local index = 1
        local supportName = dataToSend[1].spm
        for i = CONST_SLOT_SPELL1, CONST_SLOT_SPELL4 do
          local spell = player:getSlotItem(i)
          local data = {}
          if spell then
            local spellConfig = SPELLS[spell:getSpellName()]
            local config = nil
            if spellConfig then
              config = spellConfig.getConfig()
            end
            if config then
              local correctSupport = not config.supports[supportName]
              if REVERSE_SUPPORT[supportName] then
                correctSupport = (config.supports[supportName] or false)
              end

              data = {spell:getType():getClientId(), correctSupport}
            end
          end
          supportExtraInfo[index] = data
          index = index + 1
        end
        dataToSend[1].sei = supportExtraInfo
      elseif dataToSend[1].t == 18 then
        local spellName = dataToSend[1].spm
        if player:sendMarketSpellTooltip(dataToSend[1], spellName) then
          return true
        end
      end

      if dataToSend[1] then
        local slot = TYPE_TO_SLOT[dataToSend[1].t]
        if slot then
          local item2 = player:getSlotItem(slot)
          if item2 then
            dataToSend[2] = getItemTooltipData(item2, false, player)
          end

          local otherSlot = MULTIPLE_SLOTS[slot]
          if otherSlot then
            local item3 = player:getSlotItem(otherSlot)
            if item3 then
              if not dataToSend[2] then
                dataToSend[2] = getItemTooltipData(item3, false, player)
              else
                dataToSend[3] = getItemTooltipData(item3, false, player)
              end
            end
          end
        end

        player:sendExtendedOpcode(106, json.encode({1, dataToSend}))
      end
    end
  end

  return true
end


local ADAPTIVE_UNIQUES = {
 [20] = true,
 [21] = true,
 [22] = true,
}

function getItemTooltipData(item, floor, player)
	local quality = 0
  if item:isQuality() ~= 0 then
    quality = item:isQuality()
  end
	local upgradeLevel = item:getUpgradeLevel()
	if upgradeLevel then
		quality = quality + calculateUpgradeValue(upgradeLevel)
	end
  local data = {}
  local itemType = item:getType()
  data.i = itemType:getClientId()
  data.n = item:getName()
  data.r = item:getCustomAttribute("Exa") and 6 or item:getRarityId()
  if data.r == 0 then
    data.r = item:getColor()
  end
  local spellLevel = item:getCustomAttribute("spelllevel")
  if spellLevel then
    data.sp = {
      spellLevel,
      GLOBAL_SPELL_NUMBER[item:getCustomAttribute("spellid")]
    }
  end

  data.vd = item:getCustomAttribute("void")
  if item:getCustomAttribute("spelllevelall") then
    data.spa = math.floor( item:getCustomAttribute("spelllevelall") * (1 + quality / 100) )
  end
  data.tier = item:getCustomAttribute("keytier")
  -- print(os.date("%Y-%m-%d %H:%M:%S", item:getCustomAttribute("time") or 0))
  data.id = item:getId()
  local iLvl = item:getItemLevel() or 0
  local keyTier = item:getCustomAttribute("keytier") or 1
  data.uq = item:getCustomAttribute("unique")
  if data.uq then
    data.r = 5
  end
  data.de = itemType:getDescription()
  data.u = item:getRealUID()
  data.fl = floor
  data.up = item:getUpgradeLevel()
  data.s = itemType:getSlotPosition() == 1072 and TWO_HANDED_MULTIPLIER or 1
  if item:isQuality() ~= 0 then
    data.qu = item:isQuality()
  end
  data.mi = item:isMirrored()
  if BOSS_DROPS_BY_ID[data.id] then
    data.wi = BOSS_DROPS_BY_ID[data.id].weight[data.r]
  end
  data.co = item:isCorrupted()
  data.t = formatItemType(itemType, item)
  data.a = item:getAttribute(ITEM_ATTRIBUTE_ARMOR) > 0 and item:getAttribute(ITEM_ATTRIBUTE_ARMOR) or itemType:getArmor()
  data.d = item:getAttribute(ITEM_ATTRIBUTE_DEFENSE) > 0 and item:getAttribute(ITEM_ATTRIBUTE_DEFENSE) or itemType:getDefense()
  if itemType:getAttack() > 0 then
    if item:getAttribute(ITEM_ATTRIBUTE_ATTACK) > 0 then
      data.at = item:getAttribute(ITEM_ATTRIBUTE_ATTACK)
    else
      data.at = itemType:getAttack()
    end
    if player then
      if data.uq and ADAPTIVE_UNIQUES[data.uq] then
        if colleftInfo[player:getId()].attributesItems[217] then -- unique Adaptive
          local levelCap = math.min(player:getLevel(), 100)
          data.at = data.at + levelCap * US_ENCHANTMENTS[217].subvalue
        end
      end
      if colleftInfo[player:getId()].attributesItems[276] and keyTier > 1 then -- Dungeon Rat
        iLvl = iLvl + colleftInfo[player:getId()].attributesItems[276].value
      end
    end
  else
    data.at = 0
  end
  if item:getCustomAttribute("relict") then
    iLvl = 0
  end
  data.l = iLvl
  data.im = item:getImplictBonusAttributes()
  data.m = item:getBonusAttributes()
  if data.t and data.t == 23 then
    data.dn = item:getDungeonModifiers()
  end
  data.sx = item:getCustomAttribute("exp") or nil
  data.sl = item:getCustomAttribute("level") or nil
  if player then
    local tier = player:getDungeonTier()
    if tier < 0 then
      tier = 0
    end
    data.mx = 100 + (tier * 1)
    if data.mx > 200 then
      data.mx = 200
    end
  end
  data.seal = item:getSealedModifiers() or nil
  if item:getCustomAttribute("spellUnique") then
    data.spellUnique = item:getCustomAttribute("spellUnique")
  end
  if item:getCustomAttribute("spellUniqueOrb") then
    data.spellUniqueOrb = item:getCustomAttribute("spellUniqueOrb")
  end
  if item:getCustomAttribute("spellUniqueId") then
   data.spellUniqueId = item:getCustomAttribute("spellUniqueId")
  end
  data.cs = item:getCrystalSlots()
  if data.cs and data.cs > 0 then
    data.cm = item:getBonusFromCrystals() or nil
  end

  data.gp = item:calculateItemCost()
  if data.gp == 0 then
    data.gp = nil
  end
  

  if data.t == 19 then
    local supportName = item:getSpellName()
    data.spm = supportName
    local manaCost = manaCost_support[supportName]
    if manaCost then
      local quality = 0
      if data.id == 37381 and data.qu then
        quality = data.qu
      end
      data.sc = manaCost[1] + ((data.sl or 1) * (1 + (quality/ 100))) * manaCost[2]
    end

    if player then
      local supportExtraInfo = {}
      local index = 1
      for i = CONST_SLOT_SPELL1, CONST_SLOT_SPELL4 do
        local spell = player:getSlotItem(i)
        local data = {}
        if spell then
          local spellConfig = SPELLS[spell:getSpellName()]
          local config = nil
          if spellConfig then
            config = spellConfig.getConfig()
          end
          if config then
            local correctSupport = not config.supports[supportName]
            if REVERSE_SUPPORT[supportName] then
              correctSupport = (config.supports[supportName] or false)
            end

            data = {spell:getType():getClientId(), correctSupport}
          end
        end
        supportExtraInfo[index] = data
        index = index + 1
      end
      data.sei = supportExtraInfo
    end

  elseif data.t == 18 then
    local spellName = item:getSpellName()
    data.spm = spellName
  end
  -- oho ale skrypt
  if data.t and data.t == 17 then
    local HP = item:getCustomAttribute("potionHealth") or 0
    local ES = 0
    local hpIncreased = 0
    local instaHeal = 0
    local healthBarrier = false
    if item:isQuality() ~= 0 then
      hpIncreased = item:isQuality()
    end
    if player then
      if colleftInfo[player:getId()].attributesItems[249] then -- energy shield regeneration percent per second
        HP = HP + colleftInfo[player:getId()].attributesItems[249].value
      end
      if colleftInfo[player:getId()].attributesItems[16] then -- Recovery Effectiveness
        hpIncreased = colleftInfo[player:getId()].attributesItems[16].value
      end
      if player:getCharacterStat(CHARSTAT_TWO) then -- Recovery Effectiveness character stat
        hpIncreased = hpIncreased + player:getCharacterStat(CHARSTAT_TWO)
      end
      local upgradeLevel = item:getUpgradeLevel() or 0
      if upgradeLevel > 0 then
       hpIncreased = hpIncreased + calculateUpgradeValue(upgradeLevel)
      end
      if hpIncreased > 0 then
        HP = math.ceil(HP + ((HP * hpIncreased) / 100))
      end
      if colleftInfo[player:getId()].attributesItems[95] then -- Health Recovery
        HP = HP + colleftInfo[player:getId()].attributesItems[95].value
      end
      if player:getBuff(BOSS_HEALING_REDUCTION) then
        HP = HP / 2
      end
      if colleftInfo[player:getId()].attributesItems[119] then -- Energy Shield Recovery
        player:addEnergyShield(colleftInfo[player:getId()].attributesItems[119].value)
        ES = ES + colleftInfo[player:getId()].attributesItems[119].value
      end
      if colleftInfo[player:getId()].attributesItems[123] then -- Quick Heal
        instaHeal = HP * (colleftInfo[player:getId()].attributesItems[123].value / 100)
        HP = HP - instaHeal
      end
      if colleftInfo[player:getId()].attributesItems[116] then -- Health Barrier
        healthBarrier = true
        HP = HP * (1 + (colleftInfo[player:getId()].attributesItems[116].value / 100))
			end
    end
    if healthBarrier then
      data.ph = 0
      data.phi = instaHeal
      data.pes = HP
    else
      data.ph = HP
      data.phi = instaHeal
      data.pes = ES
    end
  end
  return data
end

LoginEvent:type("login")
LoginEvent:register()
ExtendedEvent:type("extendedopcode")
ExtendedEvent:register()

if configManager.getNumber(configKeys.INSTANCE_TYPE) == 0 then
  loadMarketTooltips()
	return
end