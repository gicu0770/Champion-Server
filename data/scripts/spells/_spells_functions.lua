function spellGlobalTotalDamage(player, CONFIG, dot, type)
  local totalDamage = 0
--	if player:hasBuff(ILLUMINATION_DOT_UNIQUE) then
--		if type == COMBAT_HOLYDAMAGE then
--			totalDamage = totalDamage + (player:getBuff(ILLUMINATION_DOT_UNIQUE).stacks * 5)
--		end
--	end
  return totalDamage
end


function autoattackFormule(player, CONFIG, CONFIG_SUP, item, dot, dotDamageExtra)
  local attackpower = totalAttackPower(player, CONFIG_SUP.type, CONFIG.spellId)
  if CONFIG.spellId == 45 or CONFIG.spellId == 85 or CONFIG.spellId == 86 or CONFIG.spellId == 87 or CONFIG.spellId == 107 or CONFIG.spellId == 108 then
    attackpower = totalAttackPower(player, CONFIG_SUP.type, CONFIG.spellId, false, true)
  end
  return attackpower
end
function spellGlobalFormule(player, CONFIG, CONFIG_SUP, item, dot, dotDamageExtra)
  local spellCfg = GLOBAL_SPELL_COOLDOWNS[CONFIG.spellId]
  local attackpower = player:getMagicAttack()
  if (CONFIG and CONFIG.type == COMBAT_PHYSICALDAMAGE) or (spellCfg and (spellCfg.scaling == 2 or spellCfg.addDamage == 2)) then
    attackpower = player:getPhysicalAttack()
  end
  if not attackpower or attackpower <= 0 then
    attackpower = player:getCharacterType()
  end
  if not attackpower or attackpower <= 0 then
    attackpower = 50
  end

  local multiplier = spellCfg and spellCfg.multipler or 0.80
  local baseDmg = spellCfg and spellCfg.baseDamage or 0
  local basePerLvl = spellCfg and spellCfg.baseDamagePerLevel or 0

  local spellLevel = 1
  if CONFIG_SUP and CONFIG_SUP.level and CONFIG_SUP.level > 0 then
    spellLevel = CONFIG_SUP.level
  elseif item and item:getId() > 0 then
    spellLevel = item:getCustomAttribute("level") or 1
  end

  local totalBase = baseDmg + (math.max(1, spellLevel) - 1) * basePerLvl

  if CONFIG.spellId == 5 then -- Body Slam (+6% Total HP)
    totalBase = totalBase + math.ceil(player:getMaxHealth() * 0.06)
  elseif CONFIG.spellId == 6 then -- Heavy Spin
    totalBase = 150 + (math.max(1, spellLevel) - 1) * 100
    multiplier = 0.30 + (math.max(1, spellLevel) - 1) * 0.10
  end

  local max = math.ceil(totalBase + (attackpower * multiplier))
  local max2 = 0
  return {-max, -max2}
end

function spellGetInfoToSend(player, CONFIG, CONFIG_SUP, item, area, dot)
  local infoToSend = {
    sup = {},
  }
  local tap = CONFIG_SUP.lifeTap
  infoToSend.sup = CONFIG_SUP.sup
  infoToSend.area = area or CONFIG.defualtArea
  infoToSend.baseArea = CONFIG.defualtArea
  infoToSend.type = CONFIG_SUP.type
  if CONFIG_SUP.type then
    local dmg = spellGlobalFormule(player, CONFIG, CONFIG_SUP, item, dot)
    dmg[1] = dmg[1] + (dmg[1] * spellGlobalTotalDamage(player, CONFIG, dot, type))
    infoToSend.dmg = math.ceil(dmg[1])
    infoToSend.ap = GLOBAL_SPELL_COOLDOWNS[CONFIG.spellId].multipler
    local damageDPS =  math.ceil(dmg[2])
    infoToSend.dmg2 = damageDPS and math.ceil(damageDPS) or nil
  end

  infoToSend.type2 = CONFIG_SUP.convert and CONFIG_SUP.convert[2] or nil
  local targetType
  if CONFIG.needTarget or (CONFIG_SUP.range and CONFIG_SUP.range > 0) then
    targetType = 1
  elseif CONFIG.selfTarget then
    targetType = 2
  elseif CONFIG.directional or CONFIG.forwardCast then
    targetType = 3
  end
  local baseCrit = CONFIG_SUP.critC + player:getSpecialSkill(SPECIALSKILL_CRITICALHITCHANCE)
  if CONFIG_SUP.gamble then
      infoToSend.critC = math.min(baseCrit / 2, 50)  -- dzieli na 2, ale maks 50%
  else
      infoToSend.critC = baseCrit
  end
  infoToSend.tt = targetType
  infoToSend.rarity = rarity or 0
  infoToSend.cdr = CONFIG_SUP.cooldown
  infoToSend.manaCost = CONFIG_SUP.manaCost
  infoToSend.range = CONFIG_SUP.range
  infoToSend.mr = CONFIG_SUP.manaReservation
  infoToSend.lifeTap = tap
  infoToSend.eT = CONFIG_SUP.targets
  infoToSend.lv = CONFIG_SUP.cleanLevel
  infoToSend.dmgInfo = CONFIG.dmgInfo
	-- infoToSend.critC = (CONFIG_SUP.critC + player:getSpecialSkill(SPECIALSKILL_CRITICALHITCHANCE)) / (CONFIG_SUP.gamble and 2 or 1)
  infoToSend.critM = CONFIG_SUP.critM + player:getSpecialSkill(SPECIALSKILL_CRITICALHITAMOUNT)
  infoToSend.qu = CONFIG_SUP.quality
  infoToSend.n = item:getSpellName()
  infoToSend.r = item:getRarityId()
  infoToSend.i = item:getType():getClientId()
  infoToSend.mai = CONFIG.manaInfo
  infoToSend.mi = item:isMirrored()
  infoToSend.co = item:isCorrupted()
  infoToSend.id = item:getId()
  infoToSend.proj = math.max(CONFIG_SUP.projectile or 0, CONFIG_SUP.targets or 0)
  infoToSend.boun = CONFIG_SUP.bon or 0
  --[[
  local cooldownReduction = player:getCooldownReduction()
  if cooldownReduction then
    infoToSend.cdr = infoToSend.cdr - ((infoToSend.cdr * (cooldownReduction)) / 100)
  end
  --]]
  return infoToSend
