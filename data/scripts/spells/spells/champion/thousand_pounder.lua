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
  spellName = GLOBAL_SPELL_COOLDOWNS[4].name,
  level = 1,
  magLevel = 0,
  manaCost = GLOBAL_SPELL_COOLDOWNS[4].manaCost or 0,
  spellId = 4,
  range = GLOBAL_SPELL_COOLDOWNS[4].range or 4,
  aggressive = true,
  cooldown = GLOBAL_SPELL_COOLDOWNS[4].cooldown or 4000,
  type = COMBAT_PHYSICALDAMAGE,
  forwardCast = true,

  combat_config = {
    effect = CONST_ME_HITAREA,
  },

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

  local fromPos = player:getPosition()
  local pz = fromPos.z
  local px = fromPos.x
  local py = fromPos.y
  local playerId = player:getId()

  local maxRange = CONFIG_SUP.range or CONFIG.range or 4
  local target = player:getTarget()
  local aimPos = nil
  local targetEnemy = nil

  if target and not target:isRemoved() then
    aimPos = target:getPosition()
    targetEnemy = target
  elseif mousePos and (mousePos.x ~= px or mousePos.y ~= py) then
    aimPos = mousePos
  end

  -- Calculate direction offsets from target, mousePos or facing direction
  local dx, dy = 0, 0
  local totalDistance = 0
  if aimPos then
    dx = aimPos.x - px
    dy = aimPos.y - py
    totalDistance = math.max(math.abs(dx), math.abs(dy))
  else
    local dirOffsets = {
      [DIRECTION_NORTH] = {0, -1},
      [DIRECTION_EAST] = {1, 0},
      [DIRECTION_SOUTH] = {0, 1},
      [DIRECTION_WEST] = {-1, 0},
    }
    local offset = dirOffsets[player:getDirection()] or {0, 1}
    dx = offset[1]
    dy = offset[2]
    totalDistance = maxRange
  end

  local dist = math.max(math.abs(dx), math.abs(dy))
  if dist == 0 then dist = 1; dy = 1 end

  local stepX = dx / dist
  local stepY = dy / dist

  local steps = math.min(maxRange, totalDistance)
  if steps == 0 then steps = 1 end

  local destPos = Position(px, py, pz)
  local firstHitEnemy = nil
  local currX = px + 0.5
  local currY = py + 0.5
  local lastX = px
  local lastY = py

  for i = 1, steps do
    currX = currX + stepX
    currY = currY + stepY
    local checkX = math.floor(currX)
    local checkY = math.floor(currY)

    if checkX ~= lastX or checkY ~= lastY then
      local tile = Tile(checkX, checkY, pz)
      if not tile or tile:hasProperty(CONST_PROP_BLOCKPROJECTILE) or tile:hasProperty(CONST_PROP_BLOCKSOLID) then
        break
      end

      lastX = checkX
      lastY = checkY
      destPos = Position(checkX, checkY, pz)

      -- Check if there is an enemy strictly on this tile
      local creatures = tile:getCreatures()
      if creatures then
        for _, c in ipairs(creatures) do
          if c:getId() ~= playerId and not c:isInGhostMode() then
            firstHitEnemy = c
            break
          end
        end
      end
      if not firstHitEnemy then
        local topC = tile:getTopCreature()
        if topC and topC:getId() ~= playerId and not topC:isInGhostMode() then
          firstHitEnemy = topC
        end
      end

      -- If an enemy was hit along the dash path, stop the dash here
      if firstHitEnemy then
        break
      end
    end
  end

  if not firstHitEnemy and targetEnemy and not targetEnemy:isRemoved() then
    if destPos.x == targetEnemy:getPosition().x and destPos.y == targetEnemy:getPosition().y then
      firstHitEnemy = targetEnemy
    end
  end

  -- Turn player towards aim
  local aimDir = spellGetDirectionTo(fromPos, destPos)
  if aimDir then
    player:setDirection(aimDir)
  end

  -- Damage calculation via standard spellGlobalFormule (includes +5% Max HP from _spells_functions.lua)
  local dmg = spellGlobalFormule(player, CONFIG, CONFIG_SUP, item)
  local totalDmg = dmg[1] -- negative damage

  -- Send projectile towards destination
  fromPos:sendDistanceEffect(destPos, CONST_ANI_WHIRLWINDAXE)

  -- If an enemy was hit, pull them to the player
  if firstHitEnemy and not firstHitEnemy:isRemoved() then
    local playerPos = player:getPosition()
    local pullDir = spellGetDirectionTo(playerPos, firstHitEnemy:getPosition())
    if pullDir then
      player:setDirection(pullDir)
    else
      pullDir = player:getDirection()
    end

    -- Determine tile 1 step in front of player
    local pullPos = Position(playerPos.x, playerPos.y, playerPos.z)
    if pullDir == DIRECTION_NORTH then pullPos.y = pullPos.y - 1
    elseif pullDir == DIRECTION_SOUTH then pullPos.y = pullPos.y + 1
    elseif pullDir == DIRECTION_EAST then pullPos.x = pullPos.x + 1
    elseif pullDir == DIRECTION_WEST then pullPos.x = pullPos.x - 1
    end

    local pullTile = Tile(pullPos)
    if not pullTile or pullTile:hasProperty(CONST_PROP_BLOCKSOLID) or pullTile:hasProperty(CONST_PROP_BLOCKPROJECTILE) then
      pullPos = player:getClosestFreePosition(playerPos, 1) or playerPos
    end

    -- Visual effects and teleport target
    firstHitEnemy:getPosition():sendMagicEffect(CONST_ME_POFF)
    firstHitEnemy:teleportTo(pullPos)
    pullPos:sendMagicEffect(CONST_ME_HITAREA)

    -- Damage and 0.5s stun
    doTargetCombat(player, firstHitEnemy, COMBAT_PHYSICALDAMAGE, totalDmg, totalDmg, CONST_ME_HITAREA, ORIGIN_SPELL)

    local stunCond = Condition(CONDITION_PARALYZE)
    stunCond:setParameter(CONDITION_PARAM_TICKS, 500)
    stunCond:setParameter(CONDITION_PARAM_SPEED, -firstHitEnemy:getBaseSpeed())
    firstHitEnemy:addCondition(stunCond)

    firstHitEnemy:getPosition():sendMagicEffect(CONST_ME_EXPLOSIONAREA)
    player:sendKnockup(firstHitEnemy, 500, 24)
  end

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
