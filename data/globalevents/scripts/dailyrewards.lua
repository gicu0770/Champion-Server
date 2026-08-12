function onTime(interval, lastExecution)
	--for _, targetPlayer in ipairs(Game.getPlayers()) do
	--	setDailyRewards(targetPlayer, 0)
	--end
--	for _, targetPlayer in ipairs(Game.getPlayers()) do
		--targetPlayer:sendExtendedOpcode(71, "The Darkness Rider Boss coming to Desert Arena! Teleport will be available for 5 minutes.") 
--		targetPlayer:sendExtendedOpcode(71, json.encode({text = "Time resets", color = "#ff0000"}))
--	end
	db.query("UPDATE `znote_accounts` SET `daily_rewards` = 0")
	db.query("UPDATE `players` SET `daily_quest` = '0'")
	return true
end