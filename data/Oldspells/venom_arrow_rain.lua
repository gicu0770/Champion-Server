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
  spellName = GLOBAL_SPELL_COOLDOWNS[91].name,
  level = 1,
  magLevel = 0,
  precentCost = true,
  manaCost = GLOBAL_SPELL_COOLDOWNS[91].manaCost,
  spellId = 91,
  range = GLOBAL_SPELL_COOLDOWNS[91].range,
  aggressive = true,
  forwardCast = true,
  cooldown = GLOBAL_SPELL_COOLDOWNS[91].cooldown,
  dmgInfo = "over 2.5s",
  type = COMBAT_EARTHDAMAGE,
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
    ["dot"] = true,
    ["aoe"] = true,
    ["affliction"] = true,
  },
}

local function spellCallbackStorm2(cid, position, count)
  local origin = Position(position.x - 5, position.y - 5, position.z)
  local creature = Creature(cid)
  if creature then
      if math.random(1, 20) == 1 then
          position:sendMagicEffect(400)
        --  origin:sendDistanceEffect(position, 127)
      end
      if count < 6 then
          count = count + 1
          addEvent(spellCallbackStorm2, 100, cid, position, count)
      end
  end
end

local function onCastSpell(player, item, getInfoOnly, force, mousePos)
  if not spellCheckForCast(player, item, CONFIG.spellId, getInfoOnly, force) then return end
  local CONFIG_SUP = item:applySupportSpells(CONFIG, player:getId())
  if colleftInfo[player:getId()].attributesItems[284] then
    CONFIG_SUP.resizeTo = 4
  end
  local area, tempArea = spellSetupArea(CONFIG, CONFIG_SUP, resizeTo)

  if getInfoOnly then
    return spellGetInfoToSend(player, CONFIG, CONFIG_SUP, item, tempArea)
  end
  if not checkCastableSpell(player, CONFIG, CONFIG_SUP, force) then return end
  local variant = spellSetupVariant(player, CONFIG, CONFIG_SUP, mousePos)
  if not variant then return end

  local dmg = {0, 0}
  local dotDmg = spellGlobalFormule(player, CONFIG, CONFIG_SUP, item, true)
  local combat = spellSetupCombat(player, CONFIG, CONFIG_SUP, area, dmg, force)
  local extraFunc = function(player, target)
    target:startDOT(player, VENOM_ARROW_RAIN, dotDmg[1] / 5, false, 2500, 21)
    if math.random(100) <= 20 then -- 25% chance to poison
      target:startDOT(player, POISON_ITEM, 0, false, 5000)
    end
  end
  spellSetupTargetCombat(player, combat, CONFIG, CONFIG_SUP, item, extraFunc)
  function onTargetTile(creature, position)
    spellCallbackStorm2(creature:getId(), position, 0)
  end
  spellSetupTragetTile(player, combat, CONFIG, CONFIG_SUP, item, onTargetTile)

  local pid = player:getId()
  spellExecuteCombat(player, combat, CONFIG, CONFIG_SUP, item, variant, mousePos)
  for i = 1, 5 do
    addEvent(function()
      local player = Player(pid)
      if not player or player:isRemoved() then return end
      
      if i == 5 then
        spellCleanAfterCast(player, combat)
      end
    end, 333 * i - 333)
  end
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