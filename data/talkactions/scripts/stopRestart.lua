function onSay(cid, words, param, channel)
	if cid:getAccountType() < ACCOUNT_TYPE_GOD then
		return false
	end
local restartGlobalStorage = Game.getStorageValue(STORAGE_REBOOT)
    if restartGlobalStorage ~= nil then
        broadcastMessage("Game World reboot has been canceled by Game Creator.")
        Game.setStorageValue(STORAGE_REBOOT)
        cid:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "You canceled Game World reboot progress.")
    else
        cid:sendTextMessage(MESSAGE_STATUS_SMALL,"First you must call Game World reboot by using: /restart time, reason!")

           return true
    end
end