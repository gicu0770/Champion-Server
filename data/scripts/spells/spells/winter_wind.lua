local resizeTo = {
  [1] = {
    {1, 1, 1},
    {1, 3, 1},
    {1, 1, 1}
  },

  [2] = {
    {0, 0, 1, 0, 0},
    {0, 1, 1, 1, 0},
    {1, 1, 3, 1, 1},
    {0, 1, 1, 1, 0},
    {0, 0, 1, 0, 0}
  },

  [3] = {
    {0, 1, 1, 1, 0},
    {1, 1, 1, 1, 1},
    {1, 1, 3, 1, 1},
    {1, 1, 1, 1, 1},
    {0, 1, 1, 1, 0}
  },

  [4] = {
    {0, 0, 0, 1, 0, 0, 0},
    {0, 0, 1, 1, 1, 0, 0},
    {0, 1, 1, 1, 1, 1, 0},
    {1, 1, 1, 3, 1, 1, 1},
    {0, 1, 1, 1, 1, 1, 0},
    {0, 0, 1, 1, 1, 0, 0},
    {0, 0, 0, 1, 0, 0, 0}
  },
}

local CONFIG = {
  spellName = GLOBAL_SPELL_COOLDOWNS[31].name,
  level = 1,
  magLevel = 0,
  manaCost = GLOBAL_SPELL_COOLDOWNS[31].manaCost,
  spellId = 31,
  aggressive = true,
  cooldown = GLOBAL_SPELL_COOLDOWNS[31].cooldown,
  type = COMBAT_ICEDAMAGE,
  directional = true,
  forwardCast = true,
  projectile = 1,
  defualtArea = {
    {0, 1, 0},
    {1, 3, 1},
    {0, 1, 0}
  },

  supports = {
    ["dot"] = false,
    ["aoe"] = true,
    ["split"] = true,
  }
}

-- Uses global SPELL_COMBATS_TO_REMOVE for proper cleanup on logout
local function spellStartWalking(combat, pid, expireTime, walkSpeed, direction, CONFIG_SUP, pos, walkCycle)
  local player = Player(pid)
  if not player then return end

  local newPos = Position(pos.x, pos.y, pos.z)
  pos = getNextPositionByDir(pos, newPos, direction, 1)
  if newPos == pos then
    pos:sendMagicEffect(44)
    return
  end

  newPos:sendDistanceEffect(pos, 214, true, walkSpeed, 1.0)

  spellExecuteCombat(player, combat, CONFIG, CONFIG_SUP, item, Variant(pos), nil, true)

  expireTime = expireTime - walkSpeed
  if expireTime <= 0 then
    addEvent(function()
      pos:sendMagicEffect(44)
    end, walkSpeed)
    return
  end

  addEvent(function()
    spellStartWalking(combat, pid, expireTime, walkSpeed, direction, CONFIG_SUP, pos, walkCycle)
  end, walkSpeed)
end

local function onCastSpell(player, item, getInfoOnly, force, mousePos)
  if not player then return end
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
  spellSetupTargetCombat(player, combat, CONFIG, CONFIG_SUP, item)

  function castProjectiles(player, postion, fromPos)
    addEvent(function()
      fromPos:sendDistanceEffect(postion, 126)
    end, 250)
  end
  
  spellSetupTragetTile(player, combat, CONFIG, CONFIG_SUP, item, castProjectiles)

  spellSetupCooldown(player, CONFIG, CONFIG_SUP, force)
  spellTakeCost(player, CONFIG, CONFIG_SUP)

  local shot = CONFIG.projectile
  if CONFIG_SUP.projectile >= 1 then
    shot = CONFIG_SUP.projectile
  end
  if colleftInfo[player:getId()].attributesItems[156] then
    shot = 8
  end
  -- zawsze atak w kierunku gracza
  spellStartWalking(combat, player:getId(), 5000, 500, player:getDirection(), CONFIG_SUP, player:getPosition(), 0)
  -- dodatkowe ataki tylko w innych kierunkach
  if shot >= 8 then
    shot = 8
  end
  if shot >= 2 then
    local count = 0
    local dir = 0
    while count < shot - 1 do
      if dir ~= player:getDirection() then
        spellStartWalking(combat, player:getId(), 5000, 500, dir, CONFIG_SUP, player:getPosition(), 0)
        count = count + 1
      end
      dir = dir + 1
      if dir > 7 then break end -- zabezpieczenie przed nieskończoną pętlą, jeśli jest więcej shot niż kierunków
    end
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