function onHealthChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
	--If its a field or damage over time
	if Tile(creature:getPosition()):hasFlag(TILESTATE_MAGICFIELD) == TRUE or attacker == nil then
		return primaryDamage, primaryType, secondaryDamage, secondaryType	
	end

	--If its not a player or monster attacking
	if not attacker:isPlayer() and not attacker:isMonster() then
		return primaryDamage, primaryType, secondaryDamage, secondaryType
	end
	
	if creature:isMonster() and attacker:isPlayer() then
		local monsterLevel = creature:getMonsterLevel()
		local monsterGold = math.ceil(goldFormula(monsterLevel) / 2)
		if monsterGold <= 0 then monsterGold = 1 end
		attacker:setBankBalance(attacker:getBankBalance() + monsterGold)
		Game.sendAnimatedText("+"..monsterGold.." Gold!", creature:getPosition(), 210, "Reggae One-10px-bordered")
		sendGold(attacker, monsterGold)
		attacker:refreshBalance()
		creature:getPosition():sendMagicEffect(405)
	end

		return primaryDamage, primaryType, secondaryDamage, secondaryType
	end