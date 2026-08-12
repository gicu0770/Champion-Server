function onExtendedOpcode(player, opcode, buffer)
  if opcode == ExtendedOPCodes.CODE_OPTIONS then
    local status, json_data =
    pcall(
      function()
        return json.decode(buffer)
      end
    )
    if not status then
      return false
    end
    
    if json_data.action == "SPELLEFFECT" then
      player:setStorageValue(PlayerStorage.spellEffects, json_data.value)
      return true
    elseif json_data.action == "SPELLMSG" then
      player:setStorageValue(PlayerStorage.spellMessage, json_data.value)
      return true
    end
  end

  return false
end