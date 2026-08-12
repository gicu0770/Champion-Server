local event = {}
local timeOnline = 60 * 60 * 1000

function addPremiumPoint(cid)
local player = Player(cid)
    if player then
		player:setStorageValue(PlayerStorage.onlinePoints,player:getStorageValue(PlayerStorage.onlinePoints) + 1)
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_ORANGE, "[Online Points] You have been online for an hour and have earned 1 online point.")
        event[cid] = addEvent(addPremiumPoint, timeOnline, cid)
        return
    end
    event[cid] = nil
end

function onLogin(player)
    if player:getStorageValue(PlayerStorage.onlinePoints) == -1 then
      player:setStorageValue(PlayerStorage.onlinePoints, 0)
    end
    if player and player:getLevel() >= 150 then
		local cid = player:getId()
		if not event[cid] then
			event[cid] = addEvent(addPremiumPoint, timeOnline, cid)
		end
	end
    return true
end