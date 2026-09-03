local POTION_UPGRADE_COOLDOWN = {}

local function getTimeMs()
  return os.mtime and os.mtime() or (os.time() * 1000)
end

local function isNearMona(player)
  local playerPos = player:getPosition()
  local spectators = Game.getSpectators(playerPos, false, false, 5, 5, 5, 5)
  for _, spec in ipairs(spectators) do
    if spec:isNpc() and spec:getName():lower() == "mona" then
      return true
    end
  end
  return false
end

function onExtendedOpcode(player, opcode, buffer)
  if opcode == ExtendedOPCodes.CODE_POTION_UPGRADE then
    local status, data = pcall(function() return json.decode(buffer) end)
    if not status or not data then
      return false
    end

    if data.action == "upgrade" then
      local now = getTimeMs()
      local pId = player:getId()

      -- 1. Anti-spam / lag cooldown (minimum 800ms between upgrade requests)
      if POTION_UPGRADE_COOLDOWN[pId] and (now - POTION_UPGRADE_COOLDOWN[pId] < 800) then
        return false
      end
      POTION_UPGRADE_COOLDOWN[pId] = now

      -- 2. Distance security: Player must be near Mona
      if not isNearMona(player) then
        player:sendTextMessage(MESSAGE_STATUS_SMALL, "You must be near Mona to upgrade your potion.")
        return false
      end

      -- 3. Verify expected item ID (Anti-packet replay / Anti-desync)
      local potionItem = getPlayerPotion(player)
      if not potionItem then
        player:sendTextMessage(MESSAGE_STATUS_SMALL, "You don't have any potion equipped or in your backpack!")
        sendPotionUpgradeData(player)
        return false
      end

      if data.expectedId and data.expectedId > 0 and potionItem:getId() ~= data.expectedId then
        -- The item already changed (e.g. from an earlier packet). Refresh the client view without re-upgrading.
        sendPotionUpgradeData(player)
        return false
      end

      -- 4. Atomic execution
      upgradePotionForPlayer(player)
      sendPotionUpgradeData(player)
    end
  end
  return true
end
