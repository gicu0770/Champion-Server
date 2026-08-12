function Creature:onBuffAdded(buff)
	if self:isPlayer() then
		local buffData = {
				id = buff:getId(),
				name = buff:getName(),
				description = buff:getDescription(),
				icon = buff:getIcon(),
				border = buff:getBorder(),
				stacks = buff:getStacks(),
				ticks = buff:getTicks(),
				endTime = buff:getEndTime(),
				server_time = os.time(),
				debuff = buff:isDebuff()
		}

		if not PLAYERS_ACTIVE_BUFFS[self:getId()] then
			PLAYERS_ACTIVE_BUFFS[self:getId()] = {}
		end

		table.insert(PLAYERS_ACTIVE_BUFFS[self:getId()], buffData.id, buffData)
		self:sendExtendedOpcode(ExtendedOPCodes.CODE_BUFF, json.encode({action = "add", data = buffData}))
	end
end

function Creature:onBuffUpdated(buff)
	if self:isPlayer() then
		local buffData = {
			id = buff:getId(),
			icon = buff:getIcon(),
			stacks = buff:getStacks(),
			ticks = buff:getTicks(),
			endTime = buff:getEndTime(),
			server_time = os.time(),
			debuff = buff:isDebuff()
		}
		if PLAYERS_ACTIVE_BUFFS[self:getId()][buffData.id] then
			PLAYERS_ACTIVE_BUFFS[self:getId()][buffData.id].id = buffData.id
			PLAYERS_ACTIVE_BUFFS[self:getId()][buffData.id].icon = buffData.icon
			PLAYERS_ACTIVE_BUFFS[self:getId()][buffData.id].stacks = buffData.stacks
			PLAYERS_ACTIVE_BUFFS[self:getId()][buffData.id].ticks = buffData.ticks
			PLAYERS_ACTIVE_BUFFS[self:getId()][buffData.id].endTime = buffData.endTime
			PLAYERS_ACTIVE_BUFFS[self:getId()][buffData.id].server_time = buffData.server_time
			PLAYERS_ACTIVE_BUFFS[self:getId()][buffData.id].debuff = buffData.debuff
		end
		self:sendExtendedOpcode(ExtendedOPCodes.CODE_BUFF, json.encode({action = "update", data = buffData}))
	end
end

function Creature:onBuffRemoved(buff)
	if self:isPlayer() then
		local buffData = {
				id = buff:getId(),
				debuff = buff:isDebuff()
		}
		if PLAYERS_ACTIVE_BUFFS[self:getId()][buffData.id] then
			table.remove(PLAYERS_ACTIVE_BUFFS[self:getId()], buffData.id)
		end
		self:sendExtendedOpcode(ExtendedOPCodes.CODE_BUFF, json.encode({action = "remove", data = buffData}))
	end
end
