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
    {0, 1, 1, 1, 1, 1, 0},
    {0, 1, 1, 1, 1, 1, 0},
    {1, 1, 1, 3, 1, 1, 1},
    {0, 1, 1, 1, 1, 1, 0},
    {0, 1, 1, 1, 1, 1, 0},
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
  spellName = GLOBAL_SPELL_COOLDOWNS[29].name,
  level = 1,
  magLevel = 0,
  precentCost = true,
  manaCost = GLOBAL_SPELL_COOLDOWNS[29].manaCost,
  spellId = 29,
  range = GLOBAL_SPELL_COOLDOWNS[29].range,
  aggressive = true,
  cooldown = GLOBAL_SPELL_COOLDOWNS[29].cooldown,
  type = COMBAT_PHYSICALDAMAGE,

  defualtArea = {
    {1, 1, 1},
    {1, 3, 1},
    {1, 1, 1}
  },
  newArea = {
    {0, 1, 1, 1, 0},
    {1, 1, 1, 1, 1},
    {1, 1, 3, 1, 1},
    {1, 1, 1, 1, 1},
    {0, 1, 1, 1, 0}
  },

  supports = {
    ["dot"] = false,
    ["move"] = true,
    ["aoe"] = true,
    ["close"] = true,
  },
}

local function executeLeapSlam(player, combat, CONFIG_SUP, item)
  spellExecuteCombat(player, combat, CONFIG, CONFIG_SUP, item, Variant(player), nil, true)
  local playerPos = player:getPosition()
  position = Position(playerPos.x + 2, playerPos.y + 2, playerPos.z)
  local effectDrop = 513
  if CONFIG_SUP.resizeTo then
    if CONFIG_SUP.resizeTo == 4 then
      effectDrop = 467
      position = Position(playerPos.x + 3, playerPos.y + 3, playerPos.z)
    end
  end
  position:sendMagicEffect(effectDrop, 1)
  spellCleanAfterCast(player, combat)
end

local function onCastSpell(player, item, getInfoOnly, force, mousePos)
  if not spellCheckForCast(player, item, CONFIG.spellId, getInfoOnly, force) then return end
  local CONFIG_SUP = item:applySupportSpells(CONFIG, player:getId())
  local area
  local tempArea

  if colleftInfo[player:getId()].attributesItems[183] then
    tempArea = CONFIG.newArea
    area = createCombatArea(CONFIG.newArea)
  else
    area, tempArea = spellSetupArea(CONFIG, CONFIG_SUP, resizeTo)
  end
  if getInfoOnly then
    return spellGetInfoToSend(player, CONFIG, CONFIG_SUP, item, tempArea)
  end
  if not checkCastableSpell(player, CONFIG, CONFIG_SUP, force) then return end

  local dmg = spellGlobalFormule(player, CONFIG, CONFIG_SUP, item)
  local combat = spellSetupCombat(player, CONFIG, CONFIG_SUP, area, dmg, force)
  spellSetupTargetCombat(player, combat, CONFIG, CONFIG_SUP, item)

  local position = player:getPosition()
  local targetPos = player:getTarget() and player:getTarget():getPosition() or mousePos
  if not targetPos then
    targetPos = position
  end

  local checkPathing = player:getPathTo(targetPos, 0, 0, false, false, nil, true)
  if not checkPathing or #checkPathing >= CONFIG_SUP.range then
    player:sendCancelMessage("You are too far away.")
    return
  end

  spellSetupCooldown(player, CONFIG, CONFIG_SUP, force)
  spellTakeCost(player, CONFIG, CONFIG_SUP)

  local distance = getDistanceBetween(position, targetPos)
  distance = #checkPathing > 0 and #checkPathing or distance
  player:jump(8 * distance, 70 * distance)

  if #checkPathing == 0 then
    executeLeapSlam(player, combat, CONFIG_SUP, item)
  end

  local stepCount = 0
  for k = #checkPathing, 1, -1 do
    stepCount = stepCount + 1
    local path = checkPathing[k]
    addEvent(function(cid)
      local player = Player(cid)
      if not player then return end
      if player:getZone() == ZONE_PROTECTION then
        spellCleanAfterCast(player, combat)
        return
      end
      player:move(path, FLAG_IGNOREBLOCKCREATURE)

      if k == 1 then
        executeLeapSlam(player, combat, CONFIG_SUP, item)
      end
    end, 66*stepCount, player:getId())
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