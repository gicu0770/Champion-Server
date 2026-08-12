local UID = nil
local item = nil
local QUALITY = nil
local REOPEN = nil
local HIGH = nil
local MAX_UPGRED_BOOK = 20
local BOOK_QUALITY = 26806
local BOOK_RARITY = 1
local BOOK_DOWNGRADE = 26805
local BOOK_HIGH_QUALITY = 26804
local UPGRADE_QUALITY = {
  [1] = { COST = 5000, CHANCE = 100000},
  [2] = { COST = 5000, CHANCE = 100000},
  [3] = { COST = 10000, CHANCE = 100000},
  [4] = { COST = 10000, CHANCE = 100000},
  [5] = { COST = 10000, CHANCE = 950000},
  [6] = { COST = 15000, CHANCE = 95000},
  [7] = { COST = 15000, CHANCE = 95000},
  [8] = { COST = 15000, CHANCE = 90000},
  [9] = { COST = 20000, CHANCE = 85000},
  [10] = { COST = 20000, CHANCE = 85000},
  [11] = { COST = 20000, CHANCE = 80000},
  [12] = { COST = 25000, CHANCE = 80000},
  [13] = { COST = 25000, CHANCE = 75000},
  [14] = { COST = 25000, CHANCE = 75000},
  [15] = { COST = 30000, CHANCE = 70000},
  [16] = { COST = 30000, CHANCE = 65000},
  [17] = { COST = 30000, CHANCE = 60000},
  [18] = { COST = 35000, CHANCE = 55000},
  [19] = { COST = 35000, CHANCE = 50000},
  [20] = { COST = 35000, CHANCE = 50000},
  [21] = { COST = 40000, CHANCE = 50000},
  [22] = { COST = 40000, CHANCE = 45000},
  [23] = { COST = 40000, CHANCE = 45000},
  [24] = { COST = 45000, CHANCE = 45000},
  [25] = { COST = 45000, CHANCE = 40000},
  [26] = { COST = 45000, CHANCE = 40000},
  [27] = { COST = 50000, CHANCE = 40000},
  [28] = { COST = 50000, CHANCE = 35000},
  [29] = { COST = 50000, CHANCE = 35000},
  [30] = { COST = 50000, CHANCE = 30000},
}

local UPGRADE_RARITY = {
  [1] = { COST = 5000, CHANCE = 100000},
  [2] = { COST = 7000, CHANCE = 20000},
  [3] = { COST = 10000, CHANCE = 10000},
  [4] = { COST = 15000, CHANCE = 2500},
  [5] = { COST = 20000, CHANCE = 350},
  [6] = { COST = 30000, CHANCE = 200},
}

function onExtendedOpcode(player, opcode, buffer)
  if opcode == ExtendedOPCodes.CODE_UPGRADE_PLUS_ITEMS then
    local status, json_data =
    pcall(
      function()
        return json.decode(buffer)
      end
    )
    if not status then
      return false
    end
  
    if json_data.UID then
      UID = json_data.UID
      REOPEN = json_data.reopen
      QUALITY = json_data.quality
      HIGH = json_data.high or false
      local item = player:getItem(UID)
      if item then
        if item:getRealUID() == UID then
          for slot = CONST_SLOT_HEAD, CONST_SLOT_RING2 do
            local itemslot = player:getSlotItem(slot)
            if itemslot then
              if itemslot.uid == item.uid then
              SEND_INFO(player, "Error 24", "You can't use that on equipped item!")
              return
              end
            end
          end
          UPGRADE_(player)
        else
          SEND_INFO_(player, "Error", "Unexpected Error try again!")
          return
        end
      else
        SEND_INFO_(player, "Error", "Unexpected Error try again!")
        return
      end
    else
      HIGH = json_data.high or false
      QUALITY = json_data.quality
      pos = Position(json_data.pos.x, json_data.pos.y, json_data.pos.z, json_data.pos.stackpos)
      item = player:getItem(pos)
      for slot = CONST_SLOT_HEAD, CONST_SLOT_RING2 do
        local itemslot = player:getSlotItem(slot)
        if itemslot then
          if itemslot.uid == item.uid then
          SEND_INFO(player, "Error 24", "You can't use that on equipped item!")
          return
          end
        end
      end
      SEND_PANEL_(player)
    end
  end
