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
     player:sendTextMessage(MESSAGE_STATUS_WARNING, "Sorry, this item is mirrored and can't be modified!")
     player:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
     return true
	end

     if target:getRarityId() <= 3 and target:getMaxAttributes() <= 4 then
          local attrIds = {}
          if target:getRarityId() <= 2 then
               target:setRarity(target:getRarityId() + 1)
          end
          if target:getRarityId() == 3 then
               target:setModifiersSlots(3 + 1)
          end
          local bonuses = target:getBonusAttributes()
          if bonuses then
               local slotsExtra = target:getMaxAttributes()
               if #bonuses >= slotsExtra then
                    player:say("Max attributes!", TALKTYPE_MONSTER_SAY)
                    player:getPosition():sendMagicEffect(CONST_ME_GROUNDSHAKER)
                    return false
               end
               for v, k in pairs(bonuses) do
                    table.insert(attrIds, k[1])
               end
          end
          local usItemType = target:getItemType()
          local attrId = math.random(1, #US_ENCHANTMENTS)
          local attr = US_ENCHANTMENTS[attrId]
          while isInArray(attrIds, attrId) or bit.band(usItemType, attr.itemType) == 0 or
               attr.chance and math.random(100) >= attr.chance do
               attrId = math.random(1, #US_ENCHANTMENTS)
               attr = US_ENCHANTMENTS[attrId]
          end

          local HPMPmin = 0
          local HPMPmax = 0
          local exaltedAttr = 0
          local tierAttributeRandom = math.random(1, 2)
          if player:getLevel() >= 1500 and player:getLevel() <= 900 then
               tierAttributeRandom = math.random(1, 5)
          elseif player:getLevel() >= 899 and player:getLevel() <= 600 then
               tierAttributeRandom = math.random(1, 4)
          elseif player:getLevel() >= 599 and player:getLevel() <= 300 then
               tierAttributeRandom = math.random(1, 3)
          end
          if player:getLevel() >= 750 and math.random(100) <= 50 then
               exaltedAttr = 1
               if math.random(100) <= 10 then
                    tierAttributeRandom = 7
               else
                    tierAttributeRandom = 6
               end
          end
          if REDUCTION_ATTR_VALUES[attrId] then
               if target:getTier() >= 0 then
                    HPMPmin = math.ceil(REDUCTION_ATTR_VALUES[attrId][tierAttributeRandom][1])
                    HPMPmax = math.ceil(REDUCTION_ATTR_VALUES[attrId][tierAttributeRandom][2])
               end
          end
          local value = math.random(HPMPmin, HPMPmax)
          if value <= 0 then value = 1 end
          local removePotencial = math.random(1,9)
          local itemPotencial = target:getForgePotencial()
          if itemPotencial > 0 then
               local summary = itemPotencial - removePotencial
               if summary < 0 then summary = 0 end
               target:setForgePotencial(summary)
               target:setCustomAttribute("Slot" .. target:getLastSlot() + 1, attrId .. "|" .. value .. "|" .. tierAttributeRandom .. "|" .. exaltedAttr)
          else
               player:sendTextMessage(MESSAGE_STATUS_WARNING, "You item dont have forge potencial!")
          end
          player:sendExtendedOpcode(105, json.encode({ reload = "reload" }))
     else
          player:sendTextMessage(MESSAGE_STATUS_WARNING, "Sorry, rarity!")
     end

 return true
end