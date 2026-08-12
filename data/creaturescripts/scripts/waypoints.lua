local WAYPOINTS_STORAGE = 41875

function onExtendedOpcode(player, opcode, buffer)
  if opcode == ExtendedOPCodes.CODE_WAYPOINTS then
    local status, data =
      pcall(
      function()
        return json.decode(buffer)
      end
    )
    if not status then
      return false
    end

    if data[1] == "f" then
      local data = {}
      local playerPos = player:getPosition()
      for i = 1, #WAYPOINTS do
        local waypoint = WAYPOINTS[i]    
        if playerPos == waypoint.pos then
          data[i] = 3
        elseif player:getStorageValue(WAYPOINTS_STORAGE + i) == 1 then
          data[i] = 2
        else
          data[i] = 1
        end
      end
      player:sendExtendedOpcode(ExtendedOPCodes.CODE_WAYPOINTS, json.encode({"f", WAYPOINTS, data}))
      return true
    elseif data[1] == "t" then
      local id = data[2]
      if player:getStorageValue(WAYPOINTS_STORAGE + id) == 1 then
        local pos = WAYPOINTS[id].pos
        if player:getPosition() == pos then
          return true
        end

        player:teleportTo(pos)
        pos:sendMagicEffect(CONST_ME_ENERGYAREA)
        player:sendExtendedOpcode(ExtendedOPCodes.CODE_WAYPOINTS, json.encode({"c"}))
        return true
      end
    end
  end
end