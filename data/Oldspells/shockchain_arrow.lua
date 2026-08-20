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
  spellName = GLOBAL_SPELL_COOLDOWNS[58].name,
  level = 1,
  magLevel = 0,
  manaCost = GLOBAL_SPELL_COOLDOWNS[58].manaCost,
  spellId = 58,
  range = GLOBAL_SPELL_COOLDOWNS[58].range,
  aggressive = true,
  forwardCast = true,
  cooldown = GLOBAL_SPELL_COOLDOWNS[58].cooldown,
  type = COMBAT_ENERGYDAMAGE,
  -- sameTarget = true,

  timeBeetwean = 100,
  bounces = {
    max = GLOBAL_SPELL_COOLDOWNS[58].bon,
    chance = 100,
    -- sameTarget = true,
  },

  distanceEffect = 109,

  combat_config = {
  --  effect = 48,
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
    if colleftInfo[player:getId()].attributesItems[285] then
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
    if math.random(100) <= 20 then
      target:addBuff(SHOCK)
    end
  end
  spellSetupTargetCombat(player, combat, CONFIG, CONFIG_SUP, item, extraFunc)
  if colleftInfo[player:getId()].attributesItems[285] then
    spellStartChaining(player, combat, CONFIG, CONFIG_SUP, item, force, nil, 637, 2)
  else
    spellStartChaining(player, combat, CONFIG, CONFIG_SUP, item, force, nil, 48, 0)
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
