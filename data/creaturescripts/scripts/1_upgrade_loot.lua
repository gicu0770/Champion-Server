function onDeath(creature, corpse, killer, mostDamage, unjustified, mostDamage_unjustified)
	if not creature or creature:isPlayer() or creature:getMaster() then
		return true
	end
	if not killer then
		return false
	end

	local lootMnoznik = 0
	local reduction = 1
	local lootSuma = 1
	local count = 1
	local lootRate = configManager.getNumber(configKeys.RATE_LOOT)
	if corpse or not corpse.itemid == 0 and killer and killer:isPlayer() then
		if getGlobalBuff(BUFF_GLOBAL_LOOT) then
			lootSuma = lootSuma + 0.2
		end
--		if getGlobalBuff(BUFF_GLOBAL_UPGRADE_MATERIALS_COUNT) then
--			count = count + 3
--		end
		if killer:hasBuff(STORE_LOOT_BOOST) then
			lootSuma = lootSuma + 0.2
		end
		if killer:hasBuff(MONSTER_SOUL_LOOT) then
			lootSuma = lootSuma + 0.1
		end
		if creature and creature:isMonster() then
			if creature:getSkull() > 6 then
				lootSuma = lootSuma + 0.2
			end
			if creature:getSkull() == 26 then
				lootSuma = 100000
			end
			if creature:getSkull() == 27 then
				lootSuma = lootSuma + 0.5
			end
			lootSuma = lootSuma + lootMnoznik
			lootSuma = lootSuma * lootRate
			local mType = creature:getType()
			local class = mType:items()
			local tier = mType:tier()
			local isDungeon = false
			local dungeon = killer:getDungeon()
			if dungeon then
				local instance = dungeon:getPlayerInstance(killer)
				if instance then
					isDungeon = false
				end
			end
			if not isDungeon and tier >= 1 then
				local UMchance = 7500 * lootSuma
				local up = UMchance / 1000
				if math.random(100000) <= UMchance then
					count = count + math.random(1, 3)
					if creature:getStorageValue(PlayerStorage.animationORtext) == -1 then
						creature:getPosition():sendMagicEffect(291)
					else
						Game.sendAnimatedText("Upgrade Material", creature:getPosition(), 350, "Reggae One-20px-bordered")
					end

					if class == "acc" then
						corpse:addItem(SCRAP_ACC[tier][1], count)
						if math.random(100) <= 25 then
							corpse:addItem(SCRAP_ACC[tier][2], count)
						end
					elseif class == "set" then
						corpse:addItem(SCRAP_SET[tier][1], count)
						if math.random(100) <= 25 then
							corpse:addItem(SCRAP_SET[tier][2], count)
						end
					elseif class == "falcon" or class == "spectre" or class == "fungus" then
						corpse:addItem(SCRAP_SET[tier][1], count)
						if math.random(100) <= 25 then
							corpse:addItem(SCRAP_SET[tier][2], count)
						end
					end
				end
				local tickerChance = (1000 * lootSuma) -- 2000 * lootSuma
				if mType:items() == "onehit" or mType:items() == "fragments" or mType:items() == "looter" or mType:items() == "corrupted" then
				else
					if not isDungeon and math.random(100000) <= tickerChance then
						if creature:getStorageValue(PlayerStorage.animationORtext) == -1 then
							creature:getPosition():sendMagicEffect(292)
						else
							Game.sendAnimatedText("Ticket", creature:getPosition(), 330, "Reggae One-20px-bordered")
						end
						if class == "acc" then
							corpse:addItem(TICKET_ACC[tier][math.random(#TICKET_ACC[tier])], 1)
						elseif class == "set" then
							corpse:addItem(TICKET_SET[tier][math.random(#TICKET_SET[tier])], 1)
						elseif class == "falcon" then
							corpse:addItem(TICKET_ACC[tier].falcon, 1)
						elseif class == "spectre" then
							corpse:addItem(TICKET_ACC[tier].spectre, 1)
						elseif class == "fungus" then
							corpse:addItem(TICKET_ACC[tier].fungus, 1)
						end
					end
				end
			end
		end
	end
	return true
end