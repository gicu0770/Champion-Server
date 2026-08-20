local CONFIG = {
  spellName = GLOBAL_SPELL_COOLDOWNS[122].name,
  level = 1,
  magLevel = 0,
  manaCost = GLOBAL_SPELL_COOLDOWNS[122].manaCost,
  spellId = 122,
  range = GLOBAL_SPELL_COOLDOWNS[122].range,
  aggressive = true,
  forwardCast = true,
  cooldown = GLOBAL_SPELL_COOLDOWNS[122].cooldown,
  type = COMBAT_ICEDAMAGE,
  -- sameTarget = true,

  timeBeetwean = 0,
  bounces = {
    max = GLOBAL_SPELL_COOLDOWNS[122].bon,
    chance = 100,
    -- sameTarget = true,
  },

  distanceEffect = 0,
  lineEffect = false,

  combat_config = {
  effect = 497,
	bottom = false,
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
  local extraFunc = function(player, target)
    if math.random(100) <= 20 then
      local hasteAdded = target:getBaseSpeed() * 0.5
      local conditionHaste = Condition(CONDITION_HASTE, CONDITIONID_DEFAULT)
      conditionHaste:setParameter(CONDITION_PARAM_SUBID, 777888)
      conditionHaste:setParameter(CONDITION_PARAM_TICKS, 2 * 1000) --2 secs
      conditionHaste:setFormula(0.0, -hasteAdded, 0.0, -hasteAdded)
      target:addCondition(conditionHaste)
      target:addBuff(CHILL)
    end
  end
  spellSetupTargetCombat(player, combat, CONFIG, CONFIG_SUP, item, extraFunc)
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
