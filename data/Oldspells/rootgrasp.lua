local resizeTo = {
  [1] = {
    {0, 0, 1, 0, 0},
    {0, 1, 1, 0, 0},
    {1, 1, 3, 0, 0},
    {0, 1, 1, 0, 0},
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
  spellName = GLOBAL_SPELL_COOLDOWNS[71].name,
  level = 1,
  magLevel = 0,
  manaCost = GLOBAL_SPELL_COOLDOWNS[71].manaCost,
  spellId = 71,
  range = GLOBAL_SPELL_COOLDOWNS[71].range,
  aggressive = true,
  cooldown = GLOBAL_SPELL_COOLDOWNS[71].cooldown,
  type = COMBAT_EARTHDAMAGE,
  forwardCast = true,
  timeBeetwean = 166,
  bounces = {
    max = 1,
    chance = 100,
    sameTarget = true,
  },

  combat_config = {
    effect = 55,
  },

  defualtArea = {
    {1, 1, 1},
    {1, 3, 1},
    {1, 1, 1}
  },

  supports = {
    ["dot"] = false,
    ["aoe"] = true,
  }
}

local function onCastSpell(player, item, getInfoOnly, force, mousePos)
  if not spellCheckForCast(player, item, CONFIG.spellId, getInfoOnly, force) then return end
  local CONFIG_SUP = item:applySupportSpells(CONFIG, player:getId())
  if colleftInfo[player:getId()].attributesItems[193] then
    CONFIG_SUP.resizeTo = 4
  end
  local area, tempArea = spellSetupArea(CONFIG, CONFIG_SUP, resizeTo)
  if getInfoOnly then
    return spellGetInfoToSend(player, CONFIG, CONFIG_SUP, item, tempArea)
  end
  if not checkCastableSpell(player, CONFIG, CONFIG_SUP, force) then return end

  local dmg = spellGlobalFormule(player, CONFIG, CONFIG_SUP, item)
  local combat = spellSetupCombat(player, CONFIG, CONFIG_SUP, area, dmg, force)
  local extraFunc = function(player, target)
    target:setProgressBar(500, false)
    target:addBuff(STUN, 500)

    local stun = Condition(CONDITION_STUN)
    stun:setParameter(CONDITION_PARAM_TICKS, 500)
    target:addCondition(stun)
  end
  spellSetupTargetCombat(player, combat, CONFIG, CONFIG_SUP, item, extraFunc)
  if spellExecuteCombat(player, combat, CONFIG, CONFIG_SUP, item, nil, mousePos) then
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