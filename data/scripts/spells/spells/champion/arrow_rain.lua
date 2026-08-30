local resizeTo = {
  [1] = {
    {0, 1, 1, 1, 1, 0},
    {1, 1, 1, 1, 1, 1},
    {1, 1, 1, 1, 1, 1},
    {1, 1, 1, 3, 1, 1},
    {1, 1, 1, 1, 1, 1},
    {0, 1, 1, 1, 1, 0},
  },
  [2] = {
    {0, 1, 1, 1, 1, 1, 0},
    {1, 1, 1, 1, 1, 1, 1},
    {1, 1, 1, 1, 1, 1, 1},
    {1, 1, 1, 3, 1, 1, 1},
    {1, 1, 1, 1, 1, 1, 1},
    {1, 1, 1, 1, 1, 1, 1},
    {0, 1, 1, 1, 1, 1, 0},
  },
  [3] = {
    {0, 0, 1, 1, 1, 1, 0, 0},
    {0, 1, 1, 1, 1, 1, 1, 0},
    {1, 1, 1, 1, 1, 1, 1, 1},
    {1, 1, 1, 3, 1, 1, 1, 1},
    {1, 1, 1, 1, 1, 1, 1, 1},
    {1, 1, 1, 1, 1, 1, 1, 1},
    {0, 1, 1, 1, 1, 1, 1, 0},
    {0, 0, 1, 1, 1, 1, 0, 0},
  },
  [4] = {
    {0, 0, 1, 1, 1, 1, 1, 0, 0},
    {0, 1, 1, 1, 1, 1, 1, 1, 0},
    {1, 1, 1, 1, 1, 1, 1, 1, 1},
    {1, 1, 1, 1, 1, 1, 1, 1, 1},
    {1, 1, 1, 1, 3, 1, 1, 1, 1},
    {1, 1, 1, 1, 1, 1, 1, 1, 1},
    {1, 1, 1, 1, 1, 1, 1, 1, 1},
    {0, 1, 1, 1, 1, 1, 1, 1, 0},
    {0, 0, 1, 1, 1, 1, 1, 0, 0},
  },
}

local CONFIG = {
  spellName = GLOBAL_SPELL_COOLDOWNS[9].name,
  level = 1,
  magLevel = 0,
  manaCost = GLOBAL_SPELL_COOLDOWNS[9].manaCost,
  spellId = 9,
  range = GLOBAL_SPELL_COOLDOWNS[9].range or 6,
  aggressive = true,
  forwardCast = true,
  cooldown = GLOBAL_SPELL_COOLDOWNS[9].cooldown,
  type = COMBAT_PHYSICALDAMAGE,

  combat_config = {
    effect = CONST_ME_HITAREA,
  },

  defualtArea = {
    {1, 1, 1, 1},
    {1, 1, 1, 1},
    {1, 1, 3, 1},
    {1, 1, 1, 1}
  },

  supports = {
    ["dot"] = false,
    ["close"] = false,
    ["aoe"] = true,
    ["resize"] = true,
  },
}

local function playRainVisualEffects(centerPos, radius)
  local r = radius or 2
  for dx = -r, r do
    for dy = -r, r do
      if math.random(1, 100) <= 60 then
        local targetTile = Position(centerPos.x + dx, centerPos.y + dy, centerPos.z)
        local skyPos = Position(targetTile.x - 2, targetTile.y - 4, targetTile.z)
        skyPos:sendDistanceEffect(targetTile, 1) -- Arrow projectile falling from sky
        targetTile:sendMagicEffect(CONST_ME_HITAREA)
      end
    end
  end
end

local function executeRainTick(playerId, posX, posY, posZ, tickNum, tickDmg, resizeLevel)
  local player = Player(playerId)
  if not player or player:isRemoved() then return end

  local centerPos = Position(posX, posY, posZ)
  local areaMatrix = (resizeLevel and resizeLevel > 0 and resizeTo[resizeLevel]) or CONFIG.defualtArea

  local combat = Combat()
  combat:setParameter(COMBAT_PARAM_TYPE, COMBAT_PHYSICALDAMAGE)
  combat:setParameter(COMBAT_PARAM_AGGRESSIVE, true)
  combat:setParameter(COMBAT_PARAM_DAMAGE, math.abs(tickDmg))
  combat:setArea(createCombatArea(areaMatrix))

  combat:execute(player, Variant(centerPos))

  -- Visual effects of raining arrows across the area
  playRainVisualEffects(centerPos, (resizeLevel and resizeLevel > 0) and (2 + resizeLevel) or 2)

  if tickNum < 2 then -- 3 ticks total (0, 1, 2)
    addEvent(executeRainTick, 700, playerId, posX, posY, posZ, tickNum + 1, tickDmg, resizeLevel)
  end
end

local function onCastSpell(player, item, getInfoOnly, force, mousePos)
  if not spellCheckForCast(player, item, CONFIG.spellId, getInfoOnly, force) then return end
  local CONFIG_SUP = item:applySupportSpells(CONFIG, player:getId())
  local area, tempArea = spellSetupArea(CONFIG, CONFIG_SUP, resizeTo)

  if getInfoOnly then
    return spellGetInfoToSend(player, CONFIG, CONFIG_SUP, item, tempArea)
  end
  if not checkCastableSpell(player, CONFIG, CONFIG_SUP, force) then return end

  local targetPos = mousePos
  if not targetPos then
    local target = player:getTarget()
    if target and not target:isRemoved() then
      targetPos = target:getPosition()
    else
      targetPos = player:getPosition()
    end
  end

  if not player:targetRechable(targetPos, CONFIG_SUP.range or CONFIG.range) then
    return false
  end

  local resizeLevel = CONFIG_SUP.resizeTo or 0
  local dmg = spellGlobalFormule(player, CONFIG, CONFIG_SUP, item)
  local tickDmg = dmg[1] -- negative damage

  spellSetupCooldown(player, CONFIG, CONFIG_SUP, force)
  if not force then
    spellTakeCost(player, CONFIG, CONFIG_SUP)
  end

  -- Initial tick (0ms) and subsequent ticks (700ms, 1400ms)
  executeRainTick(player:getId(), targetPos.x, targetPos.y, targetPos.z, 0, tickDmg, resizeLevel)

  return true
end

SPELLS[CONFIG.spellName] = {
  cast = function(player, item, force, pos)
    onCastSpell(player, item, false, force, pos)
  end,

  getInfo = function(player, item)
    return onCastSpell(player, item, true)
  end,

  getConfig = function()
    return CONFIG
  end,

  spellId = CONFIG.spellId,
}
