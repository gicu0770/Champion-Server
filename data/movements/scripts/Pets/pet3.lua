local storage = 6666670

local PetOutfits = {
	[1] = 313,
	[2] = 68,
	[3] = 321,
	[4] = 323,
	[5] = 333,
	[6] = 78,
}

function onEquip(cid, item, slot)
	local position = cid:getPosition()
    RemovePets(cid)
	monster = Game.createMonster("pet", Position(2000, 2000, 7), true, true)
	if monster then
		local outfit = monster:getOutfit()

		if cid:getStorageValue(storage+1) > 100 then
			monster:setSkull(cid:getStorageValue(storage+1))
		else
			cid:setStorageValue(storage+1, 100)
			monster:setSkull(100)
		end

		if cid:getStorageValue(storage) > 0 then
			outfit.lookType = PetOutfits[cid:getStorageValue(storage)]
			monster:setOutfit(outfit)
		else
			outfit.lookType = PetOutfits[1]
			monster:setOutfit(outfit)
		end

		setCreatureName(monster, cid:getName().."'s pet", "description")
		cid:addSummon(monster)
		position:sendMagicEffect(CONST_ME_MAGIC_RED)
		local deltaSpeed = math.max(cid:getSpeed() - monster:getBaseSpeed(), 0)
		monster:changeSpeed(deltaSpeed)
		monster:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
		monster:teleportTo(position)
		monster:registerEvent("PetTeleport")

		outfit = monster:getOutfit()
		cid:sendExtendedOpcode(ExtendedOPCodes.CODE_PETS, json.encode({itemid = item:getType():getClientId(), action = "first", storage = storage, outfit = PetOutfits, coutfit = outfit, soutfit = cid:getStorageValue(storage), shader = cid:getStorageValue(storage+1)}))
        return true
	end
	return false
end	
 
function onDeEquip(cid, item, slot)
    RemovePets(cid)
	return true
end