end

function spellSetupAuraCast(player, CONFIG, CONFIG_SUP, item)
  if CONFIG_SUP.resizeTo and CONFIG_SUP.resizeTo == 1 then
    CONFIG_SUP.resizeTo = 2
  end
  player:addActiveAura(CONFIG.aura, CONFIG_SUP.resizeTo or 1)
  if CONFIG_SUP.as then
      local conditionAS = Condition(CONDITION_ATTRIBUTES)
			conditionAS:setParameter(CONDITION_PARAM_SUBID, 722000+CONFIG.spellId)
			conditionAS:setParameter(CONDITION_PARAM_ATTACKSPEED, CONFIG_SUP.as)
			conditionAS:setParameter(CONDITION_PARAM_TICKS, -1)
			player:addCondition(conditionAS)
  end
  if CONFIG_SUP.vitality then
    local healthRegen = CONFIG_SUP.vitality + (player:getMaxHealth() * 0.02)
  --  player:addHealthGain(500+CONFIG.spellId, healthRegen, true)
  player:addHealthGain(500+CONFIG.spellId, healthRegen, true)
  end
  if CONFIG_SUP.clarity then
    local manaRegen = CONFIG_SUP.clarity + (player:getMaxMana() * 0.02)
  --  player:addManaGain(500+CONFIG.spellId, manaRegen, true)
  player:addManaGain(500+CONFIG.spellId, manaRegen, true)
  end
  if CONFIG_SUP.barrier then
    local esRegen = CONFIG_SUP.barrier + (player:getMaxEnergyShield() * 0.02)
  --  player:addEnergyShieldGainForce(500+CONFIG.spellId, esRegen, true)
  player:addEnergyShieldGainForce(500+CONFIG.spellId, esRegen, true)
  end
  if CONFIG_SUP.momentum then
      local movementSpeedCondition = Condition(CONDITION_HASTE)
      local hasteAdded = player:getBaseSpeed() * CONFIG_SUP.momentum / 100
      movementSpeedCondition:setParameter(CONDITION_PARAM_TICKS, -1)
      movementSpeedCondition:setParameter(CONDITION_PARAM_SUBID, 731590)
      movementSpeedCondition:setFormula(0.0, hasteAdded, 0.0, hasteAdded)
      player:addCondition(movementSpeedCondition)
  end
  if CONFIG.spellId >= 79 and CONFIG.spellId <= 81 then
    if CONFIG_SUP.multistrike then
        player:addBuff(MULTI_STRIKE)
    end
    if CONFIG_SUP.basicDamage then
      player:addBuff(BASIC_DAMAGE_SUPPORT)
      player:setBuffStacks(BASIC_DAMAGE_SUPPORT, CONFIG_SUP.basicDamage)
    end
  end
  -- 1=critM 2=basicDamage
  if CONFIG.spellId == 79 or CONFIG.spellId == 80 or CONFIG.spellId == 81 or CONFIG.spellId == 27 or CONFIG.spellId == 65 then
    if CONFIG_SUP.critM > 0 then
      player:addBuff(CRITICAL_DAMAGE_SUPPORT)
      player:setBuffStacks(CRITICAL_DAMAGE_SUPPORT, CONFIG_SUP.critM)
      if player:getStorageValue(PlayerStorage.basicSpecials + CONFIG.spellId + 1) < 0 then
        player:setStorageValue(PlayerStorage.basicSpecials + CONFIG.spellId + 1, 1)
      end
    end
  end
  if CONFIG_SUP.basicPen then
  --  player:addBuff(BASIC_WEAKNESS_PLAYER)
  --  player:setBuffStacks(BASIC_WEAKNESS_PLAYER, CONFIG_SUP.basicPen)
    player:setStorageValue(PlayerStorage.basicPen + 27, -1) -- combat aura
    player:setStorageValue(PlayerStorage.basicPen + 65, -1) -- frenzy aura
    player:setStorageValue(PlayerStorage.basicPen + 79, -1)
    player:setStorageValue(PlayerStorage.basicPen + 80, -1)
    player:setStorageValue(PlayerStorage.basicPen + 81, -1)
    if player:getStorageValue(PlayerStorage.basicPen + CONFIG.spellId) < 0 then
      player:setStorageValue(PlayerStorage.basicPen + CONFIG.spellId, CONFIG_SUP.basicPen)
    end
  end
  if CONFIG_SUP.counterPen then
    player:addBuff(COUNTER_WEAKNESS_PLAYER)
    player:setBuffStacks(COUNTER_WEAKNESS_PLAYER, CONFIG_SUP.counterPen)
    player:setStorageValue(PlayerStorage.counterPen + CONFIG.spellId, CONFIG_SUP.counterPen)
  end
  player:sendActiveAura(item:getRealUID(), true)
  if not player:getBuff(CONFIG.buff) then
    player:addBuff(CONFIG.buff)
    local spellLevel = CONFIG_SUP.level -- item:getRarityId()
    if item:isQuality() then
      spellLevel = math.floor(spellLevel * (1 + (CONFIG_SUP.quality / 100)) )
    end
    player:setBuffStacks(CONFIG.buff, spellLevel)
  end

  player:addReservation(CONFIG.spellId, CONFIG_SUP.manaReservation, CONFIG_SUP.lifeTap)
