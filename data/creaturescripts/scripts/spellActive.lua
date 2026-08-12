function onThink(creature, interval)
	local creature = Player(creature)
	if creature then
		if creature:getStorageValue(PlayerStorage.intervalBonus) >= os.time() then
		else
			local item = creature:getSlotItem(16)
			if not item then
				return
			end

			local name = item:getSpellName()
			local SPELL = SPELLS[name]
			if not SPELL then
				return
			end

			SPELL.cast(creature, item)
			creature:setStorageValue(PlayerStorage.intervalBonus, os.time() + 1)
		end
	end
	return true
end
