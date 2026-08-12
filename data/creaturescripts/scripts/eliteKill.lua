function onKill(creature, target)
	local targetPosition = target:getPosition()

	local function explosionMonster(cid, tar)
		local creature = Player(cid)
		if creature then
			exoriEffect(tar, CONST_ME_FIREAREA)
			local specs = Game.getSpectators(tar, false, false, 1, 1, 1, 1)
			if #specs > 0 then
				for i = 1, #specs do
					if specs[i]:isPlayer() then
						local damage = specs[i]:getMaxHealth() * 0.75
					--	doTargetCombatHealth(0, specs[i]:getId(), COMBAT_LIFEDRAIN, -damage, -damage, CONST_ME_NONE, ORIGIN_CONDITION)
						specs[i]:addHealth(-damage)
					end
				end
			end
		end
	end

	local function explosionForzenMonster(cid, tar)
		local creature = Player(cid)
		if creature then
			exoriEffect(tar, 212)
			local specs = Game.getSpectators(tar, false, false, 1, 1, 1, 1)
			if #specs > 0 then
				for i = 1, #specs do
					if specs[i]:isPlayer() then
						-- Stun
						local stun = Condition(CONDITION_STUN)
						stun:setParameter(CONDITION_PARAM_TICKS, 3000)
						specs[i]:addCondition(stun)
						local damage = specs[i]:getMaxHealth() * 0.33
					--	doTargetCombatHealth(0, specs[i]:getId(), COMBAT_LIFEDRAIN, -damage, -damage, CONST_ME_NONE,ORIGIN_CONDITION)
						specs[i]:addHealth(-damage)
					end
				end
			end
		end
	end

	if target:isMonster() then
		local skull = target:getSkull()
		if creature:getStorageValue(PlayerStorage.AFKrooms) >= 1 then
			return false
		end
		if skull == 12 then --- explosion
			addEvent(explosionMonster, 2000, creature:getId(), target:getPosition())
			exoriEffect(targetPosition, 234)
			for i = 1, 2 do
				local timeEE = 2 - i
				addEvent(function(targetPosition) exoriEffect(targetPosition, 234) end, i * 1000, targetPosition)
			end
		elseif skull == 11 then --	frozen
			addEvent(explosionForzenMonster, 2000, creature:getId(), target:getPosition())
			exoriEffect(targetPosition, 201)
			for i = 1, 2 do
				local timeEE = 2 - i
				addEvent(function(targetPosition) exoriEffect(targetPosition, 201) end, i * 1000, targetPosition)
			end
		end
	end

	return true
end
