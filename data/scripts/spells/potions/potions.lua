POTION_CONFIG = {
  [7618] = {health = {100, 100}, level = 1, effect = 304, maxCharges = 5, regenTime = 10000, cooldownPotion = 3000}, -- health potion

  [7588] = {health = {180, 180}, level = 15, description = "Only for players of level 15 or above may drink this fluid.", effect = 304}, -- strong health potion

  [7591] = {health = {220, 220}, level = 23, description = "Only for players of level 23 or above may drink this fluid.", effect = 304}, -- great health potion

  [8473] = {health = {280, 280}, level = 33, description = "Only for players of level 33 or above may drink this fluid.", effect = 304}, -- ultimate health potion

  [26031] = {health = {340, 340}, level = 43, description = "Only for players of level 43 or above may drink this fluid.", effect = 306}, -- ultimate spirit potion

  [36912] = {health = {400, 400}, level = 52, description = "Only for players of level 52 or above may drink this fluid.", effect = 304}, -- health potion

  [34256] = {health = {460, 460}, level = 62, description = "Only for players of level 62 or above may drink this fluid.", effect = 304}, -- health potion

  [26917] = {health = {520, 520}, level = 72, description = "Only for players of level 72 or above may drink this fluid.", effect = 304}, -- energy shield
}

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
  local potionLevel = item:getItemLevel() - 10
  if potionLevel and player:getLevel() < potionLevel or potion.vocations and
    not table.contains(potion.vocations, player:getVocation():getId()) then
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
      return true
    end

    -- Consume 1 charge
    charges = charges - 1
    item:setCustomAttribute("charges", charges)
    player:sendTextMessage(MESSAGE_STATUS_SMALL, "Potion used (" .. charges .. "/" .. maxCharges .. " charges remaining).")

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