end

function spellSetupAuraEnd(player, CONFIG, item, uid)
  player:removeCondition(CONDITION_ATTRIBUTES, CONDITIONID_COMBAT, 722000+CONFIG.spellId)
  player:removeActiveAura(CONFIG.aura)
  if uid or item then
    player:sendActiveAura(uid or item:getRealUID(), false)
  end
  player:removeReservation(CONFIG.spellId)
  player:removeBuff(CONFIG.buff)
  if CONFIG.spellId >= 79 and CONFIG.spellId <= 81 then
    player:removeBuff(MULTI_STRIKE)
    player:removeBuff(BASIC_DAMAGE_SUPPORT)
  end
  if CONFIG.spellId == 79 or CONFIG.spellId == 80 or CONFIG.spellId == 81 or CONFIG.spellId == 27 or CONFIG.spellId == 65 then
      if player:getStorageValue(PlayerStorage.basicSpecials + CONFIG.spellId + 1) > 0 then
        player:setStorageValue(PlayerStorage.basicSpecials + CONFIG.spellId + 1, -1)
        player:removeBuff(CRITICAL_DAMAGE_SUPPORT)
      end
  end

  player:setStorageValue(PlayerStorage.basicPen + 27, -1) -- combat aura
  player:setStorageValue(PlayerStorage.basicPen + 65, -1) -- frenzy aura
  player:setStorageValue(PlayerStorage.basicPen + 79, -1)
  player:setStorageValue(PlayerStorage.basicPen + 80, -1)
  player:setStorageValue(PlayerStorage.basicPen + 81, -1)
  if player:getStorageValue(PlayerStorage.basicPen + CONFIG.spellId) > 0 then
    player:setStorageValue(PlayerStorage.basicPen + CONFIG.spellId, -1)
  --  player:removeBuff(BASIC_WEAKNESS_PLAYER)
  end
  if player:getStorageValue(PlayerStorage.counterPen + CONFIG.spellId) > 0 then
    player:setStorageValue(PlayerStorage.counterPen + CONFIG.spellId, -1)
    player:removeBuff(COUNTER_WEAKNESS_PLAYER)
  end
  player:removeHealthGain(500+CONFIG.spellId, true)
  player:removeManaGain(500+CONFIG.spellId, true)
  player:removeEnergyShieldGainForce(500+CONFIG.spellId, true)
  player:removeCondition(CONDITION_HASTE, CONDITIONID_COMBAT, 731590)
  local spellCd = Condition(CONDITION_SPELLCOOLDOWN)
  spellCd:setParameter(CONDITION_PARAM_TICKS, CONFIG.cooldown)
  spellCd:setParameter(CONDITION_PARAM_SUBID, CONFIG.spellId)
  player:addCondition(spellCd)
end

function spellSetupCooldown(player, CONFIG, CONFIG_SUP, force)
  local cooldown = CONFIG_SUP.cooldown
  if CONFIG.aura then
    cooldown = 500
  end
  local spellId = CONFIG.spellId
  if cooldown < 300 then
    cooldown = 300
  end
  if player:getStorageValue(435024) == 1 then -- Sorcerer + Druid "Elemental Synergy"
    if CONFIG_SUP.type == COMBAT_FIREDAMAGE then
      player:addBuff(FIRE)
    elseif CONFIG_SUP.type == COMBAT_ICEDAMAGE then
      player:addBuff(ICE)
    elseif CONFIG_SUP.type == COMBAT_ENERGYDAMAGE then
      player:addBuff(LIGHTNING)
    elseif CONFIG_SUP.type == COMBAT_EARTHDAMAGE then
      player:addBuff(EARTH)
    end
  end
  if spellId == 87 then
    local spellLevel = CONFIG_SUP.level -- item:getRarityId()
    player:addBuff(RIPOSTE, 3000)
    player:setBuffStacks(RIPOSTE, spellLevel)
  end
  if colleftInfo[player:getId()].attributesItems[195] then -- subklas Suffering Power
      local burnHP = player:getMaxHealth() * US_ENCHANTMENTS[195].subvalue2
      player:addHealth(-burnHP)
  end
  if colleftInfo[player:getId()].attributesItems[153] then -- subklas Grace
      local recoveryHPES = player:getMaxHealth() * US_ENCHANTMENTS[153].subvalue2
      player:addHealth(recoveryHPES)
      player:addEnergyShield(recoveryHPES)
  end
  if colleftInfo[player:getId()].attributesItems[151] then -- subklas Righteous Fury
      player:addBuff(HOLY_FURY)
  end

  if not force then
    local globalCd = Condition(CONDITION_SPELLGROUPCOOLDOWN)
    globalCd:setParameter(CONDITION_PARAM_TICKS, 200)
    globalCd:setParameter(CONDITION_PARAM_SUBID, 1)
    player:addCondition(globalCd)
  end


  if force then
    cooldown = 1000
  end

  local spellCd = Condition(CONDITION_SPELLCOOLDOWN)
  spellCd:setParameter(CONDITION_PARAM_TICKS, cooldown)
  spellCd:setParameter(CONDITION_PARAM_SUBID, spellId)
  player:addCondition(spellCd)
