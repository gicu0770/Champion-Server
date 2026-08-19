function onLogin(player)

	player:sendExtendedOpcode(250, json.encode({data = 1}))

	if player:getStorageValue(PlayerStorage.manaBarOption) == -1 then
		player:setStorageValue(PlayerStorage.manaBarOption, 0)
	end
	player:setStorageValue(41875 + 1, 1) -- waypoint
	player:refreshBalance()

	stopEvent(GoblinPortalKick)
	stopEvent(RiftPortalKick)
	local ip = Game.convertIpToString(player:getIp())
	local playerId = player:getGuid()
	db.query("UPDATE `players` SET `ip` = '" .. ip .. "' WHERE `id` = " .. playerId)
	player:openChannel(15)
	player:openChannel(1)
	player:setStorageValue(28002, -1)


	---------------------------------------------------------------

	local loginStr = "Welcome to " .. configManager.getString(configKeys.SERVER_NAME) .. "!"
	if player:getLastLoginSaved() <= 0 then
		player:startQuest(1)
		player:setRelictBoxWeight(30)
		player:setStorageValue(PlayerStorage.QuestTrackerActive, 0)
	else
		if loginStr ~= "" then
			player:sendTextMessage(MESSAGE_STATUS_DEFAULT, loginStr)
		end

		loginStr = string.format("Your last visit was on %s.", os.date("%a %b %d %X %Y", player:getLastLoginSaved()))
	end
	player:sendTextMessage(MESSAGE_STATUS_DEFAULT, loginStr)


	if getWorldUpTime() <= 120 then
		player:addBuff(RESTART_IMMORTAL)
	end

	-- Stamina
	nextUseStaminaTime[player.uid] = 0

	-- Promotion
	local vocation = player:getVocation()
	local promotion = vocation:getPromotion()
	if player:isPremium() then
		local value = player:getStorageValue(PlayerStorageKeys.promotion)
		if not promotion and value ~= 1 then
			player:setStorageValue(PlayerStorageKeys.promotion, 1)
		elseif value == 1 then
			player:setVocation(promotion)
		end
	elseif not promotion then
		player:setVocation(vocation:getDemotion())
	end

	player:removeCondition(CONDITION_ATTRIBUTES, CONDITION_REGENERATION, 900002)
	player:removeCondition(CONDITION_ATTRIBUTES, CONDITIONID_COMBAT, 900001)
	player:removeCondition(CONDITION_ATTRIBUTES, CONDITIONID_COMBAT, 900003)
	player:removeCondition(CONDITION_ATTRIBUTES, CONDITIONID_COMBAT, 900004)
	-- 900005 reserverd
	-- HP/mana adjust
	local vocation = player:getVocation()
	local level = player:getLevel()
	--------------------------------------------------------------- FUSION VOCATION

	local capson = 0
	if player:getStorageValue(PlayerStorage.reborn) >= 1 then
		capson = player:getStorageValue(PlayerStorage.reborn) * 50000
	end
	local supposedcap = 50000 + (vocation:getCapacityGain() * level) + capson
	local supposedhealth = CHAMPION_STATS[vocation:getName()].hp_start + (((CHAMPION_STATS[vocation:getName()].hp_level - CHAMPION_STATS[vocation:getName()].hp_start) / 50) * level) -- CHAMPION_STATS[player:getVocation():getName()].hp_start + (CHAMPION_STATS[player:getVocation():getName()].hp_level * player:getLevel())
	if supposedhealth ~= player:getMaxHealth() then
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Server detected your max health was wrongly set at " .. player:getMaxHealth() .. " and we adjusted it to " .. supposedhealth .. " automatically.")
		player:setMaxHealth(supposedhealth)
		player:addHealth(supposedhealth)
	end
	local supposedmana = CHAMPION_STATS[vocation:getName()].mana + (((CHAMPION_STATS[vocation:getName()].manaPL - CHAMPION_STATS[vocation:getName()].mana) / 50) * level) -- CHAMPION_STATS[player:getVocation():getName()].mana + (CHAMPION_STATS[player:getVocation():getName()].manaPL * player:getLevel())
	if supposedmana ~= player:getMaxMana() then
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Server detected your max mana was wrongly set at " .. player:getMaxMana() .. " and we adjusted it to " .. supposedmana .. " automatically.")
		player:setMaxMana(supposedmana)
		player:addMana(supposedmana)
	end
	if supposedcap ~= player:getCapacity() then
		--player:sendTextMessage(MESSAGE_STATUS_DEFAULT, "Server detected your max capacity was wrongly set at " .. (player:getCapacity() / 100) .. " and we adjusted it to " .. supposedcap/100 .. " automatically.")
		player:setCapacity(supposedcap)
	end
	player:sendTextMessage(MESSAGE_STATUS_DEFAULT,"[System] For level " ..player:getLevel() ..", your max HP should be: " .. supposedhealth .. " max mana should be: " .. supposedmana .. ".")

	player:addHealth(50000)
	player:addMana(50000)
	-- Events
	player:registerEvent("HiddenBosses")
	player:registerEvent("UpgradeSystemHealth")
	player:registerEvent("UpgradeSystemDeath")
	player:registerEvent("DungeonReward")
	player:registerEvent("EliteAffixHP")
	player:registerEvent("EliteAffixMANA")
	player:registerEvent("EliteKill")
	player:registerEvent("DungeonBossRemoveItem")
	player:registerEvent("AttributesSlots")
	player:registerEvent("DailyRewards")
	player:registerEvent("BattlePass")
	player:registerEvent("EventDPS")
	player:registerEvent("BossONLINE")
	player:registerEvent("GameStore")
	player:registerEvent("BossKICK")
	player:registerEvent("BossTP")
	player:registerEvent("BossCHEST")
	player:registerEvent("Travel")
	player:registerEvent("Access")
	player:registerEvent("Access2")
	player:registerEvent("PlayerDeath")
	player:registerEvent("ItemsTooltips")
	player:registerEvent("GrizzlyTasks")
	player:registerEvent("demonOak")
	player:registerEvent("Upgrades")
	player:registerEvent("PrivateShop")
	player:registerEvent("UpgradePlus")
	player:registerEvent("DarkTower")
	player:registerEvent("CharacterStats")
	player:registerEvent("CharacterStatsAdvance")
	player:registerEvent("Inspect")
	player:registerEvent("AtrributeSkills")
	player:registerEvent("Waypoints")
	player:registerEvent("Options")
	player:registerEvent("DailyQuest")
	player:registerEvent("DailyQuestKill")
	player:registerEvent("bot")
	player:registerEvent("QuestLog")

	player:registerEvent("ExpLoss")
	player:registerEvent("LevelUp")
	player:registerEvent("DungeonDeath")

	player:updateCharacterStats()

	local cid = player:getId()
	addEvent(function()
		local player = Player(cid)
		if player then
			player:setCollectionInfo()
		end
	end, 50)

	if player:getGroup():getId() == 3 then
		player:setTitle("Game Master", "Reggae One-10px-bordered", "#0dff00")
	end

  local currentLevel = player:getLevel() - 1
  local lastStatLevel = player:getStorageValue(PlayerStorageKeys.characterStatsLevel)

  if lastStatLevel < currentLevel then
    local statPointsToAdd = currentLevel - lastStatLevel
    player:addStatsPoints(statPointsToAdd)
    player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You have gained " .. statPointsToAdd .. " stat point(s).")
    player:setStorageValue(PlayerStorageKeys.characterStatsLevel, currentLevel)
  end


	PLAYER_DPS[cid] = nil
	PLAYER_EVENTS[cid] = nil

	local relictBox = player:getSlotItem(CONST_SLOT_RELICT_BOX)
	if relictBox then
		local maxWeight = relictBox:getCustomAttribute("maxWeight") or 0
		if maxWeight > 0 then
			local totalWieght = 0
			local relictItems = relictBox:getItems()
			for _, item in ipairs(relictItems) do
				local relictData = BOSS_DROPS_BY_ID[item:getId()]
				if relictData then
					local rarity = item:getRarityId() or 1
					if rarity < 1 then
						rarity = 1
					elseif rarity > 4 then
						rarity = 4
					end
					totalWieght = totalWieght + relictData.weight[rarity]
				else
					print("something wron with relict " .. item:getId())
				end
			end

			relictBox:setCustomAttribute("usedWeight", totalWieght)
		end
	end

	return true
end
