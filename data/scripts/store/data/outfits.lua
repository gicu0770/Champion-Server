return {
  {
    name = "Void Elf",
    price = 400,
    rarity = RARITYS_STORE.LIMITED,
    tooltip = { "This purchase is for your account and is permanent. You will be able to equip it on all characters on this account.", "yellow" },
    outfit = {
        [1] = {type = 2589, addons = 3},
        [2] = {type = 2589, addons = 3},
    },
    finish = function(player)
        return player:addOutfitAddon(2589, 3) and player:addOutfitAddon(2589, 3)
    end,
    check = function(player)
      return player:hasOutfit(2589) or player:hasOutfit(2589)
    end
  },
  {
    name = "Void Warrior",
    price = 400,
    rarity = RARITYS_STORE.LIMITED,
    tooltip = { "This purchase is for your account and is permanent. You will be able to equip it on all characters on this account.", "yellow" },
    outfit = {
        [1] = {type = 2590, addons = 3},
        [2] = {type = 2590, addons = 3},
    },
    finish = function(player)
        return player:addOutfitAddon(2590, 3) and player:addOutfitAddon(2590, 3)
    end,
    check = function(player)
      return player:hasOutfit(2590) or player:hasOutfit(2590)
    end
  },
  {
    name = "Void Wizard",
    price = 400,
    rarity = RARITYS_STORE.LIMITED,
    tooltip = { "This purchase is for your account and is permanent. You will be able to equip it on all characters on this account.", "yellow" },
    outfit = {
        [1] = {type = 2610, addons = 3},
        [2] = {type = 2610, addons = 3},
    },
    finish = function(player)
        return player:addOutfitAddon(2610, 3) and player:addOutfitAddon(2610, 3)
    end,
    check = function(player)
      return player:hasOutfit(2610) or player:hasOutfit(2610)
    end
  },
  {
    name = "Golden",
    price = 300,
    rarity = RARITYS_STORE.LEGENDARY,
    tooltip = { "This purchase is for your account and is permanent. You will be able to equip it on all characters on this account.", "yellow" },
    outfit = {
        [1] = {type = 1144, addons = 3},
        [2] = {type = 1145, addons = 3},
    },
    finish = function(player)
        return player:addOutfitAddon(1144, 3) and player:addOutfitAddon(1145, 3)
    end,
    check = function(player)
      return player:hasOutfit(1144) or player:hasOutfit(1145)
    end
  },
  {
    name = "Dragon Knight",
    price = 300,
    rarity = RARITYS_STORE.LEGENDARY,
    tooltip = { "This purchase is for your account and is permanent. You will be able to equip it on all characters on this account.", "yellow" },
    outfit = {
        [1] = {type = 2079, addons = 3},
        [2] = {type = 2078, addons = 3},
    },
    finish = function(player)
        return player:addOutfitAddon(2079, 3) and player:addOutfitAddon(2078, 3)
    end,
    check = function(player)
      return player:hasOutfit(2079) or player:hasOutfit(2078)
    end
  },
  {
    name = "Battle Wizard",
    price = 300,
    rarity = RARITYS_STORE.LEGENDARY,
    tooltip = { "This purchase is for your account and is permanent. You will be able to equip it on all characters on this account.", "yellow" },
    outfit = {
        [1] = {type = 2083, addons = 3},
        [2] = {type = 2083, addons = 3},
    },
    finish = function(player)
        return player:addOutfitAddon(2083, 3) and player:addOutfitAddon(2083, 3)
    end,
    check = function(player)
      return player:hasOutfit(2083) or player:hasOutfit(2083)
    end
  },
  {
    name = "Reaper of Soul",
    price = 300,
    rarity = RARITYS_STORE.LEGENDARY,
    tooltip = { "This purchase is for your account and is permanent. You will be able to equip it on all characters on this account.", "yellow" },
    outfit = {
        [1] = {type = 2012, addons = 3},
        [2] = {type = 2012, addons = 3},
    },
    finish = function(player)
        return player:addOutfitAddon(2012, 3) and player:addOutfitAddon(2012, 3)
    end,
    check = function(player)
      return player:hasOutfit(2012) or player:hasOutfit(2012)
    end
  },
  {
    name = "Demonic Knight",
    price = 300,
    rarity = RARITYS_STORE.LEGENDARY,
    tooltip = { "This purchase is for your account and is permanent. You will be able to equip it on all characters on this account.", "yellow" },
    outfit = {
        [1] = {type = 2081, addons = 3},
        [2] = {type = 2081, addons = 3},
    },
    finish = function(player)
        return player:addOutfitAddon(2081, 3) and player:addOutfitAddon(2081, 3)
    end,
    check = function(player)
      return player:hasOutfit(2081) or player:hasOutfit(2081)
    end
  },
  {
    name = "High Elf",
    price = 300,
    rarity = RARITYS_STORE.LEGENDARY,
    tooltip = { "This purchase is for your account and is permanent. You will be able to equip it on all characters on this account.", "yellow" },
    outfit = {
      [1] = {type = 2082, addons = 3},
      [2] = {type = 2082, addons = 3},
    },
    finish = function(player)
      return player:addOutfitAddon(2082, 3) and player:addOutfitAddon(2082, 3)
    end,
    check = function(player)
      return player:hasOutfit(2082) or player:hasOutfit(2082)
    end
  },
  {
    name = "Gentleman",
    price = 300,
    rarity = RARITYS_STORE.LEGENDARY,
    tooltip = { "This purchase is for your account and is permanent. You will be able to equip it on all characters on this account.", "yellow" },
    outfit = {
      [1] = {type = 2090, addons = 3},
    },
    finish = function(player)
      return player:addOutfitAddon(2090, 3)
    end,
    check = function(player)
      return player:hasOutfit(2090)
    end
  },
  {
    name = "Tyrael",
    price = 300,
    rarity = RARITYS_STORE.LEGENDARY,
    tooltip = { "This purchase is for your account and is permanent. You will be able to equip it on all characters on this account.", "yellow" },
    outfit = {
      [1] = {type = 2015, addons = 3},
    },
    finish = function(player)
      return player:addOutfitAddon(2015, 3)
    end,
    check = function(player)
      return player:hasOutfit(2015)
    end
  },
  {
    name = "Fencer",
    price = 200,
    rarity = RARITYS_STORE.RARE,
    tooltip = { "This purchase is for your account and is permanent. You will be able to equip it on all characters on this account.", "yellow" },
    outfit = {
        [1] = {type = 2345, addons = 3},
        [2] = {type = 2344, addons = 3},
    },
    finish = function(player)
        return player:addOutfitAddon(2345, 3) and player:addOutfitAddon(2344, 3)
    end,
    check = function(player)
      return player:hasOutfit(2345) or player:hasOutfit(2344)
    end
  },
  {
    name = "Deepling",
    price = 200,
    rarity = RARITYS_STORE.RARE,
    tooltip = { "This purchase is for your account and is permanent. You will be able to equip it on all characters on this account.", "yellow" },
    outfit = {
        [1] = {type = 464, addons = 3},
        [2] = {type = 463, addons = 3},
    },
    finish = function(player)
        return player:addOutfitAddon(464, 3) and player:addOutfitAddon(463, 3)
    end,
    check = function(player)
      return player:hasOutfit(464) or player:hasOutfit(463)
    end
  },
  {
    name = "Insectoid",
    price = 200,
    rarity = RARITYS_STORE.RARE,
    tooltip = { "This purchase is for your account and is permanent. You will be able to equip it on all characters on this account.", "yellow" },
    outfit = {
        [1] = {type = 466, addons = 3},
        [2] = {type = 465, addons = 3},
    },
    finish = function(player)
        return player:addOutfitAddon(466, 3) and player:addOutfitAddon(465, 3)
    end,
    check = function(player)
      return player:hasOutfit(466) or player:hasOutfit(465)
    end
  },
  {
    name = "Entrepreneur",
    price = 200,
    rarity = RARITYS_STORE.RARE,
    tooltip = { "This purchase is for your account and is permanent. You will be able to equip it on all characters on this account.", "yellow" },
    outfit = {
        [1] = {type = 471, addons = 3},
        [2] = {type = 472, addons = 3},
    },
    finish = function(player)
        return player:addOutfitAddon(471, 3) and player:addOutfitAddon(472, 3)
    end,
    check = function(player)
      return player:hasOutfit(471) or player:hasOutfit(472)
    end
  },
  {
    name = "Barbarian",
    price = 150,
    rarity = RARITYS_STORE.MAGIC,
    tooltip = { "This purchase is for your account and is permanent. You will be able to equip it on all characters on this account.", "yellow" },
    outfit = {
        [1] = {type = 143, addons = 3},
        [2] = {type = 147, addons = 3},
    },
    finish = function(player)
      return player:addOutfitAddon(143, 3) and player:addOutfitAddon(147, 3)
    end,
    check = function(player)
      return player:hasOutfit(143) or player:hasOutfit(147)
    end
  },
  {
    name = "Summoner",
    price = 150,
    rarity = RARITYS_STORE.MAGIC,
    tooltip = { "This purchase is for your account and is permanent. You will be able to equip it on all characters on this account.", "yellow" },
    outfit = {
        [1] = {type = 133, addons = 3},
        [2] = {type = 141, addons = 3},
    },
    finish = function(player)
      return player:addOutfitAddon(133, 3) and player:addOutfitAddon(141, 3)
    end,
    check = function(player)
      return player:hasOutfit(133) or player:hasOutfit(141)
    end
  },
  {
    name = "Wizard",
    price = 150,
    rarity = RARITYS_STORE.MAGIC,
    tooltip = { "This purchase is for your account and is permanent. You will be able to equip it on all characters on this account.", "yellow" },
    outfit = {
        [1] = {type = 145, addons = 3},
        [2] = {type = 149, addons = 3},
    },
    finish = function(player)
      return player:addOutfitAddon(145, 3) and player:addOutfitAddon(149, 3)
    end,
    check = function(player)
      return player:hasOutfit(145) or player:hasOutfit(149)
    end
  },
  {
    name = "Oriental",
    price = 150,
    rarity = RARITYS_STORE.MAGIC,
    tooltip = { "This purchase is for your account and is permanent. You will be able to equip it on all characters on this account.", "yellow" },
    outfit = {
        [1] = {type = 146, addons = 3},
        [2] = {type = 150, addons = 3},
    },
    finish = function(player)
      return player:addOutfitAddon(146, 3) and player:addOutfitAddon(150, 3)
    end,
    check = function(player)
      return player:hasOutfit(146) or player:hasOutfit(150)
    end
  },
  {
    name = "Assassin",
    price = 150,
    rarity = RARITYS_STORE.MAGIC,
    tooltip = { "This purchase is for your account and is permanent. You will be able to equip it on all characters on this account.", "yellow" },
    outfit = {
        [1] = {type = 152, addons = 3},
        [2] = {type = 156, addons = 3},
    },
    finish = function(player)
      return player:addOutfitAddon(152, 3) and player:addOutfitAddon(156, 3)
    end,
    check = function(player)
      return player:hasOutfit(152) or player:hasOutfit(156)
    end
  },
  {
    name = "Newly Wed",
    price = 100,
    rarity = RARITYS_STORE.MAGIC,
    tooltip = { "This purchase is for your account and is permanent. You will be able to equip it on all characters on this account.", "yellow" },
    outfit = {
      [1] = {type = 328, addons = 3},
    },
    finish = function(player)
      return player:addOutfitAddon(328, 3)
    end,
    check = function(player)
      return player:hasOutfit(328)
    end
  },
  {
    name = "Hunter",
    price = 100,
    rarity = RARITYS_STORE.COMMON,
    tooltip = { "This purchase is for your account and is permanent. You will be able to equip it on all characters on this account.", "yellow" },
    outfit = {
        [1] = {type = 129, addons = 3},
        [2] = {type = 137, addons = 3},
    },
    finish = function(player)
      return player:addOutfitAddon(129, 3) and player:addOutfitAddon(137, 3)
    end,
    check = function(player)
      return player:hasOutfit(129) or player:hasOutfit(137)
    end
  },
  {
    name = "Mage",
    price = 100,
    rarity = RARITYS_STORE.COMMON,
    tooltip = { "This purchase is for your account and is permanent. You will be able to equip it on all characters on this account.", "yellow" },
    outfit = {
        [1] = {type = 130, addons = 3},
        [2] = {type = 138, addons = 3},
    },
    finish = function(player)
      return player:addOutfitAddon(130, 3) and player:addOutfitAddon(138, 3)
    end,
    check = function(player)
      return player:hasOutfit(130) or player:hasOutfit(138)
    end
  },
  {
    name = "Knight",
    price = 100,
    rarity = RARITYS_STORE.COMMON,
    tooltip = { "This purchase is for your account and is permanent. You will be able to equip it on all characters on this account.", "yellow" },
    outfit = {
        [1] = {type = 131, addons = 3},
        [2] = {type = 139, addons = 3},
    },
    finish = function(player)
      return player:addOutfitAddon(131, 3) and player:addOutfitAddon(139, 3)
    end,
    check = function(player)
      return player:hasOutfit(131) or player:hasOutfit(139)
    end
  },
  {
    name = "Druid",
    price = 100,
    rarity = RARITYS_STORE.COMMON,
    tooltip = { "This purchase is for your account and is permanent. You will be able to equip it on all characters on this account.", "yellow" },
    outfit = {
        [1] = {type = 144, addons = 3},
        [2] = {type = 148, addons = 3},
    },
    finish = function(player)
      return player:addOutfitAddon(144, 3) and player:addOutfitAddon(148, 3)
    end,
    check = function(player)
      return player:hasOutfit(144) or player:hasOutfit(148)
    end
  },
  {
    name = "Warrior",
    price = 100,
    rarity = RARITYS_STORE.COMMON,
    tooltip = { "This purchase is for your account and is permanent. You will be able to equip it on all characters on this account.", "yellow" },
    outfit = {
        [1] = {type = 134, addons = 3},
        [2] = {type = 142, addons = 3},
    },
    finish = function(player)
      return player:addOutfitAddon(134, 3) and player:addOutfitAddon(142, 3)
    end,
    check = function(player)
      return player:hasOutfit(134) or player:hasOutfit(142)
    end
  },
}
