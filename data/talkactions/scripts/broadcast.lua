function onSay(player, words, param)
	if not player:hasFlag(PlayerFlag_CanBroadcast) then
		return true
	end

	if param == "" then
		return
	end


	print("> " .. player:getName() .. " broadcasted: \"" .. param .. "\".")
	for _, targetPlayer in ipairs(Game.getPlayers()) do
		targetPlayer:sendExtendedOpcode(71, json.encode({text = param, color = "#f7ef8a"}))
		targetPlayer:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, ""..param.."")
	end
	return false
end
