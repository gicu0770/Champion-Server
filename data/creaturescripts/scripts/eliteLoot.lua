local randomItem = {26555, 18413, 18415, 18422, 18421, 18420}
local randomItemBook = {26806, 26807}
function onDeath(creature, corpse, killer, mostDamage, unjustified, mostDamage_unjustified)
	if not creature or creature:isPlayer() or creature:getMaster() then
		return true
	end
	if corpse and isContainer(corpse) or not corpse.itemid == 0 then
	local hpMonster = MonsterType(creature:getName()):getMaxHealth() * (1 + (creature:getMonsterLevel() * 0.04))
		if hpMonster >= 500 then
			if creature:getSkull() >= 7 then
				if math.random(1,100) <= 50 then
				corpse:addItem(24850,math.random(1, 5))
				end
			end
			if creature:getSkull() == 25 then
				corpse:addItem(24850,math.random(5, 25))
			end
		end
	end
	return true
end