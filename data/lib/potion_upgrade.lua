POTION_CONFIG = {
  [7618] = {
    name = "Health Potion",
    health = {100, 100},
    level = 1,
    effect = 304,
    maxCharges = 5,
    regenTime = 10000,
    cooldownPotion = 3000,
    upgradeTo = 7588,
    upgradeLevel = 10,
    upgradeGold = 500,
  },
  [7588] = {
    name = "Strong Health Potion",
    health = {150, 150},
    effect = 304,
    maxCharges = 5,
    regenTime = 10000,
    cooldownPotion = 3000,
    upgradeTo = 7591,
    upgradeLevel = 15,
    upgradeGold = 1500,
  },
  [7591] = {
    name = "Great Health Potion",
    health = {230, 230},
    effect = 304,
    maxCharges = 5,
    regenTime = 10000,
    cooldownPotion = 3000,
    upgradeTo = 8473,
    upgradeLevel = 25,
    upgradeGold = 3500,
  },
  [8473] = {
    name = "Ultimate Health Potion",
    health = {330, 330},
    effect = 304,
    maxCharges = 5,
    regenTime = 10000,
    cooldownPotion = 3000,
    upgradeTo = 26031,
    upgradeLevel = 35,
    upgradeGold = 7500,
  },
  [26031] = {
    name = "Ultimate Spirit Potion",
    health = {410, 410},
    effect = 306,
    maxCharges = 5,
    regenTime = 10000,
    cooldownPotion = 3000,
    upgradeTo = 36912,
    upgradeLevel = 40,
    upgradeGold = 15000,
  },
  [36912] = {
    name = "Heroic Health Potion",
    health = {570, 570},
    effect = 304,
    maxCharges = 5,
    regenTime = 10000,
    cooldownPotion = 3000,
    upgradeTo = 34256,
    upgradeLevel = 45,
    upgradeGold = 25000,
  },
  [34256] = {
    name = "Health Flask",
    health = {750, 750},
    effect = 304,
    maxCharges = 5,
    regenTime = 10000,
    cooldownPotion = 3000,
  },
}

function getPlayerPotion(player)
  if not player then return nil end
  -- 1. Check CONST_SLOT_POTION1 first
  local slotItem = player:getSlotItem(CONST_SLOT_POTION1)
  if slotItem and POTION_CONFIG[slotItem:getId()] then
    return slotItem
  end
  -- 2. Check player's backpacks / inventory
  for potionId, _ in pairs(POTION_CONFIG) do
    local item = player:getItemById(potionId, true)
    if item then
      return item
    end
  end
  return nil
end

function getPotionUpgradeInfo(player)
  local potionItem = getPlayerPotion(player)
  if not potionItem then
    return false, "NO_POTION"
  end

  local currentId = potionItem:getId()
  local cfg = POTION_CONFIG[currentId]
  if not cfg or not cfg.upgradeTo then
    return false, "MAX_TIER", cfg
  end

  local nextId = cfg.upgradeTo
  local nextCfg = POTION_CONFIG[nextId]
  local reqLevel = cfg.upgradeLevel or nextCfg.level or 1
  local reqGold = cfg.upgradeGold or 1000

  if player:getLevel() < reqLevel then
    return false, "LOW_LEVEL", cfg, nextCfg, reqLevel, reqGold
  end

  if player:getTotalMoney() < reqGold then
    return false, "NO_GOLD", cfg, nextCfg, reqLevel, reqGold
  end

  return true, "CAN_UPGRADE", cfg, nextCfg, reqLevel, reqGold, potionItem
end

