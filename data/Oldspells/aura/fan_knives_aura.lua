local resizeTo = {
  [1] = {
    {0, 1, 1, 1, 0},
    {1, 1, 1, 1, 1},
    {1, 1, 3, 1, 1},
    {1, 1, 1, 1, 1},
    {0, 1, 1, 1, 0}
  },

  [2] = {
    {1, 1, 1, 1, 1},
    {1, 1, 1, 1, 1},
    {1, 1, 3, 1, 1},
    {1, 1, 1, 1, 1},
    {1, 1, 1, 1, 1}
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
    {0, 0, 1, 1, 1, 0, 0},
    {0, 1, 1, 1, 1, 1, 0},
    {1, 1, 1, 1, 1, 1, 1},
    {1, 1, 1, 3, 1, 1, 1},
    {1, 1, 1, 1, 1, 1, 1},
    {0, 1, 1, 1, 1, 1, 0},
    {0, 0, 1, 1, 1, 0, 0}
  },
}

local CONFIG = {
  spellName = GLOBAL_SPELL_COOLDOWNS[83].name,
  level = 1,
  magLevel = 0,
  spellId = 83,
  manaCost = GLOBAL_SPELL_COOLDOWNS[83].manaCost,
  aggressive = true,
  selfTarget = true,
  type = COMBAT_PHYSICALDAMAGE,
  aura = 0,
  buff = AURA_FAN_KNIVES,
  cooldown = GLOBAL_SPELL_COOLDOWNS[83].cooldown,
  dmgInfo = "0.5s",
  manaInfo = "1s",

  defualtArea = {
    {1, 1, 1},
    {1, 3, 1},
    {1, 1, 1}
  },
  supports = table.copy(DMG_AURAS),
}

local ACTIVE_PLAYERS = {}
local HIDDEN_AURA = {}

local function startLoopDamage(id, combat)
  local player = Player(id)
  if not player or player:isRemoved() then 
    if ACTIVE_PLAYERS[id] then
      -- Clean up combat object to prevent memory leak
      combat:delete()
      ACTIVE_PLAYERS[id] = nil
      HIDDEN_AURA[id] = nil
    end
    return 
  end

  if player:getZone() == 0 and not HIDDEN_AURA[id] then
    HIDDEN_AURA[id] = true
    player:removeActiveAura(CONFIG.aura)
    player:removeBuff(CONFIG.buff)
  elseif player:getZone() ~= 0 and HIDDEN_AURA[id] then
    HIDDEN_AURA[id] = nil
    player:addActiveAura(CONFIG.aura, ACTIVE_PLAYERS[id].size)
  elseif not HIDDEN_AURA[id] then
    local variant = Variant(player)
    combat:execute(player, variant, 0, ACTIVE_PLAYERS[id].critC, ACTIVE_PLAYERS[id].critM, ACTIVE_PLAYERS[id].gamble)
  end

  -- Check if still active before scheduling next event to prevent orphan events
  if ACTIVE_PLAYERS[id] then
    stopEvent(ACTIVE_PLAYERS[id].event)
    ACTIVE_PLAYERS[id].event = addEvent(function()
      startLoopDamage(id, combat)
    end, 500)
  end
end

local function castSpell(player, item, getInfoOnly, force)
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
    if target:isMonster() then
      player:getPosition():sendDistanceEffect(target:getPosition(), 9)
      target:getPosition():sendMagicEffect(1)
    end
  end
  spellSetupTargetCombat(player, combat, CONFIG, CONFIG_SUP, item, extraFunc)
  spellSetupAuraCast(player, CONFIG, CONFIG_SUP, item)

  ACTIVE_PLAYERS[player:getId()] = {
    event = nil,
    size = CONFIG_SUP.resizeTo or 1,
    critC = CONFIG_SUP.critC,
    critM = CONFIG_SUP.critM,
    gamble = CONFIG_SUP.gamble,
    combat = combat,
  }
  HIDDEN_AURA[player:getId()] = nil
  startLoopDamage(player:getId(), combat)
  if CONFIG_SUP.lifeTap then
    player:addHealthGain(100 + CONFIG.spellId, -CONFIG_SUP.manaCost, true)
  else
    player:addManaGain(100  + CONFIG.spellId, -CONFIG_SUP.manaCost, true)
  end
  spellSetupCooldown(player, CONFIG, CONFIG_SUP)
end

local function onCastSpell(player, item, getInfoOnly)
  if not spellCheckForCast(player, item, CONFIG.spellId, getInfoOnly, force) then return end

  if getInfoOnly then
    return castSpell(player, item, getInfoOnly)
  else
    if ACTIVE_PLAYERS[player:getId()] then
      stopEvent(ACTIVE_PLAYERS[player:getId()].event)
      spellCleanAfterCast(player, ACTIVE_PLAYERS[player:getId()].combat)
      ACTIVE_PLAYERS[player:getId()] = nil
      spellSetupAuraEnd(player, CONFIG, item)
      player:removeManaGain(100 + CONFIG.spellId, true)
      player:removeHealthGain(100 + CONFIG.spellId, true)
    else
      castSpell(player, item, getInfoOnly)
    end
  end
end

local function removeActive(player, item)
  if ACTIVE_PLAYERS[player:getId()] then
    stopEvent(ACTIVE_PLAYERS[player:getId()].event)
    spellCleanAfterCast(player, ACTIVE_PLAYERS[player:getId()].combat)
    ACTIVE_PLAYERS[player:getId()] = nil
    spellSetupAuraEnd(player, CONFIG, item)
    player:removeManaGain(100 + CONFIG.spellId, true)
    player:removeHealthGain(100 + CONFIG.spellId, true)
  end
end 

SPELLS[CONFIG.spellName] = {
  cast = function(player, item)
    onCastSpell(player, item)
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

  isActive = function(player)
    return ACTIVE_PLAYERS[player:getId()]
  end,

  spellId = CONFIG.spellId,
  overTimeMana = true,
}