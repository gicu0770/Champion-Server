function onHealthChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
if creature:isMonster() then
	if creature:getName() == "Golden Goblin"
	or creature:getName() == "Golden Mummy"
	or creature:getName() == "Golden Dragon"
	or creature:getName() == "Golden Angel"
	or creature:getName() == "Golden Archangel"
	or creature:getName() == "Corrupted Evil" 
	or creature:getName() == "Corrupted Death" 
	or creature:getName() == "Corrupted Hybrid" 
	or creature:getName() == "Corrupted Avenger" then
		primaryDamage = 1
		secondaryDamage = 0
	end	
end
  return primaryDamage, primaryType, secondaryDamage, secondaryType
end