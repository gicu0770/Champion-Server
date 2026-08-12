
function onSay(player, words, param)
	if not player:getGroup():getAccess() then
		return true
	end

	if player:getAccountType() < ACCOUNT_TYPE_GOD then
		return false
	end
	local buffs = {BUFF_GLOBAL_SKILL,BUFF_GLOBAL_DAMAGE,BUFF_GLOBAL_DAMAGE_REDUCTION,BUFF_GLOBAL_HEALING,BUFF_GLOBAL_FOSSIL,BUFF_GLOBAL_UPGRADE_MATERIALS_COUNT,BUFF_GLOBAL_EXP,BUFF_GLOBAL_GOLD,BUFF_GLOBAL_LOOT,BUFF_GLOBAL_PORTALS}
	for i = 1, #buffs do
		removeGlobalBuff(buffs[i])
	end
	
	player:sendTextMessage(MESSAGE_INFO_DESCR, "Global buffs removed")

	
return false
end