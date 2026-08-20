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
	-- GRACZ ATAKUJE
	if attacker:isPlayer() then -- atakujacym jest gracz
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
		if creature:isMonster() then -- celem jest monster
			local physical_defense = MONSTER_CONFIG[creature:getType():tier()].physical_defense - physical_penetration
			local magic_defense = MONSTER_CONFIG[creature:getType():tier()].magic_defense - magic_penetration
			if primaryType == COMBAT_PHYSICALDAMAGE and physical_defense > 0 then
				primaryDamage = primaryDamage - (primaryDamage * physical_defense / 100)
			--	print("DMG redukcja physical "..primaryDamage.." ")
			elseif primaryType ~= COMBAT_PHYSICALDAMAGE and magic_defense > 0 then
				primaryDamage = primaryDamage - (primaryDamage * magic_defense / 100)
			--	print("DMG redukcja magic "..primaryDamage.." ")
			end
		end
		if creature:isPlayer() then -- celem jest PLAYER
			local physical_defense = creature:getPhysicalDefensePercent() - physical_penetration
			local magic_defense = creature:getMagicDefensePercent() - magic_penetration
			print("GRACZ DMG start "..primaryDamage.." ")
			if primaryType == COMBAT_PHYSICALDAMAGE and physical_defense > 0 then
				primaryDamage = primaryDamage - (primaryDamage * physical_defense / 100)
				print("GRACZ DMG redukcja physical "..primaryDamage.." ")
			elseif primaryType ~= COMBAT_PHYSICALDAMAGE and magic_defense > 0 then
				primaryDamage = primaryDamage - (primaryDamage * magic_defense / 100)
				print("GRACZ DMG redukcja magic "..primaryDamage.." ")
			end
--			if creature:getBuff(COURAGE) then -- Gorn
--				primaryDamage = primaryDamage * 0.70
--			end
			print("GRACZ DMG redukcja KONCOWA "..primaryDamage.." ")
		end
		--[[
		if origin == ORIGIN_SPELL and attacker:getVocation():getId() == 3 then -- Juki
			local damage = math.ceil(player_damage * 0.30 / 5)
			creature:startDOT(attacker, JUKI_BURN, -damage, false, 5000)
			creature:setShader("Burn", 5)
		end
		if attacker:getVocation():getId() == 1 then -- Mia
			local slow = 0
			if creature:isMonster() then
			  slow = ((creature:getSpeed() * 20) / 100)
			elseif creature:isPlayer() then
			  slow = ((creature:getBaseSpeed() * 20) / 100)
			end
			local Chilling = Condition(CONDITION_PARALYZE)
			Chilling:setParameter(CONDITION_PARAM_TICKS, 3000)
			Chilling:setParameter(CONDITION_PARAM_SPEED, -slow)
			creature:setShader("Chill", 3)
			creature:addBuff(CHILL)
			creature:addCondition(Chilling)
		end
		if attacker:getBuff(DECISIVE_STRIKE) then -- Gorn
			if origin == ORIGIN_MELEE or origin == ORIGIN_WAND or origin == ORIGIN_RANGED then
				creature:addBuff(SILENCE, 2500)
				local damage = primaryDamage * GLOBAL_SPELL_INFO["Gorn"]["Decisive Strike"].multipler[attacker:getStorageValue(PlayerStorage.spellQ)]
				doTargetCombatHealth(attacker:getId(), creature:getId(), COMBAT_PHYSICALDAMAGE, -damage, -damage, 1, ORIGIN_SPELL)
				creature:getPosition():sendMagicEffect(254)
				attacker:removeBuff(DECISIVE_STRIKE)
			end
		end
		if attacker:getBuff(HAWK_EYE) then -- Mia
			if origin == ORIGIN_MELEE or origin == ORIGIN_WAND or origin == ORIGIN_RANGED then
				local damage = primaryDamage * GLOBAL_SPELL_INFO["Mia"]["Ranger Focus"].multipler[attacker:getStorageValue(PlayerStorage.spellE)]
				for i = 1, 3 do
					local pos = Position(attacker:getPosition().x + math.random(-1,1), attacker:getPosition().y - math.random(-1,1), attacker:getPosition().z)
					pos:sendDistanceEffect(creature:getPosition(), 49)
					doTargetCombatHealth(attacker:getId(), creature:getId(), COMBAT_PHYSICALDAMAGE, -damage, -damage, 1, ORIGIN_SPELL)
				end
			end
		end
		--]]
		
	end
	-- GRACZ CEL PLAYER VS MONSTER
	if creature:isPlayer() and attacker:isMonster() then -- atakuje cie potwor ZWIEKSZANIE OBRAZEN MOBOW
		local monster_damage_bonus = 0
		if attacker:getType():tier() then
			local monsterTier = attacker:getType():tier()
			primaryDamage = MONSTER_CONFIG[monsterTier].damage
		--	print("Monster damage: "..primaryDamage.."")
			local skull = attacker:getSkull()
			if skull >= 7 then -- All Elite
				monster_damage_bonus = monster_damage_bonus + 20
			end
		end
		if monster_damage_bonus > 0 then
			primaryDamage = primaryDamage + ((primaryDamage * monster_damage_bonus) / 100)
		--	print("Monster damage boost ELITE: "..primaryDamage.."")
		end
		-- redukcja obrazen gracza kiedy jestes celem
		if creature:isPlayer() then -- celem jest PLAYER
			local physical_defense = creature:getPhysicalDefensePercent()
			local magic_defense = creature:getMagicDefensePercent()
			if primaryType == COMBAT_PHYSICALDAMAGE and physical_defense > 0 then
				primaryDamage = primaryDamage - (primaryDamage * physical_defense / 100)
		--		print("Monster redukcja physical "..primaryDamage.." ")
			elseif primaryType ~= COMBAT_PHYSICALDAMAGE and magic_defense > 0 then
				primaryDamage = primaryDamage - (primaryDamage * magic_defense / 100)
		--		print("Monster DMG redukcja magic "..primaryDamage.." ")
			end
		end
	end
	return primaryDamage, primaryType, secondaryDamage, secondaryType
end