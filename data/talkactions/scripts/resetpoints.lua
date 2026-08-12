function onSay(player, words, param)
	player:getPosition():sendMagicEffect(50)
	resetStats(player)
	return false
end
