function onSay(player, words, param)
    local item = player:addItem(2400,1)
    addEvent(function() player:sendTextMessage(MESSAGE_INFO_DESCR, item:getCustomAttribute("PA_Level")..item:getId()) end, 5000)
	return false
end