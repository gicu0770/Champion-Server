function Dungeon:onQueue()
	local queue = self:getQueue()
	local players = queue:getPlayers()
	if not players then
		return
	end

	local inQueue = queue:getPlayersNumber()
	for _, player in ipairs(players) do
		player:sendExtendedOpcode(
			ExtendedOPCodes.CODE_DUNGEONS,
			json.encode({ action = "queueUpdate", data = { id = self:getId(), queue = inQueue, estimated = self:getEstimatedQueueTime(player) } })
		)
		local party = player:getParty()
		if party then
			party:getLeader():sendExtendedOpcode(
				ExtendedOPCodes.CODE_DUNGEONS,
				json.encode({ action = "queueUpdate",
				data = { id = self:getId(), queue = inQueue, estimated = self:getEstimatedQueueTime(player) } })
			)
			local members = party:getMembers()
			for _, member in ipairs(members) do
				if member ~= player then
					member:sendExtendedOpcode(
						ExtendedOPCodes.CODE_DUNGEONS,
						json.encode({ action = "queueUpdate",
						data = { id = self:getId(), queue = inQueue, estimated = self:getEstimatedQueueTime(player) } })
					)
				end
			end
		end
	end
end

function Dungeon:onPrepare(instance, player)
	player:sendExtendedOpcode(ExtendedOPCodes.CODE_DUNGEONS, json.encode({ action = "prepare" }))
end

soloDungeons = {
	["Ice Castle"] = true,
	["Amethyst Peaks"] = true,
	["Golden Horizon"] = true,
	["Infernal Tar"] = true,
	["Pyramid Ruins"] = true,
	["Venom Grave"] = true,
	["Bonebound Arena"] = true,
	["Voidflare Arena"] = true,
	["Reaper Castle"] = true,
	["Molten Core"] = true,
	["Wildwood"] = true,
	["Frostbound"] = true,
	["Otherworld"] = true,
	["Firecastle Ruins"] = true,
	["Toxic Arena"] = true,
	["Bloodfall Arena"] = true,
}

specialDungeons = {
	["Golden Horizon"] = true,
	["Amethyst Peaks"] = true,
	["Golden Vault"] = true,
	["Ice Castle"] = true,
	["Infernal Tar"] = true,
	--Bridges Eldritch Bridge
	["Eldritch Bridge"] = true,
	["Gravebound Bridge"] = true,
	["Liberator Bridge"] = true,
	["Soulbound Bridge"] = true,
}

local forceLives = {
	["Ice Castle"] = 0,
	["Amethyst Peaks"] = 0,
	["Golden Horizon"] = 0,
	["Infernal Tar"] = 0,
	["Pyramid Ruins"] = 0,
	["Venom Grave"] = 0,
	["Bonebound Arena"] = 0,
	["Voidflare Arena"] = 0,
	["Reaper Castle"] = 0,
	["Molten Core"] = 0,
	["Wildwood"] = 0,
	["Frostbound"] = 0,
	["Otherworld"] = 0,
	["Firecastle Ruins"] = 0,
	["Toxic Arena"] = 0,
	["Bloodfall Arena"] = 0,
}

