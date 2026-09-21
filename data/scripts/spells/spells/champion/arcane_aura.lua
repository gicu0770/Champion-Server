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
  spellName = GLOBAL_SPELL_COOLDOWNS[17].name,
  level = 1,
  magLevel = 0,
  spellId = 17,
  manaCost = GLOBAL_SPELL_COOLDOWNS[17].manaCost,
  aggressive = true,
  selfTarget = true,
  aura = 2, -- Using aura effect id 2 for now, change if a specific energy/arcane aura exists
  cooldown = GLOBAL_SPELL_COOLDOWNS[17].cooldown,
  type = COMBAT_ENERGYDAMAGE,
  dmgInfo = "1s",
  manaInfo = "1s",

  defualtArea = {
    {1, 1, 1},
    {1, 3, 1},
    {1, 1, 1}
  },

  supports = table.copy(DMG_AURAS) or {
    ["dot"] = true,
    ["aoe"] = true,
    ["resize"] = true,
  },
}

local ACTIVE_PLAYERS = {}
local HIDDEN_AURA = {}

local function startLoopDamage(id, combat)
  local player = Player(id)
  if not player or player:isRemoved() then 
    if ACTIVE_PLAYERS[id] then
      combat:delete()
      ACTIVE_PLAYERS[id] = nil
      HIDDEN_AURA[id] = nil
    end
    return 
  end

  if player:getZone() == 0 and not HIDDEN_AURA[id] then
    HIDDEN_AURA[id] = true
    player:removeActiveAura(CONFIG.aura)
  elseif player:getZone() ~= 0 and HIDDEN_AURA[id] then
    HIDDEN_AURA[id] = nil
    player:addActiveAura(CONFIG.aura, ACTIVE_PLAYERS[id].size)
  elseif not HIDDEN_AURA[id] then
    local variant = Variant(player)
    combat:execute(player, variant, 0, ACTIVE_PLAYERS[id].critC, ACTIVE_PLAYERS[id].critM, ACTIVE_PLAYERS[id].gamble)
  end

  if ACTIVE_PLAYERS[id] then
    stopEvent(ACTIVE_PLAYERS[id].event)
    ACTIVE_PLAYERS[id].event = addEvent(function()
      startLoopDamage(id, combat)
    end, 1000)
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
  spellSetupTargetCombat(player, combat, CONFIG, CONFIG_SUP, item)
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
  
  -- Drain mana per second
  local manaDrain = math.max(10, player:getMaxMana() * 0.02)
  if CONFIG_SUP.lifeTap then
    player:addHealthGain(100 + CONFIG.spellId, -manaDrain, true)
  else
    player:addManaGain(100  + CONFIG.spellId, -manaDrain, true)
  end
  spellSetupCooldown(player, CONFIG, CONFIG_SUP)
end

local function onCastSpell(player, item, getInfoOnly)
  if not spellCheckForCast(player, item, CONFIG.spellId, getInfoOnly, false) then return end

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
    player:removeManaGain(100 + CONFIG.spellId, true)
    player:removeHealthGain(100 + CONFIG.spellId, true)
  end
end

function onUse(player, item, fromPosition, target, toPosition, isHotkey)
  return onCastSpell(player, item, false, false, toPosition)
end

function getInfo(player, item)
  return onCastSpell(player, item, true)
end