end


function spellCheckForCast(player, item, spellId, getInfoOnly, force)
  if not player or not item then 
    return false
  end
  if not getInfoOnly then
    local spellLevel = item:getCustomAttribute("level") or 0
    if spellLevel <= 0 then
      return false
    end
    if not force then
      if player:hasCondition(CONDITION_SPELLGROUPCOOLDOWN, 1) then
        return false
      end
    end
    if player:hasCondition(CONDITION_SPELLCOOLDOWN, spellId) then 
      return false
    end
  end

  return true
end

local defualt_effect = {
  [COMBAT_PHYSICALDAMAGE] = 1,
  [COMBAT_FIREDAMAGE] = 37,
  [COMBAT_EARTHDAMAGE] = 47,
  [COMBAT_ENERGYDAMAGE] = 12,
  [COMBAT_HOLYDAMAGE] = 91,
  [COMBAT_ICEDAMAGE] = 44,
  [COMBAT_DEATHDAMAGE] = 18,
  [COMBAT_HEALING] = 15,
}

function spellSetupArea(CONFIG, CONFIG_SUP, resizeTo, newArea)
  local area, tempArea = nil, nil
  if CONFIG_SUP.resizeTo and resizeTo then
    area = resizeTo[CONFIG_SUP.resizeTo] or resizeTo[CONFIG_SUP.resizeTo - 1]
    tempArea = area
    if diaoganlresizeTo then
      area = createCombatArea(area, diaoganlresizeTo[CONFIG_SUP.resizeTo] or diaoganlresizeTo[CONFIG_SUP.resizeTo - 1])
    else
      area = createCombatArea(area)
    end
  end

  if CONFIG_SUP.pin > 0 then
    local pinArea = CONFIG.defualtArea or CONFIG.diaoganlArea
    local tiles = 0
    for i = 1, #pinArea do
      for j = 1, #pinArea[i] do
        if pinArea[i][j] == 1 then
          tiles = tiles + 1
        end
      end
    end
    area = createCombatArea({ { 3 } })

    if not CONFIG_SUP.pinDmgAdded then
      CONFIG_SUP.extraDmg[CONFIG_SUP.type] = CONFIG_SUP.extraDmg[CONFIG_SUP.type] + ((CONFIG_SUP.pin * tiles)/ 100)
      CONFIG_SUP.pinDmgAdded = true
    end

    CONFIG_SUP.forcedEffect = defualt_effect[CONFIG_SUP.type] or 1
    return area, { { 3 } }
  end
  local defaultA = CONFIG.defualtArea
  if newArea then
    defaultA = CONFIG.newArea
  end
  area = area or CONFIG.diaoganlArea and createCombatArea(defaultA, CONFIG.diaoganlArea) or createCombatArea(defaultA)
  return area, tempArea
end

function spellSetupCombat(player, CONFIG, CONFIG_SUP, area, dmg, force)
  local combat = Combat()
  local isHealing = CONFIG_SUP.type == COMBAT_HEALING
  combat:setParameter(COMBAT_PARAM_BLOCKARMOR, true)
  combat:setParameter(COMBAT_PARAM_BLOCKSHIELD, true)

  if CONFIG.combat_config then
    if CONFIG.combat_config.effect then
      combat:setParameter(COMBAT_PARAM_EFFECT, CONFIG_SUP.forcedEffect or CONFIG.combat_config.effect)
    end

    if CONFIG.combat_config.bottom then
      combat:setParameter(COMBAT_PARAM_BOTTOMEFFECT, 1)
    end

    if CONFIG.combat_config.savePos then
      combat:setParameter(COMBAT_PARAM_SAVEPOS, 1)
    end

    if CONFIG.combat_config.distanceEffect then
      combat:setParameter(COMBAT_PARAM_DISTANCEEFFECT, CONFIG.combat_config.distanceEffect)
    end

    if not CONFIG_SUP.forcedEffect then
      if CONFIG.combat_config.center then
        combat:setParameter(COMBAT_PARAM_CENTEREFFECT, CONFIG.combat_config.center)
      end
      if CONFIG.combat_config.offsetX then
        combat:setParameter(COMBAT_PARAM_OFFSETXEFFECT, CONFIG.combat_config.offsetX)
      end
      if CONFIG.combat_config.offsetY then
        combat:setParameter(COMBAT_PARAM_OFFSETYEFFECT, CONFIG.combat_config.offsetY)
      end
    end
  end

  if force then
    combat:setOrigin(ORIGIN_AUTOCAST)
    CONFIG_SUP.force = true
  else
    CONFIG_SUP.force = nil
  end
  combat:setParameter(COMBAT_PARAM_TYPE, CONFIG_SUP.type)
  if CONFIG_SUP.convert then
    combat:setParameter(COMBAT_PARAM_DAMAGE2, isHealing == true and dmg[2] or -dmg[2])
    combat:setParameter(COMBAT_PARAM_TYPE2, CONFIG_SUP.convert[2])
  end
  if dmg[1] > 0 then
    dmg[1] = -1
  end

  combat:setParameter(COMBAT_PARAM_DAMAGE, isHealing == true and dmg[1] or -dmg[1])
  combat:setArea(area)
  combat:setParameter(COMBAT_PARAM_AGGRESSIVE, not isHealing)
  return combat
