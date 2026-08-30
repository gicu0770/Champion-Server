local resizeTo = {
  [1] = {
    {1, 1, 1, 1, 1},
    {0, 1, 1, 1, 0},
    {0, 1, 1, 1, 0},
    {0, 1, 1, 1, 0},
    {0, 1, 1, 1, 0},
    {0, 1, 1, 1, 0},
    {0, 0, 3, 0, 0}
  },
  [2] = {
    {1, 1, 1, 1, 1},
    {1, 1, 1, 1, 1},
    {0, 1, 1, 1, 0},
    {0, 1, 1, 1, 0},
    {0, 1, 1, 1, 0},
    {0, 1, 1, 1, 0},
    {0, 0, 3, 0, 0}
  },
  [3] = {
    {1, 1, 1, 1, 1, 1, 1},
    {0, 1, 1, 1, 1, 1, 0},
    {0, 1, 1, 1, 1, 1, 0},
    {0, 0, 1, 1, 1, 0, 0},
    {0, 0, 1, 1, 1, 0, 0},
    {0, 0, 1, 1, 1, 0, 0},
    {0, 0, 0, 3, 0, 0, 0}
  },
  [4] = {
    {1, 1, 1, 1, 1, 1, 1, 1, 1},
    {0, 1, 1, 1, 1, 1, 1, 1, 0},
    {0, 0, 1, 1, 1, 1, 1, 0, 0},
    {0, 0, 1, 1, 1, 1, 1, 0, 0},
    {0, 0, 0, 1, 1, 1, 0, 0, 0},
    {0, 0, 0, 1, 1, 1, 0, 0, 0},
    {0, 0, 0, 0, 3, 0, 0, 0, 0}
  },
}

local CONFIG = {
  spellName = GLOBAL_SPELL_COOLDOWNS[8].name,
  level = 1,
  magLevel = 0,
  manaCost = GLOBAL_SPELL_COOLDOWNS[8].manaCost,
  spellId = 8,
  range = GLOBAL_SPELL_COOLDOWNS[8].range or 6,
  aggressive = true,
  cooldown = GLOBAL_SPELL_COOLDOWNS[8].cooldown,
  type = COMBAT_PHYSICALDAMAGE,
  directional = true,

  combat_config = {
    effect = CONST_ME_HITAREA,
  },

  defualtArea = {
    {1, 1, 1},
    {1, 1, 1},
    {1, 1, 1},
    {1, 1, 1},
    {1, 1, 1},
    {1, 1, 1},
    {0, 3, 0}
  },

    diaoganlArea = {
    {0, 1, 1, 0, 0, 0, 0},
    {1, 1, 1, 1, 0, 0, 0},
    {1, 1, 1, 1, 1, 0, 0},
    {0, 1, 1, 1, 1, 1, 0},
    {0, 0, 1, 1, 1, 1, 1},
    {0, 0, 0, 1, 1, 1, 1},
    {0, 0, 0, 0, 1, 1, 3}
  },

  supports = {
    ["dot"] = true,
    ["aoe"] = true,
    ["resize"] = true,
  }
}

local function shootVolleyProjectiles(playerPos, dir)
  if dir == DIRECTION_NORTH then
    for length = 1, 6 do
      for width = -1, 1 do
        playerPos:sendDistanceEffect(Position(playerPos.x + width, playerPos.y - length, playerPos.z), 1)
      end
    end
  elseif dir == DIRECTION_SOUTH then
    for length = 1, 6 do
      for width = -1, 1 do
        playerPos:sendDistanceEffect(Position(playerPos.x + width, playerPos.y + length, playerPos.z), 1)
      end
    end
  elseif dir == DIRECTION_EAST then
    for length = 1, 6 do
      for width = -1, 1 do
        playerPos:sendDistanceEffect(Position(playerPos.x + length, playerPos.y + width, playerPos.z), 1)
      end
    end
  elseif dir == DIRECTION_WEST then
    for length = 1, 6 do
      for width = -1, 1 do
        playerPos:sendDistanceEffect(Position(playerPos.x - length, playerPos.y + width, playerPos.z), 1)
      end
    end
  elseif dir == DIRECTION_NORTHEAST then
    for d = 1, 6 do
      playerPos:sendDistanceEffect(Position(playerPos.x + d, playerPos.y - d, playerPos.z), 1)
      playerPos:sendDistanceEffect(Position(playerPos.x + d - 1, playerPos.y - d, playerPos.z), 1)
      playerPos:sendDistanceEffect(Position(playerPos.x + d, playerPos.y - d + 1, playerPos.z), 1)
    end
  elseif dir == DIRECTION_SOUTHEAST then
    for d = 1, 6 do
      playerPos:sendDistanceEffect(Position(playerPos.x + d, playerPos.y + d, playerPos.z), 1)
      playerPos:sendDistanceEffect(Position(playerPos.x + d - 1, playerPos.y + d, playerPos.z), 1)
      playerPos:sendDistanceEffect(Position(playerPos.x + d, playerPos.y + d - 1, playerPos.z), 1)
    end
  elseif dir == DIRECTION_NORTHWEST then
    for d = 1, 6 do
      playerPos:sendDistanceEffect(Position(playerPos.x - d, playerPos.y - d, playerPos.z), 1)
      playerPos:sendDistanceEffect(Position(playerPos.x - d + 1, playerPos.y - d, playerPos.z), 1)
      playerPos:sendDistanceEffect(Position(playerPos.x - d, playerPos.y - d + 1, playerPos.z), 1)
    end
  elseif dir == DIRECTION_SOUTHWEST then
    for d = 1, 6 do
      playerPos:sendDistanceEffect(Position(playerPos.x - d, playerPos.y + d, playerPos.z), 1)
      playerPos:sendDistanceEffect(Position(playerPos.x - d + 1, playerPos.y + d, playerPos.z), 1)
      playerPos:sendDistanceEffect(Position(playerPos.x - d, playerPos.y + d - 1, playerPos.z), 1)
    end
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

  if mousePos then
    local dir = spellGetDirectionTo(player:getPosition(), mousePos)
    if dir then
      player:setDirection(dir)
    end
  end

  local dmg = spellGlobalFormule(player, CONFIG, CONFIG_SUP, item)
  local combat = spellSetupCombat(player, CONFIG, CONFIG_SUP, area, dmg, force)

  spellSetupTargetCombat(player, combat, CONFIG, CONFIG_SUP, item)

  local variant = Variant(player, true)
  if spellExecuteCombat(player, combat, CONFIG, CONFIG_SUP, item, variant, mousePos) then
    shootVolleyProjectiles(player:getPosition(), player:getDirection())
    spellSetupCooldown(player, CONFIG, CONFIG_SUP, force)
    spellCleanAfterCast(player, combat)
  end

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
