manaCost_support = {
  ["resize"] = {1.5, 0},
  ["multicast"] = {1.5, 0},
  ["eledmg"] = {1.35, 0.004},
  ["phydmg"] = {1.35, 0.004},
  ["dualdamage"] = {1.35, 0.004},
  ["lifeTap"] = {0, 0},
  ["cdr"] = {1.35, 0.004},
  ["cost"] = {0.85, -0.0025},
  ["dot"] = {1.35, 0.004},
  ["addFire"] = {1.20, 0.0015},
  ["addIce"] = {1.20, 0.0015},
  ["addPois"] = {1.20, 0.0015},
  ["addDeath"] = {1.20, 0.0015},
  ["addEne"] = {1.20, 0.0015},
  ["addHoly"] = {1.20, 0.0015},
  ["addPhys"] = {1.20, 0.0015},
  ["quality"] = {1.35, 0.004},
  ["critChance"] = {1.35, 0.004},
  ["critMulti"] = {1.35, 0.004},
  ["pinpoint"] = {1.35, 0.004},
  ["elePen"] = {1.35, 0.004},
  ["armorPen"] = {1.35, 0.004},
  ["dualpen"] = {1.35, 0.004},
  ["bloodth"] = {1.35, 0},
  ["splash"] = {1.35, 0.004},
  ["eleWeak"] = {1.35, 0.004},
  ["phyWeak"] = {1.35, 0.004},
  ["dualweakness"] = {1.35, 0.004},
  
  ["gamble"] = {1.35, 0.004},
  ["enchanced"] = {1.35, 0.004},
  ["ddsup"] = {1.35, 0.004},
  ["coc"] = {3.00, 0},
  ["cok"] = {3.00, 0},
  ["codt"] = {3.00, 0},
  ["copu"] = {3.00, 0},

  ["bounce"] = {1.35, 0.004},
  ["split"] = {1.35, 0.004},


  ["wave"] = {1.20, 0.0015},
  ["aoe"] = {1.20, 0.0015},
  ["close"] = {1.20, 0.0015},
  ["move"] = {1.20, 0.0015},
  ["single"] = {1.20, 0.0015},

  ["affliction"] = {1.5, 0},
  ["poisonChance"] = {1.05, 0.004},
  ["igniteChance"] = {1.05, 0.004},

  ["lifeDrain"] = {1.20, 0.004},
  ["energyDrain"] = {1.20, 0.004},
  ["manaDrain"] = {1.20, 0.004},


  ["vitality"] = {1.20, 0.004},
  ["clarity"] = {1.20, 0.004},
  ["barrier"] = {1.20, 0.004},
  ["momentum"] = {1.20, 0.004},

  ["physMastery"] = {1.20, 0.004},
  ["eleMastery"] = {1.20, 0.004},
  ["dualMastery"] = {1.20, 0.004},

  ["basicPen"] = {1.20, 0.004},
  ["counterPen"] = {1.20, 0.004},
  ["as"] = {1.20, 0.004},

  ["basicMastery"] = {1.20, 0.004},
  ["multistrike"] = {1.5, 0},
  ["basicDamage"] = {1.20, 0},
}

TOTALCOUNT_SUPPORTS = {
  ["vitality"] = 1,
  ["clarity"] = 1,
  ["barrier"] = 1,
  ["lifeDrain"] = 1,
  ["energyDrain"] = 1,
  ["manaDrain"] = 1,
  ["basicPen"] = 1,
  ["multistrike"] = 1,
  ["momentum"] = 1,
  ["eleWeak"] = 1,
  ["phyWeak"] = 1,
  ["dualweakness"] = 1,
  ["armorPen"] = 1,
  ["dualpen"] = 1,
  ["elePen"] = 1,
}

ONLY_WORKS_WITH_TAG = {
  ["basicDamage"] = {28},
  ["multistrike"] = {28},
}

local dmgRatio = 0.003

local masteryLevel = {
  [0] = 5,
  [1] = 7,
  [2] = 11,
  [3] = 18,
  [4] = 25
}
local base = {
  [0] = 1,
  [1] = 1,
  [2] = 2,
  [3] = 3,
  [4] = 4
}

