local CONFIG = {
  spellName = "Essence Drain",
  level = 1,
  magLevel = 0,
  manaCost = GLOBAL_SPELL_COOLDOWNS[73].manaCost,
  spellId = 73,
  range = GLOBAL_SPELL_COOLDOWNS[73].range,
  aggressive = true,
  forwardCast = true,
  cooldown = GLOBAL_SPELL_COOLDOWNS[73].cooldown,
  type = COMBAT_DEATHDAMAGE,
  -- sameTarget = true,

  timeBeetwean = 166,
  bounces = {
    max = GLOBAL_SPELL_COOLDOWNS[73].bon,
    chance = 100,
    -- sameTarget = true,
  },

  distanceEffect = 219,

  combat_config = {
    effect = 1,
  },

  defualtArea = { { 3 } },
  supports = {
    ["resize"] = false,
    ["bounce"] = true,
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
  if not variant then 
    return 
  end
  spellSetupTargetCombat(player, combat, CONFIG, CONFIG_SUP, item)
  spellStartChaining(player, combat, CONFIG, CONFIG_SUP, item, force)
  local tile = Tile(variant:getPosition())
  local target
  if tile then
    target = tile:getTopCreature()
  end
  if not target then
    target = player
  end
  if colleftInfo[player:getId()].attributesItems[286] then
    if spellExecuteCombat(player, combat, CONFIG, CONFIG_SUP, item, variant) then
      local extraTargets = getClosestTargets(player, target, player:getPosition(), CONFIG_SUP.range, US_ENCHANTMENTS[286].subvalue, true)
      for i = 1, #extraTargets do
        spellExecuteCombat(player, combat, CONFIG, CONFIG_SUP, item, Variant(extraTargets[i]), nil, true)
        player:getPosition():sendDistanceEffect(Variant(extraTargets[i]):getPosition(), 219)
      end
      spellSetupCooldown(player, CONFIG, CONFIG_SUP, force)
      spellCleanAfterCast(player, combat)
    end
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