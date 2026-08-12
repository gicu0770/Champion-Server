function onThink(creature, interval)
if creature then
 if creature:getStorageValue(PlayerStorage.intervalBonus) >= os.time() then
 
 else
	local config = {
	[1] = {buff = EARTH_TURTLE, look = 303},
	[2] = {buff = WEREWOLF, look = 308},
	[3] = {buff = MUTATED_BAT, look = 307}
	}
    local randomM = math.random(1,3)
    local conditionOutfit = Condition(CONDITION_OUTFIT)
	local outfit = creature:getOutfit()
	conditionOutfit:setTicks(5000)
--	conditionOutfit:setOutfit({lookType = config[randomM].look, lookHead = 0, lookBody = 0, lookLegs = 0, lookFeet = 0, lookAddons = 0, lookMount = 0, lookWings = 0, lookAura = 0 })
	conditionOutfit:setOutfit({lookType = config[randomM].look, lookHealthBar = 2, lookManaBar = 1}) 
	creature:addCondition(conditionOutfit)
	creature:addBuff(config[randomM].buff)
	creature:getPosition():sendMagicEffect(117)
	if randomM == 2 then
	 local HPregen = creature:getMaxHealth() * 0.10
	 local regenR = Condition(CONDITION_REGENERATION)
	 regenR:setParameter(CONDITION_PARAM_TICKS, 5000)
	 regenR:setParameter(CONDITION_PARAM_HEALTHGAIN, HPregen)
	 regenR:setParameter(CONDITION_PARAM_HEALTHTICKS, 1000)
	 regenR:setParameter(CONDITION_PARAM_SUBID, 900005)
	 creature:addCondition(regenR)
	end

  creature:setStorageValue(PlayerStorage.intervalBonus, os.time() + 14)
 end
end
    return true
end