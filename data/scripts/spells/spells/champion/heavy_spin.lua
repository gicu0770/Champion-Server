local resizeTo = {
  [1] = {
    {0, 0, 1, 0, 0},
    {0, 1, 1, 1, 0},
    {1, 1, 3, 1, 1},
    {0, 1, 1, 1, 0},
    {0, 0, 1, 0, 0}
  },
  [2] = {
    {0, 0, 0, 1, 0, 0, 0},
    {0, 0, 1, 1, 1, 0, 0},
    {0, 1, 1, 1, 1, 1, 0},
    {1, 1, 1, 3, 1, 1, 1},
    {0, 1, 1, 1, 1, 1, 0},
    {0, 0, 1, 1, 1, 0, 0},
    {0, 0, 0, 1, 0, 0, 0}
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
    {0, 0, 0, 0, 1, 0, 0, 0, 0},
    {0, 0, 0, 1, 1, 1, 0, 0, 0},
    {0, 0, 1, 1, 1, 1, 1, 0, 0},
    {0, 1, 1, 1, 1, 1, 1, 1, 0},
    {1, 1, 1, 1, 3, 1, 1, 1, 1},
    {0, 1, 1, 1, 1, 1, 1, 1, 0},
    {0, 0, 1, 1, 1, 1, 1, 0, 0},
    {0, 0, 0, 1, 1, 1, 0, 0, 0},
    {0, 0, 0, 0, 1, 0, 0, 0, 0}
  },
}

local CONFIG = {
  spellName = GLOBAL_SPELL_COOLDOWNS[6].name,
  level = 1,
  magLevel = 0,
  manaCost = GLOBAL_SPELL_COOLDOWNS[6].manaCost or 0,
  spellId = 6,
  range = GLOBAL_SPELL_COOLDOWNS[6].range or 0,
  aggressive = false,
  selfTarget = true,
  cooldown = GLOBAL_SPELL_COOLDOWNS[6].cooldown or 60000,
  type = COMBAT_PHYSICALDAMAGE,

  combat_config = {
  },

  defualtArea = {
    {1, 1, 1},
    {1, 3, 1},
    {1, 1, 1}
  },

  supports = {
    ["dot"] = false,
    ["close"] = true,
    ["aoe"] = false,
    ["resize"] = false,
  },
}

local function onCastSpell(player, item, getInfoOnly, force, mousePos)
  if not spellCheckForCast(player, item, CONFIG.spellId, getInfoOnly, force) then return end
  local CONFIG_SUP = item:applySupportSpells(CONFIG, player:getId())

  if getInfoOnly then
    return spellGetInfoToSend(player, CONFIG, CONFIG_SUP, item, nil)
  end
  if not checkCastableSpell(player, CONFIG, CONFIG_SUP, force) then return end

  spellSetupCooldown(player, CONFIG, CONFIG_SUP, force)
  if not force then
    spellTakeCost(player, CONFIG, CONFIG_SUP)
  end

  local expireTime = os.time() + 7
  player:setStorageValue(PlayerStorage.colossusRampageTime, expireTime)

  -- CC Cleanse: remove any active paralyze/slow
  player:removeCondition(CONDITION_PARALYZE)

  -- Visual effects
  local playerPos = player:getPosition()
  playerPos:sendMagicEffect(CONST_ME_MAGIC_RED)
  playerPos:sendMagicEffect(517)
  player:say("COLOSSUS!", TALKTYPE_MONSTER_SAY)

  -- Pulse visual effect and cleanse CC every 1s for 7 seconds
  local playerId = player:getId()
  for i = 1, 6 do
    addEvent(function()
      local p = Player(playerId)
      if p and p:getStorageValue(PlayerStorage.colossusRampageTime) >= os.time() then
        p:getPosition():sendMagicEffect(CONST_ME_MAGIC_RED)
        p:removeCondition(CONDITION_PARALYZE)
      end
    end, i * 1000)
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
