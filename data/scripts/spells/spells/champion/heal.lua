local CONFIG = {
  spellName = GLOBAL_SPELL_COOLDOWNS[13].name,
  level = 1,
  magLevel = 0,
  manaCost = GLOBAL_SPELL_COOLDOWNS[13].manaCost,
  spellId = 13,
  range = GLOBAL_SPELL_COOLDOWNS[13].range,
  aggressive = false,
  selfTarget = false,
  cooldown = GLOBAL_SPELL_COOLDOWNS[13].cooldown,
  type = COMBAT_HEALING,

  combat_config = {},
  defualtArea = {{3}},
  supports = {
    ['dot'] = false,
    ['close'] = false,
    ['aoe'] = false,
    ['resize'] = false,
  },
}

local function getPlayerOnTile(pos)
  if not pos then return nil end
  local tile = Tile(pos)
  if not tile then return nil end
  local creatures = tile:getCreatures()
  if creatures then
    for _, c in ipairs(creatures) do
      if c:isPlayer() and not c:isRemoved() then
        return c
      end
    end
  end
  return nil
end

local function onCastSpell(player, item, getInfoOnly, force, mousePos)
  if not spellCheckForCast(player, item, CONFIG.spellId, getInfoOnly, force) then return end
  local CONFIG_SUP = item:applySupportSpells(CONFIG, player:getId())
  local area, tempArea = spellSetupArea(CONFIG, CONFIG_SUP)

  if getInfoOnly then
    return spellGetInfoToSend(player, CONFIG, CONFIG_SUP, item, tempArea)
  end
  if not checkCastableSpell(player, CONFIG, CONFIG_SUP, force) then return end

  local maxRange = CONFIG_SUP.range or CONFIG.range or 5
  local healTarget = nil

  -- 1. Check current targeted creature (if it's a player)
  local target = player:getTarget()
  if target and not target:isRemoved() and target:isPlayer() then
    healTarget = target
  end

  -- 2. Check mousePos (if hovering over a player or near a player)
  if not healTarget and mousePos then
    healTarget = getPlayerOnTile(mousePos)
    if not healTarget then
      for dx = -1, 1 do
        for dy = -1, 1 do
          if dx ~= 0 or dy ~= 0 then
            local nearby = getPlayerOnTile(Position(mousePos.x + dx, mousePos.y + dy, mousePos.z))
            if nearby then
              healTarget = nearby
              break
            end
          end
        end
        if healTarget then break end
      end
    end
  end

  -- 3. Default to caster if no other player target found
  if not healTarget or healTarget:isRemoved() then
    healTarget = player
  end

  -- 4. Check range and reachability
  local playerPos = player:getPosition()
  local targetPos = healTarget:getPosition()

  if healTarget:getId() ~= player:getId() then
    if playerPos.z ~= targetPos.z or playerPos:getDistance(targetPos) > maxRange then
      player:sendCancelMessage(RETURNVALUE_DESTINATIONOUTOFREACH)
      return false
    end
    if not player:targetRechable(targetPos, maxRange, true) then
      return false
    end
  end

  -- 5. Spend mana / cost
  if not force then
    if not spellTakeCost(player, CONFIG, CONFIG_SUP) then
      return false
    end
  end

  -- 6. Setup cooldown & cast tracker
  if not PLAYER_LAST_CAST_SPELL then PLAYER_LAST_CAST_SPELL = {} end
  PLAYER_LAST_CAST_SPELL[player:getId()] = {
    id = CONFIG.spellId,
    name = CONFIG.spellName,
    clock = os.clock()
  }
  spellSetupCooldown(player, CONFIG, CONFIG_SUP, force)

  -- 7. Calculate heal amount
  local dmg = spellGlobalFormule(player, CONFIG, CONFIG_SUP, item)
  local bonus = spellGlobalTotalDamage(player, CONFIG, false, CONFIG_SUP.type)
  local healAmount = math.abs(math.ceil(dmg[1] + (dmg[1] * bonus)))
  if healAmount <= 0 then
    healAmount = 100
  end

  -- 8. Apply heal & visual animated text
  healTarget:addHealth(healAmount)
--  Game.sendAnimatedText("+" .. healAmount, targetPos, TEXTCOLOR_LIGHTGREEN, "Reggae One-14px-bordered")
  healTarget:sendTextMessage(MESSAGE_HEALED, string.format("Healed for %d hitpoints.", healAmount))

  -- 9. 20% speed for 2s & remove paralyze / slow
  healTarget:removeCondition(CONDITION_PARALYZE)
  local speedCondition = Condition(CONDITION_HASTE)
  speedCondition:setParameter(CONDITION_PARAM_TICKS, 2000)
  speedCondition:setParameter(CONDITION_PARAM_SPEED, math.floor(healTarget:getBaseSpeed() * 0.20))
  healTarget:addCondition(speedCondition)

  -- 10. Magic effects
  if healTarget:getId() ~= player:getId() then
    playerPos:sendDistanceEffect(targetPos, 39)
  end
  targetPos:sendMagicEffect(50)

  -- 11. Support spell callbacks
  if CONFIG_SUP.func and #CONFIG_SUP.func > 0 then
    for i = 1, #CONFIG_SUP.func do
      CONFIG_SUP.func[i](player, healTarget, healAmount)
    end
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