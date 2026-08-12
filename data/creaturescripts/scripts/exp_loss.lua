function onDeath(player, corpse, killer, mostDamageKiller, lastHitUnjustified, mostDamageUnjustified)
    if player:hasFlag(PlayerFlag_NotGenerateLoot) or player:getVocation():getId() == VOCATION_NONE then
        return true
    end
    player:setStorageValue(801106, 0)
    --[[
    local level = player:getLevel()
    local expSet = player:getExperience() - getExpForLevel(level - 1)
    if killer:isMonster() then
        player:removeExperience(expSet, true)
    end
    --]]
    return true
end
