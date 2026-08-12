function onUse(player, item, fromPosition, itemEx, toPosition)
	if player:getStorageValue(PlayerStorage.trait) < 0 then
		selfSay("You have not finished the Undead Cave Dungeon!", player) -- Ukonczony dung
	else
		item:remove()
		player:setStorageValue(PlayerStorage.secondTrait, 0)
		player:showTraitSelector()
	end

	return true
end