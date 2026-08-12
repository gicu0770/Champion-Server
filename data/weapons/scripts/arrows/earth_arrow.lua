local combat = Combat()
combat:setParameter(COMBAT_PARAM_TYPE, COMBAT_PHYSICALDAMAGE)
combat:setParameter(COMBAT_PARAM_BLOCKARMOR, true)

function onGetFormulaValues(player, skill, attack, factor)
	local level = player:getLevel()
	local spelldamage = 1 + (configManager.getNumber(configKeys.MELEE_DAMAGE_OVER) / 100)
	local max = (level / 5) + (((((skill / 4) + 1) * (attack / 3)) * 1.03))
	return -max * spelldamage, -max * spelldamage
end

combat:setCallback(CALLBACK_PARAM_SKILLVALUE, "onGetFormulaValues")

local combat2 = Combat()
combat2:setParameter(COMBAT_PARAM_TYPE, COMBAT_EARTHDAMAGE)
combat2:setParameter(COMBAT_PARAM_DISTANCEEFFECT, 40)
combat2:setParameter(COMBAT_PARAM_EFFECT, 21)

function onGetFormulaValues2(player, skill, attack, factor)
	local level = player:getLevel()
	local spelldamage = 1 + (configManager.getNumber(configKeys.MELEE_DAMAGE_OVER) / 100)
	local max = (level / 5) + (((((skill / 4) + 1) * (attack / 3)) * 1.03))
	return (-max * spelldamage) * 0.02, (-max * spelldamage) * 0.02
end

combat2:setCallback(CALLBACK_PARAM_SKILLVALUE, "onGetFormulaValues2")

function onUseWeapon(player, variant)
	if not combat:execute(player, variant) then
		return false
	end
	if not combat2:execute(player, variant) then
		return false
	end
	return true
end


