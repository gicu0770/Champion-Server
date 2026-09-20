-- Cleric passive regeneration (+2% Max HP/s) is handled natively by the server engine via Player:setStatistics() and healthGainMap.
-- No periodic Lua polling or Game.getPlayers() loops are needed, resulting in 0% CPU background overhead.
function onThink(interval)
	return true
end