function Dungeon:onStart(instance, player)
	local config = INSTANCE_MONSTER_MODIFIERS[instance:getKeyUID()]
	local attr = {}
	local level = 0
	local tier = 0
	if config then
		config.started = os.time()
		attr = config.attr
		level = config.mlvl or 0
		tier = config.tier or 0

		if not config.chestSpawned then
			local positions = self:getRewardChestPositions()
			if positions then
				local chests = 2
				for i = 1, chests do
					local pos = positions[math.random(1, #positions)]
					if pos then
						pos.y = pos.y + (1000 * (instance:getId() - 1))
						local chest = Game.createItem(37413, 1, pos)
						if chest then
							instance:addItem(chest)
						end
					end
				end
			end

      config.chestSpawned = true
		end
	end

	local title = self:getTitle()
	if soloDungeons[title] then
		if not instance:getBoss() then
			spawnDungeonBoss(self, instance)
		end
	end

	if forceLives[title] then
		instance:setLives(forceLives[title])
	end


	player:addBuff(RESTART_IMMORTAL, 5000)
	player:sendExtendedOpcode(
		ExtendedOPCodes.CODE_DUNGEONS,
		json.encode(
			{
				action = "start",
				data = {
					level = level,
          tier = tier,
					boss = self:getBoss(),
					dType = self:getCompleteType(),
					left = instance:getMonstersTotalCount(),
					duration = self:getDuration(),
					objectives = self:getBonusObjectives(),
					title = self:getTitle(),
					lives = instance:getLives(),
					attr = attr,
				}
			}
		)
	)

end

function Dungeon:onFail(instance)
	local keyUID = instance:getKeyUID()
	if keyUID and INSTANCE_MONSTER_MODIFIERS[keyUID] then
		INSTANCE_MONSTER_MODIFIERS[keyUID] = nil
	end	
end

function Dungeon:onSuccess(instance)
	--[[
	local runners = instance:getRunners()
	local reqParty = self:getRequiredParty()
	local keyUID = instance:getKeyUID()
	local config = INSTANCE_MONSTER_MODIFIERS[keyUID]
	if config then
		if config.tier > 0 then
			for _, runner in ipairs(runners) do
				local conTier = config.tier
				local currentKeyTier = runner:getDungeonTier()
				local bossTier = runner:getStorageValue(PlayerStorage.endGameBossTierUnlocked)
				local allowed = false
				if conTier < 20 and bossTier >= 0 then allowed = true
				elseif conTier < 50 and bossTier >= 1 then allowed = true
				elseif conTier < 70 and bossTier >= 2 then allowed = true
				elseif conTier < 90 and bossTier >= 3 then allowed = true
				elseif conTier < 120 and bossTier >= 4 then allowed = true
				elseif conTier >= 120 and bossTier >= 5 then allowed = true
				end
				if not specialDungeons[self:getTitle()] then
					if allowed and conTier > currentKeyTier then
						runner:setDungeonTier(currentKeyTier + 1)
						if runner:getStorageValue(PlayerStorage.playerTier) < currentKeyTier then
							runner:setStorageValue(PlayerStorage.playerTier, currentKeyTier)
						end
					end
				end
			end
		end
	end
	--]]


	local runners = instance:getRunners()
	local keyUID = instance:getKeyUID()
	local config = INSTANCE_MONSTER_MODIFIERS[keyUID]

	if not config or config.tier <= 0 then
		return
	end

	local function isBossAllowed(tier, bossTier)
		if tier < 20 then
			return true
		elseif tier < 50 then
			return bossTier >= 1
		elseif tier < 70 then
			return bossTier >= 2
		elseif tier < 90 then
			return bossTier >= 3
		elseif tier < 120 then
			return bossTier >= 4
		else
			return bossTier >= 5
		end
	end

	for _, runner in ipairs(runners) do
		local playerTier = runner:getDungeonTier()
		local dungeonTier = config.tier
		local bossTier = runner:getStorageValue(PlayerStorage.endGameBossTierUnlocked)
		-- HARD GATE (boss requirement)
		if isBossAllowed(dungeonTier, bossTier) then
			-- ANTI-CARRY: tylko jeśli dungeon jest wyżej niż gracz
			if playerTier < dungeonTier then
				-- +1 PROGRESSION ONLY
				local newTier = playerTier + 1
				runner:setDungeonTier(newTier)
				runner:setStorageValue(PlayerStorage.playerTier, newTier)
			end
		end
	end



	if self:getTitle() == "Molten Core" then -- Nowa mapa Emberlord
		for _, runner in ipairs(runners) do
			if not runner:hasCompletedChallenge(ChallengesIndex.SPECTRE_DONE) then
				runner:completeChallenge(ChallengesIndex.SPECTRE_DONE)
				runner:sendExtendedOpcode(71, json.encode({ text = "Congratulations! {New Map} You can unlock new Waypoint! First Promotion!\nYour Health, Energy Shield Regeneration +5 and Mana Regeneration +1. Damage Reduction Penalty: -5%", color = "#f7ef8a" }))
				runner:setStorageValue(41875+6,1) -- new content fungus
				runner:setStorageValue(PlayerStorage.reborn, runner:getStorageValue(PlayerStorage.reborn) + 1)
				runner:finishQuest(2)
				runner:startQuest(3)
			end
		end
	end

	if self:getTitle() == "Otherworld" then -- Nowe drzewko talentow Voidlord
		for _, runner in ipairs(runners) do
			if not runner:hasCompletedChallenge(ChallengesIndex.FLAME_CAVE) then
				runner:completeChallenge(ChallengesIndex.FLAME_CAVE)
				runner:sendExtendedOpcode(71, json.encode({ text = "Congratulations! {New Map} You can unlock new Waypoint! Return to Orrn and choose {Second Talents}! Second Promotion!\nYour Health, Energy Shield Regeneration +5 and Mana Regeneration +1. Damage Reduction Penalty: -5%", color = "#f7ef8a" }))
				runner:setStorageValue(41875+11,1) -- new content libery
				runner:setStorageValue(999997, 0)
				runner:setStorageValue(PlayerStorage.reborn, runner:getStorageValue(PlayerStorage.reborn) + 1)
				runner:sendCurrentTalents()
				runner:finishQuest(4)
				runner:startQuest(5)
			end
		end
	end
	if self:getTitle() == "Toxic Arena" then -- Specialization
		for _, runner in ipairs(runners) do
			if not runner:hasCompletedChallenge(ChallengesIndex.SPECIALIZATION) then
				runner:completeChallenge(ChallengesIndex.SPECIALIZATION)
				runner:sendExtendedOpcode(71, json.encode({ text = "You have defeated {Forest Keeper}! You unlock {Specialization} look Talent window.", color = "#00ff00" }))
				runner:setStorageValue(PlayerStorage.specialization, 0)
				runner:sendCurrentTalents()
				runner:finishQuest(7)
				runner:startQuest(8)
			end
		end
	end
	if self:getTitle() == "Wildwood" then -- Fusion Ability Naturelord
		for _, runner in ipairs(runners) do
			if not runner:hasCompletedChallenge(ChallengesIndex.SWAMP_PIT_FUSION) then
				runner:completeChallenge(ChallengesIndex.SWAMP_PIT_FUSION)
				runner:sendExtendedOpcode(71, json.encode({ text = "Congratulations! {New Map} You can unlock new Waypoint! Your {Fusion Talent} now is unlocked! Third Promotion!\nYour Health, Energy Shield Regeneration +5 and Mana Regeneration +1. Damage Reduction Penalty: -5%", color = "#f7ef8a" }))
				runner:setStorageValue(41875+17,1) -- new content undead
				runner:setStorageValue(PlayerStorage.fusionTalent, 1)
				runner:sendCurrentTalents()
				runner:setStorageValue(PlayerStorage.reborn, runner:getStorageValue(PlayerStorage.reborn) + 1)
				runner:finishQuest(9)
				runner:startQuest(10)
			end
		end
	end
	if self:getTitle() == "Frostbound" then -- Trait last promotion Icelord
		for _, runner in ipairs(runners) do
			if not runner:hasCompletedChallenge(ChallengesIndex.UNDEAD_CAVE_TRAIT) then
				runner:completeChallenge(ChallengesIndex.UNDEAD_CAVE_TRAIT)
				runner:sendExtendedOpcode(71, json.encode({ text = "Congratulations! Return to Orrn and choose {Trait} from another vocations.", color = "#f7ef8a" }))
				runner:setStorageValue(PlayerStorage.trait, 1)
				runner:sendCurrentTalents()
				runner:finishQuest(11)
				runner:startQuest(12)
			end
		end
	end
	if self:getTitle() == "Firecastle Ruins" then -- Voort
		for _, runner in ipairs(runners) do
			if not runner:hasCompletedChallenge(ChallengesIndex.VOORT) then
				runner:completeChallenge(ChallengesIndex.VOORT)
				runner:sendExtendedOpcode(71, json.encode({ text = "Congratulations! {New Map} You can unlock new Waypoint! You have defeated {Voort}! The Age of Legends begins now.\nBrace yourself for the ultimate adventure!\nDamage Reduction Penalty: -10% and +5 Character Points, Penetration +15%\n{Unlocked [Golden Enhancement] check menu!}", color = "#f7ef8a" }))
				runner:setStorageValue(PlayerStorage.endGame, 1)
				runner:setDungeonTier(1)
				runner:setStorageValue(PlayerStorage.portalVoort, -1)
				runner:addStatsPoints(5)
				runner:finishQuest(14)
				runner:startQuest(15)
			end
		end
	end
	--[[
	BOSS_TIER = {
		[1] = { relictWeight = 50, storage = 1, name = "Venomgrizzle", message = "You have defeated {Venomgrizzle}! Prepare for the next challenge!", color = "#ff8800" },
		[2] = { relictWeight = 75, storage = 2, name = "Bonebound Stalker", message = "You have defeated {Bonebound Stalker}! The journey continues!", color = "#ff8800" },
		[3] = { relictWeight = 100, storage = 3, name = "Voidflare Wisp", message = "You have defeated {Voidflare Wisp}! Only one remains!", color = "#ff8800" },
		[4] = { relictWeight = 125, storage = 4, name = "Reaper Shade", message = "You have defeated {Reaper Shade}! All bosses conquered!", color = "#00ff00" },
	}
	--]]
	if self:getTitle() == "Venom Grave" then -- Venomgrizzle
		for _, runner in ipairs(runners) do
			if not runner:hasCompletedChallenge(ChallengesIndex.TIER_BOSS1) and runner:getStorageValue(PlayerStorage.endGameBossTierUnlocked) < 0 then
				runner:completeChallenge(ChallengesIndex.TIER_BOSS1)
				runner:sendExtendedOpcode(71, json.encode({ text = BOSS_TIER[1].message, color = BOSS_TIER[1].color }))
				runner:setStorageValue(PlayerStorage.endGameBossTierUnlocked, BOSS_TIER[1].storage)
				runner:addRelictBoxWeight(BOSS_TIER[1].relictWeight)
				runner:finishQuest(15)
				runner:startQuest(16)
			end
		end
	end
	if self:getTitle() == "Bonebound Arena" then -- Bonebound Stalker
		for _, runner in ipairs(runners) do
			if not runner:hasCompletedChallenge(ChallengesIndex.TIER_BOSS2) and runner:getStorageValue(PlayerStorage.endGameBossTierUnlocked) == 1 then
				runner:completeChallenge(ChallengesIndex.TIER_BOSS2)
				runner:sendExtendedOpcode(71, json.encode({ text = BOSS_TIER[2].message, color = BOSS_TIER[2].color }))
				runner:setStorageValue(41875+21,1) -- new content Toxic Gutterwork's
			--	runner:setStorageValue(PlayerStorage.endGameBossTierUnlocked, BOSS_TIER[2].storage)
				runner:addRelictBoxWeight(BOSS_TIER[2].relictWeight)
				runner:finishQuest(16)
				runner:startQuest(17)
			end
		end
	end
	-- dodatkowa linia
	if self:getTitle() == "Bloodfall Arena" then -- Blood Fury
		for _, runner in ipairs(runners) do
			if not runner:hasCompletedChallenge(ChallengesIndex.TIER_BOSS3) and runner:getStorageValue(PlayerStorage.endGameBossTierUnlocked) == 1 then
				runner:completeChallenge(ChallengesIndex.TIER_BOSS3)
				runner:sendExtendedOpcode(71, json.encode({ text = BOSS_TIER[3].message, color = BOSS_TIER[3].color }))
				runner:setStorageValue(PlayerStorage.endGameBossTierUnlocked, BOSS_TIER[3].storage)
				runner:addRelictBoxWeight(BOSS_TIER[3].relictWeight)
				runner:finishQuest(18)
				runner:startQuest(19)
			end
		end
	end

	if self:getTitle() == "Voidflare Arena" then -- Voidflare Wisp -- nowe ID questow
		for _, runner in ipairs(runners) do
			if not runner:hasCompletedChallenge(ChallengesIndex.TIER_BOSS4) and runner:getStorageValue(PlayerStorage.endGameBossTierUnlocked) == 3 then
				runner:completeChallenge(ChallengesIndex.TIER_BOSS4)
				runner:sendExtendedOpcode(71, json.encode({ text = BOSS_TIER[4].message, color = BOSS_TIER[4].color }))
				runner:setStorageValue(PlayerStorage.endGameBossTierUnlocked, BOSS_TIER[4].storage)
				runner:addRelictBoxWeight(BOSS_TIER[4].relictWeight)
				runner:finishQuest(19)
				runner:startQuest(20)
			end
		end
	end
	if self:getTitle() == "Reaper Castle" then -- Reaper Shade
		for _, runner in ipairs(runners) do
			if not runner:hasCompletedChallenge(ChallengesIndex.TIER_BOSS5) and runner:getStorageValue(PlayerStorage.endGameBossTierUnlocked) == 4 then
				runner:completeChallenge(ChallengesIndex.TIER_BOSS5)
				runner:sendExtendedOpcode(71, json.encode({ text = BOSS_TIER[5].message, color = BOSS_TIER[5].color }))
				runner:setStorageValue(PlayerStorage.endGameBossTierUnlocked, BOSS_TIER[5].storage)
				runner:addRelictBoxWeight(BOSS_TIER[5].relictWeight)
				runner:setStorageValue(PlayerStorage.reborn, runner:getStorageValue(PlayerStorage.reborn) + 1)
				runner:finishQuest(20)
				runner:startQuest(21)
			end
		end
	end

	if self:getTitle() == "Eldritch Bridge" then --  Bridge Dungeon
		for _, runner in ipairs(runners) do
			if not runner:hasCompletedChallenge(ChallengesIndex.BRIDGE_1) then
				runner:completeChallenge(ChallengesIndex.BRIDGE_1)
				runner:setStorageValue(PlayerStorage.sideBoss19, 1)
				runner:sendExtendedOpcode(71, json.encode({ text = "You have defeated Eldritch Reaver and gained +10% Overpower Damage!", color = "#f7ef8a" }))
				runner:finishQuest(26)
			end
		end
	end
	if self:getTitle() == "Gravebound Bridge" then --  Bridge Dungeon
		for _, runner in ipairs(runners) do
			if not runner:hasCompletedChallenge(ChallengesIndex.BRIDGE_2) then
				runner:completeChallenge(ChallengesIndex.BRIDGE_2)
				runner:setStorageValue(PlayerStorage.sideBoss20, 1)
				runner:sendExtendedOpcode(71, json.encode({ text = "You have defeated Grave Spearlord and gained +10% Overpower Damage!", color = "#f7ef8a" }))
				runner:finishQuest(27)
			end
		end
	end
	if self:getTitle() == "Liberator Bridge" then --  Bridge Dungeon
		for _, runner in ipairs(runners) do
			if not runner:hasCompletedChallenge(ChallengesIndex.BRIDGE_3) then
				runner:completeChallenge(ChallengesIndex.BRIDGE_3)
				runner:setStorageValue(PlayerStorage.sideBoss21, 1)
				runner:sendExtendedOpcode(71, json.encode({ text = "You have defeated Minotaur Liberator and gained +10% Overpower Damage!", color = "#f7ef8a" }))
				runner:finishQuest(28)
			end
		end
	end
	if self:getTitle() == "Soulbound Bridge" then --  Bridge Dungeon
		for _, runner in ipairs(runners) do
			if not runner:hasCompletedChallenge(ChallengesIndex.BRIDGE_4) then
				runner:completeChallenge(ChallengesIndex.BRIDGE_4)
				runner:setStorageValue(PlayerStorage.sideBoss22, 1)
				runner:sendExtendedOpcode(71, json.encode({ text = "You have defeated Soulbound Lich and gained +10% Overpower Damage!", color = "#f7ef8a" }))
				runner:finishQuest(29)
			end
		end
	end
--[[
	265 Venomgrizzle - Venom Grave
	600 Bonebound Stalker - Bonebound Arena
	900 Voidflare Wisp - Voidflare Arena
	1350 Reaper Shade - Reaper Castle
--]]

	if keyUID and INSTANCE_MONSTER_MODIFIERS[keyUID] then
		INSTANCE_MONSTER_MODIFIERS[keyUID] = nil
	end
end

-- Elite counter per instance
local instanceEliteCounters = {}

function Dungeon:onMonsterSpawn(instance, monster)
	local partyMebmers = self:getPlayersCount()
	monster:registerEvent("SpellHealthChangeEvent")
	monster:registerEvent("UpgradeSystemHealth")
	monster:registerEvent("UpgradeSystemMana")
	monster:registerEvent("UpgradeSystemKill")
	monster:registerEvent("EliteAffixHP")
	monster:registerEvent("EliteAffixMANA")
	monster:registerEvent("StrongBoxDeath")
	monster:registerEvent("StoneRespawnDeath")
	monster:registerEvent("BuffDeath")
	monster:registerEvent("UpgradeSystemDeath")
	monster:registerEvent("TaskDeath")
	local config = INSTANCE_MONSTER_MODIFIERS[instance:getKeyUID()]
	-- Initialize or increment elite counter for this instance
	local instanceId = instance:getKeyUID()
	if not instanceEliteCounters[instanceId] then
		instanceEliteCounters[instanceId] = 0
	end
	instanceEliteCounters[instanceId] = instanceEliteCounters[instanceId] + 1
	local elite = instanceEliteCounters[instanceId]
	if config then
		math.randomseed(os.time())
		local monsterLevel = config.mlvl
		local outfit = monster:getOutfit()
		local hpMulti = config[1] and config[1] or 0
		hpMulti = hpMulti + (config.players - 1) * 50
		monster:setMonsterLevel(monsterLevel)
		local monsterHP = healthFormula(monsterLevel)
		monsterHP = monsterHP + (monsterHP * hpMulti / 100)
		monsterHP = math.ceil(monsterHP * partyMebmers)
		monster:setMaxHealth(monsterHP)
		monster:setHealth(monsterHP)
		applyMonsterModifiers(monster, config, instance)
		if config[16] then -- More Monsters
			local clonesCount = math.floor(config[16] / 100)
			local extraChance = config[16] % 100
			for i = 1, clonesCount do
				local clone = Game.createMonster(monster:getName(), monster:getPosition())
				if clone then
					clone:setMaxHealth(monsterHP)
					clone:setHealth(monsterHP)
					clone:setMonsterLevel(monsterLevel)
					clone:registerEvent("EliteAffixHP")
					applyMonsterModifiers(clone, config, instance)
				end
			end
			if math.random(1, 100) <= extraChance then
				local extraClone = Game.createMonster(monster:getName(), monster:getPosition())
				if extraClone then
					extraClone:setMaxHealth(monsterHP)
					extraClone:setHealth(monsterHP)
					extraClone:setMonsterLevel(monsterLevel)
					extraClone:registerEvent("EliteAffixHP")
					applyMonsterModifiers(extraClone, config, instance)
				end
			end
		end
		if config[17] then -- More Elite Monsters
			local clonesCount = math.floor(config[17] / 100)
			local extraChance = config[17] % 100
			for i = 1, clonesCount do
				local clone = Game.createMonster(monster:getName(), monster:getPosition())
				if clone then
					clone:setMaxHealth(monsterHP)
					clone:setHealth(monsterHP)
					clone:setMonsterLevel(monsterLevel)
					clone:registerEvent("EliteAffixHP")
					applyMonsterModifiers(clone, config, instance)
					applyEliteAffix(monster, 100, monster:getPosition(), true)
				end
			end
			if math.random(1, 100) <= extraChance then
				local extraClone = Game.createMonster(monster:getName(), monster:getPosition())
				if extraClone then
					extraClone:setMaxHealth(monsterHP)
					extraClone:setHealth(monsterHP)
					extraClone:setMonsterLevel(monsterLevel)
					extraClone:registerEvent("EliteAffixHP")
					applyMonsterModifiers(extraClone, config, instance)
					applyEliteAffix(monster, 100, monster:getPosition(), true)
				end
			end
		end
		if config[12] or config[13] or config[14] or config[15] then -- All Realm
		-- Clone every 4th monster is cloned
		-- Every 5th monster is elite
			if elite % 5 == 0 then
				local clone = Game.createMonster(monster:getName(), monster:getPosition())
				if clone then
					clone:setMaxHealth(monsterHP)
					clone:setHealth(monsterHP)
					clone:setMonsterLevel(monsterLevel)
					clone:registerEvent("EliteAffixHP")
					outfit.lookOutline = "Black Outline"
					clone:setOutfit(outfit)
					applyMonsterModifiers(clone, config, instance)
				end
			end
			if elite % 4 == 0 then
				local monsterHP = healthFormula(monsterLevel)
				monster:setMaxHealth(monsterHP)
				monster:setHealth(monsterHP)
				monster:setMonsterLevel(monsterLevel)
				applyMonsterModifiers(monster, config, instance)
				applyEliteAffix(monster, 100, monster:getPosition(), true)
			end
		end
		if config[12] then -- Tar Realm
			outfit.lookOutline = "Black Outline"
			monster:setOutfit(outfit)
		end
		if config[13] then -- Golden Realm
			outfit.lookOutline = "Gold Outline"
			monster:setOutfit(outfit)
		end
		if config[14] then -- Thunder Realm
			outfit.lookOutline = "Purple Outline"
			monster:setOutfit(outfit)
		end
		if config[15] then -- Iced Realm
			outfit.lookOutline = "Cyan Outline"
			monster:setOutfit(outfit)
		end
		if self:getTitle() == "Soulbound Bridge" or self:getTitle() == "Gravebound Bridge" or self:getTitle() == "Liberator Bridge" or self:getTitle() == "Eldritch Bridge" then
			local mType = monster:getType()
			local dungeonboss = mType:items() == "dungeonboss"
			if dungeonboss then
				local monsterHP = (healthFormula(config.mlvl+5) * 30)
				monster:setMaxHealth(monsterHP)
				monster:setHealth(monsterHP)
			end
		end
	end
	applyEliteAffix(monster, 3, monster:getPosition(), true)
end

function Dungeon:onPlayerLeft(instance, player)
	-- Clean up elite counter when player leaves
	local instanceId = instance:getKeyUID()
	if instanceEliteCounters[instanceId] then
		instanceEliteCounters[instanceId] = nil
	end
	
	player:sendExtendedOpcode(
		ExtendedOPCodes.CODE_DUNGEONS,
		json.encode({ action = "finish", data = { success = instance:isBossSpawned() and not instance:getBoss() } })
	)
end

local config = {
	-- Tier 1
	['Queen Lair'] = {
		hasStones = false,
		STONES = {
		},
		BOSS_PORTAL = {
			{ xCreate = 247, yCreate = 267, zCreate = 6, createRemovedItem = 28300 }, -- BOSS Position(247, 267, 6)
		},
	},
	['Flame Cave'] = {
		hasStones = false,
		STONES = {
		},
		BOSS_PORTAL = {
			{ xCreate = 1092, yCreate = 1073, zCreate = 8, createRemovedItem = 28300 }, -- Flame Cave {x = 1092, y = 1073, z = 8} Pozycja Boss & Teleport po zabiciu 
		},
	}, 
	['Swamp Pit'] = {
		hasStones = false,
		STONES = {
		},
		BOSS_PORTAL = {
			{xCreate = 1063, yCreate = 1182, zCreate = 8, createRemovedItem = 28300}, -- BOSS
		},
	},
	['Undead Cave'] = {
		hasStones = false,
		STONES = {
		},
		BOSS_PORTAL = {
			{ xCreate = 1043, yCreate = 1123, zCreate = 7, createRemovedItem = 28300 }, -- BOSS Position(247, 267, 6)
		},
	},
	['Celestial Ascent'] = {
		hasStones = false,
		STONES = {
		},
		BOSS_PORTAL = {
			{ xCreate = 1021, yCreate = 986, zCreate = 6, createRemovedItem = 28300 }, -- BOSS Position(247, 267, 6)
		},
	},
	['Glacier Pass'] = {
		hasStones = false,
		STONES = {
		},
		BOSS_PORTAL = {
			{ xCreate = 447, yCreate = 232, zCreate = 7, createRemovedItem = 28300 }, -- BOSS Position(247, 267, 6)
		},
	},
	['Pyramid Ruins'] = {
		hasStones = false,
		STONES = {
		},
		BOSS_PORTAL = {
			{ xCreate = 1035, yCreate = 1035, zCreate = 7, createRemovedItem = 28300 }, -- BOSS Position(247, 267, 6)
		},
	},
	['Golden Horizon'] = {
		hasStones = false,
		STONES = {
		},
		BOSS_PORTAL = {
			{ xCreate = 1037, yCreate = 1025, zCreate = 6, createRemovedItem = 28300 }, -- BOSS Position(247, 267, 6)
		},
	},
	['Ice Castle'] = {
		hasStones = false,
		STONES = {
		},
		BOSS_PORTAL = {
			{ xCreate = 1028, yCreate = 1027, zCreate = 6, createRemovedItem = 28300 }, -- BOSS Position(247, 267, 6)
		},
	},
	['Amethyst Peaks'] = {
		hasStones = false,
		STONES = {
		},
		BOSS_PORTAL = {
			{ xCreate = 1032, yCreate = 1035, zCreate = 6, createRemovedItem = 28300 }, -- BOSS Position(247, 267, 6)
		},
	},
	['Infernal Tar'] = {
		hasStones = false,
		STONES = {
		},
		BOSS_PORTAL = {
			{ xCreate = 1043, yCreate = 1035, zCreate = 6, createRemovedItem = 28300 }, -- BOSS Position(247, 267, 6)
		},
	},
	['Venom Grave'] = {
		hasStones = false,
		STONES = {
		},
		BOSS_PORTAL = {
			{ xCreate = 1046, yCreate = 1041, zCreate = 7, createRemovedItem = 28300 }, -- BOSS Position(247, 267, 6)
		},
	},
	['Bonebound Arena'] = {
		hasStones = false,
		STONES = {
		},
		BOSS_PORTAL = {
			{ xCreate = 1050, yCreate = 1040, zCreate = 6, createRemovedItem = 28300 }, -- BOSS Position(247, 267, 6)
		},
	},
	['Voidflare Arena'] = {
		hasStones = false,
		STONES = {
		},
		BOSS_PORTAL = {
			{ xCreate = 1056, yCreate = 1051, zCreate = 5, createRemovedItem = 28300 }, -- BOSS Position(247, 267, 6)
		},
	},
	['Reaper Castle'] = {
		hasStones = false,
		STONES = {
		},
		BOSS_PORTAL = {
			{ xCreate = 1027, yCreate = 1030, zCreate = 6, createRemovedItem = 28300 }, -- BOSS Position(247, 267, 6)
		},
	},
	
	
	['Infernal Bridge'] = {
		hasStones = false,
		STONES = {
		},
		BOSS_PORTAL = {
			{ xCreate = 453, yCreate = 285, zCreate = 5, createRemovedItem = 28300 }, -- BOSS Position{x = 453, y = 285, z = 5}
		},
	},
	['Void Castle'] = {
		hasStones = false,
		STONES = {
		},
		BOSS_PORTAL = {
			{ xCreate = 271, yCreate = 261, zCreate = 6, createRemovedItem = 28300 }, -- BOSS Position{x = 271, y = 261, z = 6}
		},
	},
	['Underwater'] = {
		hasStones = false,
		STONES = {
		},
		BOSS_PORTAL = {
			{ xCreate = 1090, yCreate = 1086, zCreate = 7, createRemovedItem = 28300 }, -- BOSS Position{x = 1090, y = 1086, z = 7}
		},
	},
	
	['Molten Core'] = {
		hasStones = false,
		STONES = {
		},
		BOSS_PORTAL = {
			{ xCreate = 1000, yCreate = 993, zCreate = 7, createRemovedItem = 28300 }, -- BOSS Position{x = 1090, y = 1086, z = 7}
		},
	},
	['Otherworld'] = {
		hasStones = false,
		STONES = {
		},
		BOSS_PORTAL = {
			{ xCreate = 1000, yCreate = 993, zCreate = 7, createRemovedItem = 28300 }, -- BOSS Position{x = 1090, y = 1086, z = 7}
		},
	},
	['Wildwood'] = {
		hasStones = false,
		STONES = {
		},
		BOSS_PORTAL = {
			{ xCreate = 1000, yCreate = 993, zCreate = 7, createRemovedItem = 28300 }, -- BOSS Position{x = 1090, y = 1086, z = 7}
		},
	},
	['Frostbound'] = {
		hasStones = false,
		STONES = {
		},
		BOSS_PORTAL = {
			{ xCreate = 1000, yCreate = 993, zCreate = 7, createRemovedItem = 28300 }, -- BOSS Position{x = 1090, y = 1086, z = 7}
		},
	},
	['Firecastle Ruins'] = {
		hasStones = false,
		STONES = {
		},
		BOSS_PORTAL = {
			{ xCreate = 1011, yCreate = 1000, zCreate = 7, createRemovedItem = 28300 }, -- BOSS Position{x = 1090, y = 1086, z = 7}
		},
	},
	['Toxic Arena'] = {
		hasStones = false,
		STONES = {
		},
		BOSS_PORTAL = {
			{ xCreate = 1000, yCreate = 1000, zCreate = 3, createRemovedItem = 28300 }, -- BOSS Position{x = 1090, y = 1086, z = 7}
		},
	},
	['Bloodfall Arena'] = {
		hasStones = false,
		STONES = {
		},
		BOSS_PORTAL = {
			{ xCreate = 1002, yCreate = 991, zCreate = 7, createRemovedItem = 28300 }, -- BOSS Position{x = 1090, y = 1086, z = 7}
		},
	},
	['Lost Sanctum'] = {
		hasStones = false,
		STONES = {
		},
		BOSS_PORTAL = {
			{ xCreate = 1205, yCreate = 986, zCreate = 7, createRemovedItem = 28300 }, -- BOSS Position(1205, 986, 7)
		},
	},
	['Inferno Depths'] = {
		hasStones = false,
		STONES = {
		},
		BOSS_PORTAL = {
			{ xCreate = 1267, yCreate = 1060, zCreate = 5, createRemovedItem = 28300 }, -- BOSS Position 1267, 1060, 5)
		},
	},
	['Venom Caves'] = {
		hasStones = false,
		STONES = {
		},
		BOSS_PORTAL = {
			{ xCreate = 1179, yCreate = 1090, zCreate = 8, createRemovedItem = 28300 }, -- BOSS Position 1179, 1090, 8)
		},
	},
	['Soulbound Bridge'] = {
		hasStones = true,
		STONES = {
		--[[
			{ xCreate = 1217, yCreate = 1063, zCreate = 6, createRemovedItem = 9118 },
	
			{ xCreate = 1216, yCreate = 1063, zCreate = 6, createRemovedItem = 9118 },
 
			{ xCreate = 1215, yCreate = 1063, zCreate = 6, createRemovedItem = 9118 },
		--]]
		},
		BOSS_PORTAL = {
			{ xCreate = 1227, yCreate = 1056, zCreate = 6, createRemovedItem = 28300 }, -- BOSS Position 1179, 1090, 8)
		},
	},
	['Gravebound Bridge'] = {
		hasStones = false,
		STONES = {
		},
		BOSS_PORTAL = {
			{ xCreate = 1237, yCreate = 1029, zCreate = 6, createRemovedItem = 28300 }, -- BOSS Position 1179, 1090, 8)
		},
	},
	['Liberator Bridge'] = {
		hasStones = false,
		STONES = {
		},
		BOSS_PORTAL = {
			{ xCreate = 1309, yCreate = 1046, zCreate = 6, createRemovedItem = 28300 }, -- BOSS Position 1179, 1090, 8)
		},
	},
	['Eldritch Bridge'] = {
		hasStones = false,
		STONES = {
		},
		BOSS_PORTAL = {
			{ xCreate = 1246, yCreate = 1067, zCreate = 6, createRemovedItem = 28300 }, -- BOSS Position 1179, 1090, 8)
		},
	},
	['Golden Vault'] = {
		hasStones = false,
		STONES = {
		},
		BOSS_PORTAL = {
			{ xCreate = 1205, yCreate = 1177, zCreate = 7, createRemovedItem = 28300 }, -- BOSS Position 1179, 1090, 8)
		},
	},
	-- END	
}

