function onStepIn(cid, item, pos, fromPosition)
	if item.actionid == 27566 then
	 local creature = Creature(cid)
	 if creature then
	  creature:teleportTo(fromPosition)
	 return true
	 end
	end
	return true
end