end

function UPGRADE_(player)
  if item then
    local uid = item:getRealUID()
    local itemType = item:getType()
    local item_data = {
      uid = uid,
      clientId = itemType:getClientId()
    }

    for slot = CONST_SLOT_HEAD, CONST_SLOT_RING2 do
      local itemslot = player:getSlotItem(slot)
      if itemslot then
        if itemslot.uid == item_data.uid then
          SEND_INFO_(player, "Error", "You can't use that on equipped item!")
          return true
        end
      end
    end

--	if item:isAncient() or item:isPrimal_Ancient() or item:isEternal() then
--	  SEND_INFO(player, "Error 25", "You can't use that on ancient item!")
--	  return
--	end

    if item_data.uid == UID then
      if item:isUnidentified() then
        SEND_INFO_(player, "Error", "This item is Unidentified, use scroll on this item and try again!")
		    return
      else
        if QUALITY then
          BOOK = BOOK_QUALITY
          if HIGH then BOOK = BOOK_HIGH_QUALITY end
          if player:getItemCount(BOOK) == 0 then
            SEND_INFO_(player, "Error", "You don't have enough items!")
            return
          else
            player:removeItem(BOOK, 1)
          end

          if not player:removeTotalMoney(UPGRADE_QUALITY[item:isQuality()+1].COST) then
            SEND_INFO_(player, "Error", "You don't have enough money!")
            return
          end

          if math.random(100000) <= UPGRADE_QUALITY[item:isQuality()+1].CHANCE then
            item:setCustomAttribute("quality", item:isQuality()+1)
		--	item:updateAttributes(player)
            SEND_INFO_(player, "Successful", "The advancement of the Item was successful.")
			if player:isQuestActive(4) then
				player:updateQuest(4, 1)
				SEND_INFO(player, "Successful", "[Daily Quest]: Upgrade Complete!")
			end
          else
            if player:getItemCount(BOOK_DOWNGRADE) > 0 then
              player:removeItem(BOOK_DOWNGRADE, 1)
              SEND_INFO_(player, "Fail", "The refinement failed. The item was protected by Book of Downgrade.")
            else
              item:setCustomAttribute("quality", item:isQuality()-1)
              SEND_INFO_(player, "Fail", "The refinement failed.")
            end
          end
        else
          if player:getItemCount(BOOK_RARITY) == 0 then
            SEND_INFO_(player, "Error", "You don't have enough items!")
            return
          else
            player:removeItem(BOOK_RARITY, 1)
          end

          if not player:removeTotalMoney(UPGRADE_RARITY[item:getRarityId()+1].COST) then
            SEND_INFO_(player, "Error", "You don't have enough money!")
            return
          end

          if math.random(100000) <= UPGRADE_RARITY[item:getRarityId()+1].CHANCE then
            item:setCustomAttribute("rarity", item:getRarityId()+1)
			item:updateAttributes(player)
            SEND_INFO_(player, "Successful", "The advancement of the Item was successful.")
			if player:isQuestActive(4) then
				player:updateQuest(4, 1)
				SEND_INFO(player, "Successful", "[Daily Quest]: Upgrade Complete!")
			end
			if item:getRarity().name == "Heroic" then
			player:getPosition():sendMagicEffect(50)
			Game.broadcastMessage("Congratulations! "..player:getName().." discovered "..item:getRarity().name.." "..item:getName().."!", MESSAGE_STATUS_WARNING)
				for _, targetPlayer in ipairs(Game.getPlayers()) do
				targetPlayer:sendExtendedOpcode(71, json.encode({text = "Congratulations {"..player:getName().."} discovered {"..item:getRarity().name.."} "..item:getName().."!", color = "#FF0000"}))
				end
			end
			if item:getRarity().name == "Mythic" then
			player:getPosition():sendMagicEffect(50)
			Game.broadcastMessage("Congratulations! "..player:getName().." discovered "..item:getRarity().name.." "..item:getName().."!", MESSAGE_STATUS_WARNING)
				for _, targetPlayer in ipairs(Game.getPlayers()) do
				targetPlayer:sendExtendedOpcode(71, json.encode({text = "Congratulations {"..player:getName().."} discovered {"..item:getRarity().name.."} "..item:getName().."!", color = "#e6cc07"}))
				end
			end
			
          else
            SEND_INFO_(player, "Fail", "The refinement failed.")
          end
        end
      end
    end
  end
