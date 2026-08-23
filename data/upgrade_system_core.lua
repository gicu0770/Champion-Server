dofile("data/upgrade_system_const.lua")

US_CONDITIONS = {}
US_BUFFS = {}

local US_SUBID = {}

function Player:addPlayerModifiersFromItem(item, slot)
  if not self or not item then
    return
  end

  local uuid = item:getRealUID()
  if item:getId() == 38037 then
    local ringSlot = slot == CONST_SLOT_RING and CONST_SLOT_RING2 or CONST_SLOT_RING
    local ring = self:getSlotItem(ringSlot)
    if ring then
      item = ring
    end
  end

  local slotPos = item:getType():getSlotPosition()
  local newBonuses = item:getBonusAttributes() or {}
  local implictBonuses = item:getImplictBonusAttributes()
  local crystalBonuses = item:getBonusFromCrystals()
  if implictBonuses then
    for i = 1, #implictBonuses do
      table.insert( newBonuses, implictBonuses[i] )
    end
  end

  if crystalBonuses then
    for i = 1, #crystalBonuses do
      crystalBonuses[i].ownQuality = true
      table.insert( newBonuses, crystalBonuses[i] )
    end
  end

  if not newBonuses then
    return
  end

  for i = 1, #newBonuses do
    local value = newBonuses[i]
    local bonusId = value[1]
    local bonusValue = value[2]
    local attr = US_ENCHANTMENTS[bonusId]
    local ownQuality = value.ownQuality
    local quality = item:isQuality()
    local upgradeLevel = item:getUpgradeLevel()
    if upgradeLevel then
      quality = quality + calculateUpgradeValue(upgradeLevel)
    end
    if attr then
      if ownQuality and value[5] then
        bonusValue = (bonusValue * (1 + value[5] / 100))
      else
        if quality and (not attr.noQuality or not attr.noValue) then
          bonusValue = (bonusValue * (1 + quality / 100))
        end
      end

      if attr.combatType == US_TYPES.CONDITION then
        if not US_CONDITIONS[bonusId] then
          US_CONDITIONS[bonusId] = {}
        end
        if not US_CONDITIONS[bonusId]then
          US_CONDITIONS[bonusId] = {}
        end

        if not US_CONDITIONS[bonusId][uuid] then
          US_CONDITIONS[bonusId][uuid] = {}
          US_CONDITIONS[bonusId][uuid].cond = Condition(attr.condition)
          US_CONDITIONS[bonusId][uuid].value = bonusValue
          local condition = US_CONDITIONS[bonusId][uuid].cond
          if attr.condition ~= CONDITION_MANASHIELD then
            condition:setParameter(CONDITION_PARAM_SUBID,1000 + self:getNextSubId(slotPos, i))
            condition:setParameter(attr.param, attr.percentage == true and bonusValue or bonusValue)
            condition:setParameter(CONDITION_PARAM_TICKS, -1)
          else
            condition:setParameter(CONDITION_PARAM_TICKS, 86400000)
          end
          condition:setParameter(CONDITION_PARAM_BUFF_SPELL, true)
          self:addCondition(condition)
        else
          local condition = US_CONDITIONS[bonusId][uuid].cond
          US_CONDITIONS[bonusId][uuid].value = US_CONDITIONS[bonusId][uuid].value + bonusValue
          condition:setParameter(attr.param, US_CONDITIONS[bonusId][uuid].value)
          self:addCondition(condition)
        end
      end
    end
  end
end

function us_onEquip(cid, slot)
  local player = Player(cid)
  if not player then return end
  local item = player:getSlotItem(slot)
  if not item then
    return
  end

  player:addPlayerModifiersFromItem(item, slot)
end

function removeOldModifiers(item, player, uuid)
  local oldBonuses = item:getBonusAttributes() or {}
  local implictBonuses = item:getImplictBonusAttributes()
  local crystalBonuses = item:getBonusFromCrystals()
  if implictBonuses then
    for i = 1, #implictBonuses do
      table.insert( oldBonuses, implictBonuses[i] )
    end
  end
  if crystalBonuses then
    for i = 1, #crystalBonuses do
      table.insert( oldBonuses, crystalBonuses[i] )
    end
  end
  if oldBonuses then
    for _, value in pairs(oldBonuses) do
      local attr = US_ENCHANTMENTS[value[1]]
      if attr then
        if attr.combatType == US_TYPES.CONDITION then
          if US_CONDITIONS[value[1]] and US_CONDITIONS[value[1]] and US_CONDITIONS[value[1]][uuid] and US_CONDITIONS[value[1]][uuid].cond then
            local condition = US_CONDITIONS[value[1]][uuid].cond
            if condition:getType() ~= CONDITION_MANASHIELD then
              player:removeCondition(
                condition:getType(),
                CONDITIONID_COMBAT,
                condition:getSubId()
              )
            else
              player:removeCondition(condition:getType(), CONDITIONID_COMBAT)
            end
            US_CONDITIONS[value[1]][uuid] = nil
          end
        end
      end
    end
  end
end

function checkItemBeforeEquip(player, item, slot, equip)
  if slot <= CONST_SLOT_POTION2 then
    if slot ~= CONST_SLOT_BACKPACK then
      if equip then
        if item:getType():isUpgradable() then
          us_onEquip(player:getId(), slot)
          if slot == CONST_SLOT_RING or slot == CONST_SLOT_RING2 then
            local ringSlot = slot == CONST_SLOT_RING and CONST_SLOT_RING2 or CONST_SLOT_RING
            local ring = player:getSlotItem(ringSlot)
            if ring and ring:getId() == 38037 then
              us_onEquip(player:getId(), ringSlot)
            end
          end
        end
      else
        if item:getType():isUpgradable() then
          local uuid = item:getRealUID()
          if item:getId() == 38037 then
            local ringSlot = slot == CONST_SLOT_RING and CONST_SLOT_RING2 or CONST_SLOT_RING
            local ring = player:getSlotItem(ringSlot)
            if ring then
              item = ring
            end
          else
            if slot == CONST_SLOT_RING or slot == CONST_SLOT_RING2 then
              local ringSlot = slot == CONST_SLOT_RING and CONST_SLOT_RING2 or CONST_SLOT_RING
              local ring = player:getSlotItem(ringSlot)
              if ring and ring:getId() == 38037 then
                removeOldModifiers(item, player, ring:getRealUID())
              end
            end
          end
          removeOldModifiers(item, player, uuid)
        end
      end
    end
  end
end

function us_onMoveItem(player, item, fromPosition, toPosition)
  if not item:getType():isUpgradable() and not item:getType():canHaveItemLevel() then -- or toPosition.y == CONST_SLOT_AMMO then
    return true
  end

  if item:isUnidentified() then
    if toPosition.y <= CONST_SLOT_POTION2 and toPosition.y ~= CONST_SLOT_BACKPACK then
      player:sendTextMessage(MESSAGE_STATUS_SMALL, "You can't wear unidentified items.")
      player:say("You can't wear unidentified items!", TALKTYPE_MONSTER_SAY)
      return false
    end
  end

  if US_CONFIG.REQUIRE_LEVEL == true then
    if player:getLevel() < item:getItemLevel() and not item:isLimitless() then
      if toPosition.y <= CONST_SLOT_POTION2 and toPosition.y ~= CONST_SLOT_BACKPACK then
        player:sendTextMessage(MESSAGE_STATUS_SMALL, "You need higher level to equip that item.")
        player:say("Need higher level!", TALKTYPE_MONSTER_SAY)
        return false
      end
    end
  end
  return true
end

function Player.setGemSpell(self)
  for i = 1, #GLOBAL_SPELL_NUMBER do
    self:forgetSpell(GLOBAL_SPELL_NUMBER[i])
  end
  for slot = CONST_SLOT_HEAD, CONST_SLOT_POTION2 do
    local item = self:getSlotItem(slot)
    if item then
      if item:isGem() then
        if item:getGem() then --	magic bolt
          self:learnSpell(GLOBAL_SPELL_NUMBER[item:getGem()])
        end
      end
    end
  end
end

function Player.setGemSupport(self)
  for slot = CONST_SLOT_HEAD, CONST_SLOT_POTION2 do
    local item = self:getSlotItem(slot)
    if item then
      if item:isGemSupport() then
        if item:getGemSupport() then   --	magic bolt
          self:setStorageValue(PlayerStorage.spell_support + item:isGemSupport(), 1)
        else
          self:setStorageValue(PlayerStorage.spell_support + item:isGemSupport(), -1)
        end
      end
    end
  end
end

function us_onLogin(player)
  player:registerEvent("UpgradeSystemKill")
  player:registerEvent("UpgradeSystemHealth")
  player:registerEvent("UpgradeSystemMana")
  player:registerEvent("UpgradeSystemPD")

  --player:setCollectionInfo()
  for slot = CONST_SLOT_HEAD, CONST_SLOT_POTION2 do
    local item = player:getSlotItem(slot)
    if item then
      player:addPlayerModifiersFromItem(item, slot)
    end
  end

  local relictBox = player:getSlotItem(CONST_SLOT_RELICT_BOX)
  if relictBox then
    local relictItems = relictBox:getItems()
    for _, item in ipairs(relictItems) do
      player:addPlayerModifiersFromItem(item, CONST_SLOT_RELICT_BOX)
    end
  end
end

function us_onDeath(creature, corpse, lasthitkiller, mostdamagekiller, lasthitunjustified, mostdamageunjustified)
  if creature and lasthitkiller then
    local isPlayer = creature:isPlayer()
    local player = lasthitkiller:isPlayer()
    local range = 1
    if player and colleftInfo[lasthitkiller:getId()].attributesItems[142] then
      range = 4
    end
    if CREATURE_ACTIVE_BUFFS[creature:getId()] then
      for key, buff in pairs(CREATURE_ACTIVE_BUFFS[creature:getId()]) do
        local afterDeath = creature:getAfterDeathDOT(key)
        if afterDeath then
          local from = creature:getPosition()
          local creatures = Game.getSpectators(creature:getPosition(), false, false, range, range, range, range)
          for i = 1, #creatures do
            if creatures[i]:isMonster() then
              local to = creatures[i]:getPosition()
              afterDeath(creatures[i])
              from:sendDistanceEffect(to, 269)
            end
          end
        end
      end

      if not isPlayer then
        local cid = creature:getId()
        CREATURE_ACTIVE_BUFFS[cid] = nil
        ACTIVATED_DOT[cid] = nil
      end
    end
  end

  if not lasthitkiller or not creature:isMonster() or not corpse or corpse.itemid == 0 or not corpse:isContainer() then
    return true
  end
  if not lasthitkiller:isPlayer() and not lasthitkiller:getMaster() then
    return true
  end

  if lasthitkiller:isPlayer() then
    lasthitkiller:autoCastSpell(2)
  end

  return true
end

