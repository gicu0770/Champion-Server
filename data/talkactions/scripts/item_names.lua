
function onSay(player, words, param)
local firstSet = {26774, 26767, 26828, 26438, 26754, 26637, 26519, 26520, 26521, 26522, 26434, 2456, 26435, 26436, 26437, 26439, 2429, 2423, 36666, 2661, 2121}
local secondSet = {26523, 26524, 26525, 26526, 26749, 26552, 26490, 26491, 26492, 26493, 15643, 8849, 26392, 26393, 26394, 26395, 26570, 26608, 26618, 2394, 2124, 23541}
local trzeciSet = {26441, 26442, 26443, 26444, 26752, 26445, 26453, 26454, 26455, 26456, 26463, 8853, 25522, 26446, 26447, 26448, 26449, 26450, 26452, 26451, 26643, 2135, 2179}
local descInfo = "***     First items Item Level 10     ***"
for i = 1, #firstSet do
local itemID = firstSet[i]
local itemName = ItemType(itemID):getName()
descInfo = string.format("%s\n ID: %s Name: %s", descInfo, itemID, itemName)
end
descInfo = string.format("%s\n ***     Second Items Item Level 25     ***", descInfo)
for i = 1, #secondSet do
local itemID = secondSet[i]
local itemName = ItemType(itemID):getName()
descInfo = string.format("%s\n ID: %s Name: %s", descInfo, itemID, itemName)
end
descInfo = string.format("%s\n ***     Thrid Items Item Level 45     ***", descInfo)
for i = 1, #trzeciSet do
local itemID = trzeciSet[i]
local itemName = ItemType(itemID):getName()
descInfo = string.format("%s\n ID: %s Name: %s", descInfo, itemID, itemName)
end
--	player:sendTextMessage(MESSAGE_INFO_DESCR, descInfo)

for i = 1, 50 do
	local storageStart = player:getStorageValue(435000 + i)
	local storageNumer = 435000 + i
	player:setStorageValue(storageNumer, -1)
	player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Storage Key: " .. storageNumer .. " Storage Value: " .. storageStart)
end

	return false
end