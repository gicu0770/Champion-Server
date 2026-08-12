function onHealthChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
  if creature == attacker then
    return primaryDamage, primaryType, secondaryDamage, secondaryType
  end
	--If its a field or damage over time
	if Tile(creature:getPosition()):hasFlag(TILESTATE_MAGICFIELD) == TRUE or attacker == nil then
		return primaryDamage, primaryType, secondaryDamage, secondaryType	
	end

	--If its not a player or monster attacking
	if not attacker:isPlayer() and not attacker:isMonster() then
		return primaryDamage, primaryType, secondaryDamage, secondaryType		
	end

if creature:isPlayer() then ------------------ODBIJANIE OBRAZEN
	local reflect = creature:getEffectiveSkillLevel(SKILL_REF)
	if reflect > math.random(100) then
	local damageRef = (creature:getEffectiveSkillLevel(SKILL_REFD) * primaryDamage) / 100
			local pos = creature:getPosition()
			Game.sendAnimatedText('REFLECT', pos, 205)
	doTargetCombat(creature, attacker, primaryType, damageRef, damageRef, secondaryType)
	creature:getPosition():sendDistanceEffect(attacker:getPosition(), 41)
	attacker:getPosition():sendMagicEffect(4)
	end
end
	
	local dodge = false
	--Calculate DODGE chance of players
	if creature:isPlayer() then
	local dodgeChance = creature:getEffectiveSkillLevel(SKILL_DODGE)
		if dodgeChance > math.random(100) then			
			dodge = true
			local pos = creature:getPosition()
			Game.sendAnimatedText('DODGE', pos, 129)
--			--creature:say("DODGE", TALKTYPE_MONSTER_SAY)
		end
	end
	


	--If dodged
	if dodge then
		return primaryDamage - primaryDamage, primaryType, secondaryDamage - secondaryDamage, secondaryType
	end
		
		--Normal damage
		return primaryDamage, primaryType, secondaryDamage, secondaryType		
	end


function onManaChange(creature, attacker, manaChange, origin)
--If its a field or damage over time
	if Tile(creature:getPosition()):hasFlag(TILESTATE_MAGICFIELD) == TRUE or attacker == nil then
		return manaChange
	end
	
	 if creature:isPlayer() and manaChange == COMBAT_HEALING then
	 return manaChange
	 end
	
if creature:isPlayer() then ------------------ODBIJANIE OBRAZEN
	local reflect = creature:getEffectiveSkillLevel(SKILL_REF)
	if reflect > math.random(100) then
	local damageRef = (creature:getEffectiveSkillLevel(SKILL_REFD) * manaChange) / 100
			local pos = creature:getPosition()
			Game.sendAnimatedText('REFLECT', pos, 205)
	doTargetCombat(creature, attacker, primaryType, -damageRef, -damageRef, secondaryType)
	creature:getPosition():sendDistanceEffect(attacker:getPosition(), 41)
	attacker:getPosition():sendMagicEffect(4)
	end
end
	
	local dodge = false
	--Calculate DODGE chance of players
	if creature:isPlayer() then
	local dodgeChance = creature:getEffectiveSkillLevel(SKILL_DODGE)
		if dodgeChance > math.random(100) then			
			dodge = true
			local pos = creature:getPosition()
			Game.sendAnimatedText('DODGE', pos, 129)
			--creature:say("DODGE", TALKTYPE_MONSTER_SAY)
		end
	end

	--If dodged
	if dodge then
	manaChange = 0
		return manaChange
	end

	
    return manaChange
end