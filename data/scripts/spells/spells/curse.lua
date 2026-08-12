local resizeTo = {
  [1] = {
    {1, 0, 1},
    {0, 3, 0},
    {1, 0, 1}
  },

  [2] = {
    {1, 0, 0, 0, 1},
    {0, 1, 0, 1, 0},
    {0, 0, 3, 0, 0},
    {0, 1, 0, 1, 0},
    {1, 0, 0, 0, 1}
  },

  [3] = {
    {1, 0, 1, 0, 1},
    {0, 1, 0, 1, 0},
    {1, 0, 3, 0, 1},
    {0, 1, 0, 1, 0},
    {1, 0, 1, 0, 1}
  },

  [4] = {
    {1, 0, 1, 0, 1},
    {0, 1, 1, 1, 0},
    {1, 1, 3, 1, 1},
    {0, 1, 1, 1, 0},
    {1, 0, 1, 0, 1}
  },
}

local CONFIG = {
  spellName = "Curse",
  type = COMBAT_DEATHDAMAGE,
  level = 1,
  magLevel = 0,
  precentCost = true,
  manaCost = GLOBAL_SPELL_COOLDOWNS[7].manaCost,
  spellId = 7,
  range = GLOBAL_SPELL_COOLDOWNS[7].range,
  aggressive = true,
  forwardCast = true,
  needTarget = true,
  cooldown = GLOBAL_SPELL_COOLDOWNS[7].cooldown,
  dmgInfo = "over 5s",

  defualtArea = {{3}},

  combat_config = {
    effect = 18,
  },

  supports = {
    ["multicast"] = false,
    ["dot"] = true,
    ["single"] = true,
    ["affliction"] = true,
  },
}

local function onCastSpell(player, item, getInfoOnly, force, mousePos)
  if not spellCheckForCast(player, item, CONFIG.spellId, getInfoOnly, force) then return end
  local CONFIG_SUP = item:applySupportSpells(CONFIG, player:getId())
  local area, tempArea = spellSetupArea(CONFIG, CONFIG_SUP, resizeTo)

  if getInfoOnly then
    return spellGetInfoToSend(player, CONFIG, CONFIG_SUP, item, tempArea, true)
  end
  if not checkCastableSpell(player, CONFIG, CONFIG_SUP, force) then return end


  local dmg = {0,0}
  local dotDmg = spellGlobalFormule(player, CONFIG, CONFIG_SUP, item, true)
  local combat = spellSetupCombat(player, CONFIG, CONFIG_SUP, area, dmg, force)
  local extraFunc = function(player, target)
    local playerId = player:getId()
    local function afterDeath(target)
      local playerCast = Player(playerId)
      if not playerCast or not target then return end
      if not target:isMonster() then return end
      target:startDOT(playerCast, CURSE_RUNE_DOT, dotDmg[1] / 10, false, 5000, nil, nil, afterDeath)
    end
    target:startDOT(player, CURSE_RUNE_DOT, dotDmg[1] / 10, false, 5000, nil, nil, afterDeath)
    if math.random(100) <= 100 then
      target:startDOT(player, HARVEST_DEBUFF, 0, false, 5000, 18)
    end
  end
  spellSetupTargetCombat(player, combat, CONFIG, CONFIG_SUP, item, extraFunc)
  if spellExecuteCombat(player, combat, CONFIG, CONFIG_SUP, item) then
    spellSetupCooldown(player, CONFIG, CONFIG_SUP, force)
    spellCleanAfterCast(player, combat)
  end
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