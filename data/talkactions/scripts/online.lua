local maxPlayersPerMessage = 10

function onSay(player, words, param)

	local hasAccess = player:getGroup():getAccess()
	local players = Game.getPlayers()
	local onlineList = {}
	local sorcerer = 0 
	local druid = 0
	local knight = 0
	local paladin = 0
	local archer = 0
	local shadow = 0
	for _, targetPlayer in ipairs(players) do
		if hasAccess or not targetPlayer:isInGhostMode() then
			
			if targetPlayer:isSorcerer() then
				sorcerer = sorcerer + 1
			elseif targetPlayer:isDruid() then
				druid = druid + 1
			elseif targetPlayer:isKnight() then
				knight = knight + 1
			elseif targetPlayer:isPaladin() then
				paladin = paladin + 1
			elseif targetPlayer:isArcher() then
				archer = archer + 1
			elseif targetPlayer:isShadow() then
				shadow = shadow + 1
			end
			table.insert(onlineList, ("%s [%s] | (%s)"):format(targetPlayer:getName(), targetPlayer:getLevel(), targetPlayer:getVocation():getName()))
		end
	end

	local playersOnline = #onlineList
	local unique_players_via_ip, character_count = {}, 0
  
    for _, pid in ipairs(getPlayersOnline()) do  
        if((getPlayerCustomFlagValue(player, PLAYERCUSTOMFLAG_GAMEMASTERPRIVILEGES) or not getPlayerCustomFlagValue(pid, PLAYERCUSTOMFLAG_GAMEMASTERPRIVILEGES)) and (not isPlayerGhost(pid) or getPlayerGhostAccess(player) >= getPlayerGhostAccess(pid))) then
            character_count = character_count + 1
            local ip, ip_found = getPlayerIp(pid), 0
            for i = 1, #unique_players_via_ip do
                if ip == unique_players_via_ip[i] then
                    ip_found = 1
                    break
                end
            end
            if ip_found == 0 then
                table.insert(unique_players_via_ip, ip)
            end
        end
    end
	
	player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, ("Players online: %d\nSorcerers: "..sorcerer.." | Druid: "..druid.." | Knights: "..knight.." | Paladins: "..paladin.." | Archers: "..archer.." | Shadows: "..shadow..""):format(playersOnline))

	for i = 1, playersOnline, maxPlayersPerMessage do
		local j = math.min(i + maxPlayersPerMessage - 1, playersOnline)
		local msg = table.concat(onlineList, ", ", i, j) .. "."
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, msg)
	end
	return false
end
