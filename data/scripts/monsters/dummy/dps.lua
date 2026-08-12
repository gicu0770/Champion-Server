DPS_STORAGE = PlayerStorage.dpsStorage
PLAYER_DPS = {}
PLAYER_EVENTS = {}
PLAYER_TIMERS = {}
PLAYER_HIGHEST_DPS = {}

function CheckDPS(pid, cid, startTime)
  local player = Player(pid)
  local target = Monster(cid)

  if not player or player:isRemoved() or not target or target:isRemoved() then
    return
  end

  PLAYER_DPS[pid] = PLAYER_DPS[pid] or {}
  PLAYER_HIGHEST_DPS[pid] = PLAYER_HIGHEST_DPS[pid] or {}
  PLAYER_TIMERS[pid] = PLAYER_TIMERS[pid] or {}
  PLAYER_EVENTS[pid] = PLAYER_EVENTS[pid] or {}

  local elapsed = os.time() - startTime
  local currentDPS = PLAYER_DPS[pid][cid] or 0
  local lastHighest = PLAYER_HIGHEST_DPS[pid][cid] or 0

  if currentDPS > lastHighest then
    PLAYER_HIGHEST_DPS[pid][cid] = currentDPS
  end

  target:setHealth(70000000000000000)

  if elapsed < 5 then
    PLAYER_EVENTS[pid][cid] = addEvent(CheckDPS, 1000, pid, cid, startTime)
  else
    local best = PLAYER_HIGHEST_DPS[pid][cid] or 0

    if best > player:getDPS() then
      player:setDPS(best)
      target:say(string.format("New Record! DPS: %s", formatDamage(best)), TALKTYPE_MONSTER_SAY, false, player, target:getPosition())
      player:sendTextMessage(MESSAGE_INFO_DESCR, "New DPS Record: " .. formatDamage(best))
    else
      target:say(string.format("DPS: %s", formatDamage(best)), TALKTYPE_MONSTER_SAY, false, player, target:getPosition())
      player:sendTextMessage(MESSAGE_INFO_DESCR, "Last DPS: " .. formatDamage(best))
    end

    PLAYER_EVENTS[pid][cid] = nil
    PLAYER_DPS[pid][cid] = 0
    PLAYER_HIGHEST_DPS[pid][cid] = 0
  end
end

local HealthDrain = CreatureEvent("DummyHealthDrain")
function HealthDrain.onHealthDrain(creature, attacker, damage)
  if creature and not creature:isRemoved() and creature:isMonster() and attacker and not attacker:isRemoved() and attacker:isPlayer() then
    local pid = attacker:getId()
    local cid = creature:getId()

    PLAYER_DPS[pid] = PLAYER_DPS[pid] or {}
    PLAYER_EVENTS[pid] = PLAYER_EVENTS[pid] or {}
    PLAYER_TIMERS[pid] = PLAYER_TIMERS[pid] or {}
    PLAYER_HIGHEST_DPS[pid] = PLAYER_HIGHEST_DPS[pid] or {}

    PLAYER_DPS[pid][cid] = (PLAYER_DPS[pid][cid] or 0) + math.abs(damage)

    if not PLAYER_EVENTS[pid][cid] then
      PLAYER_TIMERS[pid][cid] = os.time()
      PLAYER_EVENTS[pid][cid] = addEvent(CheckDPS, 1000, pid, cid, PLAYER_TIMERS[pid][cid])
    end
  end
end

HealthDrain:type("onhealthdrain")
HealthDrain:register()
