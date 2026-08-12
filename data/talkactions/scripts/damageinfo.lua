function onSay(player, words, param)


if param == "spell" then
 if player:getStorageValue(PlayerStorage.damageInfo) == 1 then
  player:sendTextMessage(MESSAGE_INFO_DESCR,"More Info about Spell Damage OFF")
  player:setStorageValue(PlayerStorage.damageInfo, -1)
 else
  player:sendTextMessage(MESSAGE_INFO_DESCR,"More Info about Spell Damage ON")
  player:setStorageValue(PlayerStorage.damageInfo, 1)
  player:openChannel(17)
 end
elseif param == "taken" then
 if player:getStorageValue(PlayerStorage.damageTakenInfo) == 1 then
  player:sendTextMessage(MESSAGE_INFO_DESCR,"More Info about Damage Taken OFF")
  player:setStorageValue(PlayerStorage.damageTakenInfo, -1)
 else
  player:sendTextMessage(MESSAGE_INFO_DESCR,"More Info about Damage Taken ON")
  player:setStorageValue(PlayerStorage.damageTakenInfo, 1)
  player:openChannel(18)
 end
elseif param == "healing" then
 if player:getStorageValue(PlayerStorage.damageHealingInfo) == 1 then
  player:sendTextMessage(MESSAGE_INFO_DESCR,"More Info about Healing OFF")
  player:setStorageValue(PlayerStorage.damageHealingInfo, -1)
 else
  player:sendTextMessage(MESSAGE_INFO_DESCR,"More Info about Healing ON")
  player:setStorageValue(PlayerStorage.damageHealingInfo, 1)
  player:openChannel(19)
 end
elseif param == "dot" then
 if player:getStorageValue(PlayerStorage.damageDotInfo) == 1 then
  player:sendTextMessage(MESSAGE_INFO_DESCR,"More Info about DoT OFF")
  player:setStorageValue(PlayerStorage.damageDotInfo, -1)
 else
  player:sendTextMessage(MESSAGE_INFO_DESCR,"More Info about DoT ON")
  player:setStorageValue(PlayerStorage.damageDotInfo, 1)
  player:openChannel(31)
 end
elseif param == "basic" then
 if player:getStorageValue(PlayerStorage.basicInfo) == 1 then
  player:sendTextMessage(MESSAGE_INFO_DESCR,"More Info about Basic OFF")
  player:setStorageValue(PlayerStorage.basicInfo, -1)
 else
  player:sendTextMessage(MESSAGE_INFO_DESCR,"More Info about Basic ON")
  player:setStorageValue(PlayerStorage.basicInfo, 1)
  player:openChannel(32)
 end
 --[[
elseif param == "proc" then
 if player:getStorageValue(PlayerStorage.castInfo) == 1 then
  player:sendTextMessage(MESSAGE_INFO_DESCR,"More Info about Proc OFF")
  player:setStorageValue(PlayerStorage.castInfo, -1)
 else
  player:sendTextMessage(MESSAGE_INFO_DESCR,"More Info about Proc ON")
  player:setStorageValue(PlayerStorage.castInfo, 1)
  player:openChannel(32)
 end
 --]]
else

player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Wrong parameters.\n!info spell\n!info taken\n!info healing\n!info dot\n!info basic")
return false
end
	return false
end