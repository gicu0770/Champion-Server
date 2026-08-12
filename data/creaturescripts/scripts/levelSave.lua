function onAdvance(player, skill, oldLevel, newLevel)
        if skill == SKILL_LEVEL and newLevel > oldLevel then
        tasks:updateTasks(player)
        player:save()
    end

    return true
end