function onSay(player, words, param)

  local restartGlobalStorage = Game.getStorageValue(STORAGE_REBOOT)
  local split = param:split(",")
  local server = "Server"

  local time = tonumber(split[1])
  local reason = split[2]

  if not player:getGroup():getAccess() then
    return true
  end

  if player:getAccountType() < ACCOUNT_TYPE_GOD then
    return false
  end

  if time == nil or time <= 0 then
    player:sendCancelMessage("ERROR: Argument - time, not found! You need to use it properly ex. /restart time, reason")
    return false
  end
  if time >= 1800 then
    player:sendCancelMessage("Time to restart cannot be longer than 30 minutes (1800).")
    return false
  end
  if reason == nil then
    player:sendCancelMessage("ERROR: Argument - reason, not found! You need to use it properly ex. /restart time, reason")
    return false
  end

  if not Game.getStorageValue(STORAGE_REBOOT) then
    for _, tmpPlayer in ipairs(Game.getPlayers()) do
      broadcastMessage("Game World is going to perform maintenance reboot in ".. time .." seconds, because of following reason: ".. reason ..".", MESSAGE_STATUS_WARNING)
    end
    player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Executed Game World Rebooting! To stop this action, write: /stopRestart")
    Game.setStorageValue(STORAGE_REBOOT, time)
    addEvent(minusTime,1000,tmpPlayer)
    return true
  else
    player:sendTextMessage(MESSAGE_STATUS_CONSOLE_ORANGE, "Rebooting Progress is already running, to Stop this action, write: /stopRestart")
  return true
  end
end

function minusTime()
  local restartGlobalStorage = Game.getStorageValue(STORAGE_REBOOT)
    if restartGlobalStorage == nil then
      return true
    end
    if restartGlobalStorage > 0 then
      for _, tmpPlayer in ipairs(Game.getPlayers()) do
        tmpPlayer:sendTextMessage(MESSAGE_STATUS_SMALL,"Game World is going to reboot in: "..restartGlobalStorage.." seconds.")
      end
      Game.setStorageValue(STORAGE_REBOOT,restartGlobalStorage - 1)
      addEvent(minusTime,1000)
    elseif restartGlobalStorage == 0 then
      for _, tmpPlayer in ipairs(Game.getPlayers()) do
        tmpPlayer:sendTextMessage(MESSAGE_STATUS_SMALL,"Rebooting Game World!")
      end
      saveServer()
      addEvent(rebootServer(), 1000)
    end

    end