local spellActions = {
  resize = function(data, rarity, config, level) 
      if rarity == 0 then
        rarity = 1
      end
       data.resizeTo = rarity
        for k, v in pairs(data.extraDmg) do
          data.extraDmg[k] = v + ((level * 0.003 + 0.2) / GLOBAL_SPELL_COOLDOWNS[config.spellId].hits)
        end
    end,
  multicast = function(data, rarity, config, level) data.multiCast = 1 end,
  multistrike = function(data, rarity, CONFIG, level)
    if GLOBAL_SPELL_COOLDOWNS[CONFIG.spellId].basic_aura then
      data.multistrike = 1
    end
  end,
  basicDamage = function(data, rarity, CONFIG, level)
    if GLOBAL_SPELL_COOLDOWNS[CONFIG.spellId].basic_aura then
      data.basicDamage = 20 + (level * 0.3)
    end
  end,
  dot = function(data, rarity, config, level)
    if config.supports["dot"] then
      for k, v in pairs(data.extraDmg) do
        data.extraDmg[k] = v + (level * 0.015 + 0.1)
      end
    end
  --  data.dotExtra = data.dotExtra + math.floor(level * 0.002 + 0.1)
  end,
  as = function(data, rarity, config, level)
    data.as = math.floor(level * 0.25 + 5)
  end,
  momentum = function(data, rarity, config, level)
    data.momentum = math.floor(level * 0.25 + 10)
  end,
  vitality = function(data, rarity, config, level)
    data.vitality = math.floor(level * 3 + 30)
  end,
  clarity = function(data, rarity, config, level)
    data.clarity = math.floor(level * 0.5 + 10)
  end,
  barrier = function(data, rarity, config, level)
    data.barrier = math.floor(level * 3 + 30)
  end,
  physMastery = function(data, rarity, CONFIG, level)
    if GLOBAL_SPELL_COOLDOWNS[CONFIG.spellId].element then
      if GLOBAL_SPELL_COOLDOWNS[CONFIG.spellId].element == 106 then
        data.level = data.level + math.floor(level * 0.2 + 10)
      end
    end
  end,
  basicMastery = function(data, rarity, CONFIG, level)
    if GLOBAL_SPELL_COOLDOWNS[CONFIG.spellId].basic_aura then
        data.level = data.level + math.floor(level * 0.2 + 10)
    end
  end,
  eleMastery = function(data, rarity, CONFIG, level)
    if GLOBAL_SPELL_COOLDOWNS[CONFIG.spellId].element then
      if GLOBAL_SPELL_COOLDOWNS[CONFIG.spellId].element >= 100 and GLOBAL_SPELL_COOLDOWNS[CONFIG.spellId].element <= 103 then
        data.level = data.level + math.floor(level * 0.2 + 10)
      end
    end
  end,
  dualMastery = function(data, rarity, CONFIG, level)
    if GLOBAL_SPELL_COOLDOWNS[CONFIG.spellId].element then
      if GLOBAL_SPELL_COOLDOWNS[CONFIG.spellId].element >= 104 and GLOBAL_SPELL_COOLDOWNS[CONFIG.spellId].element <= 105 then
        data.level = data.level + math.floor(level * 0.2 + 10)
      end
    end
  end,

  lifeDrain = function(data, rarity, config, level)
    table.insert(data.onCast,
      function(player)
        --local recovery = (player:getMaxHealth() * math.floor(level * 0.03 + 1)) / 100
        local recovery = math.floor(level * 2 + 25) + (player:getMaxHealth() * 0.01)
        player:addHealth(recovery)
      end
    )
  end,
  energyDrain = function(data, rarity, config, level)
    table.insert(data.onCast,
      function(player)
        -- local recovery = (player:getMaxEnergyShield() * math.floor(level * 0.03 + 1)) / 100
        local recovery = math.floor(level * 2 + 25) + (player:getMaxEnergyShield() * 0.01)
        player:addEnergyShield(recovery)
      end
    )
  end,
  manaDrain = function(data, rarity, config, level)
    table.insert(data.onCast,
      function(player)
        -- local recovery = (player:getMaxMana() * math.floor(level * 0.03 + 1)) / 100
        local recovery = math.floor(level * 2 + 25) + (player:getMaxMana() * 0.01)
        player:addMana(recovery)
      end
    )
  end,
  affliction = function(data, rarity, config, level)
    if config.supports["dot"] then
      data.affliction = true
    end
  --  data.dotExtra = data.dotExtra + math.floor(level * 0.002 + 0.1)
  end,
  poisonChance = function(data, rarity, config, level)
    table.insert(data.func,
      function(player, target)
        for i = 1, math.floor(level * 0.04 + 1) do
          target:startDOT(player, POISON_ITEM, 0, false, 5000)
        end
      end
    )
  end,
  igniteChance = function(data, rarity, config, level)
    table.insert(data.func,
      function(player, target)
        for i = 1, math.floor(level * 0.04 + 1) do
          target:startDOT(player, IGNITE_ITEM, 0, false, 5000)
        end
      end
    )
  end,
  aoe = function(data, rarity, CONFIG, level)
    if GLOBAL_SPELL_COOLDOWNS[CONFIG.spellId].aoe then
      for k, v in pairs(data.extraDmg) do
        data.extraDmg[k] = v + ((level * 0.0045 + 0.2) / GLOBAL_SPELL_COOLDOWNS[CONFIG.spellId].hits)
      end
    end
  end,
  wave = function(data, rarity, CONFIG, level)
    if GLOBAL_SPELL_COOLDOWNS[CONFIG.spellId].wave then
      for k, v in pairs(data.extraDmg) do
        data.extraDmg[k] = v + ((level * 0.008 + 0.2) / GLOBAL_SPELL_COOLDOWNS[CONFIG.spellId].hits)
      end
    end
  end,
  close = function(data, rarity, CONFIG, level)
    if GLOBAL_SPELL_COOLDOWNS[CONFIG.spellId].close then
      for k, v in pairs(data.extraDmg) do
        data.extraDmg[k] = v + ((level * 0.006 + 0.2) / GLOBAL_SPELL_COOLDOWNS[CONFIG.spellId].hits)
      end
    end
  end,
  move = function(data, rarity, CONFIG, level)
    if GLOBAL_SPELL_COOLDOWNS[CONFIG.spellId].move then
      for k, v in pairs(data.extraDmg) do
        data.extraDmg[k] = v + ((level * 0.008 + 0.2) / GLOBAL_SPELL_COOLDOWNS[CONFIG.spellId].hits)
      end
    end
  end,
  single = function(data, rarity, CONFIG, level)
    if GLOBAL_SPELL_COOLDOWNS[CONFIG.spellId].single then
      for k, v in pairs(data.extraDmg) do
        data.extraDmg[k] = v + ((level * 0.006 + 0.2) / GLOBAL_SPELL_COOLDOWNS[CONFIG.spellId].hits)
      end
    end
  end,
  eledmg = function(data, rarity, CONFIG, level)
    for k, v in pairs(data.extraDmg) do
      if k == COMBAT_FIREDAMAGE or k == COMBAT_ICEDAMAGE or k == COMBAT_ENERGYDAMAGE or k == COMBAT_EARTHDAMAGE then
        data.extraDmg[k] = v + ((level * 0.0045 + 0.2) / GLOBAL_SPELL_COOLDOWNS[CONFIG.spellId].hits)
      end
    end
  end,
  phydmg = function(data, rarity, CONFIG, level) -- brute
    for k, v in pairs(data.extraDmg) do
       if k == COMBAT_PHYSICALDAMAGE then
         data.extraDmg[k] = v + ((level * 0.0045 + 0.2) / GLOBAL_SPELL_COOLDOWNS[CONFIG.spellId].hits)
       end
     end
  end,
  dualdamage = function(data, rarity, CONFIG, level)
    for k, v in pairs(data.extraDmg) do
      if k == COMBAT_HOLYDAMAGE or k == COMBAT_DEATHDAMAGE then
        data.extraDmg[k] = v + ((level * 0.0045 + 0.2) / GLOBAL_SPELL_COOLDOWNS[CONFIG.spellId].hits)
      end
    end
  end,
  lifeTap = function(data) data.lifeTap = true end,
  cdr = function(data, rarity, config, level, cdRed)
    return cdRed + ((data.cooldown * (level * 0.15 + 5)) / 100)
  end,
  addFire = function(data, rarity, CONFIG, level)
    addedDamageSup(rarity, COMBAT_FIREDAMAGE, data, CONFIG, level)
  end,
  addIce = function(data, rarity, CONFIG, level)
    addedDamageSup(rarity, COMBAT_ICEDAMAGE, data, CONFIG, level)
  end,
  addPois = function(data, rarity, CONFIG, level)
    addedDamageSup(rarity, COMBAT_EARTHDAMAGE, data, CONFIG, level)
  end,
  addDeath = function(data, rarity, CONFIG, level)
    addedDamageSup(rarity, COMBAT_DEATHDAMAGE, data, CONFIG, level)
  end,
  addEne = function(data, rarity, CONFIG, level)
    addedDamageSup(rarity, COMBAT_ENERGYDAMAGE, data, CONFIG, level)
  end,
  addHoly = function(data, rarity, CONFIG, level)
    addedDamageSup(rarity, COMBAT_HOLYDAMAGE, data, CONFIG, level)
  end,
  addPhys = function(data, rarity, CONFIG, level)
    addedDamageSup(rarity, COMBAT_PHYSICALDAMAGE, data, CONFIG, level)
  end,
  quality = function(data, rarity, config, level) data.quality = data.quality + (level * 0.12 + 10) end,
  critChance = function(data, rarity, config, level) 
  data.critC = data.critC + (level * 0.1 + 5) end,
  critMulti = function(data, rarity, config, level) 
  data.critM = data.critM + (level * 0.3 + 10) end,
  pinpoint = function(data, rarity, config, level) 
  data.pin = data.pin + (level * 0.03 + 1) end,
  elePen = function(data, rarity, config, level)
    table.insert(data.func,
      function(player, target)
        target:addBuff(SUPPORT_ELEMENTAL_REDUCTION)
        target:setBuffStacks(SUPPORT_ELEMENTAL_REDUCTION, math.floor(level * 0.15 + 5))
      end
    )
  end,
  armorPen = function(data, rarity, config, level)
    table.insert(data.func,
      function(player, target)
        target:addBuff(SUPPORT_PHYSICAL_REDUCTION)
        target:setBuffStacks(SUPPORT_PHYSICAL_REDUCTION,  math.floor(level * 0.15 + 5))
      end
    )
  end,
  dualpen = function(data, rarity, config, level)
    table.insert(data.func,
      function(player, target)
        target:addBuff(SUPPORT_DUALITY_REDUCTION)
        target:setBuffStacks(SUPPORT_DUALITY_REDUCTION,  math.floor(level * 0.15 + 5))
      end
    )
  end,
  basicPen = function(data, rarity, CONFIG, level)
    if GLOBAL_SPELL_COOLDOWNS[CONFIG.spellId].basic then
      data.basicPen = math.floor(level * 0.15 + 5)
    end
  end,
  counterPen = function(data, rarity, CONFIG, level)
    if GLOBAL_SPELL_COOLDOWNS[CONFIG.spellId].counter then
      data.counterPen = math.floor(level * 0.35 + 5)
    end
  end,
  bloodth = function(data, rarity, CONFIG, level) data.bloodThrist = data.bloodThrist + 30 + (level * 0.2917)  end,
  splash = function(data, rarity, CONFIG, level)
    local addedDamage = level * 0.0015 + 0.05
    table.insert(data.func,
      function(player, target, damage)
        local dmg = math.ceil(damage * addedDamage)
        local origin = data.force and ORIGIN_AUTOCAST or ORIGIN_SPELL
        doAreaCombatHealth(player, CONFIG.type, target:getPosition(), area3x3, dmg, dmg, 0, origin, 0, 9999)
        Position(target:getPosition().x + 3, target:getPosition().y + 3, target:getPosition().z):sendMagicEffect(650)
      end
    )
  end,
  eleWeak = function(data, rarity, config, level)
    table.insert(data.func,
      function(player, target)
        target:addBuff(SUPPORT_ELEMENTAL_REDUCTION_ATTACK)
        target:setBuffStacks(SUPPORT_ELEMENTAL_REDUCTION_ATTACK, math.floor(level * 0.15 + 5))
      end
    )
  end,
  phyWeak = function(data, rarity, config, level)
    table.insert(data.func,
      function(player, target)
        target:addBuff(SUPPORT_PHYSICAL_REDUCTION_ATTACK)
        target:setBuffStacks(SUPPORT_PHYSICAL_REDUCTION_ATTACK, math.floor(level * 0.15 + 5))
      end
    )
  end,
  dualweakness = function(data, rarity, config, level)
    table.insert(data.func,
      function(player, target)
        target:addBuff(SUPPORT_DUALITY_REDUCTION_ATTACK)
        target:setBuffStacks(SUPPORT_DUALITY_REDUCTION_ATTACK, math.floor(level * 0.15 + 5))
      end
    )
  end,
  gamble = function(data, rarity, config, level)
    data.critM = data.critM + 80 + level * 0.5
    data.gamble = true
  end,
  enchanced = function(data, rarity, config, level)
    data.level = data.level + math.floor(level * 0.2 + 10)
  end,
  coc = function(data, rarity, config, level) 
    data.disableCast = true
    data.cast = 1
  end,
  cok = function(data, rarity, config, level) 
    data.disableCast = true
    data.cast = 2
  end,
  codt = function(data, rarity, config, level) 
    data.disableCast = true
    data.cast = 3
  end,
  copu = function(data, rarity, config, level) 
    data.disableCast = true
    data.cast = 4
  end,
  ddsup = function(data, rarity, config, level)
    data.doubleDamage = data.doubleDamage + level * 0.04 + 1
  end,
  cost = function(data, rarity, config, level)
    -- empty
  end,
  bounce = function(data, rarity, config, level)
    if data.bon then
      data.bon = data.bon + math.min(math.floor((level * 0.03 + 1)), 8)
    end
  end,
  split = function(data, rarity, config, level)
    if data.targets then
      data.targets = data.targets + math.min(math.floor((level * 0.03 + 1)), 8)
    end
    if data.projectile then
      data.projectile = data.projectile + math.min(math.floor((level * 0.03 + 1)), 8)
    end
  end,
}

