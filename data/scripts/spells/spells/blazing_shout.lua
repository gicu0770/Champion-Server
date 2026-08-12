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
    {0, 0, 0, 1, 0, 0, 0},
    {0, 1, 1, 1, 1, 1, 0},
    {0, 1, 1, 1, 1, 1, 0},
    {1, 1, 1, 3, 1, 1, 1},
    {0, 1, 1, 1, 1, 1, 0},
    {0, 1, 1, 1, 1, 1, 0},
    {0, 0, 0, 1, 0, 0, 0}
  },
  [4] = {
    {1, 0, 1, 1, 1, 0, 1},
    {0, 1, 1, 1, 1, 1, 0},
    {1, 1, 1, 1, 1, 1, 1},
    {1, 1, 1, 3, 1, 1, 1},
    {1, 1, 1, 1, 1, 1, 1},
    {0, 1, 1, 1, 1, 1, 0},
    {1, 0, 1, 1, 1, 0, 1}
  },
}

local CONFIG = {
  spellName = GLOBAL_SPELL_COOLDOWNS[59].name,
  level = 1,
  magLevel = 0,
  precentCost = true,
  manaCost = GLOBAL_SPELL_COOLDOWNS[59].manaCost,
  spellId = 59,
  range = GLOBAL_SPELL_COOLDOWNS[59].range,
  aggressive = true,
  selfTarget = true,
  cooldown = GLOBAL_SPELL_COOLDOWNS[59].cooldown,
  type = COMBAT_FIREDAMAGE,

  combat_config = {
  --  effect = 487,
  --  center = true,
  --  offsetX = 2,
  --  offsetY = 2
  },

  defualtArea = {
    { 0, 1, 1, 1, 0  },
    { 1, 1, 1, 1, 1  },
    { 1, 1, 3, 1, 1  },
    { 1, 1, 1, 1, 1  },
    { 0, 1, 1, 1, 0  },
  },
  newArea ={
    {0, 0, 1, 1, 1, 0, 0},
    {0, 1, 1, 1, 1, 1, 0},
    {1, 1, 1, 1, 1, 1, 1},
    {1, 1, 1, 3, 1, 1, 1},
    {1, 1, 1, 1, 1, 1, 1},
    {0, 1, 1, 1, 1, 1, 0},
    {0, 0, 1, 1, 1, 0, 0}
  },
  --[[
  convert = {
    0.90,
    COMBAT_FIREDAMAGE,
  },
  --]]

  supports = {
    ["dot"] = false,
    ["aoe"] = true,
    ["close"] = true,
  },
}

local function onCastSpell(player, item, getInfoOnly, force, mousePos)
  if not spellCheckForCast(player, item, CONFIG.spellId, getInfoOnly, force) then return end
  local CONFIG_SUP = item:applySupportSpells(CONFIG, player:getId())
  local area
  local tempArea

  if colleftInfo[player:getId()].attributesItems[148] then
    tempArea = CONFIG.newArea
    area = createCombatArea(CONFIG.newArea)
  else
    area, tempArea = spellSetupArea(CONFIG, CONFIG_SUP, resizeTo)
  end
  if getInfoOnly then
    return spellGetInfoToSend(player, CONFIG, CONFIG_SUP, item, tempArea, dot)
  end
  if not checkCastableSpell(player, CONFIG, CONFIG_SUP, force) then return end

  local dmg = spellGlobalFormule(player, CONFIG, CONFIG_SUP, item)
  local combat = spellSetupCombat(player, CONFIG, CONFIG_SUP, area, dmg, force)
  local variant = spellSetupVariant(player, CONFIG, CONFIG_SUP, mousePos)
  if not variant then 
    return 
  end
  local extraFunc = function(player, target)
    target:addBuff(BLAZING_SHOUT)
    if math.random(1,100) <= 20 then
      target:startDOT(player, IGNITE_ITEM, 0, false, 5000, 16)
    end
  end
  spellSetupTargetCombat(player, combat, CONFIG, CONFIG_SUP, item, extraFunc)

  if spellExecuteCombat(player, combat, CONFIG, CONFIG_SUP, item) then
    local playerPos = player:getPosition()
    local effectShout = 487
    local bottom = 0
    local position = Position(playerPos.x + 2, playerPos.y + 2, playerPos.z)
    if colleftInfo[player:getId()].attributesItems[148] then
      effectShout = 486
      position = Position(playerPos.x + 3, playerPos.y + 3, playerPos.z)
      bottom = 1
    end
    position:sendMagicEffect(effectShout, bottom)
    spellSetupCooldown(player, CONFIG, CONFIG_SUP, force)
    spellCleanAfterCast(player, combat)
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