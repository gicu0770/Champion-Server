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
  spellName = GLOBAL_SPELL_COOLDOWNS[1].name,
  level = 1,
  magLevel = 0,
  manaCost = GLOBAL_SPELL_COOLDOWNS[1].manaCost,
  spellId = 1,
  range = GLOBAL_SPELL_COOLDOWNS[1].range,
  aggressive = true,
  cooldown = GLOBAL_SPELL_COOLDOWNS[1].cooldown,
  type = COMBAT_FIREDAMAGE,
  forwardCast = true,

  combat_config = {
  -- effect = 7,
  --  effect = 488,
    distanceEffect = 74,
  --  center = true,
  --  offsetX = 3,
  --  offsetY = 3
  },
  distanceEffect = 74,
  timeBeetwean = 500,
  bounces = {
    max = 3,
    chance = 100,
    -- sameTarget = true,
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
  }
}

local function onCastSpell(player, item, getInfoOnly, force, mousePos)
  if not spellCheckForCast(player, item, CONFIG.spellId, getInfoOnly, force) then return end
  local CONFIG_SUP = item:applySupportSpells(CONFIG, player:getId())
  local area, tempArea = spellSetupArea(CONFIG, CONFIG_SUP, resizeTo)
  if getInfoOnly then
    return spellGetInfoToSend(player, CONFIG, CONFIG_SUP, item, tempArea)
  end
  if not checkCastableSpell(player, CONFIG, CONFIG_SUP, force) then return end

  local dmg = spellGlobalFormule(player, CONFIG, CONFIG_SUP, item)
  local dotDmg = spellGlobalFormule(player, CONFIG, CONFIG_SUP, item, true, true)
  local combat = spellSetupCombat(player, CONFIG, CONFIG_SUP, area, dmg, force)

  local extraFunc = function(player, target)
    if math.random(1,100) <= 20 then
      target:startDOT(player, IGNITE_ITEM, 0, false, 5000, 16)
    end
  end

  spellSetupTargetCombat(player, combat, CONFIG, CONFIG_SUP, item, extraFunc)
  local variant = spellSetupVariant(player, CONFIG, CONFIG_SUP, mousePos)
  if not variant then return end
  if not colleftInfo[player:getId()].attributesItems[173] then
    if spellExecuteCombat(player, combat, CONFIG, CONFIG_SUP, item, nil, mousePos) then
      spellSetupCooldown(player, CONFIG, CONFIG_SUP, force)
      local playerPos = variant:getPosition()
      local effect = 181
      position = Position(playerPos.x + 1, playerPos.y + 1, playerPos.z)
      if CONFIG_SUP.resizeTo then
        if CONFIG_SUP.resizeTo >= 1 and CONFIG_SUP.resizeTo <= 2 then
          effect = 488
          position = Position(playerPos.x + 3, playerPos.y + 3, playerPos.z)
        elseif CONFIG_SUP.resizeTo >= 3 then
          effect = 460
          position = Position(playerPos.x + 3, playerPos.y + 3, playerPos.z)
        end
      end
      position:sendMagicEffect(effect, 0)
      spellCleanAfterCast(player, combat)
    end
  else
      spellSetupCooldown(player, CONFIG, CONFIG_SUP, force)
      local playerPos = variant:getPosition()
      local effect = 181
      local moveEffect = 1
      position = Position(playerPos.x + 1, playerPos.y + 1, playerPos.z)
      if CONFIG_SUP.resizeTo then
        if CONFIG_SUP.resizeTo >= 1 and CONFIG_SUP.resizeTo <= 2 then
          effect = 488
          position = Position(playerPos.x + 3, playerPos.y + 3, playerPos.z)
          moveEffect = 3
        elseif CONFIG_SUP.resizeTo >= 3 then
          effect = 460
          position = Position(playerPos.x + 3, playerPos.y + 3, playerPos.z)
          moveEffect = 3
        end
      end
    --  position:sendMagicEffect(effect, 0)
      spellStartChaining(player, combat, CONFIG, CONFIG_SUP, item, force, nil, effect, moveEffect)
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