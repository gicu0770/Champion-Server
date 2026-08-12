local resizeTo = {
  [1] = {
    {0, 1, 0},
    {1, 3, 1},
    {0, 1, 0}
  },

  [2] = {
    {1, 1, 1},
    {1, 3, 1},
    {1, 1, 1}
  },

  [3] = {
    {0, 0, 1, 0, 0},
    {0, 1, 1, 1, 0},
    {1, 1, 3, 1, 1},
    {0, 1, 1, 1, 0},
    {0, 0, 1, 0, 0}
  },

  [4] = {
    {0, 1, 1, 1, 0},
    {1, 1, 1, 1, 1},
    {1, 1, 3, 1, 1},
    {1, 1, 1, 1, 1},
    {0, 1, 1, 1, 0}
  },
}

local CONFIG = {
  spellName = GLOBAL_SPELL_COOLDOWNS[28].name,
  level = 1,
  magLevel = 0,
  precentCost = true,
  manaCost = GLOBAL_SPELL_COOLDOWNS[28].manaCost,
  spellId = 28,
  lifeTap = false,
  range = GLOBAL_SPELL_COOLDOWNS[28].range,
  aggressive = true,
  forwardCast = true,
  cooldown = GLOBAL_SPELL_COOLDOWNS[28].cooldown,
  type = COMBAT_PHYSICALDAMAGE,
  targets = GLOBAL_SPELL_COOLDOWNS[28].split,
  dmgInfo = "over 2.5s",

  defualtArea = {{3}},

  combat_config = {
    effect = 676,
    bottom = false,
  },

  supports = {
    ["dot"] = true,
    ["lifeTap"] = false,
    ["split"] = true,
    ["close"] = true,
    ["affliction"] = true,
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

  local dmg = {0,0}
  local dotDmg = spellGlobalFormule(player, CONFIG, CONFIG_SUP, item, true)
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
    target:startDOT(player, PERFORATE, dotDmg[1] / 5, false, 2500)
    target:startDOT(player, BLEED_ITEM, 0, false, 5000, 1)
  end
  spellSetupTargetCombat(player, combat, CONFIG, CONFIG_SUP, item, extraFunc)
  local sparkCount = CONFIG_SUP.targets
  if colleftInfo[player:getId()].attributesItems[290] then
    sparkCount = sparkCount + US_ENCHANTMENTS[290].subvalue
  end
  if spellExecuteCombat(player, combat, CONFIG, CONFIG_SUP, item, variant) then
    if sparkCount >= 1 then
      local extraTargets = getClosestTargets(player, target, player:getPosition(), CONFIG_SUP.range, sparkCount, true)
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