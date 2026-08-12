local DAILY_REWARDS = {
    {
       item = {
       ServerID = 0,
       ClientID = 3043,
       Count = 1,
       Description = "Crystal Coin"
       }
   },
   {
       item = {
       ServerID = 26532,
       ClientID = 23876,
       Count = 25,
       Description = "Scroll of Identification\nCan be used on unidentified item to reveal hidden attributes."
       }
   },
   {
       item = {
       ServerID = 26555,
       ClientID = 23899,
       Count = 5,
       Description = "Upgrade Crystal\nCan be used on a piece of equipment for a chance to upgrade it."
       }
   },
    {
       item = {
       ServerID = 24850,
       ClientID = 22194,
       Count = 70,
       Description = "Crystal Fossil\nThere is unknown crystal inside, try to use crystal extractor."
       }
   },
   {
       item = {
       ServerID = 21250,
       ClientID = 18933,
       Count = 50,
       Description = "Book Fragment\nCraft material. You can craft Upgrades Books with this fragments."
       }
   },
   {
       item = {
       ServerID = 26805,
       ClientID = 24149,
       Count = 2,
       Description = "Book Of Downgrade\nItem protected from downgrade."
       }
   },
    {
       item = {
       ServerID = nil,									-- DZIEN 7 EXP
       ClientID = 33741,
       Count = 5,
       Description = "Exp Boost for 1.5h (if PACC 3h). This boost start with claim reward!!!"
       }
   },
   {
       item = {
       ServerID = 0,
       ClientID = 3043,
       Count = 100,
       Description = "Crystal Coin"
       }
   },
   {
       item = {
       ServerID = 26532,
       ClientID = 23876,
       Count = 200,
       Description = "Scroll of Identification\nCan be used on unidentified item to reveal hidden attributes."
       }
   },
    {
       item = {
       ServerID = 24850,
       ClientID = 22194,
       Count = 200,
       Description = "Crystal Fossil\nThere is unknown crystal inside, try to use crystal extractor."
       }
   },
    {
       item = {
       ServerID = 24850,
       ClientID = 22194,
       Count = 300,
       Description = "Crystal Fossil\nThere is unknown crystal inside, try to use crystal extractor."
       }
   },
   {
       item = {
       ServerID = 26805,
       ClientID = 24149,
       Count = 10,
       Description = "Book Of Downgrade\nItem protected from downgrade."
       }
   },
     {
       item = {
       ServerID = 24850,
       ClientID = 22194,
       Count = 300,
       Description = "Crystal Fossil\nThere is unknown crystal inside, try to use crystal extractor."
       }
   },
    {
       item = {
       ServerID = nil,									-- DZIEN 14 EXP
       ClientID = 33741,
       Count = 1,
       Description = "Exp Boost for 1.5h (if PACC 3h) This boost start with claim reward!!!"
       }
   },
   {
       item = {
       ServerID = 0,
       ClientID = 3043,
       Count = 300,
       Description = "Crystal Coin"
       }
   },
   {
       item = {
       ServerID = 26527,
       ClientID = 23871,
       Count = 1,
       Description = "Perfect Faith Crystals\nCan be used on a piece of equipment to change values of all attributes."
       }
   },
   {
       item = {
       ServerID = 21250,
       ClientID = 18933,
       Count = 300,
       Description = "Book Fragment\nCraft material. You can craft Upgrades Books with this fragments."
       }
   },
  {
       item = {
       ServerID = 36671,
       ClientID = 34015,
       Count = 5,
       Description = "Lucky Upgrade Crystal \nUpgrade Crystal with extra upgrade chance +10%."
       }
   },
  {
       item = {
       ServerID = 26805,
       ClientID = 24149,
       Count = 10,
       Description = "Book Of Downgrade\nItem protected from downgrade."
       }
   },	
  {
       item = {
       ServerID = 36671,
       ClientID = 34015,
       Count = 10,
       Description = "Book Of Ability\nUse on an item to discover a secret ability. Reusing increases the ability level."
       }
   },	
    {
       item = {
       ServerID = nil,									-- DZIEN 21 EXP
       ClientID = 33741,
       Count = 1,
       Description = "Exp Boost for 1.5h (if PACC 3h) This boost start with claim reward!!!"
       }
   },
  {
       item = {
       ServerID = 0,
       ClientID = 3043,
       Count = 500,
       Description = "Crystal Coin"
       }
   },
   {
       item = {
       ServerID = 24850,
       ClientID = 22194,
       Count = 400,
       Description = "Crystal Fossil\nThere is unknown crystal inside, try to use crystal extractor."
       }
   },
   {
       item = {
       ServerID = 26803,
       ClientID = 24147,
       Count = 10,
       Description = "Book Of Corruption\nItem that will corrupt an item, causing unpredictable and possibly powerful results. Once an item is corrupted, its stats no longer be modified by any other upgrade items. A successful attempt adds an additional Attribute Slot, but a failed attempt removes all Attributes from the item."
       }
   },
  {
       item = {
       ServerID = 18423,
       ClientID = 16129,
       Count = 10,
       Description = "Crystal of Oblivion\nRe-draws an item ability."
       }
   },
  {
       item = {
       ServerID = 36671,
       ClientID = 34015,
       Count = 20,
       Description = "Lucky Upgrade Crystal\nUpgrade Crystal with extra upgrade chance +10%"
       }
   },
  {
       item = {
       ServerID = 26803,
       ClientID = 24147,
       Count = 10,
       Description = "Book Of Ability\nUse on an item to discover a secret ability. Reusing increases the ability level."
       }
   },
   {
       item = {
       ServerID = nil,									-- DZIEN 28 EXP
       ClientID = 33741,
       Count = 1,
       Description = "Exp Boost for 1.5h (if PACC 3h) This boost start with claim reward!!!"
       }
   }
}
 

