local resizeTo = {
  [1] = {
    { 0, 1, 0 },
    { 0, 3, 0 },
  },
  [2] = {
    { 0, 0, 0 },
    { 0, 1, 0 },
    { 1, 3, 1 },
  },
  [3] = {
    { 0, 0, 0 },
    { 0, 0, 0 },
    { 0, 1, 0 },
    { 0, 1, 0 },
    { 1, 3, 1 },
  },
  [4] = {
    { 0, 0, 0 },
    { 0, 0, 0 },
    { 0, 1, 0 },
    { 1, 1, 1 },
    { 1, 3, 1 },
  },
}

local diaoganlresizeTo = {
  [1] = {
    { 0, 0, 0 },
    { 0, 1, 0 },
    { 0, 0, 3 }
  },
  [2] = {
    { 1, 0, 0 },
    { 0, 3, 1 },
    { 0, 1, 0 },
  },
  [3] = {
    { 1, 0, 0, 0 },
    { 0, 1, 0, 0 },
    { 0, 0, 3, 1 },
    { 0, 0, 1, 0 }
  },
  [4] = {
    { 1, 0, 0, 0 },
    { 0, 1, 1, 0 },
    { 0, 1, 3, 1 },
    { 0, 0, 1, 0 }
  },
}

local CONFIG = {
  spellName = GLOBAL_SPELL_COOLDOWNS[105].name,
  level = 1,
  magLevel = 0,
  precentCost = true,
  manaCost = GLOBAL_SPELL_COOLDOWNS[105].manaCost,
  spellId = 105,
  range = GLOBAL_SPELL_COOLDOWNS[105].range,
  aggressive = true,
  forwardCast = true,
  cooldown = GLOBAL_SPELL_COOLDOWNS[105].cooldown,
  type = COMBAT_ICEDAMAGE,

  combat_config = {
    effect = 528,
    -- distanceEffect = 22,
  },

  defualtArea = {
    { 0, 3, 0 },
  },

  diaoganlArea = {
    { 0, 3, 0 },
  },

  supports = {
    ["dot"] = false,
    ["single"] = true,
  },
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
