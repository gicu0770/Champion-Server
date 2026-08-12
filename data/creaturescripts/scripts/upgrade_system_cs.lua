function onLogin(player)
	us_onLogin(player)
	return true
end



function onHealthChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin, critical, spellUID, critChance, distance)
	-- if spellUID then
	-- 	local spell = SPELL_CACHE[spellUID]
	-- 	if spell then
	 	--	print(spell.id)
	 	--	print(json.encode(spell.hs))
	-- 	end
	--end

	if creature and creature:isMonster() then
		if primaryType == COMBAT_HEALING then
			return primaryDamage, primaryType, secondaryDamage, secondaryType
		end
	end
	if attacker and creature then
		-- Health globe
		if creature:isMonster() and attacker:isPlayer() then
			local chance = 100
			local race = MonsterType(creature:getName()):getRace()
			if race == 6 then 
				chance = 1000 
			elseif creature:getSkull() >= 7 then 
				chance = 500 
			end
		
			if math.random(100000) <= chance then
				local pos = creature:getPosition()
				local globs = {37275, 37276, 37277}
				local tile = Tile(pos)
		
				-- Sprawdzanie, czy orb już istnieje na tej samej pozycji
				if not (tile:getItemById(37275) or tile:getItemById(37276) or tile:getItemById(37277)) then
					local random_globa = globs[math.random(#globs)]
					local item = Game.createItem(random_globa, 1, pos)
					item:setAttribute(ITEM_ATTRIBUTE_DURATION, 30000)
		
					-- Mapowanie efektyw na orb
					local effects = { [37275] = 343, [37276] = 345, [37277] = 347 }
					creature:getPosition():sendMagicEffect(effects[random_globa])
				end
			end
		end
		-- health globe
		if creature:isPlayer() and attacker:isPlayer() and primaryType ~= COMBAT_HEALING then
			if creature:getName() ~= attacker:getName() then
				creature:addBuff(PVP_CONDITION)
				attacker:addBuff(PVP_CONDITION)
			end
		end
	end
	if origin == ORIGIN_CONDITION then
		return primaryDamage, primaryType, secondaryDamage, secondaryType
	end
	return us_onHealthChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin, critical, spellUID, critChance, distance)
end
function onManaChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin, critical, spellUID, critChance, distance)
	return us_onManaChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin,critical, spellUID, critChance, distance)
end
function onDeath(creature, corpse, lasthitkiller, mostdamagekiller, lasthitunjustified, mostdamageunjustified)
	return us_onDeath(creature, corpse, lasthitkiller, mostdamagekiller, lasthitunjustified, mostdamageunjustified)
end
function onKill(player, target, lastHit)
	return us_onKill(player, target, lastHit)
end
function onPrepareDeath(creature, killer)
	return us_onPrepareDeath(creature, killer)
end
function us_onManaChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin, critical, spellUID, critChance, distance)
	---Mana increase with potions and spells
	if primaryType == COMBAT_MANADRAIN or secondaryType == COMBAT_MANADRAIN then
		local manaOriginal = primaryDamage
		local manaPrimary = 0
		if manaPrimary > 0 then
			primaryDamage = math.floor(primaryDamage + (primaryDamage * manaPrimary / 100))
		end
		if creature:isPlayer() then
			if creature and creature:getStorageValue(PlayerStorage.damageHealingInfo) == 1 then
				if creature:openChannel(30) then
					creature:sendChannelMessage(""," Mana Recovery Increased " ..manaPrimary .. "% \n[Base " .. manaOriginal .. " Done " .. primaryDamage .. "]",TALKTYPE_CHANNEL_R1, 30)
				end
			end
		end
		return primaryDamage, primaryType, secondaryDamage, secondaryType
	end
	---Mana increase with potions and spells
	if not creature or not attacker then
		return primaryDamage, primaryType, secondaryDamage, secondaryType
	end
	if creature:isPlayer() and creature:getParty() and attacker:isPlayer() and attacker:getParty() then
		if creature:getParty() == attacker:getParty() then
			return primaryDamage, primaryType, secondaryDamage, secondaryType
		end
	end
	if primaryType == COMBAT_LIFEDRAIN or secondaryType == COMBAT_LIFEDRAIN then
		return primaryDamage, primaryType, secondaryDamage, secondaryType
	end
	if primaryType == COMBAT_MANADRAIN or secondaryType == COMBAT_MANADRAIN then
		return primaryDamage, primaryType, secondaryDamage, secondaryType
	end
	if creature == attacker and primaryType ~= COMBAT_HEALING then
		return primaryDamage, primaryType, secondaryDamage, secondaryType
	end
	if origin == ORIGIN_CONDITION then
		return primaryDamage, primaryType, secondaryDamage, secondaryType
	end
	return us_onDamaged(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin, critical, spellUID, critChance, distance)
end

function us_onHealthChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin, critical, spellUID, critChance, distance)
	if creature then
		if creature:isPlayer() then
			if primaryType ~= COMBAT_MANADRAIN or secondaryType ~= COMBAT_MANADRAIN then
				if primaryType ~= COMBAT_HEALING or secondaryType ~= COMBAT_HEALING then
					if creature:hasBuff(RESTART_IMMORTAL) or creature:hasBuff(SHADOW) or creature:hasBuff(BOSS_IMMORTAL)  then
						primaryDamage = 0
						secondaryDamage = 0
						return primaryDamage, primaryType, secondaryDamage, secondaryType
					end
				end
			end
		end
	end
	---Increase healing with all sources
	if primaryType == COMBAT_HEALING or secondaryType == COMBAT_HEALING then
		local healingPrimary = 0
		local primaryDamageStart = primaryDamage
		if creature:isPlayer() then
			if healingPrimary > 0 then
				primaryDamage = math.floor(primaryDamage + (primaryDamage * healingPrimary / 100))
			end
		end
		---end
		if creature:isPlayer() then
			if creature and creature:getStorageValue(PlayerStorage.damageHealingInfo) == 1 then
				if creature:openChannel(30) then
					creature:sendChannelMessage("","Healing " .. primaryDamageStart .. "  +" .. healingPrimary .. "% = " .. primaryDamage .. "]",TALKTYPE_CHANNEL_O, 30)
				end
			end
		end
		return primaryDamage, primaryType, secondaryDamage, secondaryType
	end
	---Increase healing with all sources
	if not creature or not attacker then
		return primaryDamage, primaryType, secondaryDamage, secondaryType
	end
	if creature:isPlayer() and creature:getParty() and attacker:isPlayer() and attacker:getParty() then
		if creature:getParty() == attacker:getParty() then
			return primaryDamage, primaryType, secondaryDamage, secondaryType
		end
	end
	if primaryType == COMBAT_LIFEDRAIN or secondaryType == COMBAT_LIFEDRAIN then
		return primaryDamage, primaryType, secondaryDamage, secondaryType
	end
	if creature == attacker and primaryType ~= COMBAT_HEALING then
		return primaryDamage, primaryType, secondaryDamage, secondaryType
	end
	if origin == ORIGIN_CONDITION then
		return primaryDamage, primaryType, secondaryDamage, secondaryType
	end
	return us_onDamaged(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin, critical, spellUID, critChance, distance)
end

