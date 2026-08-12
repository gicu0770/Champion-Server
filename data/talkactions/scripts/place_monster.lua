function onSay(player, words, param)
	if not player:getGroup():getAccess() then
		return true
	end

	-- name,monsterLevel,Elite

	local split = param:splitTrimmed(",")

	local position = player:getPosition()
	local monster = Game.createMonster(split[1], position)
	local monsterHP = 1
	if monster then
		monster:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
		position:sendMagicEffect(CONST_ME_MAGIC_RED)
	--	if split[2] then
	--		monster:setDifficulty(split[2])
	--	end
		if split[2] then
			monster:setMonsterLevel(split[2])
			monsterHP = healthFormula(tonumber(split[2]))
			monster:setMaxHealth(monsterHP)
			monster:setHealth(monsterHP)
		end
		if split[3] then
			monsterHP = monsterHP * 2.5
            monster:setMaxHealth(monsterHP)
            monster:setHealth(monsterHP)
			if split[3] == 9 then
			monsterHP = monsterHP * 1.5
            monster:setMaxHealth(monsterHP)
            monster:setHealth(monsterHP)
			end
			if split[3] == 11 or split[3] == 12 then
			monster:registerEvent("EliteKill")
			end
			monster:setSkull(split[3])
			monster:setStorageValue(PlayerStorage.eliteAffixes, split[3] - 6)
			monster:registerEvent("EliteAffixHP")
			monster:registerEvent("EliteAffixMANA")
			if split[3] == 23 then
			local Chilling = Condition(CONDITION_HASTE)
			Chilling:setParameter(CONDITION_PARAM_TICKS, -1)
			Chilling:setParameter(CONDITION_PARAM_SPEED, 1000)
			monster:addCondition(Chilling)
			end
			if split[3] == 27 then
			monsterHP = monsterHP * 7
            monster:setMaxHealth(monsterHP)
            monster:setHealth(monsterHP)
			end
		end
	else
		player:sendCancelMessage("There is not enough room.")
		position:sendMagicEffect(CONST_ME_POFF)
	end

	return false
end


