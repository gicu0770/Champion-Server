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
  spellName = "Affliction Aura",
  level = 1,
  magLevel = 0,
  spellId = 32,
  aggressive = true,
  selfTarget = true,
  combat = 2,
  aura = 3,
  manaCost = GLOBAL_SPELL_COOLDOWNS[32].manaCost,
  buff = AURA_AFFLICTION,
  type = COMBAT_DEATHDAMAGE,
  cooldown = GLOBAL_SPELL_COOLDOWNS[32].cooldown,
  dmgInfo = "over 2.5s",
  manaInfo = "1s",

  defualtArea = {
    {1, 1, 1},
    {1, 3, 1},
    {1, 1, 1}
  },

  supports = table.copy(DMG_AURAS),
}
CONFIG.supports["dot"] = true

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
    return spellGetInfoToSend(player, CONFIG, CONFIG_SUP, item, tempArea, true)
  end

  if not checkCastableSpell(player, CONFIG, CONFIG_SUP, force) then return end
  local dotDuration = 2500
  local dmgTick = 5
  if colleftInfo[player:getId()].attributesItems[142] then
    dotDuration = 1000
    dmgTick = 3
  end
  local dmg = {0, 0}
  local dotDmg = spellGlobalFormule(player, CONFIG, CONFIG_SUP, item, true)
  local combat = spellSetupCombat(player, CONFIG, CONFIG_SUP, area, dmg, force)


  local extraFunc = function(player, target)
    target:startDOT(player, DOT_ELEMENTAL_AFFLICTION_AURA, dotDmg[1] / dmgTick, false, dotDuration)

    if math.random(100) <= 100 then
      target:startDOT(player, HARVEST_DEBUFF, 0, false, 5000, 18)
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

local function removeActive(player, item, uid)
  if ACTIVE_PLAYERS[player:getId()] then
    stopEvent(ACTIVE_PLAYERS[player:getId()].event)
    spellCleanAfterCast(player, ACTIVE_PLAYERS[player:getId()].combat)
    ACTIVE_PLAYERS[player:getId()] = nil
    spellSetupAuraEnd(player, CONFIG, item)
    player:removeManaGain(102, true)
    player:removeHealthGain(102, true)
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