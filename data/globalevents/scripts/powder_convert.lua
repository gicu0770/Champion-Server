

function onPreRemoveItem(corpse, playerId)
	if not corpse then
		return true
	end

	local player = Player(playerId)
	if not player or player:isRemoved() then
		return true
	end

	local items = corpse:getItems()
	local countPowder = {0, 0}
	for _, item in ipairs(items) do
		local index, powder = item:convertToPowder()
		countPowder[index] = countPowder[index] + powder
	end

	if countPowder[1] <= 0 and countPowder[2] <= 0 then
		return true
	end

	local party = player:getParty()
  if party and party:isSharedExperienceEnabled() then
		countPowder[1] = math.floor(countPowder[1] / (party:getMemberCount() + 1))
		countPowder[2] = math.floor(countPowder[2] / (party:getMemberCount() + 1))
    local leader = party:getLeader()
		leader:addPowder(countPowder[1], false)
		leader:addPowder(countPowder[2], true)
    for _, member in ipairs(party:getMembers()) do
			member:addPowder(countPowder[1], false)
			member:addPowder(countPowder[2], true)
    end
  else
		player:addPowder(countPowder[1], false)
		player:addPowder(countPowder[2], true)
  end

	return true
end
