local CONFIG = {
  spellName = GLOBAL_SPELL_COOLDOWNS[4].name,
  level = 1,
  magLevel = 0,
  manaCost = GLOBAL_SPELL_COOLDOWNS[4].manaCost or 0,
  spellId = 4,
  range = GLOBAL_SPELL_COOLDOWNS[4].range or 4,
  aggressive = true,
  forwardCast = true,
  cooldown = GLOBAL_SPELL_COOLDOWNS[4].cooldown or 4000,
  type = COMBAT_PHYSICALDAMAGE,

  combat_config = {
    effect = CONST_ME_HITAREA,
    effectEx = 609,
  },

  defualtArea = {
    {3},
  },

  supports = {
    ["dot"] = true,
    ["single"] = true,
  }
}
local stunTime = 1200

local PULLED_CREATURES = {}

local function onCastSpell(player, item, getInfoOnly, force, mousePos)
  if not spellCheckForCast(player, item, CONFIG.spellId, getInfoOnly, force) then return end
  local CONFIG_SUP = item:applySupportSpells(CONFIG, player:getId())
  local area = spellSetupArea(CONFIG, CONFIG_SUP)

  if getInfoOnly then
    return spellGetInfoToSend(player, CONFIG, CONFIG_SUP, item, CONFIG.defualtArea)
  end
  if not checkCastableSpell(player, CONFIG, CONFIG_SUP, force) then return end

  local variant = spellSetupVariant(player, CONFIG, CONFIG_SUP, mousePos)
  if not variant then return end

  local function onHit(player, target)
    if not target or target:isRemoved() or target:getHealth() <= 0 then return end

    local playerPos = player:getPosition()
    local targetPos = target:getPosition()
    local playerId = player:getId()
    local targetId = target:getId()

    -- Face target
    local aimDir = spellGetDirectionTo(playerPos, targetPos)
    if aimDir then
      player:setDirection(aimDir)
    end

    -- Linear effect between player and target (Holy Scatter pattern)
    if CONFIG.combat_config.effectEx then
      playerPos:sendLineEffect(targetPos, CONFIG.combat_config.effectEx)
    end

    local distance = getDistanceBetween(targetPos, playerPos)
    local newPosition = target:getClosestFreePosition(playerPos, false)
    if not newPosition or newPosition.x == 0 then
      newPosition = player:getClosestFreePosition(playerPos, 1) or playerPos
    end

    -- 1. Optymalizacja wydajnosci: jesli cel juz stoi obok gracza (distance <= 1), pomijamy A* pathfinding
    if distance <= 1 or (newPosition.x == targetPos.x and newPosition.y == targetPos.y) then
      targetPos:sendMagicEffect(CONST_ME_HITAREA)
      local stun = Condition(CONDITION_STUN)
      stun:setParameter(CONDITION_PARAM_TICKS, stunTime)
      target:addCondition(stun)
      target:addBuff(STUN, stunTime)
      target:setProgressBar(stunTime, false)
      player:sendKnockup(target, stunTime, 24)
      target:jump(24, stunTime)
      return
    end

    -- 2. Ograniczenie przeszukiwania A* do maxSearchDist = 8 (zamiast nieskonczonego)
    local checkPathing = target:getPathTo(newPosition, 0, 0, true, false, 8, true)
    if not checkPathing then
      checkPathing = target:getPathTo(playerPos, 0, 1, true, false, 8, true)
    end

    -- 3. Jesli sciezka jest calkowicie zablokowana (np. rzeka/sciana) -> fallback teleport
    if not checkPathing or #checkPathing == 0 then
      if newPosition and newPosition.x ~= 0 then
        targetPos:sendMagicEffect(CONST_ME_POFF)
        target:teleportTo(newPosition)
        newPosition:sendMagicEffect(CONST_ME_HITAREA)
      end
      local stun = Condition(CONDITION_STUN)
      stun:setParameter(CONDITION_PARAM_TICKS, stunTime)
      target:addCondition(stun)
      target:addBuff(STUN, stunTime)
      target:setProgressBar(stunTime, false)
      player:sendKnockup(target, stunTime, 24)
      target:jump(24, stunTime)
      return
    end

    -- 4. Ochrona przed kolizja gdy wielu Guardow przyciaga ten sam cel
    local pullId = (PULLED_CREATURES[targetId] or 0) + 1
    PULLED_CREATURES[targetId] = pullId

    local stepCount = 0
    for k = #checkPathing, 1, -1 do
      stepCount = stepCount + 1
      local path = checkPathing[k]
      addEvent(function(tid, pid, isLast, currentPullId)
        local t = Creature(tid)
        if not t or t:isRemoved() or t:getHealth() <= 0 then return end

        -- Przerwij jesli nowszy pull przejal ten cel
        if PULLED_CREATURES[tid] ~= currentPullId then return end

        t:move(path, FLAG_IGNOREBLOCKCREATURE)

        if isLast then
          PULLED_CREATURES[tid] = nil
          local landingPos = t:getPosition()
          if newPosition and newPosition.x ~= 0 and (landingPos.x ~= newPosition.x or landingPos.y ~= newPosition.y) then
            local freePos = t:getClosestFreePosition(newPosition, false)
            if freePos and freePos.x ~= 0 then
              t:teleportTo(freePos)
              landingPos = freePos
            end
          end

          landingPos:sendMagicEffect(CONST_ME_HITAREA)
          local stun = Condition(CONDITION_STUN)
          stun:setParameter(CONDITION_PARAM_TICKS, stunTime)
          t:addCondition(stun)
          t:addBuff(STUN, stunTime)
          t:setProgressBar(stunTime, false)

          local p = Player(pid)
          if p and not p:isRemoved() then
            p:sendKnockup(t, stunTime, 24)
          end
          t:jump(24, stunTime)
        end
      end, 33 * stepCount, targetId, playerId, k == 1, pullId)
    end
  end

  local dmg = spellGlobalFormule(player, CONFIG, CONFIG_SUP, item)
  local combat = spellSetupCombat(player, CONFIG, CONFIG_SUP, area, dmg, force)
  spellSetupTargetCombat(player, combat, CONFIG, CONFIG_SUP, item, onHit)

  if spellExecuteCombat(player, combat, CONFIG, CONFIG_SUP, item, variant, mousePos) then
    spellCleanAfterCast(player, combat)
    spellSetupCooldown(player, CONFIG, CONFIG_SUP, force)
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
