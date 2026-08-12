local resizeTo = {
  [1] = {
    {0, 0, 0},
    {0, 3, 0},
    {0, 0, 0}
  },

  [2] = {
    {0, 0, 0},
    {0, 3, 0},
    {0, 0, 0}
  },

  [3] = {
    {0, 0, 0},
    {0, 3, 0},
    {0, 0, 0}
  },

  [4] = {
    {0, 0, 0},
    {0, 3, 0},
    {0, 0, 0}
  },
}

local CONFIG = {
  spellName = GLOBAL_SPELL_COOLDOWNS[66].name,
  level = 1,
  magLevel = 0,
  manaCost = GLOBAL_SPELL_COOLDOWNS[66].manaCost,
  spellId = 66,
  range = GLOBAL_SPELL_COOLDOWNS[66].range,
  aggressive = true,
  cooldown = GLOBAL_SPELL_COOLDOWNS[66].cooldown,
  type = COMBAT_ENERGYDAMAGE,
  forwardCast = true,
  dmgInfo = "x2",
  critC = 5,
  critM = 10,

  combat_config = {
    effect = 48,
    distanceEffect = 98,
  },

  defualtArea = {
    {0, 0, 0},
    {0, 3, 0},
    {0, 0, 0}
  },

  supports = {
    ["dot"] = false,
    ["single"] = true,
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
  spellSetupTargetCombat(player, combat, CONFIG, CONFIG_SUP, item)
  local variant = spellSetupVariant(player, CONFIG, CONFIG_SUP, mousePos)
  if not variant then return end
  if spellExecuteCombat(player, combat, CONFIG, CONFIG_SUP, item, variant, mousePos) then
    local pid = player:getId()
    local uid = item:getRealUID()
    for i = 1, 1 do
      addEvent(function()
        local player = Player(pid)
        if not player or player:isRemoved() then return end
        local variant = spellSetupVariant(player, CONFIG, CONFIG_SUP, mousePos)
        if not variant then return end
        local item = Game.getRealUniqueItem(uid)
        if not item then return end
        spellExecuteCombat(player, combat, CONFIG, CONFIG_SUP, item, variant, mousePos, true)
        if i == 1 then
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