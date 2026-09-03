function onAdvance(player, skill, oldLevel, newLevel)
  if skill ~= SKILL_LEVEL or newLevel <= oldLevel then
    return true
  end

  player:recalculateBaseStats()
  player:setHealth(player:getMaxHealth())
  player:addMana(player:getMaxMana())
  if player.updateCharacterStats then
    player:updateCharacterStats()
  end
  player:updateInspect()

  local pid = player:getId()
  addEvent(function()
    local player = Player(pid)
    if not player then
      return
    end

    player:sendCurrentTalents()
    player:updateMaxSpellLevelEver()
    player:sendSpellUpgradeInfo()
  end, 100)

	local pos = player:getPosition()
	local pos2 = Position(pos.x - 1, pos.y - 1, pos.z)
	pos2:sendMagicEffect(237)

--[[
  local skillPointsTable = {
    [3] = true,
    [5] = true,
    [10] = true,
    [15] = true,
    [20] = true,
    [30] = true,
    [40] = true,
    [50] = true,
    [60] = true,
    [70] = true,
    [80] = true
}

    local level = player:getLevel()
    if skillPointsTable[level] then
      player:addSkillTreePoints(1, level)
    end
    --]]

  return true
end