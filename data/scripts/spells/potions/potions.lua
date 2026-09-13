POTION_CONFIG = POTION_CONFIG or {
  [7618] = {name = "Health Potion", health = {150, 150}, effect = 304, maxCharges = 5, regenTime = 10000, cooldownPotion = 3000, upgradeTo = 7588, upgradeLevel = 5, upgradeGold = 500}, -- health potion
  [7588] = {name = "Strong Health Potion", health = {200, 200}, effect = 304, maxCharges = 5, regenTime = 10000, cooldownPotion = 3000, upgradeTo = 7591, upgradeLevel = 10, upgradeGold = 1500}, -- strong health potion
  [7591] = {name = "Great Health Potion", health = {250, 250}, effect = 304, maxCharges = 5, regenTime = 10000, cooldownPotion = 3000, upgradeTo = 8473, upgradeLevel = 15, upgradeGold = 3500}, -- great health potion
  [8473] = {name = "Ultimate Health Potion", health = {300, 300}, effect = 304, maxCharges = 5, regenTime = 10000, cooldownPotion = 3000, upgradeTo = 26031, upgradeLevel = 20, upgradeGold = 7500}, -- ultimate health potion
  [26031] = {name = "Ultimate Spirit Potion", health = {400, 400}, effect = 306, maxCharges = 5, regenTime = 10000, cooldownPotion = 3000, upgradeTo = 36912, upgradeLevel = 30, upgradeGold = 15000}, -- ultimate spirit potion
  [36912] = {name = "Heroic Health Potion", health = {500, 500}, effect = 304, maxCharges = 5, regenTime = 10000, cooldownPotion = 3000, upgradeTo = 34256, upgradeLevel = 35, upgradeGold = 25000}, -- health potion
  [34256] = {name = "Health Flask", health = {650, 650}, effect = 304, maxCharges = 5, regenTime = 10000, cooldownPotion = 3000}, -- health potion
}

function Player:sendPotionCharges(slot, currentCharges, maxCharges)
  self:sendExtendedOpcode(ExtendedOPCodes.CODE_CASTSPELL, json.encode({
    potionCharges = currentCharges,
    maxCharges = maxCharges,
    potionSlot = slot or 1
  }))
end

POTION_CHARGES_REGEN = POTION_CHARGES_REGEN or {}

function getEquippedPotionSlot(player, itemUid)
  if not player or not player:isPlayer() then return nil end
  local slot1Item = player:getSlotItem(CONST_SLOT_POTION1)
  if slot1Item and slot1Item:getRealUID() == itemUid then
    return 1
  end
  local slot2Item = player:getSlotItem(CONST_SLOT_POTION2)
  if slot2Item and slot2Item:getRealUID() == itemUid then
    return 2
  end
  return nil
end

function startPotionChargesRegen(player, item, regenTime, maxCharges)
  if not item then return end
  local itemUid = item:getRealUID()
  if itemUid == 0 then return end

  if POTION_CHARGES_REGEN[itemUid] then
    return
  end
  POTION_CHARGES_REGEN[itemUid] = true

  local playerGuid = (player and player:isPlayer()) and player:getGuid() or 0
  if not item:getCustomAttribute("lastChargeRegen") then
    item:setCustomAttribute("lastChargeRegen", os.time())
  end

  local function regenCharge()
    local it = Game.getRealUniqueItem(itemUid)
    if not it then
      POTION_CHARGES_REGEN[itemUid] = nil
      return
    end

    local currentCharges = it:getCustomAttribute("charges") or maxCharges
    if currentCharges < maxCharges then
      currentCharges = currentCharges + 1
      it:setCustomAttribute("charges", currentCharges)
      it:setCustomAttribute("lastChargeRegen", os.time())

      local targetPlayer = nil
      if playerGuid ~= 0 then
        targetPlayer = Player(playerGuid)
      end
      if not targetPlayer then
        local topParent = it:getTopParent()
        if topParent and topParent:isPlayer() then
          targetPlayer = topParent
        end
      end

      if targetPlayer then
        local slot = getEquippedPotionSlot(targetPlayer, itemUid)
        if slot then
          targetPlayer:sendTextMessage(MESSAGE_STATUS_SMALL, "Potion charge restored (" .. currentCharges .. "/" .. maxCharges .. ").")
          targetPlayer:sendPotionCharges(slot, currentCharges, maxCharges)
        end
      end

      if currentCharges < maxCharges then
        addEvent(regenCharge, regenTime)
      else
        POTION_CHARGES_REGEN[itemUid] = nil
      end
    else
      POTION_CHARGES_REGEN[itemUid] = nil
    end
  end

  addEvent(regenCharge, regenTime)
end

