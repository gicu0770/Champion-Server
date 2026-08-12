local config = {
    [1] = {"no-pvp", WORLD_TYPE_NO_PVP},
    [2] = {"pvp", WORLD_TYPE_PVP},
    [3] = {"pvp-enforced", WORLD_TYPE_PVP_ENFORCED},
}

function onSay(player, words, param)
    if not player:getGroup():getAccess() then
        return true
    end
	if player:getAccountType() < ACCOUNT_TYPE_GOD then
		return false
	end
    local param = tonumber(param)
    local haveConfig = config[param]
    if not param or not haveConfig then
        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Command param required. exemple: /pvp 1, 2 or 3")
        return true
    end

    if haveConfig then
        Game.setWorldType(haveConfig[2])
        Game.broadcastMessage("Gameworld type set to: " .. haveConfig[1] .. ".", MESSAGE_EVENT_ADVANCE)
        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Gameworld type set to: " .. haveConfig[1] .. ".")
    end
  
    return true
end