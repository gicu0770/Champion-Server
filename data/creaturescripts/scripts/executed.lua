
function us_onHealthChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
for slot = CONST_SLOT_HEAD, CONST_SLOT_RING2 do
local item = attacker:getSlotItem(slot)
	if item then
		if item:getType():usesSlot(slot) then
		local values = item:getBonusAttributes()
			if values then
				for key, value in pairs(values) do
				local attr = US_ENCHANTMENTS[value[1]]
					if attr then
						if attr.combatType and attr.combatType ~= US_TYPES.CONDITION then
							if attr.combatType == US_TYPES.TRIGGER then
								if attr.triggerType == US_TRIGGERS.ATTACK then
								attr.execute(attacker, creature, value[2])
								end
							end
						end  
					end
				end
			end
		end	
	end	   
end
  return primaryDamage, primaryType, secondaryDamage, secondaryType
end