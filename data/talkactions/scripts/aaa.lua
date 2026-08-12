function onSay(player, words, param)
    local split = param:split(",")

    local action = split[1]
    if action == "loot" then
        local item = Game.getRealUniqueItem(tostring(split[2]))
        if item then
            local parent = item:getParent()
            if parent and parent:isItem() and parent:getName():lower():find("loot bag") then
                if item:moveTo(player:getSlotItem(CONST_SLOT_BACKPACK)) then
                sendLootedItem(player, item:getRealUID(), tonumber(split[3]))
                else
                sendLootedItem(player, item:getRealUID(), tonumber(split[3]), 1)
                player:sendTooltipMessage("You don't have enough space in your backpack.")
                end
            end
        end
    end

    return false
end