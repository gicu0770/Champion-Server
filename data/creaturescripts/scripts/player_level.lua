function onExtendedOpcode(player, opcode, buffer)
  if opcode == ExtendedOPCodes.CODE_PLAYER_LEVEL then
    local status, json_data = pcall(function() return json.decode(buffer) end)
    if not status or not json_data then return false end

    local target = nil
    if json_data.id then
      target = Player(json_data.id)
    elseif json_data.name then
      target = Player(json_data.name)
    end

    if target then
      player:sendExtendedOpcode(ExtendedOPCodes.CODE_PLAYER_LEVEL, json.encode({
        id = target:getId(),
        name = target:getName(),
        level = target:getLevel()
      }))
    end
    return true
  end
  return true
end
