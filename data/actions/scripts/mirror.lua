function onUse(player, item, fromPosition, target, toPosition, isHotkey)
if item:getId() == 0 then return end	
	if not target or not target:isItem() or not target:getType():isUpgradable() then
     return false
	end
	
	if toPosition.y <= CONST_SLOT_RING2 then
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
	
	if target:isMirrored() then
     player:sendTextMessage(MESSAGE_STATUS_WARNING, "Sorry, this item is mirrored and can't be mirrored again!")
     player:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
     return true
	end
	

 local itemType = ItemType(target.itemid)
 local weaponType = itemType:getWeaponType()
if formatItemTypeUPGRADE(itemType) == "Pet" then
 player:sendTextMessage(MESSAGE_INFO_DESCR, "Pet cannot be copied.")
 player:say("Pet cannot be copied.", TALKTYPE_MONSTER_SAY)
 return true
end

local copy = Game.createItem(target:getId(), 1)
if copy then
if target:isPA() then
 copy:setCustomAttribute("PA", target:isPA())
 copy:setCustomAttribute("PA_Level", target:getCustomAttribute("PA_Level"))
 copy:setCustomAttribute("PAdesc", target:isPA())
end
copy:setRarity(target:getRarityId())
copy:setQuality(target:isQuality())
copy:setTier(target:getTier())
copy:setItemLevel(target:getItemLevel())
if target:isInfluenced() then copy:setInfluenced(target:getInfluenced()) end
if target:isLevelReq() then copy:setLevelReq(target:getLevelReq()) end
if target:isSoulShard() then copy:setSoulShard(target:getSoulShard()) copy:setSoulShardLevel(target:getSoulShardLevel()) copy:setEmptySlotItem(1) end
if target:isDungeonItem() then copy:setDungeonItem(target:getDungeonItem()) end
if target:isClassItem() then copy:setClassItem(target:getClassItem()) copy:setClassItemLevel(target:getClassItemLevel()) end
if target:isCraftBonus() then copy:setCraftBonus(target:getCraftBonus()) end
if target:isVocationReq() then copy:setVocationReq(target:getVocationReq()) end
if target:isImplicit() then copy:setImplicit(target:getImplicit()) end
if target:isAncient() then copy:setAncient(target:getAncient()) end
if target:isPrimal_Ancient() then copy:setPrimalAncient(target:getPrimal_Ancient()) end
if target:isEternal() then copy:setEternal(target:getEternal()) end
if target:bindItem() then copy:setbindItem(target:bindItem()) end
copy:setUpgradeLevel(target:getUpgradeLevel())
if target:getBonusAttributes() then
 for i = 1, target:getMaxAttributes() do
   local attr = target:getBonusAttribute(i)
   if attr then
    copy:addAttribute(i, attr[1], attr[2])
   end
 end
end
copy:setMirrored(1)
-- local accointID = player:getAccountId()
-- copy:setbindCharacterItem(accointID)


 if itemType:getArmor() > 0 then
  copy:setAttribute(ITEM_ATTRIBUTE_ARMOR, target:getAttribute(ITEM_ATTRIBUTE_ARMOR))
 end
 if itemType:getAttack() > 0 then
  copy:setAttribute(ITEM_ATTRIBUTE_ATTACK, target:getAttribute(ITEM_ATTRIBUTE_ATTACK))
 end

 if player:addItemEx(copy) == RETURNVALUE_NOERROR then
-- target:setMirrored(1)
 item:remove(1)
 end
end

 return true
end