function onExtendedOpcode(player, opcode, buffer)
   if opcode == ExtendedOPCodes.CODE_DAILY_REWARDS then
     local status, json_data =
       pcall(
       function()
         return json.decode(buffer)
       end
     )
     if not status then
       return false
     end
     
     PassLevel = nil
     
       local reward = getDailyRewards(player)
       local day = getDay(player)
     if json_data.action == "OPEN" then
       player:sendExtendedOpcode(ExtendedOPCodes.CODE_DAILY_REWARDS, json.encode({myData = DAILY_REWARDS}))
       player:sendExtendedOpcode(ExtendedOPCodes.CODE_DAILY_REWARDS, json.encode({reward = reward}))
       player:sendExtendedOpcode(ExtendedOPCodes.CODE_DAILY_REWARDS, json.encode({day = day}))
     end
     
if json_data.ID then
   PassLevel = json_data.ID
end

   local DailyRewards = getDailyRewards(player)
   local day = getDay(player)
   if DailyRewards == 0 then
   for i = 1, #DAILY_REWARDS do
       if i == PassLevel then
           if PassLevel == 7 or PassLevel == 14 or PassLevel == 21 or PassLevel == 28 and player:isPremium() then --- daily exp
               player:setStorageValue(PlayerStorage.expDaily, os.time() + 10800)
               player:sendExtendedOpcode(71, json.encode({text = "Your {3} hours of {30}% XP has started", color = "#f7ef8a"}))
               player:addBuff(BUFF_EXP_DAILY)
               ExpShowTotal(player)
           elseif PassLevel == 7 or PassLevel == 14 or PassLevel == 21 or PassLevel == 28 and not player:isPremium() then
               player:setStorageValue(PlayerStorage.expDaily, os.time() + 5400)
               player:sendExtendedOpcode(71, json.encode({text = "Your {1.5} hours of {30}% XP has started", color = "#f7ef8a"}))
               player:addBuff(BUFF_EXP_DAILY)
               ExpShowTotal(player)		
           end --- daily exp
           if PassLevel == 1 or PassLevel == 8 or PassLevel == 15 or PassLevel == 22 and player:isPremium() then --- daily exp
               local gold = (DAILY_REWARDS[i].item.Count * 2) * 10000
               player:setBankBalance(player:getBankBalance() + gold)
               player:refreshBalance()
               player:sendExtendedOpcode(71, json.encode({text = "Daily reward received: "..gold.." gold", color = "#f7ef8a"}))
           elseif PassLevel == 1 or PassLevel == 8 or PassLevel == 15 or PassLevel == 22 and not player:isPremium() then
               local gold2 = DAILY_REWARDS[i].item.Count * 10000
               player:setBankBalance(player:getBankBalance() + gold2)
               player:refreshBalance()
               player:sendExtendedOpcode(71, json.encode({text = "Daily reward received: "..gold2.." gold", color = "#f7ef8a"}))
           end --- money
       if PassLevel == 7 or PassLevel == 14 or PassLevel == 21 or PassLevel == 28 then
       else
           local bag = Game.createItem(28901, 1)
       local inbox = player:getInbox()
           local count = DAILY_REWARDS[i].item.Count
		   local rewardSave = DAILY_REWARDS[i].item.Count
		   local rewardSave2 = DAILY_REWARDS[i].item.ServerID
           if player:isPremium() then count = count * 2 end
           if count > 100 then
               count = count / 100
           else
               count = 1
           end
		   if rewardSave < 100 then
			if player:isPremium() then
				rewardSave = rewardSave * 2
			end
		   end
       for i = 1, count do
           bag:addItem(rewardSave2, rewardSave, INDEX_WHEREEVER, FLAG_NOLIMIT)
       end
           local rew = DAILY_REWARDS[i].item.ServerID
           local rewName = ItemType(DAILY_REWARDS[i].item.ServerID):getName()
           local countPremium = 0
           if player:isPremium() then
           countPremium = (DAILY_REWARDS[i].item.Count * 2)
           elseif not player:isPremium() then
           countPremium = DAILY_REWARDS[i].item.Count
           end
           if PassLevel == 26 then
               if player:isPremium() then
                   local rewAction = bag:addItem(DAILY_REWARDS[i].item.ServerID, DAILY_REWARDS[i].item.Count, INDEX_WHEREEVER, FLAG_NOLIMIT)
               end
           end
       if PassLevel == 1 or PassLevel == 8 or PassLevel == 15 or PassLevel == 22 then
       else
       inbox:addItemEx(bag, INDEX_WHEREEVER, FLAG_NOLIMIT)
       player:sendExtendedOpcode(71, json.encode({text = "Daily reward received: {"..rewName.."} x"..countPremium.."\nCheck your depot inbox.", color = "#f7ef8a"}))
       end
       end
       setDailyRewards(player, 1)
       setDay(player, day + 1)
       end
   end
end


    
    
   end
 end