end

function SEND_PANEL_(player)
  if not item or not item:getType():isUpgradable() then
    return false
  end

  local itemType = item:getType()
  local item_data = {
	  uid = item:getRealUID(),
	  clientId = itemType:getClientId()
  }
    if item:isCorrupted() then
	 SEND_INFO(player, "Error", "Sorry, this item is corrupted and can't be modified!")
	 return
	end
  if QUALITY then
    if HIGH then
      if not UPGRADE_QUALITY[item:isQuality()+1] then
        SEND_INFO_(player, "Error", "This item is already on maximum upgrade level")
        return false
      end
      if item:isQuality()+1 <= MAX_UPGRED_BOOK then
        SEND_INFO_(player, "Error", "You can use this book only on +20% Qualiy.")
        return false
      end
    else
      if item:isQuality() >= MAX_UPGRED_BOOK then
        SEND_INFO_(player, "Error", "This item is already on maximum upgrade level")
        return false
      end
    end
  else

  end

  for slot = CONST_SLOT_HEAD, CONST_SLOT_RING2 do
    local itemslot = player:getSlotItem(slot)
    if itemslot then
      if itemslot.uid == item_data.uid then
        SEND_INFO_(player, "Error", "You can't use that on equipped item!")
        return true
      end
    end
  end

  item_data.bookq = player:getItemCount(BOOK_QUALITY)
  item_data.bookhq = player:getItemCount(BOOK_HIGH_QUALITY)
  item_data.bookr = player:getItemCount(BOOK_RARITY)
  item_data.bookd = player:getItemCount(BOOK_DOWNGRADE)
  item_data.itemName = item:getName()
  item_data.rarityId = item:getRarityId()
  item_data.quality = item:isQuality()
  item_data.balance = getPlayerMoney(player)
  item_data.high = HIGH
  if QUALITY then
    item_data.cost = UPGRADE_QUALITY[item_data.quality+1].COST
    item_data.chance = (UPGRADE_QUALITY[item_data.quality+1].CHANCE) / 1000
    player:sendExtendedOpcode(ExtendedOPCodes.CODE_UPGRADE_PLUS_ITEMS, json.encode({data = item_data, quality = true}))
  else
    item_data.cost = UPGRADE_RARITY[item_data.rarityId+1].COST
    item_data.chance = (UPGRADE_RARITY[item_data.rarityId+1].CHANCE) / 1000
    player:sendExtendedOpcode(ExtendedOPCodes.CODE_UPGRADE_PLUS_ITEMS, json.encode({data = item_data, quality = false}))
  end
end

function SEND_INFO_(player, title, msg)
  if title == "Error" then
    player:sendExtendedOpcode(ExtendedOPCodes.CODE_UPGRADE_PLUS_ITEMS, json.encode({title = title, msg = msg, quit = "1",}))
	return
  else
    if REOPEN == true then
    local item = player:getItem(UID)
    if item then
      if item:getRealUID() == UID then
        SEND_PANEL_(player)
      else
       SEND_INFO_(player, "Error", "Unexpected Error try again!")
      end
	  else
		  SEND_INFO_(player, "Error", "Unexpected Error try again!")
	  end
      player:sendExtendedOpcode(ExtendedOPCodes.CODE_UPGRADE_PLUS_ITEMS, json.encode({title = title, msg = msg}))
    else
      player:sendExtendedOpcode(ExtendedOPCodes.CODE_UPGRADE_PLUS_ITEMS, json.encode({title = title, msg = msg, quit = "1",}))
    end
  end
end

function getPlayerMoney(cid)
  local player = Player(cid)
  if player then
      return player:getMoney() + player:getBankBalance()
  end
  return false
end