end

function checkCastableSpell(player, CONFIG, CONFIG_SUP, force)
  if CONFIG_SUP.disableCast and not force then 
    return false
  end

  local spellCheck = {
    level = CONFIG.level,
    magLevel = CONFIG.magLevel,
    spellId = CONFIG.spellId,
    range = CONFIG.range,
    aggressive = CONFIG.aggressive,
    manaCost = CONFIG_SUP.manaCost,
    cooldown = CONFIG_SUP.cooldown,

    needTarget = CONFIG.needTarget,
    manaReservation = CONFIG_SUP.manaReservation,
    lifeTap = CONFIG_SUP.lifeTap,
  }

  return player:spellCheck(spellCheck)
end

function spellSetupTragetTile(player, combat, CONFIG, CONFIG_SUP, item, extraFunc)
  if extraFunc then
    function onTargetTile(player, position, fromPos)
      extraFunc(player, position, fromPos)
    end
    combat:setCallback(CALLBACK_PARAM_TARGETTILE, "onTargetTile")
  end
end

local DIR_OFFSETS = {
  [DIRECTION_NORTH] = {x = 0, y = -1},
  [DIRECTION_EAST] = {x = 1, y = 0},
  [DIRECTION_SOUTH] = {x = 0, y = 1},
  [DIRECTION_WEST] = {x = -1, y = 0},
  [DIRECTION_SOUTHWEST] = {x = -1, y = 1},
  [DIRECTION_SOUTHEAST] = {x = 1, y = 1},
  [DIRECTION_NORTHWEST] = {x = -1, y = -1},
  [DIRECTION_NORTHEAST] = {x = 1, y = -1},
}

function spellGetDirectionTo(fromPos, toPos)
  local dx = toPos.x - fromPos.x
  local dy = toPos.y - fromPos.y

  if dx == 0 and dy == 0 then
    return nil
  end

  local absX = math.abs(dx)
  local absY = math.abs(dy)

  if absX > absY * 2.2 then
    return dx > 0 and DIRECTION_EAST or DIRECTION_WEST
  elseif absY > absX * 2.2 then
    return dy > 0 and DIRECTION_SOUTH or DIRECTION_NORTH
  else
    if dx > 0 and dy < 0 then
      return DIRECTION_NORTHEAST
    elseif dx > 0 and dy > 0 then
      return DIRECTION_SOUTHEAST
    elseif dx < 0 and dy < 0 then
      return DIRECTION_NORTHWEST
    elseif dx < 0 and dy > 0 then
      return DIRECTION_SOUTHWEST
    end
  end

  return DIRECTION_NORTH
end

function spellGetSkillshotTarget(player, mousePos, maxRange)
  local fromPos = player:getPosition()
  local pz = fromPos.z
  local px = fromPos.x
  local py = fromPos.y

  local dx, dy = 0, 0
  if mousePos and (mousePos.x ~= px or mousePos.y ~= py) then
    dx = mousePos.x - px
    dy = mousePos.y - py
  else
    local dirOffset = DIR_OFFSETS[player:getDirection()] or {x = 0, y = 1}
    dx = dirOffset.x
    dy = dirOffset.y
  end

  local dist = math.max(math.abs(dx), math.abs(dy))
  if dist == 0 then dist = 1; dy = 1 end

  local stepX = dx / dist
  local stepY = dy / dist

  local lastX = px
  local lastY = py
  local currX = px + 0.5
  local currY = py + 0.5
  local playerId = player:getId()

  for i = 1, maxRange do
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

      local topCreature = tile:getTopCreature()
      if topCreature and topCreature:getId() ~= playerId and not topCreature:isInGhostMode() then
        break
      end
    end
  end

  return Position(lastX, lastY, pz)
end

