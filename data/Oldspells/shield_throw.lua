local CONFIG = {
  spellName = GLOBAL_SPELL_COOLDOWNS[85].name,
  level = 1,
  magLevel = 0,
  manaCost = GLOBAL_SPELL_COOLDOWNS[85].manaCost,
  spellId = 85,
  range = GLOBAL_SPELL_COOLDOWNS[85].range,
  aggressive = true,
  forwardCast = true,
  cooldown = GLOBAL_SPELL_COOLDOWNS[85].cooldown,
  type = COMBAT_PHYSICALDAMAGE,
  -- sameTarget = true,

  timeBeetwean = 166,
  bounces = {
    max = GLOBAL_SPELL_COOLDOWNS[85].bon,
    chance = 100,
    -- sameTarget = true,
  },

  distanceEffect = 239,

  combat_config = {
    effect = 1,
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
  local area, tempArea = spellSetupArea(CONFIG, CONFIG_SUP, resizeTo)

  if getInfoOnly then
    return spellGetInfoToSend(player, CONFIG, CONFIG_SUP, item, tempArea)
  end
  if not checkCastableSpell(player, CONFIG, CONFIG_SUP, force) then return end
  local dmg = spellGlobalFormule(player, CONFIG, CONFIG_SUP, item)
  local combat = spellSetupCombat(player, CONFIG, CONFIG_SUP, area, dmg, force)
    if not colleftInfo[player:getId()].isShield then
    player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "You need to have a shield equipped to use this spell.")
    return
  end
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
