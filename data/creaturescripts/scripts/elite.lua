local CLEAVE_SPLASH = {
	[DIRECTION_SOUTH] = {  -- NORTH
		area = {
			{ 0, 0, 0 },
			{ 1, 2, 1 },
			{ 1, 1, 1 },
			{ 1, 1, 1 }
		},
		effect = 660,
		offset = {x = 2, y = 2},
	},
	[DIRECTION_EAST] = {   -- WEST
		area = {
			{ 0, 1, 1, 1 },
			{ 0, 2, 1, 1 },
			{ 0, 1, 1, 1 }
		},
		effect = 662,
		offset = {x = 2, y = 2},
	},
	[DIRECTION_NORTH] = {   -- SOUTH
		area = {
			{ 1, 1, 1 },
			{ 1, 1, 1 },
			{ 1, 2, 1 },
			{ 0, 0, 0 }
		},
		effect = 661,
		offset = {x = 2, y = 2},
	},
	[DIRECTION_WEST] = {	--  EAST
		area = {
			{ 1, 1, 1, 0 },
			{ 1, 1, 2, 0 },
			{ 1, 1, 1, 0 }
		},
		effect = 659,
		offset = {x = 2, y = 2},
	},
	[DIRECTION_NORTHEAST] = { --  SOUTHWEST
		area = {
			{ 0, 1, 1, 1 },
			{ 1, 1, 1, 1 },
			{ 0, 2, 1, 1 },
			{ 0, 0, 1, 0 }
		},
		effect = 657,
		offset = {x = 1, y = 3},
	},
	[DIRECTION_SOUTHEAST] = { -- NORTHWEST
		area = {
			{ 0, 0, 1, 0 },
			{ 0, 2, 1, 1 },
			{ 1, 1, 1, 1 },
			{ 0, 1, 1, 1 }
		},
		effect = 658,
		offset = {x = 1, y = 1},
	},
	[DIRECTION_SOUTHWEST] = { --  NORTHEAST
		area = {
			{ 0, 1, 0, 0 },
			{ 1, 1, 2, 0 },
			{ 1, 1, 1, 1 },
			{ 1, 1, 1, 0 }
		},
		effect = 655,
		offset = {x = 3, y = 1},
	},
	[DIRECTION_NORTHWEST] = {  --  SOUTHEAST
		area = {
			{ 1, 1, 1, 0 },
			{ 1, 1, 1, 1 },
			{ 1, 1, 2, 0 },
			{ 0, 1, 0, 0 }
		},
		effect = 656,
		offset = {x = 3, y = 3},
	}
}



local function isBadTile(tile)
	return (tile == nil or tile:getGround() == nil or tile:hasProperty(TILESTATE_NONE) or tile:hasProperty(TILESTATE_FLOORCHANGE_EAST) or
		isItem(tile:getThing()) and not isMoveable(tile:getThing()) or
		-- tile:getTopCreature() or
		tile:hasFlag(TILESTATE_PROTECTIONZONE))
end

function onHealthChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin, critical, spellUID, critChance, distance)
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
	return affix_onDamaged(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin, critical, spellUID, critChance, distance)
end

function onManaChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin, critical, spellUID, critChance, distance)
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

	return affix_onDamaged(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin, critical, spellUID, critChance, distance)
end

function affix_onDamaged(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin, critical, spellUID, critChance, distance)
	local procDamage = 0
	local procName = ""
	local procType = false
	local multiFix = false
	local dualWilding = false
	local physicalPenetration = 0
	local elementalPenetration = 0
	local dualityPenetration = 0
	local multishot = false
	local multishotDamage = 0
	local cleave = false
	local beforeCrit = 0
	local focusedStrike = false
	if attacker:isPlayer() then -- gracz atakuje moba
		if colleftInfo[attacker:getId()].isDualWielding then
			dualWilding = true
		end
		local critDamage = attacker:getSpecialSkill(SPECIALSKILL_CRITICALHITAMOUNT)
		if not creature then return primaryDamage, primaryType, secondaryDamage, secondaryType end
		if not creature:isMonster() then return primaryDamage, primaryType, secondaryDamage, secondaryType end
		local skull = creature:getSkull()
		local damageReduction = 0
		local originalDamage = primaryDamage
		if attacker:getStorageValue(435024) == 10 then -- Archer + Knight Siegebreaker
			attacker:addBuff(QUICK_STAB)
			if attacker:getBuff(QUICK_STAB) then
				physicalPenetration = physicalPenetration + (attacker:getBuff(QUICK_STAB).stacks * FUSION_SCALING[10].bonus)
			end
		end
		if colleftInfo[attacker:getId()] then
			if colleftInfo[attacker:getId()].attributesItems[31] then -- Physical Penetration Damage 31
				physicalPenetration = physicalPenetration + colleftInfo[attacker:getId()].attributesItems[31].value
			end
			if colleftInfo[attacker:getId()].attributesItems[122] then -- Elemental Penetration Damage 31
				elementalPenetration = elementalPenetration + colleftInfo[attacker:getId()].attributesItems[122].value
			end
			if colleftInfo[attacker:getId()].attributesItems[198] then -- Duality Penetration Damage 198
				dualityPenetration = dualityPenetration + colleftInfo[attacker:getId()].attributesItems[198].value
			end
		end
		-- Dungeon Modifier
		if creature:getStorageValue(PlayerStorage.monsterModifier_physicalProtection) > 0 then
			if primaryType == COMBAT_PHYSICALDAMAGE then
				damageReduction = damageReduction + creature:getStorageValue(PlayerStorage.monsterModifier_physicalProtection)
			end
		end
		if creature:getStorageValue(PlayerStorage.monsterModifier_elementalProtection) > 0 then
			if primaryType == COMBAT_FIREDAMAGE or primaryType == COMBAT_ICEDAMAGE or primaryType == COMBAT_ENERGYDAMAGE or primaryType == COMBAT_EARTHDAMAGE then
				damageReduction = damageReduction + creature:getStorageValue(PlayerStorage.monsterModifier_elementalProtection)
			end
		end
		if creature:getStorageValue(PlayerStorage.monsterModifier_dualityProtection) > 0 then
			if primaryType == COMBAT_DEATHDAMAGE or primaryType == COMBAT_HOLYDAMAGE then
				damageReduction = damageReduction + creature:getStorageValue(PlayerStorage.monsterModifier_dualityProtection)
			end
		end

		if creature:getStorageValue(PlayerStorage.monsterModifier_dodge) > 0 then
			if math.random(100) <= creature:getStorageValue(PlayerStorage.monsterModifier_dodge) then
				if origin == ORIGIN_RANGED or origin == ORIGIN_MELEE or origin == ORIGIN_WAND then
					primaryDamage = 0
					Game.sendAnimatedText('DODGE', creature:getPosition(), 129)
					creature:getPosition():sendMagicEffect(3)
				end
			end
		end
		if creature:getStorageValue(PlayerStorage.monsterModifier_spell_avoid) > 0 then
			if math.random(100) <= creature:getStorageValue(PlayerStorage.monsterModifier_spell_avoid) then
				if origin == ORIGIN_SPELL or origin == ORIGIN_AUTOCAST then
					primaryDamage = 0
					Game.sendAnimatedText('AVOID', creature:getPosition(), 129)
					creature:getPosition():sendMagicEffect(3)
				end
			end
		end
