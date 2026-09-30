PATH_BUFFS = {
	{buff = TOXIC_PATH},
	{buff = PYRO_PATH},
	{buff = CRYO_PATH},
	{buff = THUNDER_PATH},
	{buff = PASSING_PATH},
	{buff = SACRED_PATH},
	{buff = BLOODY_PATH},
}

local function restoreItemCooldowns(player)
  if not player then return end
  local now = os.time()
  local itemCooldowns = {
    { storage = PlayerStorage.gargoyleActiveCd, buff = GARGOYLE_STONEPLATE_CD },
    { storage = PlayerStorage.redemptionCooldown, buff = REDEMPTION_CD },
    { storage = PlayerStorage.zhonyaCooldown, buff = TIME_STOP_CD },
    { storage = PlayerStorage.bansheeCooldown, buff = ANNUL_CD },
    { storage = PlayerStorage.solariCooldown, buff = SOLARI_CD },
    { storage = PlayerStorage.guardianAngelCooldown, buff = GA_COOLDOWN },
  }

  for _, entry in ipairs(itemCooldowns) do
    if entry.storage and entry.buff then
      local cdEnd = player:getStorageValue(entry.storage)
      if cdEnd and cdEnd > now then
        local remainingMs = (cdEnd - now) * 1000
        if not player:hasBuff(entry.buff) then
          player:addBuff(entry.buff, remainingMs)
        else
          local buffData = { entry.buff, 1, remainingMs, true }
          player:sendExtendedOpcode(ExtendedOPCodes.CODE_BUFF, json.encode({1, buffData}))
        end
      end
    end
  end
end

local LoginEvent = CreatureEvent("LoginEventBuff")
function LoginEvent.onLogin(player)
  restoreItemCooldowns(player)
  player:getActiveBuffs()
  player:registerEvent("BuffExtendedOpcode")
  player:registerEvent("ReconnectEventBuff")
  local playerId = player:getId()
  addEvent(function()
    local player = Player(playerId)
    if not player then
      return
    end

    restoreItemCooldowns(player)
    player:autoOpenContainers()
  end, 100)
  return true
end

local ReconnectEvent = CreatureEvent("ReconnectEventBuff")
function ReconnectEvent.onReconnect(player)
  restoreItemCooldowns(player)
  player:getActiveBuffs()
  local playerId = player:getId()
  addEvent(function()
    local player = Player(playerId)
    if not player then
      return
    end

    restoreItemCooldowns(player)
    player:autoOpenContainers()
  end, 100)
  return true
end

local ExtendedEvent = CreatureEvent("BuffExtendedOpcode")
function ExtendedEvent.onExtendedOpcode(player, opcode, buffer)
  if opcode ~= ExtendedOPCodes.CODE_BOSSBAR then return false end
  local status, data = pcall(function() return json.decode(buffer) end)
  if not status then return false end

  if data == 1 then
    local target = player:getTarget()
    if not target then return end
    local id = target:getId()
    local buffs = CREATURE_ACTIVE_BUFFS[id]
    local buffsToSend = {}
    if buffs ~= nil then
      if buffs.monster then
        buffs.monster = nil
      end

      local buffsToDelete = {}
      for _, buff in pairs(buffs) do
        local leftTime = buff.endTime - (os.time() * 1000)
        if leftTime < 0 or buff.ticks == -1 then
          table.insert(buffsToDelete, buff.id)
        else
          local tempBuff = {
            buff.id,
            buff.stacks,
            leftTime,
          }
          table.insert(buffsToSend, tempBuff)
        end
      end

      for i = 1, #buffsToDelete do
        target:removeBuff(buffsToDelete[i])
      end
    end

    player:sendExtendedOpcode(ExtendedOPCodes.CODE_BOSSBAR, json.encode({1, id, buffsToSend}))
  end

  return true
end

