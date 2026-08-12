function onThink(interval)
	saveServerAsync(50)
	saveBuffs()
	updateHighScoreClones()
	return true
end