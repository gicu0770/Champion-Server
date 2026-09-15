local CONFIG = {
  spellName = GLOBAL_SPELL_COOLDOWNS[12].name,
  level = 1,
  magLevel = 0,
  manaCost = GLOBAL_SPELL_COOLDOWNS[12].manaCost,
  spellId = 12,
  range = GLOBAL_SPELL_COOLDOWNS[12].range or 0,
  aggressive = false,
  selfTarget = true,
  cooldown = GLOBAL_SPELL_COOLDOWNS[12].cooldown,
  type = COMBAT_PHYSICALDAMAGE,

  combat_config = {
    effect = CONST_ME_POFF,
  },

  defualtArea = {
    {3}
  },

  supports = {
    ["dot"] = false,
    ["single"] = true,
  },
}

local function onCastSpell(player, item, getInfoOnly, force, mousePos)
  if not spellCheckForCast(player, item, CONFIG.spellId, getInfoOnly, force) then return end
  local CONFIG_SUP = item:applySupportSpells(CONFIG, player:getId())
  
  if getInfoOnly then
    return spellGetInfoToSend(player, CONFIG, CONFIG_SUP, item, CONFIG.defualtArea)
  end
  if not checkCastableSpell(player, CONFIG, CONFIG_SUP, force) then return end

  -- Smoke cloud effect
  player:getPosition():sendMagicEffect(CONST_ME_POFF)

  -- Stealth (monsters ignore)
  local stealth = Condition(CONDITION_INVISIBLE)
  stealth:setParameter(CONDITION_PARAM_TICKS, 3500)
  player:addCondition(stealth)

  -- Real Invisibility (players don't see, completely hidden)
  if not player:isInGhostMode() then
    player:setGhostMode(true)
    local playerId = player:getId()
    addEvent(function()
      local p = Player(playerId)
      if p and p:isInGhostMode() and not p:getGroup():getAccess() then
        p:setGhostMode(false)
        -- Small delay to let the client process the appearance before teleporting to force update
        addEvent(function()
          local p2 = Player(playerId)
          if p2 then p2:teleportTo(p2:getPosition(), true) end
        end, 50)
      end
    end, 3500)
  end

  -- Speed boost +35%
  local speed = Condition(CONDITION_HASTE)
  speed:setParameter(CONDITION_PARAM_TICKS, 3500)
  speed:setParameter(CONDITION_PARAM_SPEED, math.floor(player:getBaseSpeed() * 0.35))
  player:addCondition(speed)

  -- Set storage for Death Mark next attack buff
  player:setStorageValue(PlayerStorage.deathMarkActive, os.time() + 4) -- lasts up to 4s (same as stealth roughly)

  spellSetupCooldown(player, CONFIG, CONFIG_SUP, force)
  if not force then
    spellTakeCost(player, CONFIG, CONFIG_SUP)
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
