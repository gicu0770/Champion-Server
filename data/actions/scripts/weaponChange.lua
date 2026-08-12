
 
function onUse(player, item, fromPosition, itemEx, toPosition, isHotkey)
local voc = player:getVocation():getId()
-- Archer
	local tansformDOne = false
	local vocArcher = {3,7,11,15}
	local vocShadow = {21,22,23,24}
	if player:isArcher() or player:isShadow() then
	local values = itemEx:getBonusAttributes()
     if values then
      for key, value in pairs(values) do
      value[1] = value[1]
      value[2] = value[2]
      local attr = US_ENCHANTMENTS[value[1]]
       if attr then
        if attr.name == "Multi Shot" and value[2] >= 2 then
	     player:sendTextMessage(MESSAGE_INFO_DESCR,"The crossbow has a multi shot change to a bow is not available because the bow has a different double shot attribute..")
	    return false  
       end
      end
     end
     end
	end
	if player:isArcher() then
	-- T1 Bow
    if itemEx.itemid == 26502 then
		itemEx:transform(25523)
		tansformDOne = true
	elseif itemEx.itemid == 25523 then
		itemEx:transform(26502)
		tansformDOne = true
	end
	-- T2 Bow
    if itemEx.itemid == 22418 then
		itemEx:transform(22421)
		tansformDOne = true
	elseif itemEx.itemid == 22421 then
		itemEx:transform(22418)
		tansformDOne = true
	end
	-- T3 Bow
    if itemEx.itemid == 26536 then
		itemEx:transform(26594)
		tansformDOne = true
	elseif itemEx.itemid == 26594 then
		itemEx:transform(26536)
		tansformDOne = true
	end
	-- T4 Bow
    if itemEx.itemid == 8856 then
		itemEx:transform(15644)
		tansformDOne = true
	elseif itemEx.itemid == 15644 then
		itemEx:transform(8856)
		tansformDOne = true
	end	
	-- T5 Bow
    if itemEx.itemid == 26550 then
		itemEx:transform(16111)
		tansformDOne = true
	elseif itemEx.itemid == 16111 then
		itemEx:transform(26550)
		tansformDOne = true
	end		
	-- T6 Bow
    if itemEx.itemid == 36125 then
		itemEx:transform(36126)
		tansformDOne = true
	elseif itemEx.itemid == 36126 then
		itemEx:transform(36125)
		tansformDOne = true
	end		
	-- T7 Bow
    if itemEx.itemid == 35952 then
		itemEx:transform(35951)
		tansformDOne = true
	elseif itemEx.itemid == 35951 then
		itemEx:transform(35952)
		tansformDOne = true
	end	
	-- T8 Bow
    if itemEx.itemid == 35929 then
		itemEx:transform(35936)
		tansformDOne = true
	elseif itemEx.itemid == 35936 then
		itemEx:transform(35929)
		tansformDOne = true
	end	
	-- T9 Bow
    if itemEx.itemid == 37067 then
		itemEx:transform(37068)
		tansformDOne = true
	elseif itemEx.itemid == 37068 then
		itemEx:transform(37067)
		tansformDOne = true
	end	
	end
