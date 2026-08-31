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
			local skullVal = tonumber(split[3])
			if skullVal == 7 then
				monsterHP = math.ceil(monsterHP * 1.5)
			elseif skullVal == 8 then
				monsterHP = math.ceil(monsterHP * 2.5)
			else
				monsterHP = math.ceil(monsterHP * 2.5)
			end
			monster:setMaxHealth(monsterHP)
			monster:setHealth(monsterHP)
			monster:setSkull(skullVal)
			monster:setStorageValue(PlayerStorage.eliteAffixes, skullVal - 6)
			monster:registerEvent("EliteAffixHP")
			monster:registerEvent("BuffDeath")
			local outfit = monster:getOutfit()
			outfit.lookHealthBar = 2
			monster:setOutfit(outfit)
		end
	else
		player:sendCancelMessage("There is not enough room.")
		position:sendMagicEffect(CONST_ME_POFF)
	end

	return false
end


