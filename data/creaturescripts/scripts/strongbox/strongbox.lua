function onDeath(creature, corpse, killer, mostDamage, unjustified, mostDamage_unjustified)
	if not creature or not corpse then return true end
	if creature:getStorageValue(PlayerStorage.strongBoxMonsterBoss) < 0 then return true end
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
					if creature:getStorageValue(PlayerStorage.strongBoxMonsterBoss) == 1 then
						math.randomseed(os.time())
						local monsterLevel = creature:getMonsterLevel()
						if math.random(100) <= 30 then
							randomPotionLoot(player, corpse, 5000 + (5000 * monsterLevel / 100), 3000 + (3000 * monsterLevel / 100), monsterLevel, lootItems)
						end
						randomSupportRune(player, corpse, 3000 + (3000 * monsterLevel / 100), 1500 + (1500 * monsterLevel / 100), 150 + (150 * monsterLevel / 100), lootItems)
						randomSpellRune(player, corpse, 3000 + (3000 * monsterLevel / 100), 1500 + (1500 * monsterLevel / 100), 150 + (150 * monsterLevel / 100), lootItems)

						local description, items = "Congratulations, you defeated the strongbox Boss!\nYou rewards:\n", corpse:getItems()
						player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, description .. '')
					end
				end
			end
			------------------------------------------					
		end
	end
end
