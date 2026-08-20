local resizeTo = {
  [1] = {
    {0, 0, 1, 0, 0},
    {0, 1, 1, 0, 0},
    {1, 1, 3, 0, 0},
    {0, 1, 1, 0, 0},
    {0, 0, 1, 0, 0}
  },

  [2] = {
    {0, 1, 1, 1, 0},
    {1, 1, 1, 1, 1},
    {1, 1, 3, 1, 1},
    {1, 1, 1, 1, 1},
    {0, 1, 1, 1, 0}
  },

  [3] = {
    {0, 0, 1, 1, 1, 0, 0},
    {0, 1, 1, 1, 1, 1, 0},
    {1, 1, 1, 1, 1, 1, 1},
    {1, 1, 1, 3, 1, 1, 1},
    {1, 1, 1, 1, 1, 1, 1},
    {0, 1, 1, 1, 1, 1, 0},
    {0, 0, 1, 1, 1, 0, 0}
  },

  [4] = {
    {0, 1, 1, 1, 1, 1, 0},
    {1, 1, 1, 1, 1, 1, 1},
    {1, 1, 1, 1, 1, 1, 1},
    {1, 1, 1, 3, 1, 1, 1},
    {1, 1, 1, 1, 1, 1, 1},
    {1, 1, 1, 1, 1, 1, 1},
    {0, 1, 1, 1, 1, 1, 0}
  },
}

local CONFIG = {
  spellName = GLOBAL_SPELL_COOLDOWNS[49].name,
  level = 1,
  magLevel = 0,
  manaCost = GLOBAL_SPELL_COOLDOWNS[49].manaCost,
  spellId = 49,
  range = GLOBAL_SPELL_COOLDOWNS[49].range,
  aggressive = true,
  cooldown = GLOBAL_SPELL_COOLDOWNS[49].cooldown,
  type = COMBAT_ICEDAMAGE,
  forwardCast = true,

  combat_config = {
    effect = 0,
    distanceEffect = 249,
  },

  defualtArea = {
    {1, 1, 1},
    {1, 3, 1},
    {1, 1, 1}
  },

  supports = {
    ["dot"] = false,
    ["aoe"] = true,
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
  local variant = spellSetupVariant(player, CONFIG, CONFIG_SUP, mousePos)
  if not variant then return end
  local dmg = spellGlobalFormule(player, CONFIG, CONFIG_SUP, item)
  local dotDmg = spellGlobalFormule(player, CONFIG, CONFIG_SUP, item, true)
  local combat = spellSetupCombat(player, CONFIG, CONFIG_SUP, area, dmg, force)
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
  if spellExecuteCombat(player, combat, CONFIG, CONFIG_SUP, item, nil, mousePos) then
    local playerPos = variant:getPosition()
    position = Position(playerPos.x + 2, playerPos.y + 2, playerPos.z)
    position:sendMagicEffect(654)
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