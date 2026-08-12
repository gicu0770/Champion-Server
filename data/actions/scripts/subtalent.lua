function onUse(player, item, fromPosition, itemEx, toPosition)
	if player:getStorageValue(435001) ~= -1 then
		player:showSecondTalentSelector(item)
	else
		player:popupFYI("You dont have Second Talents!")
	end
	return true
end