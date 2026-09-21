local resizeTo = {
  [1] = {
    {1, 1, 1},
    {1, 3, 1},
    {1, 1, 1}
  }
}

local CONFIG = {
  spellName = GLOBAL_SPELL_COOLDOWNS[18].name,
  level = 1,
  magLevel = 0,
  manaCost = GLOBAL_SPELL_COOLDOWNS[18].manaCost,
  spellId = 18,
  range = GLOBAL_SPELL_COOLDOWNS[18].range or 4,
  aggressive = true,
  cooldown = GLOBAL_SPELL_COOLDOWNS[18].cooldown,
  type = COMBAT_ENERGYDAMAGE,

  combat_config = {
    effect = CONST_ME_PURPLEENERGY,
  },

  defualtArea = {
    {1, 1, 1},
    {1, 3, 1},
    {1, 1, 1}
  },

  supports = {
    ["dot"] = true,
    ["aoe"] = true,
    ["resize"] = true,
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

  local dmg = spellGlobalFormule(player, CONFIG, CONFIG_SUP, item)
  local combat = spellSetupCombat(player, CONFIG, CONFIG_SUP, area, dmg, force)

  -- Stun for 0.7s (700ms) on hit enemies
  local extraFunc = function(caster, target)
    if not target or target:isRemoved() then return end
    if caster and target:getId() == caster:getId() then return end

    local stun = Condition(CONDITION_STUN)
    stun:setParameter(CONDITION_PARAM_TICKS, 700)
    target:addCondition(stun)
    target:addBuff(STUN, 700)
    target:setProgressBar(700, false)
    Game.sendAnimatedText("STUN", target:getPosition(), TEXTCOLOR_YELLOW, "Reggae One-12px-bordered")
  end

  spellSetupTargetCombat(player, combat, CONFIG, CONFIG_SUP, item, extraFunc)

  local maxRange = CONFIG_SUP.range or CONFIG.range or 4
  local target = player:getTarget()
  local impactPos = nil

  if target and not target:isRemoved() and player:targetRechable(target:getPosition(), maxRange, false) then
    impactPos = target:getPosition()
  elseif mousePos and player:targetRechable(mousePos, maxRange, false) then
    impactPos = mousePos
  else
    impactPos = player:getPosition()
  end

  local variant = Variant(impactPos)
  player:getPosition():sendDistanceEffect(impactPos, 39)

  if spellExecuteCombat(player, combat, CONFIG, CONFIG_SUP, item, variant, mousePos) then
    spellSetupCooldown(player, CONFIG, CONFIG_SUP, force)
    impactPos:sendMagicEffect(CONST_ME_PURPLEENERGY)
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
