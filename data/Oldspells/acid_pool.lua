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
  spellName = GLOBAL_SPELL_COOLDOWNS[33].name,
  level = 1,
  magLevel = 0,
  precentCost = true,
  manaCost = GLOBAL_SPELL_COOLDOWNS[33].manaCost,
  cooldown = GLOBAL_SPELL_COOLDOWNS[33].cooldown,
  range = GLOBAL_SPELL_COOLDOWNS[33].range,
  spellId = 33,
  aggressive = true,
  forwardCast = true,
  type = COMBAT_EARTHDAMAGE,
  dmgInfo = "over 2.5s",

  combat_config = {
  --  effect = 393, -- 515
  --  distanceEffect = 15,
    bottom = true,
  },

  defualtArea = {
    {1, 1, 1},
    {1, 3, 1},
    {1, 1, 1}
  },

  supports = {
    ["dot"] = true,
    ["aoe"] = true,
    ["resize"] = true,
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
  if colleftInfo[player:getId()].attributesItems[138] then
    dotDuration = 3500
  end
  local dmg = {0, 0} -- spellGlobalFormule(player, CONFIG, CONFIG_SUP, item)
  local dotDmg = spellGlobalFormule(player, CONFIG, CONFIG_SUP, item, true)
  local combat = spellSetupCombat(player, CONFIG, CONFIG_SUP, area, dmg, force)
  local extraFunc = function(player, target)
    if not player then return end
    target:startDOT(player, ACID_POOL, dotDmg[1] / 5, false, dotDuration)
    if math.random(100) <= 20 then -- 25% chance to poison
      target:startDOT(player, POISON_ITEM, 0, false, 5000)
    end
  end
  spellSetupTargetCombat(player, combat, CONFIG, CONFIG_SUP, item, extraFunc)
  local variant = spellSetupVariant(player, CONFIG, CONFIG_SUP, mousePos)
  if not variant then return end
    local playerPos = variant:getPosition()       --player:getPosition()
    local effect = 516
    position = Position(playerPos.x + 1, playerPos.y + 1, playerPos.z)
    if CONFIG_SUP.resizeTo then
      if CONFIG_SUP.resizeTo >= 1 and CONFIG_SUP.resizeTo <= 2 then
        effect = 515
        position = Position(playerPos.x + 2, playerPos.y + 2, playerPos.z)
      elseif CONFIG_SUP.resizeTo >= 3 then
        effect = 514
        position = Position(playerPos.x + 3, playerPos.y + 3, playerPos.z)
      end
    end
    position:sendMagicEffect(effect, 0)
    if spellExecuteCombat(player, combat, CONFIG, CONFIG_SUP, item) then
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