local resizeTo = {
  [1] = {
    { 0, 1, 0 },
    { 0, 3, 0 },
  },
  [2] = {
    { 0, 0, 0 },
    { 0, 1, 0 },
    { 1, 3, 1 },
  },
  [3] = {
    { 0, 0, 0 },
    { 0, 0, 0 },
    { 0, 1, 0 },
    { 0, 1, 0 },
    { 1, 3, 1 },
  },
  [4] = {
    { 0, 0, 0 },
    { 0, 0, 0 },
    { 0, 1, 0 },
    { 1, 1, 1 },
    { 1, 3, 1 },
  },
}

local CONFIG = {
  spellName = GLOBAL_SPELL_COOLDOWNS[72].name,
  level = 1,
  magLevel = 0,
  precentCost = true,
  manaCost = GLOBAL_SPELL_COOLDOWNS[72].manaCost,
  spellId = 72,
  range = GLOBAL_SPELL_COOLDOWNS[72].range,
  aggressive = true,
  forwardCast = true,
  cooldown = GLOBAL_SPELL_COOLDOWNS[72].cooldown,
  type = COMBAT_ICEDAMAGE,
  targets = GLOBAL_SPELL_COOLDOWNS[72].split,
  -- dmgInfo = "hit 3 targets",

  combat_config = {
    effect = 475,
    distanceEffect = 125,
  },

  defualtArea = {
    { 0, 3, 0 },
  },

  diaoganlArea = {
    { 0, 3, 0 },
  },

  supports = {
    ["dot"] = false,
    ["split"] = true,
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
  if not variant then 
    return 
  end

  local tile = Tile(variant:getPosition())
  local target
  if tile then
    target = tile:getTopCreature()
  end
  if not target then
    target = player
  end
  local extraFunc = function(player, target)
    if math.random(100) <= 20 then
      local hasteAdded = target:getBaseSpeed() * 0.5
      local conditionHaste = Condition(CONDITION_HASTE, CONDITIONID_DEFAULT)
      conditionHaste:setParameter(CONDITION_PARAM_SUBID, 777778)
      conditionHaste:setParameter(CONDITION_PARAM_TICKS, 2 * 1000) --2 secs
      conditionHaste:setFormula(0.0, -hasteAdded, 0.0, -hasteAdded)
      target:addCondition(conditionHaste)
      target:addBuff(CHILL)
    end
  end
  spellSetupTargetCombat(player, combat, CONFIG, CONFIG_SUP, item, extraFunc)

  if spellExecuteCombat(player, combat, CONFIG, CONFIG_SUP, item, variant) then
    if CONFIG_SUP.targets >= 1 then
      local extraTargets = getClosestTargets(player, target, player:getPosition(), CONFIG_SUP.range, CONFIG_SUP.targets, true)
      for i = 1, #extraTargets do
        spellExecuteCombat(player, combat, CONFIG, CONFIG_SUP, item, Variant(extraTargets[i]), nil, true)
      end
    end

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
