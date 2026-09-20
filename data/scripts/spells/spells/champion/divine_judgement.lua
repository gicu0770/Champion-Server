local resizeTo = {
  [1] = {
    {1, 1, 1, 1, 1},
    {1, 1, 1, 1, 1},
    {1, 1, 3, 1, 1},
    {1, 1, 1, 1, 1},
    {1, 1, 1, 1, 1}
  }
}

local CONFIG = {
  spellName = GLOBAL_SPELL_COOLDOWNS[15].name,
  level = 1,
  magLevel = 0,
  manaCost = GLOBAL_SPELL_COOLDOWNS[15].manaCost,
  spellId = 15,
  range = GLOBAL_SPELL_COOLDOWNS[15].range,
  aggressive = true,
  cooldown = GLOBAL_SPELL_COOLDOWNS[15].cooldown,
  type = COMBAT_ENERGYDAMAGE,


  defualtArea = {
    {1, 1, 1, 1, 1},
    {1, 1, 1, 1, 1},
    {1, 1, 3, 1, 1},
    {1, 1, 1, 1, 1},
    {1, 1, 1, 1, 1}
  },
    combat_config = {
    effect = 50,
  },
  supports = {
    ['dot'] = false,
    ['close'] = false,
    ['aoe'] = true,
    ['resize'] = true,
  },
}

local function isAlly(caster, other)
  if not other or not other:isPlayer() or other:isRemoved() then return false end
  if other:getId() == caster:getId() then return true end
  local p1 = caster:getParty()
  local p2 = other:getParty()
  if p1 and p2 and p1 == p2 then return true end
  local g1 = caster:getGuild()
  local g2 = other:getGuild()
  if g1 and g2 and g1:getId() == g2:getId() then return true end
  local skull = other:getSkull()
  if skull == SKULL_WHITE or skull == SKULL_RED or skull == SKULL_BLACK then
    return false
  end
  return true
end

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
  
  local extraFunc = function(caster, target)
    if not target or target:isRemoved() then return end
    target:addBuff(STUN, 1000)
    Game.sendAnimatedText("STUN", target:getPosition(), TEXTCOLOR_YELLOW, "Reggae One-12px-bordered")
  end

  spellSetupTargetCombat(player, combat, CONFIG, CONFIG_SUP, item, extraFunc)

  local maxRange = CONFIG_SUP.range or CONFIG.range or 5
  local target = player:getTarget()
  local impactPos = nil

  if target and not target:isRemoved() and player:targetRechable(target:getPosition(), maxRange, false) then
    impactPos = target:getPosition()
  elseif mousePos and player:targetRechable(mousePos, maxRange, false) then
    impactPos = mousePos
  else
    impactPos = player:getPosition()
  end

  local variant = Variant(impactPos)

  player:getPosition():sendDistanceEffect(impactPos, 39)
  if spellExecuteCombat(player, combat, CONFIG, CONFIG_SUP, item, variant, mousePos) then
    spellSetupCooldown(player, CONFIG, CONFIG_SUP, force)
    impactPos:sendMagicEffect(CONST_ME_HOLYAREA)
    
    -- Collect all allies in 5x5 area around impactPos, plus the caster themselves
    local affectedPlayers = { [player:getId()] = player }
    local spectators = Game.getSpectators(impactPos, false, true, 2, 2, 2, 2)
    for _, spec in pairs(spectators) do
      if isAlly(player, spec) then
        affectedPlayers[spec:getId()] = spec
      end
    end

    -- Apply 25% max HP heal + Immortality (RESTART_IMMORTAL) + floating text to all affected players
    for _, p in pairs(affectedPlayers) do
      if p and not p:isRemoved() then
        local healAmount = math.floor(p:getMaxHealth() * 0.25)
        p:addHealth(healAmount)
        local pPos = p:getPosition()
 --       Game.sendAnimatedText("+" .. healAmount, pPos, TEXTCOLOR_LIGHTGREEN, "Reggae One-14px-bordered")
        p:addBuff(RESTART_IMMORTAL, 3000)
        Game.sendAnimatedText("IMMORTAL", pPos, TEXTCOLOR_WHITE_EXP, "Reggae One-14px-bordered")
        pPos:sendMagicEffect(12) -- holy heal effect
        p:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "[Divine Judgement] You are immune to death for 2 seconds and healed for " .. healAmount .. " HP!")
      end
    end

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