function spellSetupVariant(player, CONFIG, CONFIG_SUP, mousePos)
  local targetCast = false
  local mouseCast = false
  local forceDirectional = false
  if not player then
    return nil
  end
  local target = player:getTarget()
  if CONFIG.forwardCast then
    if target and not target:isRemoved() then
      targetCast = player:targetRechable(target:getPosition(), CONFIG_SUP.range)
      if not targetCast then 
        return nil
      end
    else
      if mousePos then
        mouseCast = player:targetRechable(mousePos, CONFIG_SUP.range)
        if not mouseCast then
          return nil
        end
      else
        forceDirectional = true
      end
    end
  end

  local variant = nil
  if CONFIG.selfTarget then
    variant = Variant(player)
  elseif CONFIG.directional or forceDirectional then
    variant = Variant(player, true)
  elseif targetCast or CONFIG.needTarget then
    variant = Variant(target)
  elseif mouseCast then
    variant = Variant(mousePos)
  end

  return variant
end

function spellSetupTargetCombat(player, combat, CONFIG, CONFIG_SUP, item, extraFunc)
  if #CONFIG_SUP.func > 0 then
    local damage = spellGlobalFormule(player, CONFIG, CONFIG_SUP, item)
    function onTargetCombat(player, target)
      for i = 1, #CONFIG_SUP.func do
        CONFIG_SUP.func[i](player, target, damage[1]+damage[2])
      end
      if extraFunc then
        extraFunc(player, target)
      end
    end
    combat:setCallback(CALLBACK_PARAM_TARGETCREATURE, "onTargetCombat")
  else
    function clean(player, target)
      if extraFunc then
        extraFunc(player, target)
      end
    end
    combat:setCallback(CALLBACK_PARAM_TARGETCREATURE, "clean")
  end
end

function spellExecuteCombat(player, combat, CONFIG, CONFIG_SUP, item, variant, mousePos, free)
  local variant = variant or spellSetupVariant(player, CONFIG, CONFIG_SUP, mousePos)
  if not variant then
    return false
  end
  if not free then
    if not spellTakeCost(player, CONFIG, CONFIG_SUP) then
      return false
    end
  end

  return combat:execute(player, variant, CONFIG_SUP.multiCast, CONFIG_SUP.critC, CONFIG_SUP.critM, CONFIG_SUP.gamble, CONFIG_SUP.realUID)
end

function spellCleanAfterCast(player, combat)
  combat:delete()
  combat = nil
end

function spellTakeCost(player, CONFIG, CONFIG_SUP)
  if #CONFIG_SUP.onCast > 0 then
    for i = 1, #CONFIG_SUP.onCast do
      CONFIG_SUP.onCast[i](player)
    end
  end

local healtRecovery = 0
local manaRecovery = 0
local esRecovery = 0
if colleftInfo[player:getId()].attributesItems[46] then -- health on Hit
  healtRecovery = healtRecovery + colleftInfo[player:getId()].attributesItems[46].value
end
if colleftInfo[player:getId()].attributesItems[201] then
  manaRecovery = manaRecovery + colleftInfo[player:getId()].attributesItems[201].value
end
if player:hasBuff(SACRED_PATH) then -- Sacred Path
  if CONFIG_SUP.type == COMBAT_HOLYDAMAGE then
    healtRecovery = healtRecovery + (player:getMaxHealth() * 0.01)
    esRecovery = esRecovery + (player:getMaxEnergyShield() * 0.01)
  end
end
if player:getCharacterStat(CHARSTAT_HPHIT) then -- HP on Hit
    healtRecovery = healtRecovery + (player:getCharacterStat(CHARSTAT_HPHIT))
end
if player:getCharacterStat(CHARSTAT_ESHIT) then -- ES on Hit
    esRecovery = esRecovery + (player:getCharacterStat(CHARSTAT_ESHIT))
end
if healtRecovery > 0 then
  player:addHealth(healtRecovery)
end
if manaRecovery > 0 then
  player:addMana(manaRecovery)
end
if esRecovery > 0 then
  player:addEnergyShield(esRecovery)
end
--  end
  if CONFIG_SUP.lifeTap then
    local tapCostHP = player:getMaxHealth() * 0.05
    addHealthCast(player:getId(), -CONFIG_SUP.manaCost, CONFIG_SUP.force)
    if colleftInfo[player:getId()].attributesItems[126] then -- Subklas Arc Leech
      player:addEnergyShield(math.ceil(player:getMaxEnergyShield() * US_ENCHANTMENTS[126].subvalue))
    end
    if player:getStorageValue(435024) == 5 then -- Sorcerer + Shadow Warlock
      player:addEnergyShield(player:getMaxEnergyShield() * FUSION_SCALING[5].regen)
    end
    if colleftInfo[player:getId()].attributesItems[132] then -- Subklas Bloodfire
      if player:getHealth() >= player:getMaxHealth() * US_ENCHANTMENTS[132].subvalue then
        local hpCost = player:getMaxHealth() * US_ENCHANTMENTS[132].subvalue
        player:addHealth(-hpCost)
      end
    end
    return player:addHealth(-tapCostHP)
  elseif not CONFIG_SUP.lifeTap then
    if player:getStorageValue(435024) == 5 then -- Sorcerer + Shadow Warlock
      player:addEnergyShield(player:getMaxEnergyShield() * FUSION_SCALING[5].regen)
    end
    if colleftInfo[player:getId()].attributesItems[117] then -- Mana Spent gained as Energy Shield
      player:addEnergyShield(math.ceil(CONFIG_SUP.manaCost * colleftInfo[player:getId()].attributesItems[117].value / 100))
    end
    if colleftInfo[player:getId()].attributesItems[126] then -- Subklas Arc Leech
      player:addEnergyShield(math.ceil(player:getMaxEnergyShield() * US_ENCHANTMENTS[126].subvalue))
    end
    if colleftInfo[player:getId()].attributesItems[132] then -- Subklas Bloodfire
      if player:getHealth() >= player:getMaxHealth() * US_ENCHANTMENTS[132].subvalue then
        local hpCost = player:getMaxHealth() * US_ENCHANTMENTS[132].subvalue
        player:addHealth(-hpCost)
      end
    end
    return player:addMana(-CONFIG_SUP.manaCost)
  end
