local resizeTo = {
  [1] = {
    { 0, 0, 1, 0, 0 },
    { 0, 1, 1, 1, 0 },
    { 1, 1, 3, 1, 1 },
    { 0, 1, 1, 1, 0 },
    { 0, 0, 1, 0, 0 }
  },
  [2] = {
    { 0, 1, 1, 1, 0 },
    { 1, 1, 1, 1, 1 },
    { 1, 1, 3, 1, 1 },
    { 1, 1, 1, 1, 1 },
    { 0, 1, 1, 1, 0 }
  },
  [3] = {
    { 1, 1, 1, 1, 1 },
    { 1, 1, 1, 1, 1 },
    { 1, 1, 3, 1, 1 },
    { 1, 1, 1, 1, 1 },
    { 1, 1, 1, 1, 1 }
  },
  [4] = {
    { 0, 0, 0, 1, 0, 0, 0 },
    { 0, 1, 1, 1, 1, 1, 0 },
    { 0, 1, 1, 1, 1, 1, 0 },
    { 1, 1, 1, 3, 1, 1, 1 },
    { 0, 1, 1, 1, 1, 1, 0 },
    { 0, 1, 1, 1, 1, 1, 0 },
    { 0, 0, 0, 1, 0, 0, 0 }
  },
}

local CONFIG = {
  spellName = GLOBAL_SPELL_COOLDOWNS[22].name,
  level = 1,
  magLevel = 0,
  precentCost = true,
  manaCost = GLOBAL_SPELL_COOLDOWNS[22].manaCost,
  spellId = 22,
  range = GLOBAL_SPELL_COOLDOWNS[22].range,
  aggressive = true,
  forwardCast = true,
  cooldown = GLOBAL_SPELL_COOLDOWNS[22].cooldown,
  type = COMBAT_ICEDAMAGE,
  dmgInfo = "x2",
  combat_config = {
    bottom = true,
  },
  --[[
  convert = {
    0.95,
    COMBAT_ICEDAMAGE,
  },
  --]]

  defualtArea = {
    {0, 0, 0, 1, 0, 0, 0},
    {0, 0, 1, 1, 1, 0, 0},
    {0, 1, 1, 1, 1, 1, 0},
    {1, 1, 1, 3, 1, 1, 1},
    {0, 1, 1, 1, 1, 1, 0},
    {0, 0, 1, 1, 1, 0, 0},
    {0, 0, 0, 1, 0, 0, 0}
  },

  supports = {
    ["dot"] = false,
    ["aoe"] = true,
  },
}

local function executeColdSnap(player, combat, CONFIG_SUP, item)
  local playerPos = player:getPosition()
  position = Position(playerPos.x + 1, playerPos.y + 1, playerPos.z)
  player:sendCreatureEffect(183)
end

local function onCastSpell(player, item, getInfoOnly, force, mousePos)
  if not spellCheckForCast(player, item, CONFIG.spellId, getInfoOnly, force) then return end
  local CONFIG_SUP = item:applySupportSpells(CONFIG, player:getId())
  local area, tempArea = spellSetupArea(CONFIG, CONFIG_SUP, resizeTo)


  if getInfoOnly then
    return spellGetInfoToSend(player, CONFIG, CONFIG_SUP, item, tempArea)
  end
  if not checkCastableSpell(player, CONFIG, CONFIG_SUP, force) then return end
  local variant = spellSetupVariant(player, CONFIG, CONFIG_SUP, mousePos)
  if not variant then return end

  local dmg = spellGlobalFormule(player, CONFIG, CONFIG_SUP, item)
  local combat = spellSetupCombat(player, CONFIG, CONFIG_SUP, area, dmg, force)
  spellSetupTargetCombat(player, combat, CONFIG, CONFIG_SUP, item)
  local hits = 2
  if colleftInfo[player:getId()].attributesItems[125] then
    hits = 3
  end
  local pid = player:getId()
  local uid = item:getRealUID()
  for i = 1, hits do
    addEvent(function() 
      local player = Player(pid)
      if not player or player:isRemoved() then return end
      local item = Game.getRealUniqueItem(uid)
      if not item then return end
      spellExecuteCombat(player, combat, CONFIG, CONFIG_SUP, item, nil, mousePos, i ~= 1)
      local effectPosition = variant:getPosition()
      effectPosition = Position(effectPosition.x + 3, effectPosition.y + 3, effectPosition.z)
      effectPosition:sendMagicEffect(536)
    --  local effectFrom = variant:getPosition()
    --  local effectTo = Position(effectFrom.x - 3, effectFrom.y - 7, effectFrom.z)
    --  effectTo:sendLineEffect(effectFrom, 598)
    --  player:getPosition():sendLineEffect(effectTo, 598)
    --  executeColdSnap(player, combat, CONFIG_SUP, item)
      if i == hits then
        spellCleanAfterCast(player, combat)
      end
    end, 750 * i - 750)
  end
  spellSetupCooldown(player, CONFIG, CONFIG_SUP, force)
  return true
end

SPELLS[CONFIG.spellName] = {
  cast = function(player, item, force, mousePos)
    onCastSpell(player, item, false, force, mousePos)
  end,

  getInfo = function(player, item)
    return onCastSpell(player, item, true)
  end,

  getConfig = function()
    return CONFIG
  end,
  
  spellId = CONFIG.spellId,
}