function addedDamageSup(rarity, damageType, data, CONFIG, level)
  if CONFIG.type == damageType then
    data.extraDmg[damageType] = data.extraDmg[damageType] + ((level * 0.35 + 10) / 100)
  else
    table.insert(data.func,
      function(player, target, damage)
        local dmg = math.ceil(damage * ((level * 0.35 + 10) / 100))
        local origin = data.force and ORIGIN_AUTOCAST or ORIGIN_SPELL
        doTargetCombatHealth(player, target, damageType, dmg, dmg, 0, origin, 0, 0)
      end
    )
  end
end

SUPPORT_SLOTS = {
  [12] = {19,20,21,22},
  [13] = {23,24,25,26},
  [14] = {27,28,29,30},
  [15] = {31,32,33,34},
}

FROM_SUPPORT_TO_SPELL = {
  [19] = 12,
  [20] = 12,
  [21] = 12,
  [22] = 12,
  [23] = 13,
  [24] = 13,
  [25] = 13,
  [26] = 13,
  [27] = 14,
  [28] = 14,
  [29] = 14,
  [30] = 14,
  [31] = 15,
  [32] = 15,
  [33] = 15,
  [34] = 15,
}

function Item:applySupportSpells(CONFIG)
  if not self or not self:getParent() then
    return
  end

  local pla = nil
  local id = nil
  if self:getRealUID() ~= 0 and not self:getParent():isTile() then
    id = self:getParent():getId()
    if SPELL_CACHE[self:getRealUID()] then
      return SPELL_CACHE[self:getRealUID()]
    end

    pla = Player(id)
  end

  local supportCostReduction = 1.0
  local data = {
    id = CONFIG.spellId,
    multiCast = 0,
    realUID = self:getRealUID(),
    lifeTap = CONFIG.lifeTap or false,
    manaCost = CONFIG.manaCost or 0,
    cooldown = CONFIG.cooldown or 0,
    manaReservation = CONFIG.manaReservation,
    range = CONFIG.range,
    targets = CONFIG.targets,
    sup = {},
    hs = {},
    func = {},
    onCast = {},
    dotExtra = 0,
    quality = self:isQuality(),
    critC = CONFIG.critC or 0,
    critM = CONFIG.critM or 0,
    pin = 0,
    type = CONFIG.type,
    bloodThrist = 0,
    convert = CONFIG.convert,
    gamble = false,
    affliction = false,
    projectile = CONFIG.projectile,
    bon = tonumber(CONFIG.bounces and CONFIG.bounces.max) or 0,
    level = 0,
    cleanLevel = 0,
    doubleDamage = 0,
    extraDmg = {
      [COMBAT_PHYSICALDAMAGE] = 0.0,
      [COMBAT_FIREDAMAGE] = 0.0,
      [COMBAT_EARTHDAMAGE] = 0.0,
      [COMBAT_ENERGYDAMAGE] = 0.0,
      [COMBAT_HOLYDAMAGE] = 0.0,
      [COMBAT_ICEDAMAGE] = 0.0,
      [COMBAT_DEATHDAMAGE] = 0.0,
      [COMBAT_HEALING] = 0.0,
    },
  }