local LogoutEvent = CreatureEvent("LogoutEventBuff")
function LogoutEvent.onLogout(player)
  if DOT_SYSTEM then
    DOT_SYSTEM.cleanup(player:getId())
    DOT_SYSTEM.cleanupCaster(player:getId())
  end

  if not CREATURE_ACTIVE_BUFFS[player:getId()] then
    return true
  end

  for _, buff in pairs(CREATURE_ACTIVE_BUFFS[player:getId()]) do
    local realBuff = BUFFS[buff.id]
    if realBuff then
      if not realBuff.saveAfterLogout then
        CREATURE_ACTIVE_BUFFS[player:getId()][buff.id] = nil
      end
    end
  end

  local size = 0
  for _, buff in pairs(CREATURE_ACTIVE_BUFFS[player:getId()]) do
    size = size + 1
  end

  if size == 0 then
    CREATURE_ACTIVE_BUFFS[player:getId()] = nil
  end
  return true
end

function addGlobalBuff(id, time)
  local buff = BUFFS[id]
  if not buff then
    return
  end

  if not GLOBAL_ACTIVE_BUFFS[id] then
    GLOBAL_ACTIVE_BUFFS[id] = {}
  else
    local leftTime = GLOBAL_ACTIVE_BUFFS[id].endTime - (os.time() * 1000)
    if leftTime > 0 or buff.ticks == -1 then
      updateGlobalBuff(id, time)
      return
    end
  end

  if buff.maxStacks == 1 then
    buff.stacks = 1
  end

  buff.server_time = os.time() * 1000
  if time == nil then
    buff.endTime = buff.server_time + buff.ticks
  else 
    buff.endTime = (os.time() * 1000) + time
  end

  GLOBAL_ACTIVE_BUFFS[id] = buff

  local buffToSend = {
    buff.id,
    buff.stacks,
    buff.endTime - os.time() * 1000,
    buff.debuff
  }

  for _, targetPlayer in ipairs(Game.getPlayers()) do
    targetPlayer:sendExtendedOpcode(ExtendedOPCodes.CODE_BUFF, json.encode({1, buffToSend }))
	end
end

function updateGlobalBuff(id, time)
  local buff = GLOBAL_ACTIVE_BUFFS[id]
  local realBuff = BUFFS[id]
  if buff and realBuff then
    buff.endTime = buff.endTime + time

    local buffToSend = {
      buff.id,
      buff.stacks,
      buff.endTime - os.time() * 1000,
      buff.debuff
    }

    for _, targetPlayer in ipairs(Game.getPlayers()) do
      targetPlayer:sendExtendedOpcode(ExtendedOPCodes.CODE_BUFF, json.encode({1, buffToSend}))
    end
  end
end

function getGlobalBuff(id)
  local buff = GLOBAL_ACTIVE_BUFFS[id]
  local realBuff = BUFFS[id]
  if buff and realBuff then
    local time = buff.endTime - (os.time() * 1000)
    if time > 0 or realBuff.ticks == -1 then
      realBuff.endTime = buff.endTime
      return realBuff
    else
      removeGlobalBuff(id)
      return false
    end
  else
    return false
  end
  return
end

function removeGlobalBuff(id)
  local buff = GLOBAL_ACTIVE_BUFFS[id]
  local realBuff = BUFFS[id]
  if buff and realBuff then
    for _, targetPlayer in ipairs(Game.getPlayers()) do
      if targetPlayer:isPlayer() then
        targetPlayer:sendExtendedOpcode(ExtendedOPCodes.CODE_BUFF, json.encode({3, {id, false}}))
      end
    end
    GLOBAL_ACTIVE_BUFFS[id] = nil
  end
end