function Dungeon:onMonstersCount(instance, count)
	if instance then
		if config[self:getTitle()].hasStones then
			local configStones = config[self:getTitle()].STONES
			for i = 1, #configStones do
				local instancePosition = instance:getPosition()
				local TPstonePos = { x = instancePosition.x + config[self:getTitle()].STONES[i].xCreate, y = instancePosition.y + config[self:getTitle()].STONES[i].yCreate, z = config[self:getTitle()].STONES[i].zCreate }
				if not Tile(TPstonePos):getItemById(config[self:getTitle()].STONES[i].createRemovedItem) then
					Game.createItem(config[self:getTitle()].STONES[i].createRemovedItem, -1, TPstonePos)
				end
			end
		end
		local configCreateItems = config[self:getTitle()].BOSS_PORTAL
		for i = 1, #configCreateItems do
			local instancePosition = instance:getPosition()
			local TPstonePos = { x = instancePosition.x + config[self:getTitle()].BOSS_PORTAL[i].xCreate, y =
			instancePosition.y + config[self:getTitle()].BOSS_PORTAL[i].yCreate, z = config[self:getTitle()].BOSS_PORTAL[i].zCreate }
			if Tile(TPstonePos):getItemById(config[self:getTitle()].BOSS_PORTAL[i].createRemovedItem) then
				Tile(TPstonePos):getItemById(config[self:getTitle()].BOSS_PORTAL[i].createRemovedItem):remove()
			end
		end
	end
end
