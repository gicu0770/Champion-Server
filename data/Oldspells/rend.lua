local resizeTo = {

  [1] = {
    {0, 0, 1, 0, 0},
    {0, 1, 1, 1, 0},
    {1, 1, 3, 1, 1},
    {0, 1, 1, 1, 0},
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
    {0, 0, 0, 1, 0, 0, 0},
    {0, 1, 1, 1, 1, 1, 0},
    {0, 1, 1, 1, 1, 1, 0},
    {1, 1, 1, 3, 1, 1, 1},
    {0, 1, 1, 1, 1, 1, 0},
    {0, 1, 1, 1, 1, 1, 0},
    {0, 0, 0, 1, 0, 0, 0}
  },
  [4] = {
    {0, 0, 1, 1, 1, 0, 0},
    {0, 1, 1, 1, 1, 1, 0},
    {1, 1, 1, 1, 1, 1, 1},
    {1, 1, 1, 3, 1, 1, 1},
    {1, 1, 1, 1, 1, 1, 1},
    {0, 1, 1, 1, 1, 1, 0},
    {0, 0, 1, 1, 1, 0, 0}
  },
}

local CONFIG = {
  spellName = GLOBAL_SPELL_COOLDOWNS[41].name,
  level = 1,
  magLevel = 0,
  precentCost = true,
  manaCost = GLOBAL_SPELL_COOLDOWNS[41].manaCost,
  spellId = 41,
  range = GLOBAL_SPELL_COOLDOWNS[41].range,
  aggressive = true,
  selfTarget = true,
  cooldown = GLOBAL_SPELL_COOLDOWNS[41].cooldown,
  type = COMBAT_PHYSICALDAMAGE,
  dmgInfo = "over 2.5s",

  combat_config = {
    effect = 0,
  },

  defualtArea = {
    { 1, 1, 1 },
    { 1, 3, 1 },
    { 1, 1, 1 },
  },

  supports = {
    ["dot"] = true,
    ["aoe"] = true,
    ["close"] = true,
    ["affliction"] = true,
  },
}

local function onCastSpell(player, item, getInfoOnly, force, mousePos)
  if not spellCheckForCast(player, item, CONFIG.spellId, getInfoOnly, force) then return end
  local effectEx = 399
  local posEx = 2
  local CONFIG_SUP = item:applySupportSpells(CONFIG, player:getId())
  if colleftInfo[player:getId()].attributesItems[290] then
    CONFIG_SUP.resizeTo = 4
    effectEx = 698
    posEx = 4
  end
  local area, tempArea = spellSetupArea(CONFIG, CONFIG_SUP, resizeTo)

  if getInfoOnly then
    return spellGetInfoToSend(player, CONFIG, CONFIG_SUP, item, tempArea, dot)
  end
  if not checkCastableSpell(player, CONFIG, CONFIG_SUP, force) then return end


  local dmg = {0, 0}
  local dotDmg = spellGlobalFormule(player, CONFIG, CONFIG_SUP, item, true)
  local combat = spellSetupCombat(player, CONFIG, CONFIG_SUP, area, dmg, force)
  local extraFunc = function(player, target)
    target:startDOT(player, REND, dotDmg[1] / 5, false, 2500, 1)
    if math.random(100) <= 20 then
      target:startDOT(player, BLEED_ITEM, 0, false, 5000, 1)
    end
  end
  spellSetupTargetCombat(player, combat, CONFIG, CONFIG_SUP, item, extraFunc)

  if spellExecuteCombat(player, combat, CONFIG, CONFIG_SUP, item) then
    spellSetupCooldown(player, CONFIG, CONFIG_SUP, force)
    local playerPos = player:getPosition()
    position = Position(playerPos.x + posEx, playerPos.y + posEx, playerPos.z)
    position:sendMagicEffect(effectEx)
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