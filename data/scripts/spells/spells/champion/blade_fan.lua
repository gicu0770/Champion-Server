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
  spellName = GLOBAL_SPELL_COOLDOWNS[11].name,
  level = 1,
  magLevel = 0,
  manaCost = GLOBAL_SPELL_COOLDOWNS[11].manaCost,
  spellId = 11,
  range = GLOBAL_SPELL_COOLDOWNS[11].range or 0,
  aggressive = true,
  selfTarget = true,
  cooldown = GLOBAL_SPELL_COOLDOWNS[11].cooldown,
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
    ["aoe"] = true,
    ["resize"] = true,
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
  
  local dmg = spellGlobalFormule(player, CONFIG, CONFIG_SUP, item)
  local combat = spellSetupCombat(player, CONFIG, CONFIG_SUP, area, dmg, force)
  local variant = spellSetupVariant(player, CONFIG, CONFIG_SUP, mousePos)
  
  local extraFunc = function(caster, target)
    if not target or target:isRemoved() then return end
    if target:isMonster() or (target:isPlayer() and not caster:hasSecureMode()) then
      if target.addBuff then
        target:addBuff(SILENCE, 1500)
      end
    end
  end

  spellSetupTargetCombat(player, combat, CONFIG, CONFIG_SUP, item, extraFunc)
  
  if spellExecuteCombat(player, combat, CONFIG, CONFIG_SUP, item, variant, mousePos) then
    
    -- Custom distance effect: Shurikens flying from player to all area tiles
    local playerPos = player:getPosition()
    local activeArea = tempArea or CONFIG.defualtArea
    if activeArea then
      local cx, cy = 0, 0
      for y, row in ipairs(activeArea) do
        for x, val in ipairs(row) do
          if val == 3 or val == 2 then
            cx, cy = x, y
            break
          end
        end
        if cx > 0 then break end
      end
      
      if cx > 0 and cy > 0 then
        for y, row in ipairs(activeArea) do
          for x, val in ipairs(row) do
            if val == 1 then
              local destPos = Position(playerPos.x + (x - cx), playerPos.y + (y - cy), playerPos.z)
              playerPos:sendDistanceEffect(destPos, 7) -- 7 = CONST_ANI_SHURIKEN
            end
          end
        end
      end
    end

    spellCleanAfterCast(player, combat)
    spellSetupCooldown(player, CONFIG, CONFIG_SUP, force)
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
