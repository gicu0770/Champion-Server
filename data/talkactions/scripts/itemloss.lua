function onSay(player, words, param)
	if not player:getGroup():getAccess() then
		return true
	end

	if player:getAccountType() < ACCOUNT_TYPE_GAMEMASTER then
		return false
	end

	logCommand(player, words, param)

	local storageKey = GlobalStorageKeys and GlobalStorageKeys.disableDeathItemLoss or 545403
	local isCurrentlyDisabled = (Game.getStorageValue(storageKey) == 1)

	param = param and param:lower():trim() or ""

	local newState = nil

	if param == "off" or param == "disable" or param == "wylacz" or param == "0" then
		-- Utrata przedmiotow wylaczona (brak utraty)
		newState = true
	elseif param == "on" or param == "enable" or param == "wlacz" or param == "1" then
		-- Utrata przedmiotow wlaczona (standardowa utrata)
		newState = false
	elseif param == "status" or param == "info" or param == "check" then
		if isCurrentlyDisabled then
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "[Item Loss] Utrata przedmiotow po smierci jest obecnie: WYLACZONA (gracze NIE traca przedmiotow).")
		else
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "[Item Loss] Utrata przedmiotow po smierci jest obecnie: WLACZONA (standardowy drop).")
		end
		return false
	else
		-- Toggle przy braku parametru lub innym slowie
		newState = not isCurrentlyDisabled
	end

	if newState then
		Game.setStorageValue(storageKey, 1)
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "[Item Loss] Utrata przedmiotow po smierci zostala WYLACZONA dla wszystkich graczy.")
	else
		Game.setStorageValue(storageKey, 0)
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "[Item Loss] Utrata przedmiotow po smierci zostala WLACZONA dla wszystkich graczy.")
	end

	return false
end
