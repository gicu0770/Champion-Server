local CONFIG = {
  spellName = GLOBAL_SPELL_COOLDOWNS[10].name,
  level = 1,
  magLevel = 0,
  manaCost = GLOBAL_SPELL_COOLDOWNS[10].manaCost,
  spellId = 10,
  range = GLOBAL_SPELL_COOLDOWNS[10].range or 5,
  aggressive = true,
  needTarget = true,
  cooldown = GLOBAL_SPELL_COOLDOWNS[10].cooldown,
  type = COMBAT_PHYSICALDAMAGE,

  combat_config = {
    effect = CONST_ME_HITAREA,
  },

  defualtArea = {
    {3}
  },

  supports = {
    ["dot"] = true,
    ["single"] = true,
  },
}

local function getPositionBehindTarget(target)
  local pos = target:getPosition()
  local dir = target:getDirection()
  
  if dir == DIRECTION_NORTH then
    pos.y = pos.y + 1
  elseif dir == DIRECTION_SOUTH then
    pos.y = pos.y - 1
  elseif dir == DIRECTION_EAST then
    pos.x = pos.x - 1
  elseif dir == DIRECTION_WEST then
    pos.x = pos.x + 1
  end
  
  return pos
end

local function onCastSpell(player, item, getInfoOnly, force, mousePos)
  if not spellCheckForCast(player, item, CONFIG.spellId, getInfoOnly, force) then return end
  local CONFIG_SUP = item:applySupportSpells(CONFIG, player:getId())
  
  if getInfoOnly then
    return spellGetInfoToSend(player, CONFIG, CONFIG_SUP, item, CONFIG.defualtArea)
  end
  if not checkCastableSpell(player, CONFIG, CONFIG_SUP, force) then return end

  local target = player:getTarget()
  if not target or target:isRemoved() then
    player:sendCancelMessage("You need a target for this spell.")
    return false
  end

  local playerPos = player:getPosition()
  local targetPos = target:getPosition()
  
  if playerPos:getDistance(targetPos) > (CONFIG_SUP.range or CONFIG.range) then
    player:sendCancelMessage("Target is out of range.")
    return false
  end
  
  -- Removes Slows
  player:removeCondition(CONDITION_PARALYZE)
  
  -- Give Crit Buff for Phantom Steps (guarantees crit)
  player:setStorageValue(PlayerStorage.phantomStepCrit, 1)
  -- Optional visual effect
  player:getPosition():sendMagicEffect(CONST_ME_POFF)

  local behindPos = getPositionBehindTarget(target)
  local tile = Tile(behindPos)
  if not tile or tile:hasProperty(CONST_PROP_BLOCKSOLID) or tile:hasProperty(CONST_PROP_BLOCKPROJECTILE) then
    behindPos = player:getClosestFreePosition(targetPos, 1) or targetPos
  end

  -- Teleport behind target
  player:teleportTo(behindPos)
  behindPos:sendMagicEffect(CONST_ME_TELEPORT)
  
  -- Face the target
  local aimDir = spellGetDirectionTo(behindPos, targetPos)
  if aimDir then
    player:setDirection(aimDir)
  end
  
  -- Damage
  local dmg = spellGlobalFormule(player, CONFIG, CONFIG_SUP, item)
  local totalDmg = dmg[1]
  
  doTargetCombat(player, target, CONFIG.type, totalDmg, totalDmg, CONST_ME_DRAWBLOOD, ORIGIN_SPELL)
  
  -- Bleed DoT (100% AD over 3s)
  local attackpower = player:getPhysicalAttack() or 100
  local totalTicks = 3
  local totalDotDamage = attackpower -- 100% AD
  local dmgPerTick = math.max(1, math.ceil(totalDotDamage / totalTicks))

  target:applyDot(player, {
    buffId = BLEED_ITEM,
    damage = dmgPerTick,
    duration = 3000,
    combatType = COMBAT_PHYSICALDAMAGE,
    mode = "refresh",
    maxStacks = 1,
    initialTick = true,
    interval = 1000,
    effect = CONST_ME_DRAWBLOOD -- Or effect = 0, standard physical effect
  })

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
