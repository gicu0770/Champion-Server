local resizeTo = {
  [1] = {
    {0, 0, 1, 0, 0},
    {0, 1, 1, 1, 0},
    {1, 1, 3, 1, 1},
    {0, 1, 1, 1, 0},
    {0, 0, 1, 0, 0}
  },
  [2] = {
    {0, 0, 0, 1, 0, 0, 0},
    {0, 0, 1, 1, 1, 0, 0},
    {0, 1, 1, 1, 1, 1, 0},
    {1, 1, 1, 3, 1, 1, 1},
    {0, 1, 1, 1, 1, 1, 0},
    {0, 0, 1, 1, 1, 0, 0},
    {0, 0, 0, 1, 0, 0, 0}
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
    {0, 0, 0, 0, 1, 0, 0, 0, 0},
    {0, 0, 0, 1, 1, 1, 0, 0, 0},
    {0, 0, 1, 1, 1, 1, 1, 0, 0},
    {0, 1, 1, 1, 1, 1, 1, 1, 0},
    {1, 1, 1, 1, 3, 1, 1, 1, 1},
    {0, 1, 1, 1, 1, 1, 1, 1, 0},
    {0, 0, 1, 1, 1, 1, 1, 0, 0},
    {0, 0, 0, 1, 1, 1, 0, 0, 0},
    {0, 0, 0, 0, 1, 0, 0, 0, 0}
  },
}

local CONFIG = {
  spellName = GLOBAL_SPELL_COOLDOWNS[1].name,
  level = 1,
  magLevel = 0,
  manaCost = GLOBAL_SPELL_COOLDOWNS[1].manaCost,
  spellId = 1,
  range = GLOBAL_SPELL_COOLDOWNS[1].range or 5,
  aggressive = true,
  cooldown = GLOBAL_SPELL_COOLDOWNS[1].cooldown,
  type = COMBAT_ENERGYDAMAGE,
  forwardCast = true,

  combat_config = {
    distanceEffect = 74,
  },
  distanceEffect = 74,
  effectEx = 488,
  offsetX = 3,
  offsetY = 3,

  defualtArea = {
    {1, 1, 1},
    {1, 3, 1},
    {1, 1, 1}
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

  local dmg = spellGlobalFormule(player, CONFIG, CONFIG_SUP, item)
  local combat = spellSetupCombat(player, CONFIG, CONFIG_SUP, area, dmg, force)

  -- Slow 30% for 1 second on hit targets
  local extraFunc = function(caster, target)
    if not target or target:isRemoved() then return end
    local slow = 0
    if target:isMonster() then
      slow = math.floor((target:getSpeed() * 30) / 100)
    elseif target:isPlayer() then
      slow = math.floor((target:getBaseSpeed() * 30) / 100)
    end
    if slow > 0 then
      local slowCondition = Condition(CONDITION_PARALYZE)
      slowCondition:setParameter(CONDITION_PARAM_TICKS, 1000)
      slowCondition:setParameter(CONDITION_PARAM_SPEED, -slow)
      target:addCondition(slowCondition)
    end
  end

  spellSetupTargetCombat(player, combat, CONFIG, CONFIG_SUP, item, extraFunc)

  local maxRange = CONFIG_SUP.range or CONFIG.range or 5
  local impactPos = spellGetSkillshotTarget(player, mousePos, maxRange)
  player:getPosition():sendDistanceEffect(impactPos, CONFIG.distanceEffect or 74)

  if spellExecuteCombat(player, combat, CONFIG, CONFIG_SUP, item, Variant(impactPos), mousePos) then
    spellSetupCooldown(player, CONFIG, CONFIG_SUP, force)

    -- Centered magic effect with offset
    local eff = CONFIG.effectEx or 488
    local offX = CONFIG.offsetX or 3
    local offY = CONFIG.offsetY or 3
    if CONFIG_SUP.resizeTo and CONFIG_SUP.resizeTo >= 3 then
      eff = 460
    end
    local effectPos = Position(impactPos.x + offX, impactPos.y + offY, impactPos.z)
    effectPos:sendMagicEffect(eff)

    spellCleanAfterCast(player, combat)

    -- Lingering flame explosion after 1s (half of primary damage: half base + 40% Magic Attack)
    local playerId = player:getId()
    local lingeringPos = Position(impactPos.x, impactPos.y, impactPos.z)
    local secondaryDmg = math.ceil(math.abs(dmg[1]) * 0.50)
    if secondaryDmg <= 0 then secondaryDmg = 1 end

    addEvent(function()
      local p = Player(playerId)
      if not p or p:isRemoved() then return end

      local secondEffectPos = Position(lingeringPos.x + offX, lingeringPos.y + offY, lingeringPos.z)
      secondEffectPos:sendMagicEffect(eff)

      local secondCombat = Combat()
      secondCombat:setParameter(COMBAT_PARAM_TYPE, COMBAT_ENERGYDAMAGE)
      secondCombat:setParameter(COMBAT_PARAM_DAMAGE, secondaryDmg)
      secondCombat:setParameter(COMBAT_PARAM_BLOCKARMOR, true)
      secondCombat:setParameter(COMBAT_PARAM_BLOCKSHIELD, true)
      if area then
        secondCombat:setArea(area)
      end
      secondCombat:execute(p, Variant(lingeringPos))
      secondCombat:delete()
    end, 1000)
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