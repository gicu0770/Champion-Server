local resizeTo = {
  [1] = {
    {1, 3, 1}
  }
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
    effect = CONST_ME_EXPLOSIONAREA,
  },

  defualtArea = {
    {1, 3, 1}
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

  -- Determine dash direction and step offsets from mouse or player direction
  local dx, dy = 0, 0
  if mousePos and (mousePos.x ~= px or mousePos.y ~= py) then
    dx = mousePos.x - px
    dy = mousePos.y - py
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
  end

  local dist = math.max(math.abs(dx), math.abs(dy))
  if dist == 0 then dist = 1; dy = 1 end

  local stepX = dx / dist
  local stepY = dy / dist

  local maxRange = CONFIG.range or 4
  local destX = px
  local destY = py
  local firstHitTarget = nil
  local currX = px + 0.5
  local currY = py + 0.5
  local playerId = player:getId()

  for i = 1, maxRange do
    currX = currX + stepX
    currY = currY + stepY
    local checkX = math.floor(currX)
    local checkY = math.floor(currY)

    if checkX ~= destX or checkY ~= destY then
      local tile = Tile(checkX, checkY, pz)
      if not tile or tile:hasProperty(CONST_PROP_BLOCKPROJECTILE) or tile:hasProperty(CONST_PROP_BLOCKSOLID) then
        break
      end

      destX = checkX
      destY = checkY

      -- Scan for first enemy on this tile
      local specs = Game.getSpectators(Position(checkX, checkY, pz), false, false, 0, 0, 0, 0)
      for _, creature in ipairs(specs) do
        if creature:getId() ~= playerId and not creature:isInGhostMode() then
          firstHitTarget = creature
          break
        end
      end

      -- If first enemy hit, stop dash right here
      if firstHitTarget then
        break
      end
    end
  end

  -- Face dash destination
  local targetPos = Position(destX, destY, pz)
  local dir = spellGetDirectionTo(fromPos, targetPos)
  if dir then
    player:setDirection(dir)
  end

  -- Move player to destination with poff magic effect
  fromPos:sendMagicEffect(CONST_ME_POFF)
  player:teleportTo(targetPos)
  targetPos:sendMagicEffect(CONST_ME_POFF)

  -- Damage calculation: 300 (+50% Total Physical Attack) + scaling per spellLevel
  local spellLevel = item:getCustomAttribute("level") or 1
  local totalBase = 300 + (math.max(1, spellLevel) - 1) * 60
  local physAtk = player:getPhysicalAttack()
  if not physAtk or physAtk <= 0 then
    physAtk = player:getCharacterType() or 50
  end
  local totalDmg = math.ceil(totalBase + (physAtk * 0.50))

  -- Apply damage and airborne knockup ONLY to the first hit target
  if firstHitTarget and not firstHitTarget:isRemoved() then
    doTargetCombat(player, firstHitTarget, COMBAT_PHYSICALDAMAGE, -totalDmg, -totalDmg, CONST_ME_HITAREA, ORIGIN_SPELL)

    -- 0.5s Stun / Airborne
    local stunCond = Condition(CONDITION_PARALYZE)
    stunCond:setParameter(CONDITION_PARAM_TICKS, 500)
    stunCond:setParameter(CONDITION_PARAM_SPEED, -firstHitTarget:getBaseSpeed())
    firstHitTarget:addCondition(stunCond)

    firstHitTarget:getPosition():sendMagicEffect(CONST_ME_EXPLOSIONAREA)
    player:sendKnockup(firstHitTarget, 500, 24)
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
