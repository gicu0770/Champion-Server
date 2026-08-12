local WAYPOINTS_STORAGE = 41875

function onStepIn(player, item, position, fromPosition)
  if not player:isPlayer() then return false end
  if fromPosition:getDistance(position) ~= 1 then return true end

  local data = {}
  local playerPos = player:getPosition()
  for i = 1, #WAYPOINTS do
    local waypoint = WAYPOINTS[i]
    if position == waypoint.pos and player:getStorageValue(WAYPOINTS_STORAGE + i) ~= 1 then
      player:setStorageValue(WAYPOINTS_STORAGE + i, 1)
      player:sendTextMessage(MESSAGE_INFO_DESCR, "New waypoint unlocked!\n-- " .. waypoint.name .. " --")
    end

    if playerPos == waypoint.pos then
      data[i] = 3
    elseif player:getStorageValue(WAYPOINTS_STORAGE + i) == 1 then
      data[i] = 2
    else
      data[i] = 1
    end
  end

  player:sendExtendedOpcode(ExtendedOPCodes.CODE_WAYPOINTS, json.encode({"i", data}))
	return true
end

function onStepOut(player, item, position, fromPosition)
  if not player:isPlayer() then return false end
  player:sendExtendedOpcode(ExtendedOPCodes.CODE_WAYPOINTS, json.encode({"c"}))
end