function onSay(player, words, param)
if player:getStorageValue(51100) == -1 then
accessDraken = 'Draken Dungeon: Access Denied!'
elseif player:getStorageValue(51100) == 1 then
accessDraken = 'Draken Dungeon: Access Achieved!'
end



if player:getStorageValue(51101) == -1 then
accessForgotten = "Forgotten Land: Access Denied!"
elseif player:getStorageValue(51101) == 1 then
accessForgotten = "Forgotten Land: Access Achieved!"
end

if player:getStorageValue(51102) == -1 then
accessBrother = "Brotherhood Castle: Access Denied!"
elseif player:getStorageValue(51102) == 1 then
accessBrother = "Brotherhood Castle: Access Achieved!"
end

if player:getStorageValue(51203) == -1 then
accessPrism = "Prism Set: Access Denied!"
elseif player:getStorageValue(51203) == 1 then
accessPrism = "Prism Set: Access Achieved!"
end

if player:getStorageValue(51204) == -1 then
accessWolfing = "Undead City Stage 1: Access Denied!"
elseif player:getStorageValue(51204) == 1 then
accessWolfing = "Undead City Stage 1: Access Achieved!"
end

if player:getStorageValue(51205) == -1 then
accessUW = "Undead City Stage 2: Access Denied!"
elseif player:getStorageValue(51205) == 1 then
accessUW = "Undead City Stage 2: Access Achieved!"
end

if player:getStorageValue(51206) == -1 then
accessUD = "Undead City Stage 3: Access Denied!"
elseif player:getStorageValue(51206) == 1 then
accessUD = "Undead City Stage 3: Access Achieved!"
end

if player:getStorageValue(51207) == -1 then
accessUR = "Undead City Last Stage: Access Denied!"
elseif player:getStorageValue(51207) == 1 then
accessUR = "Undead City Last Stage: Access Achieved!"
end

if player:getStorageValue(51208) == -1 then
accessUU = "Royal Village: Access Denied!"
elseif player:getStorageValue(51208) == 1 then
accessUU = "Royal Village: Access Achieved!"
end

if player:getStorageValue(51209) == -1 then
accessTT = "Rage Hell and Royal Stone Craft: Access Denied!"
elseif player:getStorageValue(51209) == 1 then
accessTT = "Rage Hell and Royal Stone Craft: Access Achieved!"
end

if player:getStorageValue(51210) == -1 then
accessFF = "Hell Stone Craft: Access Denied!"
elseif player:getStorageValue(51210) == 1 then
accessFF = "Hell Stone Craft: Access Achieved!"
end


	 player:showTextDialog(12193, "1. "..accessDraken.."\n2."..accessForgotten.."\n3."..accessBrother.."\n4."..accessPrism.."\n5."..accessWolfing.."\n6."..accessUW.."\n7."..accessUD.."\n7."..accessUR.."\n8."..accessUU.."\n9."..accessTT.."\n10."..accessFF.."")
	 --player:sendTextMessage(MESSAGE_INFO_DESCR, ""..accessDraken.."\n"..accessForgotten.."\n"..accessBrother.."\n"..accessPrism.."\n"..accessWolfing.."")
	return false
end
