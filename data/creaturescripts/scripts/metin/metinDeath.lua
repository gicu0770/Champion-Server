function onDeath(creature, corpse, killer, mostDamage, unjustified, mostDamage_unjustified)
	local creatruresPLAYER = Game.getSpectators(corpse:getPosition(), false, false, 10, 10, 10, 10)
	for _, creatureT in pairs(creatruresPLAYER) do
		if Player(creatureT:getId()) and creatureT:getStorageValue(PlayerStorage.riftReward) == 1 then
			Position(creatureT:getPosition()):sendMagicEffect(CONST_ME_POFF)
			creatureT:setStorageValue(PlayerStorage.riftReward, -1)
	local globalLoot = 1
	if getGlobalBuff(BUFF_GLOBAL_LOOT) then
		globalLoot = globalLoot + 0.5
	end	
-------------------------------------------		
if creature:getName() == "First Rift Portal" then	
	local bag = Game.createItem(1992, 1)
	local inbox = creatureT:getInbox()
	bag:setAttribute(ITEM_ATTRIBUTE_NAME, "Reward Bag")
		bag:addItem(26805, math.random(1,2), INDEX_WHEREEVER, FLAG_NOLIMIT)
		bag:addItem(26806, math.random(1,2), INDEX_WHEREEVER, FLAG_NOLIMIT)
		bag:addItem(26807, math.random(1,2), INDEX_WHEREEVER, FLAG_NOLIMIT)
		bag:addItem(24850, math.random(1,10), INDEX_WHEREEVER, FLAG_NOLIMIT)
		bag:addItem(21250, math.random(1,10), INDEX_WHEREEVER, FLAG_NOLIMIT)			
	if math.random(1,100000) <= 5000 * globalLoot then	-- 5000 = 5%
		bag:addItem(26804, 1, INDEX_WHEREEVER, FLAG_NOLIMIT)	-- high quality
	end
	if math.random(1,100000) <= 1000 * globalLoot then
		bag:addItem(26803, 1, INDEX_WHEREEVER, FLAG_NOLIMIT)	--	abiliyu
		end
	if math.random(1,100000) <= 1000 * globalLoot then
		bag:addItem(18423, 1, INDEX_WHEREEVER, FLAG_NOLIMIT)	--	abiliyu remover
	end
	inbox:addItemEx(bag, INDEX_WHEREEVER, FLAG_NOLIMIT)
	local description, items = "Congratulations, Rift Portal was defeated!\nYou rewards: ", bag:getItems()
            for _, item in pairs(items) do
                description = string.format("%s%d %s%s", description, item:getCount(), item:getName(), (_ == #items and '.' or ', '))
            end		
				creatureT:sendTextMessage(MESSAGE_EVENT_ADVANCE, description..'\nCheck your depot inbox.')
end			
if creature:getName() == "Second Rift Portal" then	
	local bag = Game.createItem(1992, 1)
	local inbox = creatureT:getInbox()
	bag:setAttribute(ITEM_ATTRIBUTE_NAME, "Reward Bag")
		bag:addItem(26805, math.random(1,4), INDEX_WHEREEVER, FLAG_NOLIMIT)
		bag:addItem(26806, math.random(1,4), INDEX_WHEREEVER, FLAG_NOLIMIT)
		bag:addItem(26807, math.random(1,4), INDEX_WHEREEVER, FLAG_NOLIMIT)
		bag:addItem(24850, math.random(1,20), INDEX_WHEREEVER, FLAG_NOLIMIT)
		bag:addItem(21250, math.random(1,20), INDEX_WHEREEVER, FLAG_NOLIMIT)
	if math.random(1,100000) <= 5000 * globalLoot then	-- 5000 = 5%
		bag:addItem(26804, 1, INDEX_WHEREEVER, FLAG_NOLIMIT)	-- high quality
	end
	if math.random(1,100000) <= 1000 * globalLoot then
		bag:addItem(26803, 1, INDEX_WHEREEVER, FLAG_NOLIMIT)	--	abiliyu
		end
	if math.random(1,100000) <= 1000 * globalLoot then
		bag:addItem(18423, 1, INDEX_WHEREEVER, FLAG_NOLIMIT)	--	abiliyu remover
	end
	inbox:addItemEx(bag, INDEX_WHEREEVER, FLAG_NOLIMIT)
	local description, items = "Congratulations, Rift Portal was defeated!\nYou rewards: ", bag:getItems()
            for _, item in pairs(items) do
                description = string.format("%s%d %s%s", description, item:getCount(), item:getName(), (_ == #items and '.' or ', '))
            end		
				creatureT:sendTextMessage(MESSAGE_EVENT_ADVANCE, description..'\nCheck your depot inbox.')
end		
if creature:getName() == "Third Rift Portal" then	
	local bag = Game.createItem(1992, 1)
	local inbox = creatureT:getInbox()
	bag:setAttribute(ITEM_ATTRIBUTE_NAME, "Reward Bag")
		bag:addItem(26805, math.random(1,6), INDEX_WHEREEVER, FLAG_NOLIMIT)
		bag:addItem(26806, math.random(1,6), INDEX_WHEREEVER, FLAG_NOLIMIT)
		bag:addItem(26807, math.random(1,6), INDEX_WHEREEVER, FLAG_NOLIMIT)
		bag:addItem(24850, math.random(1,30), INDEX_WHEREEVER, FLAG_NOLIMIT)
		bag:addItem(21250, math.random(1,30), INDEX_WHEREEVER, FLAG_NOLIMIT)
	if math.random(1,100000) <= 5000 * globalLoot then	-- 5000 = 5%
		bag:addItem(26804, 1, INDEX_WHEREEVER, FLAG_NOLIMIT)	-- high quality
	end
	if math.random(1,100000) <= 1000 * globalLoot then
		bag:addItem(26803, 1, INDEX_WHEREEVER, FLAG_NOLIMIT)	--	abiliyu
		end
	if math.random(1,100000) <= 1000 * globalLoot then
		bag:addItem(18423, 1, INDEX_WHEREEVER, FLAG_NOLIMIT)	--	abiliyu remover
	end
	inbox:addItemEx(bag, INDEX_WHEREEVER, FLAG_NOLIMIT)
	local description, items = "Congratulations, Rift Portal was defeated!\nYou rewards: ", bag:getItems()
            for _, item in pairs(items) do
                description = string.format("%s%d %s%s", description, item:getCount(), item:getName(), (_ == #items and '.' or ', '))
            end		
				creatureT:sendTextMessage(MESSAGE_EVENT_ADVANCE, description..'\nCheck your depot inbox.')
end			
------------------------------------------				
				
		end
	end
	

end