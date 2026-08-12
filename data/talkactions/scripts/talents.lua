
function onSay(player, words, param)
	if not player:getGroup():getAccess() then
		return true
	end

	if player:getAccountType() < ACCOUNT_TYPE_GOD then
		return false
	end
	local target = Player(param)
	if not target then
		player:sendCancelMessage("A player with that name is not online.")
		return false
	end
	local TALENT = TALENTS_SORCERER
	if target:isSorcerer() then
      TALENT = TALENTS_SORCERER
    end

    if target:isDruid() then
      TALENT = TALENTS_DRUID
    end

    if target:isArcher() then
      TALENT = TALENTS_ARCHER
    end

    if target:isKnight() then
      TALENT = TALENTS_KNIGHT
    end
  
    if target:isPaladin() then
      TALENT = TALENTS_PALADIN
    end
	
    if target:isShadow() then
      TALENT = TALENTS_SHADOW
    end
	local vocName = target:getVocation():getName()
	player:sendTextMessage(MESSAGE_INFO_DESCR, "Name: "..param..", Vocation: "..vocName.."")
	for i = 1, #TALENT do
		if target:getStorageValue(TALENT[i].STORAGE) == 1 then
		player:sendTextMessage(MESSAGE_INFO_DESCR, "Level: "..TALENT[i].LEVEL.." - "..TALENT[i].TALENT[1].NAME.."")
		end
		if target:getStorageValue(TALENT[i].STORAGE) == 2 then
		player:sendTextMessage(MESSAGE_INFO_DESCR, "Level: "..TALENT[i].LEVEL.." - "..TALENT[i].TALENT[2].NAME.."")
		end
		if target:getStorageValue(TALENT[i].STORAGE) == 3 then
		player:sendTextMessage(MESSAGE_INFO_DESCR, "Level: "..TALENT[i].LEVEL.." - "..TALENT[i].TALENT[3].NAME.."")
		end
	end


	
return false
end