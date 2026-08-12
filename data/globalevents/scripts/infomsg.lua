local msgInfoIndex = 1
local messagesInfo = {
	{
		chatMesssage = "Store Info",
		midMesssage = "All {Cosmetics} from {Outfits} to {Town Portal} you buy in {Store} are {Permanent}.\nThey carry over to all future {Seasons}!",
		color = "#f7ef8a",
	},
}

function onThink(interval)
	local msg = messagesInfo[msgInfoIndex]
	if not msg then
		msgInfoIndex = 1
		msg = messagesInfo[msgInfoIndex]
	end

	local players = Game.getPlayers()
	for _, player in ipairs(players) do
		player:sendExtendedOpcode(71, json.encode({text = msg.midMesssage, color = msg.color}))
		player:sendTextMessage(MESSAGE_EVENT_ORANGE, msg.chatMesssage)
	end

	msgInfoIndex = msgInfoIndex + 1
	return true
end