function Creature:setBuffStacks(id, stacks, time)
  local buff = BUFFS[id]
  if not buff then
    return
  end

  local creature_buff = CREATURE_ACTIVE_BUFFS[self:getId()] and CREATURE_ACTIVE_BUFFS[self:getId()][id] or false
  if not creature_buff then
    self:addBuff(id, time, stacks)
    return
  end
  if not time then
    time = buff.ticks
  end

  local server_time = os.time() * 1000
  creature_buff.stacks = stacks
  creature_buff.endTime = server_time + time
  local buffToSend = {
    buff.id,
    stacks,
    creature_buff.endTime - (os.time() * 1000),
    buff.debuff,
  }

  if self:isPlayer() then
    self:sendExtendedOpcode(ExtendedOPCodes.CODE_BUFF, json.encode({2, buffToSend}))
  elseif self:isMonster() then
    local targetList = self:getTargetingPlayers()
    for _, playerBuff in ipairs(targetList) do
      if playerBuff then
        if not playerBuff:isRemoved() then
          local playerTarget = playerBuff:getTarget()
          if playerTarget == self then
            playerBuff:sendExtendedOpcode(ExtendedOPCodes.CODE_BOSSBAR, json.encode({3, buffToSend}))
          end
        end
      end
    end
  end
end

function Creature:addBuff(id, time, stacks, maxStacks)
  local buff = BUFFS[id]
  if not buff then
    return
  end

  if not CREATURE_ACTIVE_BUFFS[self:getId()] then
    CREATURE_ACTIVE_BUFFS[self:getId()] = {}
  end

  local playerList = {}
  if self:isMonster() then
    local targetList = self:getTargetingPlayers()
    for _, playerBuff in ipairs(targetList) do
      if playerBuff then
        if not playerBuff:isRemoved() then
          local playerTarget = playerBuff:getTarget()
          if playerTarget == self then
            table.insert(playerList, playerBuff)
          end
        end
      end
    end
  end

  if self:hasBuff(id, true) then
    self:updateBuff(id, time, playerList, maxStacks)
    return
  end

  local server_time = os.time() * 1000
  local duration = time or buff.ticks
  local endTime = server_time + duration
  stacks = stacks or 1
  CREATURE_ACTIVE_BUFFS[self:getId()][buff.id] = {
    id = buff.id,
    endTime = endTime,
    stacks = stacks,
  }

  if id == STUN and duration > 0 then
    self:setProgressBar(duration, false)
    if not self:hasCondition(CONDITION_STUN) then
      local c = Condition(CONDITION_STUN)
      c:setParameter(CONDITION_PARAM_TICKS, duration)
      self:addCondition(c)
    end
  elseif id == SILENCE and duration > 0 then
    self:setProgressBar(duration, false)
    if not self:hasCondition(CONDITION_SILENCE) then
      local c = Condition(CONDITION_SILENCE)
      c:setParameter(CONDITION_PARAM_TICKS, duration)
      self:addCondition(c)
    end
  elseif id == ROOT and duration > 0 then
    self:setProgressBar(duration, false)
    if not self:hasCondition(CONDITION_ROOT) then
      local c = Condition(CONDITION_ROOT)
      c:setParameter(CONDITION_PARAM_TICKS, duration)
      self:addCondition(c)
    end
  end

  local buffToSend = {
    buff.id,
    stacks,
    endTime - (os.time() * 1000),
    buff.debuff,
  }

  if self:isPlayer() then
    self:sendExtendedOpcode(ExtendedOPCodes.CODE_BUFF, json.encode({1, buffToSend}))
  else
    for _, player in pairs(playerList) do
      player:sendExtendedOpcode(ExtendedOPCodes.CODE_BOSSBAR, json.encode({2, buffToSend}))
    end
    CREATURE_ACTIVE_BUFFS[self:getId()].monster = true
  end
end

function Creature:getBuff(id)
  local buff = BUFFS[id]
  if self:hasBuff(id) and buff then
    local activeBuff = CREATURE_ACTIVE_BUFFS[self:getId()] and CREATURE_ACTIVE_BUFFS[self:getId()][id]
    if activeBuff then
      buff.endTime = activeBuff.endTime
      buff.stacks = activeBuff.stacks
    end
    return buff
  end
  return false
end

function Creature:getBuffStacks(id)
  local creatureBuffs = CREATURE_ACTIVE_BUFFS[self:getId()]
  if creatureBuffs and creatureBuffs[id] and self:hasBuff(id) then
    return creatureBuffs[id].stacks or 1
  end
  return 0
