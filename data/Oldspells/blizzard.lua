local resizeTo = {
  [1] = {
    {0, 0, 0, 1, 0, 0, 0},
    {0, 0, 1, 1, 1, 0, 0},
    {0, 1, 1, 1, 1, 1, 0},
    {1, 1, 1, 3, 1, 1, 1},
    {0, 1, 1, 1, 1, 1, 0},
    {0, 0, 1, 1, 1, 0, 0},
    {0, 0, 0, 1, 0, 0, 0}
  },

  [2] = {
    {0, 0, 1, 1, 1, 0, 0},
    {0, 1, 1, 1, 1, 1, 0},
    {1, 1, 1, 1, 1, 1, 1},
    {1, 1, 1, 3, 1, 1, 1},
    {1, 1, 1, 1, 1, 1, 1},
    {0, 1, 1, 1, 1, 1, 0},
    {0, 0, 1, 1, 1, 0, 0}
  },

  [3] = {
    {0, 1, 1, 1, 1, 1, 0},
    {1, 1, 1, 1, 1, 1, 1},
    {1, 1, 1, 1, 1, 1, 1},
    {1, 1, 1, 3, 1, 1, 1},
    {1, 1, 1, 1, 1, 1, 1},
    {1, 1, 1, 1, 1, 1, 1},
    {0, 1, 1, 1, 1, 1, 0}
  },
  [4] = {
    {0, 0, 0, 1, 1, 1, 0, 0, 0},
    {0, 0, 1, 1, 1, 1, 1, 0, 0},
    {0, 1, 1, 1, 1, 1, 1, 1, 0},
    {1, 1, 1, 1, 1, 1, 1, 1, 1},
    {1, 1, 1, 1, 3, 1, 1, 1, 1},
    {1, 1, 1, 1, 1, 1, 1, 1, 1},
    {0, 1, 1, 1, 1, 1, 1, 1, 0},
    {0, 0, 1, 1, 1, 1, 1, 0, 0},
    {0, 0, 0, 1, 1, 1, 0, 0, 0},
  },
}
local CONFIG = {
  spellName = GLOBAL_SPELL_COOLDOWNS[75].name,
  level = 1,
  magLevel = 0,
  precentCost = true,
  manaCost = GLOBAL_SPELL_COOLDOWNS[75].manaCost,
  spellId = 75,
  range = GLOBAL_SPELL_COOLDOWNS[75].range,
  aggressive = true,
  forwardCast = true,
  cooldown = GLOBAL_SPELL_COOLDOWNS[75].cooldown,
  type = COMBAT_ICEDAMAGE,
  defualtArea = {
    {0, 0, 0, 1, 0, 0, 0},
    {0, 0, 1, 1, 1, 0, 0},
    {0, 1, 1, 1, 1, 1, 0},
    {1, 1, 1, 3, 1, 1, 1},
    {0, 1, 1, 1, 1, 1, 0},
    {0, 0, 1, 1, 1, 0, 0},
    {0, 0, 0, 1, 0, 0, 0}
  },
  defualtAreaEx = {
    {0, 0, 0, 1, 1, 1, 0, 0, 0},
    {0, 0, 1, 1, 1, 1, 1, 0, 0},
    {0, 1, 1, 1, 1, 1, 1, 1, 0},
    {1, 1, 1, 1, 1, 1, 1, 1, 1},
    {1, 1, 1, 1, 3, 1, 1, 1, 1},
    {1, 1, 1, 1, 1, 1, 1, 1, 1},
    {0, 1, 1, 1, 1, 1, 1, 1, 0},
    {0, 0, 1, 1, 1, 1, 1, 0, 0},
    {0, 0, 0, 1, 1, 1, 0, 0, 0},
  },

  supports = {
    ["dot"] = true,
    ["aoe"] = true,
  },
}

local function spellCallbackStorm2(cid, position, count)
  local origin = Position(position.x - 4, position.y - 4, position.z)
  local creature = Creature(cid)
  if creature then
      if math.random(1, 10) == 1 then
          position:sendMagicEffect(123)
          origin:sendDistanceEffect(position, 126)
      end
      if count < 6 then
          count = count + 1
          addEvent(spellCallbackStorm2, 100, cid, position, count)
      end
  end
end

local function onCastSpell(player, item, getInfoOnly, force, mousePos)
  if not spellCheckForCast(player, item, CONFIG.spellId, getInfoOnly, force) then return end
  local CONFIG_SUP = item:applySupportSpells(CONFIG, player:getId())
  local area, tempArea = spellSetupArea(CONFIG, CONFIG_SUP, resizeTo)

  if getInfoOnly then
    return spellGetInfoToSend(player, CONFIG, CONFIG_SUP, item, tempArea)
  end
  if not checkCastableSpell(player, CONFIG, CONFIG_SUP, force) then return end

  local dmg = spellGlobalFormule(player, CONFIG, CONFIG_SUP, item)
  local dotDmg = spellGlobalFormule(player, CONFIG, CONFIG_SUP, item, true, true)
  local combat = spellSetupCombat(player, CONFIG, CONFIG_SUP, area, dmg, force)
  local combatUnique = spellSetupCombat(player, CONFIG, CONFIG_SUP, createCombatArea(CONFIG.defualtAreaEx), {dmg[1]*0.2,dmg[2]*0.2}, force)
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
  function onTargetTile(creature, position)
    spellCallbackStorm2(creature:getId(), position, 0)
  end
  spellSetupTragetTile(player, combat, CONFIG, CONFIG_SUP, item, onTargetTile)

  local variant = spellSetupVariant(player, CONFIG, CONFIG_SUP, mousePos)
  if not variant then return end
  spellExecuteCombat(player, combat, CONFIG, CONFIG_SUP, item, variant, mousePos)
  if colleftInfo[player:getId()].attributesItems[156] then
    local effectPosition = variant:getPosition()
    effectPosition = Position(effectPosition.x + 6, effectPosition.y + 6, effectPosition.z)
    effectPosition:sendMagicEffect(578, 1)
    spellExecuteCombat(player, combatUnique, CONFIG, CONFIG_SUP, item, variant, mousePos)
  end
  spellCleanAfterCast(player, combat)
  spellSetupCooldown(player, CONFIG, CONFIG_SUP, force)
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