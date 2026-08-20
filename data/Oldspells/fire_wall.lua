local resizeTo = {
  [1] = {
    {1, 1, 1, 1, 3, 1, 1, 1, 1},
  },

  [2] = {
    {1, 1, 1, 1, 1, 1, 1, 1, 1},
    {1, 1, 1, 1, 3, 1, 1, 1, 1},
  },

  [3] = {
    {1, 1, 1, 1, 1, 1, 1, 1, 1},
    {1, 1, 1, 1, 3, 1, 1, 1, 1},
    {1, 1, 1, 1, 1, 1, 1, 1, 1},
  },

  [4] = {
    {1, 1, 1, 1, 1, 1, 1, 1, 1},
    {1, 1, 1, 1, 1, 1, 1, 1, 1},
    {1, 1, 1, 1, 3, 1, 1, 1, 1},
    {1, 1, 1, 1, 1, 1, 1, 1, 1},
  },
}

local CONFIG = {
  spellName = GLOBAL_SPELL_COOLDOWNS[51].name,
  level = 1,
  magLevel = 0,
  precentCost = true,
  manaCost = GLOBAL_SPELL_COOLDOWNS[51].manaCost,
  spellId = 51,
  range = GLOBAL_SPELL_COOLDOWNS[51].range,
  aggressive = true,
  forwardCast = true,
  cooldown = GLOBAL_SPELL_COOLDOWNS[51].cooldown,
  type = COMBAT_FIREDAMAGE,
  dmgInfo = "x3",
  combat_config = {
    effect = 16,
    bottom = true,
    savePos = true,
  },

  defualtArea = {
    {1, 1, 1, 3, 1, 1, 1},
  },
  newArea = {
    {0, 1, 1, 1, 0, 0, 0, 1, 1, 1, 0},
    {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
    {1, 1, 1, 1, 1, 3, 1, 1, 1, 1, 1},
    {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
    {0, 1, 1, 1, 0, 0, 0, 1, 1, 1, 0}
  },

  supports = {
    ["dot"] = false,
    ["aoe"] = true,
    ["resize"] = true,
  },
}

local function onCastSpell(player, item, getInfoOnly, force, mousePos)
  if not spellCheckForCast(player, item, CONFIG.spellId, getInfoOnly, force) then return end
  local CONFIG_SUP = item:applySupportSpells(CONFIG, player:getId())
  local area
  local tempArea

  if colleftInfo[player:getId()].attributesItems[173] then
    tempArea = CONFIG.newArea
    area = createCombatArea(CONFIG.newArea)
  else
    area, tempArea = spellSetupArea(CONFIG, CONFIG_SUP, resizeTo)
  end
  if getInfoOnly then
    return spellGetInfoToSend(player, CONFIG, CONFIG_SUP, item, tempArea)
  end
  if not checkCastableSpell(player, CONFIG, CONFIG_SUP, force) then return end

  local dmg = spellGlobalFormule(player, CONFIG, CONFIG_SUP, item)
  local combat = spellSetupCombat(player, CONFIG, CONFIG_SUP, area, dmg, force)
  local extraFunc = function(player, target)
    if math.random(1,100) <= 20 then
      target:startDOT(player, IGNITE_ITEM, 0, false, 5000, 16)
    end
  end
  
  spellSetupTargetCombat(player, combat, CONFIG, CONFIG_SUP, item, extraFunc)
  local variant = spellSetupVariant(player, CONFIG, CONFIG_SUP, mousePos)
  if not variant then return end
  if spellExecuteCombat(player, combat, CONFIG, CONFIG_SUP, item, variant, mousePos) then
    local pid = player:getId()
    local uid = item:getRealUID()
    for i = 1, 2 do
      addEvent(function()
        local player = Player(pid)
        if not player or player:isRemoved() then return end
        local variant = spellSetupVariant(player, CONFIG, CONFIG_SUP, mousePos)
        if not variant then return end
        local item = Game.getRealUniqueItem(uid)
        if not item then return end
        spellExecuteCombat(player, combat, CONFIG, CONFIG_SUP, item, variant, mousePos, true)
        if i == 4 then
          spellCleanAfterCast(player, combat)
        end
      end, 1000 * i)
    end
    spellSetupCooldown(player, CONFIG, CONFIG_SUP, force)
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