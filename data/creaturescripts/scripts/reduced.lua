function onHealthChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
	if not creature then return primaryDamage, primaryType, secondaryDamage, secondaryType end
	if not attacker then return primaryDamage, primaryType, secondaryDamage, secondaryType end

	if attacker:isPlayer() then
		if attacker:getStorageValue(PlayerStorage.msParty) - os.time() >= 0 then
			if primaryDamage < 0 then
				primaryDamage = math.floor(primaryDamage + (primaryDamage * 10 / 100))
			end
			if secondaryDamage < 0 then
				secondaryDamage = math.floor(secondaryDamage + (secondaryDamage * 10 / 100))
			end
		end
	end
	if creature:isPlayer() then
		if creature:getStorageValue(PlayerStorage.ekParty) - os.time() >= 0 then
			if primaryDamage < 0 then
				primaryDamage = math.floor(primaryDamage - (primaryDamage * 10 / 100))
			end
			if secondaryDamage < 0 then
				secondaryDamage = math.floor(secondaryDamage - (secondaryDamage * 10 / 100))
			end
			if primaryType == COMBAT_MANADRAIN or secondaryType == COMBAT_MANADRAIN then
			if primaryDamage < 0 then
				primaryDamage = math.floor(primaryDamage - (primaryDamage * 10 / 100))
			end
			if secondaryDamage < 0 then
				secondaryDamage = math.floor(secondaryDamage - (secondaryDamage * 10 / 100))
			end
			end
		end
	end
	
	if creature:isPlayer() then
		if creature:getStorageValue(PlayerStorage.msPartyMana) - os.time() >= 0 then
		if primaryType == COMBAT_MANADRAIN or secondaryType == COMBAT_MANADRAIN or primaryType == COMBAT_LIFEDRAIN or secondaryType == COMBAT_LIFEDRAIN then
			if primaryDamage < 0 then
				primaryDamage = math.floor(primaryDamage - (primaryDamage * 30 / 100))
			end
			if secondaryDamage < 0 then
				secondaryDamage = math.floor(secondaryDamage - (secondaryDamage * 30 / 100))
			end
		end
	end
end
	
    return primaryDamage, primaryType, secondaryDamage, secondaryType
end

function onManaChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
	if not creature then return primaryDamage, primaryType, secondaryDamage, secondaryType end
	if not attacker then return primaryDamage, primaryType, secondaryDamage, secondaryType end
	
	if attacker:isPlayer() then
		if attacker:getStorageValue(PlayerStorage.msParty) - os.time() >= 0 then
			if primaryDamage > 0 then
				primaryDamage = math.floor(primaryDamage + (primaryDamage * 10 / 100))
			end
			if secondaryDamage > 0 then
				secondaryDamage = math.floor(secondaryDamage + (secondaryDamage * 10 / 100))
			end
		end
	end
	if creature:isPlayer() then
		if creature:getStorageValue(PlayerStorage.ekParty) - os.time() >= 0 then
			if primaryDamage > 0 then
				primaryDamage = math.floor(primaryDamage - (primaryDamage * 10 / 100))
			end
			if secondaryDamage > 0 then
				secondaryDamage = math.floor(secondaryDamage - (secondaryDamage * 10 / 100))
			end
			if primaryType == COMBAT_MANADRAIN or secondaryType == COMBAT_MANADRAIN or primaryType == COMBAT_LIFEDRAIN or secondaryType == COMBAT_LIFEDRAIN then
			if primaryDamage < 0 then
				primaryDamage = math.floor(primaryDamage - (primaryDamage * 10 / 100))
			end
			if secondaryDamage < 0 then
				secondaryDamage = math.floor(secondaryDamage - (secondaryDamage * 10 / 100))
			end
			end
		end
	end
	if creature:isPlayer() then
		if creature:getStorageValue(PlayerStorage.msPartyMana) - os.time() >= 0 then
		if primaryType == COMBAT_MANADRAIN or secondaryType == COMBAT_MANADRAIN then
			if primaryDamage < 0 then
				primaryDamage = math.floor(primaryDamage - (primaryDamage * 30 / 100))
			end
			if secondaryDamage < 0 then
				secondaryDamage = math.floor(secondaryDamage - (secondaryDamage * 30 / 100))
			end
		end
	end
end
    return primaryDamage, primaryType, secondaryDamage, secondaryType
end