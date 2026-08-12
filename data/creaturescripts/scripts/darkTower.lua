local cfg = {
    ['koon'] = {kickPosition = Position(771, 1031, 5), area = Position(1054, 86, 7), range = 12, kickTime = 10, textKill="Koon was defeated wait 10 seconds to teleport!", textKick="You finished arena!"},
    ['brit'] = {kickPosition = Position(771, 1031, 5), area = Position(1054, 86, 7), range = 12, kickTime = 10, textKill="Brit was defeated wait 10 seconds to teleport!", textKick="You finished arena!"},
    ['groomi'] = {kickPosition = Position(771, 1031, 5), area = Position(1054, 86, 7), range = 12, kickTime = 10, textKill="Groomi was defeated wait 10 seconds to teleport!", textKick="You finished arena!"},
    ['dronm'] = {kickPosition = Position(771, 1031, 5), area = Position(1054, 86, 7), range = 12, kickTime = 10, textKill="Dronm was defeated wait 10 seconds to teleport!", textKick="You finished arena!"},
    ['olp'] = {kickPosition = Position(771, 1031, 5), area = Position(1054, 86, 7), range = 12, kickTime = 10, textKill="Olp was defeated wait 10 seconds to teleport!", textKick="You finished arena!"},
    ['borni'] = {kickPosition = Position(771, 1031, 5), area = Position(1054, 86, 7), range = 12, kickTime = 10, textKill="borni was defeated wait 10 seconds to teleport!", textKick="You finished arena!"},
    ['aron'] = {kickPosition = Position(771, 1031, 5), area = Position(1054, 86, 7), range = 12, kickTime = 10, textKill="Aron was defeated wait 10 seconds to teleport!", textKick="You finished arena!"},
    ['timmi'] = {kickPosition = Position(771, 1031, 5), area = Position(1054, 86, 7), range = 12, kickTime = 10, textKill="Timmi was defeated wait 10 seconds to teleport!", textKick="You finished arena!"},
    ['rekto'] = {kickPosition = Position(771, 1031, 5), area = Position(1054, 86, 7), range = 12, kickTime = 10, textKill="Rekto was defeated wait 10 seconds to teleport!", textKick="You finished arena!"},
    ['werton'] = {kickPosition = Position(771, 1031, 5), area = Position(1054, 86, 7), range = 12, kickTime = 10, textKill="Werton was defeated wait 10 seconds to teleport!", textKick="You finished arena!"},
    ['Dasdasd'] = {kickPosition = Position(771, 1031, 5), area = Position(1054, 86, 7), range = 12, kickTime = 10, textKill="Forgotten King was defeated wait 10 seconds to teleport!", textKick="You finished arena!"}
}
 

function onKill(creature, target)
    local tmp = cfg[target:getName():lower()]
    if tmp and target:isMonster() then
	local player = Player(creature:getId())



	local creatruresPLAYER = Game.getSpectators(tmp.area, false, false, tmp.range, tmp.range, tmp.range, tmp.range)
	for _, creature in pairs(creatruresPLAYER) do
		if Player(creature:getId()) then
			Position(player:getPosition()):sendMagicEffect(CONST_ME_POFF)
			player:sendTextMessage(MESSAGE_EVENT_ADVANCE, tmp.textKick)
			local sto2 = creature:getStorageValue(PlayerStorage.darkTower)
			local rewardCounts = (sto2 + 2) * 2 -- flor * 2
	local bag = Game.createItem(1992, 1)
	local inbox = creature:getInbox()
	bag:setAttribute(ITEM_ATTRIBUTE_NAME, "Reward Bag")
	if creature:getStorageValue(PlayerStorage.darkTower) >= -1 and creature:getStorageValue(PlayerStorage.darkTower) <= 1 then 
		bag:addItem(24850, (rewardCounts * 5), INDEX_WHEREEVER, FLAG_NOLIMIT)
		creature:addExperience(rewardCounts * 1500000, true)
	elseif creature:getStorageValue(PlayerStorage.darkTower) >= 2 then 
		bag:addItem(24850, (rewardCounts * 5), INDEX_WHEREEVER, FLAG_NOLIMIT)

		bag:addItem(36979, rewardCounts, INDEX_WHEREEVER, FLAG_NOLIMIT)
		bag:addItem(36981, rewardCounts, INDEX_WHEREEVER, FLAG_NOLIMIT)
		bag:addItem(2157, (rewardCounts * 3), INDEX_WHEREEVER, FLAG_NOLIMIT)

		creature:addExperience(rewardCounts * 1500000, true)
	end
	inbox:addItemEx(bag, INDEX_WHEREEVER, FLAG_NOLIMIT)
	local description, items = "Congratulations, you finished the floor!\nYou rewards: ", bag:getItems()
            for _, item in pairs(items) do
                description = string.format("%s%d %s%s", description, item:getCount(), item:getName(), (_ == #items and '.' or ', '))
            end
			creature:sendTextMessage(MESSAGE_EVENT_ADVANCE, description..'\nCheck your depot inbox.')				
			--creature:sendTextMessage(MESSAGE_INFO_DESCR, tmp.textKill)
			creature:teleportTo(tmp.kickPosition)
			creature:setStorageValue(PlayerStorage.darkTower, sto2 + 1)
				return false
			end
		end

--------------
end
    return true
end