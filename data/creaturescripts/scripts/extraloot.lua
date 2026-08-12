function onDeath(creature, corpse, killer, mostDamage, unjustified, mostDamage_unjustified)
    if configManager.getNumber(configKeys.RATE_LOOT) == 0 then
        return
    end
if not creature:isMonster() then
return true
end




    local currencies = {
        [2148] = 1,
        [2152] = 100,
        [2160] = 10000
    }

    local player = Player(corpse:getCorpseOwner())
    local mType = creature:getType()
    if not player or player:getStamina() > 840 then
        local currencyTransferAmount = 1
        
        local monsterLoot = mType:getLoot()
        for i = 1, #monsterLoot do
            local status, item = corpse:createLootItem(monsterLoot[i])
            if item then
                --print(item.itemid)
                if currencies[item:getType():getId()] ~= nil then
                --print("coins")
                    if player and player:isPremium() then
                        currencyTransferAmount = ((currencyTransferAmount + item:getCount()) * currencies[item:getType():getId()])
                        --item:remove()
						item:moveTo(player)
                    end
                end
				
            else
                --print('[Warning] DropLoot:', 'Could not add loot item to corpse.')
            end
			
        end
		
		currencyTransferAmount = currencyTransferAmount * getConfigInfo('rateLootGold')
		if player and player:isPremium() then
		currencyTransferAmount = currencyTransferAmount * 1.20
		end
        if player then
            if currencyTransferAmount > 0 then
				local target = player:getTarget()
				local monsterLvl = creature:getMonsterLevel() / 2
				local totalMoney = currencyTransferAmount + monsterLvl
                player:setBankBalance(player:getBankBalance() + currencyTransferAmount + monsterLvl)
				local premiumbonus = currencyTransferAmount * 0.20
				if player and player:isPremium() then
				player:sendChannelMessage("", "Gold: " .. totalMoney .. " [ Premium: + 20% gold " .. premiumbonus .. " ]", TALKTYPE_CHANNEL_O, 9)
				else
				player:sendChannelMessage("", "Gold: " .. totalMoney .. ".", TALKTYPE_CHANNEL_O, 9)
				end
            end

			
			local target = player:getTarget()
			local monsterLvl = creature:getMonsterLevel()
            local text = ("Loot of %s Lv %s: %s"):format(mType:getNameDescription(), monsterLvl, corpse:getContentDescription())
            local party = player:getParty()
            if party then
                party:broadcastPartyLoot(text)
            else
                --player:sendTextMessage(MESSAGE_LOOT, text)
				player:sendChannelMessage("", ""..text.."", TALKTYPE_CHANNEL_R1, 9)
            end
        end
    else
        local text = ("Loot of %s: nothing (due to low stamina)"):format(mType:getNameDescription())
        local party = player:getParty()
        if party then
            party:broadcastPartyLoot(text)
        else
            --player:sendTextMessage(MESSAGE_LOOT, text)
			player:sendChannelMessage("", ""..text.."", TALKTYPE_CHANNEL_R1, 9)
        end
    end
	
end