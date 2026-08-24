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
	return true
end

function Party:onLeave(player)
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
	self:getLeader():sendExtendedOpcode(
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
	return true
end

function Party:onDisband()
	onDungeonPartyDisband(self)
	for _, member in ipairs(self:getMembers()) do
		member:sendExtendedOpcode(
			ExtendedOPCodes.CODE_PARTY,
			json.encode(
				{
					action = "disband",
				}
			)
		)
	end
	self:getLeader():sendExtendedOpcode(
		ExtendedOPCodes.CODE_PARTY,
		json.encode(
			{
				action = "disband",
			}
		)
	)
	return true
end

function Party:onLeaderPass(oldLeader, newLeader)
	onDungeonPartyLeaderPass(self, oldLeader, newLeader)
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
