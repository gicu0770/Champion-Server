function onSay(player, words, param)
	if not player:getGroup():getAccess() then
		return true
	end

	-- Get Lua memory usage in KB
	local memoryKB = collectgarbage("count")
	local memoryMB = memoryKB / 1024

	local message = "=== Lua Memory Usage ==="
		.. "\nMemory Count: " .. string.format("%.2f MB (%.2f KB)", memoryMB, memoryKB)
		.. "\n======================="

	player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, message)
	return false
end
