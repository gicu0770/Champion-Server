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
  manaCost = GLOBAL_SPELL_COOLDOWNS[6].manaCost,
  spellId = 6,
  range = GLOBAL_SPELL_COOLDOWNS[6].range,
  aggressive = true,
  selfTarget = true,
  cooldown = GLOBAL_SPELL_COOLDOWNS[6].cooldown,
  type = COMBAT_PHYSICALDAMAGE,

  combat_config = {
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

local function executeSpinTick(playerId, tickNum, tickDmg, resizeLevel)
  local player = Player(playerId)
  if not player or player:isRemoved() then return end

  local playerPos = player:getPosition()
  local areaMatrix = (resizeLevel and resizeLevel > 0 and resizeTo[resizeLevel]) or CONFIG.defualtArea

  local combat = Combat()
  combat:setParameter(COMBAT_PARAM_TYPE, COMBAT_PHYSICALDAMAGE)
  combat:setParameter(COMBAT_PARAM_AGGRESSIVE, true)
  combat:setParameter(COMBAT_PARAM_DAMAGE, math.abs(tickDmg))
  combat:setArea(createCombatArea(areaMatrix))

  combat:execute(player, Variant(playerPos))

  local effect = 517
  local offset = 1
  if resizeLevel and resizeLevel >= 1 and resizeLevel <= 2 then
    effect = 513
    offset = 2
  elseif resizeLevel and resizeLevel >= 3 then
    effect = 467
    offset = 3
  end
  local position = Position(playerPos.x + offset, playerPos.y + offset, playerPos.z)
  position:sendMagicEffect(effect, 0)

  if tickNum < 3 then
    addEvent(executeSpinTick, 1000, playerId, tickNum + 1, tickDmg, resizeLevel)
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

  -- Speed bonus +70% for 4s
  local speed = math.floor((player:getBaseSpeed() or 150) * 0.70)
  if speed > 0 then
    local speedCondition = Condition(CONDITION_HASTE)
    speedCondition:setParameter(CONDITION_PARAM_TICKS, 4000)
    speedCondition:setParameter(CONDITION_PARAM_SPEED, speed)
    player:addCondition(speedCondition)
  end

  local resizeLevel = CONFIG_SUP.resizeTo or 0
  local dmg = spellGlobalFormule(player, CONFIG, CONFIG_SUP, item)
  local tickDmg = dmg[1] -- negative damage

  spellSetupCooldown(player, CONFIG, CONFIG_SUP, force)
  if not force then
    spellTakeCost(player, CONFIG, CONFIG_SUP)
  end

  -- Initial tick (0s) and subsequent ticks every 1000ms (4 ticks total: 0s, 1s, 2s, 3s)
  executeSpinTick(player:getId(), 0, tickDmg, resizeLevel)

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
