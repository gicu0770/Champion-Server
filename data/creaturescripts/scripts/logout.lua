function onLogout(player)
	local playerId = player:getId()

	if SPELLS then
		for spellName, spell in pairs(SPELLS) do
			if spell.isActive and spell.disable then
				if spell.isActive(player) then
					spell.disable(player)
				end
			end
		end
	end

	if nextUseStaminaTime[playerId] then
		nextUseStaminaTime[playerId] = nil
	end

	if player:isShop() then
		local tile = Tile(player:getPosition())
		tile:removeWidget()
	end

	colleftInfo[player:getId()] = nil

	if ACTIVATED_DOT[playerId] then
		ACTIVATED_DOT[playerId] = nil
	end
	if PLAYERS_ACTIVE_BUFFS and PLAYERS_ACTIVE_BUFFS[playerId] then
		PLAYERS_ACTIVE_BUFFS[playerId] = nil
	end
	if PLAYER_REGEN_EVENTS and PLAYER_REGEN_EVENTS[playerId] then
		PLAYER_REGEN_EVENTS[playerId] = nil
	end

	if player:getStorageValue(PlayerStorage.riftBlokade) == 1 then
	 player:setStorageValue(PlayerStorage.riftBlokade, -1)
	 player:teleportTo(player:loadPosition(PlayerStorage.playerPosition))
	end

	return true
end
