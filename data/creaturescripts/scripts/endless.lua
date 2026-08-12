function onDeath(creature, corpse, killer, mostDamage, unjustified, mostDamage_unjustified)
    if creature:getName() == "Golden Goblin"
     or creature:getName() == "Golden Mummy"
     or creature:getName() == "Golden Dragon"
     or creature:getName() == "Golden Angel"
     or creature:getName() == "Corrupted Avenger"
     or creature:getName() == "Corrupted Evil"
     or creature:getName() == "Corrupted Death"
     or creature:getName() == "Corrupted Hybrid"
     or creature:getName() == "Golden Archangel"
     or creature:getName() == "Rare Crystal"
     or creature:getName() == "Epic Crystal"
     or creature:getName() == "Legendary Crystal"
     or creature:getName() == "Common Crystal" then
     return false
    end
    if killer and killer:isPlayer() then
     local dungeon = killer:getDungeon()
     if dungeon then
      local instance = dungeon:getPlayerInstance(killer)
      if instance then
       return false
      end
     end
    end
    if not creature:isMonster() then
     return false
    end
    
    if killer:isPlayer() then
     if creature:isMonster() then
      if creature:getStorageValue(PlayerStorage.endlessBoss) == 1 then
       local storage = killer:getStorageValue(PlayerStorage.endless)
       killer:setStorageValue(PlayerStorage.endless, storage + 1)
       local floorLevel = killer:getStorageValue(PlayerStorage.endless) + 1
       killer:sendExtendedOpcode(71, json.encode({text = "You killed {Floor Boss}!\n Floor Level increased! You are at Floor "..floorLevel.."", color = "#ff0000"}))
       setEndlessArenaLevel(killer, floorLevel)
       killer:teleportTo(Position(707, 1027, 7))
       local backpack = killer:getSlotItem(CONST_SLOT_BACKPACK)
       local rewardsCount = 3
        if backpack and backpack:getEmptySlots(true) > rewardsCount then
          for i = 1, rewardsCount do
           local itemReward = killer:addItem(TIER_9_IDS[math.random(#TIER_9_IDS)], 1)
           local floorLevel = killer:getStorageValue(PlayerStorage.endless) + 1
           itemReward:setEndlessItem(floorLevel)
           setLootItem(killer, itemReward, 9, 4000, 2000, 1000)
          end
        else
          for i = 1, rewardsCount do
            killer:addItem(2401,3)
           end
        end
      end
     end
    end
    
    return true
    end