local function checkIchorShieldDecay(playerId)
	local player = Player(playerId)
	if not player then return end

	local expireTime = player:getStorageValue(PlayerStorage.ichorShieldTime)
	local now = os.time()

	if now >= expireTime then
		player:setEnergyShield(0)
		player:setMaxEnergyShield(0)
		player:removeBuff(ICHOR_SHIELD)
		player:setStorageValue(PlayerStorage.ichorShieldAmount, -1)
	else
		local remainingMs = math.max(1000, (expireTime - now) * 1000)
		addEvent(checkIchorShieldDecay, remainingMs, playerId)
	end
end

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


CHAMPION_STATS = {
	["Mia"] = {physical_character = true, hp_start = 550, hp_level = 3800, mana = 200, manaPL = 600, physical_attack = 50, physical_attackPL = 150, magic_attack = 0, magic_attackPL = 0, asPL = 50, physical_defense = 30, physical_defensePL = 80, magic_defense = 30, magic_defensePL = 80, health_regen = 1, regen_mana = 1},
	["Gorn"] = {physical_character = true, hp_start = 650, hp_level = 4500, mana = 0, manaPL = 0, physical_attack = 50, physical_attackPL = 150, magic_attack = 0, magic_attackPL = 0, asPL = 50, physical_defense = 30, physical_defensePL = 80, magic_defense = 30, magic_defensePL = 80, health_regen = 1, regen_mana = 1},
	["Juki"] = {magic_character = true, hp_start = 500, hp_level = 3300, mana = 300, manaPL = 800, physical_attack = 0, physical_attackPL = 0, magic_attack = 50, magic_attackPL = 150, asPL = 50, physical_defense = 30, physical_defensePL = 80, magic_defense = 30, magic_defensePL = 80, health_regen = 1, regen_mana = 1},
	["Limona"] = {magic_character = true, hp_start = 500, hp_level = 3000, mana = 480, manaPL = 880, physical_attack = 0, physical_attackPL = 0, magic_attack = 50, magic_attackPL = 150, asPL = 50, physical_defense = 30, physical_defensePL = 80, magic_defense = 30, magic_defensePL = 80, health_regen = 1, regen_mana = 1},
}
MONSTER_CONFIG = {
	[1] = { damage = 10, physical_defense = 20, magic_defense = 20, exp = 2, gold = 2, upgrade_materials_chance = 7500 }, -- goblin
	[2] = { damage = 20, physical_defense = 23, magic_defense = 23, exp = 4, gold = 3, upgrade_materials_chance = 7500 }, -- bandits
	[3] = { damage = 30, physical_defense = 27, magic_defense = 27, exp = 8, gold = 5, upgrade_materials_chance = 7500 }, -- orcs
}
function us_onDamaged(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin, critical, spellUID, critChance, distance)
	local isNegative = (primaryDamage < 0)
	primaryDamage = math.abs(primaryDamage)

	-- GRACZ ATAKUJE
	if attacker:isPlayer() then -- atakujacym jest gracz
		local attackerAttrs = colleftInfo[attacker:getId()] and colleftInfo[attacker:getId()].attributesItems
		local physical_penetration = attacker:getPhysicalPenetration()
		local magic_penetration = attacker:getMagicPenetration()
		attacker:getTotalAttackSpeed()
		local player_damage = attacker:getCharacterType()
		local physical_damage = 0
		local magic_damage = 0
		if origin == ORIGIN_MELEE or origin == ORIGIN_RANGED or origin == ORIGIN_WAND then -- obrazenia melee
			primaryDamage = player_damage
			if primaryType == COMBAT_PHYSICALDAMAGE then -- obrazenia fizyczne wrecz
			elseif primaryType ~= COMBAT_PHYSICALDAMAGE then -- obrazenia magiczne wrecz
			end
		end
		if primaryType == COMBAT_PHYSICALDAMAGE then -- obrazenia fizyczne
		elseif primaryType ~= COMBAT_PHYSICALDAMAGE then -- obrazenia magiczne
		end
		if attacker:hasBuff(VENGEANCE_FLAME) then
			local bonus = attacker:getStorageValue(PlayerStorage.vengeanceFlameDmg)
			if not bonus or bonus <= 0 then
				bonus = 30
			end
			primaryDamage = math.ceil(primaryDamage * (1 + bonus / 100))
		end

		-- Gorn Passive: Basic attacks deal extra 25 (+5% Total HP) Physical Damage (10s cooldown)
		if attacker:getVocation():getId() == 2 and (origin == ORIGIN_MELEE or origin == ORIGIN_RANGED or origin == ORIGIN_WAND) then
			local now = os.time()
			local nextAvailable = attacker:getStorageValue(PlayerStorage.gornAttackCooldown)
			if nextAvailable < 0 or now >= nextAvailable then
				attacker:setStorageValue(PlayerStorage.gornAttackCooldown, now + 10)
				local gornBonus = math.ceil(25 + (attacker:getMaxHealth() * 0.05))
				primaryDamage = primaryDamage + gornBonus
				creature:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
			end
		end

		-- Mia Passive (Vocation 3): Basic attacks slow by 20% for 1.5s. Every 5s, deals 50% Physical Attack extra Physical Damage.
		if attacker:getVocation():getId() == 3 and (origin == ORIGIN_MELEE or origin == ORIGIN_RANGED or origin == ORIGIN_WAND) then
			local baseSpeed = creature:getBaseSpeed() or 100
			local slow = math.floor(baseSpeed * 0.20)
			if slow > 0 then
				local slowCond = Condition(CONDITION_PARALYZE)
				slowCond:setParameter(CONDITION_PARAM_TICKS, 1500)
				slowCond:setParameter(CONDITION_PARAM_SPEED, -slow)
				creature:addCondition(slowCond)
				creature:addBuff(MIA_SLOW_DEBUFF, 1500)
			end

			local now = os.time()
			local nextAvailable = attacker:getStorageValue(PlayerStorage.miaPassiveCooldown)
			if nextAvailable < 0 or now >= nextAvailable then
				attacker:setStorageValue(PlayerStorage.miaPassiveCooldown, now + 5)
				local physAtk = attacker:getPhysicalAttack() or 50
				local bonusDmg = math.ceil(physAtk * 0.50)
				primaryDamage = primaryDamage + bonusDmg
				creature:getPosition():sendMagicEffect(CONST_ME_EXPLOSIONHIT)
			end
		end

		-- Mia Spell 1: Rapid Fire Active (+20% basic attack damage & special distance projectile)
		if attacker:hasBuff(MIA_RAPID_FIRE) and (origin == ORIGIN_MELEE or origin == ORIGIN_RANGED or origin == ORIGIN_WAND) then
			primaryDamage = math.ceil(primaryDamage * 1.20)
			attacker:getPosition():sendDistanceEffect(creature:getPosition(), 33)
		end
		local function getDefenseMultiplier(defFlat)
			if defFlat >= 0 then
				return 100 / (100 + defFlat)
			else
				local cappedDef = math.max(-60, defFlat)
				return 2 - (100 / (100 - cappedDef))
			end
		end

		local baseDmgBeforeDef = primaryDamage
		local rawDef = 0
		local penetration = 0
		local effectiveDef = 0
		local rawReductionPct = 0
		local effectiveReductionPct = 0
		local penGain = 0
		local penGainPct = 0

		-- =====================================================================
		-- DEFENSE CALCULATION (LoL & MLBB Multiplicative Order of Operations)
		-- 1. Base Target Defense (Monster Level or Player Armor/MR)
		-- 2. Flat Defense Reduction
		-- 3. Multiplicative % Defense Shred (Def * (1 - r1) * (1 - r2) ...)
		-- 4. Flat Penetration (Raw Def - Pen, allows negative defense down to -60)
		-- =====================================================================
		local isPhysical = (primaryType == COMBAT_PHYSICALDAMAGE)
		local baseTargetDef = 0

		if creature:isMonster() then -- celem jest monster
			baseTargetDef = (15 + creature:getMonsterLevel() * 1)
		elseif creature:isPlayer() then -- celem jest PLAYER
			baseTargetDef = isPhysical and creature:getPhysicalDefense() or creature:getMagicDefense()
		end

		-- Step 1: Flat Defense Reduction
		local flatDefReduction = 0
		rawDef = math.max(0, baseTargetDef - flatDefReduction)

		-- Step 2: Multiplicative % Defense Shred
		local defShredMultiplier = 1.0

		if not isPhysical then
			-- [29] Unmake (Abyssal Mask): -30% Magic Defense within 4 tiles
			if attackerAttrs and attackerAttrs[29] then
				if attacker:getPosition():getDistance(creature:getPosition()) <= 4 then
					defShredMultiplier = defShredMultiplier * 0.70
				end
			end
			-- Any future Champion spells / debuffs reducing Magic Defense can be added here:
			-- if creature:hasBuff(MAGIC_SHRED_BUFF) then defShredMultiplier = defShredMultiplier * (1.0 - shredPercent) end
		else
			-- [31] Carve (Black Cleaver): -6% Physical Defense per stack (up to -30% at 5 stacks)
			if creature:hasBuff(CARVE_DEBUFF) then
				local stacks = creature:getBuffStacks(CARVE_DEBUFF)
				defShredMultiplier = defShredMultiplier * (1.0 - (stacks * 0.06))
			end
			-- Any future Champion spells / debuffs reducing Physical Defense can be added here:
			-- if creature:hasBuff(PHYSICAL_SHRED_BUFF) then defShredMultiplier = defShredMultiplier * (1.0 - shredPercent) end
		end

		-- Apply total multiplicative % shred
		rawDef = math.floor(rawDef * defShredMultiplier)

		-- Step 3: Flat Penetration
		penetration = isPhysical and physical_penetration or magic_penetration
		effectiveDef = rawDef - penetration

		local rawMult = getDefenseMultiplier(rawDef)
		rawReductionPct = (1 - rawMult) * 100

		targetDefMult = getDefenseMultiplier(effectiveDef)
		effectiveReductionPct = (1 - targetDefMult) * 100

		local dmgWithoutPen = math.ceil(baseDmgBeforeDef * rawMult)
		local dmgWithPen = math.ceil(baseDmgBeforeDef * targetDefMult)
		penGain = dmgWithPen - dmgWithoutPen
		penGainPct = (dmgWithoutPen > 0) and (((dmgWithPen - dmgWithoutPen) / dmgWithoutPen) * 100) or 0

		primaryDamage = dmgWithPen

		-- =====================================================================
		-- MODYFIKACJE PRZEDMIOTÓW [22-28] - DAMAGE MODIFIERS
		-- =====================================================================
		-- [24] Focusing Mark: 10% more damage to marked enemy
		if creature:hasBuff(FOCUSING_MARK_DEBUFF) then
			primaryDamage = math.ceil(primaryDamage * 1.10)
		end

		-- [26] Merciless: 20% increased damage against targets below 40% health
		if attackerAttrs and attackerAttrs[26] then
			if creature:getHealth() < math.ceil(creature:getMaxHealth() * 0.40) then
				primaryDamage = math.ceil(primaryDamage * 1.20)
			end
		end

		-- [27] Gigantism: Each 500 HP increases damage by 2%
		if attackerAttrs and attackerAttrs[27] then
			local hpBonus = math.floor(attacker:getMaxHealth() / 500) * 2
			if hpBonus > 0 then
				primaryDamage = math.ceil(primaryDamage * (1 + hpBonus / 100))
			end
		end

		-- [28] Glass Cannon: Each 1% missing HP increases damage by 1%
		if attackerAttrs and attackerAttrs[28] then
			local maxHp = attacker:getMaxHealth()
			local curHp = attacker:getHealth()
			local missingPercent = math.max(0, math.floor(((maxHp - curHp) / maxHp) * 100))
			if missingPercent > 0 then
				primaryDamage = math.ceil(primaryDamage * (1 + missingPercent / 100))
			end
		end

		-- =====================================================================
		-- MODYFIKACJE PRZEDMIOTÓW [22-28] - ON-HIT PROCS & COOLDOWNS
		-- =====================================================================
		-- [24] Focusing Mark: After damaging an enemy deal 10% more damage to them and gain 10% Movement Speed. Duration: 3s, CD: 4s
		if attackerAttrs and attackerAttrs[24] then
			local now = os.time()
			local lastMark = attacker:getStorageValue(PlayerStorage.focusingMarkCooldown)
			if lastMark < 0 or (now - lastMark) >= 4 then
				attacker:setStorageValue(PlayerStorage.focusingMarkCooldown, now)
				attacker:addBuff(FOCUSING_MARK, 3000)
				local speedCond = Condition(CONDITION_HASTE)
				speedCond:setParameter(CONDITION_PARAM_TICKS, 3000)
				speedCond:setParameter(CONDITION_PARAM_SPEED, math.ceil(attacker:getBaseSpeed() * 0.10))
				speedCond:setParameter(CONDITION_PARAM_SUBID, 3260)
				attacker:addCondition(speedCond)
				attacker:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)
				creature:addBuff(FOCUSING_MARK_DEBUFF, 3000)
			end
		end

		-- [23] Brave Smite: Dealing skill damage recovers 3% Max HP. CD: 9s
		if attackerAttrs and attackerAttrs[23] and origin == ORIGIN_SPELL then
			local now = os.time()
			local lastSmite = attacker:getStorageValue(PlayerStorage.braveSmiteCooldown)
			if lastSmite < 0 or (now - lastSmite) >= 9 then
				attacker:setStorageValue(PlayerStorage.braveSmiteCooldown, now)
				local healAmount = math.ceil(attacker:getMaxHealth() * 0.03)
				attacker:addHealth(healAmount)
				attacker:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
			end
		end

		-- [22] Concussive Blast: After next Basic Attack, deal 100(+7% Total HP) Magic Damage to nearby enemies. CD: 15s
		if attackerAttrs and attackerAttrs[22] and (origin == ORIGIN_MELEE or origin == ORIGIN_RANGED or origin == ORIGIN_WAND) then
			local now = os.time()
			local lastBlast = attacker:getStorageValue(PlayerStorage.concussiveBlastCooldown)
			if lastBlast < 0 or (now - lastBlast) >= 15 then
				attacker:setStorageValue(PlayerStorage.concussiveBlastCooldown, now)
				local blastDamage = 100 + math.floor(attacker:getMaxHealth() * 0.07)
				local center = creature:getPosition()
				center:sendMagicEffect(CONST_ME_EXPLOSIONAREA)
				local spectators = Game.getSpectators(center, false, false, 2, 2, 2, 2)
				for _, spec in ipairs(spectators) do
					if spec:isMonster() and not spec:isRemoved() then
						doTargetCombatHealth(attacker:getId(), spec:getId(), COMBAT_ENERGYDAMAGE, -blastDamage, -blastDamage, CONST_ME_ENERGYAREA, ORIGIN_CONDITION)
					end
				end
			end
		end

		-- [25] Weakness Finder: Basic Attacks slow enemies by 50% and reduce AS by 30%. Duration: 1s, CD: 10s (-1s per BA, down to 3s)
		if attackerAttrs and attackerAttrs[25] and (origin == ORIGIN_MELEE or origin == ORIGIN_RANGED or origin == ORIGIN_WAND) then
			local now = os.time()
			local readyTime = attacker:getStorageValue(PlayerStorage.weaknessFinderCooldown)
			if readyTime < 0 or now >= readyTime then
				attacker:setStorageValue(PlayerStorage.weaknessFinderCooldown, now + 10)
				local slow = math.ceil(creature:getSpeed() * 0.50)
				local paralyze = Condition(CONDITION_PARALYZE)
				paralyze:setParameter(CONDITION_PARAM_TICKS, 1000)
				paralyze:setParameter(CONDITION_PARAM_SPEED, -slow)
				paralyze:setParameter(CONDITION_PARAM_SUBID, 3261)
				creature:addCondition(paralyze)
				creature:addBuff(WEAKNESS_FINDER_DEBUFF, 1000)
				creature:getPosition():sendMagicEffect(CONST_ME_POISONAREA)
			else
				local remaining = readyTime - now
				if remaining > 3 then
					local newReady = math.max(readyTime - 1, now + 3)
					attacker:setStorageValue(PlayerStorage.weaknessFinderCooldown, newReady)
				end
			end
		end

		-- [31] Carve & Fervor (Black Cleaver): On physical hit apply Carve stack to enemy and gain Fervor speed buff
		if attackerAttrs and attackerAttrs[31] and primaryType == COMBAT_PHYSICALDAMAGE then
			creature:addBuff(CARVE_DEBUFF, 6000)
			attacker:addBuff(FERVOR_BUFF, 2000)
			local speedCond = Condition(CONDITION_HASTE)
			speedCond:setParameter(CONDITION_PARAM_TICKS, 2000)
			speedCond:setParameter(CONDITION_PARAM_SPEED, 20)
			speedCond:setParameter(CONDITION_PARAM_SUBID, 3262)
			attacker:addCondition(speedCond)
		end

		-- [34] Spellblade (Sheen / Trinity Force): Next basic attack deals bonus physical damage after casting an ability
		if attackerAttrs and attackerAttrs[34] and (origin == ORIGIN_MELEE or origin == ORIGIN_RANGED or origin == ORIGIN_WAND or primaryType == COMBAT_PHYSICALDAMAGE) then
			local now = os.time()
			local procUntil = attacker:getStorageValue(PlayerStorage.spellbladeProc)
			if procUntil > 0 and now <= procUntil then
				local cdReady = attacker:getStorageValue(PlayerStorage.spellbladeCooldown)
				if cdReady < 0 or now >= cdReady then
					attacker:setStorageValue(PlayerStorage.spellbladeProc, 0)
					attacker:setStorageValue(PlayerStorage.spellbladeCooldown, now + 2)
					attacker:removeBuff(SPELLBLADE_BUFF)
					local bonusRatio = (attackerAttrs[34].value or 200) / 100
					local baseAd = attacker:getPhysicalAttack()
					local spellbladeDmg = math.ceil(baseAd * bonusRatio)
					primaryDamage = primaryDamage + spellbladeDmg
					creature:getPosition():sendMagicEffect(CONST_ME_HITAREA)
				end
			end
		end

		-- [35] Quicken (Hearthbound Axe / Trinity Force): Basic attacks on-hit grant +20 Movement Speed for 2 seconds
		if attackerAttrs and attackerAttrs[35] and (origin == ORIGIN_MELEE or origin == ORIGIN_RANGED or origin == ORIGIN_WAND or primaryType == COMBAT_PHYSICALDAMAGE) then
			local speedCond = Condition(CONDITION_HASTE)
			speedCond:setParameter(CONDITION_PARAM_TICKS, 2000)
			speedCond:setParameter(CONDITION_PARAM_SPEED, attackerAttrs[35].value or 20)
			speedCond:setParameter(CONDITION_PARAM_SUBID, 3264)
			attacker:addCondition(speedCond)
			attacker:addBuff(QUICKEN_BUFF, 2000)
		end

		-- =====================================================================
		-- EFEKTY PASYWNE, CHAMPIONI I NAKŁADANIE DOT-ÓW (PO PRZELICZENIU OBRONY)
		-- =====================================================================
		
		-- Przykład ogólnego podpalenia (pomniejszonego o obronę celu targetDefMult):
		--[[
		local totalDotDamage = creature:getMaxHealth() * 0.02
		local totalTicks = 4
		local damagePerTick = math.max(1, math.ceil((totalDotDamage * targetDefMult) / totalTicks))
		creature:applyDot(attacker, {
			buffId = IGNITE_ITEM,
			damage = damagePerTick,
			duration = 4000,
			combatType = COMBAT_ENERGYDAMAGE,
			mode = "refresh",
			maxStacks = 5,
			initialTick = true,
			interval = 1000,
			effect = 16
		})
		--]]

		local appliedDotSummary = nil

		-- Champion: Juki (Vocation 3) - nakłada Burn
		if attacker:getVocation():getId() == 1 then
			local targetMaxHp = creature:getMaxHealth()
			if creature:isMonster() and (creature:getName():lower():find("dummy") or targetMaxHp > 10000000) then
				targetMaxHp = math.max(1000, attacker:getMagicAttack() * 20)
			end
			local totalDotDamage = math.max(10, math.floor(targetMaxHp * 0.02))
			local totalTicks = 4
			local dmgPerTick = math.max(1, math.ceil((totalDotDamage * targetDefMult) / totalTicks))
			local sumDotDamage = dmgPerTick * totalTicks

			creature:applyDot(attacker, {
				buffId = JUKI_BURN,
				damage = dmgPerTick,
				duration = 4000,
				combatType = COMBAT_FIREDAMAGE,
				mode = "refresh",
				maxStacks = 5,
				initialTick = true,
				interval = 1000,
				effect = 16
			})
			if creature.setShader then
				creature:setShader("Burn", 4)
			end

			appliedDotSummary = string.format("DoT: +%d Burn (4s, %d/tick)", sumDotDamage, dmgPerTick)
		end

		-- =====================================================================
		-- LIFESTEAL (Physical & Magic Lifesteal with 1/3 AoE penalty)
		-- =====================================================================
		local lifestealPercent = 0
		if primaryType == COMBAT_PHYSICALDAMAGE then
			lifestealPercent = attacker:getPhysicalSteal()
		else
			lifestealPercent = attacker:getMagicSteal()
		end

		local isAoE = false
		if origin == ORIGIN_SPELL or origin == ORIGIN_AUTOCAST then
			local spellCfg = nil
			if spellUID and type(spellUID) == "number" then
				spellCfg = GLOBAL_SPELL_COOLDOWNS[spellUID]
				if not spellCfg and SPELL_CACHE and SPELL_CACHE[spellUID] then
					local cached = SPELL_CACHE[spellUID]
					local sid = cached.spellId or (cached.config and cached.config.spellId)
					if sid then
						spellCfg = GLOBAL_SPELL_COOLDOWNS[sid]
					end
				end
			end

			if spellCfg and spellCfg.aoe ~= nil then
				isAoE = (spellCfg.aoe == true)
			else
				isAoE = true -- domyślnie dla czarów bez podanego spellUID
			end
		end

		local lifestealHeal = 0
		local ichorShieldGain = 0
		if lifestealPercent > 0 and primaryDamage > 0 then
			local aoeMultiplier = isAoE and (1.0 / 3.0) or 1.0
			local rawHeal = (primaryDamage * (lifestealPercent / 100)) * aoeMultiplier
			lifestealHeal = math.max(1, math.floor(rawHeal + 0.5))

			if lifestealHeal > 0 then
				local curHp = attacker:getHealth()
				local maxHp = attacker:getMaxHealth()
				if (curHp + lifestealHeal) > maxHp and attackerAttrs and attackerAttrs[32] and primaryType == COMBAT_PHYSICALDAMAGE then
					local overheal = (curHp + lifestealHeal) - maxHp
					local maxShieldCap = math.floor(maxHp * 0.10)
					local curShield = attacker:getEnergyShield()
					local newShield = math.min(maxShieldCap, curShield + overheal)

					if newShield > curShield then
						ichorShieldGain = newShield - curShield
						if attacker:getMaxEnergyShield() < newShield then
							attacker:setMaxEnergyShield(newShield)
						end
						attacker:setEnergyShield(newShield)
						attacker:addBuff(ICHOR_SHIELD, 10000)
						attacker:getPosition():sendMagicEffect(CONST_ME_MAGIC_RED)

						-- Update expiration timestamp
						attacker:setStorageValue(PlayerStorage.ichorShieldTime, os.time() + 10)

						-- Spawn only 1 timer per player if not already active
						if attacker:getStorageValue(PlayerStorage.ichorShieldAmount) ~= 1 then
							attacker:setStorageValue(PlayerStorage.ichorShieldAmount, 1)
							addEvent(checkIchorShieldDecay, 10000, attacker:getId())
						end
					end
				end
				attacker:addHealth(lifestealHeal)
				attacker:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
			end
		end

		-- =====================================================================
		-- DAMAGE LOG (English / Abbreviations / No diacritics / Togglable)
		-- =====================================================================
		local sourceStr = "OTHER"
		if origin == ORIGIN_MELEE or origin == ORIGIN_RANGED or origin == ORIGIN_WAND then
			sourceStr = "AA"
		elseif origin == ORIGIN_SPELL or origin == ORIGIN_AUTOCAST then
			sourceStr = "SPELL"
		elseif origin == ORIGIN_CONDITION or origin == ORIGIN_DOT then
			sourceStr = "DOT"
		end

		local dmgTypeStr = (primaryType == COMBAT_PHYSICALDAMAGE) and "Phys" or "Magic"
		local dotSuffix = appliedDotSummary and (" | " .. appliedDotSummary) or ""
		local lsSuffix = ""
		if lifestealHeal > 0 then
			if isAoE then
				lsSuffix = string.format(" | LS: +%d HP (1/3 AoE)", lifestealHeal)
			else
				lsSuffix = string.format(" | LS: +%d HP", lifestealHeal)
			end
			if ichorShieldGain > 0 then
				lsSuffix = lsSuffix .. string.format(" [Shield: +%d]", ichorShieldGain)
			end
		end

		-- Log Outgoing Damage (Attacker Player)
		if attacker:getStorageValue(PlayerStorage.damageLog) ~= -1 then
			local shredPct = math.floor((1.0 - defShredMultiplier) * 100 + 0.5)
			local defStr = (shredPct > 0)
				and string.format("Def: %d (-%.1f%% Redu) [Shred: -%d%% (Base: %d)]", rawDef, rawReductionPct, shredPct, baseTargetDef)
				or string.format("Def: %d (-%.1f%% Redu)", rawDef, rawReductionPct)

			local logMsg = string.format(
				"[DMG] [%s] Target: %s | Base: %d (%s) | %s | Pen: %d -> Eff.Def: %d (-%.1f%% Redu) | Pen Gain: +%d (+%.1f%%) | Final: %d%s%s",
				sourceStr, creature:getName(), baseDmgBeforeDef, dmgTypeStr, defStr, penetration, effectiveDef, effectiveReductionPct, penGain, penGainPct, primaryDamage, dotSuffix, lsSuffix
			)
			print(logMsg)
			attacker:sendTextMessage(MESSAGE_STATUS_CONSOLE_ORANGE, logMsg)
		end

		-- Log Incoming Damage (Target Player in PvP)
		if creature:isPlayer() and creature:getStorageValue(PlayerStorage.damageLog) ~= -1 then
			local takenMsg = string.format(
				"[TAKEN] [%s] From: %s | Base: %d (%s) | Your Def: %d (-%.1f%%) | Pen: %d -> Eff.Def: %d (-%.1f%%) | Final Taken: %d",
				sourceStr, attacker:getName(), baseDmgBeforeDef, dmgTypeStr, rawDef, rawReductionPct, penetration, effectiveDef, effectiveReductionPct, primaryDamage
			)
			print(takenMsg)
			creature:sendTextMessage(MESSAGE_STATUS_CONSOLE_ORANGE, takenMsg)
		end
		
	end
	-- GRACZ CEL PLAYER VS MONSTER
	if creature:isPlayer() and attacker:isMonster() then -- atakuje cie potwor ZWIEKSZANIE OBRAZEN MOBOW
		local monster_damage_bonus = 0
		if attacker:getType():tier() then
			local monsterTier = attacker:getType():tier()
			primaryDamage = MONSTER_CONFIG[monsterTier].damage
			local skull = attacker:getSkull()
			if skull == 7 then -- Elite (+15% damage)
				monster_damage_bonus = monster_damage_bonus + 15
			elseif skull == 8 then -- Champion (+100% damage)
				monster_damage_bonus = monster_damage_bonus + 100
			elseif skull > 8 then
				monster_damage_bonus = monster_damage_bonus + 20
			end
		end
		if monster_damage_bonus > 0 then
			primaryDamage = primaryDamage + ((primaryDamage * monster_damage_bonus) / 100)
		end
		-- [25] Weakness Finder: reduces monster attack power/speed by 30%
		if attacker:hasBuff(WEAKNESS_FINDER_DEBUFF) then
			primaryDamage = math.ceil(primaryDamage * 0.70)
		end

		local dmgBeforeDef = primaryDamage
		local defPercent = 0
		local physical_defense = creature:getPhysicalDefensePercent()
		local magic_defense = creature:getMagicDefensePercent()
		if primaryType == COMBAT_PHYSICALDAMAGE and physical_defense > 0 then
			defPercent = physical_defense
			primaryDamage = primaryDamage - (primaryDamage * physical_defense / 100)
		elseif primaryType ~= COMBAT_PHYSICALDAMAGE and magic_defense > 0 then
			defPercent = magic_defense
			primaryDamage = primaryDamage - (primaryDamage * magic_defense / 100)
		end

		primaryDamage = math.ceil(primaryDamage)

		-- Log Damage Taken from Monster
		if creature:getStorageValue(PlayerStorage.damageLog) ~= -1 then
			local dmgTypeStr = (primaryType == COMBAT_PHYSICALDAMAGE) and "Phys" or "Magic"
			local takenMsg = string.format(
				"[TAKEN] From: %s | Base: %d (%s) | Your Def: %.1f%% | Final Taken: %d",
				attacker:getName(), dmgBeforeDef, dmgTypeStr, defPercent, primaryDamage
			)
			print(takenMsg)
			creature:sendTextMessage(MESSAGE_STATUS_CONSOLE_ORANGE, takenMsg)
		end
	end

	if isNegative then
		primaryDamage = -math.abs(primaryDamage)
	end

	return primaryDamage, primaryType, secondaryDamage, secondaryType
end