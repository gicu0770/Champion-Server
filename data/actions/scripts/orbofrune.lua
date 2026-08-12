local raritys = {
	{2000, 3, 4}, -- Legendary
	{15000, 2, 3},-- Epic 
	{100000, 1, 2}, -- Rare
	{100000, 1, 1}, -- Common
}

function onUse(player, item, fromPosition, target, toPosition, isHotkey)
if item:getId() == 0 then return end	
	if not target or not target:isItem() or target:getSpellName() == "" then
     return false
	end

	SPELL_CACHE[target:getRealUID()] = nil
	player:sendExtendedOpcode(105, json.encode({ reload = "reload", spell = true }))
	if toPosition.y <= CONST_SLOT_POTION2 then
		player:sendTextMessage(MESSAGE_STATUS_WARNING, "You can't use that on equipped item!")
		player:say("You can't use that on equipped item!", TALKTYPE_MONSTER_SAY)
		player:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
		player:getPosition():sendMagicEffect(3)
		return true
	end

	if item.itemid ~= US_CONFIG.ITEM_SCROLL_IDENTIFY and target:isUnidentified() then
		player:say("Item is unidentified!", TALKTYPE_MONSTER_SAY)
		player:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
		player:getPosition():sendMagicEffect(3)
		return true
	end

	if target:isCorrupted() then
		player:say("Item is corrupted!", TALKTYPE_MONSTER_SAY)
		player:sendTextMessage(MESSAGE_STATUS_WARNING, "You can't use that on corrupted item!")
		player:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
		player:getPosition():sendMagicEffect(3)
		return true
	end

	if target:getRarity().name == "Divine" then
		player:say("Item is Divine!", TALKTYPE_MONSTER_SAY)
		player:sendTextMessage(MESSAGE_STATUS_WARNING, "You can't use that on Divine item!")
		player:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
		player:getPosition():sendMagicEffect(3)
		return true
	end

	math.randomseed(os.time())
	local rand = math.random(1, 100000)
	local rarity = 1
	local size = 0
	for i = 1, #raritys do
		if rand <= raritys[i][1] then
			rarity = raritys[i][3]
			size = raritys[i][2]
			break
		end
	end

	target:setRarity(rarity)
	player:say("Item has become "..target:getRarity().name.."", TALKTYPE_MONSTER_SAY)
	player:getPosition():sendMagicEffect(5)
	player:sendExtendedOpcode(105, json.encode({reload = "reload"}))
	item:remove(1)
 	return true
end