-- Shadow
	-- T1 Bow
	if player:isShadow() then
    if itemEx.itemid == 26502 then
		itemEx:transform(36675)
		tansformDOne = true
	elseif itemEx.itemid == 36675 then
		itemEx:transform(26502)
		tansformDOne = true
	end
	-- T2 Bow
    if itemEx.itemid == 22418 then
		itemEx:transform(36676)
		tansformDOne = true
	elseif itemEx.itemid == 36676 then
		itemEx:transform(22418)
		tansformDOne = true
	end
	-- T3 Bow
    if itemEx.itemid == 26536 then
		itemEx:transform(36677)
		tansformDOne = true
	elseif itemEx.itemid == 36677 then
		itemEx:transform(26536)
		tansformDOne = true
	end
	-- T4 Bow
    if itemEx.itemid == 8856 then
		itemEx:transform(36678)
		tansformDOne = true
	elseif itemEx.itemid == 36678 then
		itemEx:transform(8856)
		tansformDOne = true
	end	
	-- T5 Bow
    if itemEx.itemid == 26550 then
		itemEx:transform(36679)
		tansformDOne = true
	elseif itemEx.itemid == 36679 then
		itemEx:transform(26550)
		tansformDOne = true
	end		
	-- T6 Bow
    if itemEx.itemid == 36125 then
		itemEx:transform(36680)
		tansformDOne = true
	elseif itemEx.itemid == 36680 then
		itemEx:transform(36125)
		tansformDOne = true
	end		
	-- T7 Bow
    if itemEx.itemid == 35952 then
		itemEx:transform(36681)
		tansformDOne = true
	elseif itemEx.itemid == 36681 then
		itemEx:transform(35952)
		tansformDOne = true
	end	
	-- T8 Bow
    if itemEx.itemid == 37067 then
		itemEx:transform(37071)
		tansformDOne = true
	elseif itemEx.itemid == 37071 then
		itemEx:transform(37067)
		tansformDOne = true
	end	
	-- T9 Bow
    if itemEx.itemid == 37067 then
		itemEx:transform(37068)
		tansformDOne = true
	elseif itemEx.itemid == 37068 then
		itemEx:transform(37067)
		tansformDOne = true
	end	
	end
-- Knight
	-- T1 Bow
	if player:isKnight() then
    if itemEx.itemid == 26433 then
		itemEx:transform(26534)
		tansformDOne = true
	elseif itemEx.itemid == 26534 then
		itemEx:transform(26433)
		tansformDOne = true
	end
	-- T2 Bow
    if itemEx.itemid == 26418 then
		itemEx:transform(26420)
		tansformDOne = true
	elseif itemEx.itemid == 26420 then
		itemEx:transform(26418)
		tansformDOne = true
	end
	-- T3 Bow
    if itemEx.itemid == 26481 then
		itemEx:transform(23547)
		tansformDOne = true
	elseif itemEx.itemid == 23547 then
		itemEx:transform(26481)
		tansformDOne = true
	end
	-- T4 Bow
    if itemEx.itemid == 26611 then
		itemEx:transform(26589)
		tansformDOne = true
	elseif itemEx.itemid == 26589 then
		itemEx:transform(26611)
		tansformDOne = true
	end	
	-- T5 Bow
    if itemEx.itemid == 26656 then
		itemEx:transform(26648)
		tansformDOne = true
	elseif itemEx.itemid == 26648 then
		itemEx:transform(26656)
		tansformDOne = true
	end		
	-- T6 Bow
    if itemEx.itemid == 35776 then
		itemEx:transform(35774)
		tansformDOne = true
	elseif itemEx.itemid == 35774 then
		itemEx:transform(35776)
		tansformDOne = true
	end		
	-- T7 Bow
    if itemEx.itemid == 35745 then
		itemEx:transform(35743)
		tansformDOne = true
	elseif itemEx.itemid == 35743 then
		itemEx:transform(35745)
		tansformDOne = true
	end	
	-- T8 Bow
    if itemEx.itemid == 35695 then
		itemEx:transform(35693)
		tansformDOne = true
	elseif itemEx.itemid == 35693 then
		itemEx:transform(35695)
		tansformDOne = true
	end	
	-- T9 Bow
    if itemEx.itemid == 35705 then
		itemEx:transform(35703)
		tansformDOne = true
	elseif itemEx.itemid == 35703 then
		itemEx:transform(35705)
		tansformDOne = true
	end	
	end	
