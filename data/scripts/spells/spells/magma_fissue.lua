local CONFIG = {
  spellName = GLOBAL_SPELL_COOLDOWNS[60].name,
  manaCost = GLOBAL_SPELL_COOLDOWNS[60].manaCost,
  spellId = 60,
  aggressive = true,
  cooldown = GLOBAL_SPELL_COOLDOWNS[60].cooldown,
  type = COMBAT_FIREDAMAGE,
  defualtArea = { { 3 } },
  projectile = GLOBAL_SPELL_COOLDOWNS[60].split,

  supports = {
    ["dot"] = false,
    ["resize"] = false,
    ["pinpoint"] = false,
    ["split"] = true,
  }
}
--[[
local function spellWalkRandomly(combat, pid, expireTime, walkSpeed, pos, CONFIG_SUP)
  local player = Player(pid)
  if not player then
    return
  end

  local tempPos = Position(pos.x, pos.y, pos.z)
  local newPos = Position(pos.x, pos.y, pos.z)
  tempPos = getRandomPosition(tempPos, newPos)
--  newPos:sendDistanceEffect(tempPos, 205, false, walkSpeed, 1.0)
  newPos:sendMagicEffect(220)

  spellExecuteCombat(player, combat, CONFIG, CONFIG_SUP, item, Variant(tempPos), nil, true)

  expireTime = expireTime - walkSpeed
  if expireTime <= 0 then
    addEvent(function()
      tempPos:sendMagicEffect(448)
    end, walkSpeed)
    return
  end

  addEvent(function()
    spellWalkRandomly(combat, pid, expireTime, walkSpeed, tempPos, CONFIG_SUP)
  end, walkSpeed)
end

local function onCastSpell(player, item, getInfoOnly, force, mousePos)
  if not spellCheckForCast(player, item, CONFIG.spellId, getInfoOnly, force) then return end
  local CONFIG_SUP = item:applySupportSpells(CONFIG, player:getId())
  local area, tempArea = spellSetupArea(CONFIG, CONFIG_SUP, resizeTo)

  if getInfoOnly then
    return spellGetInfoToSend(player, CONFIG, CONFIG_SUP, item, tempArea)
  end
  if not checkCastableSpell(player, CONFIG, CONFIG_SUP, force) then return end


  local dmg = spellGlobalFormule(player, CONFIG, CONFIG_SUP, item)
  local combat = spellSetupCombat(player, CONFIG, CONFIG_SUP, area, dmg, force)
  local extraFunc = function(player, target)
    if math.random(1,100) <= 20 then
      target:startDOT(player, IGNITE_ITEM, 0, false, 5000, 448)
    end
  end
  spellSetupTargetCombat(player, combat, CONFIG, CONFIG_SUP, item, extraFunc)

  local playerPos = player:getPosition()
  spellTakeCost(player, CONFIG, CONFIG_SUP)
  spellSetupCooldown(player, CONFIG, CONFIG_SUP, force)
  for i = 1, CONFIG_SUP.projectile do
    spellWalkRandomly(combat, player:getId(), 1000, 250, playerPos, CONFIG_SUP)
  end
  return true
end
--]]

local function spellWalkRandomly(combat, pid, expireTime, walkSpeed, pos, CONFIG_SUP)
  local player = Player(pid)
  if not player then
    return
  end

  local tempPos = Position(pos.x, pos.y, pos.z)
  local newPos = Position(pos.x, pos.y, pos.z)
  tempPos = getRandomPosition(tempPos, newPos)
  -- newPos:sendDistanceEffect(tempPos, 140, false, walkSpeed, 1.0)
  -- newPos:sendMagicEffect(220)
  tempPos:sendLineEffect(newPos, 220, false)


  local tile = Tile(tempPos)
  if tile then
    local monster = tile:getTopCreature()
    if monster and monster:isMonster() then
      spellExecuteCombat(player, combat, CONFIG, CONFIG_SUP, item, Variant(tempPos), nil, true)
      tempPos:sendMagicEffect(448)
      return
    end
  end
  expireTime = expireTime - walkSpeed
  if expireTime <= 0 then
    addEvent(function()
      tempPos:sendMagicEffect(448)
    end, walkSpeed)
    return
  end

  addEvent(function()
    spellWalkRandomly(combat, pid, expireTime, walkSpeed, tempPos, CONFIG_SUP)
  end, walkSpeed)
end

-- Uses global SPELL_COMBATS_TO_REMOVE for proper cleanup on logout
local function onCastSpell(player, item, getInfoOnly, force, mousePos)
  if not spellCheckForCast(player, item, CONFIG.spellId, getInfoOnly, force) then return end
  local CONFIG_SUP = item:applySupportSpells(CONFIG, player:getId())
  local area, tempArea = spellSetupArea(CONFIG, CONFIG_SUP, resizeTo)

  if getInfoOnly then
    return spellGetInfoToSend(player, CONFIG, CONFIG_SUP, item, tempArea)
  end
  if not checkCastableSpell(player, CONFIG, CONFIG_SUP, force) then return end
  
  local playerId = player:getId()
  if not SPELL_COMBATS_TO_REMOVE[playerId] then
    SPELL_COMBATS_TO_REMOVE[playerId] = {
      combats = {},
      time = os.time(),
    }
  elseif os.time() - SPELL_COMBATS_TO_REMOVE[playerId].time > 30 then
    for i = 1, #SPELL_COMBATS_TO_REMOVE[playerId].combats do
      spellCleanAfterCast(player, SPELL_COMBATS_TO_REMOVE[playerId].combats[i])
    end
    SPELL_COMBATS_TO_REMOVE[playerId].combats = {}
    SPELL_COMBATS_TO_REMOVE[playerId].time = os.time()
  end

  local dmg = spellGlobalFormule(player, CONFIG, CONFIG_SUP, item)
  local combat = spellSetupCombat(player, CONFIG, CONFIG_SUP, area, dmg, force)
  table.insert(SPELL_COMBATS_TO_REMOVE[playerId].combats, combat)
  spellSetupTargetCombat(player, combat, CONFIG, CONFIG_SUP, item)

  local playerPos = player:getPosition()
  spellTakeCost(player, CONFIG, CONFIG_SUP)
  spellSetupCooldown(player, CONFIG, CONFIG_SUP, force)


  for i = 1, CONFIG_SUP.projectile do
    spellWalkRandomly(combat, player:getId(), 2000, 100, playerPos, CONFIG_SUP)
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