--		if not BOSSESS_DAMAGE[creature:getName()] then
		--------------------
		---
			if skull >= 7 then -- Increase DAMAGE REDUCED ALL elite
				damageReduction = damageReduction + 20
			end
			if skull == 7 then -- REDUCED DAMAGE
				if primaryType == COMBAT_PHYSICALDAMAGE then
					damageReduction = damageReduction + 25
				end
			elseif skull == 27 or creature:getType():items() == "dungeonboss" or creature:getType():items() == "uberboss" then -- veterna
				damageReduction = damageReduction + 30
			elseif skull == 8 then -- REFLECT DAMAGE shaper -- OFF
			elseif skull == 19 then -- duality prot
				if primaryType == COMBAT_DEATHDAMAGE or primaryType == COMBAT_HOLYDAMAGE then
					damageReduction = damageReduction + 25
				end
			elseif skull == 20 then -- dodger 50% na dodge
				if math.random(100) <= 50 then
					primaryDamage = 0
					Game.sendAnimatedText('DODGE', creature:getPosition(), 129)
					creature:getPosition():sendMagicEffect(3)
				end
			elseif skull == 21 then -- anti magic
				if primaryType == COMBAT_FIREDAMAGE or primaryType == COMBAT_EARTHDAMAGE or primaryType == COMBAT_ENERGYDAMAGE or primaryType == COMBAT_ICEDAMAGE  then
					damageReduction = damageReduction + 25
				end
			end
			-- Odpornosc Moba
			local monsterLevel = creature:getMonsterLevel()
			local baseMonsterProt = 0
			if monsterLevel then
				baseMonsterProt = math.ceil(monsterLevel / 2)
				if baseMonsterProt >= 80 then
					baseMonsterProt = 80
				end
			end
			damageReduction = damageReduction + baseMonsterProt
			if attacker:getStorageValue(PlayerStorage.endGame) >= 1 then
				damageReduction = damageReduction - 15
			end
			-- Paths
			if attacker:hasBuff(PYRO_PATH) and creature:hasBuff(IGNITE_ITEM) then
				if primaryType == COMBAT_FIREDAMAGE then
					damageReduction = damageReduction - 15
				end
			end
			if attacker:hasBuff(BLOODY_PATH) and creature:hasBuff(BLEED_ITEM) then
				if primaryType == COMBAT_PHYSICALDAMAGE then
					if creature:getHealth() < creature:getMaxHealth() * 0.5 then
						damageReduction = damageReduction - 25
					end
				end
			end
			-- Talents
			if colleftInfo[attacker:getId()].attributesItems[159] and colleftInfo[attacker:getId()].isTwoHanded then -- Subklas Heaven's Fury
				damageReduction = damageReduction - US_ENCHANTMENTS[159].subvalue2
			end
			if colleftInfo[attacker:getId()].attributesItems[153] then -- talent Grace
				if primaryType == COMBAT_DEATHDAMAGE or primaryType == COMBAT_HOLYDAMAGE then
					damageReduction = damageReduction - US_ENCHANTMENTS[153].subvalue
				end
			end
			if colleftInfo[attacker:getId()].attributesItems[152] then -- Subklas Sacred Impact
				damageReduction = damageReduction - US_ENCHANTMENTS[152].subvalue2
			end
			if colleftInfo[attacker:getId()].attributesItems[170] then -- Arcane Insight
				if primaryType == COMBAT_ICEDAMAGE or primaryType == COMBAT_FIREDAMAGE or primaryType == COMBAT_EARTHDAMAGE or primaryType == COMBAT_ENERGYDAMAGE then
					damageReduction = damageReduction - US_ENCHANTMENTS[170].subvalue
				end
			end
			if colleftInfo[attacker:getId()].attributesItems[164] then -- Subklas Mighty Hands
				if primaryType == COMBAT_PHYSICALDAMAGE then
					damageReduction = damageReduction - US_ENCHANTMENTS[164].subvalue
				end
			end
			if attacker:hasBuff(SHATTERSTORM) then
				damageReduction = damageReduction - (attacker:getBuff(SHATTERSTORM).stacks * 3)
			end
			if colleftInfo[attacker:getId()].attributesItems[146] then -- subklas Ruinous Tremous
				damageReduction = damageReduction - US_ENCHANTMENTS[146].subvalue
				local hpLower = (creature:getMaxHealth() * US_ENCHANTMENTS[146].subvalue3)
				if creature:getHealth() <= hpLower then
					damageReduction = damageReduction - US_ENCHANTMENTS[146].subvalue2
				end
			end
			if colleftInfo[attacker:getId()].attributesItems[127] then -- Subklas Overcharged Energy
				damageReduction = damageReduction - US_ENCHANTMENTS[127].subvalue2
			end
			if colleftInfo[attacker:getId()].attributesItems[132] then -- Subklas Bloodfire
				damageReduction = damageReduction - US_ENCHANTMENTS[132].subvalue2
			end
			if colleftInfo[attacker:getId()].attributesItems[195] then -- subklas Suffering Power
				damageReduction = damageReduction - US_ENCHANTMENTS[195].subvalue
			end
			if origin == ORIGIN_SPELL or origin == ORIGIN_AUTOCAST then -- Only Spells
				if colleftInfo[attacker:getId()].attributesItems[181] then -- subklas Overcharged Arc
					damageReduction = damageReduction - US_ENCHANTMENTS[181].subvalue
				end
			end

			if attacker:getStorageValue(435024) == 4 then -- Sorcerer + Paladin Inquisitor
				damageReduction = damageReduction - FUSION_SCALING[4].bonus
				if creature:getHealth() < (creature:getMaxHealth() * FUSION_SCALING[4].hp) then
					damageReduction = damageReduction - FUSION_SCALING[4].bonus
				end
			end
			if creature:hasBuff(EARTH_WEAKNESS) then
				if primaryType == COMBAT_EARTHDAMAGE then
					damageReduction = damageReduction - 20
				end
			end
			if creature:hasBuff(EARTH_WEAKNESS_SPELL) then
				if primaryType == COMBAT_EARTHDAMAGE then
					damageReduction = damageReduction - 20
				end
			end
			if creature:hasBuff(FROSTBITE_WEAKNESS) then
				if primaryType == COMBAT_ICEDAMAGE then
					damageReduction = damageReduction - 20
				end
			end
			if creature:hasBuff(FIRE_WEAKNESS) then
				if primaryType == COMBAT_FIREDAMAGE then
					damageReduction = damageReduction - 20
				end
			end
			if creature:hasBuff(DEATH_WEAKNESS) then
				if primaryType == COMBAT_DEATHDAMAGE then
					damageReduction = damageReduction - 20
				end
			end
			if creature:hasBuff(WEAKNESS_ARROW) then
				damageReduction = damageReduction - 25
			end
			if creature:hasBuff(SHOCK) then
				if primaryType == COMBAT_ENERGYDAMAGE then
					damageReduction = damageReduction - 20
				end
			end
			if colleftInfo[attacker:getId()] then
				if creature:hasBuff(HOLY_WEAKNESS) and primaryType == COMBAT_HOLYDAMAGE then -- unique Holy Imbue
					damageReduction = damageReduction - US_ENCHANTMENTS[287].subvalue
				end
				if colleftInfo[attacker:getId()].attributesItems[175] then -- subklas Multishot Enhancment
					damageReduction = damageReduction - US_ENCHANTMENTS[175].subvalue3
				end
				if colleftInfo[attacker:getId()].attributesItems[139] and creature:getBuff(CHILL) then -- Subklas Permafrost Surge
					damageReduction = damageReduction - US_ENCHANTMENTS[139].subvalue
				end
				if colleftInfo[attacker:getId()].attributesItems[186] then -- subklas Deadly Precision
					if critical then
						damageReduction = damageReduction - US_ENCHANTMENTS[186].subvalue2
					end
				end
				if colleftInfo[attacker:getId()].attributesItems[261] then -- unique Raven Peck
					if primaryType == COMBAT_FIREDAMAGE or primaryType == COMBAT_ENERGYDAMAGE or primaryType == COMBAT_ICEDAMAGE or primaryType == COMBAT_EARTHDAMAGE then
						damageReduction = damageReduction - math.min(math.floor(highestStat(attacker) * US_ENCHANTMENTS[261].subvalue), US_ENCHANTMENTS[261].subvalue2)
					end
				end
				if colleftInfo[attacker:getId()].attributesItems[263] then -- unique Bloody Pact
					if primaryType == COMBAT_PHYSICALDAMAGE then
						damageReduction = damageReduction - math.min(math.floor(highestStat(attacker) * US_ENCHANTMENTS[263].subvalue), US_ENCHANTMENTS[263].subvalue2)
					end
				end
				if colleftInfo[attacker:getId()].attributesItems[260] then -- unique Soul Piercing
					if primaryType == COMBAT_DEATHDAMAGE or primaryType == COMBAT_HOLYDAMAGE then
						damageReduction = damageReduction - math.min(math.floor(highestStat(attacker) * US_ENCHANTMENTS[260].subvalue), US_ENCHANTMENTS[260].subvalue2)
					end
				end
				if colleftInfo[attacker:getId()].attributesItems[277] then -- unique Spark Speed
					local movementSpeedPercent = (((200 - attacker:getSpeed()) / 200) * 100) * -1
					damageReduction = damageReduction - math.min((movementSpeedPercent * US_ENCHANTMENTS[277].subvalue), US_ENCHANTMENTS[277].subvalue2)
				end
				if colleftInfo[attacker:getId()].attributesItems[278] then -- unique Ruby Speed
					damageReduction = damageReduction - math.min((attacker:getVarStats(STAT_ATTACKSPEED) * US_ENCHANTMENTS[278].subvalue), US_ENCHANTMENTS[278].subvalue2)
				end
				if colleftInfo[attacker:getId()].attributesItems[279] then -- unique Blow Strike
					damageReduction = damageReduction - math.min((attacker:getSpecialSkill(SPECIALSKILL_CRITICALHITCHANCE) * US_ENCHANTMENTS[279].subvalue), US_ENCHANTMENTS[279].subvalue2)
				end
				if colleftInfo[attacker:getId()].attributesItems[280] then -- unique Toxic Synergy
					if colleftInfo[attacker:getId()].totalailmentChances then
						damageReduction = damageReduction - math.min((colleftInfo[attacker:getId()].totalailmentChances * US_ENCHANTMENTS[280].subvalue), US_ENCHANTMENTS[280].subvalue2)
					end
				end
			end
			if creature:hasBuff(SUPPORT_PHYSICAL_REDUCTION) then
				if primaryType == COMBAT_PHYSICALDAMAGE then
					damageReduction = damageReduction - creature:getBuff(SUPPORT_PHYSICAL_REDUCTION).stacks
				end
			end
			if creature:hasBuff(SUPPORT_ELEMENTAL_REDUCTION) then
				if primaryType == COMBAT_FIREDAMAGE or primaryType == COMBAT_ICEDAMAGE or primaryType == COMBAT_ENERGYDAMAGE or primaryType == COMBAT_EARTHDAMAGE then
					damageReduction = damageReduction - creature:getBuff(SUPPORT_ELEMENTAL_REDUCTION).stacks
				end
			end
			if creature:hasBuff(SUPPORT_DUALITY_REDUCTION) then
				if primaryType == COMBAT_HOLYDAMAGE or primaryType == COMBAT_DEATHDAMAGE then
					damageReduction = damageReduction - creature:getBuff(SUPPORT_DUALITY_REDUCTION).stacks
				end
			end
			if colleftInfo[attacker:getId()].attributesItems[291] then -- All Penetration
				damageReduction = damageReduction - colleftInfo[attacker:getId()].attributesItems[291].value
			end
			if physicalPenetration > 0 then
				if primaryType == COMBAT_PHYSICALDAMAGE then
					if attacker:isPlayer() and creature:isMonster() then
						damageReduction = damageReduction - physicalPenetration
					end
				end
			end
			if elementalPenetration > 0 then
				if ELEMENTAL_TYPES[primaryType] then
					if attacker:isPlayer() and creature:isMonster() then
						damageReduction = damageReduction - elementalPenetration
					end
				end
			end
			if dualityPenetration > 0 then
				if primaryType == COMBAT_DEATHDAMAGE or primaryType == COMBAT_HOLYDAMAGE then
					if attacker:isPlayer() and creature:isMonster() then
						damageReduction = damageReduction - dualityPenetration
					end
				end
			end
			if origin == ORIGIN_MELEE or origin == ORIGIN_RANGED or origin == ORIGIN_WAND then
				if creature:hasBuff(BASIC_WEAKNESS) then
					damageReduction = damageReduction - creature:getBuff(BASIC_WEAKNESS).stacks
				end
			end
			if attacker:getStorageValue(435024) == 15 then -- Paladin + Shadow Abyssal Cleric
				damageReduction = damageReduction - FUSION_SCALING[15].bonus
			end
			if primaryDamage < 0 then
				if damageReduction >= 100 then
					damageReduction = 100
				end
				primaryDamage = math.floor(primaryDamage - (primaryDamage * damageReduction / 100))
				if origin == ORIGIN_SPELL or origin == ORIGIN_AUTOCAST then
					if attacker:hasBuff(CLEAVE) or attacker:hasBuff(MULTISHOT) or attacker:hasBuff(MYSTIC_FOCUS) then
						primaryDamage = primaryDamage / 4
					end
				end
				if origin == ORIGIN_MELEE or origin == ORIGIN_RANGED or origin == ORIGIN_WAND then
					if critical then
						if attacker:hasBuff(CRITICAL_DAMAGE_SUPPORT) then
							critDamage = critDamage + attacker:getBuff(CRITICAL_DAMAGE_SUPPORT).stacks
						end
						beforeCrit = primaryDamage
						primaryDamage = primaryDamage * (1 + (critDamage / 100))
					end
				end
				if creature and creature:isMonster() then
					local mType = creature:getType()
					if colleftInfo[attacker:getId()].attributesItems[268] then -- Boss Damage Relict Hunter Insight
						local dungeonboss = mType:items() == "dungeonboss"
						local champion = mType:items() == "champion"
						local goblin = mType:items() == "goblin"
						local strongbox = creature:getStorageValue(PlayerStorage.strongBoxMonsterBoss)
						if dungeonboss or champion or goblin or strongbox > 0 then
							primaryDamage = math.floor(primaryDamage - (primaryDamage * colleftInfo[attacker:getId()].attributesItems[268].value / 100))
						end
					end
				end
				-- Talents
				if dualWilding then
					multiFix = primaryDamage / 2
				else
					multiFix = primaryDamage
				end
				local culling = false
				local fullexe = false
				local extraBasicDamage = 1
				local extraTalentBasic = 0
				local earthExtra = false
				-- talent boost basics

				if colleftInfo[attacker:getId()].attributesItems[169] then -- subklas More Power
					extraTalentBasic = extraTalentBasic + US_ENCHANTMENTS[169].subvalue
				end
				if creature:hasBuff(BLEED_ITEM) then
					if attacker:isPlayer() and colleftInfo[attacker:getId()].attributesItems[163] then -- Subklas Bloody Fury
						extraTalentBasic = extraTalentBasic + US_ENCHANTMENTS[163].subvalue
					end
				end
				if colleftInfo[attacker:getId()].attributesItems[182] then -- Subklas Venomous Shots
					earthExtra = true
				end
				if colleftInfo[attacker:getId()].attributesItems[192] then -- subklas Deferred Death
					extraTalentBasic = extraTalentBasic + US_ENCHANTMENTS[192].subvalue2
				end
				if colleftInfo[attacker:getId()].attributesItems[187] then -- Subklas Unrelenting Strike
					if critical then
						extraTalentBasic = extraTalentBasic + US_ENCHANTMENTS[187].subvalue
					end
				end
				if colleftInfo[attacker:getId()].attributesItems[128] then -- Subklas Thunder
					if math.random(1, 100) <= US_ENCHANTMENTS[128].subvalue then
						extraTalentBasic = extraTalentBasic + US_ENCHANTMENTS[128].subvalue2
					end
				end
				if colleftInfo[attacker:getId()].attributesItems[144] then -- subklas Plague
					extraTalentBasic = extraTalentBasic + US_ENCHANTMENTS[144].subvalue2
				end

				-- Executions
				local mType = creature:getType()
				local titan = mType:items() == "titan"
				local champion = mType:items() == "champion"
				local dungeonboss = mType:items() == "dungeonboss"
				local stone = mType:items() == "stone"
				if attacker:hasBuff(PASSING_PATH) and primaryType == COMBAT_DEATHDAMAGE then -- Passing Path
					if creature:getHealth() > 0 then
						local hpActual = creature:getHealth() + multiFix
						local hpLower = (creature:getMaxHealth() * 0.15)
						if hpActual <= hpLower and not (titan or champion or dungeonboss or stone) then
							doTargetCombatHealth(attacker:getId(), creature, COMBAT_UNDEFINEDDAMAGE, -creature:getHealth(), -creature:getHealth(), 94, ORIGIN_CONDITION, 0, 114)
						--	Game.sendAnimatedText('Passing Path', attacker:getPosition(), 192, "Reggae One-10px-bordered")
						end
					end
				end
				if colleftInfo[attacker:getId()].attributesItems[176] then -- Subklas Culling Strike
					if creature:getHealth() > 0 then
						local healthPercent = US_ENCHANTMENTS[176].subvalue
						local hpActual = creature:getHealth() + multiFix
						local hpLower = (creature:getMaxHealth() * healthPercent)
						if hpActual <= hpLower and not (titan or champion or dungeonboss or stone) then
							doTargetCombatHealth(attacker:getId(), creature, COMBAT_UNDEFINEDDAMAGE, -creature:getHealth(), -creature:getHealth(), 94, ORIGIN_CONDITION, 0, 22)
						--	Game.sendAnimatedText('Culling Strike', attacker:getPosition(), 192, "Reggae One-10px-bordered")
						end
					end
				end
				if colleftInfo[attacker:getId()].attributesItems[177] then -- Subklas Decimating Strike
					if creature:isMonster() and creature:getHealth() > 0 then
						if creature:getName() == "Dummy DPS" or creature:getName() == "Dummy Armored" or creature:getName() == "Dummy Boss" or creature:getName() == "Dummy" then
						else
							local healthPercent = math.random(US_ENCHANTMENTS[177].subvalue, US_ENCHANTMENTS[177].subvalue2)
							local damageRemove = creature:getMaxHealth() * (healthPercent / 100)
							if creature:getHealth() == creature:getMaxHealth() and not (titan or champion or dungeonboss or stone) then
								doTargetCombatHealth(attacker:getId(), creature, COMBAT_UNDEFINEDDAMAGE, -damageRemove,-damageRemove, 154, ORIGIN_CONDITION, 0, 23)
							--	Game.sendAnimatedText('Decimating Strike', attacker:getPosition(), 192,"Reggae One-10px-bordered")
							end
						end
					end
				end
			--	if attacker:getStorageValue(435024) == 3 or attacker:getStorageValue(435024) == 6 or attacker:getStorageValue(435024) == 7 then -- Battlemage Toxic Hunter Hieropath
			--		local ailemtDmg = 0
			--		if colleftInfo[attacker:getId()].totalailmentChances then
			--			ailemtDmg = colleftInfo[attacker:getId()].totalailmentChances * 0.1
			--		end
			--		if doAreaCombatHealth(attacker:getId(), primaryType, creature:getPosition(), area3x3, multiFix * ailemtDmg, multiFix * ailemtDmg, 0, ORIGIN_CONDITION, 300, 115) then
			--			Position(creature:getPosition().x + 1, creature:getPosition().y + 1, creature:getPosition().z):sendMagicEffect(540)
			--		end
			--	end
				if attacker:hasBuff(CRYO_PATH) then -- Cryo Path
					if primaryType == COMBAT_ICEDAMAGE then
						if math.random(100) <= 15 then
							if doAreaCombatHealth(attacker:getId(), COMBAT_ICEDAMAGE, creature:getPosition(), area3x3, multiFix * 0.75, multiFix * 0.75, 0, ORIGIN_CONDITION, 0, 112) then
							--	Game.sendAnimatedText('Ice Explosion', attacker:getPosition(), 192, "Reggae One-10px-bordered")
								Position(creature:getPosition().x + 2, creature:getPosition().y + 2, creature:getPosition().z):sendMagicEffect(675)
							end
						end
					end
				end
				if colleftInfo[attacker:getId()].attributesItems[187] then -- Subklas Unrelenting Strike
					if critical then
						doTargetCombatHealth(attacker:getId(), creature, primaryType, multiFix * US_ENCHANTMENTS[187].subvalue, multiFix * US_ENCHANTMENTS[187].subvalue, 18, ORIGIN_CONDITION, 0, 109)
					--	Game.sendAnimatedText('Unrelenting Strike', attacker:getPosition(), 129, "Reggae One-10px-bordered")
					end
				end
				if attacker:getStorageValue(435024) == 11 then -- Archer + Paladin Dawnstalker
					if math.random(100) <= FUSION_SCALING[11].chance then
						if doAreaCombatHealth(attacker:getId(), primaryType, creature:getPosition(), area3x3, multiFix * FUSION_SCALING[11].bonus, multiFix * FUSION_SCALING[11].bonus, 0, ORIGIN_CONDITION, 100, 107) then -- 261 stary efect
						--	Game.sendAnimatedText('Flash Cut', attacker:getPosition(), 192, "Reggae One-10px-bordered")
							Position(creature:getPosition().x + 3, creature:getPosition().y + 3, creature:getPosition().z):sendMagicEffect(614)
						end
					end
				end
				if colleftInfo[attacker:getId()].attributesItems[144] then -- subklas Plague
					local damagePlague = US_ENCHANTMENTS[144].subvalue
					local hpLower = (creature:getMaxHealth() * US_ENCHANTMENTS[144].subvalue3)
					if creature:getHealth() <= hpLower then
						damagePlague = damagePlague + US_ENCHANTMENTS[144].subvalue2
					end
					doTargetCombatHealth(attacker:getId(), creature, primaryType, multiFix * damagePlague, multiFix * damagePlague, 9, ORIGIN_CONDITION, 0, 106)
				end
				if colleftInfo[attacker:getId()].attributesItems[151] then -- Righteous Fury
					if origin == ORIGIN_SPELL or origin == ORIGIN_AUTOCAST then
						if attacker:hasBuff(HOLY_FURY) then
							if attacker:getBuff(HOLY_FURY).stacks >= 3 then
								doAreaCombatHealth(attacker:getId(), primaryType, creature:getPosition(), area3x3, multiFix * US_ENCHANTMENTS[151].subvalue, multiFix * US_ENCHANTMENTS[151].subvalue, 0, ORIGIN_CONDITION, 100, 29)
								attacker:removeBuff(HOLY_FURY)
								Position(creature:getPosition().x + 2, creature:getPosition().y + 2, creature:getPosition().z):sendMagicEffect(449)
							end
						end
					end
				end
				if colleftInfo[attacker:getId()].attributesItems[174] then -- subklas Bloody Arrow
					if math.random(100) <= US_ENCHANTMENTS[174].subvalue then
						doAreaCombatHealth(attacker:getId(), primaryType, creature:getPosition(), area3x3, multiFix * US_ENCHANTMENTS[174].subvalue2, multiFix * US_ENCHANTMENTS[174].subvalue2, 0, ORIGIN_CONDITION, 100, 108)
					--	attacker:getPosition():sendDistanceEffect(creature:getPosition(), 102)
						Position(creature:getPosition().x + 1, creature:getPosition().y + 1, creature:getPosition().z):sendMagicEffect(622)
					end
				end
				if creature:hasBuff(BLEED_ITEM) then
					if attacker:isPlayer() and colleftInfo[attacker:getId()].attributesItems[163] then -- Subklas Bloody Fury
						doTargetCombatHealth(attacker:getId(), creature, primaryType, multiFix * US_ENCHANTMENTS[163].subvalue, multiFix * US_ENCHANTMENTS[163].subvalue, 1, ORIGIN_CONDITION, 0, 28)
					end
				end
				if colleftInfo[attacker:getId()].attributesItems[169] then -- subklas More Power
					doTargetCombatHealth(attacker:getId(), creature, primaryType, multiFix * US_ENCHANTMENTS[169].subvalue, multiFix * US_ENCHANTMENTS[169].subvalue, 1, ORIGIN_CONDITION, 0, 27)
				end
				if colleftInfo[attacker:getId()].attributesItems[128] then -- Subklas Thunder
					if math.random(1, 100) <= US_ENCHANTMENTS[128].subvalue then
						doTargetCombatHealth(attacker:getId(), creature, primaryType, multiFix * US_ENCHANTMENTS[128].subvalue2, multiFix * US_ENCHANTMENTS[128].subvalue2, 18, ORIGIN_CONDITION, 0, 26)
						creature:getPosition():sendMagicEffect(109)
					end
				end
				if colleftInfo[attacker:getId()].attributesItems[192] then -- subklas Deferred Death
					local sped2 = attacker:getBaseSpeed() * US_ENCHANTMENTS[192].subvalue
					local chill2 = Condition(CONDITION_PARALYZE)
					chill2:setParameter(CONDITION_PARAM_TICKS, 2000)
					chill2:setParameter(CONDITION_PARAM_SPEED, -sped2)
					chill2:setParameter(CONDITION_PARAM_SUBID, 777783)
					creature:addCondition(chill2)
					creature:addBuff(DEFERRED_DEATH)
					doTargetCombatHealth(attacker:getId(), creature, primaryType, multiFix * US_ENCHANTMENTS[192].subvalue2, multiFix * US_ENCHANTMENTS[192].subvalue2, 18, ORIGIN_CONDITION, 0, 25)
				end
				if colleftInfo[attacker:getId()].attributesItems[182] then -- Subklas Venomous Shots
					doTargetCombatHealth(attacker:getId(), creature, COMBAT_EARTHDAMAGE, multiFix * US_ENCHANTMENTS[182].subvalue, multiFix * US_ENCHANTMENTS[182].subvalue, 21, ORIGIN_CONDITION, 0, 24)
				--	primaryDamage = primaryDamage * (1 + US_ENCHANTMENTS[182].subvalue)
				end
				if colleftInfo[attacker:getId()].attributesItems[180] then -- subklas Static Conduit
					local extraTargets = getClosestTargets(creature, creature, creature:getPosition(), 3, US_ENCHANTMENTS[180].subvalue, true)
					for i = 1, #extraTargets do
						if extraTargets[i]:isMonster() then
							if doTargetCombatHealth(attacker:getId(), extraTargets[i], primaryType, multiFix * US_ENCHANTMENTS[180].subvalue2, multiFix * US_ENCHANTMENTS[180].subvalue2, 109, ORIGIN_CONDITION, 0, 105) then
							end
						end
					end
				end
				if attacker:hasBuff(THUNDER_PATH) then -- Thunder Path
					if primaryType == COMBAT_ENERGYDAMAGE then
						extraBasicDamage = extraBasicDamage + 0.25
						local extraTargets = getClosestTargets(creature, creature, creature:getPosition(), 3, 3, true)
						for i = 1, #extraTargets do
							if extraTargets[i]:isMonster() then
								if doTargetCombatHealth(attacker:getId(), extraTargets[i], COMBAT_ENERGYDAMAGE, multiFix * 0.25, multiFix * 0.25, 649, ORIGIN_CONDITION, 0, 113) then
								end
							end
						end
					end
				end
				if colleftInfo[attacker:getId()].attributesItems[147] then -- subklas Boulder
					if math.random(100) <= US_ENCHANTMENTS[147].subvalue2 then
						if doAreaCombatHealth(attacker:getId(), COMBAT_EARTHDAMAGE, creature:getPosition(), area3x3, multiFix * US_ENCHANTMENTS[147].subvalue, multiFix * US_ENCHANTMENTS[147].subvalue, 0, ORIGIN_CONDITION, 100, 102) then
						--	Game.sendAnimatedText('Boulder', attacker:getPosition(), 192, "Reggae One-10px-bordered")
						Position(creature:getPosition().x + 6, creature:getPosition().y + 6, creature:getPosition().z):sendMagicEffect(619)
						end
					end
				end
				-- Melee cast
				if origin == ORIGIN_MELEE and attacker:hasBuff(CLEAVE) then
					local target = attacker:getTarget()
					if target then
						local playerPos = attacker:getPosition()
						local effectEx = 197
						local cleaveDamage = 1.00
        				position = Position(playerPos.x + 2, playerPos.y + 2, playerPos.z)
						if colleftInfo[attacker:getId()].attributesItems[155] then
							cleaveDamage = cleaveDamage + US_ENCHANTMENTS[155].subvalue2
							extraBasicDamage = extraBasicDamage + US_ENCHANTMENTS[155].subvalue2
							if math.random(1, 100) <= US_ENCHANTMENTS[155].subvalue then
								position = Position(playerPos.x + 2, playerPos.y + 2, playerPos.z)
								effectEx = 223
								cleaveDamage = cleaveDamage + US_ENCHANTMENTS[155].subvalue3
								extraBasicDamage = extraBasicDamage + US_ENCHANTMENTS[155].subvalue3
							end
						end
						cleaveDamage = cleaveDamage + extraTalentBasic
						--position:sendMagicEffect(effectEx)
						attacker:sendCreatureEffect(effectEx)
						doAreaCombatHealth(attacker:getId(), primaryType, target:getPosition(), masshealingAreaCleave, primaryDamage * cleaveDamage, primaryDamage * cleaveDamage, 0, ORIGIN_CONDITION, 100, 115) -- a3x3effectnocenter
						if earthExtra then
							doAreaCombatHealth(attacker:getId(), COMBAT_EARTHDAMAGE, target:getPosition(), masshealingAreaCleave, primaryDamage * US_ENCHANTMENTS[182].subvalue, primaryDamage * US_ENCHANTMENTS[182].subvalue, 0, ORIGIN_CONDITION, 0, 24)
						end
					end
				end
				if origin == ORIGIN_WAND and attacker:hasBuff(MYSTIC_FOCUS) then
					local extraHitsFocus = 4
					local multiDamageFocus = 1.0
					local mysticEffect = 0
					if colleftInfo[attacker:getId()].attributesItems[154] then -- unique Blitz Staff
						multiDamageFocus = multiDamageFocus + US_ENCHANTMENTS[154].subvalue
						extraBasicDamage = extraBasicDamage + US_ENCHANTMENTS[154].subvalue
						extraHitsFocus = extraHitsFocus + US_ENCHANTMENTS[154].subvalue4
						if math.random(1, 100) <= US_ENCHANTMENTS[154].subvalue2 then
							multiDamageFocus = multiDamageFocus + US_ENCHANTMENTS[154].subvalue3
							extraBasicDamage = extraBasicDamage + US_ENCHANTMENTS[154].subvalue3
							mysticEffect = 572
						end
					end
					multiDamageFocus = multiDamageFocus + extraTalentBasic
					local target = attacker:getTarget()
					if target then
						local extraTargets = getClosestTargets(attacker, creature, creature:getPosition(), 5, extraHitsFocus, true)
						for i = 1, #extraTargets do
							if extraTargets[i]:isMonster() then
								if earthExtra then
									doTargetCombatHealth(attacker:getId(), extraTargets[i], COMBAT_EARTHDAMAGE, multiFix * US_ENCHANTMENTS[182].subvalue, multiFix * US_ENCHANTMENTS[182].subvalue, 21, ORIGIN_CONDITION, 0, 24)
								end
								if doTargetCombatHealth(attacker:getId(), extraTargets[i], primaryType, multiFix * multiDamageFocus, multiFix * multiDamageFocus, 591, ORIGIN_CONDITION, 0, 113) then
									if mysticEffect > 0 then
										extraTargets[i]:getPosition():sendMagicEffect(mysticEffect)
									end
									if colleftInfo[attacker:getId()].shotTypeLeft then
										attacker:getPosition():sendDistanceEffect(extraTargets[i]:getPosition(), colleftInfo[attacker:getId()].shotTypeLeft)
									end
									if colleftInfo[attacker:getId()].shotTypeRight then
										attacker:getPosition():sendDistanceEffect(extraTargets[i]:getPosition(), colleftInfo[attacker:getId()].shotTypeRight)
									end
								end
							end
						end
					end
				end
				if colleftInfo[attacker:getId()].attributesItems[175] then -- talent subklas Multishot Enhancment
					local extraTargets = getClosestTargets(creature, creature, creature:getPosition(), 6, US_ENCHANTMENTS[175].subvalue, true)
					extraBasicDamage = extraBasicDamage + US_ENCHANTMENTS[175].subvalue2
					for i = 1, #extraTargets do
						if extraTargets[i]:isMonster() then
							if doTargetCombatHealth(attacker:getId(), extraTargets[i], primaryType, multiFix * US_ENCHANTMENTS[175].subvalue2, multiFix * US_ENCHANTMENTS[175].subvalue2, 0, ORIGIN_CONDITION, 0, 122) then
								if colleftInfo[attacker:getId()].shotTypeLeft then
									attacker:getPosition():sendDistanceEffect(extraTargets[i]:getPosition(), colleftInfo[attacker:getId()].shotTypeLeft)
								end
								if colleftInfo[attacker:getId()].shotTypeRight then
									attacker:getPosition():sendDistanceEffect(extraTargets[i]:getPosition(), colleftInfo[attacker:getId()].shotTypeRight)
								end
							end
						end
					end
				end
				if origin == ORIGIN_RANGED and attacker:hasBuff(MULTISHOT) then
					local extraHits = 0
					local multiDamage = 0
					local holyArrow = false
					if colleftInfo[attacker:getId()].attributesItems[149] then -- unique Holy Arrow
						multiDamage = multiDamage + US_ENCHANTMENTS[149].subvalue2
						extraBasicDamage = extraBasicDamage + US_ENCHANTMENTS[149].subvalue2
						extraHits = extraHits + 2
						if math.random(1, 100) <= US_ENCHANTMENTS[149].subvalue then
							multiDamage = multiDamage + US_ENCHANTMENTS[149].subvalue3
							extraBasicDamage = extraBasicDamage + US_ENCHANTMENTS[149].subvalue3
							holyArrow = true
						end
					end
					if origin == ORIGIN_RANGED and attacker:hasBuff(MULTISHOT) then -- Aura Multishot
						multishot = true
						extraHits = extraHits + 4
						multiDamage = multiDamage + 1.00
					end
					multiDamage = multiDamage + extraTalentBasic
					if multishot then
						local extraTargets = getClosestTargets(attacker, creature, creature:getPosition(), 6, extraHits, true)
						for i = 1, #extraTargets do
							if extraTargets[i]:isMonster() then
								if earthExtra then
									doTargetCombatHealth(attacker:getId(), extraTargets[i], COMBAT_EARTHDAMAGE, multiFix * US_ENCHANTMENTS[182].subvalue, multiFix * US_ENCHANTMENTS[182].subvalue, 21, ORIGIN_CONDITION, 0, 24)
								end
								if doTargetCombatHealth(attacker:getId(), extraTargets[i], primaryType, multiFix * multiDamage, multiFix * multiDamage, 0, ORIGIN_CONDITION, 0, 104) then
									if holyArrow then
										local playerNewPos = attacker:getPosition()
										local position = Position(playerNewPos.x - 4, playerNewPos.y - 7, playerNewPos.z)
										position:sendDistanceEffect(extraTargets[i]:getPosition(), 215)
									end
									if colleftInfo[attacker:getId()].shotTypeLeft then
										attacker:getPosition():sendDistanceEffect(extraTargets[i]:getPosition(), colleftInfo[attacker:getId()].shotTypeLeft)
									end
									if colleftInfo[attacker:getId()].shotTypeRight then
										attacker:getPosition():sendDistanceEffect(extraTargets[i]:getPosition(), colleftInfo[attacker:getId()].shotTypeRight)
									end
								end
							end
						end
					end
				end

				if (origin == ORIGIN_MELEE or origin == ORIGIN_WAND or origin == ORIGIN_RANGED) then
					if colleftInfo[attacker:getId()].attributesItems[158] then -- subklas Sanctified Assault
						if math.random(1, 100) <= US_ENCHANTMENTS[158].subvalue then
							doTargetCombatHealth(attacker:getId(), creature, primaryType, multiFix * US_ENCHANTMENTS[158].subvalue2, multiFix * US_ENCHANTMENTS[158].subvalue2, 1, ORIGIN_CONDITION, 100, 30)
						end
					end
					if colleftInfo[attacker:getId()].attributesItems[126] then -- talent Arc Leech
						local extraTargets = getClosestTargets(creature, creature, creature:getPosition(), 3, US_ENCHANTMENTS[126].subvalue3, true)
						extraBasicDamage = extraBasicDamage + US_ENCHANTMENTS[126].subvalue2
						for i = 1, #extraTargets do
							if extraTargets[i]:isMonster() then
								if doTargetCombatHealth(attacker:getId(), extraTargets[i], primaryType, multiFix * US_ENCHANTMENTS[126].subvalue2, multiFix * US_ENCHANTMENTS[126].subvalue2, 571, ORIGIN_CONDITION, 0, 121) then
								end
							end
						end
					end
					
					if colleftInfo[attacker:getId()].attributesItems[165] then -- Subklas Catastrophic Blow and not colleftInfo[attacker:getId()].isTwoHanded
						if origin == ORIGIN_MELEE then
							local target = attacker:getTarget()
							if target then
								local direction = attacker:getPosition():getDirectionTo(target:getPosition())
								local area = CLEAVE_SPLASH[direction].area or CLEAVE_SPLASH[DIRECTION_NORTH].area
								local effectEx = CLEAVE_SPLASH[direction].effect or CLEAVE_SPLASH[DIRECTION_NORTH].effect
								local attackerPos = attacker:getPosition()
								local targetPos = target:getPosition()
								local offsetPos = Position(attackerPos.x + CLEAVE_SPLASH[direction].offset.x, attackerPos.y + CLEAVE_SPLASH[direction].offset.y, attackerPos.z)
								offsetPos:sendMagicEffect(effectEx)
								doAreaCombatHealth(attacker:getId(), primaryType, attackerPos, createCombatArea(area), multiFix * US_ENCHANTMENTS[165].subvalue, multiFix * US_ENCHANTMENTS[165].subvalue, 0, ORIGIN_CONDITION, 100, 103)
							end
						end
					end
				end
				-- Only Melee
				-- Only Spells
				if (origin == ORIGIN_SPELL or origin == ORIGIN_AUTOCAST) then
					if colleftInfo[attacker:getId()].attributesItems[211] then -- unique Volcanic Erruption
						if primaryType == COMBAT_FIREDAMAGE then
							if math.random(100) <= 25 then
								if doAreaCombatHealth(attacker:getId(), COMBAT_FIREDAMAGE, creature:getPosition(), area3x3, multiFix * 0.25, multiFix * 0.25, 0, ORIGIN_CONDITION, 100, 111) then
									local playerPos = creature:getPosition()
									local position = Position(playerPos.x + 3, playerPos.y + 3, playerPos.z)
									position:sendMagicEffect(488)
								--	Game.sendAnimatedText('Volcanic Erruption', attacker:getPosition(), 192, "Reggae One-10px-bordered")
								end
							end
						end
					end
					if colleftInfo[attacker:getId()].attributesItems[78] then -- Unique
						if primaryType == COMBAT_ENERGYDAMAGE then
							if math.random(100) <= colleftInfo[attacker:getId()].attributesItems[78].value then
								if doAreaCombatHealth(attacker:getId(), COMBAT_ENERGYDAMAGE, creature:getPosition(), area3x3, multiFix * 0.15, multiFix * 0.15, 109, ORIGIN_CONDITION, 100, 100) then
								--	Game.sendAnimatedText('Malestorm', attacker:getPosition(), 192, "Reggae One-10px-bordered")
								end
							end
						end
					end
 					if colleftInfo[attacker:getId()].attributesItems[134] then -- subklas Fury Flames
						doAreaCombatHealth(attacker:getId(), primaryType, creature:getPosition(), area3x3, multiFix * US_ENCHANTMENTS[134].subvalue, multiFix * US_ENCHANTMENTS[134].subvalue, 0, ORIGIN_CONDITION, 0, 101)
						Position(creature:getPosition().x + 3, creature:getPosition().y + 3, creature:getPosition().z):sendMagicEffect(488)
					end
				end
				if (origin == ORIGIN_MELEE or origin == ORIGIN_WAND or origin == ORIGIN_RANGED) then
					primaryDamage = primaryDamage * extraBasicDamage
				end
				-- Only Spells
			end