end

function spellJump(player, targetPos, height, speed)
  player:setDirection(player:getPosition():getDirectionToPlayer(targetPos))
  player:jump(height, speed)
end

function spellChainCast(combat, cid, tid, lastPos, time, effect, CONFIG, CONFIG_SUP, free, effectEx, moveEffect)
  addEvent(function()
    local player = Player(cid)
    local target = Creature(tid)
    if player and target then
      local position = lastPos or player:getPosition()
      if effectEx then
        local positionEx = Position(target:getPosition().x + moveEffect, target:getPosition().y + moveEffect, target:getPosition().z)
        positionEx:sendMagicEffect(effectEx)
      end
      if CONFIG.lineEffect then
        position:sendLineEffect(target:getPosition(), effect)
      else
        position:sendDistanceEffect(target:getPosition(), effect)
      end

      spellExecuteCombat(player, combat, CONFIG, CONFIG_SUP, item, Variant(tid), nil, free)
    end
  end, time)
end

function getClosestTargets(player, currentTarget, position, range, maxTargets, canWalkTo)
  local closestTargets = {}
  local spectators = Game.getSpectators(position, false, false, range, range, range, range)
  table.sort(spectators, function(a, b) return a:getPosition():getDistance(position) < b:getPosition():getDistance(position) end)
  for i = 1, #spectators do
    if spectators[i] ~= player and not spectators[i]:isPlayer() then
      if spectators[i]:isMonster() then
        if spectators[i] ~= currentTarget then
          if not table.contains(closestTargets, spectators[i]) then
            local checkPathing = false
            if canWalkTo then 
              checkPathing = player:targetRechable(spectators[i]:getPosition(), range, false)
            else
              checkPathing = true
            end

            if checkPathing then
              table.insert(closestTargets, spectators[i])
              if #closestTargets >= maxTargets then
                break
              end
            end
          end
        end
      end
    end
  end

  return closestTargets
end

function getClosestTarget(player, range, target, lastTarget)
  if target then
    if target == lastTarget then
      return nil
    end

    local checkPathing = player:getPathTo(target:getPosition(), 0, 1, false, false, range)
    if checkPathing then
      return target
    end
  end

  local spectators = Game.getSpectators(player:getPosition(), false, false, range+1, range+1, range+1, range+1)
  table.sort(spectators, function(a, b) return a:getPosition():getDistance(player:getPosition()) < b:getPosition():getDistance(player:getPosition()) end)
  for i = 1, #spectators do
    if spectators[i] ~= player and not spectators[i]:isPlayer() then
      if spectators[i]:isMonster() then
        if lastTarget and spectators[i] ~= lastTarget or target and spectators[i] ~= target then
          return getClosestTarget(player, range, spectators[i], target)
        elseif not lastTarget and not target then
          return getClosestTarget(player, range, spectators[i], target)
        end
      end
    end
  end

  return nil
end

function checkForTarget(player, targetId, range, lastTarget)
  local tempTarget = Monster(targetId)
  local target = getClosestTarget(player, range, tempTarget, lastTarget)
  if not target then
    player:sendCancelMessage("There is no target to attack.")
    return nil
  end

  return target
end

function spellFollowTarget(combat, pid, tid, pos)
  local player = Player(pid)
  local target = Creature(tid)
  if not player or not target then
    return
  end

  local position = player:getPosition()
  local targetPos = target:getPosition()
  local path = createPath(pos or position, targetPos, 1)
  local pos = path[1]
  combat:execute(player, Variant(pos))

  if pos.x == targetPos.x and pos.y == targetPos.y then
    return
  end

  addEvent(function()
    spellFollowTarget(combat, pid, tid, pos)
  end, 100)
end

function spellGetClosedTarget(player, cid, bounce, targets, sameTarget, range)
  targets = targets or {}
  if #targets >= bounce then
    return targets
  end
  
  local c = Creature(cid)
  if not c then
    return targets
  end

  if (player ~= c) then
    table.insert(targets, cid)
  end

  local cPosition = c:getPosition()
  local spectators = Game.getSpectators(cPosition, false, false, range, range, range, range)
  table.sort(spectators, function(a, b)
    return a:getPosition():getDistance(cPosition) < b:getPosition():getDistance(cPosition)
  end)
  
  local sid = nil
  if sameTarget then
    sid = findClosedTarget(player, spectators, targets, false, range) or findClosedTarget(player, spectators, targets, true, range)
  else
    sid = findClosedTarget(player, spectators, targets, false, range)
  end
  
  if sid then
    return spellGetClosedTarget(player, sid, bounce, targets, sameTarget, range)
  end

  return targets
