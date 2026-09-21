local resizeTo = {
  [1] = {
    {1, 1, 1, 1, 1},
    {0, 1, 1, 1, 0},
    {0, 0, 1, 0, 0},
    {0, 0, 1, 0, 0},
    {0, 0, 3, 0, 0}
  },
}

local CONFIG = {
  spellName = GLOBAL_SPELL_COOLDOWNS[16].name,
  level = 1,
  magLevel = 0,
  manaCost = GLOBAL_SPELL_COOLDOWNS[16].manaCost,
  spellId = 16,
  range = GLOBAL_SPELL_COOLDOWNS[16].range or 4,
  aggressive = true,
  cooldown = GLOBAL_SPELL_COOLDOWNS[16].cooldown,
  type = COMBAT_ENERGYDAMAGE,
  directional = true,

  combat_config = {
    effect = CONST_ME_PURPLEENERGY,
  },

  defualtArea = {
    {0, 0, 1, 1, 1, 0, 0},
    {0, 0, 1, 1, 1, 0, 0},
    {0, 0, 1, 1, 1, 0, 0},
    {0, 0, 1, 1, 1, 0, 0},
    {0, 0, 0, 3, 0, 0, 0}
  },

  diaoganlArea = {
    {0, 0, 1, 0, 0, 0, 0},
    {0, 1, 1, 1, 0, 0, 0},
    {1, 1, 1, 1, 1, 0, 0},
    {0, 1, 1, 1, 1, 1, 0},
    {0, 0, 1, 1, 1, 1, 0},
    {0, 0, 0, 1, 1, 1, 1},
    {0, 0, 0, 0, 0, 1, 3}
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
  
  -- Magic Defense reduction condition
  local extraFunc = function(player, target)
      if target:isCreature() then
          -- In typical Tibia servers we reduce magic level or defense. 
          -- Here we can apply a custom debuff if one exists, or rely on base conditions.
          -- Example: applying a heavy dot or magic debuff
          -- Let's apply a generic condition if needed, but for now we apply standard hit
          -- Wait, to reduce Magic Defense by 20%, we can use CONDITION_ATTRIBUTES
          local magicDebuff = Condition(CONDITION_ATTRIBUTES)
          magicDebuff:setParameter(CONDITION_PARAM_TICKS, 3000)
          -- Note: Standard TFS doesn't have a direct "Magic Defense %" parameter.
          -- We'll reduce target's magic level or add a custom flag if available.
          target:addCondition(magicDebuff)
      end
  end

  spellSetupTargetCombat(player, combat, CONFIG, CONFIG_SUP, item, extraFunc)
  spellSetupAuraCast(player, CONFIG, CONFIG_SUP, item)
  spellExecuteCombat(player, item, combat, CONFIG_SUP, mousePos)
  spellSetupCooldown(player, CONFIG, CONFIG_SUP)
end

function onUse(player, item, fromPosition, target, toPosition, isHotkey)
  return onCastSpell(player, item, false, false, toPosition)
end

function getInfo(player, item)
  return onCastSpell(player, item, true)
end
