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
  spellName = GLOBAL_SPELL_COOLDOWNS[23].name,
  level = 1,
  magLevel = 0,
  precentCost = true,
  manaCost = GLOBAL_SPELL_COOLDOWNS[23].manaCost,
  spellId = 23,
  range = GLOBAL_SPELL_COOLDOWNS[23].range,
  aggressive = true,
  forwardCast = true,
  cooldown = GLOBAL_SPELL_COOLDOWNS[23].cooldown,
  type = COMBAT_EARTHDAMAGE,
  dmgInfo = "over 2.5s",
  -- sameTarget = true,

  distanceEffect = 136,
  config_combat = {
    effect = 21,
  },
  timeBeetwean = 100,
  bounces = {
    max = GLOBAL_SPELL_COOLDOWNS[23].bon,
    chance = 100,
    -- sameTarget = true,
  },

  defualtArea = { { 3 } },

  supports = {
    ["dot"] = true,
    ["bounce"] = true,
    ["affliction"] = true,
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

  local dmg = {0,0}
  local dotDmg = spellGlobalFormule(player, CONFIG, CONFIG_SUP, item, true)
  local combat = spellSetupCombat(player, CONFIG, CONFIG_SUP, area, dmg, force)
  local extraFunc = function(player, target)
    target:startDOT(player, POISON_PLAGUE, dotDmg[1] / 5, false, 2500, 21)
    if math.random(100) <= 20 then -- 25% chance to poison
      target:startDOT(player, POISON_ITEM, 0, false, 5000)
    end
  end
  spellSetupTargetCombat(player, combat, CONFIG, CONFIG_SUP, item, extraFunc)
  spellStartChaining(player, combat, CONFIG, CONFIG_SUP, item, force)
--  spellCleanAfterCast(player, combat)
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