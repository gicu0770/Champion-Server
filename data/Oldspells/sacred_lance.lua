local resizeTo = {
  [1] = {
    {0, 0, 0},
    {0, 3, 0},
    {0, 0, 0}
  },

  [2] = {
    {0, 0, 0},
    {0, 3, 0},
    {0, 0, 0}
  },

  [3] = {
    {0, 0, 0},
    {0, 3, 0},
    {0, 0, 0}
  },

  [4] = {
    {0, 0, 0},
    {0, 3, 0},
    {0, 0, 0}
  },
}

local CONFIG = {
  spellName = GLOBAL_SPELL_COOLDOWNS[100].name,
  level = 1,
  magLevel = 0,
  manaCost = GLOBAL_SPELL_COOLDOWNS[100].manaCost,
  spellId = 100,
  range = GLOBAL_SPELL_COOLDOWNS[100].range,
  aggressive = true,
  cooldown = GLOBAL_SPELL_COOLDOWNS[100].cooldown,
  type = COMBAT_HOLYDAMAGE,
  forwardCast = true,

  combat_config = {
    effect = 112,
    distanceEffect = 90,
  },

  defualtArea = {
    {0, 0, 0},
    {0, 3, 0},
    {0, 0, 0}
  },

  supports = {
    ["dot"] = false,
    ["single"] = true,
  }
}

local function onCastSpell(player, item, getInfoOnly, force, mousePos)
  if not spellCheckForCast(player, item, CONFIG.spellId, getInfoOnly, force) then return end
  local CONFIG_SUP = item:applySupportSpells(CONFIG, player:getId())
  local area, tempArea = spellSetupArea(CONFIG, CONFIG_SUP, resizeTo)

  if getInfoOnly then
    return spellGetInfoToSend(player, CONFIG, CONFIG_SUP, item, tempArea)
  end
  if not checkCastableSpell(player, CONFIG, CONFIG_SUP, force) then return end
  local variant = spellSetupVariant(player, CONFIG, CONFIG_SUP, mousePos)
  if not variant then return end

  local dmg = spellGlobalFormule(player, CONFIG, CONFIG_SUP, item)
  local combat = spellSetupCombat(player, CONFIG, CONFIG_SUP, area, dmg, force)
  spellSetupTargetCombat(player, combat, CONFIG, CONFIG_SUP, item)
  if spellExecuteCombat(player, combat, CONFIG, CONFIG_SUP, item, variant, mousePos) then
    spellCleanAfterCast(player, combat)
    spellSetupCooldown(player, CONFIG, CONFIG_SUP, force)
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