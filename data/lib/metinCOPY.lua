if not Metin then
    Metin = {}
    --About drop, it's easy to add dropLoot func here, but easier just put loot to boss, in this example it's Dragon Lord and Demon
    --And set monster speed to 0 in script if you want to boss stay on 1 sqm.
    Metin.cfg = {
        indexStorage = 226000, --cfg cuz maybe in future ill add some things there
        stonesIndexStorage = 226001,

        maxStonesPerServer = 10, --how many metin stones can be spawned on map
    }

    Metin.cfg.spawns = { --metin spawn positions    SECOND
	{x = 266, y = 748, z = 12},	-- {x = 266, y = 748, z = 12}	orclops
	{x = 719, y = 612, z = 8},	-- {x = 719, y = 612, z = 8}	drakens
	{x = 1252, y = 518, z = 7}	-- {x = 1252, y = 518, z = 7}	forgotens
    }
    Metin.cfg.spawns2 = { --metin spawn positions  THRID
  	{x = 396, y = 1826, z = 9},	-- {x = 396, y = 1826, z = 9} undead warrior
	{x = 669, y = 2077, z = 8},	-- {x = 669, y = 2077, z = 8} brothery 350lvl
	{x = 482, y = 1761, z = 8}	--	{x = 482, y = 1761, z = 8} glebiej undeads
    }
    Metin.cfg.spawns3 = { --metin spawn positions		FIRST
 	{x = 1288, y = 1290, z = 9},	-- falcon
	{x = 1325, y = 1016, z = 11},		-- spectres
	{x = 297, y = 1439, z = 10},	-- 	{x = 297, y = 1439, z = 10}	vexcalw
	{x = 1012, y = 933, z = 13}	-- humubgus
    }

    Metin.stones = {
        ['First Rift Portal'] = { --just one monster with same name can be in table, i could add index to fix that but im not sure if someone want multiple summons config for same monster
            {percentHealth = 90, monsters = {"Rift Minion", "Rift Minion","Rift Minion"}}, --from biggest to lowest hp %
            {percentHealth = 75, monsters = {"Rift Minion","Rift Minion","Rift Warrior"}},
            {percentHealth = 50, monsters = {"Rift Warrior","Rift Warrior","Rift Scorpion"}},
            {percentHealth = 25, monsters = {"Rift Warrior","Rift Scorpion","Rift Scorpion"}},
            {percentHealth = 10, monsters = {"Rift Warrior","Rift Scorpion","Rift Scorpion"}},
        },
        ['Second Rift Portal'] = {
            {percentHealth = 90, monsters = {"Rift Minion", "Rift Minion","Rift Warrior"}}, --from biggest to lowest hp %
            {percentHealth = 75, monsters = {"Rift Minion","Rift Scorpion","Rift Warrior"}},
            {percentHealth = 50, monsters = {"Rift Scorpion","Rift Warrior","Rift Scorpion"}},
            {percentHealth = 25, monsters = {"Rift Intruder","Rift Scorpion","Rift Nightmare"}},
            {percentHealth = 10, monsters = {"Rift Intruder","Rift Scorpion","Rift Nightmare"}},
        },
       ['Third Rift Portal'] = {
            {percentHealth = 90, monsters = {"Rift Scorpion", "Rift Scorpion","Rift Scorpion"}}, --from biggest to lowest hp %
            {percentHealth = 75, monsters = {"Rift Intruder","Rift Scorpion","Rift Intruder"}},
            {percentHealth = 50, monsters = {"Rift Nightmare","Rift Intruder","Rift Scorpion"}},
            {percentHealth = 25, monsters = {"Rift Nightmare","Rift Nightmare","Rift Nightmare"}},
            {percentHealth = 10, monsters = {"Rift Nightmare","Rift Nightmare","Rift Nightmare"}},
        }
    }

    function Metin.getRandomSpawn()
        local freeSpawns = {}
        for i = 1, #Metin.cfg.spawns do
            local t = Tile(Metin.cfg.spawns[i])
            if t ~= nil then
                local creaturesOnTile = t:getCreatures()
                if(creaturesOnTile and #t:getCreatures() == 0) then --Delete this if you want to avoid spawn block (almost impossible to block all if have a lot of spawns)
                    table.insert(freeSpawns, Metin.cfg.spawns[i])
                end
            end
        end

        if(#freeSpawns > 0) then
            return freeSpawns[math.random(1, #freeSpawns)]
        end
        return false
    end
	
 function Metin.getRandomSpawn2()
        local freeSpawns = {}
        for i = 1, #Metin.cfg.spawns2 do
            local t = Tile(Metin.cfg.spawns2[i])
            if t ~= nil then
                local creaturesOnTile = t:getCreatures()
                if(creaturesOnTile and #t:getCreatures() == 0) then --Delete this if you want to avoid spawn block (almost impossible to block all if have a lot of spawns)
                    table.insert(freeSpawns, Metin.cfg.spawns2[i])
                end
            end
        end

        if(#freeSpawns > 0) then
            return freeSpawns[math.random(1, #freeSpawns)]
        end
        return false
    end
	
	
	
 function Metin.getRandomSpawn3()
        local freeSpawns = {}
        for i = 1, #Metin.cfg.spawns3 do
            local t = Tile(Metin.cfg.spawns3[i])
            if t ~= nil then
                local creaturesOnTile = t:getCreatures()
                if(creaturesOnTile and #t:getCreatures() == 0) then --Delete this if you want to avoid spawn block (almost impossible to block all if have a lot of spawns)
                    table.insert(freeSpawns, Metin.cfg.spawns3[i])
                end
            end
        end

        if(#freeSpawns > 0) then
            return freeSpawns[math.random(1, #freeSpawns)]
        end
        return false
    end
	
	
	
	
	

    function Metin.spawnOperator()
        local spawnedStones = Game.getStorageValue(Metin.cfg.stonesIndexStorage)
        if(spawnedStones < Metin.cfg.maxStonesPerServer) then
           
            local spawnPoint = Metin.getRandomSpawn()
		local spawnPoint2 = Metin.getRandomSpawn2()
		local spawnPoint3 = Metin.getRandomSpawn3()
		local rand = math.random(1, 3)
			--if rand == 1 then
	if(spawnPoint) then
                local monster = Game.createMonster(Metin.cache.allStones[1], spawnPoint, true)
                monster:registerEvent("MetinHealthChange")
                monster:registerEvent("MetinDeath")
                Metin.setIndex(monster, 1)
                broadcastMessage("Rift Portal spawned somewhere on map!", MESSAGE_STATUS_WARNING)
                Game.setStorageValue(Metin.cfg.stonesIndexStorage, (spawnedStones + 1))
	end
--elseif rand == 2 then
	if(spawnPoint2) then
                local monster = Game.createMonster(Metin.cache.allStones[2], spawnPoint2, true)
                monster:registerEvent("MetinHealthChange")
                monster:registerEvent("MetinDeath")
                Metin.setIndex(monster, 1)
                broadcastMessage("Rift Portal spawned somewhere on map!", MESSAGE_STATUS_WARNING)
                Game.setStorageValue(Metin.cfg.stonesIndexStorage, (spawnedStones + 1))
	end
--elseif rand == 3 then
	if(spawnPoint3) then
                local monster = Game.createMonster(Metin.cache.allStones[3], spawnPoint3, true)
                monster:registerEvent("MetinHealthChange")
                monster:registerEvent("MetinDeath")
                Metin.setIndex(monster, 1)
                broadcastMessage("Rift Portal spawned somewhere on map!", MESSAGE_STATUS_WARNING)
                Game.setStorageValue(Metin.cfg.stonesIndexStorage, (spawnedStones + 1))
	end
	--end
			
			
			
        end
    end
   

    Metin.cache = {
        allStones = {}, --stonename
        stoneCfg = {},--['stonename'] = {monstersTableSize = x, healthChangesOnPercents = {x,y,z,v,q,w..}}
        pholder = {
            monstersTableSize = 0,
            healthChangesOnPercents = {}
        }
    }
    --cache loader
        for k,v in pairs(Metin.stones) do
            table.insert(Metin.cache.allStones, k)

            Metin.cache.stoneCfg[k] = {}        
           
            table.insert(Metin.cache.stoneCfg[k], Metin.cache.pholder)
            Metin.cache.stoneCfg[k].monstersTableSize = #v
            Metin.cache.stoneCfg[k].healthChangesOnPercents = {}

            for tableEntry,mobCfg in pairs(v) do
                table.insert(Metin.cache.stoneCfg[k].healthChangesOnPercents, mobCfg.percentHealth)
            end
        end

    if(Game.getStorageValue(Metin.cfg.stonesIndexStorage) == nil) then
        Game.setStorageValue(Metin.cfg.stonesIndexStorage, 0)
    end
    --end

    function Metin.getNewHealth(monster, damage)
	local damage = 1
        if(monster:getHealth() == 0) then return false end
        local MetinIndex = Metin.getIndex(monster)
        if(MetinIndex and MetinIndex ~= -1) then --verify if monster is metin
            local metinCfg = Metin.cache.stoneCfg[monster:getName()]
            if(not metinCfg) then return print("Rift Portal error. Wrong monster name in config.") and true end

            if(metinCfg.healthChangesOnPercents[MetinIndex] == nil) then return 0 end --monster die
            local maxRetHealth = (metinCfg.healthChangesOnPercents[MetinIndex] * monster:getMaxHealth()) / 100
            local normalDamage = monster:getHealth() - damage
            if(normalDamage > maxRetHealth) then
                return normalDamage
            else
                local monsters = Metin.stones[monster:getName()][MetinIndex].monsters
                for i = 1, #monsters do
                    local summon = Game.createMonster(monsters[i], monster:getPosition(), true):setMaster(monster)
                    monster:addSummon(summon)
                end
                Metin.setIndex(monster, (MetinIndex + 1))          
                return maxRetHealth
            end        
        end
        return monster:getMaxHealth() --return max if not metin, can add error bud idk if someone need
    end

    function Metin.getIndex(monster)
        return monster:getStorageValue(Metin.cfg.indexStorage)
    end

    function Metin.setIndex(monster, newIndex)
        return monster:setStorageValue(Metin.cfg.indexStorage, newIndex)
    end
end