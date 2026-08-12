function onDeath(creature, corpse, killer, mostDamage, unjustified, mostDamage_unjustified)
	if creature:getStorageValue(PlayerStorage.riftMonster_plus) == 1 then -- plus fragments
		local tier = creature:getType():tier()
		local increaseChance = tier * 25
		randomFragments(killer, corpse, increaseChance)
	end
	if creature:getStorageValue(PlayerStorage.riftMonster_plus) == 2 then -- plus runes
		randomSpellRune(killer, corpse, 33000, 5000, 200)
	end
	if creature:getStorageValue(PlayerStorage.riftMonster_plus) == 4 then -- plus EPIC+ items
		addTierItem(killer, creature, 2, 1, creature:getType():tier(), false, true, corpse, true)
	end

	if creature:getStorageValue(PlayerStorage.riftBoss) < 0 then return true end
	local damageMeter = {}
	if creature then
		local damageMap = creature:getDamageMap()
		for id, damage in pairs(damageMap) do
			local cel = Player(id)
			if cel then
				local bossHP = creature:getMaxHealth()
				local damageDeal = damage.total
				local damageDealPercentage = damageDeal / bossHP * 100
				damageMeter[cel:getId()] = { name = cel:getName(), damagePercent = damageDealPercentage, damageValue = damageDeal }
			end
		end
	end
	local creatruresPLAYER = Game.getSpectators(corpse:getPosition(), false, false, 10, 10, 10, 10)
	for _, player in pairs(creatruresPLAYER) do
		if Player(player:getId()) then
			Position(player:getPosition()):sendMagicEffect(CONST_ME_POFF)
			player:setStorageValue(PlayerStorage.riftReward, -1)
			local globalLoot = 1
			if getGlobalBuff(BUFF_GLOBAL_LOOT) then
				globalLoot = globalLoot + 0.5
			end
			-------------------------------------------		
			for id, value in pairs(damageMeter) do
				if id == player:getId() and value.damagePercent >= 5 then
					if creature:getStorageValue(PlayerStorage.riftBoss) == 1 then
						local tier = creature:getType():tier()
						math.randomseed(os.time())
						local increaseChance = tier * 20
						addTierItem(player, creature, 2, 1, tier, false, true, corpse, true)
						randomPotionLoot(player, corpse, 30000, 8000, 8000, 700)
						currencyDrop(player, corpse, increaseChance)
						randomFragments(player, corpse, increaseChance)
						if math.random(100000) <= 10000 then
							randomSpellRune(player, corpse, 10000, 4000, 200)
						end
						if math.random(100000) <= 4000 then
							randomSupportRune(player, corpse, 3500, 2000, 100)
						end
						corpse:addItem(24850, 1 + tier, INDEX_WHEREEVER, FLAG_NOLIMIT)
						corpse:addItem(21250, 1 + tier, INDEX_WHEREEVER, FLAG_NOLIMIT)
					end
				end
			end
			------------------------------------------					
		end
	end
end
