local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)

function onCreatureAppear(cid)            npcHandler:onCreatureAppear(cid)            end
function onCreatureDisappear(cid)        npcHandler:onCreatureDisappear(cid)            end
function onCreatureSay(cid, type, msg)    npcHandler:onCreatureSay(cid, type, msg)    end
function onThink()                        npcHandler:onThink()    end

local vocAfterPromo = {9, 10, 11, 12}
function creatureSayCallback(cid, type, msg)
    if not npcHandler:isFocused(cid) then
        return false
    end
------------------------------------------FIRST------------------------------------------------
if msgcontains(msg, "first promotion") then
    local player = Player(cid)
	local vocId = player:getVocation():getId()
	if player:getStorageValue(PlayerStorage.promotionStorage) >= 1 then
	local cost = 20000
	if player:getLevel() <= 99 then
    return selfSay("You must be level 100 for the promotion!", cid)
    end
	if player:getStorageValue(PlayerStorage.reborn) > -1 then
    return selfSay("You have done first promotion!", cid)
    end
	if not player:getStorageValue(PlayerStorage.reborn) == -1 then
	return selfSay("You not done first promotion!", cid)
	end
	-------BLOKADY---------
		if player:removeTotalMoney(20000) then
			if vocId == 17 or vocId == 21 then
				player:setVocation(vocId + 1)
			else
				player:setVocation(vocId + 4)
			end
			player:getPosition():sendMagicEffect(CONST_ME_FIREWORK_BLUE)
			player:setStorageValue(PlayerStorage.reborn, 0)
			player:addStatsPoints(5)
			selfSay("You have recieved the first promotion. You are now "..player:getVocation():getName().."!\nYou attack speed increase!\nYou can reach now Level 500 for second promotion!\nYou have gained 5 extra stat point!", cid)
			player:getPosition():sendMagicEffect(50)
			else
			selfSay("You need "..cost.." gold for promotion!", cid)
		end --kasa
	else
	 return selfSay("You need finish First Promotion Challenge! You need finish POI Quest!", cid)
	end
end --slowo
------------------------------------------second PlayerStorage.reborn------------------------------------------------
if msgcontains(msg, "second promotion") then
    local player = Player(cid)
	local vocId = player:getVocation():getId()
	local cost = 3000000
	if player:getStorageValue(PlayerStorage.promotionStorage) >= 2 then
	if player:getLevel() <= 499 then
    return selfSay("You must be level 500 for the second promotion!", cid)
    end
	if player:getStorageValue(PlayerStorage.reborn) > 0 then
    return selfSay("You have done second promotion!", cid)
    end
	if player:getStorageValue(PlayerStorage.reborn) == -1 then
	return selfSay("You not done first promotion!", cid)
	end
	if player:removeTotalMoney(3000000) then
		for i = 1, 200 do
			player:setStorageValue(65000 + i, -1)
			player:setStorageValue(1510 + i, -1)
		end
		if vocId == 18 or vocId == 22 then
			player:setVocation(vocId + 1)
		else
			player:setVocation(vocId + 4)
		end
		player:addOutfitAddon(156, 3)
		player:addOutfit(156)
		player:addOutfitAddon(152, 3)
		player:addOutfit(152)
		player:getPosition():sendMagicEffect(CONST_ME_FIREWORK_BLUE)
		player:setStorageValue(PlayerStorage.reborn, 1)
		player:setStorageValue(PlayerStorage.rebornMessageAfterLogin, 1)
		local bag = player:addItem(1988, 1)
		bag:addItem(26555, 15)
		bag:addItem(26805, 5)
		bag:addItem(36671, 5)
		bag:addItem(24850, 100)
		player:addItem(10129, 1)
		player:addStatsPoints(10)
		selfSay("You have recieved the second promotion. You are now "..player:getVocation():getName().."!\nYou attack speed increase!\nYou can reach now Level 1000 for third promotion!\nYou have gained 10 extra stat point!", cid)
	local playerId = player:getGuid()
    player:remove()  
--    db.query("UPDATE `players` SET `level` = '1', `health` = '200', `healthmax` = '200', `mana` = '100', `manamax` = '100', `experience` = '0', `cap` = '500' WHERE `id` = " .. playerId)
		else
		selfSay("You need "..cost.." gold for first promotion!", cid)
	end --kasa
	else
	 return selfSay("You need finish Second Promotion Challenge! You need finish RAID Volcanic Castle on Hard Difficulty!", cid)
	end
end --slowo
	------------------------------------------SECOND PlayerStorage.reborn------------------------------------------------
if msgcontains(msg, "third promotion") then
    local player = Player(cid)
	local vocId = player:getVocation():getId()
	local cost = 10000000
	if player:getStorageValue(PlayerStorage.promotionStorage) >= 3 then
	if player:getLevel() <= 999 then
    return selfSay("You must be level 1000 for the third promotion!", cid)
    end
	if player:getStorageValue(PlayerStorage.reborn) > 1 then
    return selfSay("You have done third promotion!", cid)
    end
	if player:getStorageValue(PlayerStorage.reborn) == 0 then
	return selfSay("You not done second promotion!", cid)
	end
	if player:getStorageValue(PlayerStorage.reborn) == -1 then
	return selfSay("You not first second promotion!", cid)
	end
	if player:removeTotalMoney(10000000) then
		for i = 1, 200 do
			player:setStorageValue(65000 + i, -1)
			player:setStorageValue(1510 + i, -1)
		end
		if vocId == 19 or vocId == 23 then
			player:setVocation(vocId + 1)
		else
			player:setVocation(vocId + 4)
		end
		player:getPosition():sendMagicEffect(CONST_ME_FIREWORK_BLUE)
		player:setStorageValue(PlayerStorage.reborn, 2)
		player:setStorageValue(PlayerStorage.rebornMessageAfterLogin, 2)
		player:addAura(15)
		local bag = player:addItem(1988, 1)
		bag:addItem(26555, 35)
		bag:addItem(26805, 20)
		bag:addItem(36671, 15)
		bag:addItem(24850, 100)
		bag:addItem(24850, 100)
		bag:addItem(24850, 100)
		player:addItem(10128, 1)
		player:addStatsPoints(15)
		selfSay("You have recieved the third promotion. You are now "..player:getVocation():getName().."! You attack speed increase!\nYou have gained 15 extra stat point!", cid)
	local playerId = player:getGuid()
    player:remove()  
 --   db.query("UPDATE `players` SET `level` = '1', `health` = '200', `healthmax` = '200', `mana` = '100', `manamax` = '100', `experience` = '0', `cap` = '500' WHERE `id` = " .. playerId)
		else
		selfSay("You need "..cost.." gold for third promotion!", cid)
	end --kasa
	else
	 return selfSay("You need finish Second Promotion Challenge! You need finish RAID Prison on Hard Difficulty!", cid)
	end
end --slowo

if msgcontains(msg, "second reward") then
	local player = Player(cid)
	if player:getStorageValue(PlayerStorage.reborn) >= 1 then
    selfSay("You have done third promotion and you obtain Assassin Outfit!", cid)
	player:addOutfitAddon(156, 3)
	player:addOutfit(156)
	player:addOutfitAddon(152, 3)
	player:addOutfit(152)
	else
		selfSay("Go away!", cid)
    end
end

if msgcontains(msg, "third reward") then
	local player = Player(cid)
	if player:getStorageValue(PlayerStorage.reborn) >= 2 then
    selfSay("You have done third promotion and you obtain Violet Aura!", cid)
	player:addAura(15)
	else
		selfSay("Go away!", cid)
    end
end

---end script
    return true
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new())