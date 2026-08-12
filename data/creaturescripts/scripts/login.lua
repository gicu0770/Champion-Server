function onLogin(player)
	-- if player:getName() == "Gicu" or player:getName() == "Zocha" or player:getName() == "BoTeQ" then
	-- 	local playerPos = player:getPosition()
    -- 	local position = Position(playerPos.x + 4, playerPos.y + 4, playerPos.z)
	-- 	position:sendMagicEffect(581, 1)
	-- end
	if player:completedQuest(22) and player:getStorageValue(PlayerStorage.sideBoss15) < 0 then -- Blackfang Archer
		player:setStorageValue(PlayerStorage.sideBoss15, 1)
		player:sendExtendedOpcode(71, json.encode({ text = "You have defeated Blackfang Archer and gained +10% Overpower Damage!", color = "#f7ef8a" }))
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You have defeated Blackfang Archer and gained +10% Overpower Damage!")
	end
	if player:completedQuest(23) and player:getStorageValue(PlayerStorage.sideBoss16) < 0 then -- Thunderlord
		player:setStorageValue(PlayerStorage.sideBoss16, 1)
		player:sendExtendedOpcode(71, json.encode({ text = "You have defeated Thunderlord and gained +10% Overpower Damage!", color = "#f7ef8a" }))
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You have defeated Thunderlord and gained +10% Overpower Damage!")
	end
	if player:completedQuest(24) and player:getStorageValue(PlayerStorage.sideBoss17) < 0 then -- Holy Protector
		player:setStorageValue(PlayerStorage.sideBoss17, 1)
		player:sendExtendedOpcode(71, json.encode({ text = "You have defeated Holy Protector and gained +10% Overpower Damage!", color = "#f7ef8a" }))
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You have defeated Holy Protector and gained +10% Overpower Damage!")
	end
	if player:completedQuest(25) and player:getStorageValue(PlayerStorage.sideBoss18) < 0 then -- Frost Beast
		player:setStorageValue(PlayerStorage.sideBoss18, 1)
		player:sendExtendedOpcode(71, json.encode({ text = "You have defeated Frost Beast and gained +10% Overpower Damage!", color = "#f7ef8a" }))
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You have defeated Frost Beast and gained +10% Overpower Damage!")
	end


	if player:getStorageValue(PlayerStorage.portalVoort) >= 1 then
		player:setStorageValue(PlayerStorage.portalVoort, -1)
	end
	if player:getStorageValue(PlayerStorage.reborn) < 0 then
		player:setStorageValue(PlayerStorage.reborn, 0)
	end
	player:sendExtendedOpcode(250, json.encode({data = 1}))

	if player:getStorageValue(PlayerStorage.manaBarOption) == -1 then
		player:setStorageValue(PlayerStorage.manaBarOption, 0)
	end
	player:setStorageValue(41875 + 1, 1) -- waypoint
	player:refreshBalance()
	player:setStorageValue(PlayerStorage.riftBlokade, -1)

	stopEvent(GoblinPortalKick)
	stopEvent(RiftPortalKick)


	local traits = {
		{ check = function(p) return p:isArcher() end, id = 3, buff = ARCHER_TRAIT },
		{ check = function(p) return p:isSorcerer() end, id = 1, buff = SORCERER_TRAIT },
		{ check = function(p) return p:isDruid() end, id = 2, buff = DRUID_TRAIT },
		{ check = function(p) return p:isPaladin() end, id = 17, buff = PALADIN_TRAIT },
		{ check = function(p) return p:isKnight() end, id = 4, buff = KNIGHT_TRAIT },
		{ check = function(p) return p:isShadow() end, id = 21, buff = SHADOW_TRAIT }
	}

	for _, trait in ipairs(traits) do
		if trait.check(player) or player:getStorageValue(PlayerStorage.secondTrait) == trait.id then
			player:addBuff(trait.buff)
			player:setBuffStacks(trait.buff, player:getStorageValue(PlayerStorage.reborn) + 1)
			if trait.id == 3 then
				local hasteAdded = player:getBaseSpeed() * 15 / 100
				local conditionHaste = Condition(CONDITION_HASTE, CONDITIONID_DEFAULT)
				conditionHaste:setParameter(CONDITION_PARAM_SUBID, 717778)
				conditionHaste:setParameter(CONDITION_PARAM_TICKS, -1) --2 secs
				conditionHaste:setFormula(0.0, hasteAdded, 0.0, hasteAdded)
				player:addCondition(conditionHaste)
			else
				player:removeCondition(CONDITION_HASTE, CONDITIONID_DEFAULT, 717778)
			end
		end
	end

	

	------------------ AUTO BLESS -----------
	if player:getLevel() <= 3500 then
		for i = 1, 5 do
			player:addBlessing(i)
		end
		player:addBlessing(7)
		player:sendAdventurerBlessing()
	end
	if player:hasBlessing(7) or player:hasBlessing(5) then
		player:sendAdventurerBlessing()
	end
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
	local supposedhealth = 200 + (vocation:getHealthGain() * level)
	local supposedmana = 100 + (vocation:getManaGain() * level)
	--------------------------------------------------------------- FUSION VOCATION

	local capson = 0
	if player:getStorageValue(PlayerStorage.reborn) >= 1 then
		capson = player:getStorageValue(PlayerStorage.reborn) * 50000
	end
	local supposedcap = 50000 + (vocation:getCapacityGain() * level) + capson
	if supposedhealth ~= player:getMaxHealth() then
		--player:sendTextMessage(MESSAGE_STATUS_DEFAULT, "Server detected your max health was wrongly set at " .. player:getMaxHealth() .. " and we adjusted it to " .. supposedhealth .. " automatically.")
		player:setMaxHealth(supposedhealth)
		player:addHealth(supposedhealth)
	end
	if supposedmana ~= player:getMaxMana() then
		--player:sendTextMessage(MESSAGE_STATUS_DEFAULT, "Server detected your max mana was wrongly set at " .. player:getMaxMana() .. " and we adjusted it to " .. supposedmana .. " automatically.")
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
