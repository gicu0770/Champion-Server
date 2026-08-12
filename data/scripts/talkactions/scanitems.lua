local talk = TalkAction("/scanitems")

function talk.onSay(player, words, param)
	if not player:getGroup():getAccess() then
		return true
	end
	
	-- Parse threshold from param (default 100)
	local threshold = 100
	if param ~= "" then
		threshold = tonumber(param) or 100
	end
	
	player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Starting item scan with threshold: " .. threshold .. "...")
	
	-- Run the scan
	local suspicious = Game.scanAllPlayerItems(threshold)
	
	player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Item scan complete. Found " .. suspicious .. " suspicious entries. Check data/logs/ for details.")
	
	return false
end

talk:separator(" ")
talk:register()
