return {
  {
    name = "Void Skull",
    price = 200,
    tooltip = { "This purchase is for your account and is permanent. You will be able to equip it on all characters on this account.", "yellow" },
    effect = 666,
    rarity = RARITYS_STORE.LIMITED,
    finish = function(player)
      return player:setAccountStorageValue(PlayerStorage.footPrints + 37, 1)
    end,
    check = function(player)
      return player:getAccountStorageValue(PlayerStorage.footPrints + 37) == 1
    end
  },
  {
    name = "Void Steps",
    price = 200,
    tooltip = { "This purchase is for your account and is permanent. You will be able to equip it on all characters on this account.", "yellow" },
    effect = 668,
    rarity = RARITYS_STORE.LIMITED,
    finish = function(player)
      return player:setAccountStorageValue(PlayerStorage.footPrints + 36, 1)
    end,
    check = function(player)
      return player:getAccountStorageValue(PlayerStorage.footPrints + 36) == 1
    end
  },
  {
    name = "Dark Hand",
    price = 150,
    tooltip = { "This purchase is for your account and is permanent. You will be able to equip it on all characters on this account.", "yellow" },
    effect = 180,
    rarity = RARITYS_STORE.RARE,
    finish = function(player)
      return player:setAccountStorageValue(PlayerStorage.footPrints + 33, 1)
    end,
    check = function(player)
      return player:getAccountStorageValue(PlayerStorage.footPrints + 33) == 1
    end
  },
  {
    name = "Rainbow",
    price = 150,
    tooltip = { "This purchase is for your account and is permanent. You will be able to equip it on all characters on this account.", "yellow" },
    effect = 148,
    rarity = RARITYS_STORE.LEGENDARY,
    finish = function(player)
      return player:setAccountStorageValue(PlayerStorage.footPrints + 32, 1)
    end,
    check = function(player)
      return player:getAccountStorageValue(PlayerStorage.footPrints + 32) == 1
    end
  },
  {
    name = "Pentagram",
    price = 150,
    tooltip = { "This purchase is for your account and is permanent. You will be able to equip it on all characters on this account.", "yellow" },
    effect = 85,
    rarity = RARITYS_STORE.LEGENDARY,
    finish = function(player)
      return player:setAccountStorageValue(PlayerStorage.footPrints + 31, 1)
    end,
    check = function(player)
      return player:getAccountStorageValue(PlayerStorage.footPrints + 31) == 1
    end
  },
  {
    name = "Gold Coin",
    price = 150,
    tooltip = { "This purchase is for your account and is permanent. You will be able to equip it on all characters on this account.", "yellow" },
    effect = 405,
    rarity = RARITYS_STORE.LEGENDARY,
    finish = function(player)
      return player:setAccountStorageValue(PlayerStorage.footPrints + 30, 1)
    end,
    check = function(player)
      return player:getAccountStorageValue(PlayerStorage.footPrints + 30) == 1
    end
  },
  {
    name = "Rain Cloud",
    price = 150,
    tooltip = { "This purchase is for your account and is permanent. You will be able to equip it on all characters on this account.", "yellow" },
    effect = 206,
    rarity = RARITYS_STORE.LEGENDARY,
    finish = function(player)
      return player:setAccountStorageValue(PlayerStorage.footPrints + 29, 1)
    end,
    check = function(player)
      return player:getAccountStorageValue(PlayerStorage.footPrints + 29) == 1
    end
  },
  {
    name = "Medusa",
    price = 150,
    tooltip = { "This purchase is for your account and is permanent. You will be able to equip it on all characters on this account.", "yellow" },
    effect = 359,
    rarity = RARITYS_STORE.LEGENDARY,
    finish = function(player)
      return player:setAccountStorageValue(PlayerStorage.footPrints + 28, 1)
    end,
    check = function(player)
      return player:getAccountStorageValue(PlayerStorage.footPrints + 28) == 1
    end
  },
  {
    name = "Skeleton",
    price = 150,
    tooltip = { "This purchase is for your account and is permanent. You will be able to equip it on all characters on this account.", "yellow" },
    effect = 155,
    rarity = RARITYS_STORE.LEGENDARY,
    finish = function(player)
      return player:setAccountStorageValue(PlayerStorage.footPrints + 27, 1)
    end,
    check = function(player)
      return player:getAccountStorageValue(PlayerStorage.footPrints + 27) == 1
    end
  },
  {
    name = "Bats",
    price = 150,
    tooltip = { "This purchase is for your account and is permanent. You will be able to equip it on all characters on this account.", "yellow" },
    effect = 67,
    rarity = RARITYS_STORE.LEGENDARY,
    finish = function(player)
      return player:setAccountStorageValue(PlayerStorage.footPrints + 26, 1)
    end,
    check = function(player)
      return player:getAccountStorageValue(PlayerStorage.footPrints + 26) == 1
    end
  },
  {
    name = "Dollar",
    price = 150,
    tooltip = { "This purchase is for your account and is permanent. You will be able to equip it on all characters on this account.", "yellow" },
    effect = 141,
    rarity = RARITYS_STORE.LEGENDARY,
    finish = function(player)
      return player:setAccountStorageValue(PlayerStorage.footPrints + 25, 1)
    end,
    check = function(player)
      return player:getAccountStorageValue(PlayerStorage.footPrints + 25) == 1
    end
  },
  {
    name = "Black Decay",
    price = 150,
    tooltip = { "This purchase is for your account and is permanent. You will be able to equip it on all characters on this account.", "yellow" },
    effect = 92,
    rarity = RARITYS_STORE.LEGENDARY,
    finish = function(player)
      return player:setAccountStorageValue(PlayerStorage.footPrints + 24, 1)
    end,
    check = function(player)
      return player:getAccountStorageValue(PlayerStorage.footPrints + 24) == 1
    end
  },
  {
    name = "Death",
    price = 150,
    tooltip = { "This purchase is for your account and is permanent. You will be able to equip it on all characters on this account.", "yellow" },
    effect = 200,
    rarity = RARITYS_STORE.LEGENDARY,
    finish = function(player)
      return player:setAccountStorageValue(PlayerStorage.footPrints + 23, 1)
    end,
    check = function(player)
      return player:getAccountStorageValue(PlayerStorage.footPrints + 23) == 1
    end
  },
  
  {
    name = "Plants",
    price = 100,
    tooltip = { "This purchase is for your account and is permanent. You will be able to equip it on all characters on this account.", "yellow" },
    effect = 46,
    rarity = RARITYS_STORE.RARE,
    finish = function(player)
      return player:setAccountStorageValue(PlayerStorage.footPrints + 22, 1)
    end,
    check = function(player)
      return player:getAccountStorageValue(PlayerStorage.footPrints + 22) == 1
    end
  },
  {
    name = "White Note",
    price = 100,
    tooltip = { "This purchase is for your account and is permanent. You will be able to equip it on all characters on this account.", "yellow" },
    effect = 25,
    rarity = RARITYS_STORE.RARE,
    finish = function(player)
      return player:setAccountStorageValue(PlayerStorage.footPrints + 21, 1)
    end,
    check = function(player)
      return player:getAccountStorageValue(PlayerStorage.footPrints + 21) == 1
    end
  },
  {
    name = "Blue Note",
    price = 100,
    tooltip = { "This purchase is for your account and is permanent. You will be able to equip it on all characters on this account.", "yellow" },
    effect = 24,
    rarity = RARITYS_STORE.RARE,
    finish = function(player)
      return player:setAccountStorageValue(PlayerStorage.footPrints + 20, 1)
    end,
    check = function(player)
      return player:getAccountStorageValue(PlayerStorage.footPrints + 20) == 1
    end
  },
  {
    name = "Purple Note",
    price = 100,
    tooltip = { "This purchase is for your account and is permanent. You will be able to equip it on all characters on this account.", "yellow" },
    effect = 23,
    rarity = RARITYS_STORE.RARE,
    finish = function(player)
      return player:setAccountStorageValue(PlayerStorage.footPrints + 19, 1)
    end,
    check = function(player)
      return player:getAccountStorageValue(PlayerStorage.footPrints + 19) == 1
    end
  },
  {
    name = "Yellow Note",
    price = 100,
    tooltip = { "This purchase is for your account and is permanent. You will be able to equip it on all characters on this account.", "yellow" },
    effect = 22,
    rarity = RARITYS_STORE.RARE,
    finish = function(player)
      return player:setAccountStorageValue(PlayerStorage.footPrints + 18, 1)
    end,
    check = function(player)
      return player:getAccountStorageValue(PlayerStorage.footPrints + 18) == 1
    end
  },
  {
    name = "Rain of Holy",
    price = 100,
    tooltip = { "This purchase is for your account and is permanent. You will be able to equip it on all characters on this account.", "yellow" },
    effect = 261,
    rarity = RARITYS_STORE.RARE,
    finish = function(player)
      return player:setAccountStorageValue(PlayerStorage.footPrints + 16, 1)
    end,
    check = function(player)
      return player:getAccountStorageValue(PlayerStorage.footPrints + 16) == 1
    end
  },
  {
    name = "Rain of Stones",
    price = 100,
    tooltip = { "This purchase is for your account and is permanent. You will be able to equip it on all characters on this account.", "yellow" },
    effect = 45,
    rarity = RARITYS_STORE.RARE,
    finish = function(player)
      return player:setAccountStorageValue(PlayerStorage.footPrints + 15, 1)
    end,
    check = function(player)
      return player:getAccountStorageValue(PlayerStorage.footPrints + 15) == 1
    end
  },
  
  
  {
    name = "Grey Slush",
    price = 50,
    tooltip = { "This purchase is for your account and is permanent. You will be able to equip it on all characters on this account.", "yellow" },
    effect = 82,
    rarity = RARITYS_STORE.MAGIC,
    finish = function(player)
      return player:setAccountStorageValue(PlayerStorage.footPrints + 14, 1)
    end,
    check = function(player)
      return player:getAccountStorageValue(PlayerStorage.footPrints + 14) == 1
    end
  },
  {
    name = "Fairy",
    price = 50,
    tooltip = { "This purchase is for your account and is permanent. You will be able to equip it on all characters on this account.", "yellow" },
    effect = 81,
    rarity = RARITYS_STORE.MAGIC,
    finish = function(player)
      return player:setAccountStorageValue(PlayerStorage.footPrints + 13, 1)
    end,
    check = function(player)
      return player:getAccountStorageValue(PlayerStorage.footPrints + 13) == 1
    end
  },
  {
    name = "Fire Shrine",
    price = 50,
    tooltip = { "This purchase is for your account and is permanent. You will be able to equip it on all characters on this account.", "yellow" },
    effect = 80,
    rarity = RARITYS_STORE.MAGIC,
    finish = function(player)
      return player:setAccountStorageValue(PlayerStorage.footPrints + 12, 1)
    end,
    check = function(player)
      return player:getAccountStorageValue(PlayerStorage.footPrints + 12) == 1
    end
  },
  {
    name = "Black Devil",
    price = 50,
    tooltip = { "This purchase is for your account and is permanent. You will be able to equip it on all characters on this account.", "yellow" },
    effect = 79,
    rarity = RARITYS_STORE.MAGIC,
    finish = function(player)
      return player:setAccountStorageValue(PlayerStorage.footPrints + 11, 1)
    end,
    check = function(player)
      return player:getAccountStorageValue(PlayerStorage.footPrints + 11) == 1
    end
  },
  {
    name = "Angel Shrine",
    price = 50,
    tooltip = { "This purchase is for your account and is permanent. You will be able to equip it on all characters on this account.", "yellow" },
    effect = 78,
    rarity = RARITYS_STORE.MAGIC,
    finish = function(player)
      return player:setAccountStorageValue(PlayerStorage.footPrints + 10, 1)
    end,
    check = function(player)
      return player:getAccountStorageValue(PlayerStorage.footPrints + 10) == 1
    end
  },
  {
    name = "Stars",
    price = 50,
    tooltip = { "This purchase is for your account and is permanent. You will be able to equip it on all characters on this account.", "yellow" },
    effect = 32,
    rarity = RARITYS_STORE.MAGIC,
    finish = function(player)
      return player:setAccountStorageValue(PlayerStorage.footPrints + 9, 1)
    end,
    check = function(player)
      return player:getAccountStorageValue(PlayerStorage.footPrints + 9) == 1
    end
  },
  {
    name = "Smoke",
    price = 50,
    tooltip = { "This purchase is for your account and is permanent. You will be able to equip it on all characters on this account.", "yellow" },
    effect = 96,
    rarity = RARITYS_STORE.MAGIC,
    finish = function(player)
      return player:setAccountStorageValue(PlayerStorage.footPrints + 8, 1)
    end,
    check = function(player)
      return player:getAccountStorageValue(PlayerStorage.footPrints + 8) == 1
    end
  },
  {
    name = "Rainbow",
    price = 50,
    tooltip = { "This purchase is for your account and is permanent. You will be able to equip it on all characters on this account.", "yellow" },
    effect = 28,
    rarity = RARITYS_STORE.MAGIC,
    finish = function(player)
      return player:setAccountStorageValue(PlayerStorage.footPrints + 7, 1)
    end,
    check = function(player)
      return player:getAccountStorageValue(PlayerStorage.footPrints + 7) == 1
    end
  },
  {
    name = "Ghost",
    price = 50,
    tooltip = { "This purchase is for your account and is permanent. You will be able to equip it on all characters on this account.", "yellow" },
    effect = 66,
    rarity = RARITYS_STORE.MAGIC,
    finish = function(player)
      return player:setAccountStorageValue(PlayerStorage.footPrints + 6, 1)
    end,
    check = function(player)
      return player:getAccountStorageValue(PlayerStorage.footPrints + 6) == 1
    end
  },
  {
    name = "Bleeding",
    price = 50,
    tooltip = { "This purchase is for your account and is permanent. You will be able to equip it on all characters on this account.", "yellow" },
    effect = 94,
    rarity = RARITYS_STORE.MAGIC,
    finish = function(player)
      return player:setAccountStorageValue(PlayerStorage.footPrints + 5, 1)
    end,
    check = function(player)
      return player:getAccountStorageValue(PlayerStorage.footPrints + 5) == 1
    end
  },
  {
    name = "Ice",
    price = 50,
    tooltip = { "This purchase is for your account and is permanent. You will be able to equip it on all characters on this account.", "yellow" },
    effect = 42,
    rarity = RARITYS_STORE.MAGIC,
    finish = function(player)
      return player:setAccountStorageValue(PlayerStorage.footPrints + 4, 1)
    end,
    check = function(player)
      return player:getAccountStorageValue(PlayerStorage.footPrints + 4) == 1
    end
  },
  {
    name = "Heart",
    price = 50,
    tooltip = { "This purchase is for your account and is permanent. You will be able to equip it on all characters on this account.", "yellow" },
    effect = 36,
    rarity = RARITYS_STORE.COMMON,
    finish = function(player)
      return player:setAccountStorageValue(PlayerStorage.footPrints + 3, 1)
    end,
    check = function(player)
      return player:getAccountStorageValue(PlayerStorage.footPrints + 3) == 1
    end
  },
  {
    name = "Dice",
    price = 50,
    tooltip = { "This purchase is for your account and is permanent. You will be able to equip it on all characters on this account.", "yellow" },
    effect = 27,
    rarity = RARITYS_STORE.COMMON,
    finish = function(player)
      return player:setAccountStorageValue(PlayerStorage.footPrints + 2, 1)
    end,
    check = function(player)
      return player:getAccountStorageValue(PlayerStorage.footPrints + 2) == 1
    end
  },
  {
    name = "Poison",
    price = 50,
    tooltip = { "This purchase is for your account and is permanent. You will be able to equip it on all characters on this account.", "yellow" },
    effect = 21,
    rarity = RARITYS_STORE.COMMON,
    finish = function(player)
      return player:setAccountStorageValue(PlayerStorage.footPrints + 1, 1)
    end,
    check = function(player)
      return player:getAccountStorageValue(PlayerStorage.footPrints + 1) == 1
    end
  },
}