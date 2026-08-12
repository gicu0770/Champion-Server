POTION_CONFIG = {
  [7618] = {health = {120, 120}, level = 1, effect = 304}, -- health potion

  [7588] = {health = {180, 180}, level = 15, description = "Only for players of level 15 or above may drink this fluid.", effect = 304}, -- strong health potion

  [7591] = {health = {220, 220}, level = 23, description = "Only for players of level 23 or above may drink this fluid.", effect = 304}, -- great health potion

  [8473] = {health = {280, 280}, level = 33, description = "Only for players of level 33 or above may drink this fluid.", effect = 304}, -- ultimate health potion

  [26031] = {health = {340, 340}, level = 43, description = "Only for players of level 43 or above may drink this fluid.", effect = 306}, -- ultimate spirit potion

  [36912] = {health = {400, 400}, level = 52, description = "Only for players of level 52 or above may drink this fluid.", effect = 304}, -- health potion

  [34256] = {health = {460, 460}, level = 62, description = "Only for players of level 62 or above may drink this fluid.", effect = 304}, -- health potion

  [26917] = {health = {520, 520}, level = 72, description = "Only for players of level 72 or above may drink this fluid.", effect = 304}, -- energy shield
}

local function onUse(player, item, button)
  if not player then return end
  if player:hasCondition(CONDITION_SPELLCOOLDOWN, button+150) then
    return
  end
  local cooldownPotion = 3000
  local quality = item:isQuality()
  local potion = POTION_CONFIG[item:getId()]
  if not potion then
    print("Potion config not found for item id: "..item:getId())
    return
  end
  local potionLevel = item:getItemLevel() - 10
  if potionLevel and player:getLevel() < potionLevel or potion.vocations and
    not table.contains(potion.vocations, player:getVocation():getId()) then
      if potion.description then
        player:say(potion.description, TALKTYPE_MONSTER_SAY)
      end
    return true
  end

  if potion.cooldownPotion then
    cooldownPotion = potion.cooldownPotion
  end
  
    if potion.health then
      local regenT = "health"
      local HP = item:getCustomAttribute("potionHealth") or 0
      if colleftInfo[player:getId()].attributesItems[249] then -- energy shield regeneration percent per second
        HP = HP + colleftInfo[player:getId()].attributesItems[249].value
      end
      local hpIncreased = 0
      if quality then
        hpIncreased = quality
      end
      if colleftInfo[player:getId()].attributesItems[16] then -- Recovery Effectiveness
        hpIncreased = colleftInfo[player:getId()].attributesItems[16].value
      end
      if player:getCharacterStat(CHARSTAT_TWO) then -- Recovery Effectiveness character stat
        hpIncreased = hpIncreased + player:getCharacterStat(CHARSTAT_TWO)
      end
      local upgradeLevel = item:getUpgradeLevel() or 0
      if upgradeLevel > 0 then
       hpIncreased = hpIncreased + calculateUpgradeValue(upgradeLevel)
      end
      if hpIncreased > 0 then
        HP = math.ceil(HP + ((HP * hpIncreased) / 100))
      end
      if colleftInfo[player:getId()].attributesItems[95] then -- Health Recovery
        HP = HP + colleftInfo[player:getId()].attributesItems[95].value
      end
      if colleftInfo[player:getId()].attributesItems[119] then -- Energy Shield Recovery
        player:addEnergyShield(colleftInfo[player:getId()].attributesItems[119].value)
      end
      if player:getBuff(BOSS_HEALING_REDUCTION) then
        HP = HP / 2
      end
      if colleftInfo[player:getId()].attributesItems[123] then -- Quick Heal
        local instaHeal = HP * (colleftInfo[player:getId()].attributesItems[123].value / 100)
        HP = HP - instaHeal
        if colleftInfo[player:getId()].attributesItems[116] then -- Health Barrier
          player:addEnergyShield(instaHeal)
        else
          doTargetCombat(player:getId(), player:getId(), COMBAT_HEALING, instaHeal, instaHeal)
        end
      end
      if colleftInfo[player:getId()].attributesItems[118] then -- Haste
        local hasteAdded = player:getBaseSpeed() * colleftInfo[player:getId()].attributesItems[118].value / 100
        local conditionHaste = Condition(CONDITION_HASTE, CONDITIONID_DEFAULT)
        conditionHaste:setParameter(CONDITION_PARAM_SUBID, 777776)
        conditionHaste:setParameter(CONDITION_PARAM_TICKS, 1 * 1000) -- 2 secs
        conditionHaste:setFormula(0.0, hasteAdded, 0.0, hasteAdded)
        player:addCondition(conditionHaste)
        player:addBuff(HASTE_ITEM)
      end
      if colleftInfo[player:getId()].attributesItems[115] then -- Mana Recovery
				player:addMana(colleftInfo[player:getId()].attributesItems[115].value, true)
			end
      if colleftInfo[player:getId()].attributesItems[116] then -- Health Barrier
        regenT = "energyshield"
        HP = HP * (1 + (colleftInfo[player:getId()].attributesItems[116].value / 100))
			end
      resourceRegen(player, HP, 3, 10, regenT)
      --doTargetCombat(player:getId(), player:getId(), COMBAT_HEALING, HP, HP)
    end

    if potion.mana then
      local manaEnd = potion.mana[1] -- * 1.33
      if quality then
        manaEnd = manaEnd + (manaEnd * quality / 100)
      end
      doTargetCombatMana(player, player, manaEnd, manaEnd)
    end

    if player:getPosition():sendMagicEffect(potion.effect) then
      player:getPosition():sendMagicEffect(potion.effect)
    else
      player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
    end

  local cd = Condition(CONDITION_SPELLCOOLDOWN)
  cd:setParameter(CONDITION_PARAM_TICKS, cooldownPotion)
  cd:setParameter(CONDITION_PARAM_SUBID, button+150)
  player:addCondition(cd)
  player:updateInspect()
end


POTIONS["potions"] = {
  use = function(player, item, button)
    onUse(player, item, button)
  end
}