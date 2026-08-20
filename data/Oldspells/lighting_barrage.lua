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
  spellName = GLOBAL_SPELL_COOLDOWNS[25].name,
  level = 1,
  magLevel = 0,
  precentCost = true,
  manaCost = GLOBAL_SPELL_COOLDOWNS[25].manaCost,
  spellId = 25,
  range = GLOBAL_SPELL_COOLDOWNS[25].range,
  aggressive = true,
  forwardCast = true,
  needTarget = true,
  cooldown = GLOBAL_SPELL_COOLDOWNS[25].cooldown,
  type = COMBAT_ENERGYDAMAGE,
  dmgInfo = "x2",

  defualtArea = {{3}},

  combat_config = {
    effect = 591,
    distanceEffect = 270,
  },

  supports = {
    ["dot"] = false,
    ["single"] = true,
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
  spellSetupTargetCombat(player, combat, CONFIG, CONFIG_SUP, item)
  local variant = spellSetupVariant(player, CONFIG, CONFIG_SUP, mousePos)
  if not variant then return end
    local sparkCount = 1
    if colleftInfo[player:getId()].attributesItems[285] then
      sparkCount = US_ENCHANTMENTS[285].subvalue2
    end
  if spellExecuteCombat(player, combat, CONFIG, CONFIG_SUP, item, variant, mousePos) then
    local pid = player:getId()
    local uid = item:getRealUID()
    for i = 1, sparkCount do
      addEvent(function()
        local player = Player(pid)
        if not player or player:isRemoved() then return end
        local variant = spellSetupVariant(player, CONFIG, CONFIG_SUP, mousePos)
        if not variant then return end
        local item = Game.getRealUniqueItem(uid)
        if not item then return end
        spellExecuteCombat(player, combat, CONFIG, CONFIG_SUP, item, variant, mousePos, true)
        if i == sparkCount then
          spellCleanAfterCast(player, combat)
        end
      end, 333 * i)
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