--[[
-- Calculate mana cost based on spell level (5 at level 1, scaling to 20 at level 50)
local baseManaCost = GLOBAL_SPELL_COOLDOWNS[CONFIG.spellId].startMana or 0
local maxManaCost = data.manaCost
local maxLevel = 50
local currentLevel = math.max(1, data.level + (self:getCustomAttribute("level") or 0))


if currentLevel >= maxLevel then
  data.manaCost = maxManaCost
else
  -- Linear scaling from baseManaCost to maxManaCost
  local scaleFactor = (currentLevel - 1) / (maxLevel - 1)
  data.manaCost = math.ceil(baseManaCost + (maxManaCost - baseManaCost) * scaleFactor)
end
--]]

  local costReduction = 1.0
  local cdRed = 0
  
  if pla then
    local slot = nil
    local rarity = self:getRarityId()
    for i = CONST_SLOT_SPELL1, CONST_SLOT_SPELL4 do 
      local compareItem = pla:getSlotItem(i)
      if compareItem and compareItem:getRealUID() == self:getRealUID() and slot ~= CONST_SLOT_FORGE then
        slot = i
        break
      end
    end

    local index = 1
    local currentSupports = {}
    local infoSlotsToSend = {}
    if slot then
      for i = SUPPORT_SLOTS[slot][1], SUPPORT_SLOTS[slot][4] do
        local item = pla:getSlotItem(i)
        if item and index > rarity then
          infoSlotsToSend[index] = 3
        elseif index > rarity then
          infoSlotsToSend[index] = 4
        elseif item then
          local spellGem = item:getSpellName()
          local rarity = item:getRarityId()
          local correctSupport = not CONFIG.supports[spellGem]
          if REVERSE_SUPPORT[spellGem] then
            correctSupport = (CONFIG.supports[spellGem] or false)
          end

          if CAST_SUPPORTS[spellGem] and data.cast then
            correctSupport = false
          end

          if ONLY_WORKS_WITH_TAG[spellGem] then
            local hasTag = false
            local tags = GLOBAL_SPELL_COOLDOWNS[CONFIG.spellId].tag or {}
            for x = 1, #tags do
              for _, requiredTag in pairs(ONLY_WORKS_WITH_TAG[spellGem]) do
                if tags[x] == requiredTag then
                  hasTag = true
                  break
                end
              end
              if hasTag then
                break
              end
            end
            if not hasTag then
              correctSupport = false
            end
          end

          local totalCountWrong = false
          if TOTALCOUNT_SUPPORTS[spellGem] then
            local count = 0
            for i = CONST_SLOT_SPELL1, CONST_SLOT_SPELL4 do
              if count >= TOTALCOUNT_SUPPORTS[spellGem] then
                correctSupport = false
                break
              end
              local checkSpell = pla:getSlotItem(i)
              if checkSpell and checkSpell ~= self then
                local cache = SPELL_CACHE[checkSpell:getRealUID()]
                if cache then
                  for name, _ in pairs(cache.hs) do
                    if name == spellGem then
                      count = count + 1
                    end
                  end
                end
              end
            end

            if count >= TOTALCOUNT_SUPPORTS[spellGem] then
              correctSupport = false
              totalCountWrong = true
            end
          end

          if correctSupport and spellActions[spellGem] and not currentSupports[spellGem] then
            infoSlotsToSend[index] = 1
            local baseLevel = item:getCustomAttribute("level") or 1
            local level = math.floor(baseLevel * (1 + (item:isQuality() / 100)))
            table.insert(data.sup, { item:getName(), rarity, spellGem, item:getType():getClientId(), baseLevel, item:isQuality()  })
            data.hs[spellGem] = rarity
            local manaCost = manaCost_support[spellGem][1] + (level or 1) * manaCost_support[spellGem][2]
            if spellGem == "cost" then
              supportCostReduction = manaCost
            else
              costReduction = costReduction + (manaCost - 1.0)
            end
            currentSupports[spellGem] = true
            if spellGem == "cdr" then
              cdRed = spellActions[spellGem](data, rarity, CONFIG, level, cdRed)
            else
              spellActions[spellGem](data, rarity, CONFIG, level)
            end
          else
            if totalCountWrong then
              infoSlotsToSend[index] = 5
            else
              infoSlotsToSend[index] = 2
            end
          end
        else
          infoSlotsToSend[index] = 0
        end
        index = index + 1
      end

      pla:sendExtendedOpcode(ExtendedOPCodes.CODE_CASTSPELL, json.encode({infoSlotsToSend, slot}))
    end
  end

  if data.manaReservation then
    data.manaReservation = data.manaReservation -- * costReduction
  end

  data.manaCost = math.ceil(data.manaCost * costReduction)
  local cdrIt = 0
  local subKlas = 0
  local SacredImpact = 0
  if pla then
    cdrIt = data.cooldown * pla:getCooldownReduction() / 100
    if colleftInfo[pla:getId()].attributesItems[152] then -- Subklas Sacred Impact
      SacredImpact = data.cooldown * US_ENCHANTMENTS[152].subvalue
    end
  end
  local cooldown = data.cooldown - cdRed - cdrIt - subKlas + SacredImpact
  local capCooldown = data.cooldown - (data.cooldown * 0.5) -- Cap at 50% max CDR
  if cooldown <= capCooldown then
    cooldown = capCooldown
  end
  --[[
    local msg = 
        "== COOLDOWN DEBUG ==\n" ..
        "Base cooldown: " .. data.cooldown .. "\n" ..
        "cdRed: -" .. cdRed .. "\n" ..
        "cdrIt: -" .. cdrIt .. "\n" ..
        "subKlas: -" .. subKlas .. "\n" ..
        "SacredImpact: +" .. SacredImpact .. "\n" ..
        "Final cooldown: " .. cooldown

    pla:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, msg)
    --]]
  local precentCdr = (cooldown * 100) / data.cooldown
  if precentCdr < 20 then
    precentCdr = 20
  end

  data.cooldown = data.cooldown * (precentCdr / 100)
  if data.affliction then
    if data.cooldown >= 1500 then
      data.cooldown = 1000
    end
  end

  if pla then
    if colleftInfo[pla:getId()].attributesItems[138] then -- unique Vine Staff
      if data.id == 33 or data.id == 77 then -- Venom Nova and Acid Bomb
        data.disableCast = true
        data.cast = 1
      end
    end

    if colleftInfo[pla:getId()].attributesItems[250] then -- unique Sparknado
      if data.id == 21 then
        data.projectile = data.projectile + US_ENCHANTMENTS[250].subvalue
      end
    end

    if colleftInfo[pla:getId()].attributesItems[125] then
      if data.id == 97 then
        data.targets = data.targets + US_ENCHANTMENTS[125].subvalue
      end
    end

    if colleftInfo[pla:getId()].attributesItems[143] then
      if data.id == 116 or data.id == 114 then
        data.projectile = US_ENCHANTMENTS[143].subvalue
      end
    end

    if colleftInfo[pla:getId()].attributesItems[148] then
      if data.id == 60 or data.id == 37 then
        if data.targets then
          data.targets = data.targets + US_ENCHANTMENTS[148].subvalue
        end
        if data.projectile then
          data.projectile = data.projectile + US_ENCHANTMENTS[148].subvalue
        end
      end
    end

    if colleftInfo[pla:getId()].attributesItems[193] then
      if data.id == 40 then
        data.targets = data.targets + US_ENCHANTMENTS[193].subvalue
      end
    end

    if colleftInfo[pla:getId()].attributesItems[282] then
      if data.id == 82 then
        data.projectile = data.projectile + US_ENCHANTMENTS[282].subvalue
      end
    end
    if colleftInfo[pla:getId()].attributesItems[285] then
      if data.id == 53 then
        data.targets = data.targets + US_ENCHANTMENTS[285].subvalue
      end
    end
    if colleftInfo[pla:getId()].attributesItems[156] then
      if data.id == 31 then
        data.projectile = 8
      end
    end
    if colleftInfo[pla:getId()].attributesItems[286] then
      if data.id == 73 then
        data.projectile = 5
      end
    end
    if colleftInfo[pla:getId()].attributesItems[178] then
      if data.id == 110 then
        data.projectile = 5
      end
    end

    if colleftInfo[pla:getId()].attributesItems[143] then -- unique Skull Crasher
      if data.id >= 114 or data.id <= 117 then -- Death Hit Spells
        data.critM = data.critM + US_ENCHANTMENTS[143].subvalue2
      end
    end
    if colleftInfo[pla:getId()].attributesItems[183] then -- unique Berserker Fury
      if data.id == 26 or data.id == 29 then -- Leap Slam and Amok
        data.cooldown = 300
      end
    end
    if colleftInfo[pla:getId()].attributesItems[135] then -- unique Icy Dragon Blink
      if data.id == 62 then -- Leap Slam and Amok
        data.cooldown = 300
      end
    end
    if colleftInfo[pla:getId()].attributesItems[178] then -- unique Thunderlord
      if data.id == 113 then -- Zeus Wrath
        data.cooldown = 1000
      end
    end
    if colleftInfo[pla:getId()].attributesItems[281] then -- unique Unstable Chooper
      if data.id == 78 then -- Groundbreaker
        data.cooldown = 1000
      end
    end
    if colleftInfo[pla:getId()].attributesItems[283] then -- unique Unstable Chooper
      if data.id == 108 then -- Deform
        data.cooldown = 1000
      end
    end
    if colleftInfo[pla:getId()].attributesItems[284] then -- unique Plague River
      if data.id == 91 then -- Venom Arrow Rain
        data.cooldown = 1000
      end
    end
    if colleftInfo[pla:getId()].attributesItems[286] then -- unique Undead Imbue
      if data.id == 76 then -- Oblivion
        data.cooldown = 1000
      end
    end
    if colleftInfo[pla:getId()].attributesItems[99] and not CONFIG.manaReservation then
      data.lifeTap = true
      data.manaCost = math.ceil(data.manaCost + (data.manaCost * colleftInfo[pla:getId()].attributesItems[99].value / 100))
    end

    local extraLevel = getSpellTotalLevel(pla, CONFIG.spellId, self)
    if extraLevel then
      data.level = data.level + extraLevel
    end

    data.cleanLevel = data.level
    data.level = data.level + (self:getCustomAttribute("level") or 0)
    local manaCostDecreased = 0
    local manaCostIncreased = 0
    if colleftInfo[pla:getId()].attributesItems[48] then -- Reduced Mana Cost Percent
      manaCostDecreased = manaCostDecreased + colleftInfo[pla:getId()].attributesItems[48].value
    end
    if colleftInfo[pla:getId()].attributesItems[127] then -- Subklas Overcharged Energy
        manaCostIncreased = manaCostIncreased + US_ENCHANTMENTS[127].subvalue
    end
    if manaCostIncreased > 0 then
      data.manaCost = data.manaCost + math.ceil(data.manaCost * manaCostIncreased / 100)
    end
    if manaCostDecreased > 0 then
      data.manaCost = data.manaCost - math.ceil(data.manaCost * manaCostDecreased / 100)
      if data.manaReservation then
        data.manaReservation = data.manaReservation - data.manaReservation * manaCostDecreased / 100
      end
    end
  end

  data.manaCost = math.ceil(data.manaCost * supportCostReduction)
  if data.manaCost < 0 then
    data.manaCost = 0
  end

  if data.manaReservation then
    if data.manaReservation < 0 then
      data.manaReservation = 0
    end
    data.manaReservation = data.manaReservation * supportCostReduction
  end


  if data.cooldown < 300 then
    data.cooldown = 300
  end

  if data.multiCast > 0 and data.projectile then
    data.projectile = math.ceil(data.projectile * 2)
    data.multiCast = 0
  end

  SPELL_CACHE[self:getRealUID()] = data

  return data
end