function us_onKill(player, target, lastHit)
  if not player or not player:isPlayer() or not target or not target:isMonster() then
    return
  end
  local center = target:getPosition()
  if colleftInfo[player:getId()].attributesItems[254] then -- Void Walker
    if target:getSkull() >= 7 then
      player:addBuff(VOID_WALKER)
    end
  end
  if target:hasBuff(ILLUMINATION_DOT) then
    local power = math.ceil((target:getMaxHealth() * 10) / 100)
    doAreaCombatHealth(player:getId(), COMBAT_HOLYDAMAGE, center, area3x3, -power, -power, 0, ORIGIN_CONDITION, 0, 0)
    if colleftInfo[player:getId()].attributesItems[124] then
      player:addBuff(ILLUMINATION_DOT_UNIQUE)
    end
    Position(center.x + 2, center.y + 2, center.z):sendMagicEffect(617)
  end
  if target:hasBuff(BLAZING_SHOUT) then
    local power = math.ceil((target:getMaxHealth() * 10) / 100)
    doAreaCombatHealth(player:getId(), COMBAT_FIREDAMAGE, center, area3x3, -power, -power, 0, ORIGIN_CONDITION, 0, 0)
    Position(center.x + 3, center.y + 3, center.z):sendMagicEffect(488)
  end
  if target:hasBuff(REND) then
    local damage = math.ceil((target:getMaxHealth() * 10) / 100)
    doAreaCombatHealth(player:getId(), COMBAT_PHYSICALDAMAGE, center, area3x3, -damage, -damage, 0, ORIGIN_CONDITION, 0, 0)
    Position(center.x + 1, center.y + 1, center.z):sendMagicEffect(549)
  end
  if colleftInfo[player:getId()].attributesItems[80] then -- Health Gain on Kill
    player:addHealth(colleftInfo[player:getId()].attributesItems[80].value)
  end
  if colleftInfo[player:getId()].attributesItems[81] then -- Mana Gain on Kill
    player:addMana(colleftInfo[player:getId()].attributesItems[81].value)
  end
  if colleftInfo[player:getId()].attributesItems[82] then -- Energy Shield Gain on Kill
    player:addEnergyShield(colleftInfo[player:getId()].attributesItems[82].value)
  end
  if colleftInfo[player:getId()].attributesItems[79] then
    local damage = math.ceil((target:getMaxHealth() * 10) / 100)
    doAreaCombatHealth(player:getId(), COMBAT_FIREDAMAGE, target:getPosition(), area3x3, -damage, -damage, 7, ORIGIN_CONDITION, 0, 0)
  end
  if colleftInfo[player:getId()].attributesItems[15] then
    local damage = math.ceil((target:getMaxHealth() * 10) / 100)
    doAreaCombatHealth(player:getId(), COMBAT_FIREDAMAGE, target:getPosition(), area3x3, -damage, -damage, 7, ORIGIN_CONDITION, 0, 0)
  end

  if player:hasBuff(SHRINE_CORPSE_EXPLOSION) then
    local damage = math.ceil((target:getMaxHealth() * 10) / 100)
    doAreaCombatHealth(player:getId(), COMBAT_FIREDAMAGE, target:getPosition(), area3x3, -damage, -damage, 0, ORIGIN_CONDITION, 0, 0)
    local playerPos = target:getPosition()
    position = Position(playerPos.x + 3, playerPos.y + 3, playerPos.z)
		position:sendMagicEffect(488)
  end
  --  cd:setParameter(CONDITION_PARAM_SUBID, 6000)

  if colleftInfo[player:getId()].attributesItems[38] then
    player:addBuff(BUFF_DAMAGE_ATTRIBUTES)
  end
  if colleftInfo[player:getId()].attributesItems[39] then
    CriticalDamagecondition = Condition(CONDITION_ATTRIBUTES)
    CriticalDamagecondition:setParameter(CONDITION_PARAM_SPECIALSKILL_CRITICALHITCHANCE, 10)
    CriticalDamagecondition:setParameter(CONDITION_PARAM_TICKS, 10000)
    CriticalDamagecondition:setParameter(CONDITION_PARAM_SUBID, 3247)
    player:addCondition(CriticalDamagecondition)
    player:addBuff(BUFF_CRITICAL)
  end
  if colleftInfo[player:getId()].attributesItems[40] then
    CriticalDamagecondition = Condition(CONDITION_ATTRIBUTES)
    CriticalDamagecondition:setParameter(CONDITION_PARAM_SPECIALSKILL_CRITICALHITAMOUNT, 50)
    CriticalDamagecondition:setParameter(CONDITION_PARAM_TICKS, 10000)
    CriticalDamagecondition:setParameter(CONDITION_PARAM_SUBID, 3249)
    player:addCondition(CriticalDamagecondition)
    player:addBuff(BUFF_CRITICAL_DAMAGE)
  end

  local afterKillHeal = 0
  if target:getBuff(HARVEST_DEBUFF) then
    afterKillHeal = afterKillHeal + 1
  end
  if afterKillHeal > 0 then
    local hp = math.ceil(player:getMaxHealth() * (afterKillHeal / 100))
    local mana = math.ceil(player:getMaxMana() * (afterKillHeal / 100))
    player:addHealth(hp)
    player:addMana(mana)
  end
end

function us_onPrepareDeath(creature, killer)
  if creature:isPlayer() then
    if colleftInfo[creature:getId()].attributesItems[207] then -- Resurrection
      if creature:getBuff(RESURRECTION) then
      else
        creature:addHealth(creature:getMaxHealth())
        creature:addMana(creature:getMaxMana())
        creature:addEnergyShield(creature:getMaxEnergyShield())
        creature:getPosition():sendMagicEffect(421)
        creature:addBuff(RESURRECTION, 3*60000)
        creature:addBuff(BOSS_IMMORTAL)
        creature:sendTextMessage(MESSAGE_INFO_DESCR, "You have been revived!")
        return false
      end
    end
  end
  return true
end

function us_onGainExperience(player, source, wartosc, rawExp)
  local wartosc = 0

  return wartosc
end

function us_RemoveBuff(pid, buffId, buffName)
  if US_BUFFS[pid] then
    US_BUFFS[pid][buffId] = nil
    local player = Player(pid)
    if player then
      player:say("" .. buffName .. " ended!", TALKTYPE_MONSTER_SAY)
      player:getPosition():sendMagicEffect(7)
    end
  end
end

function Item.addAttribute(self, slot, attr, value)
  if self:getId() == 0 then return end
  self:setCustomAttribute("Slot" .. slot, attr .. "|" .. value)
end

function Item.setAttributeValue(self, slot, value)
  if self:getId() == 0 then return end
  if not value then
    self:removeCustomAttribute("Slot"..slot)
    return
  end

  self:setCustomAttribute("Slot" .. slot, value)
end

local SLOTS_TO_RARITY = {
  [0] = 0,
  [1] = 1,
  [2] = 2,
  [3] = 3,
  [4] = 3,
  [5] = 3,
  [6] = 3
}

function Item:setCorrectRarity()
  if self:getCustomAttribute("crystal") or self:getCustomAttribute("forceType") then
    self:updateSelf()
    return
  end

	local rarity = self:getMaxAttributes()
  if self:isUnique() then
    self:setRarity(5)
  elseif self:isExalted() then
    self:setRarity(self:isExalted())
  elseif self:getSpellName() ~= "" then
    self:setRarity(self:getRarityId())
  else
	  self:setRarity(SLOTS_TO_RARITY[rarity])
  end

  self:updateSelf()
end

function Item.getLastSlot(self)
  if self:getId() == 0 then return end
  local slot = 0
  local bonuses = self:getBonusAttributes()
  if not bonuses then
    return slot
  end

  for i = 1, #bonuses do
    if bonuses[i][4] > slot then
      slot = bonuses[i][4]
    end
  end

  return slot
end

function Item.getLastSlotDung(self)
  if self:getId() == 0 then return end
  local slot = 0
  local bonuses = self:getDungeonModifiers()
  if not bonuses then
    return slot
  end

  for i = 1, #bonuses do
    if bonuses[i][4] > slot then
      slot = bonuses[i][4]
    end
  end

  return slot
end

function Item.getEmptyAttributeSlot(self)
  if self:getId() == 0 then return end
  for i = 1, self:getMaxAttributes() do
    local attr = self:getCustomAttribute("Slot" .. i)
    if not attr or attr == "" then
      return i
    end
  end

  return nil
end

