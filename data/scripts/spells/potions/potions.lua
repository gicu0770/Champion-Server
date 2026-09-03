POTION_CONFIG = POTION_CONFIG or {
  [7618] = {name = "Health Potion", health = {100, 100}, effect = 304, maxCharges = 5, regenTime = 10000, cooldownPotion = 3000, upgradeTo = 7588, upgradeLevel = 10, upgradeGold = 500}, -- health potion
  [7588] = {name = "Strong Health Potion", health = {180, 180}, effect = 304, maxCharges = 5, regenTime = 10000, cooldownPotion = 3000, upgradeTo = 7591, upgradeLevel = 15, upgradeGold = 1500}, -- strong health potion
  [7591] = {name = "Great Health Potion", health = {220, 220}, effect = 304, maxCharges = 5, regenTime = 10000, cooldownPotion = 3000, upgradeTo = 8473, upgradeLevel = 25, upgradeGold = 3500}, -- great health potion
  [8473] = {name = "Ultimate Health Potion", health = {280, 280}, effect = 304, maxCharges = 5, regenTime = 10000, cooldownPotion = 3000, upgradeTo = 26031, upgradeLevel = 35, upgradeGold = 7500}, -- ultimate health potion
  [26031] = {name = "Ultimate Spirit Potion", health = {340, 340}, effect = 306, maxCharges = 5, regenTime = 10000, cooldownPotion = 3000, upgradeTo = 36912, upgradeLevel = 40, upgradeGold = 15000}, -- ultimate spirit potion
  [36912] = {name = "Heroic Health Potion", health = {400, 400}, effect = 304, maxCharges = 5, regenTime = 10000, cooldownPotion = 3000, upgradeTo = 34256, upgradeLevel = 45, upgradeGold = 25000}, -- health potion
  [34256] = {name = "Health Flask", health = {460, 460}, effect = 304, maxCharges = 5, regenTime = 10000, cooldownPotion = 3000, upgradeTo = 26917, upgradeLevel = 50, upgradeGold = 40000}, -- health potion
  [26917] = {name = "Energy Flask", health = {520, 520}, effect = 304, maxCharges = 5, regenTime = 10000, cooldownPotion = 3000}, -- energy shield
}

function Player:sendPotionCharges(slot, currentCharges, maxCharges)
  self:sendExtendedOpcode(ExtendedOPCodes.CODE_CASTSPELL, json.encode({
    potionCharges = currentCharges,
    maxCharges = maxCharges,
    potionSlot = slot or 1
  }))
end

local POTION_CHARGES_REGEN = {}

local function startPotionChargesRegen(playerId, itemUid, regenTime, maxCharges)
  if POTION_CHARGES_REGEN[itemUid] then
    return
  end
  POTION_CHARGES_REGEN[itemUid] = true

  local function regenCharge()
    local item = Game.getRealUniqueItem(itemUid)
    if not item then
      POTION_CHARGES_REGEN[itemUid] = nil
      return
    end

    local currentCharges = item:getCustomAttribute("charges") or maxCharges
    if currentCharges < maxCharges then
      currentCharges = currentCharges + 1
      item:setCustomAttribute("charges", currentCharges)

      local player = Player(playerId)
      if player then
        player:sendTextMessage(MESSAGE_STATUS_SMALL, "Potion charge restored (" .. currentCharges .. "/" .. maxCharges .. ").")
        player:sendPotionCharges(1, currentCharges, maxCharges)
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
    end

    if charges <= 0 then
      player:sendTextMessage(MESSAGE_STATUS_SMALL, "You do not have any potion charges left.")
      player:sendPotionCharges(button, 0, maxCharges)
      return true
    end

    -- Consume 1 charge
    charges = charges - 1
    item:setCustomAttribute("charges", charges)
    player:sendTextMessage(MESSAGE_STATUS_SMALL, "Potion used (" .. charges .. "/" .. maxCharges .. " charges remaining).")
    player:sendPotionCharges(button, charges, maxCharges)

    -- Start regenerating charges every regenTime (default 3 seconds)
    local regenTime = potion.regenTime or 3000
    startPotionChargesRegen(player:getId(), item:getRealUID(), regenTime, maxCharges)
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