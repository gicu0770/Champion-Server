local combat = Combat()

function killMonsterGM(player, target)
	if not player or not target then
		return
	end

	if not target:isMonster() then
		return
	end

	doTargetCombatHealth(player, target, COMBAT_PHYSICALDAMAGE, -target:getMaxHealth(), -target:getMaxHealth(), 0, ORIGIN_NONE, 0, 0)
end

combat:setParameter(COMBAT_PARAM_TYPE, COMBAT_PHYSICALDAMAGE)
combat:setCallback(CALLBACK_PARAM_TARGETCREATURE, "killMonsterGM")
combat:setArea(createCombatArea(AREA_CIRCLE9X9))
combat:setParameter(COMBAT_PARAM_DAMAGE, 1)

function onCastSpell(creature, variant)
	return combat:execute(creature, variant)
end
