function onUse(cid, item, fromPosition, itemEx, toPosition)
local upgradeCrystals = {26555, 18413, 18415, 18422, 18421, 18420}
local upgradeBooks = {26805, 26806, 26807}
------------------------------------------------------------------------------------------------------
local cap = cid:getFreeCapacity() / 100
if item.actionid == 31000 then
    if getPlayerStorageValue(cid, 13544) - os.time() <= 0 then
	if cap > 100 then
	local bag = Game.createItem(28901, 1)
	local inbox = cid:getInbox()
	bag:addItem(2160, math.random(3, 10), INDEX_WHEREEVER, FLAG_NOLIMIT)
	bag:addItem(upgradeCrystals[math.random(#upgradeCrystals)], math.random(10, 30), INDEX_WHEREEVER, FLAG_NOLIMIT)
	bag:addItem(upgradeCrystals[math.random(#upgradeCrystals)], math.random(10, 30), INDEX_WHEREEVER, FLAG_NOLIMIT)
	bag:addItem(26805, math.random(15, 30), INDEX_WHEREEVER, FLAG_NOLIMIT)
	bag:addItem(26806, math.random(15, 30), INDEX_WHEREEVER, FLAG_NOLIMIT)
	bag:addItem(26807, math.random(15, 30), INDEX_WHEREEVER, FLAG_NOLIMIT)
	bag:addItem(21250, math.random(10, 40), INDEX_WHEREEVER, FLAG_NOLIMIT)
					if math.random(1,100) <= 5 then
					bag:addItem(26804, 1, INDEX_WHEREEVER, FLAG_NOLIMIT)	-- high quality
					end
					if math.random(1,100) <= 1 then
					bag:addItem(26803, 1, INDEX_WHEREEVER, FLAG_NOLIMIT)	--	abiliyu
					end
					if math.random(1,100) <= 1 then
					bag:addItem(18423, 1, INDEX_WHEREEVER, FLAG_NOLIMIT)	--	abiliyu remover
					end
	
	cid:getPosition():sendMagicEffect(35)
	setPlayerStorageValue(cid, 13544, os.time() + 120)
	bag:setAttribute(ITEM_ATTRIBUTE_NAME, "Boss Bag")
	doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "You found Boss Bag with rewards!")
	inbox:addItemEx(bag, INDEX_WHEREEVER, FLAG_NOLIMIT)
		else
		cid:sendTextMessage(MESSAGE_EVENT_ADVANCE, 'It is too heavy, min 100.')
		end
    else
        doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "Boss Chest is empty. Back tommorow.")
    end
end
--------------------------------------------------------------------------------------------------------
return true
end