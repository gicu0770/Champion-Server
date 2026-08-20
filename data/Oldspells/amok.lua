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
  spellName = GLOBAL_SPELL_COOLDOWNS[26].name,
  level = 1,
  magLevel = 0,
  precentCost = true,
  manaCost = GLOBAL_SPELL_COOLDOWNS[26].manaCost,
  spellId = 26,
  range = GLOBAL_SPELL_COOLDOWNS[26].range,
  aggressive = true,
  directional = true,
  cooldown = GLOBAL_SPELL_COOLDOWNS[26].cooldown,
  type = COMBAT_PHYSICALDAMAGE,
  critC = 5,
  critM = 10,
  -- dmgInfo = "4",

  combat_config = {
    effect = 176,
  },

  defualtArea = {
    { 0, 3, 0 },
  },
  newArea = {
    {0, 1, 1, 1, 0},
    {1, 1, 1, 1, 1},
    {1, 1, 3, 1, 1},
    {1, 1, 1, 1, 1},
    {0, 1, 1, 1, 0}
  },

  supports = {
    ["dot"] = false,
    ["close"] = true,
    ["single"] = true,
  },
}

local function onCastSpell(player, item, getInfoOnly, force, mousePos)
  if not spellCheckForCast(player, item, CONFIG.spellId, getInfoOnly, force) then return end
  local CONFIG_SUP = item:applySupportSpells(CONFIG, player:getId())
  local area
  local tempArea

  if colleftInfo[player:getId()].attributesItems[183] then
    tempArea = CONFIG.newArea
    area = createCombatArea(CONFIG.newArea)
  else
    area, tempArea = spellSetupArea(CONFIG, CONFIG_SUP, resizeTo)
  end
  if getInfoOnly then
    return spellGetInfoToSend(player, CONFIG, CONFIG_SUP, item, tempArea)
  end
  if not checkCastableSpell(player, CONFIG, CONFIG_SUP, force) then return end
  local variant = spellSetupVariant(player, CONFIG, CONFIG_SUP, mousePos)
  if not variant then return end

  local dmg = spellGlobalFormule(player, CONFIG, CONFIG_SUP, item)
  local combat = spellSetupCombat(player, CONFIG, CONFIG_SUP, area, dmg, force)
  local extraFunc = function(player, target)
      player:addBuff(AMOK)
      local amokStack = player:getBuff(AMOK)
      if amokStack then
        local amokStackMultipler = amokStack.stacks * 5
        if amokStackMultipler then
          local conditionHaste = Condition(CONDITION_ATTRIBUTES)
          conditionHaste:setParameter(CONDITION_PARAM_SUBID, 712346)
          conditionHaste:setParameter(CONDITION_PARAM_ATTACKSPEED, amokStackMultipler)
          conditionHaste:setParameter(CONDITION_PARAM_TICKS, 5000) -- 5 secs
          player:addCondition(conditionHaste)
        end
      end
  end
  spellSetupTargetCombat(player, combat, CONFIG, CONFIG_SUP, item, extraFunc)
  spellExecuteCombat(player, combat, CONFIG, CONFIG_SUP, item, variant, mousePos)
  spellSetupCooldown(player, CONFIG, CONFIG_SUP, force)
  spellCleanAfterCast(player, combat)
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
