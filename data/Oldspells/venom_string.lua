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
  spellName = GLOBAL_SPELL_COOLDOWNS[101].name,
  level = 1,
  magLevel = 0,
  manaCost = GLOBAL_SPELL_COOLDOWNS[101].manaCost,
  spellId = 101,
  range = GLOBAL_SPELL_COOLDOWNS[101].range,
  aggressive = true,
  cooldown = GLOBAL_SPELL_COOLDOWNS[101].cooldown,
  type = COMBAT_EARTHDAMAGE,
  forwardCast = true,
  dmgInfo = "over 2.5s",

  combat_config = {
    effect = 17,
    distanceEffect = 149,
  },

  defualtArea = {
    {0, 0, 0},
    {0, 3, 0},
    {0, 0, 0}
  },

  supports = {
    ["dot"] = true,
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

  local dmg = {0,0}
  local dotDmg = spellGlobalFormule(player, CONFIG, CONFIG_SUP, item, true)
  local combat = spellSetupCombat(player, CONFIG, CONFIG_SUP, area, dmg, force)
  local extraFunc = function(player, target)
    target:startDOT(player, VENOM_STING, dotDmg[1] / 5, false, 2500, 21)
    if math.random(100) <= 20 then -- 25% chance to poison
      target:startDOT(player, POISON_ITEM, 0, false, 5000)
    end
  end

  spellSetupTargetCombat(player, combat, CONFIG, CONFIG_SUP, item, extraFunc)
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