function upgradePotionForPlayer(player)
  local canUpgrade, reason, cfg, nextCfg, reqLevel, reqGold, potionItem = getPotionUpgradeInfo(player)
  if not canUpgrade then
    if reason == "NO_POTION" then
      player:sendTextMessage(MESSAGE_STATUS_SMALL, "You don't have any potion equipped or in your backpack!")
    elseif reason == "MAX_TIER" then
      player:sendTextMessage(MESSAGE_STATUS_SMALL, "Your " .. (cfg and cfg.name or "potion") .. " is already at the maximum tier!")
    elseif reason == "LOW_LEVEL" then
      player:sendTextMessage(MESSAGE_STATUS_SMALL, "You need level " .. reqLevel .. " to upgrade this potion. (You are level " .. player:getLevel() .. ")")
    elseif reason == "NO_GOLD" then
      player:sendTextMessage(MESSAGE_STATUS_SMALL, "You need " .. reqGold .. " gold to upgrade this potion. (Your balance: " .. player:getTotalMoney() .. " gold)")
    end
    return false
  end

  if not player:removeTotalMoney(reqGold, true) then
    player:sendTextMessage(MESSAGE_STATUS_SMALL, "You don't have enough gold in your account balance!")
    return false
  end

  potionItem:transform(cfg.upgradeTo)
  potionItem:setCustomAttribute("charges", nextCfg.maxCharges)
  potionItem:setCustomAttribute("potionHealth", nextCfg.health[1])
  player:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)
  player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Congratulations! Your potion has been upgraded to " .. (nextCfg.name or "next tier") .. "!")
  player:sendPotionCharges(1, nextCfg.maxCharges, nextCfg.maxCharges)
  return true
end

function showPotionUpgradeModal(player)
  local canUpgrade, reason, cfg, nextCfg, reqLevel, reqGold, potionItem = getPotionUpgradeInfo(player)
  local title = "Potion Upgrade"
  local message = ""
  if reason == "NO_POTION" then
    message = "You don't have any potion equipped or in your backpack!\nStarter potion is Health Potion (ID: 7618)."
  elseif reason == "MAX_TIER" then
    message = "Your " .. (cfg.name or "potion") .. " is already at the maximum tier!\n"
    message = message .. "Healing: +" .. cfg.health[1] .. " Health\n"
    message = message .. "Max Charges: " .. cfg.maxCharges
  else
    local formattedGold = tostring(reqGold):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
    local playerBalance = tostring(player:getTotalMoney()):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
    message = "Current: " .. (cfg.name or "Potion") .. " (+" .. cfg.health[1] .. " HP)\n"
    message = message .. "Upgrade to: " .. (nextCfg.name or "Next Tier") .. " (+" .. nextCfg.health[1] .. " HP)\n\n"
    message = message .. "Required Level: " .. reqLevel .. " (Your level: " .. player:getLevel() .. ")\n"
    message = message .. "Cost: " .. formattedGold .. " Gold (Your balance: " .. playerBalance .. " Gold)\n\n"
    if reason == "LOW_LEVEL" then
      message = message .. "[!] Your level is too low to upgrade."
    elseif reason == "NO_GOLD" then
      message = message .. "[!] You don't have enough gold in your account balance."
    else
      message = message .. "Do you want to upgrade your potion?"
    end
  end

  player:registerEvent("ModalWindow_PotionUpgrade")
  local window = ModalWindow(1050, title, message)
  if canUpgrade then
    window:addButton(100, "Upgrade")
    window:addButton(101, "Cancel")
    window:setDefaultEnterButton(100)
    window:setDefaultEscapeButton(101)
  else
    window:addButton(101, "Close")
    window:setDefaultEnterButton(101)
    window:setDefaultEscapeButton(101)
  end
  window:sendToPlayer(player)
end

function sendPotionUpgradeData(player)
  local canUpgrade, reason, cfg, nextCfg, reqLevel, reqGold, potionItem = getPotionUpgradeInfo(player)
  local currentServerId = potionItem and potionItem:getId() or 0
  local nextServerId = (cfg and cfg.upgradeTo) or 0

  local currentClientId = currentServerId > 0 and ItemType(currentServerId):getClientId() or 0
  local nextClientId = nextServerId > 0 and ItemType(nextServerId):getClientId() or 0

  local data = {
    action = "open",
    canUpgrade = canUpgrade,
    reason = reason,
    currentServerId = currentServerId,
    currentClientId = currentClientId,
    currentName = cfg and cfg.name or "No Potion",
    currentHp = cfg and cfg.health[1] or 0,
    nextServerId = nextServerId,
    nextClientId = nextClientId,
    nextName = nextCfg and nextCfg.name or "Max Tier",
    nextHp = nextCfg and nextCfg.health[1] or 0,
    hpIncrease = (nextCfg and cfg) and (nextCfg.health[1] - cfg.health[1]) or 0,
    reqLevel = reqLevel or 1,
    playerLevel = player:getLevel(),
    reqGold = reqGold or 0,
    playerBalance = player:getTotalMoney(),
  }

  player:registerEvent("PotionUpgrade")
  player:sendExtendedOpcode(ExtendedOPCodes.CODE_POTION_UPGRADE, json.encode(data))
end
