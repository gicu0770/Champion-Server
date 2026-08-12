local resizeTo = {
  [1] = {
    {0, 1, 1, 1, 0},
    {0, 1, 1, 1, 0},
    {0, 1, 1, 1, 0},
    {0, 1, 1, 1, 0},
    {0, 1, 1, 1, 0},
    {0, 1, 1, 1, 0},
    {0, 0, 1, 0, 0},
    {0, 0, 3, 0, 0}
  },
  [2] = {
    {0, 1, 1, 1, 0},
    {0, 1, 1, 1, 0},
    {0, 1, 1, 1, 0},
    {1, 1, 1, 1, 1},
    {1, 1, 1, 1, 1},
    {0, 1, 1, 1, 0},
    {0, 1, 1, 1, 0},
    {0, 0, 3, 0, 0}
  },

  [3] = {
    {1, 1, 1, 1, 1},
    {1, 1, 1, 1, 1},
    {1, 1, 1, 1, 1},
    {1, 1, 1, 1, 1},
    {1, 1, 1, 1, 1},
    {0, 1, 1, 1, 0},
    {0, 1, 1, 1, 0},
    {0, 1, 3, 1, 0}
  },

  [4] = {
    {1, 1, 1, 1, 1},
    {1, 1, 1, 1, 1},
    {1, 1, 1, 1, 1},
    {1, 1, 1, 1, 1},
    {1, 1, 1, 1, 1},
    {1, 1, 1, 1, 1},
    {1, 1, 1, 1, 1},
    {0, 1, 1, 1, 0},
    {0, 1, 1, 1, 0},
    {0, 1, 3, 1, 0}
  },
}

local CONFIG = {
  spellName = GLOBAL_SPELL_COOLDOWNS[42].name,
  level = 1,
  magLevel = 0,
  precentCost = true,
  manaCost = GLOBAL_SPELL_COOLDOWNS[42].manaCost,
  spellId = 42,
  range = GLOBAL_SPELL_COOLDOWNS[42].range,
  aggressive = true,
  directional = true,
  cooldown = GLOBAL_SPELL_COOLDOWNS[42].cooldown,
  type = COMBAT_DEATHDAMAGE,
  dmgInfo = "over 2.5s",

  combat_config = {
    effect = 0,
  --  distanceEffect = 1,
  },

  defualtArea = {
    {1, 1, 1, 1, 1, 1, 1},
    {0, 1, 1, 1, 1, 1, 0},
    {0, 0, 1, 1, 1, 0, 0},
    {0, 0, 1, 1, 1, 0, 0},
    {0, 0, 1, 1, 1, 0, 0},
    {0, 0, 1, 1, 1, 0, 0},
    {0, 0, 1, 3, 1, 0, 0},
  },


  supports = {
    ["dot"] = true,
    ["wave"] = true,
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
  -- EFEKT NA POSTACI W ZALEŻNOŚCI OD KIERUNKU
  local dirConfig = {
    [0] = {effect = 722, offsetX = 4, offsetY = 0}, -- góra
    [1] = {effect = 721, offsetX = 8, offsetY = 4}, -- prawo
    [2] = {effect = 723, offsetX = 4, offsetY = 8}, -- dół
    [3] = {effect = 724, offsetX = 0, offsetY = 4}  -- lewo
  }

  local pDir = player:getDirection()
  local configDir = dirConfig[pDir]

  if configDir then
    local pPos = player:getPosition()
    local effectPos = Position(pPos.x + configDir.offsetX, pPos.y + configDir.offsetY, pPos.z)
    effectPos:sendMagicEffect(configDir.effect)
  end

  local dmg = {0,0}
  local dotDmg = spellGlobalFormule(player, CONFIG, CONFIG_SUP, item, true)
  local combat = spellSetupCombat(player, CONFIG, CONFIG_SUP, area, dmg, force)
  local extraFunc = function(player, target)
    target:startDOT(player, CURSE_ITEM, dotDmg[1] / dmgTick, false, dotDuration, 18)
    if math.random(100) <= 25 then
      target:startDOT(player, HARVEST_DEBUFF, 0, false, 5000, 18)
    end
  end
  spellSetupTargetCombat(player, combat, CONFIG, CONFIG_SUP, item, extraFunc)

  spellSetupTragetTile(player, combat, CONFIG, CONFIG_SUP, item)

  local variant = spellSetupVariant(player, CONFIG, CONFIG_SUP, mousePos)
  if not variant then return end
  if spellExecuteCombat(player, combat, CONFIG, CONFIG_SUP, item, variant, mousePos) then
    spellSetupCooldown(player, CONFIG, CONFIG_SUP, force)
    spellCleanAfterCast(player, combat)
  end
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
