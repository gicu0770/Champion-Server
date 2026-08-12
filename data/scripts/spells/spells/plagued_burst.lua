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
    {0, 0, 1, 1, 1, 0, 0},
    {0, 1, 1, 1, 1, 1, 0},
    {1, 1, 1, 1, 1, 1, 1},
    {1, 1, 1, 3, 1, 1, 1},
    {1, 1, 1, 1, 1, 1, 1},
    {0, 1, 1, 1, 1, 1, 0},
    {0, 0, 1, 1, 1, 0, 0}
  },

  [4] = {
    {0, 1, 1, 1, 1, 1, 0},
    {1, 1, 1, 1, 1, 1, 1},
    {1, 1, 1, 1, 1, 1, 1},
    {1, 1, 1, 3, 1, 1, 1},
    {1, 1, 1, 1, 1, 1, 1},
    {1, 1, 1, 1, 1, 1, 1},
    {0, 1, 1, 1, 1, 1, 0}
  },
}

local CONFIG = {
  spellName = GLOBAL_SPELL_COOLDOWNS[57].name,
  level = 1,
  magLevel = 0,
  precentCost = true,
  manaCost = GLOBAL_SPELL_COOLDOWNS[57].manaCost,
  spellId = 57,
  range = GLOBAL_SPELL_COOLDOWNS[57].range,
  aggressive = true,
  forwardCast = true,
  cooldown = GLOBAL_SPELL_COOLDOWNS[57].cooldown,
  type = COMBAT_EARTHDAMAGE,
  dmgInfo = "over 2.5s",
  combat_config = {
  --  effect = 505,
    distanceEffect = 166,
  --  center = true,
  --  offsetX = 1,
  --  offsetY = 1
  },

  defualtArea = {
    { 1, 1, 1 },
    { 1, 3, 1 },
    { 1, 1, 1 },
  },

  supports = {
    ["dot"] = true,
    ["aoe"] = true,
    ["affliction"] = true,
  },
}

local function onCastSpell(player, item, getInfoOnly, force, mousePos)
  if not spellCheckForCast(player, item, CONFIG.spellId, getInfoOnly, force) then return end
  local CONFIG_SUP = item:applySupportSpells(CONFIG, player:getId())
  local effectEx = 505
  local posEx = 1
  if colleftInfo[player:getId()].attributesItems[284] then
    CONFIG_SUP.resizeTo = 4
    effectEx = 514
    posEx = 3
  end
  local area, tempArea = spellSetupArea(CONFIG, CONFIG_SUP, resizeTo)

  if getInfoOnly then
    return spellGetInfoToSend(player, CONFIG, CONFIG_SUP, item, tempArea, dot)
  end
  if not checkCastableSpell(player, CONFIG, CONFIG_SUP, force) then return end

  local dmg = {0, 0}
  local dotDmg = spellGlobalFormule(player, CONFIG, CONFIG_SUP, item, true)
  local combat = spellSetupCombat(player, CONFIG, CONFIG_SUP, area, dmg, force)
  local extraFunc = function(player, target)
    target:startDOT(player, PLAGUED_BURST, dotDmg[1] / 2.5, false, 2500, 21)
    if colleftInfo[player:getId()].attributesItems[284] then
      target:startDOT(player, PLAGUED_BURST, dotDmg[1] / 2.5, false, 2500, 21)
    end
    if target:hasBuff(POISON_ITEM) then
      target:startDOT(player, PLAGUED_BURST, dotDmg[1] / 2.5, false, 2500, 21)
    end
  end
  local variant = spellSetupVariant(player, CONFIG, CONFIG_SUP, mousePos)
  if not variant then return end
  spellSetupTargetCombat(player, combat, CONFIG, CONFIG_SUP, item, extraFunc)

  if spellExecuteCombat(player, combat, CONFIG, CONFIG_SUP, item) then
    local playerPos = variant:getPosition()
    local position = Position(playerPos.x + posEx, playerPos.y + posEx, playerPos.z)
    position:sendMagicEffect(effectEx)

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