end

function Creature:updateBuff(id, time, playerList, maxStacks)
  local creatureBuff = CREATURE_ACTIVE_BUFFS[self:getId()][id]
  local buff = BUFFS[id]
  if buff and creatureBuff then
    local server_time = os.time() * 1000
    if buff.addTime then
      if time then
        creatureBuff.endTime = creatureBuff.endTime + time
      else
        creatureBuff.endTime = creatureBuff.endTime + buff.ticks
      end
    else
      if time then
        creatureBuff.endTime = server_time + time
      else
        creatureBuff.endTime = server_time + buff.ticks
      end
    end
    if not creatureBuff.stacks then
      creatureBuff.stacks = 1
    end
    if buff.stacked then
      creatureBuff.stacks = creatureBuff.stacks + 1
      local possibleMaxStacks = maxStacks or buff.maxStacks
      if possibleMaxStacks and possibleMaxStacks <= creatureBuff.stacks then
        creatureBuff.stacks = possibleMaxStacks
      end
    else
      creatureBuff.stacks = 1
    end

    CREATURE_ACTIVE_BUFFS[self:getId()][id] = {
      id = creatureBuff.id,
      endTime = creatureBuff.endTime,
      stacks = creatureBuff.stacks,
    }

    if id == STUN then
      local remaining = creatureBuff.endTime - server_time
      if remaining > 0 then
        self:setProgressBar(remaining, false)
      end
    elseif id == SILENCE then
      local remaining = creatureBuff.endTime - server_time
      if remaining > 0 then
        self:setProgressBar(remaining, false)
        local c = Condition(CONDITION_SILENCE)
        c:setParameter(CONDITION_PARAM_TICKS, remaining)
        self:addCondition(c)
      end
    elseif id == ROOT then
      local remaining = creatureBuff.endTime - server_time
      if remaining > 0 then
        self:setProgressBar(remaining, false)
        local c = Condition(CONDITION_ROOT)
        c:setParameter(CONDITION_PARAM_TICKS, remaining)
        self:addCondition(c)
      end
    end

    local data = buff
    local buffToSend = {
      data.id,
      creatureBuff.stacks,
      creatureBuff.endTime - (os.time() * 1000),
      data.debuff,
    }

    if self:isPlayer() then
      self:sendExtendedOpcode(ExtendedOPCodes.CODE_BUFF, json.encode({2, buffToSend}))
    else
      for _, player in pairs(playerList) do
        player:sendExtendedOpcode(ExtendedOPCodes.CODE_BOSSBAR, json.encode({3, buffToSend}))
      end
    end
  end
end

function Creature:removeBuff(id)
  if not id then
    return
  end

  if not CREATURE_ACTIVE_BUFFS[self:getId()] then
    return
  end

  local buff = BUFFS[id]
  if not buff then
    return
  end

  if CREATURE_ACTIVE_BUFFS[self:getId()][id] then
    CREATURE_ACTIVE_BUFFS[self:getId()][id] = nil
  end

  if id == STUN then
    self:setProgressBar(0, false)
    self:removeCondition(CONDITION_STUN)
  elseif id == SILENCE then
    self:setProgressBar(0, false)
    self:removeCondition(CONDITION_SILENCE)
  elseif id == ROOT then
    self:setProgressBar(0, false)
    self:removeCondition(CONDITION_ROOT)
  elseif id == ARDENT_CENSER_BUFF and self:isPlayer() then
    self:getTotalAttackSpeed()
  end

  local playerList = {}
  if self:isMonster() then
    local targetList = self:getTargetingPlayers()
    for _, playerBuff in ipairs(targetList) do
      if playerBuff then
        if not playerBuff:isRemoved() then
          local playerTarget = playerBuff:getTarget()
          if playerTarget == self then
            table.insert(playerList, playerBuff)
          end
        end
      end
    end
  end

  if self:isPlayer() then
    self:sendExtendedOpcode(ExtendedOPCodes.CODE_BUFF, json.encode({3, {id, buff.debuff}}))
  else
    for _, player in ipairs(playerList) do
      player:sendExtendedOpcode(ExtendedOPCodes.CODE_BOSSBAR, json.encode({4, id}))
    end
  end
