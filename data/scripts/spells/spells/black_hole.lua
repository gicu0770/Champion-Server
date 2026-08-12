local resizeTo = {
  [1] = {
    {0, 0, 1, 0, 0},
    {0, 1, 1, 1, 0},
    {1, 1, 3, 1, 1},
    {0, 1, 1, 1, 0},
    {0, 0, 1, 0, 0}
  },

  [2] = {
    {0, 1, 1, 1, 0},
    {1, 1, 1, 1, 1},
    {1, 1, 3, 1, 1},
    {1, 1, 1, 1, 1},
    {0, 1, 1, 1, 0}
  },

  [3] = {
    {0, 0, 1, 1, 1, 0, 0},
    {0, 1, 1, 1, 1, 1, 0},
    {1, 1, 1, 1, 1, 1, 1},
    {1, 1, 1, 3, 1, 1, 1},
    {1, 1, 1, 1, 1, 1, 1},
    {0, 1, 1, 1, 1, 1, 0},
    {0, 0, 1, 1, 1, 0, 0}
  },

  [4] = {
    {0, 1, 1, 1, 1, 1, 0},
    {1, 1, 1, 1, 1, 1, 1},
    {1, 1, 1, 1, 1, 1, 1},
    {1, 1, 1, 3, 1, 1, 1},
    {1, 1, 1, 1, 1, 1, 1},
    {1, 1, 1, 1, 1, 1, 1},
    {0, 1, 1, 1, 1, 1, 0}
  },
}

local CONFIG = {
  spellName = GLOBAL_SPELL_COOLDOWNS[46].name,
  level = 1,
  magLevel = 0,
  precentCost = true,
  manaCost = GLOBAL_SPELL_COOLDOWNS[46].manaCost,
  spellId = 46,
  range = GLOBAL_SPELL_COOLDOWNS[46].range,
  aggressive = true,
  forwardCast = true,
  cooldown = GLOBAL_SPELL_COOLDOWNS[46].cooldown,
  type = COMBAT_DEATHDAMAGE,
  dmgInfo = "over 2.5s",
  combat_config = {
    effect = 625,
    bottom = false,
    center = true,
    offsetX = 3,
    offsetY = 3
  },



  defualtArea = {
    { 0, 1, 1, 1, 0 },
    { 1, 1, 1, 1, 1 },
    { 1, 1, 3, 1, 1 },
    { 1, 1, 1, 1, 1 },
    { 0, 1, 1, 1, 0 },
  },

  supports = {
    ["dot"] = true,
    ["aoe"] = true,
    ["affliction"] = true,
  },
}

local function onCastSpell(player, item, getInfoOnly, force, mousePos)
  if not spellCheckForCast(player, item, CONFIG.spellId, getInfoOnly, force) then return end
  local CONFIG_SUP = item:applySupportSpells(CONFIG, player:getId())
  local area, tempArea = spellSetupArea(CONFIG, CONFIG_SUP, resizeTo)

  if getInfoOnly then
    return spellGetInfoToSend(player, CONFIG, CONFIG_SUP, item, tempArea)
  end
  if not checkCastableSpell(player, CONFIG, CONFIG_SUP, force) then return end
  local dotDuration = 2500
  local dmgTick = 5
  if colleftInfo[player:getId()].attributesItems[142] then
    dotDuration = 1000
    dmgTick = 3
  end
  local dmg = {0, 0} -- spellGlobalFormule(player, CONFIG, CONFIG_SUP, item)
  local dotDmg = spellGlobalFormule(player, CONFIG, CONFIG_SUP, item, true)
  local combat = spellSetupCombat(player, CONFIG, CONFIG_SUP, area, dmg, force)
  local extraFunc = function(player, target)
    if not player then return end
    target:startDOT(player, BLACK_HOLE, dotDmg[1] / dmgTick, false, dotDuration)
    if math.random(100) <= 25 then -- 25% chance to poison
      target:startDOT(player, HARVEST_DEBUFF, 0, false, 5000)
    end
  end
  spellSetupTargetCombat(player, combat, CONFIG, CONFIG_SUP, item, extraFunc)


  local variant = spellSetupVariant(player, CONFIG, CONFIG_SUP, mousePos)
  if not variant then return end

    local posTarget = player:getTarget() and player:getTarget():getPosition() or mousePos
    if not posTarget then
      posTarget = player:getPosition()
    end

    -- posTarget:sendMagicEffect(422)
    spellSetupCooldown(player, CONFIG, CONFIG_SUP, force)
    local pid = player:getId()
    local playerPos = variant:getPosition()
    local position = Position(playerPos.x + 3, playerPos.y + 3, playerPos.z)
    position:sendMagicEffect(625, 1)
    spellExecuteCombat(player, combat, CONFIG, CONFIG_SUP, item, variant, mousePos, i ~= 1)
    spellCleanAfterCast(player, combat)

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