local resizeTo = {
  [1] = {
    { 0, 1, 0 },
    { 1, 3, 1 },
    { 0, 1, 0 }
  },

  [2] = {
    { 1, 1, 1 },
    { 1, 3, 1 },
    { 1, 1, 1 }
  },

  [3] = {
    { 0, 0, 1, 0, 0 },
    { 0, 1, 1, 1, 0 },
    { 1, 1, 3, 1, 1 },
    { 0, 1, 1, 1, 0 },
    { 0, 0, 1, 0, 0 }
  },

  [4] = {
    { 0, 1, 1, 1, 0 },
    { 1, 1, 1, 1, 1 },
    { 1, 1, 3, 1, 1 },
    { 1, 1, 1, 1, 1 },
    { 0, 1, 1, 1, 0 }
  },
}

local CONFIG = {
  spellName = GLOBAL_SPELL_COOLDOWNS[3].name,
  level = 1,
  magLevel = 0,
  manaCost = GLOBAL_SPELL_COOLDOWNS[3].manaCost,
  spellId = 3,
  range = GLOBAL_SPELL_COOLDOWNS[3].range,
  aggressive = true,
  forwardCast = true,
  cooldown = GLOBAL_SPELL_COOLDOWNS[3].cooldown,
  type = COMBAT_ENERGYDAMAGE,
  -- sameTarget = true,
  
  timeBeetwean = 100,
  bounces = {
    max = GLOBAL_SPELL_COOLDOWNS[3].bon,
    chance = 100,
    -- sameTarget = true,
  },

  distanceEffect = 218,
  lineEffect = true,

  combat_config = {
    effect = 48,
  },

  defualtArea = { { 3 } },
  supports = {
    ["dot"] = false,
    ["bounce"] = true,
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

  local dmg = spellGlobalFormule(player, CONFIG, CONFIG_SUP, item)
  local combat = spellSetupCombat(player, CONFIG, CONFIG_SUP, area, dmg, force)
  spellSetupTargetCombat(player, combat, CONFIG, CONFIG_SUP, item)
  spellStartChaining(player, combat, CONFIG, CONFIG_SUP, item, force)
  return true
end

SPELLS[CONFIG.spellName] = {
  cast = function(player, item, force, mousePos)
    onCastSpell(player, item, false, force, mousePos)
  end,

  getInfo = function(player, item)
    return onCastSpell(player, item, true)
  end,

  getConfig = function()
    return CONFIG
  end,
  
  spellId = CONFIG.spellId,
}
