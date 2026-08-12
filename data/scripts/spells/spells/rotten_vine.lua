local CONFIG = {
  spellName = GLOBAL_SPELL_COOLDOWNS[116].name,
  manaCost = GLOBAL_SPELL_COOLDOWNS[116].manaCost,
  spellId = 116,
  aggressive = true,
  cooldown = GLOBAL_SPELL_COOLDOWNS[116].cooldown,
  type = COMBAT_DEATHDAMAGE,
  defualtArea = { { 3 } },
  projectile = GLOBAL_SPELL_COOLDOWNS[116].split,

  supports = {
    ["dot"] = false,
    ["resize"] = false,
    ["pinpoint"] = false,
    ["split"] = true,
  }
}

local function spellWalkRandomly(combat, pid, expireTime, walkSpeed, pos, CONFIG_SUP)
  local player = Player(pid)
  if not player then
    return
  end

  local tempPos = Position(pos.x, pos.y, pos.z)
  local newPos = Position(pos.x, pos.y, pos.z)
  tempPos = getRandomPosition(tempPos, newPos)
  newPos:sendDistanceEffect(tempPos, 269, false, walkSpeed, 1.0)

  local tile = Tile(tempPos)
  if tile then
    local monster = tile:getTopCreature()
    if monster and monster:isMonster() then
      spellExecuteCombat(player, combat, CONFIG, CONFIG_SUP, item, Variant(tempPos), nil, true)
      return
    end
  end
  expireTime = expireTime - walkSpeed
  if expireTime <= 0 then
    addEvent(function()
      tempPos:sendMagicEffect(200)
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
  local sparkCount = CONFIG_SUP.projectile
  if colleftInfo[player:getId()].attributesItems[143] then
    sparkCount = sparkCount + US_ENCHANTMENTS[143].subvalue
  end

  for i = 1, sparkCount do
    spellWalkRandomly(combat, player:getId(), 2500, 100, playerPos, CONFIG_SUP)
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