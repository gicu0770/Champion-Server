function onLogout(player)
  local cid = player:getId()
  if TOWN_PORTALS_PLAYERS[cid] then
	local portal = TOWN_PORTALS_ACTIVE[TOWN_PORTALS_PLAYERS[cid].portalId]
	if portal then 
		if portal.creator == cid then
			removePortal(cid)
		end
	end
  end  
	return true
end