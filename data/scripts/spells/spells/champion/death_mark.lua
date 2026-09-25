local CONFIG = {
  spellName = GLOBAL_SPELL_COOLDOWNS[12].name,
  level = 1,
  magLevel = 0,
  manaCost = GLOBAL_SPELL_COOLDOWNS[12].manaCost,
  spellId = 12,
  range = GLOBAL_SPELL_COOLDOWNS[12].range or 0,
  aggressive = false,
  selfTarget = true,
  cooldown = GLOBAL_SPELL_COOLDOWNS[12].cooldown,
  type = COMBAT_PHYSICALDAMAGE,

  combat_config = {
    effect = CONST_ME_POFF,
  },

  defualtArea = {
    {3}
  },

  supports = {
    ["dot"] = false,
    ["single"] = true,
  },
}

local function onCastSpell(player, item, getInfoOnly, force, mousePos)
  if not spellCheckForCast(player, item, CONFIG.spellId, getInfoOnly, force) then return end
  local CONFIG_SUP = item:applySupportSpells(CONFIG, player:getId())
  
  if getInfoOnly then
    return spellGetInfoToSend(player, CONFIG, CONFIG_SUP, item, CONFIG.defualtArea)
  end
  if not checkCastableSpell(player, CONFIG, CONFIG_SUP, force) then return end

  -- Smoke cloud effect
  player:getPosition():sendMagicEffect(CONST_ME_POFF)

  -- Invisibility condition (TFS 1.3 stealth - monsters ignore, no sparkles)
  local invisible = Condition(CONDITION_INVISIBLE)
  invisible:setParameter(CONDITION_PARAM_TICKS, 3500)
  player:addCondition(invisible)

  -- Stealth Outfit (Custom LookType 9 + hide health/mana/aura/wings)
  local invisibleOutfit = Condition(CONDITION_OUTFIT)
  invisibleOutfit:setParameter(CONDITION_PARAM_TICKS, 3500)
  invisibleOutfit:setOutfit({lookType = 9, lookHealthBar = 0, lookManaBar = 0, lookAura = 0, lookWings = 0})
  player:addCondition(invisibleOutfit)

  -- Instantly cancel target on all players & drop monster aggro
  player:cancelTargeters()

  -- Speed boost +35%
  local speed = Condition(CONDITION_HASTE)
  speed:setParameter(CONDITION_PARAM_TICKS, 3500)
  speed:setParameter(CONDITION_PARAM_SPEED, math.floor(player:getBaseSpeed() * 0.35))
  player:addCondition(speed)

  -- Set storage for Death Mark next attack buff
  player:setStorageValue(PlayerStorage.deathMarkActive, os.time() + 4) -- lasts up to 4s (same as stealth roughly)

  spellSetupCooldown(player, CONFIG, CONFIG_SUP, force)
  Position(player:getPosition().x + 1, player:getPosition().y + 1, player:getPosition().z):sendMagicEffect(506, 1)
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
