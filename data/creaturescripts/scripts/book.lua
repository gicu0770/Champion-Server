function onDeath(creature, corpse, killer, mostDamage, unjustified, mostDamage_unjustified)
local book = {26806, 26805, 26807}
    if not creature:isMonster() then return true end
    if corpse and corpse:isContainer() then
       if math.random(100000) <= 25 then
	corpse:addItem(book[math.random(#book)], 1)
	Game.sendAnimatedText('Mysterious Book!', corpse:getPosition(), 205) --210
	corpse:getPosition():sendMagicEffect(CONST_ME_HOLYAREA)
	killer:sendChannelMessage("", "[Extra Loot] Mysterious Book", TALKTYPE_CHANNEL_O, 9)
	killer:sendTextMessage(MESSAGE_STATUS_WARNING, "[Extra Loot] Mysterious Book")
        end
    end
    return true
end