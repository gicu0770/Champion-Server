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

  if mousePos then
    local dir = spellGetDirectionTo(player:getPosition(), mousePos)
    if dir then
      player:setDirection(dir)
    end
  end

  local dmg = spellGlobalFormule(player, CONFIG, CONFIG_SUP, item)
  local combat = spellSetupCombat(player, CONFIG, CONFIG_SUP, area, dmg, force)

  -- Reduce Physical and Magic Defense by 20% for 4 seconds on hit targets
  local extraFunc = function(caster, target)
    if not target or target:isRemoved() then return end
    if caster and target:getId() == caster:getId() then return end

    -- Apply Arcane Shred debuff (-20% Physical & Magic Defense for 4 seconds)
    target:addBuff(ARCANE_SHRED_DEBUFF, 4000)
    target:getPosition():sendMagicEffect(CONST_ME_MAGIC_RED)
  end

  spellSetupTargetCombat(player, combat, CONFIG, CONFIG_SUP, item, extraFunc)

  local variant = Variant(player, true)
  if spellExecuteCombat(player, combat, CONFIG, CONFIG_SUP, item, variant, mousePos) then
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
