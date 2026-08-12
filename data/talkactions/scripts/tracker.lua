function onSay(player, words, param)
    player:sendExtendedOpcode(ExtendedOPCodes.CODE_DAILYQUEST, json.encode({action = "TRACKER"}))
    player:sendTextMessage(MESSAGE_INFO_DESCR, "Daily Quest Tracker Hide/Show")
	return false
end