--		end
		if origin == ORIGIN_MELEE or origin == ORIGIN_RANGED or origin == ORIGIN_WAND then
			if colleftInfo[attacker:getId()].isDualWielding then
				primaryDamage = primaryDamage / 2
			end
		end
		if attacker:getStorageValue(PlayerStorage.damageInfo) == 1 then
			if attacker:isPlayer() then
				if attacker:openChannel(17) then
					local crit = ""
					local damage = primaryDamage
					if critical then
						crit = "CRITICAL"
					--	damage = ""..beforeCrit.." ["..primaryDamage.."]"
					end
					if (origin == ORIGIN_SPELL or origin == ORIGIN_AUTOCAST) or origin == ORIGIN_DOT then
						local od = shortNumbers(-originalDamage,2)
						local dd = shortNumbers(-damage,2)
						local message = string.format("Damage: %s Damage Reduction: %d%% [%s] %s", od, damageReduction, dd, crit)
						if primaryType == COMBAT_PHYSICALDAMAGE then
						--	attacker:sendChannelMessage("","Damage: "..od.." Damage Reduction: " ..damageReduction .. "% [" .. dd .. "] "..crit.."", TALKTYPE_CHANNEL_O, 17)
						attacker:sendChannelMessage("", message, TALKTYPE_CHANNEL_O, 17)
						else
						--	attacker:sendChannelMessage("","Damage: "..od.." Damage Reduction: " ..damageReduction .. "% [" .. dd .. "] "..crit.."", TALKTYPE_CHANNEL_O, 17)
						attacker:sendChannelMessage("", message, TALKTYPE_CHANNEL_O, 17)
						end
					end

				end
			end
		end

		if attacker:getStorageValue(PlayerStorage.basicInfo) == 1 then
			if attacker:isPlayer() then
				if attacker:openChannel(32) then
					local crit = ""
					local damage = primaryDamage
					if critical then
						crit = "CRITICAL"
					--	damage = ""..beforeCrit.." ["..primaryDamage.."]"
					end
					if focusedStrike then
						focusedStrike = "FOCUSED STRIKE"
					else
						focusedStrike = ""
					end
					if origin == ORIGIN_RANGED or origin == ORIGIN_MELEE or origin == ORIGIN_WAND then
						local od = shortNumbers(-originalDamage,2)
						local dd = shortNumbers(-damage,2)
						local message = string.format("Damage: %s Damage Reduction: %d%% [%s] %s", od, damageReduction, dd, crit)

						if primaryType == COMBAT_PHYSICALDAMAGE then
							--attacker:sendChannelMessage("","Damage: "..originalDamage.." Damage Reduction: " ..damageReduction .. "% [" .. damage .. "] "..crit.." "..focusedStrike.."", TALKTYPE_CHANNEL_O, 32)
							attacker:sendChannelMessage("", message, TALKTYPE_CHANNEL_O, 32)
						else
							--attacker:sendChannelMessage("","Damage: "..originalDamage.." Damage Reduction: " ..damageReduction .. "% [" .. damage .. "] "..crit.." "..focusedStrike.."", TALKTYPE_CHANNEL_O, 32)
							attacker:sendChannelMessage("", message, TALKTYPE_CHANNEL_O, 32)
						end
					end
				end
			end
		end

	end

	if creature:isPlayer() and attacker:isMonster() then
		if not creature then return primaryDamage, primaryType, secondaryDamage, secondaryType end
		if not creature:isPlayer() then return primaryDamage, primaryType, secondaryDamage, secondaryType end
		if not attacker then return primaryDamage, primaryType, secondaryDamage, secondaryType end
		if not attacker:isMonster() then return primaryDamage, primaryType, secondaryDamage, secondaryType end
		local skull = attacker:getSkull()
		local primalTotal = 0
		if not BOSSESS_DAMAGE[attacker:getName()] then
			if skull == 14 then -- waller
				if math.random(1, 100) <= 100 then
					creature:getPosition():sendMagicEffect(9)
					local playerDir = creature:getDirection()
					local pDirect = creature:getPosition()
					if playerDir == 0 then
						wallerWalltopDown(Position(pDirect.x, pDirect.y - 1, pDirect.z), 1497, 13, 3000)
					elseif playerDir == 1 then
						wallerWallleftRight(Position(pDirect.x + 1, pDirect.y, pDirect.z), 1497, 13, 3000)
					elseif playerDir == 2 then
						wallerWalltopDown(Position(pDirect.x, pDirect.y + 1, pDirect.z), 1497, 13, 3000)
					elseif playerDir == 3 then
						wallerWallleftRight(Position(pDirect.x - 1, pDirect.y, pDirect.z), 1497, 13, 3000)
					end
				end
			elseif skull == 13 then -- plagued -- OFF
			--[[
				if math.random(1, 100) <= 100 then
					creature:getPosition():sendMagicEffect(9)
					exoriCreateItem(attacker:getPosition(), 1490, 10000, math.floor((damageFormula(attacker:getMonsterLevel()) / 100)), attacker:getId())
				end
				--]]
			elseif skull == 16 then -- vampiric
				local healHit = primaryDamage / 2
				if healHit < 0 then
					healHit = healHit * -1
				end
				if MonsterType(attacker:getName()):getRace() == 6 then -- increase damage to boss
					healHit = healHit / 3
				end
				attacker:addHealth(healHit, true)
			elseif skull == 18 then -- pusher - stunner
				if attacker and attacker:isMonster() then
					local target = attacker:getTarget()
					if target and math.random(100) <= 30 then
						local stun = Condition(CONDITION_STUN)
						stun:setParameter(CONDITION_PARAM_TICKS, 500)
						target:addCondition(stun)
						target:getPosition():sendMagicEffect(178)
					end
				end
			elseif skull == 19 then -- puller
				if attacker and attacker:isMonster() then
					local target = attacker:getTarget()
					if target then
						local oldPosition = target:getPosition()
						local newPosition = target:getClosestFreePosition(attacker:getPosition(), false)
						local tile = Tile(newPosition)
						if not isBadTile(tile) and target:getPosition():isSightClear(attacker:getPosition(), true) and attacker:getPosition():getDistance(target:getPosition()) <= 5 and math.random(100) <= 30 then
							if newPosition.x == 0 then
								return primaryDamage, primaryType, secondaryDamage, secondaryType, origin
							elseif target:teleportTo(newPosition) then
								oldPosition:sendMagicEffect(178)
								newPosition:sendMagicEffect(178)
							end
						end
					end
				end
			elseif skull >= 28 and skull <= 34 then -- iced
				local ailment = {
					[28] = {debuff = FROSTBITE_ITEM, effect = 44},
					[29] = {debuff = IGNITE_ITEM, effect = 16},
					[30] = {debuff = CURSE_ITEM, effect = 18},
					[31] = {debuff = DAZZLE_ITEM, effect = 8},
					[32] = {debuff = ELECTRO_ITEM, effect = 12},
					[33] = {debuff = POISON_MOB, effect = 9},
					[34] = {debuff = BLEED_ITEM, effect = 1},
				}
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
				primaryDamage = primaryDamage * 1.20
				---END affixy przy ataku
			end
		end
		if colleftInfo[creature:getId()] then
			if colleftInfo[creature:getId()].attributesItems[219] then -- Dragon Absorb
				creature:addHealth(math.abs(primaryDamage * 0.025), true)
			end
		end
		if primaryDamage < 0 then
			if attacker and attacker:isMonster() then
				local mType = attacker:getType()
				if colleftInfo[creature:getId()].attributesItems[270] then -- Tactical Advantage
						local dungeonboss = mType:items() == "dungeonboss"
						local champion = mType:items() == "champion"
						if dungeonboss or champion then
						primaryDamage = math.floor(primaryDamage + (primaryDamage * colleftInfo[creature:getId()].attributesItems[270].value / 100))
					end
				end
			end
			if colleftInfo[creature:getId()].hasMeleeWeapon and distance <= 1 then -- melee weapons reduced 20% total damage
				primaryDamage = primaryDamage * 0.80
			end
			primaryDamage = math.floor(primaryDamage + (primaryDamage * primalTotal / 100))
		end
		---END creature:isPlayer() celem jest gracz
	end
	return primaryDamage, primaryType, secondaryDamage, secondaryType, origin, critical, spellUID, critChance, distance
end