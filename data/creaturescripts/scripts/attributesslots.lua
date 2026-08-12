function onExtendedOpcode(player, opcode, buffer)
    if opcode == ExtendedOPCodes.CODE_ATTRIBUTE_SLOTS then
      local status, json_data =
        pcall(
        function()
          return json.decode(buffer)
        end
      )
      if not status then
        return false
      end
	  
	  if json_data.action == "PARTY" then
		player:getPartyInfo()
		return true
	  end

      if json_data.action == "OPEN" then
local HELMET, ARMOR, BELT, LEGS, BOOTS, SHIELD, GLOVES, RING, RIGHT_RING,  NECKLACE,  WEAPON_MELEE,  ARTIFACT, WEAPON_DISTANCE ,  WEAPON_WAND,  WEAPON_ANY, PET  =  "","","","","","","","","","","","","","","",""
for i = 1, #US_ENCHANTMENTS do
	for x = 1, #US_ENCHANTMENTS[i].itemSlot do
		local value = US_ENCHANTMENTS[i].VALUES_PER_LEVELMAX
			if US_ENCHANTMENTS[i].itemSlot[x] == "US_ITEM_TYPES.HELMET" then
				local atr = US_ENCHANTMENTS[i].itemSlot[x]
				local bootsName = US_ENCHANTMENTS[i].format(value)
				HELMET = HELMET .. "\n" .. bootsName
			end
			if US_ENCHANTMENTS[i].itemSlot[x] == "US_ITEM_TYPES.ARMOR" then
				local atr = US_ENCHANTMENTS[i].itemSlot[x]
				local bootsName = US_ENCHANTMENTS[i].format(value)
				ARMOR = ARMOR .. "\n" .. bootsName
			end
			if US_ENCHANTMENTS[i].itemSlot[x] == "US_ITEM_TYPES.BELT" then
				local atr = US_ENCHANTMENTS[i].itemSlot[x]
				local bootsName = US_ENCHANTMENTS[i].format(value)
				BELT = BELT .. "\n" .. bootsName
			end
			if US_ENCHANTMENTS[i].itemSlot[x] == "US_ITEM_TYPES.LEGS" then
				local atr = US_ENCHANTMENTS[i].itemSlot[x]
				local bootsName = US_ENCHANTMENTS[i].format(value)
				LEGS = LEGS .. "\n" .. bootsName
			end
			if US_ENCHANTMENTS[i].itemSlot[x] == "US_ITEM_TYPES.BOOTS" then
				local atr = US_ENCHANTMENTS[i].itemSlot[x]
				local bootsName = US_ENCHANTMENTS[i].format(value)
				BOOTS = BOOTS .. "\n" .. bootsName
			end
			if US_ENCHANTMENTS[i].itemSlot[x] == "US_ITEM_TYPES.SHIELD" then
				local atr = US_ENCHANTMENTS[i].itemSlot[x]
				local bootsName = US_ENCHANTMENTS[i].format(value)
				SHIELD = SHIELD .. "\n" .. bootsName
			end
			if US_ENCHANTMENTS[i].itemSlot[x] == "US_ITEM_TYPES.GLOVES" then
				local atr = US_ENCHANTMENTS[i].itemSlot[x]
				local bootsName = US_ENCHANTMENTS[i].format(value)
				GLOVES = GLOVES .. "\n" .. bootsName
			end
			if US_ENCHANTMENTS[i].itemSlot[x] == "US_ITEM_TYPES.RING" then
				local atr = US_ENCHANTMENTS[i].itemSlot[x]
				local bootsName = US_ENCHANTMENTS[i].format(value)
				RING = RING .. "\n" .. bootsName
			end
			if US_ENCHANTMENTS[i].itemSlot[x] == "US_ITEM_TYPES.RIGHT_RING" then
				local atr = US_ENCHANTMENTS[i].itemSlot[x]
				local bootsName = US_ENCHANTMENTS[i].format(value)
				RIGHT_RING = RIGHT_RING .. "\n" .. bootsName
			end
			if US_ENCHANTMENTS[i].itemSlot[x] == "US_ITEM_TYPES.NECKLACE" then
				local atr = US_ENCHANTMENTS[i].itemSlot[x]
				local bootsName = US_ENCHANTMENTS[i].format(value)
				NECKLACE = NECKLACE .. "\n" .. bootsName
			end
			if US_ENCHANTMENTS[i].itemSlot[x] == "US_ITEM_TYPES.WEAPON_MELEE" then
				local atr = US_ENCHANTMENTS[i].itemSlot[x]
				local bootsName = US_ENCHANTMENTS[i].format(value)
				WEAPON_MELEE = WEAPON_MELEE .. "\n" .. bootsName
			end
			if US_ENCHANTMENTS[i].itemSlot[x] == "US_ITEM_TYPES.WEAPON_DISTANCE" then
				local atr = US_ENCHANTMENTS[i].itemSlot[x]
				local bootsName = US_ENCHANTMENTS[i].format(value)
				if bootsName == "Double Shot" then
					bootsName = "Double Shot (Knifes and Bows only)"
				elseif bootsName == "Multi Shot +2" then
					bootsName = "Multi Shot +2 (Crossbows only)"
				end
				WEAPON_DISTANCE = WEAPON_DISTANCE .. "\n" .. bootsName
			end
			if US_ENCHANTMENTS[i].itemSlot[x] == "US_ITEM_TYPES.WEAPON_WAND" then
				local atr = US_ENCHANTMENTS[i].itemSlot[x]
				local bootsName = US_ENCHANTMENTS[i].format(value)
				WEAPON_WAND = WEAPON_WAND .. "\n" .. bootsName
			end
			if US_ENCHANTMENTS[i].itemSlot[x] == "US_ITEM_TYPES.ARTIFACT" then
				local atr = US_ENCHANTMENTS[i].itemSlot[x]
				local bootsName = US_ENCHANTMENTS[i].format(value)
				ARTIFACT = ARTIFACT .. "\n" .. bootsName
			end
			if US_ENCHANTMENTS[i].itemSlot[x] == "US_ITEM_TYPES.WEAPON_ANY" then
				local atr = US_ENCHANTMENTS[i].itemSlot[x]
				local bootsName = US_ENCHANTMENTS[i].format(value)
				WEAPON_ANY = WEAPON_ANY .. "\n" .. bootsName
			end
			if US_ENCHANTMENTS[i].itemSlot[x] == "US_ITEM_TYPES.PET" then
				local atr = US_ENCHANTMENTS[i].itemSlot[x]
				local bootsName = US_ENCHANTMENTS[i].format(value)
				PET = PET .. "\n" .. bootsName
			end
			
		end
	end
local slots = {
	HELMET = HELMET,
	ARMOR = ARMOR,
	BELT = BELT,
	LEGS = LEGS,
	BOOTS = BOOTS, 
	SHIELD = SHIELD, 
	GLOVES = GLOVES,
	RING = RING,
	RIGHT_RING = RIGHT_RING, 
	NECKLACE = NECKLACE,
	WEAPON_MELEE = WEAPON_MELEE, 
	WEAPON_DISTANCE = WEAPON_DISTANCE ,
	WEAPON_WAND = WEAPON_WAND, 
	ARTIFACT = ARTIFACT,
	WEAPON_ANY = WEAPON_ANY,
	PET = PET
}

player:sendExtendedOpcode(ExtendedOPCodes.CODE_ATTRIBUTE_SLOTS, json.encode({slots = slots}))
		end
	end
end