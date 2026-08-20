local CONFIG = {
  spellName = GLOBAL_SPELL_COOLDOWNS[115].name,
  level = 1,
  magLevel = 0,
  manaCost = GLOBAL_SPELL_COOLDOWNS[115].manaCost,
  spellId = 115,
  range = GLOBAL_SPELL_COOLDOWNS[115].range,
  aggressive = true,
  forwardCast = true,
  cooldown = GLOBAL_SPELL_COOLDOWNS[115].cooldown,
  type = COMBAT_DEATHDAMAGE,
  -- sameTarget = true,

  timeBeetwean = 166,
  bounces = {
    max = GLOBAL_SPELL_COOLDOWNS[115].bon,
    chance = 100,
    -- sameTarget = true,
  },

  distanceEffect = 268,

  combat_config = {
  --  effect = 18,
  },

  defualtArea = { { 3 } },
  newArea = { 
    {1, 1, 1 },
    {1, 3, 1 },
    {1, 1, 1 }
  },
  supports = {
    ["resize"] = false,
    ["bounce"] = true,
  },
}

local function onCastSpell(player, item, getInfoOnly, force, mousePos)
  if not spellCheckForCast(player, item, CONFIG.spellId, getInfoOnly, force) then return end
  local CONFIG_SUP = item:applySupportSpells(CONFIG, player:getId())
  local area
  local tempArea

  if colleftInfo[player:getId()].attributesItems[143] then
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

  if colleftInfo[player:getId()].attributesItems[143] then
    spellStartChaining(player, combat, CONFIG, CONFIG_SUP, item, force, nil, 651, 3)
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