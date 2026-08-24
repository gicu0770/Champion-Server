local CONFIG = {
  spellName = GLOBAL_SPELL_COOLDOWNS[3].name,
  level = 1,
  magLevel = 0,
  manaCost = GLOBAL_SPELL_COOLDOWNS[3].manaCost,
  spellId = 3,
  range = 0,
  aggressive = false,
  cooldown = GLOBAL_SPELL_COOLDOWNS[3].cooldown,
  type = COMBAT_ENERGYDAMAGE,
  selfTarget = true,

  combat_config = {
    effect = 488,
  },
  effectEx = 488,
  offsetX = 3,
  offsetY = 3,

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

  local spellLevel = 1
  if CONFIG_SUP and CONFIG_SUP.level and CONFIG_SUP.level > 0 then
    spellLevel = CONFIG_SUP.level
  elseif item and item:getId() > 0 then
    spellLevel = item:getCustomAttribute("level") or 1
  end

  local dmgPercent = 30 + (math.max(1, spellLevel) - 1) * 5
  player:setStorageValue(PlayerStorage.vengeanceFlameDmg, dmgPercent)

  -- Add Buff for 10s (10000 ms)
  player:addBuff(VENGEANCE_FLAME, 10000)

  -- Speed bonus +30% for 10s
  local speed = math.floor(player:getBaseSpeed() * 0.30)
  if speed > 0 then
    local speedCondition = Condition(CONDITION_HASTE)
    speedCondition:setParameter(CONDITION_PARAM_TICKS, 10000)
    speedCondition:setParameter(CONDITION_PARAM_SPEED, speed)
    player:addCondition(speedCondition)
  end

  -- Visual Effect on player
  local playerPos = player:getPosition()
  local effectPos = Position(playerPos.x + (CONFIG.offsetX or 3), playerPos.y + (CONFIG.offsetY or 3), playerPos.z)
  effectPos:sendMagicEffect(CONFIG.effectEx or 488)

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