function us_onDamaged(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin, critical, spellUID, critChance, distance)
	local eliteCrit = false
	local moveSpell = false
	local bounce = false
	local wave = false
	local spellName = ""
	 if spellUID then
	 	local spell = SPELL_CACHE[spellUID]
	 	if spell then
			if GLOBAL_SPELL_COOLDOWNS[spell.id].move then
				moveSpell = true
			elseif GLOBAL_SPELL_COOLDOWNS[spell.id].bounce then
				bounce = true
			elseif GLOBAL_SPELL_COOLDOWNS[spell.id].wave then
				wave = true
	 	--	print(json.encode(spell.hs))
			end
			spellName = GLOBAL_SPELL_COOLDOWNS[spell.id].name
	 	end
	end
	local cd = Condition(CONDITION_SPELLCOOLDOWN)
	cd:setParameter(CONDITION_PARAM_TICKS, 12000)
	cd:setParameter(CONDITION_PARAM_SUBID, 5000)
	local secondWind = Condition(CONDITION_SPELLCOOLDOWN) -- second wind
	secondWind:setParameter(CONDITION_PARAM_TICKS, 17000)
	secondWind:setParameter(CONDITION_PARAM_SUBID, 5001)
	local lastBreath = Condition(CONDITION_SPELLCOOLDOWN) -- last breath
	lastBreath:setParameter(CONDITION_PARAM_TICKS, 25000)
	lastBreath:setParameter(CONDITION_PARAM_SUBID, 5002)
	local shadowCD = Condition(CONDITION_SPELLCOOLDOWN) -- ghost
	shadowCD:setParameter(CONDITION_PARAM_TICKS, 30000)
	shadowCD:setParameter(CONDITION_PARAM_SUBID, 5003)
	local armorAmount = 0
	local armorAmountPercent = 0
	local armorDamageReduction = 0
	local originalDamage = primaryDamage
	local decreasedDamage = 0
	local dotDamageMultipler = 0
	local meleeStart = 0
	local mobDmg = 0

	-- #Elite
	if attacker:isMonster() and origin ~= ORIGIN_DOT then -- Monster Multipler

		local primalTotal = 0
		local mType = attacker:getType()
		local tier = 1
		if mType then
			if tier ~= nil then
				tier = mType:tier()
			end
		end
		if attacker:getMonsterLevel() then
			local monsterLevel = attacker:getMonsterLevel()
			primaryDamage = damageFormula(monsterLevel)
		end
		if primaryDamage > 0 then
			primaryDamage = primaryDamage * -1
		end
		if attacker:getSkull() >= 7 and not BOSSESS_DAMAGE[attacker:getName()] then
			if attacker:isMonster() then
				local skull = attacker:getSkull()
				if skull >= 28 and skull <= 34 then -- iced
						local typeChange = {
							[28] = {element = COMBAT_ICEDAMAGE, effect = 44},
							[29] = {element = COMBAT_FIREDAMAGE, effect = 16},
							[30] = {element = COMBAT_DEATHDAMAGE, effect = 18},
							[31] = {element = COMBAT_HOLYDAMAGE, effect = 8},
							[32] = {element = COMBAT_ENERGYDAMAGE, effect = 12},
							[33] = {element = COMBAT_EARTHDAMAGE, effect = 9},
							[34] = {element = COMBAT_PHYSICALDAMAGE, effect = 1},
						}
					primaryType = typeChange[skull].element
				end
			end
			local skull = attacker:getSkull()
			primalTotal = primalTotal + GLOBAL_MULTIPLERS["elite_damage_multipler"]
			if skull == 15 then -- Increase DAMAGE
				primalTotal = primalTotal + GLOBAL_MULTIPLERS["eliteStrong_damage_multipler"]
		--	elseif skull == 27 then -- veterna damage increased
		--		primalTotal = primalTotal + GLOBAL_MULTIPLERS["champion_damage_multipler"]
			elseif skull == 22 then -- critical
				if math.random(100) <= 30 then
					eliteCrit = true
					primaryDamage = primaryDamage * 2
					creature:getPosition():sendMagicEffect(173)
				end
			end
		end
		primaryDamage = math.floor(primaryDamage + (primaryDamage * primalTotal / 100))
		-- Stongbox Boss
		if attacker:getStorageValue(PlayerStorage.strongBoxMonsterBoss) == 1 then
			primaryDamage = primaryDamage - (primaryDamage * GLOBAL_MULTIPLERS["strongbox_damage_multipler"] / 100)
		end
		if attacker:getStorageValue(PlayerStorage.monsterModifier_ailments) > 0 then
			if math.random(100) <= attacker:getStorageValue(PlayerStorage.monsterModifier_ailments) then
				primaryDamage = primaryDamage * 1.2
			end
		end
		--if primaryDamage < 0 then
		--	if BOSSESS_DAMAGE[attacker:getName()] then primaryDamage = primaryDamage * 2.3 end -- primaryDamage = BOSSESS_DAMAGE[attacker:getName()] end
		--	originalDamage = primaryDamage
		--end
		-- Dungeon Modifier
		local dungeonDamageMultipler = 0
		if attacker:getStorageValue(PlayerStorage.monsterModifier_damage) > 0 then
			dungeonDamageMultipler = dungeonDamageMultipler + attacker:getStorageValue(PlayerStorage.monsterModifier_damage)
		end
		if dungeonDamageMultipler > 0 then
			primaryDamage = primaryDamage + (primaryDamage * dungeonDamageMultipler / 100)
			primaryDamage = math.ceil(primaryDamage)
		end
		-- Special Attacks Boss
		local titan = mType:items() == "titan"
		local champion = mType:items() == "champion"
		local dungeonboss = mType:items() == "dungeonboss"
		if origin == ORIGIN_RANGED or origin == ORIGIN_MELEE or origin == ORIGIN_WAND or origin == ORIGIN_SPELL then
			if dungeonboss then
				primaryDamage = primaryDamage * 2
			elseif titan or champion then
				primaryDamage = primaryDamage * 1.5
			end
		end
		if dungeonboss then -- BOSSESS_DAMAGE[attacker:getName()] then
			if origin == ORIGIN_AUTOCAST then
				if titan or champion then
					primaryDamage = primaryDamage * 2
				else
					primaryDamage = primaryDamage * 3
				end
			end
		end
		mobDmg = primaryDamage
	end
	-- Player Armor
	if creature and creature:isPlayer() then
		-- Armor
		if colleftInfo[creature:getId()].armor then
			armorAmount = armorAmount + colleftInfo[creature:getId()].armor
		end
		if colleftInfo[creature:getId()].attributesItems[53] then -- armor
			armorAmount = armorAmount + colleftInfo[creature:getId()].attributesItems[53].value
		end
		--[[
		if colleftInfo[creature:getId()].attributesItems[96] then -- defense
			armorAmount = armorAmount + colleftInfo[creature:getId()].attributesItems[96].value
		end
		]]
		armorAmount = armorAmount + (armorAmount * armorAmountPercent / 100)
		armorDamageReduction = math.ceil(armorAmount / (armorAmount + 1000) * 100)
	end
	if attacker:hasBuff(BLIND) then
		if math.random(100) <= 50 then
			primaryDamage = 0
			Game.sendAnimatedText('MISS', attacker:getPosition(), 129, "Reggae One-10px-bordered")
		end
	end
	------------------------------ Less Damage Oslabienia
	local decreasedAttackPrimaryDamage = 0
	local decreasedAttackPrimaryDamageElemental = 0
	local decreasedAttackPrimaryDamagePhysical = 0
	local decreasedAttackPrimaryDamageDuality = 0
	if attacker:hasBuff(TOXIC_PATH) and creature:hasBuff(POISON_ITEM) then -- Toxic Path
		decreasedAttackPrimaryDamage = decreasedAttackPrimaryDamage + 15
	end
	if attacker:hasBuff(DISARMAMENT) then -- subklas Holy Aegis
		decreasedAttackPrimaryDamage = decreasedAttackPrimaryDamage + US_ENCHANTMENTS[166].subvalue
	end
	if attacker:hasBuff(SUPPRESSION) then
		decreasedAttackPrimaryDamage = decreasedAttackPrimaryDamage + 20
	end
	if attacker:isPlayer() and creature and creature:isMonster() then -- Subklas Permafrost Surge
		if colleftInfo[attacker:getId()].attributesItems[139] and creature:getBuff(CHILL) then
			decreasedAttackPrimaryDamage = decreasedAttackPrimaryDamage + US_ENCHANTMENTS[139].subvalue2
		end
	end
	if attacker:hasBuff(SUPPORT_PHYSICAL_REDUCTION_ATTACK) then
		decreasedAttackPrimaryDamagePhysical = decreasedAttackPrimaryDamagePhysical + attacker:getBuff(SUPPORT_PHYSICAL_REDUCTION_ATTACK).stacks
	end
	if attacker:hasBuff(SUPPORT_ELEMENTAL_REDUCTION_ATTACK) then
		decreasedAttackPrimaryDamageElemental = decreasedAttackPrimaryDamageElemental + attacker:getBuff(SUPPORT_ELEMENTAL_REDUCTION_ATTACK).stacks
	end
	if attacker:hasBuff(SUPPORT_DUALITY_REDUCTION_ATTACK) then
		decreasedAttackPrimaryDamageDuality = decreasedAttackPrimaryDamageDuality + attacker:getBuff(SUPPORT_DUALITY_REDUCTION_ATTACK).stacks
	end
	if creature:hasBuff(WEAKNESS_SUNDER) then
		decreasedAttackPrimaryDamage = decreasedAttackPrimaryDamage + 25
	end
	if decreasedAttackPrimaryDamage > 0 then
		decreasedAttackPrimaryDamagePhysical = decreasedAttackPrimaryDamagePhysical + decreasedAttackPrimaryDamage
		decreasedAttackPrimaryDamageElemental = decreasedAttackPrimaryDamageElemental + decreasedAttackPrimaryDamage
		decreasedAttackPrimaryDamageDuality = decreasedAttackPrimaryDamageDuality + decreasedAttackPrimaryDamage
	end
	if decreasedAttackPrimaryDamagePhysical > 0 then
		if primaryType == COMBAT_PHYSICALDAMAGE then
			primaryDamage = math.floor(primaryDamage - (primaryDamage * decreasedAttackPrimaryDamagePhysical / 100))
		end
		decreasedDamage = primaryDamage
	end
	if decreasedAttackPrimaryDamageElemental > 0 then
		if primaryType == COMBAT_FIREDAMAGE or primaryType == COMBAT_ICEDAMAGE or primaryType == COMBAT_ENERGYDAMAGE or primaryType == COMBAT_EARTHDAMAGE then
			primaryDamage = math.floor(primaryDamage - (primaryDamage * decreasedAttackPrimaryDamageElemental / 100))
		end
		decreasedDamage = primaryDamage
	end
	if decreasedAttackPrimaryDamageDuality > 0 then
		if primaryType == COMBAT_DEATHDAMAGE or primaryType == COMBAT_HOLYDAMAGE then
			primaryDamage = math.floor(primaryDamage - (primaryDamage * decreasedAttackPrimaryDamageDuality / 100))
		end
		decreasedDamage = primaryDamage
	end
	------------------------------ Take More Damage Oslabienia
	local morePrimal = 0
		if attacker:hasBuff(PASSING_PATH) and primaryType == COMBAT_DEATHDAMAGE then -- Passing Path
			if creature:getHealth() > 0 then
				local hpActual = creature:getHealth()
				local hpLower = (creature:getMaxHealth() * 0.15)
				if hpActual <= hpLower then
					doTargetCombatHealth(attacker:getId(), creature, COMBAT_UNDEFINEDDAMAGE, -creature:getHealth(), -creature:getHealth(), 94, ORIGIN_CONDITION, 0, 114)
					Game.sendAnimatedText('Passing Path', attacker:getPosition(), 192, "Reggae One-10px-bordered")
				end
			end
		end
	if attacker:isPlayer() then -- MORE DAMAGE
		if colleftInfo[attacker:getId()].attributesItems[180] then -- subklas Static Conduit
			morePrimal = morePrimal + US_ENCHANTMENTS[180].subvalue3
		end
		if colleftInfo[attacker:getId()].attributesItems[176] then -- subklas Culling Strike
			morePrimal = morePrimal + US_ENCHANTMENTS[176].subvalue2
		end
		if creature:hasBuff(SUPPRESSION) then -- subklas Heaven's Strike
			if colleftInfo[attacker:getId()].attributesItems[157] then
				if math.random(100) <= US_ENCHANTMENTS[157].subvalue then
					morePrimal = morePrimal + US_ENCHANTMENTS[157].subvalue2
				end
			end
		end
		if colleftInfo[attacker:getId()].attributesItems[150] then -- subklas Crusader Onslaught
			if math.random(1, 100) <= US_ENCHANTMENTS[150].subvalue5 then
				morePrimal = morePrimal + US_ENCHANTMENTS[150].subvalue6
				creature:getPosition():sendMagicEffect(91)
			elseif math.random(1, 100) <= US_ENCHANTMENTS[150].subvalue3 then
				morePrimal = morePrimal + US_ENCHANTMENTS[150].subvalue4
				creature:getPosition():sendMagicEffect(91)
			elseif math.random(1, 100) <= US_ENCHANTMENTS[150].subvalue then
				morePrimal = morePrimal + US_ENCHANTMENTS[150].subvalue2
				creature:getPosition():sendMagicEffect(49)
			end
		end
		if colleftInfo[attacker:getId()].attributesItems[168] then -- subklas Determination
			morePrimal = morePrimal + US_ENCHANTMENTS[168].subvalue
		end
		if colleftInfo[attacker:getId()].attributesItems[141] then -- Subklas Frigid Execution
			if creature:getHealth() <= (creature:getMaxHealth() * US_ENCHANTMENTS[141].subvalue) then
				morePrimal = morePrimal + US_ENCHANTMENTS[141].subvalue2
			end
		end
		if colleftInfo[attacker:getId()].attributesItems[133] then -- Subklas Infernal Wrath
			if creature:getHealth() >= (creature:getMaxHealth() * US_ENCHANTMENTS[133].subvalue) then
				morePrimal = morePrimal + US_ENCHANTMENTS[133].subvalue2
			end
		end
		if colleftInfo[attacker:getId()].attributesItems[129] then -- subklas Storm Overlord
			morePrimal = morePrimal + math.random(US_ENCHANTMENTS[129].subvalue, US_ENCHANTMENTS[129].subvalue2)
		end
		if colleftInfo[attacker:getId()].attributesItems[188] then -- subklas Quick Slash
			if attacker:getVarStats(STAT_ATTACKSPEED) >= 100 then
				morePrimal = morePrimal + US_ENCHANTMENTS[188].subvalue
			end
		end
		if colleftInfo[attacker:getId()].attributesItems[194] then -- subklas Unstable Darkness
			morePrimal = morePrimal + math.random(US_ENCHANTMENTS[194].subvalue, US_ENCHANTMENTS[194].subvalue2)
		end
		if attacker:getStorageValue(435024) == 11 then -- Archer + Paladin Dawnstalker
			local movementSpeedPercent = (((200 - attacker:getSpeed()) / 200) * 100) * -1
			morePrimal = morePrimal + (movementSpeedPercent * FUSION_SCALING[11].scaling)
		end
		if attacker:hasBuff(HARVEST_FUSION) then
			morePrimal = morePrimal + (attacker:getBuff(HARVEST_FUSION).stacks * 5)
		end
		if attacker:getStorageValue(435024) == 7 then -- Druid + Knight Warden
			morePrimal = morePrimal + FUSION_SCALING[7].bonus + (attacker:getMaxMana() * FUSION_SCALING[7].scaling)
		end
		if attacker:getStorageValue(435024) == 8 then -- Druid + Paladin Hierophant
			if colleftInfo[attacker:getId()].totalailmentChances then
				morePrimal = morePrimal + (colleftInfo[attacker:getId()].totalailmentChances * FUSION_SCALING[8].scaling)
			end
			if creature:getHealth() >= (creature:getMaxHealth() * FUSION_SCALING[8].hp) then
				morePrimal = morePrimal + FUSION_SCALING[8].bonus
			end
		end
		if attacker:getStorageValue(435024) == 4 then -- Sorcerer + Paladin Inquisitor
			morePrimal = morePrimal + (attacker:getMaxMana() * FUSION_SCALING[4].scaling)
		end
		if attacker:hasBuff(SAINT_BUFF) then
			if primaryType == COMBAT_HOLYDAMAGE then
				morePrimal = morePrimal + attacker:getBuff(SAINT_BUFF).stacks
			end
		end
		if attacker:getStorageValue(435024) == 9 then -- -- Druid + Shadow Umbral Shaman
			creature:addBuff(TOXIC_MARK)
			if creature:hasBuff(TOXIC_MARK) and creature:getBuff(TOXIC_MARK).stacks >= 10 then
				morePrimal = morePrimal + FUSION_SCALING[9].bonus
			end
			morePrimal = morePrimal + (math.max(attacker:getEffectiveSkillLevel(SKILL_DISTANCE), attacker:getEffectiveSkillLevel(SKILL_FISHING)) * FUSION_SCALING[9].scaling)
		end
		if attacker:getStorageValue(435024) == 10 then -- Archer + Knight Siegebreaker
			morePrimal = morePrimal + math.floor(attacker:getVarStats(STAT_ATTACKSPEED) * FUSION_SCALING[10].scaling)
		end
		if attacker:getStorageValue(435024) == 14 then -- Knight + Shadow Bloody Slayer
			creature:addBuff(DEEP_WOUNDS)
			if creature:hasBuff(DEEP_WOUNDS) then
				morePrimal = morePrimal + (creature:getBuff(DEEP_WOUNDS).stacks * FUSION_SCALING[14].bonus)
			end
			morePrimal = morePrimal + math.floor(attacker:getVarStats(STAT_ATTACKSPEED) * FUSION_SCALING[14].scaling)
		end
		if attacker:getStorageValue(435024) == 13 then -- Knight + Paladin Crusader
			morePrimal = morePrimal + FUSION_SCALING[13].bonus + (attacker:getEffectiveSkillLevel(SKILL_MELEE) *  FUSION_SCALING[13].scaling)
		end
		if colleftInfo[attacker:getId()].attributesItems[223] then -- unique Bloodlust
			if creature:hasBuff(BLEED_ITEM) then
				morePrimal = morePrimal + (US_ENCHANTMENTS[223].subvalue * creature:getBuff(BLEED_ITEM).stacks)
			end
		end
		if colleftInfo[attacker:getId()].attributesItems[189] then -- subklas Swift Killer
			if origin == ORIGIN_RANGED or origin == ORIGIN_MELEE or origin == ORIGIN_WAND then
				attacker:addBuff(SWIFT_KILLER)
				local swiftKillerStack = attacker:getBuff(SWIFT_KILLER)
				if swiftKillerStack then
					local swiftKillerStackMultipler = swiftKillerStack.stacks * US_ENCHANTMENTS[189].subvalue
					if swiftKillerStackMultipler then
					local conditionHaste = Condition(CONDITION_ATTRIBUTES)
					conditionHaste:setParameter(CONDITION_PARAM_SUBID, 712348)
					conditionHaste:setParameter(CONDITION_PARAM_ATTACKSPEED, swiftKillerStackMultipler)
					conditionHaste:setParameter(CONDITION_PARAM_TICKS, 3000)
					attacker:addCondition(conditionHaste)
					end
				end
			end
		end
		if attacker:hasBuff(RAGE) then -- subklas Rage
			morePrimal = morePrimal + attacker:getBuff(RAGE).stacks * 2
		end
		if attacker:getStorageValue(435024) == 5 then -- Sorcerer + Shadow Warlock
			if math.random(100) <= FUSION_SCALING[5].chance then
				morePrimal = morePrimal + FUSION_SCALING[5].bonus
			end
			morePrimal = morePrimal + (math.max(attacker:getEffectiveSkillLevel(SKILL_DISTANCE), attacker:getEffectiveSkillLevel(SKILL_FISHING)) * FUSION_SCALING[5].scaling)
		end
		if attacker:getStorageValue(435024) == 1 then -- Sorcerer + Druid Elementalist
			if primaryType == COMBAT_FIREDAMAGE or primaryType == COMBAT_ICEDAMAGE or primaryType == COMBAT_ENERGYDAMAGE or primaryType == COMBAT_EARTHDAMAGE then
				if attacker:hasBuff(FIRE) then
					morePrimal = morePrimal + FUSION_SCALING[1].bonus
				elseif attacker:hasBuff(ICE) then
					morePrimal = morePrimal + FUSION_SCALING[1].bonus
				elseif attacker:hasBuff(LIGHTNING) then
					morePrimal = morePrimal + FUSION_SCALING[1].bonus
				elseif attacker:hasBuff(EARTH) then
					morePrimal = morePrimal + FUSION_SCALING[1].bonus
				end
				morePrimal = morePrimal + (attacker:getEffectiveSkillLevel(SKILL_FISHING) * FUSION_SCALING[1].scaling)
			end
		end
		if attacker:getStorageValue(435024) == 15 then -- Paladin + Shadow Abyssal Cleric
			morePrimal = morePrimal + math.floor(attacker:getSpecialSkill(SPECIALSKILL_CRITICALHITCHANCE) * FUSION_SCALING[15].scaling)
		end
		if attacker:getStorageValue(435024) == 2 then -- Sorcerer + Archer Thundershot
				local hpActual = creature:getHealth()
				local hpLower = (creature:getMaxHealth() * FUSION_SCALING[2].hp)
				if hpActual <= hpLower then
					morePrimal = morePrimal + FUSION_SCALING[2].bonus
				end
				local movementSpeedPercent = (((200 - attacker:getSpeed()) / 200) * 100) * -1
				morePrimal = morePrimal + (movementSpeedPercent * FUSION_SCALING[2].scaling)
		end
		if attacker:getStorageValue(435024) == 3 then -- Sorcerer + Knight Battlemage
			if creature:hasBuff(IGNITE_ITEM) then
				morePrimal = morePrimal + FUSION_SCALING[3].bonus
			end
			if colleftInfo[attacker:getId()].totalailmentChances then
				morePrimal = morePrimal + (colleftInfo[attacker:getId()].totalailmentChances * FUSION_SCALING[3].scaling)
			end
		end
		if colleftInfo[attacker:getId()].attributesItems[145] and creature:hasBuff(POISON_ITEM) then -- Epidemic
			morePrimal = morePrimal + US_ENCHANTMENTS[145].subvalue
		end
		if attacker:getStorageValue(435024) == 6 then -- Druid + Archer Toxic hunter
			if colleftInfo[attacker:getId()].totalailmentChances then
				morePrimal = morePrimal + (colleftInfo[attacker:getId()].totalailmentChances * FUSION_SCALING[6].scaling)
			end
		end
		if attacker:getStorageValue(435024) == 12 then -- Archer + Shadow Nightstalker
			attacker:addBuff(ASSASSIN_INSTINCT)
			local criticalChance = 0
			if attacker:hasBuff(ASSASSIN_INSTINCT) then
				criticalChance = attacker:getBuff(ASSASSIN_INSTINCT).stacks
			end
			local CriticalDamageAdd = Condition(CONDITION_ATTRIBUTES)
			CriticalDamageAdd:setParameter(CONDITION_PARAM_TICKS, 60000)
			CriticalDamageAdd:setParameter(CONDITION_PARAM_SPECIALSKILL_CRITICALHITCHANCE, criticalChance)
			CriticalDamageAdd:setParameter(CONDITION_PARAM_SUBID, 731600)
			attacker:addCondition(CriticalDamageAdd)
		end
		if attacker:getStorageValue(435024) == 12 then -- Archer + Shadow Nightstalker
			morePrimal = morePrimal + math.floor(attacker:getSpecialSkill(SPECIALSKILL_CRITICALHITCHANCE) * FUSION_SCALING[12].scaling)
		end
	end
	if morePrimal > 0 then
		primaryDamage = math.floor(primaryDamage + (primaryDamage * morePrimal / 100))
	end

	local primaryDamageTotal = 0
	local dotDamageBonus = 0
	local SpellprimaryDamageTotal = 0
	local MeleeprimaryDamageTotal = 0
	if attacker:isPlayer() then
		if colleftInfo[attacker:getId()].attributesItems[258] then -- unique Demon Shield
			primaryType = COMBAT_FIREDAMAGE
		end
		local critDamage = attacker:getSpecialSkill(SPECIALSKILL_CRITICALHITAMOUNT)
		--- Added Damage
		local dualWilding = false
		local basicDamage = 0
		if (origin == ORIGIN_MELEE or origin == ORIGIN_WAND or origin == ORIGIN_RANGED) then -- Base Basic Damage
			if colleftInfo[attacker:getId()].isDualWielding then
				dualWilding = true
			end
			if colleftInfo[attacker:getId()].convertWeaponType[attacker:getId()] then
				primaryType = colleftInfo[attacker:getId()].convertWeaponType[attacker:getId()]
			end
			basicDamage = totalAttackPower(attacker, primaryType)
		--	local highestStat = math.max(attacker:getEffectiveSkillLevel(SKILL_MELEE), attacker:getEffectiveSkillLevel(SKILL_DISTANCE), attacker:getEffectiveSkillLevel(SKILL_FISHING)) (highestStat * 0.02) +
			if attacker:hasBuff(CLEAVE) then
				basicDamage = basicDamage * (1.5 + (	( (attacker:getBuff(CLEAVE).stacks * 0.15)) )	) -- (6.0 + ((attacker:getEffectiveSkillLevel(SKILL_MELEE) * 0.01) + (attacker:getBuff(CLEAVE).stacks * 0.02) * 5))
			elseif attacker:hasBuff(MULTISHOT) then
				basicDamage = basicDamage * (1.5 + (	( (attacker:getBuff(MULTISHOT).stacks * 0.15)) )	)
			elseif attacker:hasBuff(MYSTIC_FOCUS) then
				basicDamage = basicDamage * (1.5 + (	( (attacker:getBuff(MYSTIC_FOCUS).stacks * 0.15)) )	)
			end
			if colleftInfo[attacker:getId()].attributesItems[215] then -- Fury Hits
				attacker:addBuff(FURY_HITS)
			end
			if attacker:hasBuff(BASIC_DAMAGE_SUPPORT) then
				basicDamage = basicDamage * (1 + (attacker:getBuff(BASIC_DAMAGE_SUPPORT).stacks / 100))
			end
			if attacker:hasBuff(MULTI_STRIKE) then
				basicDamage = basicDamage * 2
			end
			primaryDamage = basicDamage
			meleeStart = primaryDamage
			
		end

		if colleftInfo[attacker:getId()].attributesItems[83] then -- FIRE_WEAKNESS
			creature:addBuff(FIRE_WEAKNESS)
		end
		if colleftInfo[attacker:getId()].attributesItems[113] then -- Earth Weakness
			creature:addBuff(EARTH_WEAKNESS)
		end
		local storagesToCheck = {27, 65, 79, 80, 81}

		for _, i in ipairs(storagesToCheck) do
			local value = attacker:getStorageValue(PlayerStorage.basicPen + i)
			if value > 0 then
				creature:addBuff(BASIC_WEAKNESS)
				creature:setBuffStacks(BASIC_WEAKNESS, value)
			end
		end

		if colleftInfo[attacker:getId()].attributesItems[51] then -- haste on hit
			if math.random(100) <= colleftInfo[attacker:getId()].attributesItems[51].value then -- colleftInfo[attacker:getId()].attributesItems[51].value then
				local hasteAdded = attacker:getBaseSpeed() * 33 / 100
				local conditionHaste = Condition(CONDITION_HASTE, CONDITIONID_DEFAULT)
				conditionHaste:setParameter(CONDITION_PARAM_SUBID, 777777)
				conditionHaste:setParameter(CONDITION_PARAM_TICKS, 2 * 1000) --2 secs
				conditionHaste:setFormula(0.0, hasteAdded, 0.0, hasteAdded)
				attacker:addCondition(conditionHaste)
				attacker:addBuff(HASTE_ITEM)
			end
		end
		if colleftInfo[attacker:getId()].attributesItems[85] then -- Frostbitten Feet
			local sped2 = attacker:getBaseSpeed() * 0.30 -- -30%
			local chill2 = Condition(CONDITION_PARALYZE)
			chill2:setParameter(CONDITION_PARAM_TICKS, 2000)
			chill2:setParameter(CONDITION_PARAM_SPEED, -sped2)
			chill2:setParameter(CONDITION_PARAM_SUBID, 777782)
			creature:addCondition(chill2)
			Game.sendAnimatedText('Frostbitten Feet', attacker:getPosition(), 129, "Reggae One-10px-bordered")
			creature:addBuff(FROSTBITTEN)
		end
		-- Increase Items
		local startDamage = primaryDamage
		----------------------- GLOBAL BOOST --------------------------
		if getGlobalBuff(BUFF_GLOBAL_DAMAGE) then
			primaryDamageTotal = primaryDamageTotal + 20
		end
		--- Paths ---
			--	if shockChance(attacker) then
			--		morePrimal = morePrimal + shockChance(attacker) * 3
			--	end
			--	if chillChance(attacker) then
			--		morePrimal = morePrimal + (chillChance(attacker) * 3)
			--	end
		local pathConfigs = {
			[TOXIC_PATH]   = { dmg = COMBAT_EARTHDAMAGE, buff = POISON_ITEM, source = creature },
			[SACRED_PATH]  = { dmg = COMBAT_HOLYDAMAGE, buff = SUPPRESSION, source = creature },
			[CRYO_PATH]    = { dmg = COMBAT_ICEDAMAGE, buff = CHILL, source = creature },
			[THUNDER_PATH] = { dmg = COMBAT_ENERGYDAMAGE, buff = SHOCK, source = creature },
			[PASSING_PATH] = { dmg = COMBAT_DEATHDAMAGE, buff = HARVEST, source = attacker },
			[BLOODY_PATH]  = { dmg = COMBAT_PHYSICALDAMAGE, buff = BLEED_ITEM, source = creature },
			[PYRO_PATH]    = { dmg = COMBAT_FIREDAMAGE, buff = IGNITE_ITEM, source = creature }
		}

		-- bez iteracji po całej tabeli
		local cfg = nil
		if attacker:hasBuff(TOXIC_PATH) then cfg = pathConfigs[TOXIC_PATH] end
		if attacker:hasBuff(SACRED_PATH) then cfg = pathConfigs[SACRED_PATH] end
		if attacker:hasBuff(CRYO_PATH) then cfg = pathConfigs[CRYO_PATH] end
		if attacker:hasBuff(THUNDER_PATH) then cfg = pathConfigs[THUNDER_PATH] end
		if attacker:hasBuff(PASSING_PATH) then cfg = pathConfigs[PASSING_PATH] end
		if attacker:hasBuff(BLOODY_PATH) then cfg = pathConfigs[BLOODY_PATH] end
		if attacker:hasBuff(PYRO_PATH) then cfg = pathConfigs[PYRO_PATH] end
		local ailmnetTotal = 0
		if colleftInfo[attacker:getId()].totalailmentChances then
			ailmnetTotal = colleftInfo[attacker:getId()].totalailmentChances
		end
	--	if colleftInfo[attacker:getId()].attributesItems[210] then -- all aliments chance
	--		ailmnetTotal = ailmnetTotal + colleftInfo[attacker:getId()].attributesItems[210].value
	--	end
	
		-- zastosowanie bonusu
	--	if cfg and primaryType == cfg.dmg and cfg.source:hasBuff(cfg.buff) then
	--		primaryDamageTotal = primaryDamageTotal + ailmnetTotal
	--	end
		primaryDamageTotal = primaryDamageTotal + ailmnetTotal
		--- Auras ---
		if attacker:hasBuff(AURA_ELEMENTAL) then
			if primaryType == COMBAT_FIREDAMAGE or primaryType == COMBAT_ICEDAMAGE or primaryType == COMBAT_ENERGYDAMAGE or primaryType == COMBAT_EARTHDAMAGE then
				primaryDamageTotal = primaryDamageTotal + (25 + (attacker:getBuff(AURA_ELEMENTAL).stacks * 1.2))
			end
		end
		if attacker:hasBuff(AURA_PHYSICAL) then
			if primaryType == COMBAT_PHYSICALDAMAGE then
				primaryDamageTotal = primaryDamageTotal + (25 + (attacker:getBuff(AURA_PHYSICAL).stacks * 1.2))
			end
		end
		if attacker:hasBuff(AURA_HOLLOW) then
			if primaryType == COMBAT_HOLYDAMAGE or primaryType == COMBAT_DEATHDAMAGE then
				primaryDamageTotal = primaryDamageTotal + (25 + (attacker:getBuff(AURA_HOLLOW).stacks * 1.2))
			end
		end
		----------------------- TALENTS --------------------------			ON ATTACK
		-- Items

		----------- Increase Damage
		if attacker:hasBuff(ILLUMINATION_DOT_UNIQUE) then
			if primaryType == COMBAT_HOLYDAMAGE then
				primaryDamageTotal = primaryDamageTotal + (attacker:getBuff(ILLUMINATION_DOT_UNIQUE).stacks * 5)
			end
		end
		if colleftInfo[attacker:getId()].attributesItems[224] then -- unique Frost Mighty
			if primaryType == COMBAT_ICEDAMAGE then
				primaryDamageTotal = primaryDamageTotal + math.floor(attacker:getEffectiveSkillLevel(SKILL_MELEE) * US_ENCHANTMENTS[224].subvalue) + math.floor(attacker:getEffectiveSkillLevel(SKILL_FISHING) * US_ENCHANTMENTS[224].subvalue)
			end
		end
		if colleftInfo[attacker:getId()].attributesItems[33] then -- Boss Damage
			if creature:isMonster() and MonsterType(creature:getName()):getRace() == 6 then
				primaryDamageTotal = primaryDamageTotal + colleftInfo[attacker:getId()].attributesItems[33].value
			end
		end
		if colleftInfo[attacker:getId()].attributesItems[36] then -- Elite Damage
			if creature:isMonster() and creature:getSkull() >= 7 then
				primaryDamageTotal = primaryDamageTotal + colleftInfo[attacker:getId()].attributesItems[36].value
			end
		end
		if attacker:hasBuff(BUFF_DAMAGE_ATTRIBUTES) then
			primaryDamageTotal = primaryDamageTotal + 20
		end
		if origin == ORIGIN_SPELL or origin == ORIGIN_AUTOCAST then
			if colleftInfo[attacker:getId()].attributesItems[18] then -- Spell Damage 15
				primaryDamageTotal = primaryDamageTotal + colleftInfo[attacker:getId()].attributesItems[18].value
			end
		end
		if origin == ORIGIN_MELEE or origin == ORIGIN_RANGED or origin == ORIGIN_WAND then
			if colleftInfo[attacker:getId()].attributesItems[19] then -- Basic Damage
				primaryDamageTotal = primaryDamageTotal + colleftInfo[attacker:getId()].attributesItems[19].value
			end
		end
		if origin == ORIGIN_MELEE or origin == ORIGIN_RANGED or origin == ORIGIN_WAND then
			if colleftInfo[attacker:getId()].attributesItems[231] then -- unique Reflected Attacks
				if attacker:hasBuff(REFLECTED_ATTACKS) then
					primaryDamageTotal = primaryDamageTotal + attacker:getBuff(REFLECTED_ATTACKS).stacks
				end
			end
		end
		if colleftInfo[attacker:getId()].attributesItems[20] then -- Damage
			primaryDamageTotal = primaryDamageTotal + colleftInfo[attacker:getId()].attributesItems[20].value
		end
		if colleftInfo[attacker:getId()].attributesItems[12] then -- Elemetal Damage 30
			if primaryType == COMBAT_FIREDAMAGE or primaryType == COMBAT_ICEDAMAGE or primaryType == COMBAT_ENERGYDAMAGE or primaryType == COMBAT_EARTHDAMAGE then
				primaryDamageTotal = primaryDamageTotal + colleftInfo[attacker:getId()].attributesItems[12].value
			end
		end
		if colleftInfo[attacker:getId()].attributesItems[196] then -- Duality Damage
			if primaryType == COMBAT_HOLYDAMAGE or primaryType == COMBAT_DEATHDAMAGE then
				primaryDamageTotal = primaryDamageTotal + colleftInfo[attacker:getId()].attributesItems[196].value
			end
		end
		local zywiolyIds = {11, 108, 57, 58, 59, 60, 61, 62}
		for _, id in ipairs(zywiolyIds) do
			local attr = colleftInfo[attacker:getId()].attributesItems[id]
			if attr and US_ENCHANTMENTS[id] and US_ENCHANTMENTS[id].combatDamage then
				if primaryType == US_ENCHANTMENTS[id].combatDamage then
					primaryDamageTotal = primaryDamageTotal + attr.value
				end
			end
		end
		if colleftInfo[attacker:getId()].attributesItems[184] then -- unique Mana Cape Mana Core
			if attacker:getMaxMana() >= US_ENCHANTMENTS[184].subvalue2 then
				primaryDamageTotal = primaryDamageTotal + US_ENCHANTMENTS[184].subvalue3
			end
		end
		if colleftInfo[attacker:getId()].attributesItems[212] then -- unique Lava Focus - elemental damage
			if primaryType == COMBAT_FIREDAMAGE or primaryType == COMBAT_ICEDAMAGE or primaryType == COMBAT_EARTHDAMAGE or primaryType == COMBAT_ENERGYDAMAGE then
				local hpores = math.floor(math.max(attacker:getMaxHealth(), attacker:getMaxEnergyShield()) * US_ENCHANTMENTS[212].subvalue)
				primaryDamageTotal = primaryDamageTotal + math.min(hpores, 400)
			end
		end
		if colleftInfo[attacker:getId()].attributesItems[251] then -- unique Divine Focus - duality damage
			if primaryType == COMBAT_HOLYDAMAGE or primaryType == COMBAT_DEATHDAMAGE then
				local hpores = math.floor(math.max(attacker:getMaxHealth(), attacker:getMaxEnergyShield()) * US_ENCHANTMENTS[251].subvalue)
				primaryDamageTotal = primaryDamageTotal + math.min(hpores, 400)
			end
		end
		if colleftInfo[attacker:getId()].attributesItems[252] then -- unique Divine Focus - physical damage
			if primaryType == COMBAT_PHYSICALDAMAGE then
				local hpores = math.floor(math.max(attacker:getMaxHealth(), attacker:getMaxEnergyShield()) * US_ENCHANTMENTS[252].subvalue)
				primaryDamageTotal = primaryDamageTotal + math.min(hpores, 400)
			end
		end
		if colleftInfo[attacker:getId()].attributesItems[221] then -- Hermes Speed
			local movementSpeedPercent = (((200 - attacker:getSpeed()) / 200) * 100) * -1
			primaryDamageTotal = primaryDamageTotal + math.min((movementSpeedPercent * US_ENCHANTMENTS[221].subvalue), 400)
		end
		if origin == ORIGIN_MELEE or origin == ORIGIN_RANGED or origin == ORIGIN_WAND then
			if colleftInfo[attacker:getId()].attributesItems[256] then -- unique focused strike
				primaryDamageTotal = primaryDamageTotal + math.min((attacker:getVarStats(STAT_ATTACKSPEED) * US_ENCHANTMENTS[256].subvalue), 400)
			end
			if attacker:hasBuff(COMBAT_AURA) then
				MeleeprimaryDamageTotal = MeleeprimaryDamageTotal + (attacker:getBuff(COMBAT_AURA).stacks * 1.2) + 25
			end
		end
		if origin == ORIGIN_MELEE or origin == ORIGIN_RANGED or origin == ORIGIN_WAND then
			if attacker:hasBuff(FURY_HITS) then
				MeleeprimaryDamageTotal = MeleeprimaryDamageTotal + (attacker:getBuff(FURY_HITS).stacks * 0.3)
			end
		end
		if colleftInfo[attacker:getId()].attributesItems[202] then -- Spell Wisdom
			SpellprimaryDamageTotal = SpellprimaryDamageTotal + attacker:getLevel()
		end
		if attacker:hasBuff(SORCERER_TRAIT) then
			SpellprimaryDamageTotal = SpellprimaryDamageTotal + (attacker:getBuff(SORCERER_TRAIT).stacks * 5)
			if primaryType == COMBAT_FIREDAMAGE or primaryType == COMBAT_ICEDAMAGE or primaryType == COMBAT_EARTHDAMAGE or primaryType == COMBAT_ENERGYDAMAGE then
				primaryDamageTotal = primaryDamageTotal + 20
			end
		end
		if colleftInfo[attacker:getId()].attributesItems[140] and creature:hasBuff(CHILL) then -- subklas Shatterstorm
			attacker:addBuff(SHATTERSTORM)
		end
		if attacker:hasBuff(PHANTOM_RUN) then
			if primaryType == COMBAT_DEATHDAMAGE then
				primaryDamageTotal = primaryDamageTotal + 33
			end
		end
		if attacker:isPlayer() and attacker:getMagicLevel() then
			primaryDamageTotal = primaryDamageTotal + (attacker:getMagicLevel() * 1)
		end
		if SpellprimaryDamageTotal > 0 then
			primaryDamageTotal = primaryDamageTotal + SpellprimaryDamageTotal
		end
		if MeleeprimaryDamageTotal > 0 then
			primaryDamageTotal = primaryDamageTotal + MeleeprimaryDamageTotal
		end
		if origin == ORIGIN_DOT then
			primaryDamageTotal = primaryDamageTotal + dotDamageBonus
		end
		if colleftInfo[attacker:getId()].attributesItems[84] then -- Fang Trust
			if primaryType == COMBAT_PHYSICALDAMAGE then
				primaryDamageTotal = primaryDamageTotal + attacker:getEffectiveSkillLevel(SKILL_DISTANCE)
			end
		end
		if colleftInfo[attacker:getId()].attributesItems[77] then -- Deep Death You deal only death damage
			if primaryType ~= COMBAT_DEATHDAMAGE then
				primaryDamage = 0
			end
			if primaryType == COMBAT_DEATHDAMAGE then
				primaryDamageTotal = primaryDamageTotal + attacker:getEffectiveSkillLevel(SKILL_DISTANCE)
			end
		end
		if primaryDamageTotal > 0 then -- Bazowy * Increased
			primaryDamage = math.floor(primaryDamage + (primaryDamage * primaryDamageTotal / 100))
		end
		-- Melee More Damage
		local moreMeleeDamage = 0
		local moreMeleeDamageSecond = 0
		if (origin == ORIGIN_MELEE or origin == ORIGIN_WAND or origin == ORIGIN_RANGED) then
			if colleftInfo[attacker:getId()].attributesItems[162] then -- Subklas Rage
				attacker:addBuff(RAGE)
			end
			if morePrimal > 0 then
				moreMeleeDamage = moreMeleeDamage + morePrimal
			end
			originalDamage = primaryDamage
			if colleftInfo[attacker:getId()].attributesItems[214] then -- "Weak Points",
				if math.random(100) <= US_ENCHANTMENTS[214].subvalue2 then
					moreMeleeDamage = moreMeleeDamage + US_ENCHANTMENTS[214].subvalue
					Game.sendAnimatedText('Weak Point', attacker:getPosition(), 129, "Reggae One-10px-bordered")
				end
			end
			if moreMeleeDamage > 0 then
				primaryDamage = math.floor(primaryDamage + (primaryDamage * (moreMeleeDamage) / 100))
				originalDamage = primaryDamage
			end
		end
		-- Globalny Damage
		if attacker:hasBuff(MONSTER_SOUL_DAMAGE) then
			primaryDamage = math.floor(primaryDamage + (primaryDamage * 20 / 100))
		end
		-- Boss Debuffs
		if creature:hasBuff(BOSS_DAMAGE_REDUCTION) then
			primaryDamage = primaryDamage / 2
		end
		-- TOTAL_DAMAGE
		local damage = (primaryDamage)
		if damage > 0 then
			damage = damage * -1
		end
		dotDamageMultipler = colleftInfo[attacker:getId()].attackPower  / 5
		if primaryDamageTotal > 0 then
			dotDamageMultipler = dotDamageMultipler + (dotDamageMultipler * (primaryDamageTotal + dotDamageBonus) / 100)
		end
		-- Only Melee
		-- Only Spells
			local skull = 0
			local race = 0
			local mType = nil
			local dungeonBoss = nil
			local titan = nil
		if creature and creature:getHealth() > 0 then
			if creature:isMonster() then
			 skull = creature:getSkull()
			 race = MonsterType(creature:getName()):getRace()
			 mType = creature:getType()
			 dungeonBoss = mType:items() == "dungeonboss"
			 titan = mType:items() == "titan"
			end
		end
		if colleftInfo[attacker:getId()].attributesItems[25] then -- Unique executoner
			if creature:getHealth() > 0 then
				local healthPercent = 0.10
				if dungeonBoss or race == 6 then
					healthPercent = 0.05
				elseif skull > 6 or titan then
					healthPercent = 0.05
				end
				local hpActual = creature:getHealth() + damage
				local hpLower = (creature:getMaxHealth() * healthPercent)
				if hpActual <= hpLower then
					doTargetCombatHealth(attacker:getId(), creature, COMBAT_UNDEFINEDDAMAGE, -creature:getHealth(), -creature:getHealth(), 290, ORIGIN_CONDITION, 0, 22)
					Game.sendAnimatedText('Execute', attacker:getPosition(), 192, "Reggae One-10px-bordered")
				end
			end
		end
		local overpower = 0
		if spellOverpower(attacker, primaryType) then
			overpower = spellOverpower(attacker, primaryType)
		end
		--[[
		if attacker:hasBuff(SHRINE_DAMAGE) then
			overpower = overpower + 50
		end
		if colleftInfo[attacker:getId()].attributesItems[240] then -- Physical Damage Overpower 240
			if primaryType == COMBAT_PHYSICALDAMAGE then
				overpower = overpower + colleftInfo[attacker:getId()].attributesItems[240].value
			end
		end
		if colleftInfo[attacker:getId()].attributesItems[241] then -- Elemental Damage Overpower 241
			if primaryType == COMBAT_FIREDAMAGE or primaryType == COMBAT_ICEDAMAGE or primaryType == COMBAT_ENERGYDAMAGE or primaryType == COMBAT_EARTHDAMAGE then
				overpower = overpower + colleftInfo[attacker:getId()].attributesItems[241].value
			end
		end
		if colleftInfo[attacker:getId()].attributesItems[242] then -- Duality Damage Overpower 242
			if primaryType == COMBAT_HOLYDAMAGE or primaryType == COMBAT_DEATHDAMAGE then
				overpower = overpower + colleftInfo[attacker:getId()].attributesItems[242].value
			end
		end
		if attacker:getStorageValue(PlayerStorage.sideBoss13) >= 1 then -- miniboss overpower 15%
			overpower = overpower + 15
		end
		if attacker:getStorageValue(PlayerStorage.sideBoss14) >= 1 then -- miniboss overpower 15%
			overpower = overpower + 15
		end
		if attacker:getStorageValue(PlayerStorage.sideBoss15) >= 1 then -- Realm Boss Overpower 10%
			overpower = overpower + 10
		end
		if attacker:getStorageValue(PlayerStorage.sideBoss16) >= 1 then -- Realm Boss Overpower 10%
			overpower = overpower + 10
		end
		if attacker:getStorageValue(PlayerStorage.sideBoss17) >= 1 then -- Realm Boss Overpower 10%
			overpower = overpower + 10
		end
		if attacker:getStorageValue(PlayerStorage.sideBoss18) >= 1 then -- Realm Boss Overpower 10%
			overpower = overpower + 10
		end
		if attacker:getStorageValue(PlayerStorage.sideBoss19) >= 1 then -- Bridge Boss Overpower 10%
			overpower = overpower + 10
		end
		if attacker:getStorageValue(PlayerStorage.sideBoss20) >= 1 then -- Bridge Boss Overpower 10%
			overpower = overpower + 10
		end
		if attacker:getStorageValue(PlayerStorage.sideBoss21) >= 1 then -- Bridge Boss Overpower 10%
			overpower = overpower + 10
		end
		if attacker:getStorageValue(PlayerStorage.sideBoss22) >= 1 then -- Bridge Boss Overpower 10%
			overpower = overpower + 10
		end
		--]]
		if overpower > 0 then
			primaryDamage = math.floor(primaryDamage + (primaryDamage * overpower / 100))
		end
		-- TOTAL_DAMAGE
		local function sendDamageMessage(attacker, prim, originType, damageType, damageTotal, originalDamage, finalDamage, channelType, spellInfo, moreDamage, chat)
			local messageType = spellInfo or "[Basic]"
			local damageTypeText = damageType ~= COMBAT_PHYSICALDAMAGE and element_names[damageType] or "Physical"
			if messageType == "[Basic]" then
				originalDamage = meleeStart * -1
				if dualWilding then
					originalDamage = originalDamage / 2
				end
				finalDamage = finalDamage * -1
			end
			local afterDamage = originalDamage + (originalDamage * damageTotal / 100)
			local afterDamageMore = afterDamage + (afterDamage * moreDamage / 100)
			local overpowerTxt = afterDamage * overpower / 100
			local message = string.format("%s %s[%s]\n> [%s] Damage Increased: +%d%% [%s] More Damage: %d%% [%s] Overpower: %d%% [%s]", prim, messageType, damageTypeText, shortNumbers(originalDamage*-1,2), damageTotal, shortNumbers(afterDamage*-1,2), moreDamage, shortNumbers(afterDamageMore*-1,2), overpower, shortNumbers(finalDamage*-1,2))
			attacker:sendChannelMessage("", message, channelType, chat)
		end
		if attacker:isPlayer() and attacker:getStorageValue(PlayerStorage.damageInfo) == 1 and attacker:openChannel(17) then
			if (origin == ORIGIN_SPELL or origin == ORIGIN_AUTOCAST) or origin == ORIGIN_DOT or origin == ORIGIN_ATTRIBUTE then
				local spellType = "[Spell]"
				if origin == ORIGIN_DOT then
					spellType = "[DoT]"
				elseif origin == ORIGIN_AUTOCAST then
					spellType = "[Spell]"
				elseif origin == ORIGIN_ATTRIBUTE then
					spellType = "[Cast/Pros]"
				end
				if primaryDamage < 0 then
					sendDamageMessage(attacker, "["..spellName.."]", origin, primaryType, primaryDamageTotal, originalDamage, primaryDamage, TALKTYPE_CHANNEL_R1, spellType, morePrimal, 17)
				end
			end
		end
		if attacker:isPlayer() and attacker:getStorageValue(PlayerStorage.basicInfo) == 1 and attacker:openChannel(32) then
			if origin == ORIGIN_RANGED or origin == ORIGIN_MELEE or origin == ORIGIN_WAND then
				local spellType = "[Basic]"
				local damage = primaryDamage
				local oriDamage = originalDamage
				if dualWilding then
					oriDamage = oriDamage / 2
					damage = damage / 2
				end
				sendDamageMessage(attacker, "", origin, primaryType, primaryDamageTotal, oriDamage, damage, TALKTYPE_CHANNEL_O, spellType, moreMeleeDamage, 32)
			end
		end
		------------------------ KONIEC PODLICZENIA OBRAZEN !!
		if origin == ORIGIN_MELEE or origin == ORIGIN_RANGED or origin == ORIGIN_WAND then -- Health On Hit
			if colleftInfo[attacker:getId()].attributesItems[46] then
				attacker:addHealth(colleftInfo[attacker:getId()].attributesItems[46].value)
			end
			if colleftInfo[attacker:getId()].attributesItems[201] then
				attacker:addMana(colleftInfo[attacker:getId()].attributesItems[201].value)
			end
			if attacker:getCharacterStat(CHARSTAT_HPHIT) then -- HP on hit
				attacker:addHealth(attacker:getCharacterStat(CHARSTAT_HPHIT))
			end
			if attacker:getCharacterStat(CHARSTAT_ESHIT) then -- ES on hit
				attacker:addEnergyShield(attacker:getCharacterStat(CHARSTAT_ESHIT))
			end
		end
		if origin == ORIGIN_MELEE or origin == ORIGIN_RANGED or origin == ORIGIN_WAND or origin == ORIGIN_SPELL or origin == ORIGIN_AUTOCAST then -- Energy Shield on Hit
			if colleftInfo[attacker:getId()].attributesItems[111] then
				attacker:addEnergyShield(colleftInfo[attacker:getId()].attributesItems[111].value)
			end
		end
		if (origin == ORIGIN_SPELL or origin == ORIGIN_AUTOCAST) or origin == ORIGIN_MELEE or origin == ORIGIN_RANGED or origin == ORIGIN_WAND then -- Critical Hits
			if colleftInfo[attacker:getId()].attributesItems[94] then
				if math.random(100) <= colleftInfo[attacker:getId()].attributesItems[94].value then
					attacker:addBuff(CRITICAL_HITS)
					local critcalHits = attacker:getBuff(CRITICAL_HITS)
					if critcalHits then
						local critcalHitsStackMultipler = critcalHits.stacks
						if critcalHitsStackMultipler then
							local conditionHaste = Condition(CONDITION_ATTRIBUTES)
							conditionHaste:setParameter(CONDITION_PARAM_SUBID, 712347)
							conditionHaste:setParameter(CONDITION_PARAM_ATTACKSPEED, critcalHitsStackMultipler)
							conditionHaste:setParameter(CONDITION_PARAM_TICKS, 3000) -- 5 secs
							attacker:addCondition(conditionHaste)
						end
					end
				end
			end
		end
		if colleftInfo[attacker:getId()].attributesItems[98] then -- Queen Blade
			if (origin == ORIGIN_SPELL or origin == ORIGIN_AUTOCAST) or origin == ORIGIN_MELEE or origin == ORIGIN_RANGED or origin == ORIGIN_WAND then
				if math.random(100) <= colleftInfo[attacker:getId()].attributesItems[98].value then
					if doTargetCombatHealth(attacker:getId(), creature, COMBAT_PHYSICALDAMAGE, 5, 5, 94, ORIGIN_CONDITION, 1000, 20) then
						creature:startDOT(attacker, BLEED_ITEM, 0, false, 5000)
					end
				end
			end
		end
		local ailment = {
			[21] = { debuff = BLEED_ITEM, damageType = COMBAT_PHYSICALDAMAGE, damage = true, time = 5000, name = "Bleed" },
			[28] = { debuff = IGNITE_ITEM, damageType = COMBAT_FIREDAMAGE, damage = true, time = 5000, name = "Ignite" },
			[32] = { debuff = POISON_ITEM, damageType = COMBAT_EARTHDAMAGE, damage = true, time = 5000, name = "Poison" },
			[37] = { debuff = CHILL, damageType = COMBAT_ICEDAMAGE, damage = true, time = 5000, name = "Chill" },
			[41] = { debuff = SHOCK, damageType = COMBAT_ENERGYDAMAGE, damage = true, time = 5000, name = "Shock" },
			[42] = { debuff = HARVEST_DEBUFF, damageType = COMBAT_DEATHDAMAGE, damage = true, time = 5000, name = "Harvest" },
			[45] = { debuff = SUPPRESSION, damageType = COMBAT_HOLYDAMAGE, damage = true, time = 5000, name = "Suppression" },
		}
		if (origin == ORIGIN_SPELL or origin == ORIGIN_AUTOCAST) or origin == ORIGIN_MELEE or origin == ORIGIN_RANGED or origin == ORIGIN_WAND then
			-- aliments
			local extraChance = 0
			if attacker:hasBuff(DRUID_TRAIT) then
				extraChance = extraChance + 20
			end
			if colleftInfo[attacker:getId()].attributesItems[210] then -- all aliments chance
				extraChance = extraChance + colleftInfo[attacker:getId()].attributesItems[210].value
			end
			for id, data in pairs(ailment) do
				local attribute = colleftInfo[attacker:getId()].attributesItems[id]
				if data.any then
					if attribute and math.random(100) <= (attribute.value + extraChance) then
						if not creature:hasBuff(data.debuff) then
							creature:addBuff(data.debuff)
						end
					end
				end
				local canApplyDebuff = false
				if data.damageType and data.damageType == primaryType then
					canApplyDebuff = true
				end
				if canApplyDebuff then
					if math.random(100) <= ((attribute and attribute.value or 0) + extraChance) then
						if data.damage then
							creature:startDOT(attacker, data.debuff, 0, false, data.time)
						else
							creature:addBuff(data.debuff)
						end
						if data.debuff == CHILL then
							local sped = creature:getBaseSpeed() * 0.30 -- -30% speed
							local ChillingIT = Condition(CONDITION_PARALYZE)
							ChillingIT:setParameter(CONDITION_PARAM_TICKS, 5000)
							ChillingIT:setParameter(CONDITION_PARAM_SUBID, 777780)
							ChillingIT:setParameter(CONDITION_PARAM_SPEED, -sped)
							creature:addCondition(ChillingIT)
						end
					end
				end
			end

			-----------------------------------
		end
	end -- ???

	local TAKENprimaryDamageTotal = 0
	local lessDamageTaken = 0
	local takenFirst = 0
	local blockSuccess = false
	local dodgeSuccess = false
	local avoidSuccess = false
	---------------------------------------------------------------------- GRACZ OTRZYMUJE OBRAZENIA   																				BBB
	if creature:isPlayer() then
		local absorbDamageHeal = 0
		local dodge = 0
		local block = 0
		local reflect = 0
		local reflectDamageBonus = 0
		local avoid = 0
		local reflectSuccess = false
		if creature:hasBuff(EVANSION) then -- Unique Flash Boots
			dodge = dodge + creature:getBuff(EVANSION).stacks * 2
		end
		if creature:hasBuff(HARD_BLOCK) then -- special
			TAKENprimaryDamageTotal = TAKENprimaryDamageTotal + creature:getBuff(HARD_BLOCK).stacks
		end
		-- Items
		if colleftInfo[creature:getId()].attributesItems[13] then -- Physical Protection
			if primaryType == COMBAT_PHYSICALDAMAGE then
				TAKENprimaryDamageTotal = TAKENprimaryDamageTotal + colleftInfo[creature:getId()].attributesItems[13].value
			end
		end
		if colleftInfo[creature:getId()].attributesItems[14] then -- Elemental Protection
			if primaryType == COMBAT_FIREDAMAGE or primaryType == COMBAT_ICEDAMAGE or primaryType == COMBAT_ENERGYDAMAGE or primaryType == COMBAT_EARTHDAMAGE then
				TAKENprimaryDamageTotal = TAKENprimaryDamageTotal + colleftInfo[creature:getId()].attributesItems[14].value
			end
		end
		if colleftInfo[creature:getId()].attributesItems[197] then -- Duality Protection
			if primaryType == COMBAT_DEATHDAMAGE or primaryType == COMBAT_HOLYDAMAGE then
				TAKENprimaryDamageTotal = TAKENprimaryDamageTotal + colleftInfo[creature:getId()].attributesItems[197].value
			end
		end
		if colleftInfo[creature:getId()].attributesItems[9] then -- Dodge 9
			dodge = dodge + colleftInfo[creature:getId()].attributesItems[9].value
		end
		if colleftInfo[creature:getId()].attributesItems[35] then -- Spell Avoid 35
			avoid = avoid + colleftInfo[creature:getId()].attributesItems[35].value
		end
		if colleftInfo[creature:getId()].attributesItems[49] then -- Counterattack 49
			reflectDamageBonus = reflectDamageBonus + colleftInfo[creature:getId()].attributesItems[49].value
		end
		if colleftInfo[creature:getId()].attributesItems[231] then -- unique Reflected Attacks
			if creature:hasBuff(REFLECTED_ATTACKS) then
				reflectDamageBonus = reflectDamageBonus + (creature:getBuff(REFLECTED_ATTACKS).stacks * 2)
			end
		end
		if colleftInfo[creature:getId()].attributesItems[22] then -- Damage Reduction 22
			TAKENprimaryDamageTotal = TAKENprimaryDamageTotal + colleftInfo[creature:getId()].attributesItems[22].value
		end
		-- Skill Tree
		if colleftInfo[creature:getId()].attributesItems[160] then -- subklas Light Bringer
			if creature:getHealth() <= (creature:getMaxHealth() * US_ENCHANTMENTS[160].subvalue) then
				if not creature:hasCondition(CONDITION_SPELLCOOLDOWN, 5001) then
					creature:addCondition(secondWind)
					resourceRegen(creature, creature:getMaxHealth() * US_ENCHANTMENTS[160].subvalue2, 5, 11, "health")
					creature:addBuff(SECOND_WIND)
					Game.sendAnimatedText('Second Wind', creature:getPosition(), 129, "Reggae One-10px-bordered")
				end
			end
		end
		if colleftInfo[creature:getId()].attributesItems[190] then -- subklas Uncatchable Shadow
			if creature:getHealth() <= (creature:getMaxHealth() * US_ENCHANTMENTS[190].subvalue) then
				if not creature:hasCondition(CONDITION_SPELLCOOLDOWN, 5003) then
					creature:addCondition(shadowCD)
					creature:addBuff(SHADOW)
					Game.sendAnimatedText('Uncatchable Shadow', creature:getPosition(), 129, "Reggae One-10px-bordered")
				end
			end
		end
		if creature:hasBuff(STONE_HEART) then
			TAKENprimaryDamageTotal = TAKENprimaryDamageTotal + 50
		end
		--- Auras ---
		--- Trait
		if creature:hasBuff(PALADIN_TRAIT) then
			if primaryType == COMBAT_FIREDAMAGE or primaryType == COMBAT_ICEDAMAGE or primaryType == COMBAT_ENERGYDAMAGE or primaryType == COMBAT_EARTHDAMAGE then
				TAKENprimaryDamageTotal = TAKENprimaryDamageTotal + 20
			end
		end
		if creature:hasBuff(KNIGHT_TRAIT) then
			if primaryType == COMBAT_PHYSICALDAMAGE then
				TAKENprimaryDamageTotal = TAKENprimaryDamageTotal + 20
			end
		end

		if creature:isPlayer() and creature:getMagicLevel() then
			TAKENprimaryDamageTotal = TAKENprimaryDamageTotal + math.ceil(creature:getMagicLevel() / 10)
		end
		-- Character Stats
		if creature:getCharacterStat(CHARSTAT_LIFE) then
			armorDamageReduction = armorDamageReduction + (creature:getCharacterStat(CHARSTAT_LIFE) * 0.5)
		end
		if armorDamageReduction > 0 then
			TAKENprimaryDamageTotal = TAKENprimaryDamageTotal + armorDamageReduction
		end
		if creature:isPlayer() and creature:getStorageValue(PlayerStorage.sideBoss6) >= 1 then
			if primaryType == COMBAT_FIREDAMAGE or primaryType == COMBAT_ICEDAMAGE or primaryType == COMBAT_ENERGYDAMAGE or primaryType == COMBAT_EARTHDAMAGE then
				TAKENprimaryDamageTotal = TAKENprimaryDamageTotal + 10
			end
		end
		if creature:isPlayer() and creature:getStorageValue(PlayerStorage.sideBoss7) >= 1 then
			if primaryType == COMBAT_HOLYDAMAGE or primaryType == COMBAT_DEATHDAMAGE then
				TAKENprimaryDamageTotal = TAKENprimaryDamageTotal + 10
			end
		end
		if creature:isPlayer() and creature:getStorageValue(PlayerStorage.sideBoss8) >= 1 then
			if primaryType == COMBAT_PHYSICALDAMAGE then
				TAKENprimaryDamageTotal = TAKENprimaryDamageTotal + 10
			end
		end

		if creature:getStorageValue(PlayerStorage.reborn) >= 1 then
			TAKENprimaryDamageTotal = TAKENprimaryDamageTotal - (creature:getStorageValue(PlayerStorage.reborn) * 5)
		end
		if creature:getStorageValue(PlayerStorage.endGame) >= 1 then
			TAKENprimaryDamageTotal = TAKENprimaryDamageTotal - 10
		end
		-- Koniec podliczen
		local maxReduction = 70
		local maxCap = 0
		if primaryType == COMBAT_PHYSICALDAMAGE and colleftInfo[creature:getId()].attributesItems[232] then -- max physical protection
			maxCap = maxCap + colleftInfo[creature:getId()].attributesItems[232].value
		elseif primaryType == COMBAT_FIREDAMAGE or primaryType == COMBAT_ICEDAMAGE or primaryType == COMBAT_ENERGYDAMAGE or primaryType == COMBAT_EARTHDAMAGE then -- max elemental protection
			if colleftInfo[creature:getId()].attributesItems[233] then
				maxCap = maxCap + colleftInfo[creature:getId()].attributesItems[233].value
			end
		elseif primaryType == COMBAT_DEATHDAMAGE or primaryType == COMBAT_HOLYDAMAGE then -- max duality protection
			if colleftInfo[creature:getId()].attributesItems[234] then
				maxCap = maxCap + colleftInfo[creature:getId()].attributesItems[234].value
			end
		end
		if maxCap >= 20 then
			maxCap = 20
		end
		maxReduction = maxReduction + maxCap

		if TAKENprimaryDamageTotal >= maxReduction then
			TAKENprimaryDamageTotal = maxReduction
		end

		if TAKENprimaryDamageTotal > 0 then -- Damage Reduction
			primaryDamage = math.floor(primaryDamage - (primaryDamage * TAKENprimaryDamageTotal / 100))
			takenFirst = primaryDamage
		elseif TAKENprimaryDamageTotal < 0 then
			primaryDamage = math.floor(primaryDamage - (primaryDamage * TAKENprimaryDamageTotal / 100))
		end
		-- Less Damage Taken Migation
		if colleftInfo[creature:getId()].attributesItems[161] then -- subklas Unbroken
			lessDamageTaken = lessDamageTaken + US_ENCHANTMENTS[161].subvalue
		end
		if creature:isPlayer() and colleftInfo[creature:getId()].attributesItems[136] then -- Subklas Cold Skin
			if creature:getHealth() >= (creature:getMaxHealth() * US_ENCHANTMENTS[136].subvalue) then
				lessDamageTaken = lessDamageTaken + US_ENCHANTMENTS[136].subvalue2
			end
			if creature:getHealth() <= (creature:getMaxHealth() * US_ENCHANTMENTS[136].subvalue4) then
				if math.random(100) <= 25 then
					creature:addMana(US_ENCHANTMENTS[136].subvalue3)
					if attacker:isMonster() then
						local sped = attacker:getBaseSpeed() * 0.30 -- -30%
						local chill = Condition(CONDITION_PARALYZE)
						chill:setParameter(CONDITION_PARAM_TICKS, 2000)
						chill:setParameter(CONDITION_PARAM_SPEED, -sped)
						chill:setParameter(CONDITION_PARAM_SUBID, 777781)
						attacker:addCondition(chill)
						Game.sendAnimatedText('CHILL', attacker:getPosition(), 129, "Reggae One-10px-bordered")
					end
				end
			end
		end
		if colleftInfo[creature:getId()].attributesItems[185] then -- subklas Inflexibility
			if creature:getHealth() >= (creature:getMaxHealth() * US_ENCHANTMENTS[185].subvalue) then
				lessDamageTaken = lessDamageTaken + US_ENCHANTMENTS[185].subvalue2
			end
		end
		if creature:hasBuff(FLEETFOOT) then -- subklas Fleetfoot
			lessDamageTaken = lessDamageTaken + US_ENCHANTMENTS[172].subvalue2
		end
		if colleftInfo[creature:getId()].attributesItems[225] then -- unique North Protection
			if creature:hasBuff(CHILL) then
				lessDamageTaken = lessDamageTaken + US_ENCHANTMENTS[225].subvalue
			end
		end

		--- Auras ---
		if primaryType == COMBAT_PHYSICALDAMAGE then
			if colleftInfo[creature:getId()].attributesItems[237] then -- Physical Mitigation
				lessDamageTaken = lessDamageTaken + colleftInfo[creature:getId()].attributesItems[237].value
			end
			if creature:hasBuff(AURA_PHYSICAL_PROTECTION) then
				lessDamageTaken = lessDamageTaken + (15 + (creature:getBuff(AURA_PHYSICAL_PROTECTION).stacks * 0.1))
			end
		end
		if primaryType == COMBAT_FIREDAMAGE or primaryType == COMBAT_ICEDAMAGE or primaryType == COMBAT_ENERGYDAMAGE or primaryType == COMBAT_EARTHDAMAGE then
			if creature:isPlayer() and colleftInfo[creature:getId()].attributesItems[131] then -- Subklas Fire Barrier
				lessDamageTaken = lessDamageTaken + US_ENCHANTMENTS[131].subvalue
			end
			if colleftInfo[creature:getId()].attributesItems[238] then -- Elemental Mitigation
				lessDamageTaken = lessDamageTaken + colleftInfo[creature:getId()].attributesItems[238].value
			end
			if creature:hasBuff(AURA_ELEMENTAL_PROTECTION) then
				lessDamageTaken = lessDamageTaken + (15 + (creature:getBuff(AURA_ELEMENTAL_PROTECTION).stacks * 0.1))
			end
		end
		if primaryType == COMBAT_HOLYDAMAGE or primaryType == COMBAT_DEATHDAMAGE then
			if colleftInfo[creature:getId()].attributesItems[239] then -- Duality Mitigation
				lessDamageTaken = lessDamageTaken + colleftInfo[creature:getId()].attributesItems[239].value
			end
			if creature:hasBuff(AURA_BLESSED) then
				lessDamageTaken = lessDamageTaken + (15 + (creature:getBuff(AURA_BLESSED).stacks * 0.1))
			end
		end
		if lessDamageTaken > 0 then -- Less Damage Taken
			if lessDamageTaken >= 75 then
				lessDamageTaken = 75
			end
			primaryDamage = math.floor(primaryDamage - (primaryDamage * lessDamageTaken / 100))
		end

		local damage = (primaryDamage)
		if damage < 0 then
			damage = damage * -1
		end
		------------------ KONCOWE OTRZYMANIE OBRAZEN
		if colleftInfo[creature:getId()].attributesItems[9] then -- Dodge
			dodge = dodge + colleftInfo[creature:getId()].attributesItems[9].value
		end
		if creature:getEffectiveSkillLevel(SKILL_DISTANCE) then -- Dexterity
			dodge = dodge + (creature:getEffectiveSkillLevel(SKILL_DISTANCE) / 10)
		end
		if creature:hasBuff(LAST_BREATH) then
			dodge = dodge + 10
			avoid = avoid + 10
		end
		if creature:hasBuff(SHADOW_TRAIT) then
			avoid = avoid + ( 2 + (creature:getBuff(SHADOW_TRAIT).stacks * 2))
		end
		if colleftInfo[creature:getId()].attributesItems[35] then -- Spell Avoid
			avoid = avoid + colleftInfo[creature:getId()].attributesItems[35].value
		end
		if colleftInfo[creature:getId()].attributesItems[204] then -- Spell Dodge
			local unique = math.floor(dodge / 3)
			avoid = avoid + unique
		end
		if (origin == ORIGIN_SPELL or origin == ORIGIN_AUTOCAST) or origin == ORIGIN_DOT then
			if avoid >= 75 then avoid = 75 end
			if avoid > 0 and math.random(100) <= avoid then avoidSuccess = true end
			if avoidSuccess then
				primaryDamage = 0
				creature:getPosition():sendMagicEffect(115)
				if creature and creature:getStorageValue(PlayerStorage.animatedTalentSkills) == -1 then
					creature:getPosition():sendMagicEffect(298)
				else
					Game.sendAnimatedText('Avoid', creature:getPosition(), 129, "Reggae One-10px-bordered")
				end
				if colleftInfo[creature:getId()].attributesItems[179] then -- subklas Elusive Recovery
					creature:addHealth(creature:getMaxHealth() * US_ENCHANTMENTS[179].subvalue)
					creature:addEnergyShield(creature:getMaxEnergyShield() * US_ENCHANTMENTS[179].subvalue)
				end
			end
		end
		reflect = reflectDamageBonus
		local counterMultiplier = 0
		if reflect > 0 then reflectSuccess = true end
		local damage_taken = 1
		local baseDamge = totalAttackPower(creature, primaryType)
		if colleftInfo[creature:getId()].isShield then
			baseDamge = totalAttackPower(creature, primaryType, nil, false, true)
		end
		--[[
		if attacker:isMonster() then
			local monsterLevel = 1
			if attacker:getMonsterLevel() then
				monsterLevel = attacker:getMonsterLevel() / 2
			end
			damage_taken = damageFormula(monsterLevel)
		elseif attacker:isPlayer() then
			damage_taken = primaryDamage
		end
		--]]
		if colleftInfo[creature:getId()].attributesItems[208] then -- Bastion Each Strenght increase 4% Counterattack.
			reflectDamageBonus = reflectDamageBonus + (creature:getEffectiveSkillLevel(SKILL_MELEE) * US_ENCHANTMENTS[208].subvalue) -- (math.min(creature:getEffectiveSkillLevel(SKILL_MELEE) * US_ENCHANTMENTS[208].subvalue, 500)) -- creature:getTotalPrecentHealthGain() ((creature:getEffectiveSkillLevel(SKILL_MELEE) + creature:getEffectiveSkillLevel(SKILL_SHIELD)) * 2)
		end
		if colleftInfo[creature:getId()].attributesItems[258] then --         name = "Demon Imbue", Each Intelligence increase 4% Counterattack.
			reflectDamageBonus = reflectDamageBonus + (creature:getEffectiveSkillLevel(SKILL_FISHING) * US_ENCHANTMENTS[258].subvalue) -- (math.min(creature:getEffectiveSkillLevel(SKILL_MELEE) * US_ENCHANTMENTS[208].subvalue, 500)) -- creature:getTotalPrecentHealthGain() ((creature:getEffectiveSkillLevel(SKILL_MELEE) + creature:getEffectiveSkillLevel(SKILL_SHIELD)) * 2)
		end
		if colleftInfo[creature:getId()].attributesItems[231] then -- unique Reflected Attacks Receiving damage grants you stacks that increase basic damage by 1% and Counterattack by 2% per stack. Maximum stacks 500.
			creature:addBuff(REFLECTED_ATTACKS)
		end
		 if creature:hasBuff(AURA_HEDGEHOG) then -- Thornmail Aura
			counterMultiplier = counterMultiplier + (300 + creature:getBuff(AURA_HEDGEHOG).stacks * 15) -- x5
		--	reflectDamageBonus = reflectDamageBonus * (3.0 + (((creature:getBuff(AURA_HEDGEHOG).stacks * 5)) / 3))
		 end
		 if reflectDamageBonus > 0 then
			reflectDamageBonus = reflectDamageBonus * (1 +  (counterMultiplier / 100))
		 end
		damage_taken = (baseDamge * (1 + (reflectDamageBonus / 100)))
		if creature and creature:getStorageValue(PlayerStorage.damageTakenInfo) == 1 and reflectDamageBonus > 0 then
			creature:sendChannelMessage("","Counterattack: Base: "..shortNumbers(baseDamge,2).." * Bonus +"..shortNumbers(reflectDamageBonus,2).."% you deal " .. shortNumbers(damage_taken, 2) .. " ", TALKTYPE_CHANNEL_Y,18)
		end
		if colleftInfo[creature:getId()].attributesItems[8] then
			block = block + colleftInfo[creature:getId()].attributesItems[8].value
		end
		if colleftInfo[creature:getId()].attributesItems[159] and colleftInfo[creature:getId()].isTwoHanded then -- subklas Heaven's Fury
			block = block + US_ENCHANTMENTS[159].subvalue
		end
		local maxBlock = 75
		local maxMaxBlock = 0
		if colleftInfo[creature:getId()].attributesItems[236] then -- Max Block Chance
			maxBlock = maxBlock + colleftInfo[creature:getId()].attributesItems[236].value
			maxMaxBlock = colleftInfo[creature:getId()].attributesItems[236].value
		end
		if block >= maxBlock then
			if maxMaxBlock >= 15 then
				maxMaxBlock = 15
			end
			block = maxBlock
		end
		if block > 0 and math.random(100) <= block then blockSuccess = true end
		-- if origin == ORIGIN_MELEE or origin == ORIGIN_RANGED or origin == ORIGIN_WAND then
		if primaryType == COMBAT_PHYSICALDAMAGE then
			if dodge >= 75 then dodge = 75 end
			if dodge > 0 and math.random(100) <= dodge then dodgeSuccess = true end
			if dodgeSuccess then
				primaryDamage = 0
				if creature and creature:getStorageValue(PlayerStorage.animatedTalentSkills) == -1 then
					creature:getPosition():sendMagicEffect(288)
				else
					Game.sendAnimatedText('Dodge', creature:getPosition(), 129, "Reggae One-10px-bordered")
				end
				if colleftInfo[creature:getId()].attributesItems[179] then -- subklas Elusive Recovery
					creature:addHealth(creature:getMaxHealth() * US_ENCHANTMENTS[179].subvalue)
					creature:addEnergyShield(creature:getMaxEnergyShield() * US_ENCHANTMENTS[179].subvalue)
				end
			end
			-- end melee distance
		end
		if blockSuccess and not dodgeSuccess and not avoidSuccess then
			if creature and creature:getStorageValue(PlayerStorage.animatedTalentSkills) == -1 then
				creature:getPosition():sendMagicEffect(287)
			else
				Game.sendAnimatedText('Block', creature:getPosition(), 129, "Reggae One-10px-bordered")
			end
			if colleftInfo[creature:getId()].attributesItems[166] then -- subklas Holy Aegis
				attacker:addBuff(DISARMAMENT)
			end
			if colleftInfo[creature:getId()].attributesItems[167] then -- subklas Titan Vitality
				creature:addHealth(creature:getMaxHealth() * US_ENCHANTMENTS[167].subvalue2)
			end
			if colleftInfo[creature:getId()].attributesItems[87] then -- Hard Block
				creature:addBuff(HARD_BLOCK)
			end
			primaryDamage = primaryDamage / 2
		end
	--	if not dodgeSuccess or not avoidSuccess then
			if reflectSuccess then -- and not dodge or not avoid
				if origin ~= ORIGIN_CAST then
					if origin ~= ORIGIN_DOT then
						local counterType = COMBAT_PHYSICALDAMAGE
						local counterMultipler = 1
					--	if blockSuccess then damage_taken = damage_taken * 3 end
						if creature:hasBuff(COUNTER_WEAKNESS_PLAYER) then -- COUNTER_WEAKNESS
							attacker:addBuff(COUNTER_WEAKNESS)
							attacker:setBuffStacks(COUNTER_WEAKNESS, creature:getBuff(COUNTER_WEAKNESS_PLAYER).stacks)
						end
						if attacker:hasBuff(COUNTER_WEAKNESS) then
							damage_taken = damage_taken + (damage_taken * attacker:getBuff(COUNTER_WEAKNESS).stacks / 100)
						end
						if attacker:hasBuff(COUNTER_WEAKNESS_SPELL) then
							damage_taken = damage_taken + (damage_taken * 1)
						end
						if colleftInfo[creature:getId()].attributesItems[258] then -- unique Demon Shield
							counterType = COMBAT_FIREDAMAGE
						end
						doTargetCombatHealth(creature, attacker:getId(), counterType, damage_taken, damage_taken, CONST_ME_NONE, ORIGIN_AUTOCAST)
						creature:getPosition():sendDistanceEffect(attacker:getPosition(), 41)
						attacker:getPosition():sendMagicEffect(4)
					end
				end
			end
	--	end
		if not dodgeSuccess or not avoidSuccess then
			if origin ~= ORIGIN_DOT then
				if colleftInfo[creature:getId()].attributesItems[86] then -- Skin Laceration
					attacker:startDOT(creature, BLEED_ITEM, 0, false, 5000)
				end
				if colleftInfo[creature:getId()].attributesItems[92] then -- Absorb Energy
					if math.random(100) <= colleftInfo[creature:getId()].attributesItems[92].value then
						local absorb_value = math.ceil(creature:getMaxMana() / 10)
						if primaryDamage > 0 then
							primaryDamage = primaryDamage - ((primaryDamage * absorb_value) / 100)
						else
							primaryDamage = primaryDamage + ((primaryDamage * absorb_value) / 100)
						end
					end
				end
				if colleftInfo[creature:getId()].attributesItems[88] then -- Demon Flame
					if math.random(100) <= colleftInfo[creature:getId()].attributesItems[88].value then
						local damageStrike = math.floor(originalDamage / 2)
						if doTargetCombatHealth(creature:getId(), attacker:getId(), US_ENCHANTMENTS[88].combatDamage, -damageStrike, -damageStrike, US_ENCHANTMENTS[88].effect, ORIGIN_CONDITION, 1000, 21) then
							creature:getPosition():sendDistanceEffect(attacker:getPosition(), US_ENCHANTMENTS[88].distance)
							attacker:getPosition():sendMagicEffect(US_ENCHANTMENTS[88].effect)
						end
					end
				end
				if absorbDamageHeal > 0 and not dodgeSuccess or not avoidSuccess then
					creature:addHealth(absorbDamageHeal, true)
				end
			end
		end
	end
	-- KONIEC OTRZYMANE
	-- 																													Total Damage Reduction				CCC $$ -- Overpower Damage Reduction
	if creature:isPlayer() then
		if creature and creature:getStorageValue(PlayerStorage.damageTakenInfo) == 1 and creature:isPlayer() then
			local originIs = "Basic Damage"
			if creature:openChannel(18) then
				if origin == ORIGIN_RANGED or origin == ORIGIN_MELEE or origin == ORIGIN_WAND and not dodgeSuccess then
				elseif (origin == ORIGIN_SPELL or origin == ORIGIN_AUTOCAST) and not avoidSuccess then
					originIs = "Spell Damage"
				elseif origin == ORIGIN_DOT and not avoidSuccess then
					originIs = "DoT Damage"
				end
				local aTxt = ""
				local crittxt = ""
				local unik = false
				if eliteCrit then
					crittxt = "CRITICAL"
				end
				if dodgeSuccess then
					aTxt = "[Dodge]"
					unik = true
				elseif blockSuccess then
					aTxt = "[Block]"
				end
				if avoidSuccess then
					aTxt = "[Spell Avoid]"
					unik = true
				end
				if unik then
					creature:sendChannelMessage("",string.format("[%s]", aTxt), TALKTYPE_CHANNEL_Y, 18)
				else
					creature:sendChannelMessage("",string.format("[%s] [%s] Damage Taken: [%d][%d] Reduction: %d%% (Armor Reduction: %d%%) = [%d] Less Damage Taken: %s%% = [%d] %s %s", originIs, element_names[primaryType], mobDmg, decreasedDamage, TAKENprimaryDamageTotal, armorDamageReduction, takenFirst, lessDamageTaken, primaryDamage, aTxt, crittxt), TALKTYPE_CHANNEL_Y, 18)
				end
			end
		end
	end

	return primaryDamage, primaryType, secondaryDamage, secondaryType, origin, critical, spellUID, critChance, distance
end

-- , 1000, 21          ostatni
-- , 1000, 65 aor ostatni
-- 67 ostatni