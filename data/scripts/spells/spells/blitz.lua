local CONFIG = {
  spellName = GLOBAL_SPELL_COOLDOWNS[111].name,
  level = 1,
  magLevel = 0,
  precentCost = true,
  manaCost = GLOBAL_SPELL_COOLDOWNS[111].manaCost,
  spellId = 111,
  range = GLOBAL_SPELL_COOLDOWNS[111].range,
  aggressive = true,
  targets = 0,
  needTarget = false,
  cooldown = GLOBAL_SPELL_COOLDOWNS[111].cooldown,
  type = COMBAT_ENERGYDAMAGE,
  combat_config = {
    effect = 0,
    effectEx = 606,
  },

  defualtArea = { { 3 } },
  newArea = { 
    { 1,1,1 },
    { 1,3,1 },
    { 1,1,1 },
   },

  supports = {
    ["dot"] = false,
    ["move"] = true,
    ["close"] = true,
    ["single"] = true,
  },
}

local CHANNELING_FLICKER = {}
local function executeFlickerStrike(player, target, combat, CONFIG_SUP, item, free, effectUnique)
  spellExecuteCombat(player, combat, CONFIG, CONFIG_SUP, item, Variant(target), nil, free)
  if effectUnique == 716 then
    Position(target:getPosition().x + 2, target:getPosition().y + 2, target:getPosition().z):sendMagicEffect(effectUnique)
  else
    target:getPosition():sendMagicEffect(effectUnique)
  end
end


local function preExecuteFlickerStrike(player, targetId, combat, CONFIG_SUP, item, effectUnique)
  local target = checkForTarget(player, targetId, CONFIG_SUP.range)
  if not target then 
    CHANNELING_FLICKER[player:getId()] = nil
    return 
  end

  local distance = getDistanceBetween(player:getPosition(), target:getPosition())
  if distance >= 2 then
    CHANNELING_FLICKER[player:getId()] = nil
    return
  end

  if CONFIG_SUP.targets >= 1 then
    local extraTargets = getClosestTargets(player, target, target:getPosition(), 2, CONFIG_SUP.targets, true)
    for i = 1, #extraTargets do
      executeFlickerStrike(player, extraTargets[i], combat, CONFIG_SUP, item, true, effectUnique)
    end
  end

  executeFlickerStrike(player, target, combat, CONFIG_SUP, item, nil, effectUnique)
  spellCleanAfterCast(player, combat)
  CHANNELING_FLICKER[player:getId()] = nil
end

local function startFlickerStrike(player, combat, CONFIG, CONFIG_SUP, item, effectUnique)
  local cid = player:getId()
  local target = checkForTarget(player, player:getTarget() and player:getTarget():getId() or 0, CONFIG_SUP.range)
  if not target then return end
  local targetPos = target:getPosition()
  local playerPos = player:getPosition()
  local distance = getDistanceBetween(targetPos, playerPos)

  local checkPathing = player:getPathTo(targetPos, 0, 1, false, false, 0, true)
  if not checkPathing then
    return
  end

  local distance = #checkPathing > 0 and #checkPathing or distance
  CHANNELING_FLICKER[cid] = true
  player:jump(8 * distance, 60 * distance)
  if #checkPathing == 0 then
    preExecuteFlickerStrike(player, target:getId(), combat, CONFIG_SUP, item, effectUnique)
    return
  end

  local stepCount = 0
  for k = #checkPathing, 1, -1 do
    stepCount = stepCount + 1
    local path = checkPathing[k]
    addEvent(function(cid)
      local player = Player(cid)
      if not player or player:isRemoved() then return end
      player:move(path)
      if k == 1 then
        preExecuteFlickerStrike(player, target:getId(), combat, CONFIG_SUP, item, effectUnique)
      end
    end, 33*stepCount, player:getId())
  end
end

local function onCastSpell(player, item, getInfoOnly, force, mousePos)
  if not getInfoOnly and CHANNELING_FLICKER[player:getId()] then return end
  if not spellCheckForCast(player, item, CONFIG.spellId, getInfoOnly, force) then return end
  local CONFIG_SUP = item:applySupportSpells(CONFIG, player:getId())
  local area
  local tempArea
  local effectUnique = 577

  if colleftInfo[player:getId()].attributesItems[191] then
    tempArea = CONFIG.newArea
    area = createCombatArea(CONFIG.newArea)
    effectUnique = 716
  else
    area, tempArea = spellSetupArea(CONFIG, CONFIG_SUP, resizeTo)
  end
  CONFIG_SUP.targets = CONFIG_SUP.resizeTo and CONFIG_SUP.resizeTo or 0

  if getInfoOnly then
    return spellGetInfoToSend(player, CONFIG, CONFIG_SUP, item, tempArea)
  end
  if not checkCastableSpell(player, CONFIG, CONFIG_SUP, force) then return end

  local dmg = spellGlobalFormule(player, CONFIG, CONFIG_SUP, item)
  local combat = spellSetupCombat(player, CONFIG, CONFIG_SUP, area, dmg, force)
  spellSetupTargetCombat(player, combat, CONFIG, CONFIG_SUP, item)
  startFlickerStrike(player, combat, CONFIG, CONFIG_SUP, item, effectUnique)
  local target = checkForTarget(player, player:getTarget() and player:getTarget():getId() or 0, CONFIG_SUP.range)
  if not target then return end
  player:getPosition():sendLineEffect(target:getPosition(), CONFIG.combat_config.effectEx)
  spellSetupCooldown(player, CONFIG, CONFIG_SUP, force)
  return true
end

local function removeActive(player, item)
  if CHANNELING_FLICKER[player:getId()] then
    CHANNELING_FLICKER[player:getId()] = nil
  end
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

  disable = function(player, item)
    removeActive(player, item)
  end,

  spellId = CONFIG.spellId,
}
