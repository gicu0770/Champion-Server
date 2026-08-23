SIDE_BOSSES = SIDE_BOSSES or {}
for _, data in pairs(SIDE_BOSSES) do
	UNIQUE_BOSS_STORAGES[data.id] = data.storage
end

function onDeath(creature, corpse, killer, mostDamage, unjustified, mostDamage_unjustified)
	if not killer then return end
	if not corpse then return end
	if not creature then return end
	if not creature:isMonster() then return end
	if not killer:isPlayer() then return end
	local globalSpawnChance = 1
	local treasureGoblinChance = EVENT_CHANCE["Treasure Goblin"].chance
	local monsterSoulChance = 1000 -- 1500
	local globesChance = 500
	local expGlobeMultipler = 50 -- x15
	local championChance = EVENT_CHANCE["Champion"].chance
	local bossRelictChance = EVENT_CHANCE["Boss"].relictHolderChance

	local skull = creature:getSkull()
	if corpse or not corpse.itemid == 0 then
		if creature:getType():items() == "stoneminion" then
			return false
		end
		local monsterLevel = 1
		if creature:isMonster() then
			monsterLevel = creature:getMonsterLevel()
		end
		local relictBonus = 0
		local killerInfo = colleftInfo[killer:getId()]
		if killer and killer:isPlayer() and killerInfo and killerInfo.attributesItems[269] then -- Challenging Encounter
			monsterLevel = monsterLevel + killerInfo.attributesItems[269].value
		end
		if killer:isPlayer() then
			if killerInfo and killerInfo.attributesItems[264] then -- Goblin chance
				globalSpawnChance = globalSpawnChance + (killerInfo.attributesItems[264].value / 100)
			end
			if killerInfo and killerInfo.attributesItems[265] then -- Champion Chance
				globalSpawnChance = globalSpawnChance + (killerInfo.attributesItems[265].value / 100)
			end
			local bossName = creature:getName()
			local bossData = SIDE_BOSSES[bossName]
		
			if bossData and killer:isPlayer() then
				local damageMeter = {}
				local damageMap = creature:getDamageMap()
				local bossHP = creature:getMaxHealth()
				for id, damage in pairs(damageMap) do
					local player = Player(id)
					if player then
						local damageDeal = damage.total
						local damageDealPercentage = damageDeal / bossHP * 100
						damageMeter[player:getId()] = { name = player:getName(), damagePercent = damageDealPercentage, damageValue = damageDeal }
						if damageMeter[player:getId()] then
						--	print("Player: " .. player:getName() .. ", Damage: " .. damageDeal .. ", Percentage: " .. string.format("%.2f", damageDealPercentage) .. "%")
							local damageNeeded = damageMeter[player:getId()].damagePercent
							if damageNeeded >= 10 then
								if player and player:getStorageValue(bossData.storage) ~= 1 then
									player:setStorageValue(bossData.storage, 1)
									bossData.reward(player)
									player:sendExtendedOpcode(ExtendedOPCodes.CODE_WAYPOINTS, json.encode({5, bossData.id}))	
									player:setStatistics()
								else
									player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You have already defeated " .. bossName .. " and claimed your reward.")
								end
							end
						end
					end
				end
			end

			--- World Boss
			local lootItems = {}
			if creature:getName() == "Gorn" then
				local damageMeter = {}
				local damageMap = creature:getDamageMap()
				for id, damage in pairs(damageMap) do
					local player = Player(id)
					if player then
						local bossHP = creature:getMaxHealth()
						local damageDeal = damage.total
						local damageDealPercentage = damageDeal / bossHP * 100
						damageMeter[player:getId()] = { name = player:getName(), damagePercent = damageDealPercentage, damageValue = damageDeal }
					end
				end
				local playerInArea = Game.getSpectators(creature:getPosition(), false, false, 15, 15, 15, 15)
				for _, creature in pairs(playerInArea) do
					local player = Player(creature:getId())
					if player then
						if damageMeter[player:getId()] then
							player:setStorageValue(PlayerStorage.worldBossDamagePercent, damageMeter[player:getId()].damagePercent)
							player:setStorageValue(PlayerStorage.worldBossDamage, damageMeter[player:getId()].damageValue)
						end
					end
				end
				-- Sortowanie po damagePercent malejąco
				local topList = {}
				for _, v in pairs(damageMeter) do
					table.insert(topList, v)
				end
				table.sort(topList, function(a, b) return a.damagePercent > b.damagePercent end)

				-- Tworzenie tekstu TOP 3
				local wynik = "Top 3 Damage Dealers:\n"
				for i = 1, math.min(3, #topList) do
					local entry = topList[i]
					wynik = wynik .. i .. ". " .. entry.name .. " - " .. string.format("%.2f", entry.damagePercent) .. "% (" .. entry.damageValue .. " dmg)\n"
				end

				-- Wysyłanie wiadomości do wszystkich graczy
				for _, player in ipairs(Game.getPlayers()) do
					player:sendExtendedOpcode(71, json.encode({text = "The {"..creature:getName().."} has been defeated!\n"..wynik, color = "#f7ef8a"}))
				end
			end
			--- 
			--[[
			local dungeon = killer:getDungeon()
			if dungeon then
				local instance = dungeon:getPlayerInstance(killer)
				if instance then
					return false
				end
			end
			--]]
		end
		if getGlobalBuff(BUFF_GLOBAL_PORTALS) then
			globalSpawnChance = globalSpawnChance + 0.2
		end
		if killer:hasBuff(STORE_PORTALS_BOOST) then
			globalSpawnChance = globalSpawnChance + 0.2
		end
		local mods_attributes = {
			[3] = PlayerStorage.monsterModifier_damage,
			[5] = PlayerStorage.monsterModifier_physicalProtection,
			[6] = PlayerStorage.monsterModifier_elementalProtection,
			[7] = PlayerStorage.monsterModifier_dualityProtection,
			[8] = PlayerStorage.monsterModifier_spell_avoid,
			[9] = PlayerStorage.monsterModifier_dodge,
			[10] = PlayerStorage.monsterModifier_ailments,
			[11] = PlayerStorage.monsterModifier_movements,
			[22] = PlayerStorage.monsterModifier_damage_elemental,
			[23] = PlayerStorage.monsterModifier_damage_physical,
		}
		local dungeon = killer:getDungeon()
		if dungeon then
			local instance = dungeon:getPlayerInstance(killer)
			local mType = creature:getType()
			if instance and mType:items() == "dungeonboss" and creature:getStorageValue(PlayerStorage.bossCloneEX) < 0 then
				if monsterLevel >= EVENT_CHANCE["Boss"].levelDrop then
					local cloneBossChance = (killerInfo and killerInfo.attributesItems[267]) and killerInfo.attributesItems[267].value or 0
					local randd = math.random(1, 100)
					if randd <= bossRelictChance then -- Relict Holder Chance Boss
						local voort = Game.createMonster(EVENT_CHANCE["Boss"].name, creature:getPosition())
						local outfit = voort:getOutfit()
						local hp = creature:getMaxHealth() * 2
						voort:setMaxHealth(hp)
						voort:setHealth(hp)
						outfit.lookHealthBar = 2
						voort:setStorageValue(PlayerStorage.bossRelictBoss, 1)
						voort:setStorageValue(PlayerStorage.bossCloneEX, 1)
						outfit.lookOutline = "Red Outline"
						outfit.lookShader = "Red Rage"
						voort:setMonsterLevel(monsterLevel + 20)
						voort:setTitle("Relict Holder", "Reggae One-10px-bordered", "white")
						instance:addMonster(voort)
					elseif cloneBossChance >= randd then -- Clone Dungeon Boss Chance
					  	local partyMebmers = dungeon:getPlayersCount()
							local clone = Game.createMonster(creature:getName(), creature:getPosition())
							if clone then
								instance:addMonster(clone)
								local config = INSTANCE_MONSTER_MODIFIERS[instance:getKeyUID()]
								if config then
								local hpMulti = (config[1] and config[1] or 0) + (config[2] and config[2] or 0)
								hpMulti = hpMulti + (config.players - 1) * 50
								local monsterHP = (healthFormula(monsterLevel) * 15)
								monsterHP = monsterHP + (monsterHP * hpMulti / 100)
								monsterHP = math.ceil(monsterHP * partyMebmers)
								clone:registerEvent("SpellHealthChangeEvent")
								clone:registerEvent("UpgradeSystemHealth")
								clone:registerEvent("UpgradeSystemMana")
								clone:registerEvent("UpgradeSystemKill")
								clone:registerEvent("EliteAffixHP")
								clone:registerEvent("EliteAffixMANA")
								clone:registerEvent("UpgradeSystemDeath")
								clone:registerEvent("TaskDeath")
								clone:registerEvent("DungeonBossTP")
								local monsterHP = creature:getMaxHealth()
								clone:setMaxHealth(monsterHP)
								clone:setHealth(monsterHP)
								clone:registerEvent("EliteAffixHP")
								clone:setMonsterLevel(monsterLevel)
								clone:setStorageValue(PlayerStorage.monsterModifier_bonus, config.bonus)
								clone:setStorageValue(PlayerStorage.monsterModifier_partyBonus, config.partyBonus)
								clone:setStorageValue(PlayerStorage.bossCloneEX, 1)
								for index, storageKey in pairs(mods_attributes) do
									local value = config[index] or 0
									if value > 0 then
										clone:setStorageValue(storageKey, value)
										if index == 11 then
										local sped =  value
										local Chilling = Condition(CONDITION_PARALYZE)
										Chilling:setParameter(CONDITION_PARAM_TICKS, -1)
										Chilling:setParameter(CONDITION_PARAM_SPEED, sped)
										clone:addCondition(Chilling)
										end
									end
								end
								if config.tier >= 1 then
									clone:setStorageValue(PlayerStorage.keyTier, config.tier)
								end
							end
						end
					end
				end
			end
		end
		if creature:getStorageValue(PlayerStorage.strongBoxMonsterBoss) > 0 then
			if killerInfo and killerInfo.attributesItems[274] then -- Shiny Box
				if math.random(100) <= killerInfo.attributesItems[274].value then
					local buffRandom = math.random(1,9)
					if buffRandom == 1 then
						killer:addBuff(SHRINE_DAMAGE)
					elseif buffRandom == 2 then
						applyResourceRegen(killer, "energyshield", 200, 120, 105, SHRINE_REGEN)
						applyResourceRegen(killer, "mana", 200, 120, 104, SHRINE_REGEN)
						applyResourceRegen(killer, "health", 200, 120, 103, SHRINE_REGEN)
					elseif buffRandom == 3 then
						local movementSpeedCondition = Condition(CONDITION_HASTE)
						local hasteAdded = killer:getBaseSpeed() * 150 / 100
						movementSpeedCondition:setParameter(CONDITION_PARAM_TICKS, 120000)
						movementSpeedCondition:setParameter(CONDITION_PARAM_SUBID, 731700)
						movementSpeedCondition:setFormula(0.0, hasteAdded, 0.0, hasteAdded)
						killer:addCondition(movementSpeedCondition)
						killer:addBuff(SHRINE_MOVEMENT_SPEED)
					elseif buffRandom == 4 then
						local criticalChance_shrine = Condition(CONDITION_ATTRIBUTES)
						criticalChance_shrine:setParameter(CONDITION_PARAM_TICKS, 120000)
						criticalChance_shrine:setParameter(CONDITION_PARAM_SPECIALSKILL_CRITICALHITCHANCE, 100)
						criticalChance_shrine:setParameter(CONDITION_PARAM_SUBID, 731701)
						killer:addCondition(criticalChance_shrine)
						killer:addBuff(SHRINE_CRITICAL_CHANCE)
					elseif buffRandom == 5 then
						local conditionHaste = Condition(CONDITION_ATTRIBUTES)
						conditionHaste:setParameter(CONDITION_PARAM_SUBID, 731702)
						conditionHaste:setParameter(CONDITION_PARAM_ATTACKSPEED, 300)
						conditionHaste:setParameter(CONDITION_PARAM_TICKS, 120000)
						killer:addCondition(conditionHaste)
						killer:addBuff(SHRINE_ATTACKSPEED)
					elseif buffRandom == 6 then
						killer:addBuff(SHRINE_EXP)
					elseif buffRandom == 7 then
						killer:addBuff(SHRINE_LOOT)
					elseif buffRandom == 8 then
						killer:addBuff(SHRINE_GOLD)
					elseif buffRandom == 9 then
						killer:addBuff(SHRINE_CORPSE_EXPLOSION)
					end
				end
			end
		end
		-- Void Stone
		if creature:getName() == "Void Stone" then
			if killerInfo and killerInfo.attributesItems[289] then -- Void Blessing
				for i = 1, killerInfo.attributesItems[289].value do
					killer:addBuff(VOIDSTONE_BUFF)
				end
			end
		end
		-- Treasure Goblin
		if creature:getName() == "Treasure Goblin" then
			local monsterGold = math.ceil(goldFormula(monsterLevel) * 10)
			killer:setBankBalance(killer:getBankBalance() + monsterGold)
		end
		if creature:getName() ~= "Treasure Goblin" then
			if math.random(100000) <= treasureGoblinChance + (globalSpawnChance * treasureGoblinChance - treasureGoblinChance) then
			local mType = creature:getType()
			if mType:items() == "titan" or mType:items() == "dummy" or mType:items() == "dungeonboss" or creature:getSkull() >= 1 or creature:getName() == "Treasure Goblin" or mType:items() == "stone" or mType:items() == "stoneminion" then
				return false
			end
				local goblinName = "Treasure Goblin"
				local goblinSpawn = false
				if monsterLevel >= EVENT_CHANCE["Treasure Goblin"].levelDrop then
					if math.random(100) <= EVENT_CHANCE["Treasure Goblin"].relictHolderChance then
						goblinName = EVENT_CHANCE["Treasure Goblin"].name
					end
				end
				local duplication = 1
				if killerInfo and killerInfo.attributesItems[271] then -- Duplication
					local chanceDuplication = killerInfo.attributesItems[271].value
					if math.random(100) <= chanceDuplication then
						duplication = duplication + 1
					end
					if math.random(100) <= (chanceDuplication / 2) then
						duplication = duplication + 1
					end
				end
				if goblinName == EVENT_CHANCE["Treasure Goblin"].name then
					duplication = 1
				end
				for i = 1, duplication do
					goblinSpawn = Game.createMonster(goblinName, creature:getPosition())
					if goblinSpawn then
						local outfit = goblinSpawn:getOutfit()
						local hp = creature:getMaxHealth() * 3
						goblinSpawn:setMaxHealth(hp)
						goblinSpawn:setHealth(hp)
						goblinSpawn:setMonsterLevel(monsterLevel)
						creature:getPosition():sendMagicEffect(50)
						creature:say("Hahahah ohh RUN!", TALKTYPE_MONSTER_SAY)
						if goblinName == EVENT_CHANCE["Treasure Goblin"].name then
							goblinSpawn:setStorageValue(PlayerStorage.goblinRelictBoss, 1)
							outfit.lookHealthBar = 2
							outfit.lookOutline = "Gold Outline"
							goblinSpawn:setMonsterLevel(monsterLevel + 20)
							goblinSpawn:setOutfit(outfit)
							goblinSpawn:setTitle("Relict Holder", "Reggae One-10px-bordered", "white")
						end
						local dungeon = killer:getDungeon()
						if dungeon then
							local instance = dungeon:getPlayerInstance(killer)
							if instance then
								instance:addMonster(goblinSpawn)
							end
						end
						if killer:isPlayer() then
							killer:sendExtendedOpcode(71,json.encode({ text ="You summon {"..goblinName.."} kill him!", color ="#ff0000" }))
						end
					end
				end
			end
		end

		-- Champion
		if math.random(100000) <= championChance + (globalSpawnChance * championChance - championChance) then
			local mType = creature:getType()
			if mType:items() == "titan" or mType:items() == "dummy" or mType:items() == "dungeonboss" or creature:getSkull() >= 1 or creature:getName() == "Treasure Goblin" then
				return false
			end
			local champions = {
				{550, "Twistgrove"}, {800, "Twistgrove"},
				{90, "Twistgrove"}, {80, "Seano"}, {70, "Boa"}, {60, "Frogy"},
				{50, "Minn"}, {40, "Tuu"}, {30, "Urna"}, {20, "Brute"},
				{10, "Behemoth"}, {1, "War Wolf"}
			}
			local relictBoss = false
			local txt = ""
			local dungeon = killer:getDungeon()
			if dungeon then
				local instance = dungeon:getPlayerInstance(killer)
				if instance then
					champions = {"Twistgrove", "Seano", "Boa"}
				end
			end

			local championName = "War Wolf"
			if dungeon then
				championName = champions[math.random(#champions)]
				if monsterLevel >= EVENT_CHANCE["Champion"].levelDrop  then
					if math.random(100) <= EVENT_CHANCE["Champion"].relictHolderChance then
						relictBoss = true
						txt = " RELICT HOLDER"
						championName = EVENT_CHANCE["Champion"].name
					end
				end
			else
				for _, champ in ipairs(champions) do
					if monsterLevel >= champ[1] then
						championName = champ[2]
						break
					end
				end
			end
			local cloneChamp = false
			if killerInfo and killerInfo.attributesItems[275] then -- Duplication
				local cloneChance = killerInfo.attributesItems[275].value
				if math.random(100) <= cloneChance then
					cloneChamp = true
				end
			end
			local function bossSpawn(pos, name, health, killerId, relictBoss, isDungeon)
				local cryE = Game.createMonster(name, pos)
				if cryE then
					local outfit = cryE:getOutfit()
					cryE:setMaxHealth(health * 7)
					cryE:setHealth(cryE:getMaxHealth())
					cryE:registerEvent("EliteAffixHP")
					cryE:setStorageValue(PlayerStorage.eliteAffixes, 21)	
					cryE:setSkull(27)
					cryE:setMonsterLevel(monsterLevel)
					cryE:setAura(2169, 120)
					outfit.lookHealthBar = 2
					if relictBoss then
						cryE:setStorageValue(PlayerStorage.championRelictBoss, 1)
						outfit.lookOutline = "Red Outline"
						outfit.lookShader = "Red Rage"
						cryE:setMonsterLevel(monsterLevel + 20)
						cryE:setTitle("Relict Holder", "Reggae One-10px-bordered", "white")
					end	
					cryE:setOutfit(outfit)
					-- Retrieve killer player by ID to avoid stale references
					local adddedToInstance = false
					local killerPlayer = Player(killerId)
					if killerPlayer then
						local dungeon = killerPlayer:getDungeon()
						if dungeon then
							local instance = dungeon:getPlayerInstance(killerPlayer)
							if instance then
								instance:addMonster(cryE)
								local config = INSTANCE_MONSTER_MODIFIERS[instance:getKeyUID()]
								if config then
									applyMonsterModifiers(cryE, config, instance)
								end
								adddedToInstance = true
							end
						end
					end

					if isDungeon and not adddedToInstance then
						cryE:remove()
						return
					end
				end
			end
		
			if corpse then
				local poCorps = creature:getPosition()
				local posC = Position(poCorps.x + 1, poCorps.y + 1, poCorps.z)
				for i = 1, 2 do
					addEvent(function() posC:sendMagicEffect(551, 1) end, i * 1500)
				end

				local isDungeon = killer:getDungeon() ~= nil
				addEvent(bossSpawn, 4000, poCorps, championName, creature:getMaxHealth(), killer:getId(), relictBoss, isDungeon)
				if cloneChamp then
					addEvent(bossSpawn, 4000, poCorps, championName, creature:getMaxHealth(), killer:getId(), relictBoss, isDungeon)
				end
				if killer:isPlayer() then
					killer:sendExtendedOpcode(71, json.encode({text = "You summoned the"..txt.." {" .. championName .. "} {CHAMPION}, get ready for his coming!", color = "#f3c824"}))
				end
			end
		end
		-- Monster Soul
		if math.random(100000) <= monsterSoulChance + (globalSpawnChance * monsterSoulChance - monsterSoulChance) then
			local tile = Tile(creature:getPosition())
			if tile then
				if not tile:getItemById(36788) then
					local posExtra = creature:getPosition()
					local item = Game.createItem(36788, 1, posExtra)
					item:setActionId(27562)
					item:setAttribute(ITEM_ATTRIBUTE_DURATION, 30000)
					Game.sendAnimatedText("Monster Soul!", creature:getPosition(), 215, "Reggae One-20px-bordered")
					creature:getPosition():sendMagicEffect(349)
				end
			end
		end
		-- Globes
		if math.random(100000) <= globesChance + (globalSpawnChance * globesChance - globesChance) then
			local posExtra = creature:getPosition()
			local globs = {37275, 37276, 37277, 37278}
			local tile = Tile(posExtra)
			
			if tile and not (tile:getItemById(37275) or tile:getItemById(37276) or tile:getItemById(37277) or tile:getItemById(37278)) then
				local random_globa = globs[math.random(#globs)]
				local item = Game.createItem(random_globa, 1, posExtra)
				item:setAttribute(ITEM_ATTRIBUTE_DURATION, 30000)
				
				local effects = { [37275] = 343, [37276] = 345, [37277] = 347, [37278] = 349 }
				creature:getPosition():sendMagicEffect(effects[random_globa])
				
				if random_globa == 37278 then
					local mobExp = math.ceil(expFormula(monsterLevel) * expGlobeMultipler)
					item:setBonusGlobe(mobExp)
				end
			end
		end
		-- XXX
		return false
	end
	return true
end
