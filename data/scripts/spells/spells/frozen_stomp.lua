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
  spellName = GLOBAL_SPELL_COOLDOWNS[61].name,
  level = 1,
  magLevel = 0,
  precentCost = true,
  manaCost = GLOBAL_SPELL_COOLDOWNS[61].manaCost,
  spellId = 61,
  range = GLOBAL_SPELL_COOLDOWNS[61].range,
  aggressive = true,
  selfTarget = true,
  cooldown = GLOBAL_SPELL_COOLDOWNS[61].cooldown,
  type = COMBAT_ICEDAMAGE,

  combat_config = {
  --  effect = 177
  --  effect = 401,
  --  center = true,
  --  bottom = true,
  --  offsetX = 3,
  --  offsetY = 3
  },

  defualtArea = {
    {1, 1, 1},
    {1, 3, 1},
    {1, 1, 1}
  },

  supports = {
    ["dot"] = false,
    ["aoe"] = true,
    ["close"] = true,
    ["resize"] = true,
  },
}

local function onCastSpell(player, item, getInfoOnly, force, mousePos)
  if not spellCheckForCast(player, item, CONFIG.spellId, getInfoOnly, force) then return end
  local CONFIG_SUP = item:applySupportSpells(CONFIG, player:getId())
  if colleftInfo[player:getId()].attributesItems[135] then -- Icy Dragon Blade
    CONFIG_SUP.resizeTo = 4
  end
  local area, tempArea = spellSetupArea(CONFIG, CONFIG_SUP, resizeTo)

  if getInfoOnly then
    return spellGetInfoToSend(player, CONFIG, CONFIG_SUP, item, tempArea)
  end
  if not checkCastableSpell(player, CONFIG, CONFIG_SUP, force) then return end

  local dmg = spellGlobalFormule(player, CONFIG, CONFIG_SUP, item)
  local combat = spellSetupCombat(player, CONFIG, CONFIG_SUP, area, dmg, force)
  local variant = spellSetupVariant(player, CONFIG, CONFIG_SUP, mousePos)
    local extraFunc = function(player, target)
      target:setProgressBar(500, false)
      target:addBuff(STUN, 500)
  
      local stun = Condition(CONDITION_STUN)
      stun:setParameter(CONDITION_PARAM_TICKS, 500)
      target:addCondition(stun)
    end
  spellSetupTargetCombat(player, combat, CONFIG, CONFIG_SUP, item, extraFunc)
  if spellExecuteCombat(player, combat, CONFIG, CONFIG_SUP, item, variant, mousePos) then
    spellSetupCooldown(player, CONFIG, CONFIG_SUP, force)
    local playerPos = player:getPosition()
    local effect = 518
     position = Position(playerPos.x + 1, playerPos.y + 1, playerPos.z)
     if CONFIG_SUP.resizeTo then
      if CONFIG_SUP.resizeTo >= 1 and CONFIG_SUP.resizeTo <= 2 then
        effect = 512
        position = Position(playerPos.x + 2, playerPos.y + 2, playerPos.z)
      elseif CONFIG_SUP.resizeTo >= 3 then
        effect = 215
        position = Position(playerPos.x + 3, playerPos.y + 3, playerPos.z)
      end
    end
    position:sendMagicEffect(effect, 1)
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