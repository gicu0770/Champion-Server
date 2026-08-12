local function isBadTile(tile)
	return (tile == nil or tile:getGround() == nil or tile:hasProperty(TILESTATE_NONE) or tile:hasProperty(TILESTATE_FLOORCHANGE_EAST) or
		isItem(tile:getThing()) and not isMoveable(tile:getThing()) or
		-- tile:getTopCreature() or
		tile:hasFlag(TILESTATE_PROTECTIONZONE))
end

function onHealthChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
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
	return affix_onDamaged(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
end

function onManaChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
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

	return affix_onDamaged(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
end

function affix_onDamaged(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
	if attacker:isPlayer() then
		local skull = creature:getSkull()
		local primalTotal = 0
		local originalDamage = primaryDamage
		if skull >= 7 then -- Increase DAMAGE REDUCED ALL elite
			primalTotal = primalTotal + 30
		end
		if skull == 7 then -- REDUCED DAMAGE
			if primaryType == COMBAT_PHYSICALDAMAGE then
				primalTotal = primalTotal + 50
			end
		elseif skull == 27 then -- veterna
			primalTotal = primalTotal + 50
		elseif skull == 8 then -- REFLECT DAMAGE
			if attacker then
				local damage = attacker:getMaxHealth() * 0.1
				if attacker:hasBuff(RESTART_IMMORTAL) or attacker:hasBuff(KNIGHT_PROTECTOR) or attacker:hasBuff(FREEZ) or attacker:hasBuff(CRYO_FORM) or attacker:hasBuff(GHOST) then
					damage = 0
				end
				if attacker:hasBuff(PERMA_UTAMA) and attacker:getMana() >= attacker:getMaxMana() * 0.05 then
					damage = attacker:getMaxMana() * 0.1
					attacker:addMana(-damage, true)
				else
					doTargetCombat(creature:getId(), attacker:getId(), COMBAT_LIFEDRAIN, -damage, -damage, CONST_ME_NONE)
				end
			end
			creature:getPosition():sendDistanceEffect(attacker:getPosition(), 41)
		elseif skull == 17 then -- Electrified	COMBAT_ENERGYDAMAGE
			electroShoced(creature:getPosition(), 1491, 3000)
			if attacker then
				local damage = attacker:getMaxHealth() * 0.05
				if attacker:hasBuff(RESTART_IMMORTAL) or attacker:hasBuff(GHOST) then
					damage = 0
				end
				if attacker:hasBuff(PERMA_UTAMA) then
					if attacker:getMana() >= attacker:getMaxMana() * 0.05 then
						damage = attacker:getMaxMana() * 0.05
						attacker:addMana(-damage, true)
					end
				else
					doTargetCombat(creature:getId(), attacker:getId(), COMBAT_LIFEDRAIN, -damage, -damage, CONST_ME_NONE)
				end
			end
		elseif skull == 13 then -- plagued
			if math.random(1, 100) <= 100 then
				attacker:getPosition():sendMagicEffect(9)
				exoriCreateItem(attacker:getPosition(), 1490, 10000)
				if attacker then
					local damage = attacker:getMaxHealth() * 0.05
					if attacker:hasBuff(RESTART_IMMORTAL) or attacker:hasBuff(GHOST) then
						damage = 0
					end
					if attacker:hasBuff(PERMA_UTAMA) and attacker:getMana() >= attacker:getMaxMana() * 0.05 then
						damage = attacker:getMaxMana() * 0.05
						attacker:addMana(-damage, true)
					else
						doTargetCombat(creature:getId(), attacker:getId(), COMBAT_LIFEDRAIN, -damage, -damage,
							CONST_ME_NONE)
					end
				end
			end
		elseif skull == 20 then -- dodger 50% na dodge
			if math.random(100) <= 50 then
				if origin == ORIGIN_RANGED or origin == ORIGIN_MELEE or origin == ORIGIN_WAND then
					primaryDamage = 0
					secondaryDamage = 0
					Game.sendAnimatedText('Dodge', creature:getPosition(), 129)
					creature:getPosition():sendMagicEffect(3)
				end
			end
		elseif skull == 21 then -- anti magic
			if primaryType ~= COMBAT_PHYSICALDAMAGE then
				primalTotal = primalTotal + 50
			end
		end
		if primaryDamage < 0 then
			primaryDamage = math.floor(primaryDamage - (primaryDamage * primalTotal / 100))
		end
		---END attack:isPlayer() -- celem jest elite monster

		if attacker:getStorageValue(PlayerStorage.damageInfo) == 1 then
			if attacker:isPlayer() then
				if attacker:openChannel(17) then
					if origin == ORIGIN_RANGED or origin == ORIGIN_MELEE or origin == ORIGIN_WAND then
						if primaryType == COMBAT_PHYSICALDAMAGE then
							if primalTotal > 0 then
								attacker:sendChannelMessage("","Start: "..originalDamage.." Monster Damage Reduction: +" ..primalTotal .. "% [" .. primaryDamage .. "]", TALKTYPE_CHANNEL_Y, 17)
							end
						else
							if primalTotal > 0 then
								attacker:sendChannelMessage("","Start: "..originalDamage.." Monster Damage Reduction: +" ..primalTotal .. "% [" .. primaryDamage .. "]", TALKTYPE_CHANNEL_Y, 17)
							end
						end
					end
					if origin == ORIGIN_SPELL or origin == ORIGIN_DOT then
						if primaryType == COMBAT_PHYSICALDAMAGE then
							if primalTotal > 0 then
								attacker:sendChannelMessage("","Start: "..originalDamage.." Monster Damage Reduction: +" ..primalTotal .. "% [" .. primaryDamage .. "]", TALKTYPE_CHANNEL_Y, 17)
							end
						else
							if primalTotal > 0 then
								attacker:sendChannelMessage("","Start: "..originalDamage.." Monster Damage Reduction: +" ..primalTotal .. "% [" .. primaryDamage .. "]", TALKTYPE_CHANNEL_Y, 17)
							end
						end
					end
				end
			end
		end

	end

	if creature:isPlayer() then
		local skull = attacker:getSkull()
		local primalTotal = 0
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
		elseif skull == 13 then -- plagued
			if math.random(1, 100) <= 100 then
				creature:getPosition():sendMagicEffect(9)
				exoriCreateItem(creature:getPosition(), 1490, 10000)
				if creature then
					local damage = creature:getMaxHealth() * 0.05
					if creature:hasBuff(RESTART_IMMORTAL) or creature:hasBuff(GHOST) then
						damage = 0
					end
					if creature:hasBuff(PERMA_UTAMA) and creature:getMana() >= creature:getMaxMana() * 0.05 then
						damage = creature:getMaxMana() * 0.05
						creature:addMana(-damage, true)
					else
						doTargetCombat(attacker:getId(), creature:getId(), COMBAT_LIFEDRAIN, -damage, -damage,CONST_ME_NONE)
					end
				end
			end
		elseif skull == 16 then -- vampiric
			local healHit = primaryDamage
			if healHit < 0 then
				healHit = healHit * -1
			end
			if MonsterType(attacker:getName()):getRace() == 6 then -- increase damage to boss
				healHit = healHit / 3
			end
			attacker:addHealth(healHit, true)
		elseif skull == 18 then -- pusher - stunner
			if creature:getStorageValue(PlayerStorage.AFKrooms) < 1 then
				if attacker and attacker:isMonster() then
					local target = attacker:getTarget()
					if target and math.random(100) <= 30 then
						local stun = Condition(CONDITION_STUN)
						stun:setParameter(CONDITION_PARAM_TICKS, 500)
						target:addCondition(stun)
						target:getPosition():sendMagicEffect(178)
					end
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
			creature:startDOT(attacker, ELITE_DOT, 0.03, true, 5000)
			---END affixy przy ataku
		end

		if primaryDamage < 0 then
			primaryDamage = math.floor(primaryDamage + (primaryDamage * primalTotal / 100))
		end
		---END creature:isPlayer() celem jest gracz
	end
	if creature:isPlayer() and attacker:isMonster() then
		if creature:hasBuff(PERMA_UTAMA) then
			local leftMana = creature:getMana() + primaryDamage
			creature:addMana(primaryDamage, true)
			if leftMana < 0 then
				primaryDamage = leftMana
			else
				primaryDamage = 0
			end
		end
	end
	return primaryDamage, primaryType, secondaryDamage, secondaryType, origin
end