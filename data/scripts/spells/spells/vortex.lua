local resizeTo = {
  [1] = {
    { 0, 0, 1, 0, 0 },
    { 0, 1, 1, 1, 0 },
    { 1, 1, 3, 1, 1 },
    { 0, 1, 1, 1, 0 },
    { 0, 0, 1, 0, 0 }
  },
  [2] = {
    { 0, 1, 1, 1, 0 },
    { 1, 1, 1, 1, 1 },
    { 1, 1, 3, 1, 1 },
    { 1, 1, 1, 1, 1 },
    { 0, 1, 1, 1, 0 }
  },
  [3] = {
    { 0, 0, 1, 1, 1, 0, 0 },
    { 0, 1, 1, 1, 1, 1, 0 },
    { 1, 1, 1, 1, 1, 1, 1 },
    { 1, 1, 1, 3, 1, 1, 1 },
    { 1, 1, 1, 1, 1, 1, 1 },
    { 0, 1, 1, 1, 1, 1, 0 },
    { 0, 0, 1, 1, 1, 0, 0 }
  },
  [4] = {
    { 0, 0, 1, 1, 1, 1, 1, 0, 0 },
    { 0, 1, 1, 1, 1, 1, 1, 1, 0 },
    { 1, 1, 1, 1, 1, 1, 1, 1, 1 },
    { 1, 1, 1, 1, 1, 1, 1, 1, 1 },
    { 1, 1, 1, 1, 3, 1, 1, 1, 1 },
    { 1, 1, 1, 1, 1, 1, 1, 1, 1 },
    { 1, 1, 1, 1, 1, 1, 1, 1, 1 },
    { 0, 1, 1, 1, 1, 1, 1, 1, 0 },
    { 0, 0, 1, 1, 1, 1, 1, 0, 0 }
  },
}

local CONFIG = {
  spellName = "Vortex",
  level = 1,
  magLevel = 0,
  precentCost = true,
  manaCost = GLOBAL_SPELL_COOLDOWNS[8].manaCost,
  spellId = 8,
  range = GLOBAL_SPELL_COOLDOWNS[8].range,
  aggressive = true,
  forwardCast = true,
  cooldown = GLOBAL_SPELL_COOLDOWNS[8].cooldown,
  type = COMBAT_PHYSICALDAMAGE,

  combat_config = {
    effect = 0,
  },

  defualtArea = {
    { 1, 1, 1 },
    { 1, 3, 1 },
    { 1, 1, 1 }
  },

  supports = {
    ["dot"] = false,
    ["close"] = true,
    ["aoe"] = true,
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
  local variant = spellSetupVariant(player, CONFIG, CONFIG_SUP, mousePos)
  if not variant then return end
    local playerPos = player:getPosition()
    position = Position(playerPos.x + 2, playerPos.y + 2, playerPos.z)
    if spellExecuteCombat(player, combat, CONFIG, CONFIG_SUP, item, variant, mousePos) then
      Position(variant:getPosition().x + 2, variant:getPosition().y + 2, variant:getPosition().z):sendMagicEffect(474)
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
