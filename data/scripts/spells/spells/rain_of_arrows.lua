local resizeTo = {
  [1] = {
    {0, 0, 0, 1, 0, 0, 0},
    {0, 0, 1, 1, 1, 0, 0},
    {0, 1, 1, 1, 1, 1, 0},
    {1, 1, 1, 3, 1, 1, 1},
    {0, 1, 1, 1, 1, 1, 0},
    {0, 0, 1, 1, 1, 0, 0},
    {0, 0, 0, 1, 0, 0, 0}
  },

  [2] = {
    {0, 0, 1, 1, 1, 0, 0},
    {0, 1, 1, 1, 1, 1, 0},
    {1, 1, 1, 1, 1, 1, 1},
    {1, 1, 1, 3, 1, 1, 1},
    {1, 1, 1, 1, 1, 1, 1},
    {0, 1, 1, 1, 1, 1, 0},
    {0, 0, 1, 1, 1, 0, 0}
  },

  [3] = {
    {0, 1, 1, 1, 1, 1, 0},
    {1, 1, 1, 1, 1, 1, 1},
    {1, 1, 1, 1, 1, 1, 1},
    {1, 1, 1, 3, 1, 1, 1},
    {1, 1, 1, 1, 1, 1, 1},
    {1, 1, 1, 1, 1, 1, 1},
    {0, 1, 1, 1, 1, 1, 0}
  },
  [4] = {
    {0, 0, 0, 1, 1, 1, 0, 0, 0},
    {0, 0, 1, 1, 1, 1, 1, 0, 0},
    {0, 1, 1, 1, 1, 1, 1, 1, 0},
    {1, 1, 1, 1, 1, 1, 1, 1, 1},
    {1, 1, 1, 1, 3, 1, 1, 1, 1},
    {1, 1, 1, 1, 1, 1, 1, 1, 1},
    {0, 1, 1, 1, 1, 1, 1, 1, 0},
    {0, 0, 1, 1, 1, 1, 1, 0, 0},
    {0, 0, 0, 1, 1, 1, 0, 0, 0},
  },
}
local CONFIG = {
  spellName = "Rain Of Arrows",
  level = 1,
  magLevel = 0,
  precentCost = true,
  manaCost = GLOBAL_SPELL_COOLDOWNS[34].manaCost,
  spellId = 34,
  range = GLOBAL_SPELL_COOLDOWNS[34].range,
  aggressive = true,
  forwardCast = true,
  cooldown = GLOBAL_SPELL_COOLDOWNS[34].cooldown,
--  dmgInfo = "x5",
  type = COMBAT_PHYSICALDAMAGE,
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

local function spellCallbackStorm2(cid, position, count, effect)
  local origin = Position(position.x - 5, position.y - 5, position.z)
  local creature = Creature(cid)
  if creature then
      if math.random(1, 3) == 1 then
          position:sendMagicEffect(effect)
        --  origin:sendDistanceEffect(position, 127)
      end
      if count < 2 then
          count = count + 1
          addEvent(spellCallbackStorm2, 200, cid, position, count)
      end
  end
end

local function onCastSpell(player, item, getInfoOnly, force, mousePos)
  if not spellCheckForCast(player, item, CONFIG.spellId, getInfoOnly, force) then return end
  local CONFIG_SUP = item:applySupportSpells(CONFIG, player:getId())
  local effect = 490
  local damageBoost = 1.0
  if colleftInfo[player:getId()].attributesItems[282] then
    CONFIG_SUP.resizeTo = 4
    effect = 624
    damageBoost = 1.25
  end
  local area, tempArea = spellSetupArea(CONFIG, CONFIG_SUP, resizeTo)

  if getInfoOnly then
    return spellGetInfoToSend(player, CONFIG, CONFIG_SUP, item, tempArea)
  end
  if not checkCastableSpell(player, CONFIG, CONFIG_SUP, force) then return end
  local variant = spellSetupVariant(player, CONFIG, CONFIG_SUP, mousePos)
  if not variant then return end

  local dmg = spellGlobalFormule(player, CONFIG, CONFIG_SUP, item)
  local combat = spellSetupCombat(player, CONFIG, CONFIG_SUP, area, {dmg[1]*damageBoost,dmg[2]*damageBoost}, force)
  spellSetupTargetCombat(player, combat, CONFIG, CONFIG_SUP, item)
  function onTargetTile(creature, position)
    spellCallbackStorm2(creature:getId(), position, 0, effect)
  end
  spellSetupTragetTile(player, combat, CONFIG, CONFIG_SUP, item, onTargetTile)

  local pid = player:getId()
  --[[
  for i = 1, 5 do
    addEvent(function()
      local player = Player(pid)
      if not player or player:isRemoved() then return end
  --    spellExecuteCombat(player, combat, CONFIG, CONFIG_SUP, item, variant, mousePos, i ~= 1)
      if i == 5 then
        spellCleanAfterCast(player, combat)
      end
    end, 333 * i - 333)
  end
  --]]
  spellExecuteCombat(player, combat, CONFIG, CONFIG_SUP, item, variant, mousePos)
  spellCleanAfterCast(player, combat)
  spellSetupCooldown(player, CONFIG, CONFIG_SUP, force)
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