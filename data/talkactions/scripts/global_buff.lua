
function onSay(player, words, param)
	if not player:getGroup():getAccess() then
		return true
	end

	if player:getAccountType() < ACCOUNT_TYPE_GOD then
		return false
	end

	if not param then
		player:sendCancelMessage("Insufficient parameters.")
		return false
	end
	local originalParam = param
	if param == "damage" then
		param = BUFF_GLOBAL_DAMAGE
	elseif param == "damage reduction" then
		param = BUFF_GLOBAL_DAMAGE_REDUCTION
	elseif param == "fossil" then
		param = BUFF_GLOBAL_FOSSIL
	elseif param == "healing" then
		param = BUFF_GLOBAL_HEALING
	elseif param == "upgrade" then
		param = BUFF_GLOBAL_UPGRADE_MATERIALS_COUNT
	elseif param == "exp" then
		param = BUFF_GLOBAL_EXP
	elseif param == "gold" then
		param = BUFF_GLOBAL_GOLD
	elseif param == "loot" then
		param = BUFF_GLOBAL_LOOT
	elseif param == "skill" then
		param = BUFF_GLOBAL_SKILL
	elseif param == "portal" then
		param = BUFF_GLOBAL_PORTALS
	end
	local tim = 1 * 3600000
	if getGlobalBuff(param) then
		tim = tim + (getGlobalBuff(param).endTime - (os.time() * 1000))
		for _, targetPlayer in ipairs(Game.getPlayers()) do
			local buffMessage = string.format("Player %s extended {%s} global boost by {1h}!", player:getName(), originalParam)
			targetPlayer:sendExtendedOpcode(71, json.encode({text = buffMessage, color = "#f7ef8a"}))
		end
	else
		for _, targetPlayer in ipairs(Game.getPlayers()) do
				local buffMessage = string.format("Player %s activated {%s} global boost by {1h}!", player:getName(), originalParam)
				targetPlayer:sendExtendedOpcode(71, json.encode({text = buffMessage, color = "#f7ef8a"}))		
		end
	end
	addGlobalBuff(param, tim)
	
return false
end