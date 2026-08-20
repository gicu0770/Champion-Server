local resizeTo = {

  [1] = {
    {0, 0, 0, 0, 0},
    {0, 1, 1, 1, 0},
    {0, 1, 3, 1, 0},
    {0, 1, 1, 1, 0},
    {0, 0, 0, 0, 0}
  },
}
local CONFIG = {
  spellName = GLOBAL_SPELL_COOLDOWNS[18].name,
  level = 1,
  magLevel = 0,
  manaCost = GLOBAL_SPELL_COOLDOWNS[18].manaCost,
  spellId = 18,
  range = GLOBAL_SPELL_COOLDOWNS[18].range,
  aggressive = true,
  forwardCast = true,
  cooldown = GLOBAL_SPELL_COOLDOWNS[18].cooldown,
  type = COMBAT_PHYSICALDAMAGE,
  -- sameTarget = true,

  timeBeetwean = 166,
  bounces = {
    max = GLOBAL_SPELL_COOLDOWNS[18].bon,
    chance = 100,
    -- sameTarget = true,
  },

  distanceEffect = 8,

  combat_config = {
  --  effect = 1,
  },

  defualtArea = { { 3 } },
  supports = {
    ["resize"] = false,
    ["bounce"] = true,
  },
}

local function onCastSpell(player, item, getInfoOnly, force, mousePos)
  if not spellCheckForCast(player, item, CONFIG.spellId, getInfoOnly, force) then return end
  local CONFIG_SUP = item:applySupportSpells(CONFIG, player:getId())
  if colleftInfo[player:getId()].attributesItems[282] then
    CONFIG_SUP.resizeTo = 1
  end
  local area, tempArea = spellSetupArea(CONFIG, CONFIG_SUP, resizeTo)

  if getInfoOnly then
    return spellGetInfoToSend(player, CONFIG, CONFIG_SUP, item, tempArea)
  end
  if not checkCastableSpell(player, CONFIG, CONFIG_SUP, force) then return end

  local dmg = spellGlobalFormule(player, CONFIG, CONFIG_SUP, item)
  local combat = spellSetupCombat(player, CONFIG, CONFIG_SUP, area, dmg, force)
  spellSetupTargetCombat(player, combat, CONFIG, CONFIG_SUP, item)
  if colleftInfo[player:getId()].attributesItems[282] then
    spellStartChaining(player, combat, CONFIG, CONFIG_SUP, item, force, nil, 549, 1)
  else
    spellStartChaining(player, combat, CONFIG, CONFIG_SUP, item, force)
  end
  
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
