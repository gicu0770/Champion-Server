local config = {
	['vampire queen'] = {items = {26157, 28823}, items2 = {26179}, chance2 = {15}, itemsUnique = TIER_1_IDS, gold = 10000, tier = 1},	-- energy soul orb
} 
function onDeath(creature, corpse, killer, mostDamage, unjustified, mostDamage_unjustified)
	local monster = config[creature:getName():lower()]
    if not creature or creature:isPlayer() or not monster or creature:getMaster() then
        return true
    end
	if not creature:isMonster() then return true end
		if corpse and corpse:isContainer() or not corpse.itemid == 0 then
			local difficulty = 1
				local dungeon = killer:getDungeon()
				if dungeon then
				local instance = dungeon:getPlayerInstance(killer)
					if instance then
					local runners = instance:getRunners()
						for _, runner in ipairs(runners) do
					local bag = Game.createItem(28901, 1)
					local inbox = runner:getInbox()
					local mType = creature:getType()
					local difficultyProphyLoot = {0, 1, 2, 3, 4, 5}
					local difficultyBadged = {1, 2, 4, 7, 14, 25}
					local globalLoot = 1
					local difficultyLoot = {0, 10, 20, 30, 50, 75}
					local difficultyRarityChance = {1.0, 1.15, 1.5, 2.0, 3.0, 5.0}

				local damageMeter = {}
				if creature then
				 local damageMap = creature:getDamageMap()
				 for id, damage in pairs(damageMap) do
				  local player = Player(id)
				  if player then
				  local bossHP = creature:getMaxHealth()
				  local damageDeal = damage.total
				  local damageDealPercentage = damageDeal / bossHP * 100
				  damageMeter[id] = {name = player:getName(), damagePercent = damageDealPercentage, damageValue = damageDeal}
				  end
				 end
				end
					DUNGEON_TIER = {
						["Queen Lair"] = {tier = 1},
						["Galaxy"] = {tier = 2},
					}




						if damageMeter[runner:getId()] then
							if damageMeter[runner:getId()].damagePercent >= 5 then
								local cor = bag:getItems()
								local loot = {}
								local lootedItems = {}
								local outfit = creature:getOutfit()
								local name = creature:getName()
								local monsterId = creature:getId()
								for _, item in ipairs(cor) do
									local uid = item:getRealUID() == 0 and item:getId() or item:getRealUID()
									local item_data = {
										c = item:getCount(),
										i = item:getId(),
										ci = item:getType():getClientId(),
										u = item:getRealUID(),
										r = item:getRarityId(),
									}
									table.insert(loot, item_data)
								end
								if not bag:moveTo(runner:getSlotItem(CONST_SLOT_BACKPACK)) then
									inbox:addItemEx(bag, INDEX_WHEREEVER, FLAG_NOLIMIT)
								end
								sendLoot(runner, loot, monsterId)
								if #loot ~= 0 then
									sendCreatureCorpse(runner, outfit, monsterId, name)
									sendLoot(runner, loot, monsterId)
								end
							else
								runner:sendTextMessage(MESSAGE_INFO_DESCR, "You didn't deal 5% of damage to the boss and didn't receive the reward!")
							end
						end
						end
					end
				end					
	end
	return true
end