function updateAndSyncPotionCharges(player, item, slot)
  if not item then return end
  local potion = POTION_CONFIG[item:getId()]
  if not potion or not potion.maxCharges then return end

  local maxCharges = potion.maxCharges
  local regenTimeMs = potion.regenTime or 10000
  local regenTimeSec = math.max(1, math.floor(regenTimeMs / 1000))
  local currentCharges = item:getCustomAttribute("charges")

  if currentCharges == nil then
    currentCharges = maxCharges
    item:setCustomAttribute("charges", currentCharges)
    item:setCustomAttribute("lastChargeRegen", os.time())
  end

  local now = os.time()
  local lastRegen = item:getCustomAttribute("lastChargeRegen")

  if currentCharges < maxCharges then
    if lastRegen and lastRegen > 0 and now > lastRegen then
      local elapsed = now - lastRegen
      local gained = math.floor(elapsed / regenTimeSec)
      if gained > 0 then
        currentCharges = math.min(maxCharges, currentCharges + gained)
        item:setCustomAttribute("charges", currentCharges)
        item:setCustomAttribute("lastChargeRegen", lastRegen + (gained * regenTimeSec))
      end
    else
      item:setCustomAttribute("lastChargeRegen", now)
    end
  end

  if currentCharges < maxCharges then
    startPotionChargesRegen(player, item, regenTimeMs, maxCharges)
  end

  if player and player:isPlayer() then
    local pSlot = slot or getEquippedPotionSlot(player, item:getRealUID()) or 1
    player:sendPotionCharges(pSlot, currentCharges, maxCharges)
  end

  return currentCharges, maxCharges
end

function Player:syncPotionCharges(slot)
  local item = self:getSlotItem(15 + slot)
  if item then
    return updateAndSyncPotionCharges(self, item, slot)
  end
end

local function onUse(player, item, button)
  if not player then return end
  if player:hasCondition(CONDITION_SPELLCOOLDOWN, button+150) then
    return
  end
  local cooldownPotion = 1000
  local quality = item:isQuality()
  local potion = POTION_CONFIG[item:getId()]
  if not potion then
    print("Potion config not found for item id: "..item:getId())
    return
  end
  if potion.vocations and not table.contains(potion.vocations, player:getVocation():getId()) then
    if potion.description then
      player:say(potion.description, TALKTYPE_MONSTER_SAY)
    end
    return true
  end

  -- Charges System Check
  if potion.maxCharges then
    local maxCharges = potion.maxCharges
    local charges = item:getCustomAttribute("charges")
    if charges == nil then
      charges = maxCharges
      item:setCustomAttribute("charges", charges)
      item:setCustomAttribute("lastChargeRegen", os.time())
    end

    local regenTime = potion.regenTime or 10000

    if charges <= 0 then
      player:sendTextMessage(MESSAGE_STATUS_SMALL, "You do not have any potion charges left.")
      player:sendPotionCharges(button, 0, maxCharges)
      -- Ensure regen is running to prevent permanent deadlock
      startPotionChargesRegen(player, item, regenTime, maxCharges)
      return true
    end

    -- Consume 1 charge
    charges = charges - 1
    item:setCustomAttribute("charges", charges)
    item:setCustomAttribute("lastChargeRegen", os.time())
    player:sendTextMessage(MESSAGE_STATUS_SMALL, "Potion used (" .. charges .. "/" .. maxCharges .. " charges remaining).")
    player:sendPotionCharges(button, charges, maxCharges)

    -- Start regenerating charges every regenTime
    startPotionChargesRegen(player, item, regenTime, maxCharges)
  end

  if potion.cooldownPotion then
    cooldownPotion = potion.cooldownPotion
  end
  
    if potion.health then
      local regenT = "health"
      local HP = item:getCustomAttribute("potionHealth") or 0
      if HP == 0 and potion.health then
        HP = potion.health[1]
      end

      resourceRegen(player, HP, 3, 10, regenT)
    end

    if potion.mana then
      local manaEnd = potion.mana[1] -- * 1.33
      if quality then
        manaEnd = manaEnd + (manaEnd * quality / 100)
      end
      doTargetCombatMana(player, player, manaEnd, manaEnd)
    end

    if player:getPosition():sendMagicEffect(potion.effect) then
      player:getPosition():sendMagicEffect(potion.effect)
    else
      player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
    end

  local cd = Condition(CONDITION_SPELLCOOLDOWN)
  cd:setParameter(CONDITION_PARAM_TICKS, cooldownPotion)
  cd:setParameter(CONDITION_PARAM_SUBID, button+150)
  player:addCondition(cd)
  player:updateInspect()
end


POTIONS["potions"] = {
  use = function(player, item, button)
    onUse(player, item, button)
  end
}