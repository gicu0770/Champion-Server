local combat = Combat()
combat:setParameter(COMBAT_PARAM_TYPE, COMBAT_ENERGYDAMAGE)
combat:setParameter(COMBAT_PARAM_DISTANCEEFFECT, 5)
combat:setParameter(COMBAT_PARAM_EFFECT, 38)
combat:setArea(createCombatArea(AREA_WAND))
combat:setParameter(COMBAT_PARAM_BLOCKARMOR, true)
combat:setParameter(COMBAT_PARAM_BLOCKSHIELD, true)

function onGetFormulaValues(player, skill, attack, factor)
	local level = player:getLevel()
	local magiclevel = player:getEffectiveSkillLevel(SKILL_FISHING)
	local spelldamage = 1 + (configManager.getNumber(configKeys.WAND_DAMAGE_OVER) / 100)
	local wandAoeReduction = 1 - (configManager.getNumber(configKeys.WAND_AOE_DAMAGE_OVER) / 100)
	local int = player:getCharacterStat(CHARSTAT_INTELLIGENCE)
	local max = (level / 5) + (((((magiclevel / 4) + 1) * (attack / 3)) * 1.03))
	return (-max * spelldamage) * wandAoeReduction, (-max * spelldamage) * wandAoeReduction
end

combat:setCallback(CALLBACK_PARAM_SKILLVALUE, "onGetFormulaValues")

function onUseWeapon(player, variant)
	if not combat:execute(player, variant) then
		return false
	end
	return true
end
