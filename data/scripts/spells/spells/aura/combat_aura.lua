local CONFIG = {
  spellName = GLOBAL_SPELL_COOLDOWNS[27].name,
  level = 1,
  magLevel = 0,
  spellId = 27,
  manaReservation = GLOBAL_SPELL_COOLDOWNS[27].manaReservation,
  buff = COMBAT_AURA,
  cooldown = 3000,

  supports = table.copy(NON_DMG_AURAS_BASIC),
}
CONFIG.supports["basicPen"] = true
CONFIG.supports["dualpen"] = true
CONFIG.supports["armorPen"] = true
CONFIG.supports["elePen"] = true

local ACTIVE_PLAYERS = {}
local function castSpell(player, item, getInfoOnly)
  if not spellCheckForCast(player, item, CONFIG.spellId, getInfoOnly, force) then return end
  local CONFIG_SUP = item:applySupportSpells(CONFIG, player:getId())

  if getInfoOnly then
    return spellGetInfoToSend(player, CONFIG, CONFIG_SUP, item, tempArea)
  end

  if not checkCastableSpell(player, CONFIG, CONFIG_SUP, force) then return end
  spellSetupAuraCast(player, CONFIG, CONFIG_SUP, item)
  ACTIVE_PLAYERS[player:getId()] = true
  spellSetupCooldown(player, CONFIG, CONFIG_SUP)
end

local function onCastSpell(player, item, getInfoOnly)
  if not spellCheckForCast(player, item, CONFIG.spellId, getInfoOnly, force) then return end

  if getInfoOnly then
    return castSpell(player, item, getInfoOnly)
  else
    if ACTIVE_PLAYERS[player:getId()] then
      ACTIVE_PLAYERS[player:getId()] = nil
      spellSetupAuraEnd(player, CONFIG, item)
    else
      castSpell(player, item, getInfoOnly)
    end
  end
end

local function removeActive(player, item)
  if ACTIVE_PLAYERS[player:getId()] then
    ACTIVE_PLAYERS[player:getId()] = nil
    spellSetupAuraEnd(player, CONFIG, item)
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
}