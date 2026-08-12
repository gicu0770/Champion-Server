return {
 {
    name = "Hand Portal",
    price = 300,
    tooltip = { "This purchase is for your account and is permanent. You will be able to equip it on all characters on this account.", "yellow" },
    item_id = 37101,
    portal = true,
    rarity = RARITYS_STORE.LIMITED,
    finish = function(player)
      return player:setAccountStorageValue(PlayerStorage.portals + 20, 1)
    end,
    check = function(player)
      return player:getAccountStorageValue(PlayerStorage.portals + 20) == 1
    end
  },
  {
    name = "Poison Portal",
    price = 200,
    tooltip = { "This purchase is for your account and is permanent. You will be able to equip it on all characters on this account.", "yellow" },
    item_id = 37100,
    portal = true,
    rarity = RARITYS_STORE.LEGENDARY,
    finish = function(player)
      return player:setAccountStorageValue(PlayerStorage.portals + 17, 1)
    end,
    check = function(player)
      return player:getAccountStorageValue(PlayerStorage.portals + 17) == 1
    end
  },
  {
    name = "Hell Gate",
    price = 200,
    tooltip = { "This purchase is for your account and is permanent. You will be able to equip it on all characters on this account.", "yellow" },
    item_id = 37108,
    portal = true,
    rarity = RARITYS_STORE.LEGENDARY,
    finish = function(player)
      return player:setAccountStorageValue(PlayerStorage.portals + 16, 1)
    end,
    check = function(player)
      return player:getAccountStorageValue(PlayerStorage.portals + 16) == 1
    end
  },
  {
    name = "Vortex Gate",
    price = 200,
    tooltip = { "This purchase is for your account and is permanent. You will be able to equip it on all characters on this account.", "yellow" },
    item_id = 34761,
    portal = true,
    rarity = RARITYS_STORE.LEGENDARY,
    finish = function(player)
      return player:setAccountStorageValue(PlayerStorage.portals + 15, 1)
    end,
    check = function(player)
      return player:getAccountStorageValue(PlayerStorage.portals + 15) == 1
    end
  },
  
  
  {
    name = "Arcane Conduit",
    price = 200,
    tooltip = { "This purchase is for your account and is permanent. You will be able to equip it on all characters on this account.", "yellow" },
    item_id = 34766,
    portal = true,
    rarity = RARITYS_STORE.RARE,
    finish = function(player)
      return player:setAccountStorageValue(PlayerStorage.portals + 14, 1)
    end,
    check = function(player)
      return player:getAccountStorageValue(PlayerStorage.portals + 14) == 1
    end
  },
  {
    name = "Crystal Gate",
    price = 200,
    tooltip = { "This purchase is for your account and is permanent. You will be able to equip it on all characters on this account.", "yellow" },
    item_id = 34762,
    portal = true,
    rarity = RARITYS_STORE.RARE,
    finish = function(player)
      return player:setAccountStorageValue(PlayerStorage.portals + 13, 1)
    end,
    check = function(player)
      return player:getAccountStorageValue(PlayerStorage.portals + 13) == 1
    end
  },
  
  
  {
    name = "Firelight Portal",
    price = 150,
    tooltip = { "This purchase is for your account and is permanent. You will be able to equip it on all characters on this account.", "yellow" },
    item_id = 37094,
    portal = true,
    rarity = RARITYS_STORE.MAGIC,
    finish = function(player)
      return player:setAccountStorageValue(PlayerStorage.portals + 12, 1)
    end,
    check = function(player)
      return player:getAccountStorageValue(PlayerStorage.portals + 12) == 1
    end
  },
  {
    name = "Otherworld Portal",
    price = 150,
    tooltip = { "This purchase is for your account and is permanent. You will be able to equip it on all characters on this account.", "yellow" },
    item_id = 29724,
    portal = true,
    rarity = RARITYS_STORE.MAGIC,
    finish = function(player)
      return player:setAccountStorageValue(PlayerStorage.portals + 10, 1)
    end,
    check = function(player)
      return player:getAccountStorageValue(PlayerStorage.portals + 10) == 1
    end
  },
  {
    name = "Blue Fiery Portal",
    price = 150,
    tooltip = { "This purchase is for your account and is permanent. You will be able to equip it on all characters on this account.", "yellow" },
    item_id = 31101,
    portal = true,
    rarity = RARITYS_STORE.MAGIC,
    finish = function(player)
      return player:setAccountStorageValue(PlayerStorage.portals + 9, 1)
    end,
    check = function(player)
      return player:getAccountStorageValue(PlayerStorage.portals + 9) == 1
    end
  },
  {
    name = "Gold Fiery Portal",
    price = 150,
    tooltip = { "This purchase is for your account and is permanent. You will be able to equip it on all characters on this account.", "yellow" },
    item_id = 31100,
    portal = true,
    rarity = RARITYS_STORE.MAGIC,
    finish = function(player)
      return player:setAccountStorageValue(PlayerStorage.portals + 8, 1)
    end,
    check = function(player)
      return player:getAccountStorageValue(PlayerStorage.portals + 8) == 1
    end
  },
  {
    name = "Red Fiery Portal",
    price = 150,
    tooltip = { "This purchase is for your account and is permanent. You will be able to equip it on all characters on this account.", "yellow" },
    item_id = 38160,
    portal = true,
    rarity = RARITYS_STORE.MAGIC,
    finish = function(player)
      return player:setAccountStorageValue(PlayerStorage.portals + 7, 1)
    end,
    check = function(player)
      return player:getAccountStorageValue(PlayerStorage.portals + 7) == 1
    end
  },
  
 
  {
    name = "Gray Portal",
    price = 100,
    tooltip = { "This purchase is for your account and is permanent. You will be able to equip it on all characters on this account.", "yellow" },
    item_id = 28294,
    portal = true,
    rarity = RARITYS_STORE.COMMON,
    finish = function(player)
      return player:setAccountStorageValue(PlayerStorage.portals + 6, 1)
    end,
    check = function(player)
      return player:getAccountStorageValue(PlayerStorage.portals + 6) == 1
    end
  },
  {
    name = "Green Portal",
    price = 100,
    tooltip = { "This purchase is for your account and is permanent. You will be able to equip it on all characters on this account.", "yellow" },
    item_id = 28296,
    portal = true,
    rarity = RARITYS_STORE.COMMON,
    finish = function(player)
      return player:setAccountStorageValue(PlayerStorage.portals + 5, 1)
    end,
    check = function(player)
      return player:getAccountStorageValue(PlayerStorage.portals + 5) == 1
    end
  },
  {
    name = "Purple Portal",
    price = 100,
    tooltip = { "This purchase is for your account and is permanent. You will be able to equip it on all characters on this account.", "yellow" },
    item_id = 28298,
    portal = true,
    rarity = RARITYS_STORE.COMMON,
    finish = function(player)
      return player:setAccountStorageValue(PlayerStorage.portals + 4, 1)
    end,
    check = function(player)
      return player:getAccountStorageValue(PlayerStorage.portals + 4) == 1
    end
  },
  {
    name = "Golden Portal",
    price = 100,
    tooltip = { "This purchase is for your account and is permanent. You will be able to equip it on all characters on this account.", "yellow" },
    item_id = 28302,
    portal = true,
    rarity = RARITYS_STORE.COMMON,
    finish = function(player)
      return player:setAccountStorageValue(PlayerStorage.portals + 3, 1)
    end,
    check = function(player)
      return player:getAccountStorageValue(PlayerStorage.portals + 3) == 1
    end
  },
  {
    name = "Fire Portal",
    price = 100,
    tooltip = { "This purchase is for your account and is permanent. You will be able to equip it on all characters on this account.", "yellow" },
    item_id = 28300,
    portal = true,
    rarity = RARITYS_STORE.COMMON,
    finish = function(player)
      return player:setAccountStorageValue(PlayerStorage.portals + 2, 1)
    end,
    check = function(player)
      return player:getAccountStorageValue(PlayerStorage.portals + 2) == 1
    end
  },
  {
    name = "Purplelight Essence",
    price = 50,
    tooltip = { "This purchase is for your account and is permanent. You will be able to equip it on all characters on this account.", "yellow" },
    item_id = 37093,
    portal = true,
    rarity = RARITYS_STORE.NORMAL,
    finish = function(player)
      return player:setAccountStorageValue(PlayerStorage.portals + 11, 1)
    end,
    check = function(player)
      return player:getAccountStorageValue(PlayerStorage.portals + 11) == 1
    end
  },
}
