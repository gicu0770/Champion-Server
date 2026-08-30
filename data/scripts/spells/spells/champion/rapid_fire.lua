local CONFIG = {
  spellName = GLOBAL_SPELL_COOLDOWNS[7].name,
  level = 1,
  magLevel = 0,
  manaCost = GLOBAL_SPELL_COOLDOWNS[7].manaCost,
  spellId = 7,
  range = 0,
  aggressive = false,
  cooldown = GLOBAL_SPELL_COOLDOWNS[7].cooldown,
  type = COMBAT_PHYSICALDAMAGE,
  selfTarget = true,

  combat_config = {
    effect = CONST_ME_MAGIC_GREEN,
  },

  supports = {
    ["dot"] = false,
    ["aoe"] = false,
    ["resize"] = false,
  }
}

local function onCastSpell(player, item, getInfoOnly, force, mousePos)
  if not spellCheckForCast(player, item, CONFIG.spellId, getInfoOnly, force) then return end
  local CONFIG_SUP = item:applySupportSpells(CONFIG, player:getId())
  if getInfoOnly then
    return spellGetInfoToSend(player, CONFIG, CONFIG_SUP, item, nil)
  end
  if not checkCastableSpell(player, CONFIG, CONFIG_SUP, force) then return end

  -- Add Rapid Fire Buff for 5s (5000 ms)
  player:addBuff(MIA_RAPID_FIRE, 5000)

  -- Attack Speed bonus +40% for 5s (5000 ms)
  local asCondition = Condition(CONDITION_ATTRIBUTES)
  asCondition:setParameter(CONDITION_PARAM_TICKS, 5000)
  asCondition:setParameter(CONDITION_PARAM_ATTACKSPEED, 40)
  player:addCondition(asCondition)

  -- Visual Effect on player
  player:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)

  spellSetupCooldown(player, CONFIG, CONFIG_SUP, force)
  if not force then
    spellTakeCost(player, CONFIG, CONFIG_SUP)
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