end

function Creature:hasBuff(id, delete)
  if not CREATURE_ACTIVE_BUFFS[self:getId()] then
    return false
  end

  local buff = CREATURE_ACTIVE_BUFFS[self:getId()][id]
  local realBuff = BUFFS[id]
  if buff and realBuff then
    local time = buff.endTime - (os.time() * 1000)
    if time > 0 or realBuff.ticks == -1 then
      return true
    else
      if not delete then
        self:removeBuff(id)
      end
      return false
    end
  else
    return false
  end
end

function Creature:getActiveBuffs()
  local buffs = CREATURE_ACTIVE_BUFFS[self:getId()]
  if buffs then
    for _, buff in pairs(buffs) do
      if buff.id then
        local realBuff = BUFFS[buff.id]
        local time = buff.endTime - os.time() * 1000
        if time > 0 or realBuff.ticks == -1 then
          if self:hasBuff(buff.id) then
            if self:isPlayer() then
              if realBuff then
                local buffToSend = {
                  buff.id,
                  buff.stacks,
                  time,
                  buff.debuff,
                }

                self:sendExtendedOpcode(ExtendedOPCodes.CODE_BUFF, json.encode({1, buffToSend}))
              end
            end
          else
            self:addBuff(buff.id, time)
          end
        else
          CREATURE_ACTIVE_BUFFS[self:getId()][buff.id] = nil
        end
      end
    end
  end

  local globalBuffs = GLOBAL_ACTIVE_BUFFS
  if globalBuffs then
    for _, buff in pairs(globalBuffs) do
      local realBuff = BUFFS[buff.id]
      local time = buff.endTime - os.time() * 1000
      if time > 0 or realBuff.ticks == -1 then
        if self:isPlayer() then
          if realBuff then
            local buffToSend = {
              buff.id,
              buff.stacks,
              time,
              buff.debuff,
            }
            self:sendExtendedOpcode(ExtendedOPCodes.CODE_BUFF, json.encode({1, buffToSend}))
          end
        end
      else  
        removeGlobalBuff(buff.id)
      end
    end
  end
  return true
end

local DeathMonster = CreatureEvent("BuffDeath")
function DeathMonster.onDeath(creature, corpse, killer, mostDamage, unjustified, mostDamage_unjustified)
	if not creature or creature:isPlayer() then
		return true
	end

  if DOT_SYSTEM then
    DOT_SYSTEM.cleanup(creature:getId())
  end

  if CREATURE_ACTIVE_BUFFS[creature:getId()] then
    CREATURE_ACTIVE_BUFFS[creature:getId()] = nil
  end
	return true
end


DeathMonster:type("death")
DeathMonster:register()

LoginEvent:type("login")
LoginEvent:register()

ReconnectEvent:type("reconnect")
ReconnectEvent:register()

LogoutEvent:type("logout")
LogoutEvent:register()

ExtendedEvent:type("extendedopcode")
ExtendedEvent:register()

if not Creature._originalAddCondition then
  Creature._originalAddCondition = Creature.addCondition
  function Creature:addCondition(condition)
    if condition and condition:getType() == CONDITION_STUN then
      local ticks = condition:getTicks()
      if ticks > 0 and not self:hasBuff(STUN) then
        self:addBuff(STUN, ticks)
      end
    end
    return self:_originalAddCondition(condition)
  end
end

if not Creature._originalRemoveCondition then
  Creature._originalRemoveCondition = Creature.removeCondition
  function Creature:removeCondition(conditionType, conditionId, subId, force)
    if conditionType == CONDITION_STUN then
      if self:hasBuff(STUN) then
        self:removeBuff(STUN)
      end
    end
    return self:_originalRemoveCondition(conditionType, conditionId, subId, force)
  end
end