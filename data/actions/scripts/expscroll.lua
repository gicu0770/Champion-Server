function onUse(cid, item, fromPosition, itemEx, toPosition)
    local player = Player(cid)
    if player:getStorageValue(PlayerStorage.expScroll) >= os.time() then
        player:say('You already have +30% EXP for next 3 hours!', TALKTYPE_MONSTER_SAY)
        return true
    end

		player:setStorageValue(PlayerStorage.expScroll, os.time() + 10800)
		Item(item.uid):remove(1)
		player:say('Your 3 hours of 30% XP has started!', TALKTYPE_MONSTER_SAY)
		player:addBuff(BUFF_EXP_SCROLL)
		ExpShowTotal(player)
    return true
end