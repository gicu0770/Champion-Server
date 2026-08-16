function Party.broadcastPartyLoot(self, text)
	--self:getLeader():sendTextMessage(MESSAGE_INFO_DESCR, text)
	self:getLeader():sendChannelMessage("", text, TALKTYPE_CHANNEL_O, CHANNEL_LOOT)
	local membersList = self:getMembers()
	for i = 1, #membersList do
		local player = membersList[i]
		if player then
			player:sendChannelMessage("", text, TALKTYPE_CHANNEL_O, CHANNEL_LOOT)
			--player:sendTextMessage(MESSAGE_INFO_DESCR, text)
		end
	end
end
