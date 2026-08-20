local resizeTo = {
  [1] = {
    {0, 0, 1, 0, 0},
    {0, 1, 1, 1, 0},
    {1, 1, 3, 1, 1},
    {0, 1, 1, 1, 0},
    {0, 0, 1, 0, 0}
  },
  [2] = {
    {0, 1, 1, 1, 0},
    {1, 1, 1, 1, 1},
    {1, 1, 3, 1, 1},
    {1, 1, 1, 1, 1},
    {0, 1, 1, 1, 0}
  },
  [3] = {
    {0, 0, 0, 1, 0, 0, 0},
    {0, 0, 1, 1, 1, 0, 0},
    {0, 1, 1, 1, 1, 1, 0},
    {1, 1, 1, 3, 1, 1, 1},
    {0, 1, 1, 1, 1, 1, 0},
    {0, 0, 1, 1, 1, 0, 0},
    {0, 0, 0, 1, 0, 0, 0}
  },

  [4] = {
    {0, 0, 1, 1, 1, 0, 0},
    {0, 1, 1, 1, 1, 1, 0},
    {1, 1, 1, 1, 1, 1, 1},
    {1, 1, 1, 3, 1, 1, 1},
    {1, 1, 1, 1, 1, 1, 1},
    {0, 1, 1, 1, 1, 1, 0},
    {0, 0, 1, 1, 1, 0, 0}
  },
}

local CONFIG = {
  spellName = "Tornado",
  level = 1,
  magLevel = 0,
  manaCost = GLOBAL_SPELL_COOLDOWNS[24].manaCost,
  spellId = 24,
  range = GLOBAL_SPELL_COOLDOWNS[24].range,
  aggressive = true,
  cooldown = GLOBAL_SPELL_COOLDOWNS[24].cooldown,
  type = COMBAT_ENERGYDAMAGE,
  projectile = GLOBAL_SPELL_COOLDOWNS[24].split,
    combat_config = {
    effect = 0,
    bottom = true,
  },

  defualtArea = {
    {1, 1, 1},
    {1, 3, 1},
    {1, 1, 1}
  },

  supports = {
    ["split"] = true,
    ["aoe"] = true,
  }
}

local function spellWalkRandomly(combat, pid, expireTime, walkSpeed, pos, CONFIG_SUP)
  local player = Player(pid)
  if not player then
    return
  end

  local tempPos = Position(pos.x, pos.y, pos.z)
  local newPos = Position(pos.x, pos.y, pos.z)
  tempPos = getRandomPosition(tempPos, newPos)
  newPos:sendDistanceEffect(tempPos, 417, true, walkSpeed, 1.0)

  spellExecuteCombat(player, combat, CONFIG, CONFIG_SUP, item, Variant(tempPos), nil, true)

  expireTime = expireTime - walkSpeed
  if expireTime <= 0 then
    addEvent(function()
      tempPos:sendMagicEffect(114)
    end, walkSpeed)
    return
  end

  addEvent(function()
    spellWalkRandomly(combat, pid, expireTime, walkSpeed, tempPos, CONFIG_SUP)
  end, walkSpeed)
end

-- Uses global SPELL_COMBATS_TO_REMOVE for proper cleanup on logout
local function onCastSpell(player, item, getInfoOnly, force, mousePos)
  if not spellCheckForCast(player, item, CONFIG.spellId, getInfoOnly, force) then return end
  local CONFIG_SUP = item:applySupportSpells(CONFIG, player:getId())
  local area, tempArea = spellSetupArea(CONFIG, CONFIG_SUP, resizeTo)

  if getInfoOnly then
    return spellGetInfoToSend(player, CONFIG, CONFIG_SUP, item, tempArea)
  end
  if not checkCastableSpell(player, CONFIG, CONFIG_SUP, force) then return end

  local playerId = player:getId()
  if not SPELL_COMBATS_TO_REMOVE[playerId] then
    SPELL_COMBATS_TO_REMOVE[playerId] = {
      combats = {},
      time = os.time(),
    }
  elseif os.time() - SPELL_COMBATS_TO_REMOVE[playerId].time > 30 then
    for i = 1, #SPELL_COMBATS_TO_REMOVE[playerId].combats do
      spellCleanAfterCast(player, SPELL_COMBATS_TO_REMOVE[playerId].combats[i])
    end
    SPELL_COMBATS_TO_REMOVE[playerId].combats = {}
    SPELL_COMBATS_TO_REMOVE[playerId].time = os.time()
  end

  local dmg = spellGlobalFormule(player, CONFIG, CONFIG_SUP, item)
  local combat = spellSetupCombat(player, CONFIG, CONFIG_SUP, area, dmg, force)
  table.insert(SPELL_COMBATS_TO_REMOVE[playerId].combats, combat)

  local extraFunc = function(player, target)
    if target == player then
      return
    end
    target:getPosition():sendMagicEffect(649)
  end
  spellSetupTargetCombat(player, combat, CONFIG, CONFIG_SUP, item, extraFunc)

  local playerPos = player:getPosition()
  spellSetupCooldown(player, CONFIG, CONFIG_SUP, force)
  spellTakeCost(player, CONFIG, CONFIG_SUP)
  for i = 1, CONFIG_SUP.projectile do
    spellWalkRandomly(combat, player:getId(), 2500, 500, playerPos, CONFIG_SUP)
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