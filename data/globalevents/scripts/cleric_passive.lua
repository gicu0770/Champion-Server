function onThink(interval)
	for _, player in ipairs(Game.getPlayers()) do
		if player and not player:isRemoved() and player:hasClericPartyRegen() then
			if player:getHealth() > 0 and player:getHealth() < player:getMaxHealth() then
				local regen = math.ceil(player:getMaxHealth() * 0.02)
				player:addHealth(regen)
			end
		end
	end
	return true
end