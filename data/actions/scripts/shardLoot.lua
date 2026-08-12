function onUse(player, item, fromPosition, target, toPosition, isHotkey)
    local amount = item:getCount()
    for i = 1, amount do
        local soulshards = {36971, 36972, 36973, 36974, 36975, 36976, 36977, 36978, 36980, 37286, 37284, 37295, 37301, 37283, 37290, 37282, 37287, 37298}
        local randomM = math.random(#soulshards)
        local shard = player:addItem(soulshards[randomM], 1)
        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Soul Shard: " .. shard:getName() .. "")
        shard:setSoulShard(randomM)
        if math.random(100000) <= 1000 then
            shard:setLegendarySoulShard(1)
            shard:setRarity(4)
            local name = ItemType(soulshards[randomM]):getName()
            shard:setAttribute(ITEM_ATTRIBUTE_NAME, "Legendary " .. name .. "")
            player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Soul Shard: " .. shard:getName() .. " become Legendary!!!")
        end
        if math.random(100000) <= 1000 then
            local elementShard = {
                [1]= {name = "Flame"},
                [2]= {name = "Frozen"},
                [3]= {name = "Tunder"},
                [4]= {name = "Toxic"},
                [5]= {name = "Dark"},
                [6]= {name = "Bless"},
                [7]= {name = "Power"},
            }
            local eleRand = math.random(1, 7)
            local name = ItemType(soulshards[randomM]):getName()
            shard:setAttribute(ITEM_ATTRIBUTE_NAME, ""..elementShard[eleRand].name.." " .. name .. "")
            shard:setCustomAttribute("elemental_empower", eleRand)
        end
    end
    item:remove(amount)
   return true
end