function onThink(creature, interval)
if creature then
 if creature:getStorageValue(PlayerStorage.intervalBonus) >= os.time() then
 else
  creature:addBuff(GHOST)
  creature:getPosition():sendMagicEffect(158)
    local conditionOutfit = Condition(CONDITION_OUTFIT)
	local outfit = creature:getOutfit()
	conditionOutfit:setTicks(2000)
	conditionOutfit:setOutfit({lookType = 48, lookHead = 0, lookBody = 0, lookLegs = 0, lookFeet = 0, lookAddons = 0, lookMount = 0, lookWings = outfit.lookWings, lookAura = 0 })
	creature:addCondition(conditionOutfit)
  creature:setStorageValue(PlayerStorage.intervalBonus, os.time() + 9)
 end
end
    return true
end