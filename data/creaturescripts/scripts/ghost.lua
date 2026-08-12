function onThink(creature, interval)
	if creature then
		if creature:getStorageValue(PlayerStorage.intervalBonus) >= os.time() then
		else
			creature:addBuff(GHOST)
			creature:getPosition():sendMagicEffect(100)
			creature:setStorageValue(PlayerStorage.intervalBonus, os.time() + 5)
			local conditionOutfit = Condition(CONDITION_OUTFIT)
			conditionOutfit:setTicks(3000)
			conditionOutfit:setOutfit({lookType = 48, lookHealthBar = 2, lookManaBar = 1}) 
			creature:addCondition(conditionOutfit)
		end
	end
	return true
end
