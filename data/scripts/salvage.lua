local LoginEvent = CreatureEvent("SalvageLogin")
function LoginEvent.onLogin(player)
  player:registerEvent("SalvageExtendedOpcode")
  return true
end

local ExtendedEvent = CreatureEvent("SalvageExtendedOpcode")
function ExtendedEvent.onExtendedOpcode(player, opcode, buffer)
  if opcode ~= ExtendedOPCodes.CODE_SALVAGE then return false end
  local status, data = pcall(function() return json.decode(buffer) end)
  if not status then return false end

  if data[1] == 1 then
    salvageItems(player, data[2])
  elseif data[1] == 2 then
    salvageSingleItem(player, data[2])
  end

  return true
end

function salvageSingleItem(player, id, returnValue)
  local item = player:getItem(id)
  local countPowder = {0, 0, 0}
  if item then
    if item:isLocked() then
      return
    end

    countPowder[3] = countPowder[3] + 1
    local index, powder = item:convertToPowder()
    countPowder[index] = countPowder[index] + powder
    item:remove()
    if returnValue then
      return index, powder
    else
      player:addPowder(countPowder[1], false)
      player:addPowder(countPowder[2], true)
    end
  end
end

function salvageItems(player, items)
  if not items or #items == 0 then return false end
  local countPowder = {0, 0, 0}
  for _, id in ipairs(items) do
    local index, powder = salvageSingleItem(player, id, true)
    if index then
      countPowder[3] = countPowder[3] + 1
      countPowder[index] = countPowder[index] + powder
    end
  end

  player:sendExtendedOpcode(ExtendedOPCodes.CODE_SALVAGE, json.encode({1, countPowder}))
  player:addPowder(countPowder[1], false)
  player:addPowder(countPowder[2], true)
end

LoginEvent:type("login")
LoginEvent:register()
ExtendedEvent:type("extendedopcode")
ExtendedEvent:register()