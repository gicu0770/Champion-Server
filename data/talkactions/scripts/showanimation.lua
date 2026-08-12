function onSay(player, words, param)
if player:getStorageValue(PlayerStorage.animatedTalentSkills) == 1 then
	player:sendTextMessage(MESSAGE_INFO_DESCR,"Show Animation Text Skill/Talents ON")
	player:setStorageValue(PlayerStorage.animatedTalentSkills, -1)
	else
	player:sendTextMessage(MESSAGE_INFO_DESCR,"Show Animation Text Skill/Talents OFF")
	player:setStorageValue(PlayerStorage.animatedTalentSkills, 1)
end
	return false
end