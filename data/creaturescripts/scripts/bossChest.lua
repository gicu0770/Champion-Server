local config = {
	['shadow illusion'] = { area = Position(1184, 1246, 7), range = 16 },
	['c-t125'] = { area = Position(1184, 1246, 7), range = 16 },
	['heavenly reaper'] = { area = Position(1184, 1246, 7), range = 16 },
	['azmodan'] = { area = Position(1184, 1246, 7), range = 16 },
	['ddd'] = { area = Position(150, 134, 7), range = 14 }
}

function onDeath(creature, corpse, killer, mostDamage, unjustified, mostDamage_unjustified)
	local upgradeCrystals = { 26555, 18413, 18415, 18422, 18421, 18420 }
	local upgradeBooks = { 26806, 26807 }
	local monster = config[creature:getName():lower()]
	if monster then
		if not creature or creature:isPlayer() or not monster or creature:getMaster() then
			return true
		end
		if not creature:isMonster() then return true end
		local damageMeter = {}
		local damageMap = creature:getDamageMap()
		for id, damage in pairs(damageMap) do
			local player = Player(id)
			if player then
				local bossHP = creature:getMaxHealth()
				local damageDeal = damage.total
				local damageDealPercentage = damageDeal / bossHP * 100
				damageMeter[player:getId()] = { name = player:getName(), damagePercent = damageDealPercentage,damageValue = damageDeal }
			end
		end
		local playerInArea = Game.getSpectators(monster.area, false, false, monster.range, monster.range, monster.range,
			monster.range)
		for _, creature in pairs(playerInArea) do
			if Player(creature:getId()) then
				Position(creature:getPosition()):sendMagicEffect(CONST_ME_POFF)
				--			creature:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You found Boss Bag with rewards! Check you inbox!")
				local globalLoot = 1
				if getGlobalBuff(BUFF_GLOBAL_LOOT) then
					globalLoot = globalLoot + 0.5
				end
				local inbox = creature:getInbox()
				local bag = Game.createItem(28901, 1)

				local strongboxRewrds = {
					[1] = { minlevel = 1, maxlevel = 49, tierReward = BASIC_ITEMS_1, tier = 0 },
					[3] = { minlevel = 50, maxlevel = 120, tierReward = BASIC_ITEMS__2, tier = 0 },
					[2] = { minlevel = 121, maxlevel = 149, tierReward = BASIC_ITEMS__3, tier = 0 },
					[4] = { minlevel = 150, maxlevel = 199, tierReward = TIER_1_IDS, tier = 1 },
					[5] = { minlevel = 200, maxlevel = 299, tierReward = TIER_2_IDS, tier = 2 },
					[6] = { minlevel = 300, maxlevel = 499, tierReward = TIER_3_IDS, tier = 3 },
					[7] = { minlevel = 500, maxlevel = 699, tierReward = TIER_4_IDS, tier = 4 },
					[8] = { minlevel = 700, maxlevel = 899, tierReward = TIER_5_IDS, tier = 5 },
					[9] = { minlevel = 900, maxlevel = 1099, tierReward = TIER_6_IDS, tier = 6 },
					[10] = { minlevel = 1100, maxlevel = 1299, tierReward = TIER_7_IDS, tier = 7 },
					[11] = { minlevel = 1300, maxlevel = 1549, tierReward = TIER_8_IDS, tier = 8 },
					[12] = { minlevel = 1550, maxlevel = 1699, tierReward = TIER_9_IDS, tier = 9 },
					[13] = { minlevel = 1700, maxlevel = 3000, tierReward = TIER_10_IDS, tier = 10 },
				}

				local level = creature:getLevel()
				if level >= 1500 then
					local paragonLevel = creature:getStorageValue(PlayerStorage.paragonLevel)
					if paragonLevel == -1 then
						paragonLevel = 0
					end
					level = level + paragonLevel
				end
				for i = 1, #strongboxRewrds do
					if level >= strongboxRewrds[i].minlevel and level <= strongboxRewrds[i].maxlevel then
						tierReward = strongboxRewrds[i].tierReward
						tier = strongboxRewrds[i].tier
					end
				end
				local rarityChance = 4
				local rewardCounts = 5
				local influ = true
				local legendaPlus = true
				for i = 1, rewardCounts do
					local rewardEvent = bag:addItem(tierReward[math.random(#tierReward)], 1)
					rewardEvent:setHighRarityItem(rarityChance)
					--[[
					if influ then
						local influRoll = math.random(1, 15)
						if math.random(100000) <= 250 then influRoll = math.random(17, 25) end
						if math.random(100000) <= 25000 then
							rewardEvent:setInfluenced(influRoll)
						end
						if legendaPlus then
							rewardEvent:setLegendaryItem(1)
							rewardEvent:setWorldBoss(1)
						end
					end
					--]]
					rewardEvent:setWorldBoss(1)
					setLootItem(creature, rewardEvent, tier)
				end
				randomPotionLoot(creature, corpse, 20000, 7000, 5000, 700)
			--	currencyDrop(creature, corpse, 1, 10, 1, 2500, 1, 8000, 5)
			--	randomFragments(creature, corpse, 1, 300, 2, 5000, 3, 50000, 200)
				if math.random(100000) <= 100000 then
					randomSpellRune(creature, corpse, 10000, 4000, 500)
				end
				if math.random(100000) <= 100000 then
					randomSupportRune(creature, corpse, 3500, 2000, 400)
				end
				--[[
				if math.random(1, 100000) <= 100000 then
					local crystalInflu = Game.createItem(21399, 1)
					local influRoll = math.random(1, 16)
					if math.random(100000) <= 3000 then
						influRoll = math.random(17, 25)
					end
					crystalInflu:setInfluenced(influRoll)
					local influ_name = influenced_info[influRoll].name
					crystalInflu:setAttribute(ITEM_ATTRIBUTE_NAME, "" .. influ_name .. " Influenced Token")
					crystalInflu:moveTo(bag)
				end
				--]]
				bag:setAttribute(ITEM_ATTRIBUTE_NAME, "Boss Bag")
				local randomm = math.random(5000, 20000)

				if creature:getPosition():getDistance(corpse:getPosition()) <= 30 then
					creature:setBankBalance(creature:getBankBalance() + randomm)
					creature:refreshBalance()
					if not bag:moveTo(creature:getSlotItem(CONST_SLOT_BACKPACK)) then
						inbox:addItemEx(bag, INDEX_WHEREEVER, FLAG_NOLIMIT)
					end
				end
				local description, items = "Congratulations, you defeated the boss!\nYou rewards: ", bag:getItems()
				for _, item in pairs(items) do
					description = string.format("%s%d {%s}%s", description, item:getCount(), item:getName(),
						(_ == #items and '.\nDamage Meter:\n' or ', '))
				end
				creature:addExperience(getExpForLevel(creature:getLevel() + 1) - creature:getExperience(), false)
				local paragonLevel = creature:getStorageValue(PlayerStorage.paragonLevel)
				local amount = ((creature:getExperience() * 0.3) / 100) / 10
				if creature:getLevel() >= 1500 then
					creature:setStorageValue(PlayerStorage.paragonLevel, paragonLevel + 1) -- paragon level
					-- creature:paragonUP(amount, true)
					-- creature:addStatsPoints(1)
				end
				local expp = comma_value(getExpForLevel(creature:getLevel() + 1) - creature:getExperience())
				local goldD = comma_value(randomm)
				if creature:getPosition():getDistance(corpse:getPosition()) <= 20 then
					for id, value in pairs(damageMeter) do
						description = string.format("%s {%s}: %.2f%%  %s\n", description, value.name, value.damagePercent, shortNumbers(value.damageValue, 2))
					end
					if creature:getLevel() >= 1500 then
						creature:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE,
							description .. '\nGold: {' ..
							goldD .. '}\nParagon EXP +{' .. amount .. '}\nCheck your depot inbox!')
						creature:sendExtendedOpcode(216,
							json.encode({
								text = description ..
								'\nGold: {' .. goldD .. '}\nParagon EXP +{' .. amount .. '}\nCheck your depot inbox!',
								color = "#f7ef8a" }))
					else
						creature:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE,
							description .. '\nGold: {' .. goldD .. '}\nEXP: {' .. expp .. '}\nCheck your depot inbox!')
						creature:sendExtendedOpcode(216,
							json.encode({
								text = description .. '\nGold: {' ..
								goldD .. '}\nEXP: {' .. expp .. '}\nCheck your depot inbox!', color = "#f7ef8a" }))
					end
				else
					creature:sendExtendedOpcode(216,
						json.encode({
							text =
							"You were too far from the boss!\nOr you did not deal any damage!\nYou do not receive a reward!",
							color = "#f7ef8a" }))
				end
			end
		end


		local buffName = ""
		local tim = 0
		local globalBoostRandom = { BUFF_GLOBAL_DAMAGE, BUFF_GLOBAL_DAMAGE_REDUCTION, BUFF_GLOBAL_HEALING,
			BUFF_GLOBAL_FOSSIL, BUFF_GLOBAL_UPGRADE_MATERIALS_COUNT }
		local boostChoosen = globalBoostRandom[math.random(#globalBoostRandom)]
		if boostChoosen == BUFF_GLOBAL_EXP then
			buffName = "50% Bonus Exp"
			tim = 3600000
		elseif boostChoosen == BUFF_GLOBAL_GOLD then
			buffName = "50% Bonus Gold"
			tim = 3600000
		elseif boostChoosen == BUFF_GLOBAL_LOOT then
			buffName = "50% Bonus Loot"
			tim = 3600000
		elseif boostChoosen == BUFF_GLOBAL_SKILL then
			buffName = "100% Bonus Skill"
			tim = 3600000
			storageGlobal = GlobalStorageKeys.globalSKILLtime
		elseif boostChoosen == BUFF_GLOBAL_DAMAGE then
			buffName = "+20% Damage against Monsters"
			tim = 3600000
		elseif boostChoosen == BUFF_GLOBAL_DAMAGE_REDUCTION then
			buffName = "+10% Damage Reduction against Monsters"
			tim = 3600000
		elseif boostChoosen == BUFF_GLOBAL_HEALING then
			buffName = "You healing increased by 10%"
			tim = 3600000
		elseif boostChoosen == BUFF_GLOBAL_FOSSIL then
			buffName = "Your chance of Fossil Crystal is doubled"
			tim = 3600000
		elseif boostChoosen == BUFF_GLOBAL_UPGRADE_MATERIALS_COUNT then
			buffName = "Upgrade Materials Amount increased +3"
			tim = 3600000
		end
		if getGlobalBuff(boostChoosen) then
			tim = tim + (getGlobalBuff(boostChoosen).endTime - (os.time() * 1000))
			for _, targetPlayer in ipairs(Game.getPlayers()) do
				local buffMessage = string.format("Boss defeated and extended {%s} global boost by {1h}!", buffName)
				targetPlayer:sendExtendedOpcode(71, json.encode({ text = buffMessage, color = "#f7ef8a" }))
			end
		else
			for _, targetPlayer in ipairs(Game.getPlayers()) do
				local buffMessage = string.format("Boss defeated and activated {%s} global boost by {1h}!", buffName)
				targetPlayer:sendExtendedOpcode(71, json.encode({ text = buffMessage, color = "#f7ef8a" }))
			end
		end
		addGlobalBuff(boostChoosen, tim)
	end
	return true
end
