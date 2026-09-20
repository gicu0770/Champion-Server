function Party:onJoin(player)
	onDungeonPartyJoin(self, player)
	for _, member in ipairs(self:getMembers()) do
		player:sendExtendedOpcode(
			ExtendedOPCodes.CODE_PARTY,
			json.encode(
				{
					action = "addmember",
					data = {
						id = member:getName(),
						outfit = member:getOutfit(),
					}
				}
			)
		)
		member:sendExtendedOpcode(
			ExtendedOPCodes.CODE_PARTY,
			json.encode(
				{
					action = "addmember",
					data = {
						id = player:getName(),
						outfit = player:getOutfit(),
					}
				}
			)
		)
	end
	player:sendExtendedOpcode(
		ExtendedOPCodes.CODE_PARTY,
		json.encode(
			{
				action = "addmember",
				data = {
					id = self:getLeader():getName(),
					outfit = self:getLeader():getOutfit(),
				}
			}
		)
	)
	self:getLeader():sendExtendedOpcode(
		ExtendedOPCodes.CODE_PARTY,
		json.encode(
			{
				action = "addmember",
				data = {
					id = player:getName(),
					outfit = player:getOutfit(),
				}
			}
		)
	)

	local playerGuid = player:getId()
	local leader = self:getLeader()
	local leaderGuid = leader and leader:getId()
	local memberGuids = {}
	for _, member in ipairs(self:getMembers()) do
		table.insert(memberGuids, member:getId())
	end

	addEvent(function()
		local p = Player(playerGuid)
		if p then p:refreshPartyRegen() end
		if leaderGuid then
			local l = Player(leaderGuid)
			if l then l:refreshPartyRegen() end
		end
		for _, mid in ipairs(memberGuids) do
			local m = Player(mid)
			if m then m:refreshPartyRegen() end
		end
	end, 100)

	return true
end

function Party:onLeave(player)
	local playerGuid = player:getId()
	local leader = self:getLeader()
	local leaderGuid = leader and leader:getId()
	local memberGuids = {}
	for _, member in ipairs(self:getMembers()) do
		if member:getId() ~= playerGuid then
			table.insert(memberGuids, member:getId())
		end
	end

	for _, member in ipairs(self:getMembers()) do
		member:sendExtendedOpcode(
			ExtendedOPCodes.CODE_PARTY,
			json.encode(
				{
					action = "removemember",
					data = {
						id = player:getName(),
					}
				}
			)
		)
	end
	if leader then
		leader:sendExtendedOpcode(
			ExtendedOPCodes.CODE_PARTY,
			json.encode(
				{
					action = "removemember",
					data = {
						id = player:getName(),
					}
				}
			)
		)
	end

	addEvent(function()
		local p = Player(playerGuid)
		if p then p:refreshPartyRegen() end
		if leaderGuid then
			local l = Player(leaderGuid)
			if l then l:refreshPartyRegen() end
		end
		for _, mid in ipairs(memberGuids) do
			local m = Player(mid)
			if m then m:refreshPartyRegen() end
		end
	end, 100)

	return true
end

function Party:onDisband()
	onDungeonPartyDisband(self)
	local leader = self:getLeader()
	local leaderGuid = leader and leader:getId()
	local memberGuids = {}
	for _, member in ipairs(self:getMembers()) do
		table.insert(memberGuids, member:getId())
		member:sendExtendedOpcode(
			ExtendedOPCodes.CODE_PARTY,
			json.encode(
				{
					action = "disband",
				}
			)
		)
	end
	if leader then
		leader:sendExtendedOpcode(
			ExtendedOPCodes.CODE_PARTY,
			json.encode(
				{
					action = "disband",
				}
			)
		)
	end

	addEvent(function()
		if leaderGuid then
			local l = Player(leaderGuid)
			if l then l:refreshPartyRegen() end
		end
		for _, mid in ipairs(memberGuids) do
			local m = Player(mid)
			if m then m:refreshPartyRegen() end
		end
	end, 100)

	return true
end

function Party:onLeaderPass(oldLeader, newLeader)
	onDungeonPartyLeaderPass(self, oldLeader, newLeader)
	local oldId = oldLeader and oldLeader:getId()
	local newId = newLeader and newLeader:getId()
	addEvent(function()
		if oldId then
			local o = Player(oldId)
			if o then o:refreshPartyRegen() end
		end
		if newId then
			local n = Player(newId)
			if n then n:refreshPartyRegen() end
		end
	end, 100)
end

function Party:onShareExperience(exp)
	local partyExp = math.ceil(exp / (#self:getMembers() + 1))
	if self:isSharedExperienceEnabled() then
		local leader = self:getLeader()
		sendExp(leader, partyExp)
		-- leader:addExpToSpells(partyExp)
		leader:addExperience(partyExp, true)
		for _, member in ipairs(self:getMembers()) do
			sendExp(member, partyExp)
			-- member:addExpToSpells(partyExp)
			member:addExperience(partyExp, true)
		end
  end

	return partyExp
end
