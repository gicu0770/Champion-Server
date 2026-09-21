local resizeTo = {
  [1] = {
    {1, 1, 1},
    {1, 3, 1},
    {1, 1, 1}
  },
  [2] = {
    {0, 1, 1, 1, 0},
    {1, 1, 1, 1, 1},
    {1, 1, 3, 1, 1},
    {1, 1, 1, 1, 1},
    {0, 1, 1, 1, 0}
  },
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
    ["single"] = true,
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

  -- Stun for 0.7s
  local extraFunc = function(player, target)
      if target:isCreature() then
          local stun = Condition(CONDITION_PARALYZE)
          stun:setParameter(CONDITION_PARAM_TICKS, 700)
          stun:setParameter(CONDITION_PARAM_SPEED, -3000)
          target:addCondition(stun)
      end
  end

  spellSetupTargetCombat(player, combat, CONFIG, CONFIG_SUP, item, extraFunc)
  spellSetupAuraCast(player, CONFIG, CONFIG_SUP, item)
  
  if mousePos then
      spellExecuteCombat(player, item, combat, CONFIG_SUP, mousePos)
  else
      local target = player:getTarget()
      if target then
          spellExecuteCombat(player, item, combat, CONFIG_SUP, target:getPosition())
      else
          spellExecuteCombat(player, item, combat, CONFIG_SUP, player:getPosition())
      end
  end

  spellSetupCooldown(player, CONFIG, CONFIG_SUP)
end

function onUse(player, item, fromPosition, target, toPosition, isHotkey)
  return onCastSpell(player, item, false, false, toPosition)
end

function getInfo(player, item)
  return onCastSpell(player, item, true)
end
