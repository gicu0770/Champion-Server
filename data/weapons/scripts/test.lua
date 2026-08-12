local combat = Combat()
combat:setParameter(COMBAT_PARAM_TYPE, COMBAT_PHYSICALDAMAGE)

function onGetFormulaValues(player, skill, attack, factor)
local str = player:getCharacterStat(CHARSTAT_STRENGTH)
	local min = 1000
	local max = 1000
	return -min - ((min * str) /100), -max - ((max * str) /100)
end

combat:setCallback(CALLBACK_PARAM_SKILLVALUE, "onGetFormulaValues")
function onUseWeapon(player, variant)
	if not combat:execute(player, variant) then
		return false
	end
	return true
end


