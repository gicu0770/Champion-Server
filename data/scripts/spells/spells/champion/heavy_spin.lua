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
  spellName = GLOBAL_SPELL_COOLDOWNS[6].name,
  level = 1,
  magLevel = 0,
  manaCost = GLOBAL_SPELL_COOLDOWNS[6].manaCost or 0,
  spellId = 6,
  range = GLOBAL_SPELL_COOLDOWNS[6].range or 0,
  aggressive = true,
  selfTarget = true,
  cooldown = GLOBAL_SPELL_COOLDOWNS[6].cooldown or 6000,
  type = COMBAT_PHYSICALDAMAGE,

  combat_config = {
    effect = CONST_ME_HITAREA,
  },

  defualtArea = {
    {1, 1, 1},
    {1, 3, 1},
    {1, 1, 1}
  },

  supports = {
    ["dot"] = false,
    ["close"] = true,
    ["aoe"] = true,
    ["resize"] = true,
  },
}

local function executeSpinTick(playerId, tickNum)
  local player = Player(playerId)
  if not player or player:isRemoved() then return end

  local item = player:getSlotItem(CONST_SLOT_SPELL3)
  local CONFIG_SUP = item and item:applySupportSpells(CONFIG, playerId) or CONFIG

  local spellLevel = item and item:getCustomAttribute("level") or 1
  local physAtk = player:getPhysicalAttack()
  if not physAtk or physAtk <= 0 then
    physAtk = player:getCharacterType() or 50
  end

  local baseTick = 150 + (math.max(1, spellLevel) - 1) * 100
  local multiplier = 0.30 + (math.max(1, spellLevel) - 1) * 0.10
  local tickDmg = math.ceil(baseTick + (physAtk * multiplier))

  local playerPos = player:getPosition()
  local r = 1
  if CONFIG_SUP.resizeTo then
    if CONFIG_SUP.resizeTo >= 1 and CONFIG_SUP.resizeTo <= 2 then
      r = 2
    elseif CONFIG_SUP.resizeTo >= 3 then
      r = 3
    end
  end

  -- Damage all enemies in area
  local spectators = Game.getSpectators(playerPos, false, false, r, r, r, r)
  for _, creature in ipairs(spectators) do
    if creature:getId() ~= playerId and not creature:isInGhostMode() then
      doTargetCombat(player, creature, COMBAT_PHYSICALDAMAGE, -tickDmg, -tickDmg, CONST_ME_HITAREA, ORIGIN_SPELL)
    end
  end

  -- Send visual effect
  local effect = 517
  local position = Position(playerPos.x + 1, playerPos.y + 1, playerPos.z)
  if CONFIG_SUP.resizeTo then
    if CONFIG_SUP.resizeTo >= 1 and CONFIG_SUP.resizeTo <= 2 then
      effect = 513
      position = Position(playerPos.x + 2, playerPos.y + 2, playerPos.z)
    elseif CONFIG_SUP.resizeTo >= 3 then
      effect = 467
      position = Position(playerPos.x + 3, playerPos.y + 3, playerPos.z)
    end
  end
  position:sendMagicEffect(effect, 0)

  if tickNum < 3 then
    addEvent(executeSpinTick, 1000, playerId, tickNum + 1)
  end
end

local function spinRotationStep(playerId, step)
  local player = Player(playerId)
  if not player or player:isRemoved() then return end

  local curDir = player:getDirection()
  player:setDirection((curDir + 1) % 4)

  if step < 19 then -- 20 steps * 200ms = 4000ms
    addEvent(spinRotationStep, 200, playerId, step + 1)
  end
end

local function onCastSpell(player, item, getInfoOnly, force, mousePos)
  if not spellCheckForCast(player, item, CONFIG.spellId, getInfoOnly, force) then return end
  local CONFIG_SUP = item:applySupportSpells(CONFIG, player:getId())
  local area, tempArea = spellSetupArea(CONFIG, CONFIG_SUP, resizeTo)

  if getInfoOnly then
    return spellGetInfoToSend(player, CONFIG, CONFIG_SUP, item, tempArea)
  end
  if not checkCastableSpell(player, CONFIG, CONFIG_SUP, force) then return end

  -- Add Buff for 4s (4000 ms)
  player:addBuff(HEAVY_SPIN_BUFF, 4000)

  -- Speed bonus +20% for 4s
  local speed = math.floor((player:getBaseSpeed() or 150) * 0.20)
  if speed > 0 then
    local speedCondition = Condition(CONDITION_HASTE)
    speedCondition:setParameter(CONDITION_PARAM_TICKS, 4000)
    speedCondition:setParameter(CONDITION_PARAM_SPEED, speed)
    player:addCondition(speedCondition)
  end

  spellSetupCooldown(player, CONFIG, CONFIG_SUP, force)
  if not force then
    spellTakeCost(player, CONFIG, CONFIG_SUP)
  end

  -- Initial tick (0s) and subsequent ticks every 1000ms (4 ticks total)
  executeSpinTick(player:getId(), 0)

  -- Spin rotation animation (every 200ms for 4s)
  spinRotationStep(player:getId(), 0)

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
