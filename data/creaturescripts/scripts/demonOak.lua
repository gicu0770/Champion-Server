local cfg = {
    ['demon oak left hand'] = {monstersPos = Position(904, 503, 7), bossName = "Demon Oak Right Hand", textKill = "You defead Demon Oak Left Hand!\nDemon Oak Right Hand coming!"},
    ['demon oak right hand'] = {monstersPos = Position(902, 501, 7), bossName = "Demon Oak Raven", textKill = "You defead Demon Oak Right Hand\nDemon Oak Raven coming!"},
    ['demon oak raven'] = {monstersPos = Position(902, 504, 7), bossName = "Demon Oak", textKill = "You defead Demon Oak Raven\nDemon Oak coming!!!"},	
    ['demon oak'] = {monstersPos = Position(902, 504, 7), bossName = "Demon Oak Fury", textKill = "You defead Demon Oak Raven\nYou make fury Demon Oak!!!"},
	
	
	['ddd123'] = {tpDestination = Position(89, 127, 7), area = Position(150, 134, 7), textKill = "30"}
}




function onKill(creature, target)
	local player = Player(creature:getId())
	if target:getName() == "Demon Oak Fury" then
	local sto = player:getStorageValue(PlayerStorage.demonOak)
	player:setStorageValue(PlayerStorage.demonOak, sto + 1)
	if player:getLevel() >= 100 then
		local bag = Game.createItem(1992, 1)
		local inbox = player:getInbox()
		bag:setAttribute(ITEM_ATTRIBUTE_NAME, "Reward Bag")
		bag:addItem(26805, 2, INDEX_WHEREEVER, FLAG_NOLIMIT)
		bag:addItem(24850, 20, INDEX_WHEREEVER, FLAG_NOLIMIT)
		bag:addItem(21250, 20, INDEX_WHEREEVER, FLAG_NOLIMIT)
		local leftRing = bag:addItem(26832, 1, INDEX_WHEREEVER, FLAG_NOLIMIT)
		local rightRing = bag:addItem(26965, 1, INDEX_WHEREEVER, FLAG_NOLIMIT)
		 leftRing:setQuestItem(1)
		 setLootItem(player, leftRing, 1, 7000, 4000, 2000)
		 rightRing:setQuestItem(1)
		 setLootItem(player, rightRing, 1, 7000, 4000, 2000)
		 if not bag:moveTo(player:getSlotItem(CONST_SLOT_BACKPACK)) then
			inbox:addItemEx(bag, INDEX_WHEREEVER, FLAG_NOLIMIT)
			local description, items = "Congratulations, you finished the Demon Oak Quest!\nYou rewards: ", bag:getItems()
			for _, item in pairs(items) do
				description = string.format("%s%d %s%s", description, item:getCount(), item:getName(), (_ == #items and '.' or ', '))
			end		
			creature:sendExtendedOpcode(216, json.encode({text = description..'\nCheck your depot inbox!', color = "#f7ef8a"}))
		 end
	end
	return false
	end
	
    local tmp = cfg[target:getName():lower()]
    if tmp and target:isMonster() then


	Game.createMonster(tmp.bossName, tmp.monstersPos, true, true)
	player:sendTextMessage(MESSAGE_EVENT_ADVANCE, tmp.textKill)
	
end
    return true
end