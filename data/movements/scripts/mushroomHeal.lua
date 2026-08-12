
function onStepIn(creature, item, position, fromPosition)
if creature:isPlayer() then
	if item.actionid == 27551 then
		local hp = creature:getMaxHealth() * 0.01
		creature:addHealth(hp)
		item:remove()
	end
end
	return true
end
