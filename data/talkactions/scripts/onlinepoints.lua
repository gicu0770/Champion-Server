function onSay(player, words, param)
    local storage = player:getStorageValue(125230)
        player:sendTextMessage(MESSAGE_INFO_DESCR, "You have ".. storage .." Online Points.")
    return false
end