-- Paladin
	-- T1 Bow
	if player:isPaladin() then
    if itemEx.itemid == 26433 then
		itemEx:transform(26432)
		tansformDOne = true
	elseif itemEx.itemid == 26432 then
		itemEx:transform(26433)
		tansformDOne = true
	end
	-- T2 Bow
    if itemEx.itemid == 26418 then
		itemEx:transform(26419)
		tansformDOne = true
	elseif itemEx.itemid == 26419 then
		itemEx:transform(26418)
		tansformDOne = true
	end
	-- T3 Bow
    if itemEx.itemid == 26481 then
		itemEx:transform(7431)
		tansformDOne = true
	elseif itemEx.itemid == 7431 then
		itemEx:transform(26481)
		tansformDOne = true
	end
	-- T4 Bow
    if itemEx.itemid == 26611 then
		itemEx:transform(26614)
		tansformDOne = true
	elseif itemEx.itemid == 26614 then
		itemEx:transform(26611)
		tansformDOne = true
	end	
	-- T5 Bow
    if itemEx.itemid == 26656 then
		itemEx:transform(26642)
		tansformDOne = true
	elseif itemEx.itemid == 26642 then
		itemEx:transform(26656)
		tansformDOne = true
	end		
	-- T6 Bow
    if itemEx.itemid == 35776 then
		itemEx:transform(35777)
		tansformDOne = true
	elseif itemEx.itemid == 35777 then
		itemEx:transform(35776)
		tansformDOne = true
	end		
	-- T7 Bow
    if itemEx.itemid == 35745 then
		itemEx:transform(35746)
		tansformDOne = true
	elseif itemEx.itemid == 35746 then
		itemEx:transform(35745)
		tansformDOne = true
	end	
	-- T8 Bow
    if itemEx.itemid == 35695 then
		itemEx:transform(35696)
		tansformDOne = true
	elseif itemEx.itemid == 35696 then
		itemEx:transform(35695)
		tansformDOne = true
	end	
	-- T9 Bow
    if itemEx.itemid == 35705 then
		itemEx:transform(35706)
		tansformDOne = true
	elseif itemEx.itemid == 35706 then
		itemEx:transform(35705)
		tansformDOne = true
	end	
	end		
-- Sorcerer Druid
	-- T1 Bow
	if player:isSorcerer() or player:isDruid() then
    if itemEx.itemid == 26462 then
		itemEx:transform(26538)
		tansformDOne = true
	elseif itemEx.itemid == 26538 then
		itemEx:transform(26462)
		tansformDOne = true
	end
	-- T2 Bow
    if itemEx.itemid == 26551 then
		itemEx:transform(26631)
		tansformDOne = true
	elseif itemEx.itemid == 26631 then
		itemEx:transform(26551)
		tansformDOne = true
	end
	-- T3 Bow
    if itemEx.itemid == 26603 then
		itemEx:transform(26607)
		tansformDOne = true
	elseif itemEx.itemid == 26607 then
		itemEx:transform(26603)
		tansformDOne = true
	end
	-- T4 Bow
    if itemEx.itemid == 26544 then
		itemEx:transform(26468)
		tansformDOne = true
	elseif itemEx.itemid == 26468 then
		itemEx:transform(26544)
		tansformDOne = true
	end	
	-- T5 Bow
    if itemEx.itemid == 26630 then
		itemEx:transform(26604)
		tansformDOne = true
	elseif itemEx.itemid == 26604 then
		itemEx:transform(26630)
		tansformDOne = true
	end		
	-- T6 Bow
    if itemEx.itemid == 35946 then
		itemEx:transform(36248)
		tansformDOne = true
	elseif itemEx.itemid == 36248 then
		itemEx:transform(35946)
		tansformDOne = true
	end		
	-- T7 Bow
    if itemEx.itemid == 35945 then
		itemEx:transform(36249)
	elseif itemEx.itemid == 36249 then
		itemEx:transform(35945)
		tansformDOne = true
	end	
	-- T8 Bow
    if itemEx.itemid == 35727 then
		itemEx:transform(35941)
		tansformDOne = true
	elseif itemEx.itemid == 35941 then
		itemEx:transform(35727)
		tansformDOne = true
	end	
	-- T9 Bow
    if itemEx.itemid == 37072 then
		itemEx:transform(35758)
		tansformDOne = true
	elseif itemEx.itemid == 35758 then
		itemEx:transform(37072)
		tansformDOne = true
	end	
	end			
	if tansformDOne then
	item:remove(1)
	player:getPosition():sendMagicEffect(50)
	local weaponName = itemEx:getName()
	player:sendTextMessage(MESSAGE_INFO_DESCR,"You transform your weapon to "..weaponName.."!")
	else
	player:getPosition():sendMagicEffect(3)
	player:sendTextMessage(MESSAGE_INFO_DESCR,"You can only transform weapons with Tier and for you vocation.")
	return false
	end
	
    return true
end