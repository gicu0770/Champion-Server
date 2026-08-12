function onSay(player, words, param)
	if not player:getGroup():getAccess() then
		return true
	end

	if player:getAccountType() < ACCOUNT_TYPE_GOD then
		return false
	end
	
	local split = param:split(",")
	local target = Player(split[1])
	if not target then
		player:sendCancelMessage("A player with that name is not online.")
		return false
	end

for i = 1, 70 do
	local storageStart = target:getStorageValue(435000 + i)
	local storageNumer = 435000 + i
	target:setStorageValue(storageNumer, -1)
end
target:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Talents restart")
player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Talents restarted "..target:getName().."")

if split[2] then
	target:setStorageValue(TALENTS2_STORAGE, tonumber(split[2]))
end
	return false

end