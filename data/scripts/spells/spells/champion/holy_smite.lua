local resizeTo = {
  [1] = {
    {0, 1, 1, 1, 0},
    {1, 1, 1, 1, 1},
    {1, 1, 3, 1, 1},
    {1, 1, 1, 1, 1},
    {0, 1, 1, 1, 0}
  },
  [2] = {
    {1, 1, 1, 1, 1, 1, 1},
    {1, 1, 1, 1, 1, 1, 1},
    {1, 1, 1, 1, 1, 1, 1},
    {1, 1, 1, 3, 1, 1, 1},
    {1, 1, 1, 1, 1, 1, 1},
    {1, 1, 1, 1, 1, 1, 1},
    {1, 1, 1, 1, 1, 1, 1}
  }
}

local CONFIG = {
  spellName = GLOBAL_SPELL_COOLDOWNS[14].name,
  level = 1,
  magLevel = 0,
  manaCost = GLOBAL_SPELL_COOLDOWNS[14].manaCost,
  spellId = 14,
  range = GLOBAL_SPELL_COOLDOWNS[14].range,
  aggressive = true,
  selfTarget = true,
  cooldown = GLOBAL_SPELL_COOLDOWNS[14].cooldown,
  type = COMBAT_ENERGYDAMAGE,

  combat_config = {
    effect = 50,
  },
  defualtArea = {
    {0, 1, 1, 1, 0},
    {1, 1, 1, 1, 1},
    {1, 1, 3, 1, 1},
    {1, 1, 1, 1, 1},
    {0, 1, 1, 1, 0}
  },
  supports = {
    ['dot'] = false,
    ['close'] = true,
    ['aoe'] = true,
    ['resize'] = true,
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
  local variant = spellSetupVariant(player, CONFIG, CONFIG_SUP, mousePos)

  local extraFunc = function(caster, target)
    if not target or target:isRemoved() then return end
    target:addBuff(BLIND, 2000)
    Game.sendAnimatedText("BLIND", target:getPosition(), TEXTCOLOR_YELLOW, "Reggae One-12px-bordered")
  end

  spellSetupTargetCombat(player, combat, CONFIG, CONFIG_SUP, item, extraFunc)
  if spellExecuteCombat(player, combat, CONFIG, CONFIG_SUP, item, variant, mousePos) then
    spellSetupCooldown(player, CONFIG, CONFIG_SUP, force)
    player:getPosition():sendMagicEffect(CONST_ME_HOLYDAMAGE)
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