end

function findClosedTarget(player, spectators, targets, sameTarget, range)
  local playerPos = player:getPosition()
  for _, spectator in ipairs(spectators) do
    local sid = spectator:getId()
    local checkLastCreature = false
    local checkSameTarget = sameTarget or not table.contains(targets, sid)
    if sameTarget then 
      if targets[#targets] and targets[#targets] == sid then
        checkSameTarget = false
      end
    end

    local lastCreature = Creature(targets[#targets])
    if lastCreature then
      checkLastCreature = true
    end

    if (spectator:isMonster() or (spectator:isPlayer() and not player:hasSecureMode())) and checkSameTarget then
      if canAttackTarget(playerPos, spectator:getPosition()) then
        if checkLastCreature then
          if spectator:targetRechable(lastCreature:getPosition(), range) then
            return sid
          end
        else
          return sid
        end
      end
    end
  end
  return nil
end

function spellStartChaining(player, combat, CONFIG, CONFIG_SUP, item, force, bounce, effectEx, moveEffect)
  if not bounce then
    bounce = CONFIG.bounces.max
    if CONFIG_SUP.bon then
      bounce = CONFIG_SUP.bon
    end
  end
  local target = player:getTarget()
  if not target then
    target = player
  else
    if not player:targetRechable(target:getPosition(), CONFIG_SUP.range) then
      spellCleanAfterCast(player, combat)
      return
    end
  end

  local targets = spellGetClosedTarget(player, target:getId(), bounce, nil, CONFIG.sameTarget, CONFIG_SUP.range)
  if #targets == 0 then
    player:sendCancelMessage("There is no target nearby to cast the spell.")
    spellCleanAfterCast(player, combat)
    return
  end

  local maxTime = 0
  for i, tid in pairs(targets) do
    if i ~= 1 and math.random(100) > CONFIG.bounces.chance then
      break
    end
    local lastPos = nil
    if targets[i - 1] then
      if type(targets[i - 1]) == "number" then
        local lastCreature = Creature(targets[i - 1])
        if lastCreature then
          lastPos = lastCreature:getPosition()
        end
      else
        if targets[i - 1] then
          lastPos = targets[i - 1]:getPosition()
        end
      end
    end
    if i == 1 then
      spellSetupCooldown(player, CONFIG, CONFIG_SUP, force)
    end

    maxTime = CONFIG.timeBeetwean * (i - 1)
    spellChainCast(combat, player:getId(), tid, lastPos, CONFIG.timeBeetwean * (i - 1), CONFIG.distanceEffect, CONFIG, CONFIG_SUP, i ~= 1, effectEx, moveEffect)
  end

  addEvent(function()
    spellCleanAfterCast(nil, combat)
  end, maxTime + 1000)
end

function Position:getDirectionToPlayer(toPosition)
  local dir = DIRECTION_NORTH
  if(self.x > toPosition.x) then
      dir = DIRECTION_WEST
      if(self.y > toPosition.y) then
          dir = DIRECTION_WEST
      elseif(self.y < toPosition.y) then
          dir = DIRECTION_WEST
      end
  elseif(self.x < toPosition.x) then
      dir = DIRECTION_EAST
      if(self.y > toPosition.y) then
          dir = DIRECTION_EAST
      elseif(self.y < toPosition.y) then
          dir = DIRECTION_EAST
      end
  else
      if(self.y > toPosition.y) then
          dir = DIRECTION_NORTH
      elseif(self.y < toPosition.y) then
          dir = DIRECTION_SOUTH
      end
  end
  return dir
end

function isBadTileSpells(tile)
	return (tile == nil
		or tile:getGround() == nil
		or tile:hasProperty(TILESTATE_NONE)
		or tile:hasProperty(TILESTATE_FLOORCHANGE_EAST)
		or tile:hasFlag(TILESTATE_FLOORCHANGE)
		or tile:hasFlag(TILESTATE_HOUSE)
		or tile:hasFlag(TILESTATE_BLOCKSOLID)
		or isItem(tile:getThing()) and not isMoveable(tile:getThing())
		or not tile:isWalkable()
		or tile:hasFlag(TILESTATE_PROTECTIONZONE)
	)
end

function Player:sendActiveAura(id, enabled)
  for i = 1, 4 do
    local item = self:getSlotItem(11+i)
    if item then
      if item:getRealUID() == id then
        self:sendExtendedOpcode(ExtendedOPCodes.CODE_CASTSPELL, json.encode({slot = i, enabled = enabled}))
        break
      end
    end
  end
end

function getRandomPosition(pos, newPos)
  pos:getNextPosition(math.random(0, 7))
  local found = false
  if isBadTile2(Tile(pos)) then
    for i = 0, 7 do
      local copyPos = Position(newPos.x, newPos.y, newPos.z)
      copyPos:getNextPosition(i)
      if not isBadTile2(Tile(copyPos)) then
        return copyPos
      end
    end

    return newPos
  end

  return pos
end

function getNextPositionByDir(pos, newPos, dir, steps)
  local copyPos = Position(newPos.x, newPos.y, newPos.z)
  for i = 1, steps do
    copyPos:getNextPosition(dir)
    if isBadTile2(Tile(copyPos)) then
      return pos
    end
  end

  return copyPos
end