function onSay(player, words, param)
	local rarity = tostring(param)
	local choosen = 0
	if rarity == "common" then
		choosen = 1
	elseif rarity == "rare" or rarity == "Rare" then
		choosen = 2
	elseif rarity == "epic" or rarity == "Epic" then
		choosen = 3
	elseif rarity == "legendary" or rarity == "Legendary" then
		choosen = 4
	elseif rarity == "heroic" or rarity == "Heroic" then
		choosen = 5
	elseif rarity == "mythic" or rarity == "Mythic" then
		choosen = 6
	elseif rarity == "divine" or rarity == "Divine" then
		choosen = 7
	else
		player:sendTextMessage(MESSAGE_INFO_DESCR, "Wrong rarity name.")
		return false
	end

	player:setStorageValue(PlayerStorage.autolootrarityActivated,choosen)
	player:sendTextMessage(MESSAGE_INFO_DESCR, "You Auto Pickup Rarity set to "..rarity..".")
	return false
end
