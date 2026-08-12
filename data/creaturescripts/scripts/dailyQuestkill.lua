local questStorage = PlayerStorage.dailyQuestKill
local questStorageStartEnd = PlayerStorage.dailyQuestKillstartEnd

function onDeath(target, corpse, player, mostDamage, unjustified, mostDamage_unjustified)
    if not target or target:isPlayer() or target:getMaster() then
        return true
    end
if player then
local party = player:getParty()
if party then
    local members = party:getMembers() 
    for i = 1, #members do
        local member = members[i]
        if member:getPosition():getDistance(target:getPosition()) <= 150 then
			local kills = member:getStorageValue(questStorage)
			local ilosc = 200 + (member:getLevel() * 2)
			if member:getStorageValue(questStorageStartEnd) == -1 then
				member:setStorageValue(questStorage, member:getStorageValue(questStorage) + 1)
				member:sendTextMessage(MESSAGE_STATUS_CONSOLE_ORANGE,"You Daily Quest Kill: "..kills.."/"..ilosc.."") 
			end
			if kills >= ilosc and member:getStorageValue(questStorageStartEnd) == -1 then
			member:sendTextMessage(MESSAGE_STATUS_CONSOLE_ORANGE,"You Daily Quest Kill is done!")
			member:setStorageValue(questStorageStartEnd, 1)
			end
        end
    end
    local leader = party:getLeader()
    if leader:getPosition():getDistance(target:getPosition()) <= 150 then
			local kills = leader:getStorageValue(questStorage)
			local ilosc = 200 + (leader:getLevel() * 2)
			if leader:getStorageValue(questStorageStartEnd) == -1 then
				leader:setStorageValue(questStorage, leader:getStorageValue(questStorage) + 1)
				leader:sendTextMessage(MESSAGE_STATUS_CONSOLE_ORANGE,"You Daily Quest Kill: "..kills.."/"..ilosc.."")
			end
			if kills >= ilosc and leader:getStorageValue(questStorageStartEnd) == -1 then
			leader:sendTextMessage(MESSAGE_STATUS_CONSOLE_ORANGE,"You Daily Quest Kill is done!")
			leader:setStorageValue(questStorageStartEnd, 1)
			end
    end
else

	local kills = player:getStorageValue(questStorage)
	local ilosc = 200 + (player:getLevel() * 2)
	if player:getStorageValue(questStorageStartEnd) == -1 then
		player:setStorageValue(questStorage, player:getStorageValue(questStorage) + 1)
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_ORANGE,"You Daily Quest Kill: "..kills.."/"..ilosc.."")
	end
	if kills >= ilosc and player:getStorageValue(questStorageStartEnd) == -1 then
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_ORANGE,"You Daily Quest Kill is done!")
		player:setStorageValue(questStorageStartEnd, 1)
	end

end
end
    return true
end