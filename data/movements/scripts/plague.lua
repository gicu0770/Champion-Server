function onStepIn(creature, item, position, fromPosition)
		if creature:isPlayer() then
			if item.actionid == 27541 then -- plagued
				if creature:hasBuff(RESTART_IMMORTAL) or creature:hasBuff(KNIGHT_PROTECTOR) or creature:hasBuff(FREEZ) or creature:hasBuff(CRYO_FORM) or creature:hasBuff(GHOST) then
					return false
				end
				if item:getCustomAttribute("monsterId") then
					doTargetCombatHealth(item:getCustomAttribute("monsterId"), creature, COMBAT_EARTHDAMAGE, 1, 1, CONST_ME_NONE, ORIGIN_SPELL)
				else
					item:remove(1)
				end
			elseif item.actionid == 27542 then -- electro
				if creature:hasBuff(RESTART_IMMORTAL) or creature:hasBuff(KNIGHT_PROTECTOR) or creature:hasBuff(FREEZ) or creature:hasBuff(CRYO_FORM) or creature:hasBuff(GHOST) then
					return false
				end
			--	creature:addHealth(-damage)
			--	doTargetCombatHealth(creature, creature, COMBAT_ENERGYDAMAGE, -damage, -damage, CONST_ME_NONE, ORIGIN_CONDITION)
				if item:getCustomAttribute("monsterId") then
					doTargetCombatHealth(item:getCustomAttribute("monsterId"), creature, COMBAT_ENERGYDAMAGE, 1, 1, CONST_ME_NONE, ORIGIN_SPELL)
				else
					item:remove(1)
				end
			end
		end
		return true
	end