function Item.getBonusAttribute(self, slot)
  if self:getId() == 0 then return end
  local bonuses = self:getCustomAttribute("Slot" .. slot)
  if bonuses then
    local data = {}
    for bonus in bonuses:gmatch("([^|]+)") do
      data[#data + 1] = tonumber(bonus)
    end
    return data
  end

  return nil
end

function Item.getBonusAttributes(self)
  if self:getId() == 0 then return end
  local data = {}
  local slotss = self:getMaxAttributes()
  for i = 1, slotss do
    local bonuses = self:getCustomAttribute("Slot" .. i)
    if bonuses then
      local t = {}
      for bonus in bonuses:gmatch("([^|]+)") do
        t[#t + 1] = tonumber(bonus)
      end
      t[4] = i
      data[#data + 1] = t
    end
  end

  return #data > 0 and data or nil
end

function Item.sealModifier(self, id)
  local seals = self:getCustomAttribute("Seal")
  local text = ""
  if seals then
    text = seals
  end

  self:setCustomAttribute("Seal", text..id.."|")
end

function Item.getSealedModifiers(self)
  local seals = self:getCustomAttribute("Seal")
  local data = {}
  local empty = true

  if seals then
    for id in string.gmatch(seals, "([^|]+)") do
      data[id] = true
      empty = false
    end
  end

  if empty then
    return nil
  end

  return data
end

function Item.setItemLevel(self, level, first)
  local oldLevel = self:getItemLevel() or 0
  local itemType = ItemType(self.itemid)
  local finalValue = 0
  local value = 0
  if oldLevel < level then
    value = (level - oldLevel)
  else
    value = (oldLevel - level)
  end
  if itemType:getAttack() > 0 and US_CONFIG.ATTACK_PER_ITEM_LEVEL and US_CONFIG.ATTACK_FROM_ITEM_LEVEL then
    if value >= US_CONFIG.ATTACK_PER_ITEM_LEVEL then
      finalValue = math.floor((value / US_CONFIG.ATTACK_PER_ITEM_LEVEL) * US_CONFIG.ATTACK_FROM_ITEM_LEVEL)
    else
      finalValue = 0
    end
    if oldLevel < level then
      self:setAttribute(
        ITEM_ATTRIBUTE_ATTACK,
        (self:getAttribute(ITEM_ATTRIBUTE_ATTACK) > 0) and (self:getAttribute(ITEM_ATTRIBUTE_ATTACK) + finalValue) or
        (itemType:getAttack() + finalValue)
      )
    else
      self:setAttribute(
        ITEM_ATTRIBUTE_ATTACK,
        (self:getAttribute(ITEM_ATTRIBUTE_ATTACK) > 0) and (self:getAttribute(ITEM_ATTRIBUTE_ATTACK) - finalValue) or
        (itemType:getAttack() - finalValue)
      )
    end
  end
  if itemType:getDefense() > 0 and US_CONFIG.DEFENSE_PER_ITEM_LEVEL and US_CONFIG.DEFENSE_FROM_ITEM_LEVEL then
    if value >= US_CONFIG.DEFENSE_PER_ITEM_LEVEL then
      finalValue = math.floor((value / US_CONFIG.DEFENSE_PER_ITEM_LEVEL) * US_CONFIG.DEFENSE_FROM_ITEM_LEVEL)
    else
      finalValue = 0
    end
    if oldLevel < level then
      self:setAttribute(
        ITEM_ATTRIBUTE_DEFENSE,
        (self:getAttribute(ITEM_ATTRIBUTE_DEFENSE) > 0) and (self:getAttribute(ITEM_ATTRIBUTE_DEFENSE) + finalValue) or
        (itemType:getDefense() + finalValue)
      )
    else
      self:setAttribute(
        ITEM_ATTRIBUTE_DEFENSE,
        (self:getAttribute(ITEM_ATTRIBUTE_DEFENSE) > 0) and (self:getAttribute(ITEM_ATTRIBUTE_DEFENSE) - finalValue) or
        (itemType:getDefense() - finalValue)
      )
    end
  end
  if itemType:getArmor() > 0 and US_CONFIG.ARMOR_PER_ITEM_LEVEL and US_CONFIG.ARMOR_FROM_ITEM_LEVEL then
    if value >= US_CONFIG.ARMOR_PER_ITEM_LEVEL then
      finalValue = math.floor((value / US_CONFIG.ARMOR_PER_ITEM_LEVEL) * US_CONFIG.ARMOR_FROM_ITEM_LEVEL)
    else
      finalValue = 0
    end
    if oldLevel < level then
      self:setAttribute(
        ITEM_ATTRIBUTE_ARMOR,
        (self:getAttribute(ITEM_ATTRIBUTE_ARMOR) > 0) and (self:getAttribute(ITEM_ATTRIBUTE_ARMOR) + finalValue) or
        (itemType:getArmor() + finalValue)
      )
    else
      self:setAttribute(
        ITEM_ATTRIBUTE_ARMOR,
        (self:getAttribute(ITEM_ATTRIBUTE_ARMOR) > 0) and (self:getAttribute(ITEM_ATTRIBUTE_ARMOR) - finalValue) or
        (itemType:getArmor() - finalValue)
      )
    end
  end
  if itemType:getHitChance() > 0 and US_CONFIG.HITCHANCE_PER_ITEM_LEVEL and US_CONFIG.HITCHANCE_FROM_ITEM_LEVEL then
    if value >= US_CONFIG.HITCHANCE_PER_ITEM_LEVEL then
      finalValue = math.floor((value / US_CONFIG.HITCHANCE_PER_ITEM_LEVEL) * US_CONFIG.HITCHANCE_FROM_ITEM_LEVEL)
    else
      finalValue = 0
    end
    if oldLevel < level then
      self:setAttribute(
        ITEM_ATTRIBUTE_HITCHANCE,
        (self:getAttribute(ITEM_ATTRIBUTE_HITCHANCE) > 0) and (self:getAttribute(ITEM_ATTRIBUTE_HITCHANCE) + finalValue) or
        (itemType:getHitChance() + finalValue)
      )
    else
      self:setAttribute(
        ITEM_ATTRIBUTE_HITCHANCE,
        (self:getAttribute(ITEM_ATTRIBUTE_HITCHANCE) > 0) and (self:getAttribute(ITEM_ATTRIBUTE_HITCHANCE) - finalValue) or
        (itemType:getHitChance() - finalValue)
      )
    end
  end
  if first then
    if itemType:getAttack() > 0 and US_CONFIG.ITEM_LEVEL_PER_ATTACK then
      level = level + math.floor(itemType:getAttack() / US_CONFIG.ITEM_LEVEL_PER_ATTACK)
    end
    if itemType:getDefense() > 0 and US_CONFIG.ITEM_LEVEL_PER_DEFENSE then
      level = level + math.floor(itemType:getDefense() / US_CONFIG.ITEM_LEVEL_PER_DEFENSE)
    end
    if itemType:getArmor() > 0 and US_CONFIG.ITEM_LEVEL_PER_ARMOR then
      level = level + math.floor(itemType:getArmor() / US_CONFIG.ITEM_LEVEL_PER_ARMOR)
    end
    if itemType:getHitChance() > 0 and US_CONFIG.ITEM_LEVEL_PER_HITCHANCE then
      level = level + math.floor(itemType:getHitChance() / US_CONFIG.ITEM_LEVEL_PER_HITCHANCE)
    end
  end
  return self:setCustomAttribute("item_level", level)
end

function Item.getItemLevel(self)
  if self:getId() == 0 then return end
  return self:getCustomAttribute("item_level") and self:getCustomAttribute("item_level") or 0
end

function Item.getUpgradeLevel(self)
  if self:getId() == 0 then return end
  return self:getCustomAttribute("ulvl") and self:getCustomAttribute("ulvl") or 0
end

function Item.setUpgradeLevel(self, level)
  if self:getId() == 0 then return end
  return self:setCustomAttribute("ulvl", level)
end

function Item.unidentify(self)
  self:setCustomAttribute("unidentified", true)
end

function Item.isUnidentified(self)
  if self:getId() == 0 then return end
  return self:getCustomAttribute("unidentified")
end

function Item.identify(self, player, itemType, weaponType)
  if self:getId() == 0 then return end
  self:removeCustomAttribute("unidentified")
  local usItemType = self:getItemType()
  local canUnique = false
--  for i = 1, #US_UNIQUES do
--    if US_UNIQUES[i].minLevel <= self:getItemLevel() and bit.band(usItemType, US_UNIQUES[i].itemType) ~= 0 then
--      canUnique = true
--      break
--    end
--  end
  if US_CONFIG.IDENTIFY_UPGRADE_LEVEL then
    local upgrade_level = math.random(0, US_CONFIG.IDENTIFY_UPGRADE_LEVEL_MAX)
    if upgrade_level > 0 then
      self:setUpgradeLevel(upgrade_level)
    end
  end
  if US_CONFIG.IDENTIFY_QUALITY_LEVEL then
    local quality_level = math.random(0, US_CONFIG.IDENTIFY_QUALITY_LEVEL_MAX)
    if quality_level > 0 then
      self:setQuality(quality_level)
    end
  end
  if not self:isCraftBonus() then
    self:rollRarity(player)
  end
  if canUnique and math.random(0, US_CONFIG.UNIQUE_CHANCE) == 1 then
    local unique = math.random(#US_UNIQUES)
    while US_UNIQUES[unique].minLevel > self:getItemLevel() or bit.band(usItemType, US_UNIQUES[unique].itemType) == 0 or
      US_UNIQUES[unique].chance and math.random(100) >= US_UNIQUES[unique].chance do
      unique = math.random(#US_UNIQUES)
    end
    self:setUnique(unique)
    player:sendTextMessage(MESSAGE_INFO_DESCR, "Unique item " .. self:getUniqueName() .. " discovered!")
    player:say("Unique Item!", TALKTYPE_MONSTER_SAY)
  else
    self:rollAttribute()
    --	player:say("Item is: "..self:getRarity().name.."!", TALKTYPE_MONSTER_SAY)
    player:sendExtendedOpcode(105, json.encode({ reload = "reload" }))
  end
  return true
end

function Item.setUnique(self, uniqueId)
  if self:getId() == 0 then return end
  self:setCustomAttribute("unique", uniqueId)
  local unique = US_UNIQUES[uniqueId]
  if unique then
    for i = 1, #unique.attributes do
      local attrId = unique.attributes[i]
      local attr = US_ENCHANTMENTS[attrId]
      local value = attr.VALUES_PER_LEVEL and math.random(1, math.ceil(self:getItemLevel() * attr.VALUES_PER_LEVEL))
      self:setCustomAttribute("Slot" .. self:getLastSlot() + 1, attrId .. "|" .. value)
    end
  end
end

function Item.getUnique(self)
  if self:getId() == 0 then return end
  return self:getCustomAttribute("unique") and self:getCustomAttribute("unique") or nil
end

function Item.isUnique(self)
  if self:getId() == 0 then return end
  return self:getCustomAttribute("unique") and true or false
end

function Item.getUniqueName(self)
  return US_UNIQUES[self:getUnique()].name
end

-- 																			Ancient
function Item.setAncient(self, ancientId)
  if self:getId() == 0 then return end
  self:setCustomAttribute("ancient", ancientId)
  local ancient = US_UNIQUES[ancientId]
  if ancient then
    for i = 1, #ancient.attributes do
      local attrId = ancient.attributes[i]
      local attr = US_ENCHANTMENTS[attrId]
      local value = attr.VALUES_PER_LEVEL and math.random(1, math.ceil(self:getItemLevel() * attr.VALUES_PER_LEVEL))
      self:setCustomAttribute("Slot" .. self:getLastSlot() + 1, attrId .. "|" .. value)
    end
  end
end

function Item.setGem(self, gem)
  if self:getId() == 0 then return end
  return self:setCustomAttribute("gem", gem)
end

function Item.getGem(self)
  if self:getId() == 0 then return end
  return self:getCustomAttribute("gem") and self:getCustomAttribute("gem") or 0
end

function Item.isGem(self)
  if self:getId() == 0 then return end
  return self:getCustomAttribute("gem") and true or false
end

function Item.setGemSupport(self, gem_support)
  if self:getId() == 0 then return end
  return self:setCustomAttribute("gem_support", gem_support)
end

function Item.getGemSupport(self)
  if self:getId() == 0 then return end
  return self:getCustomAttribute("gem_support") and self:getCustomAttribute("gem_support") or 0
end

function Item.isGemSupport(self)
  if self:getId() == 0 then return end
  return self:getCustomAttribute("gem_support") and true or false
end

function Item.setClassItemLevel(self, classlevel)
  if self:getId() == 0 then return end
  return self:setCustomAttribute("classlevel", classlevel)
end

function Item.getClassItemLevel(self)
  if self:getId() == 0 then return end
  return self:getCustomAttribute("classlevel") and self:getCustomAttribute("classlevel") or 0
end

function Item.setClassItem(self, class)
  if self:getId() == 0 then return end
  return self:setCustomAttribute("class", class)
end

function Item.getClassItem(self)
  if self:getId() == 0 then return end
  return self:getCustomAttribute("class") and self:getCustomAttribute("class") or 0
end

function Item.isClassItem(self)
  if self:getId() == 0 then return end
  return self:getCustomAttribute("class") and true or false
end

-- fusuon
function Item.setFusionLevel(self, fusion_level)
  if self:getId() == 0 then return end
  return self:setCustomAttribute("fusion_level", fusion_level)
end

function Item.getFusionLevel(self)
  if self:getId() == 0 then return end
  return self:getCustomAttribute("fusion_level") and self:getCustomAttribute("fusion_level") or 0
end

function Item.isFusionLevel(self)
  if self:getId() == 0 then return end
  return self:getCustomAttribute("fusion_level") and true or false
end

---						CRAFT
function Item.setCraftBonus(self, craftbonus)
  if self:getId() == 0 then return end
  return self:setCustomAttribute("craftbonus", craftbonus)
end

function Item.getCraftBonus(self)
  if self:getId() == 0 then return end
  return self:getCustomAttribute("craftbonus") and self:getCustomAttribute("craftbonus") or 0
end

function Item.isCraftBonus(self)
  if self:getId() == 0 then return end
  return self:getCustomAttribute("craftbonus") and true or false
end

-----------------------------------------------------------------------------
function Item.setArenaScalingAttributes(self, arenascalingattributes_item)
  if self:getId() == 0 then return end
  return self:setCustomAttribute("arenascalingattributes_item", arenascalingattributes_item)
end

function Item.getArenaScalingAttributes(self)
  if self:getId() == 0 then return end
  return self:getCustomAttribute("arenascalingattributes_item") and
      self:getCustomAttribute("arenascalingattributes_item") or 0
end

function Item.isArenaScalingAttributes(self)
  if self:getId() == 0 then return end
  return self:getCustomAttribute("arenascalingattributes_item") and true or false
end
-----------------------------------------------------------------------------
function Item.setForgePotencial(self, forge_potencial)
  if self:getId() == 0 then return end
  return self:setCustomAttribute("forge_potencial", forge_potencial)
end

function Item.getForgePotencial(self)
  if self:getId() == 0 then return end
  return self:getCustomAttribute("forge_potencial") and self:getCustomAttribute("forge_potencial") or 0
end

function Item.isForgePotencial(self)
  if self:getId() == 0 then return end
  return self:getCustomAttribute("forge_potencial") and true or false
end
-----------------------------------------------------------------------------
function Item.setArenaScalingLevel(self, arenascalinglevel_item)
  if self:getId() == 0 then return end
  return self:setCustomAttribute("arenascalinglevel_item", arenascalinglevel_item)
end

function Item.getArenaScalingLevel(self)
  if self:getId() == 0 then return end
  return self:getCustomAttribute("arenascalinglevel_item") and self:getCustomAttribute("arenascalinglevel_item") or 0
end

function Item.isArenaScalingLevel(self)
  if self:getId() == 0 then return end
  return self:getCustomAttribute("arenascalinglevel_item") and true or false
end

-----------------------------------------------------------------------------
function Item.setEndlessItem(self, endless_item)
  if self:getId() == 0 then return end
  return self:setCustomAttribute("endless_item", endless_item)
end

function Item.getEndlessItem(self)
  if self:getId() == 0 then return end
  return self:getCustomAttribute("endless_item") and self:getCustomAttribute("endless_item") or 0
end

function Item.isEndlessItem(self)
  if self:getId() == 0 then return end
  return self:getCustomAttribute("endless_item") and true or false
end

-----------------------------------------------------------------------------
function Item.setEndlessItemCorrupted(self, endless_item_corrupted)
  if self:getId() == 0 then return end
  return self:setCustomAttribute("endless_item_corrupted", endless_item_corrupted)
end

function Item.getEndlessItemCorrupted(self)
  if self:getId() == 0 then return end
  return self:getCustomAttribute("endless_item_corrupted") and self:getCustomAttribute("endless_item_corrupted") or 0
end

function Item.isEndlessItemCorrupted(self)
  if self:getId() == 0 then return end
  return self:getCustomAttribute("endless_item_corrupted") and true or false
end

-------------------------------------------------------------------------
function Item.setDungeonItem(self, dungeon_item)
  if self:getId() == 0 then return end
  return self:setCustomAttribute("dungeon_item", dungeon_item)
end

function Item.getDungeonItem(self)
  if self:getId() == 0 then return end
  return self:getCustomAttribute("dungeon_item") and self:getCustomAttribute("dungeon_item") or 0
end

function Item.isDungeonItem(self)
  if self:getId() == 0 then return end
  return self:getCustomAttribute("dungeon_item") and true or false
end

---							Soul Shard
function Item.setSoulShard(self, soulshard)
  if self:getId() == 0 then return end
  return self:setCustomAttribute("soulshard", soulshard)
end

function Item.setSoulShardLevel(self, soulshardlevel)
  if self:getId() == 0 then return end
  return self:setCustomAttribute("soulshardlevel", soulshardlevel)
end

function Item.getSoulShardLevel(self)
  if self:getId() == 0 then return end
  return self:getCustomAttribute("soulshardlevel") and self:getCustomAttribute("soulshardlevel") or 0
end

function Item.isSoulShardLevel(self)
  if self:getId() == 0 then return end
  return self:getCustomAttribute("soulshardlevel") and true or false
end

function Item.getSoulShard(self)
  if self:getId() == 0 then return end
  return self:getCustomAttribute("soulshard") and self:getCustomAttribute("soulshard") or 0
end

function Item.isSoulShard(self)
  if self:getId() == 0 then return end
  return self:getCustomAttribute("soulshard") and true or false
end

function Item.isLegendarySoulShard(self)
  if self:getId() == 0 then return end
  return self:getCustomAttribute("legendary_soulshard") and true or false
end

function Item.setLegendarySoulShard(self, legendary_soulshard)
  if self:getId() == 0 then return end
  return self:setCustomAttribute("legendary_soulshard", legendary_soulshard)
end

function Item.getLegendarySoulShard(self)
  if self:getId() == 0 then return end
  return self:getCustomAttribute("legendary_soulshard") and self:getCustomAttribute("legendary_soulshard") or 0
end

--- globe
function Item.isBonusGlobe(self)
  if self:getId() == 0 then return end
  return self:getCustomAttribute("globe") and true or false
end

function Item.setBonusGlobe(self, globe)
  if self:getId() == 0 then return end
  return self:setCustomAttribute("globe", globe)
end

function Item.getBonusGlobe(self)
  if self:getId() == 0 then return end
  return self:getCustomAttribute("globe") and self:getCustomAttribute("globe") or 0
end

--
function Item.isInfluenced(self)
  if self:getId() == 0 then return end
  return self:getCustomAttribute("influenced") and true or false
end

function Item.setInfluenced(self, influenced)
  if self:getId() == 0 then return end
  return self:setCustomAttribute("influenced", influenced)
end

function Item.getInfluenced(self)
  if self:getId() == 0 then return end
  return self:getCustomAttribute("influenced") and self:getCustomAttribute("influenced") or 0
end

-- req Level
function Item.isLevelReq(self)
  if self:getId() == 0 then return end
  return self:getCustomAttribute("levelreq") and true or false
end

function Item.setLevelReq(self, levelreq)
  if self:getId() == 0 then return end
  return self:setCustomAttribute("levelreq", levelreq)
end

function Item.getLevelReq(self)
  if self:getId() == 0 then return end
  return self:getCustomAttribute("levelreq") and self:getCustomAttribute("levelreq") or 0
end

function Item.isVocationReq(self)
  if self:getId() == 0 then return end
  return self:getCustomAttribute("vocreq") and true or false
end

function Item.setVocationReq(self, vocreq)
  if self:getId() == 0 then return end
  return self:setCustomAttribute("vocreq", vocreq)
end

function Item.getVocationReq(self)
  if self:getId() == 0 then return end
  return self:getCustomAttribute("vocreq") and self:getCustomAttribute("vocreq") or 0
end

-- level

-- Comparing Offensive
function Item.setComparingOffensive(self, comparing_offensive)
  if self:getId() == 0 then return end
  return self:setCustomAttribute("comparing_offensive", comparing_offensive)
end

function Item.getComparingOffensive(self)
  if self:getId() == 0 then return end
  return self:getCustomAttribute("comparing_offensive") and self:getCustomAttribute("comparing_offensive") or 0
end

function Item.isComparingOffensive(self)
  if self:getId() == 0 then return end
  return self:getCustomAttribute("comparing_offensive") and true or false
end

-- Comparing Toughness
function Item.setComparingToughness(self, comparing_toughness)
  if self:getId() == 0 then return end
  return self:setCustomAttribute("comparing_toughness", comparing_toughness)
end

function Item.getComparingToughness(self)
  if self:getId() == 0 then return end
  return self:getCustomAttribute("comparing_toughness") and self:getCustomAttribute("comparing_toughness") or 0
end

function Item.isComparingToughness(self)
  if self:getId() == 0 then return end
  return self:getCustomAttribute("comparing_toughness") and true or false
end

-- Comparing Recovery
function Item.setComparingRecovery(self, comparing_recovery)
  if self:getId() == 0 then return end
  return self:setCustomAttribute("comparing_recovery", comparing_recovery)
end

function Item.getComparingRecovery(self)
  if self:getId() == 0 then return end
  return self:getCustomAttribute("comparing_recovery") and self:getCustomAttribute("comparing_recovery") or 0
end

function Item.isComparingRecovery(self)
  if self:getId() == 0 then return end
  return self:getCustomAttribute("comparing_recovery") and true or false
end

function Item.isExalted(self)
  if self:getId() == 0 then return end
  local bonuses = self:getCustomAttribute("DungeonKey") and self:getDungeonModifiers() or self:getBonusAttributes()
  if not bonuses then
    return false
  end

  local highestTier = 0
  for i = 1, #bonuses do
    local attr = bonuses[i]
    if attr and attr ~= "" then
      if attr[3] and attr[3] > 5 then
        highestTier = math.max(highestTier, attr[3])
      end
    end
  end

  if highestTier < 6 then
    return false
  end

  return highestTier
end

function Item.setCorrupted(self, corrupted)
  if self:getId() == 0 then return end
  return self:setCustomAttribute("corrupted", corrupted)
end

function Item.getCorrupted(self)
  if self:getId() == 0 then return end
  return self:getCustomAttribute("corrupted") and self:getCustomAttribute("corrupted") or 0
end

function Item.isCorrupted(self)
  if self:getId() == 0 then return end
  return self:getCustomAttribute("corrupted") and true or false
end

--																	FLASK
function Item.setFlask(self, flask)
  if self:getId() == 0 then return end
  return self:setCustomAttribute("flask", flask)
end

function Item.getFlask(self)
  if self:getId() == 0 then return end
  return self:getCustomAttribute("flask") and self:getCustomAttribute("flask") or 0
end

function Item.isFlask(self)
  if self:getId() == 0 then return end
  return self:getCustomAttribute("flask") and true or false
end

--																	FLASK attribite
function Item.setFlaskAttribute(self, flask_attribute)
  if self:getId() == 0 then return end
  return self:setCustomAttribute("flask_attribute", flask_attribute)
end

function Item.getFlaskAttribute(self)
  if self:getId() == 0 then return end
  return self:getCustomAttribute("flask_attribute") and self:getCustomAttribute("flask_attribute") or 0
end

function Item.isFlaskAttribute(self)
  if self:getId() == 0 then return end
  return self:getCustomAttribute("flask_attribute") and true or false
end

--														FLASK BONUS
function Item.setFlaskBonus(self, flaskbonus)
  if self:getId() == 0 then return end
  return self:setCustomAttribute("flaskbonus", flaskbonus)
end

function Item.getFlaskBonus(self)
  if self:getId() == 0 then return end
  return self:getCustomAttribute("flaskbonus") and self:getCustomAttribute("flaskbonus") or 0
end

function Item.isFlaskBonus(self)
  if self:getId() == 0 then return end
  return self:getCustomAttribute("flaskbonus") and true or false
end
--														FLASK BONUS dwa
function Item.setFlaskBonus2(self, flaskbonus2)
  if self:getId() == 0 then return end
  return self:setCustomAttribute("flaskbonus2", flaskbonus2)
end

function Item.getFlaskBonus2(self)
  if self:getId() == 0 then return end
  return self:getCustomAttribute("flaskbonus2") and self:getCustomAttribute("flaskbonus2") or 0
end

function Item.isFlaskBonus2(self)
  if self:getId() == 0 then return end
  return self:getCustomAttribute("flaskbonus2") and true or false
end

--														FLASK BONUS RANDOM
function Item.setFlaskBonusValue(self, flaskbonusvalue)
  if self:getId() == 0 then return end
  return self:setCustomAttribute("flaskbonusvalue", flaskbonusvalue)
end

function Item.getFlaskBonusValue(self)
  if self:getId() == 0 then return end
  return self:getCustomAttribute("flaskbonusvalue") and self:getCustomAttribute("flaskbonusvalue") or 0
end

function Item.isFlaskBonusValue(self)
  if self:getId() == 0 then return end
  return self:getCustomAttribute("flaskbonusvalue") and true or false
end

function Item.setPortalItem(self, portal_item)
  if self:getId() == 0 then return end
  return self:setCustomAttribute("portal_item", portal_item)
end

function Item.getPortalItem(self)
  if self:getId() == 0 then return end
  return self:getCustomAttribute("portal_item") and self:getCustomAttribute("portal_item") or 0
end

function Item.isPortalItem(self)
  if self:getId() == 0 then return end
  return self:getCustomAttribute("portal_item") and true or false
end

---																										setStrongBox
function Item.setStrongBox(self, strongbox)
  if self:getId() == 0 then return end
  return self:setCustomAttribute("strongbox", strongbox)
end

function Item.getStrongBox(self)
  if self:getId() == 0 then return end
  return self:getCustomAttribute("strongbox") and self:getCustomAttribute("strongbox") or 0
end

function Item.isStrongBox(self)
  if self:getId() == 0 then return end
  return self:getCustomAttribute("strongbox") and true or false
end
--- Item is from Strong box
function Item.setStrongBoxItem(self, strongbox_item)
  if self:getId() == 0 then return end
  return self:setCustomAttribute("strongbox_item", strongbox_item)
end

function Item.getStrongBoxItem(self)
  if self:getId() == 0 then return end
  return self:getCustomAttribute("strongbox_item") and self:getCustomAttribute("strongbox_item") or 0
end

function Item.isStrongBoxItem(self)
  if self:getId() == 0 then return end
  return self:getCustomAttribute("strongbox_item") and true or false
end

---																										setStrongBox	ID
function Item.setStrongBoxId(self, strongboxid)
  if self:getId() == 0 then return end
  return self:setCustomAttribute("strongboxid", strongboxid)
end

function Item.getStrongBoxId(self)
  if self:getId() == 0 then return end
  return self:getCustomAttribute("strongboxid") and self:getCustomAttribute("strongboxid") or 0
end

function Item.isStrongBoxId(self)
  if self:getId() == 0 then return end
  return self:getCustomAttribute("strongboxid") and true or false
end

---																										setStrongBox	AFFIX
function Item.setStrongBoxAffix(self, strongboxaffix)
  if self:getId() == 0 then return end
  return self:setCustomAttribute("strongboxaffix", strongboxaffix)
end

function Item.getStrongBoxAffix(self)
  if self:getId() == 0 then return end
  return self:getCustomAttribute("strongboxaffix") and self:getCustomAttribute("strongboxaffix") or 0
end

function Item.isStrongBoxAffix(self)
  if self:getId() == 0 then return end
  return self:getCustomAttribute("strongboxaffix") and true or false
end

---																										setStrongBox	TIER
function Item.setStrongBoxTier(self, strongboxtier)
  if self:getId() == 0 then return end
  return self:setCustomAttribute("strongboxtier", strongboxtier)
end

function Item.getStrongBoxTier(self)
  if self:getId() == 0 then return end
  return self:getCustomAttribute("strongboxtier") and self:getCustomAttribute("strongboxtier") or 0
end

function Item.isStrongBoxTier(self)
  if self:getId() == 0 then return end
  return self:getCustomAttribute("strongboxtier") and true or false
end

---																										setHM 	WIEKSZA SZANSA NA HEROIC I MYTHIC	
function Item.setHM(self, hm)
  if self:getId() == 0 then return end
  return self:setCustomAttribute("hm", hm)
end

function Item.getHM(self)
  if self:getId() == 0 then return end
  return self:getCustomAttribute("hm") and self:getCustomAttribute("hm") or 0
end

function Item.isHM(self)
  if self:getId() == 0 then return end
  return self:getCustomAttribute("hm") and true or false
end

function Item.isCraftItem(self)
  if self:getId() == 0 then return end
  return self:getCustomAttribute("craftitem") and true or false
end

function Item.setCraftItem(self, craftitem)
  if self:getId() == 0 then return end
  return self:setCustomAttribute("craftitem", craftitem)
end

function Item.getCraftItem(self)
  if self:getId() == 0 then return end
  return self:getCustomAttribute("craftitem") and self:getCustomAttribute("craftitem") or 0
end

function Item.isImplicit(self)
  if self:getId() == 0 then return end
  return self:getCustomAttribute("implicit") and true or false
end

function Item.setImplicit(self, implicit)
  if self:getId() == 0 then return end
  return self:setCustomAttribute("implicit", implicit)
end

function Item.getImplicit(self)
  if self:getId() == 0 then return end
  return self:getCustomAttribute("implicit") and self:getCustomAttribute("implicit") or 0
end

function Item.isHeroicItem(self)
  if self:getId() == 0 then return end
  return self:getCustomAttribute("heroicitem") and true or false
end

function Item.setHeroicItem(self, heroicitem)
  if self:getId() == 0 then return end
  return self:setCustomAttribute("heroicitem", heroicitem)
end

function Item.getHeroicItem(self)
  if self:getId() == 0 then return end
  return self:getCustomAttribute("heroicitem") and self:getCustomAttribute("heroicitem") or 0
end

function Item.isLegendaryItem(self)
  if self:getId() == 0 then return end
  return self:getCustomAttribute("legendaryitem") and true or false
end

function Item.setLegendaryItem(self, legendaryitem)
  if self:getId() == 0 then return end
  return self:setCustomAttribute("legendaryitem", legendaryitem)
end

function Item.getLegendaryItem(self)
  if self:getId() == 0 then return end
  return self:getCustomAttribute("legendaryitem") and self:getCustomAttribute("legendaryitem") or 0
end

function Item.isDivineRandom(self)
  if self:getId() == 0 then return end
  return self:getCustomAttribute("divine_random") and true or false
end

function Item.setDivineRandom(self, divine_random)
  if self:getId() == 0 then return end
  return self:setCustomAttribute("divine_random", divine_random)
end

function Item.getDivineRandom(self)
  if self:getId() == 0 then return end
  return self:getCustomAttribute("divine_random") and self:getCustomAttribute("divine_random") or 0
end

function Item.isDivineAbility(self)
  if self:getId() == 0 then return end
  return self:getCustomAttribute("divine_ability") and true or false
end

function Item.setDivineAbility(self, divine_ability)
  if self:getId() == 0 then return end
  return self:setCustomAttribute("divine_ability", divine_ability)
end

function Item.getDivineAbility(self)
  if self:getId() == 0 then return end
  return self:getCustomAttribute("divine_ability") and self:getCustomAttribute("divine_ability") or 0
end

function Item.isEmptySlotItem(self)
  if self:getId() == 0 then return end
  return self:getCustomAttribute("slot_item") and true or false
end

function Item.setEmptySlotItem(self, slot_item)
  if self:getId() == 0 then return end
  return self:setCustomAttribute("slot_item", slot_item)
end

function Item.getEmptySlotItem(self)
  if self:getId() == 0 then return end
  return self:getCustomAttribute("slot_item") and self:getCustomAttribute("slot_item") or 0
end
-- champion
function Item.setChampionItem(self, champion_item)
  if self:getId() == 0 then return end
  return self:setCustomAttribute("champion_item", champion_item)
end

function Item.getChampionItem(self)
  if self:getId() == 0 then return end
  return self:getCustomAttribute("champion_item") and self:getCustomAttribute("champion_item") or 0
end

function Item.isChampionItem(self)
  if self:getId() == 0 then return end
  return self:getCustomAttribute("champion_item") and true or false
end
-- champion
-- worldboss
function Item.setWorldBoss(self, world_boss_item)
  if self:getId() == 0 then return end
  return self:setCustomAttribute("world_boss_item", world_boss_item)
end

function Item.getWorldBoss(self)
  if self:getId() == 0 then return end
  return self:getCustomAttribute("world_boss_item") and self:getCustomAttribute("world_boss_item") or 0
end

function Item.isWorldBoss(self)
  if self:getId() == 0 then return end
  return self:getCustomAttribute("world_boss_item") and true or false
end
-- worldboss

function Item.isEpicHeroicMax(self)
  if self:getId() == 0 then return end
  return self:getCustomAttribute("epicheroicmax") and true or false
end

function Item.setEpicHeroicMax(self, epicheroicmax)
  if self:getId() == 0 then return end
  return self:setCustomAttribute("epicheroicmax", epicheroicmax)
end

function Item.getEpicHeroicMax(self)
  if self:getId() == 0 then return end
  return self:getCustomAttribute("epicheroicmax") and self:getCustomAttribute("epicheroicmax") or 0
end

function Item.isQuestItem(self)
  if self:getId() == 0 then return end
  return self:getCustomAttribute("questitem") and true or false
end

function Item.setQuestItem(self, questitem)
  if self:getId() == 0 then return end
  return self:setCustomAttribute("questitem", questitem)
end

function Item.getQuestItem(self)
  if self:getId() == 0 then return end
  return self:getCustomAttribute("questitem") and self:getCustomAttribute("questitem") or 0
end

function Item.isHighRarityItem(self)
  if self:getId() == 0 then return end
  return self:getCustomAttribute("high_rarity_item") and true or false
end

function Item.setHighRarityItem(self, high_rarity_item)
  if self:getId() == 0 then return end
  return self:setCustomAttribute("high_rarity_item", high_rarity_item)
end

function Item.getHighRarityItem(self)
  if self:getId() == 0 then return end
  return self:getCustomAttribute("high_rarity_item") and self:getCustomAttribute("high_rarity_item") or 0
end

---																									-----------------------

function Item.getAncient(self)
  if self:getId() == 0 then return end
  return self:getCustomAttribute("ancient") and self:getCustomAttribute("ancient") or nil
end

function Item.isAncient(self)
  if self:getId() == 0 then return end
  return self:getCustomAttribute("ancient") and true or false
end

function Item.getAncientName(self)
  return US_UNIQUES[self:getAncient()].name
end

-- 																			Ancient

-- 																		Primal Ancient
function Item.setPrimalAncient(self, primal_ancientId)
  if self:getId() == 0 then return end
  self:setCustomAttribute("primal_ancient", primal_ancientId)
  local primal_ancient = US_UNIQUES[primal_ancientId]
  if primal_ancient then
    for i = 1, #primal_ancient.attributes do
      local attrId = primal_ancient.attributes[i]
      local attr = US_ENCHANTMENTS[attrId]
      local value = attr.VALUES_PER_LEVEL and
          math.random(math.ceil(self:getItemLevel() * attr.VALUES_PER_LEVEL),
            math.ceil(self:getItemLevel() * attr.VALUES_PER_LEVEL))
      self:setCustomAttribute("Slot" .. self:getLastSlot() + 1, attrId .. "|" .. value)
    end
  end
end

function Item.getPrimal_Ancient(self)
  if self:getId() == 0 then return end
  return self:getCustomAttribute("primal_ancient") and self:getCustomAttribute("primal_ancient") or nil
end

function Item.isPrimal_Ancient(self)
  if self:getId() == 0 then return end
  return self:getCustomAttribute("primal_ancient") and true or false
end

function Item.getPrimal_AncientName(self)
  return US_UNIQUES[self:getPrimal_Ancient()].name
end

-- 																	Primal Ancient

-- 																		Eternal
function Item.setEternal(self, eternalId)
  if self:getId() == 0 then return end
  self:setCustomAttribute("eternal", eternalId)
  local eternal = US_UNIQUES[eternalId]
  if eternal then
    for i = 1, #eternal.attributes do
      local attrId = eternal.attributes[i]
      local attr = US_ENCHANTMENTS[attrId]
      local value = attr.VALUES_PER_LEVEL and
          math.random(math.ceil(self:getItemLevel() * attr.VALUES_PER_LEVEL),
            math.ceil(self:getItemLevel() * attr.VALUES_PER_LEVEL))
      self:setCustomAttribute("Slot" .. self:getLastSlot() + 1, attrId .. "|" .. value)
    end
  end
end

function Item.getEternal(self)
  if self:getId() == 0 then return end
  return self:getCustomAttribute("eternal") and self:getCustomAttribute("eternal") or nil
end

function Item.isEternal(self)
  if self:getId() == 0 then return end
  return self:getCustomAttribute("eternal") and true or false
end

function Item.getEternalName(self)
  return US_UNIQUES[self:getEternal()].name
end

-- 																		Eternal

function Item.setMemory(self, value)
  self:setCustomAttribute("memory", value)
end

function Item.hasMemory(self)
  if self:getId() == 0 then return end
  return self:getCustomAttribute("memory")
end

function Item.setLimitless(self, value)
  self:setCustomAttribute("limitless", value)
end

function Item.isLimitless(self)
  if self:getId() == 0 then return end
  return self:getCustomAttribute("limitless")
end

function Item.setMirrored(self, value)
  self:setCustomAttribute("mirrored", value)
end

function Item.getTier(self)
  if self:getId() == 0 then return end
  return self:getCustomAttribute("tier") and self:getCustomAttribute("tier") or 0
end

function Item.setTier(self, value)
  self:setCustomAttribute("tier", value)
end

function Item.isMirrored(self)
  if self:getId() == 0 then return end
  return self:getCustomAttribute("mirrored")
end

function Item.isLocked(self)
  if self:getId() == 0 then return end
  return self:getCustomAttribute("locked") and self:getCustomAttribute("locked") == 1
end

function Item.isLOOL(self)
  if self:getId() == 0 then return end
  return self:getCustomAttribute("lool")
end

function Item.setLOOL(self, value)
  self:setCustomAttribute("lool", value)
end

function Item.isQuality(self)
  if self:getId() == 0 then return end
  return self:getCustomAttribute("quality") or 0
end

function Item.getQuality(self)
  return self:isQuality()
end

function Item.setQuality(self, value)
  self:setCustomAttribute("quality", value)
end

function Item.isPA(self)
  if self:getId() == 0 then return end
  return self:getCustomAttribute("PA") and self:getCustomAttribute("PA") or 0
end

function Item.setPA(self, value)
  self:setCustomAttribute("PA", value)
end

function Item.getPALevel(self)
  if self:getId() == 0 then return end
  return self:getCustomAttribute("PA_Level") or 0
end

function Item.bindItem(self)
  if self:getId() == 0 then return end
  return self:getCustomAttribute("bind") or 0
end

function Item.setbindItem(self, value)
  if self:getId() == 0 then return end
  self:setCustomAttribute("bind", value)
end

function Item.bindCharacterItem(self)
  if self:getId() == 0 then return end
  return self:getCustomAttribute("bind_character") or 0
end

function Item.setbindCharacterItem(self, value)
  if self:getId() == 0 then return end
  self:setCustomAttribute("bind_character", value)
end

function Item.getItemType(self)
  local itemType = self:getType()
  local slot = itemType:getSlotPosition() - SLOTP_LEFT - SLOTP_RIGHT

  local weaponType = itemType:getWeaponType()
  if weaponType > 0 then
    if weaponType == WEAPON_DISTANCE and formatItemTypeUPGRADE(itemType) == "Crossbow" then
      return US_ITEM_TYPES.WEAPON_CROSSBOW
    end
    if weaponType == WEAPON_DISTANCE and formatItemTypeUPGRADE(itemType) == "Bow" then
      return US_ITEM_TYPES.WEAPON_BOW
    end
    if weaponType == WEAPON_DISTANCE and formatItemTypeUPGRADE(itemType) == "Tknife" then
      return US_ITEM_TYPES.WEAPON_KNIFE
    end
    if weaponType == WEAPON_SHIELD then
      return US_ITEM_TYPES.SHIELD
    end
    if weaponType == WEAPON_WAND then
      return US_ITEM_TYPES.WEAPON_WAND
    end
    if weaponType == WEAPON_SWORD then
      return US_ITEM_TYPES.WEAPON_SWORD
    end
    if weaponType == WEAPON_CLUB then
      return US_ITEM_TYPES.WEAPON_CLUB
    end
    if weaponType == WEAPON_AXE then
      return US_ITEM_TYPES.WEAPON_AXE
    end
  else
    if slot == SLOTP_HEAD then
      return US_ITEM_TYPES.HELMET
    end
    if slot == SLOTP_ARMOR then
      return US_ITEM_TYPES.ARMOR
    end
    if slot == SLOTP_LEGS then
      return US_ITEM_TYPES.LEGS
    end
    if slot == SLOTP_FEET then
      return US_ITEM_TYPES.BOOTS
    end
    if slot == SLOTP_NECKLACE then
      return US_ITEM_TYPES.NECKLACE
    end
    if slot == SLOTP_GLOVES then
      return US_ITEM_TYPES.GLOVES
    end
    if slot == SLOTP_RING2 then
      return US_ITEM_TYPES.RING
    end
    if slot == SLOTP_POTION1 then
      return US_ITEM_TYPES.POTION
    end
    if slot == SLOTP_RING then
      return US_ITEM_TYPES.RING
    end
  end

  local forcedType = self:getCustomAttribute("forceType")
  if forcedType then
    return forcedType
  end

  if self:getLootIndex() == 4 then
    return US_ITEM_TYPES.RELICT_ANY
  end

  return US_ITEM_TYPES.ALL
end

function Item.isWeapon(self)
  local itemType = self:getType()
  local slot = itemType:getSlotPosition() - SLOTP_LEFT - SLOTP_RIGHT
  local weaponType = itemType:getWeaponType()
  local weapon = false
  if weaponType > 0 then
    if weaponType == WEAPON_DISTANCE and formatItemTypeUPGRADE(itemType) == "Crossbow" then
      weapon = true
    end
    if weaponType == WEAPON_DISTANCE and formatItemTypeUPGRADE(itemType) == "Bow" or formatItemTypeUPGRADE(itemType) == "Tknife" then
      weapon = true
    end
    if weaponType == WEAPON_DISTANCE then
      weapon = true
    end
    if weaponType == WEAPON_WAND then
      weapon = true
    end
    if isInArray({ WEAPON_SWORD, WEAPON_CLUB, WEAPON_AXE }, weaponType) then
      weapon = true
    end
  end
  return weapon
end

function Item.isSet(self)
  local itemType = self:getType()
  local slot = itemType:getSlotPosition() - SLOTP_LEFT - SLOTP_RIGHT
  local weaponType = itemType:getWeaponType()
  local weapon = false
  if weaponType > 0 then
    if weaponType == WEAPON_SHIELD then
      weapon = true
    end
  else
    if slot == SLOTP_HEAD then
      weapon = true
    end
    if slot == SLOTP_ARMOR then
      weapon = true
    end
    if slot == SLOTP_LEGS then
      weapon = true
    end
    if slot == SLOTP_FEET then
      weapon = true
    end
  end
  return weapon
end

function Item.isAccessories(self)
  local itemType = self:getType()
  local slot = itemType:getSlotPosition() - SLOTP_LEFT - SLOTP_RIGHT
  local weaponType = itemType:getWeaponType()
  local weapon = false
  if weaponType > 0 then
    if weaponType == WEAPON_DISTANCE and formatItemTypeUPGRADE(itemType) == "Crossbow" then
      weapon = true
    end
    if weaponType == WEAPON_DISTANCE and formatItemTypeUPGRADE(itemType) == "Bow" or formatItemTypeUPGRADE(itemType) == "Tknife" then
      weapon = true
    end
    if weaponType == WEAPON_DISTANCE then
      weapon = true
    end
    if weaponType == WEAPON_WAND then
      weapon = true
    end
    if weaponType == WEAPON_AMMO then
      weapon = true
    end
    if isInArray({ WEAPON_SWORD, WEAPON_CLUB, WEAPON_AXE }, weaponType) then
      weapon = true
    end
  else
    if slot == SLOTP_NECKLACE then
      return US_ITEM_TYPES.NECKLACE
    end
    if slot == SLOTP_GLOVES then
      return US_ITEM_TYPES.GLOVES
    end
    if slot == SLOTP_RING2 then
      return US_ITEM_TYPES.RING
    end
    if slot == SLOTP_POTION1 then
      return US_ITEM_TYPES.POTION
    end
    if slot == SLOTP_RING then
      return US_ITEM_TYPES.RING
    end
  end
  return weapon
end

function Item.setRarity(self, rarity)
  self:setCustomAttribute("rarity", rarity)
end

function Item.getRarity(self)
  if self:getId() == 0 then return end
  return self:getCustomAttribute("rarity") and US_CONFIG.RARITY[self:getCustomAttribute("rarity")] or US_CONFIG.RARITY[COMMON]
end

function Item.getRarityId(self)
  if self:getId() == 0 then return end
  return self:getCustomAttribute("rarity") and self:getCustomAttribute("rarity") or 0
end

function Item.getMaxAttributes(self)
  if self:isUnique() then
    return US_UNIQUES[self:getUnique()].attr and #US_UNIQUES[self:getUnique()].attr or 0
  end

  return self:getCustomAttribute("slots") or 0
end

function Item.countModifiers(self)
  if self:getId() == 0 then return end

  local count = 0
  local bonuses = self:getBonusAttributes()
  if not bonuses then
    return count
  end

  return #bonuses
end

function Item.countDungModifiers(self)
  if self:getId() == 0 then return end

  local count = 0
  local bonuses = self:getDungeonModifiers()
  if not bonuses then
    return count
  end

  return #bonuses
end

function Item.correctModifiersPlaces(self, value)
  local slots = self:getMaxAttributes()
  if slots and slots > value then
    local bonusAttributes = self:getBonusAttributes()
    local newAttributes = {}
    if bonusAttributes then
      for i = 1, #bonusAttributes do
        local attr = bonusAttributes[i]
        if attr then
          table.insert(newAttributes, attr)
        end
      end

      for i = 1, 6 do
        self:setAttributeValue(i, nil)
      end
    end

    for i = 1, #newAttributes do
      local attr = newAttributes[i]
      self:setAttributeValue(i, attr[1] .. "|" .. attr[2] .. "|" .. attr[3])
    end
  end
end

function Item.correctModifiersPlacesDungeon(self, value)
  local slots = self:getMaxAttributes()
  if slots and slots > value then
    local bonusAttributes = self:getDungeonModifiers()
    local newAttributes = {}
    if bonusAttributes then
      for i = 1, #bonusAttributes do
        local attr = bonusAttributes[i]
        if attr then
          table.insert(newAttributes, attr)
        end
      end

      for i = 1, 6 do
        self:setDungeonModifier(i, nil)
      end
    end

    for i = 1, #newAttributes do
      local attr = newAttributes[i]
      self:setDungeonModifier(i, attr[1] .. "|" .. attr[2] .. "|" .. attr[3])
    end
  end
end

function Item.setModifiersSlots(self, value)
  if self:getId() == 0 then return end
  if keysToDungeon[self:getId()] then
    self:correctModifiersPlacesDungeon(value)
  else
    self:correctModifiersPlaces(value)
  end
  self:setCustomAttribute("slots", value)
end

-- tar Weapons nad Shield - 2
-- golden ring, ring, helmet - 3
-- peaks boots, necklace, potions - 3
-- iced armor, legs, gloves - 3
function ItemType.isTarEq(self)
  if self:getId() == 0 then return end
  if self:isStackable() or self:getTransformEquipId() > 0 or self:getDecayId() > 0 or self:getDestroyId() > 0 or self:getCharges() > 0 then
    return false
  end
  local weaponType = self:getWeaponType()
  if weaponType > 0 then
    if weaponType == WEAPON_AMMO then
      return true
    end
    if
        weaponType == WEAPON_SHIELD or weaponType == WEAPON_DISTANCE or weaponType == WEAPON_WAND or isInArray({ WEAPON_SWORD, WEAPON_CLUB, WEAPON_AXE }, weaponType)
    then
      return true
    end
  end
  return false
end

function ItemType.isGoldenEq(self)
  if self:getId() == 0 then return end
  if self:isStackable() or self:getTransformEquipId() > 0 or self:getDecayId() > 0 or self:getDestroyId() > 0 or self:getCharges() > 0 then
    return false
  end
  local slot = self:getSlotPosition() - SLOTP_LEFT - SLOTP_RIGHT
  if slot == SLOTP_HEAD or slot == SLOTP_RING or slot == SLOTP_RING2 then
    return true
  end
  return false
end

function ItemType.isPeaksEq(self)
  if self:getId() == 0 then return end
  if self:isStackable() or self:getTransformEquipId() > 0 or self:getDecayId() > 0 or self:getDestroyId() > 0 or self:getCharges() > 0 then
    return false
  end
  local slot = self:getSlotPosition() - SLOTP_LEFT - SLOTP_RIGHT
  if slot == SLOTP_FEET or slot == SLOTP_NECKLACE or slot == SLOTP_POTION1 then
    return true
  end
  return false
end

function ItemType.isIcedEq(self)
  if self:getId() == 0 then return end
  if self:isStackable() or self:getTransformEquipId() > 0 or self:getDecayId() > 0 or self:getDestroyId() > 0 or self:getCharges() > 0 then
    return false
  end
  local slot = self:getSlotPosition() - SLOTP_LEFT - SLOTP_RIGHT
  if slot == SLOTP_ARMOR or slot == SLOTP_LEGS or slot == SLOTP_GLOVES then
    return true
  end
  return false
end

function ItemType.isArmors(self)
  if self:getId() == 0 then return end
  if self:isStackable() or self:getTransformEquipId() > 0 or self:getDecayId() > 0 or self:getDestroyId() > 0 or self:getCharges() > 0 then
    return false
  end
  local slot = self:getSlotPosition() - SLOTP_LEFT - SLOTP_RIGHT

  local weaponType = self:getWeaponType()
  if weaponType > 0 then
    if weaponType == WEAPON_AMMO then
      return true
    end
    if
        weaponType == WEAPON_SHIELD or weaponType == WEAPON_DISTANCE or weaponType == WEAPON_WAND or
        isInArray({ WEAPON_SWORD, WEAPON_CLUB, WEAPON_AXE }, weaponType)
    then
      return true
    end
  else
    if slot == SLOTP_HEAD or slot == SLOTP_ARMOR or slot == SLOTP_LEGS or slot == SLOTP_FEET or slot == SLOTP_NECKLACE or slot == SLOTP_RING or slot == SLOTP_GLOVES or slot == SLOTP_RING2 or slot == SLOTP_POTION1 then
      return true
    end
  end
  return false
end

function ItemType.isUpgradable(self)
  if self:getId() == 0 then return end
  if self:isStackable() or self:getTransformEquipId() > 0 or self:getDecayId() > 0 or self:getDestroyId() > 0 or self:getCharges() > 0 then
    return false
  end
  local slot = self:getSlotPosition() - SLOTP_LEFT - SLOTP_RIGHT

  local weaponType = self:getWeaponType()
  if weaponType > 0 then
    if weaponType == WEAPON_AMMO then
      return true
    end
    if
        weaponType == WEAPON_SHIELD or weaponType == WEAPON_DISTANCE or weaponType == WEAPON_WAND or
        isInArray({ WEAPON_SWORD, WEAPON_CLUB, WEAPON_AXE }, weaponType)
    then
      return true
    end
    --   if weaponType == WEAPON_AMMO then return true end
  else
    if slot == SLOTP_HEAD or slot == SLOTP_ARMOR or slot == SLOTP_LEGS or slot == SLOTP_FEET or slot == SLOTP_NECKLACE or slot == SLOTP_RING or slot == SLOTP_GLOVES or slot == SLOTP_RING2 or slot == SLOTP_POTION1 or slot == SLOTP_SPELL1 or slot == SLOTP_SUPPORT1_1 then
      return true
    end
  end
  return false
end

function ItemType.isMeleeWeapon(self)
  local weaponType = self:getWeaponType()
  if weaponType > 0 then
    if isInArray({ WEAPON_SWORD, WEAPON_CLUB, WEAPON_AXE }, weaponType) then
      return true
    end
  end
  return false
end

function ItemType.canHaveItemLevel(self)
  if self:isStackable() or self:getTransformEquipId() > 0 or self:getDecayId() > 0 or self:getDestroyId() > 0 or self:getCharges() > 0 then
    return false
  end
  local slot = self:getSlotPosition() - SLOTP_LEFT - SLOTP_RIGHT

  local weaponType = self:getWeaponType()
  if weaponType > 0 then
    if weaponType == WEAPON_AMMO then
      return true
    end
    if
        weaponType == WEAPON_SHIELD or weaponType == WEAPON_DISTANCE or weaponType == WEAPON_WAND or
        isInArray({ WEAPON_SWORD, WEAPON_CLUB, WEAPON_AXE }, weaponType)
    then
      return true
    end
    --    if weaponType == WEAPON_AMMO then return true end
  else
    if slot == SLOTP_HEAD or slot == SLOTP_ARMOR or slot == SLOTP_LEGS or slot == SLOTP_FEET or slot == SLOTP_NECKLACE or slot == SLOTP_RING or slot == SLOTP_GLOVES or slot == SLOTP_RING2 or slot == SLOTP_POTION1 or slot == SLOTP_SPELL1 then
      return true
    end
  end
  return false
end

function MonsterType.calculateItemLevel(self)
  local level = 1
  local monsterValue = self:getMaxHealth() + self:getExperience()
  level = math.ceil(math.pow(monsterValue, 0.381))
  return math.max(1, level)
end

function Player.getNextSubId(self, itemSlot, attrSlot)
  local cid = self:getId()
  if not US_SUBID[cid] then
    US_SUBID[cid] = { current = 0 }
  end

  local subId = US_SUBID[cid]
  subId.current = subId.current + 1

  if not subId[itemSlot] then
    subId[itemSlot] = {}
  end

  subId[itemSlot][attrSlot] = subId.current

  return subId.current
end

function Player:getItemLevel()
  local iLvl = 0
  for slot = CONST_SLOT_HEAD, CONST_SLOT_POTION2 do
    local item = self:getSlotItem(slot)
    if item then
      local itemType = item:getType()
      if itemType:usesSlot(slot) then
        iLvl = iLvl + item:getItemLevel()
      end
    end
  end
  return iLvl
end

function Player:getItemLevelTotal()
  local iLvl = 0
  for slot = CONST_SLOT_HEAD, CONST_SLOT_POTION2 do
    local item = self:getSlotItem(slot)
    if item then
      local itemType = item:getType()
      if itemType:usesSlot(slot) then
        local slotsMax = item:getMaxAttributes()
        local totalAtrBonus = 0
        for i = 1, slotsMax do
          local enchant = item:getBonusAttribute(i)
          if enchant and #enchant > 0 then
            if enchant[1] == 1 or enchant[1] == 2 or enchant[1] == 23 or enchant[1] == 24 then
              enchant[2] = math.ceil(enchant[2] / 100)
            end
            totalAtrBonus = totalAtrBonus + enchant[2]
          end
        end
        iLvl = iLvl + item:getItemLevel() + totalAtrBonus
      end
    end
  end
  return iLvl
end

function exoriEffect(center, effect)
  for i = -1, 1 do
      local top = Position(center.x + i, center.y - 1, center.z)
      local middle = Position(center.x + i, center.y, center.z)
      local bottom = Position(center.x + i, center.y + 1, center.z)
      top:sendMagicEffect(effect)
      middle:sendMagicEffect(effect)
      bottom:sendMagicEffect(effect)
  end
end

function exoriCreateItem(center, itemID, duration, damage, monster)
  for i = -1, 1 do
      local top = Position(center.x + i, center.y - 1, center.z)
      local middle = Position(center.x + i, center.y, center.z)
      local bottom = Position(center.x + i, center.y + 1, center.z)
      if isBadTileCreature(top) then
      else
          local field1 = Game.createItem(itemID, 1, top)
          field1:setActionId(27541)
          field1:setCustomAttribute("plagued", damage)
          field1:setCustomAttribute("monsterId", monster)
          field1:setAttribute(ITEM_ATTRIBUTE_DURATION, duration)
      end

      if isBadTileCreature(middle) then
      else
          local field2 = Game.createItem(itemID, 1, middle)
          field2:setActionId(27541)
          field2:setCustomAttribute("plagued", damage)
          field2:setCustomAttribute("monsterId", monster)
          field2:setAttribute(ITEM_ATTRIBUTE_DURATION, duration)
      end

      if isBadTileCreature(bottom) then
      else
          local field3 = Game.createItem(itemID, 1, bottom)
          field3:setActionId(27541)
          field3:setCustomAttribute("plagued", damage)
          field3:setCustomAttribute("monsterId", monster)
          field3:setAttribute(ITEM_ATTRIBUTE_DURATION, duration)
      end
  end
end

function fieldCreateItem(center, itemID, duration)
  local position = Position(center.x, center.y, center.z)
  if isBadTileCreature(position) then
  else
      local field = Game.createItem(itemID, 1, position)
      field:setActionId(27541)
      field:setAttribute(ITEM_ATTRIBUTE_DURATION, duration)
  end
end

function electroShoced(center, itemID, duration, damage, monster)
  for i = -1, 1 do
      local r = math.random(-1, 1)
      if math.random(1, 100) <= 70 then
          local top = Position(center.x + i + r, center.y - i + r, center.z)
          local middle = Position(center.x + i + r, center.y + r, center.z)
          local bottom = Position(center.x + i + r, center.y + i + r, center.z)
          if isBadTileCreature(top) then
          else
              local field1 = Game.createItem(itemID, 1, top)
              if field1 then
                field1:setActionId(27542)
                field1:setCustomAttribute("plagued", damage)
                field1:setCustomAttribute("monsterId", monster)
                field1:setAttribute(ITEM_ATTRIBUTE_DURATION, duration)
              end
          end
          if isBadTileCreature(bottom) then
          else
              local field2 = Game.createItem(itemID, 1, middle)
              if field2 then
                field2:setActionId(27542)
                field2:setCustomAttribute("plagued", damage)
                field2:setCustomAttribute("monsterId", monster)
                field2:setAttribute(ITEM_ATTRIBUTE_DURATION, duration)
              end
          end
          if isBadTileCreature(bottom) then
          else
              local field3 = Game.createItem(itemID, 1, bottom)
              if field3 then
                field3:setActionId(27542)
                field3:setCustomAttribute("plagued", damage)
                field3:setCustomAttribute("monsterId", monster)
                field3:setAttribute(ITEM_ATTRIBUTE_DURATION, duration)
              end
          end
      end
  end
end

function posBlocking(pos)
  local tile = Tile(pos)
  if tile then
      local thing = tile:getTopVisibleThing(player)
      if thing then
          local thingID = thing:getId()
          if thingID ~= 0 then
              local wall = ItemType(thingID):isBlocking()
              if wall or thing:isMonster() or thing:isPlayer() then
                  wall = true
              else
                  wall = false
              end
          end
      end
  end
  return wall
end

function wallerWalltopDown(center, itemID, effect, duration)
  local middle = Position(center.x, center.y, center.z)
  local middleT = Position(center.x + 1, center.y, center.z)
  local middleD = Position(center.x - 1, center.y, center.z)
  if isBadTile(middle) then
  else
      local wall1 = Game.createItem(3491, 1, middle)
      wall1:setAttribute(ITEM_ATTRIBUTE_DURATION, duration)
      middle:sendMagicEffect(effect)
  end
  if isBadTile(middleT) then
  else
      local wall2 = Game.createItem(3494, 1, middleT)
      wall2:setAttribute(ITEM_ATTRIBUTE_DURATION, duration)
      middleT:sendMagicEffect(effect)
  end
  if isBadTile(middleD) then
  else
      local wall3 = Game.createItem(3493, 1, middleD)
      wall3:setAttribute(ITEM_ATTRIBUTE_DURATION, duration)
      middleD:sendMagicEffect(effect)
  end
  return true
end

-- player:addItem(itemId[, count = 1[, canDropOnMap = true[, subType = 1[, slot = CONST_SLOT_WHEREEVER]]]])
function wallerWallleftRight(center, itemID, effect, duration)
  local middle = Position(center.x, center.y, center.z)
  local middleT = Position(center.x, center.y + 1, center.z)
  local middleD = Position(center.x, center.y - 1, center.z)
  if isBadTile(middle) then
  else
      local wall1 = Game.createItem(3485, 1, middle)
      wall1:setAttribute(ITEM_ATTRIBUTE_DURATION, duration)
      middle:sendMagicEffect(effect)
  end
  if isBadTile(middleT) then
  else
      local wall2 = Game.createItem(3487, 1, middleT)
      wall2:setAttribute(ITEM_ATTRIBUTE_DURATION, duration)
      middleT:sendMagicEffect(effect)
  end
  if isBadTile(middleD) then
  else
      local wall3 = Game.createItem(3488, 1, middleD)
      wall3:setAttribute(ITEM_ATTRIBUTE_DURATION, duration)
      middleD:sendMagicEffect(effect)
  end
  return true
end

function mushroomHealing(center, itemID, duration)
  for i = 1, 5 do
      local top = Position(center.x + math.random(-1, 1), center.y - math.random(-1, 1), center.z)
      if isBadTile(top) then
      else
          local field1 = Game.createItem(itemID, 1, top)
          if field1 ~= nil then
              field1:setActionId(27551)
              field1:setAttribute(ITEM_ATTRIBUTE_DURATION, duration)
          end
      end
  end
end

function mine(center, itemID, duration, actionID, count, creatureID)
  if creatureID ~= 0 then
      for i = 1, count do
          local top = Position(center.x + math.random(-1, 1), center.y - math.random(-1, 1), center.z)
          if isBadTile(top) then
          else
              local field1 = Game.createItem(itemID, 1, top)
              if field1 ~= nil then
                  field1:setActionId(actionID)
                  field1:setCustomAttribute("creatureSpecialID", creatureID)
                  field1:setAttribute(ITEM_ATTRIBUTE_DURATION, duration)
              end
          end
      end
  end
end

function Item.addDungeonModifier(self, slot, attr, value, tier)
  if self:getId() == 0 then return end
  self:setCustomAttribute("Dung" .. slot, attr .. "|" .. value .. "|" .. tier)
end

function Item.getDungeonModifier(self, slot)
  if self:getId() == 0 then return end
  local bonuses = self:getCustomAttribute("Dung" .. slot)
  if bonuses then
    local data = {}
    for bonus in bonuses:gmatch("([^|]+)") do
      data[#data + 1] = tonumber(bonus)
    end
    return data
  end

  return nil
end

function Item.setDungeonModifier(self, slot, value)
  if self:getId() == 0 then return end
  if not value then
    self:removeCustomAttribute("Dung"..slot)
    return
  end

  self:setCustomAttribute("Dung" .. slot, value)
end

function Item.getDungeonModifiers(self)
  if self:getId() == 0 then return end
  local data = {}
  for i = 1, self:getMaxAttributes() do
    
    local bonuses = self:getCustomAttribute("Dung" .. i)
    if bonuses then
       local t = {}
       for bonus in bonuses:gmatch("([^|]+)") do
         t[#t + 1] = tonumber(bonus)
       end
       t[4] = i
       data[#data + 1] = t
      end
  end

  return #data > 0 and data or nil
end

function Item:randomizeDungeonAttribute(attr)
  local monsterLevel = self:getItemLevel()
  local currentAttr = {}
  local tempCurrentAttr = self:getDungeonModifiers()
  local newAttr = nil
  local specialModifiers = {12, 13, 14, 15}
  local specialUsed = false

  if tempCurrentAttr then
    for i = 1, #tempCurrentAttr do
      local modId = tempCurrentAttr[i][1]
      currentAttr[modId] = true
      if isInArray(specialModifiers, modId) then
        specialUsed = true
      end
    end
  end

  local attributesToCheck = table.copy(US_DUNGEONS_MODIFIERS)
  local totalAttributes = #attributesToCheck

  while (totalAttributes > 0) do
    totalAttributes = #attributesToCheck
    local randIndex = math.random(1, totalAttributes)
    local enchant = attributesToCheck[randIndex]
    if not enchant then
      break
    end

    local attrId = randIndex
    local noChance = true
    if enchant.chance and math.random(1, 100) <= enchant.chance then
      noChance = false
    end

    local levelRequirement = true
    if enchant.minLevel then
      levelRequirement = monsterLevel >= enchant.minLevel
    end
    local isSpecial = isInArray(specialModifiers, attrId)

    if (not currentAttr[attrId]) and levelRequirement and noChance then
      if not (isSpecial and specialUsed) then
        newAttr = attrId
        break
      end
    end

    table.remove(attributesToCheck, randIndex)
  end

  if newAttr == nil then
    print("randomizeDungeonAttribute | no attribute found for this item | UID: " .. self:getRealUID())
  end

  return newAttr
end


function generateRandomDungeonAttributeValue(attr, tier)
  local enchant = US_DUNGEONS_MODIFIERS[attr]
  if not enchant then
    print("missing dungeon attr: " .. attr)
    return 1
  end

  if enchant.noValue then
    return 1
  end

  local value = enchant.TIER[tier]
  return math.random(value[1], value[2])
end

function Item:randomizeAttribute()
  local newAttr = nil
  local itemType = self:getItemType()
  local tempCurrentAttr = self:getBonusAttributes()
  local itemLevel = self:getItemLevel()
  local currentAttr = {}

  -- aktualne mody itemu
  if tempCurrentAttr then
    for i = 1, #tempCurrentAttr do
      currentAttr[tempCurrentAttr[i][1]] = true
    end
  end

  -- >>> DEFINICJA GRUP (DODAJESZ KOLEJNE BEZ ZMIAN W LOGICE)
  local GROUPS = {
    damageMods = { -- Physical 11, Elemental 12 and Duality 198
      [11] = true, [12] = true, [196] = true,
    },
    AddedMods = { -- Physical 70, Elemental 69 and Duality 68
      [70] = true, [69] = true, [68] = true,
    },
    penMods = { -- Physical Penetration 31, Elemental Penetration 122 and Duality Penetration 198
      [31] = true, [122] = true, [198] = true,
    },
    chanceMods = { -- Bleed Chance 21, Ignite Chance 28, Poison Chance 32, Chill Chance 37, Shock Chance 41, Harvest Chance 42, Suppression Chance 45
      [21] = true, [28] = true, [32] = true, [37] = true, [41] = true, [42] = true, [45] = true,
    },
    skillMods = { -- Intelligence 3, Strength 4, Dexterity 5
      [3] = true, [4] = true, [5] = true,
    },
    spellsLevelMods = { -- Elemental Spells 228, Physical Spell 229, Duality 230, 107 All Spells, 262 Basic Spells
      [228] = true, [229] = true, [230] = true, [107] = true, [262] = true,
    },
  }
  -- <<< KONIEC DEFINICJI GRUP

  -- sprawdzamy, które grupy item już posiada
  local groupUsed = {}
  for id, _ in pairs(currentAttr) do
    for groupName, group in pairs(GROUPS) do
      if group[id] then
        groupUsed[groupName] = true
      end
    end
  end

  local attributes = US_ENCHANTMENTS_ITEMTYPE[itemType]
  local candidates = {}

  for _, enchant in ipairs(attributes) do
    local chanceOk = (not enchant.chance) or (math.random(1, 100) <= enchant.chance)
    local levelOk = (not enchant.minLevel) or (itemLevel >= enchant.minLevel)
    local notDuplicate = not currentAttr[enchant.id]

    -- sprawdzenie blokady grupowej
    local groupOk = true
    for groupName, group in pairs(GROUPS) do
      if group[enchant.id] and groupUsed[groupName] then
        groupOk = false
        break
      end
    end

    if chanceOk and levelOk and notDuplicate and groupOk then
      table.insert(candidates, enchant.id)
    end
  end

  if #candidates > 0 then
    newAttr = candidates[math.random(1, #candidates)]
  else
    print("randomizeAttribute | no attribute found for this item | UID: " .. self:getRealUID())
  end

  return newAttr
end


function generateRandomAttributeValue(attr, tier, item, lastValue, perfect)
  local affix = 1
  if not REDUCTION_ATTR_VALUES[attr] then
    return affix
  end
  local valueMin = REDUCTION_ATTR_VALUES[attr][tier][1]
  local valueMax = REDUCTION_ATTR_VALUES[attr][tier][2]
  if perfect then
    valueMin = valueMax
  end
  affix = math.random(valueMin, valueMax)
  if lastValue then
    if lastValue > affix then
      affix = lastValue
    end
  end
  if affix <= 0 then affix = 1 end
  local slot = ItemType(item:getId()):getSlotPosition()
  if (slot == 1072) then
    affix = math.floor(affix * TWO_HANDED_MULTIPLIER)
  end

  return affix
end

function getTierAttribute(item, multiplier)
  local tier = 1
  if not multiplier then multiplier = 0 end
  local itemTier = item:getItemLevel() -- self:getTier()
  for i = 1, #TIER_AFFIXES do
    if itemTier >= TIER_AFFIXES[i][3] then
      local rand = math.random(100000)
      local tierBetter = TIER_AFFIXES[i][1] + (TIER_AFFIXES[i][1] * multiplier)
      if rand <= tierBetter then
        local min = 1
        if itemTier >= 70 then
          min = 3
        elseif itemTier >= 41 then
          min = 2
        end
        tier = math.random(min, math.max(TIER_AFFIXES[i][2], min))
        break
      end
    end
  end
  local exaBetter = EXALTED_ITEMS[2]
  local exaBetter7 = EXALTED_ITEMS[3]
  if itemTier >= EXALTED_ITEMS[1] and math.random(100) <= exaBetter then
    if math.random(100) <= exaBetter7 then
      tier = 7
    else
      tier = 6
    end
  end
  return tier
end

function Item.getBonusFromCrystals(self)
  if self:getId() == 0 then return end
  local data = {}
  for i = 1, self:getCrystalSlots() do
    local bonuses = self:getCustomAttribute("Cry" .. i)
    if bonuses then
      local t = {}
      for bonus in bonuses:gmatch("([^|]+)") do
        t[#t + 1] = tonumber(bonus)
      end
      t[5] = i 
      data[#data + 1] = t
    end
  end

  return #data > 0 and data or nil
end

function Item.getBonusFromCrystal(self, slot)
  if self:getId() == 0 then return end
  local data = {}
  local bonuses = self:getCustomAttribute("Cry" .. slot)
  if bonuses then
    for bonus in bonuses:gmatch("([^|]+)") do
      data[#data + 1] = tonumber(bonus)
    end
  end

  return #data > 0 and data or nil
end


function Item.getCrystalSlots(self)
  if self:getId() == 0 then return end

  return self:getCustomAttribute("cslots") or 0
end

function Item.setCrystalSlots(self, value)
  if self:getId() == 0 then return end

  self:setCustomAttribute("cslots", value)
end

function Item.setCrystalValue(self, slot, value)
  if self:getId() == 0 then return end
  if not value then
    self:removeCustomAttribute("Cry"..slot)
    return
  end

  self:setCustomAttribute("Cry" .. slot, value)
end