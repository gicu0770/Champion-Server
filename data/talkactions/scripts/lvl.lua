function onSay(player, words, param)
	if player:getAccountType() < ACCOUNT_TYPE_GOD then
		return false
	end
	--[[--
	local function getExpForLevel(level)
	 level = level - 1
	 return ((50 * level * level * level) - (150 * level * level) + (400 * level)) / 3
	end
	player:addExperience(getExpForLevel(player:getLevel() + param) - player:getExperience(), false)
	--]]--
	local playerId = player:getGuid()
	local level = param
    player:remove()  
    db.query("UPDATE `players` SET `level` = '"..level.."', `health` = '200', `healthmax` = '200', `mana` = '100', `manamax` = '100', `experience` = '0', `cap` = '500' WHERE `id` = " .. playerId)
	return false
end
