return {
  {
    name = "Void Flame",
    price = 400,
    tooltip = { "This purchase is for your account and is permanent. You will be able to equip it on all characters on this account.", "yellow" },
    outfit = { aura = 2512 },
    rarity = RARITYS_STORE.LIMITED,
    animate = true,
    finish = function(player)
      return player:addAura(2512)
    end,
    check = function(player)
      return player:hasAura(2512)
    end
  },
  {
    name = "Void Aura",
    price = 400,
    tooltip = { "This purchase is for your account and is permanent. You will be able to equip it on all characters on this account.", "yellow" },
    outfit = { aura = 2530 },
    rarity = RARITYS_STORE.LIMITED,
    animate = true,
    finish = function(player)
      return player:addAura(2530)
    end,
    check = function(player)
      return player:hasAura(2530)
    end
  },
  {
    name = "Fire Aura",
    price = 300,
    tooltip = { "This purchase is for your account and is permanent. You will be able to equip it on all characters on this account.", "yellow" },
    outfit = { aura = 2126 },
    rarity = RARITYS_STORE.LEGENDARY,
    animate = true,
    finish = function(player)
      return player:addAura(2126)
    end,
    check = function(player)
      return player:hasAura(2126)
    end
  },
  {
    name = "Elements",
    price = 400,
    tooltip = { "This purchase is for your account and is permanent. You will be able to equip it on all characters on this account.", "yellow" },
    outfit = { aura = 2456 },
    rarity = RARITYS_STORE.LIMITED,
    animate = true,
    finish = function(player)
      return player:addAura(2456)
    end,
    check = function(player)
      return player:hasAura(2456)
    end
  },
  {
    name = "Flamebound Essence",
    price = 250,
    tooltip = { "This purchase is for your account and is permanent. You will be able to equip it on all characters on this account.", "yellow" },
    outfit = { aura = 2571 },
    rarity = RARITYS_STORE.LEGENDARY,
    animate = true,
    finish = function(player)
      return player:addAura(2571)
    end,
    check = function(player)
      return player:hasAura(2571)
    end
  },
  {
    name = "Candle",
    price = 250,
    tooltip = { "This purchase is for your account and is permanent. You will be able to equip it on all characters on this account.", "yellow" },
    outfit = { aura = 2108 },
    rarity = RARITYS_STORE.LEGENDARY,
    animate = true,
    finish = function(player)
      return player:addAura(2108)
    end,
    check = function(player)
      return player:hasAura(2108)
    end
  },
  {
    name = "Rainbow Grace",
    price = 250,
    tooltip = { "This purchase is for your account and is permanent. You will be able to equip it on all characters on this account.", "yellow" },
    outfit = { aura = 2137 },
    rarity = RARITYS_STORE.LEGENDARY,
    animate = true,
    finish = function(player)
      return player:addAura(2137)
    end,
    check = function(player)
      return player:hasAura(2137)
    end
  },
  {
    name = "Rainbow Sky",
    price = 250,
    tooltip = { "This purchase is for your account and is permanent. You will be able to equip it on all characters on this account.", "yellow" },
    outfit = { aura = 2136 },
    rarity = RARITYS_STORE.LEGENDARY,
    animate = true,
    finish = function(player)
      return player:addAura(2136)
    end,
    check = function(player)
      return player:hasAura(2136)
    end
  },
  {
    name = "Arcane Wisp",
    price = 250,
    tooltip = { "This purchase is for your account and is permanent. You will be able to equip it on all characters on this account.", "yellow" },
    outfit = { aura = 2523 },
    rarity = RARITYS_STORE.LEGENDARY,
    animate = true,
    finish = function(player)
      return player:addAura(2523)
    end,
    check = function(player)
      return player:hasAura(2523)
    end
  },
  {
    name = "Verdant Wisp",
    price = 250,
    tooltip = { "This purchase is for your account and is permanent. You will be able to equip it on all characters on this account.", "yellow" },
    outfit = { aura = 2524 },
    rarity = RARITYS_STORE.LEGENDARY,
    animate = true,
    finish = function(player)
      return player:addAura(2524)
    end,
    check = function(player)
      return player:hasAura(2524)
    end
  },
  {
    name = "Solar Wisp",
    price = 250,
    tooltip = { "This purchase is for your account and is permanent. You will be able to equip it on all characters on this account.", "yellow" },
    outfit = { aura = 2525 },
    rarity = RARITYS_STORE.LEGENDARY,
    animate = true,
    finish = function(player)
      return player:addAura(2525)
    end,
    check = function(player)
      return player:hasAura(2525)
    end
  },
  {
    name = "Ember Wisp",
    price = 250,
    tooltip = { "This purchase is for your account and is permanent. You will be able to equip it on all characters on this account.", "yellow" },
    outfit = { aura = 2526 },
    rarity = RARITYS_STORE.LEGENDARY,
    animate = true,
    finish = function(player)
      return player:addAura(2526)
    end,
    check = function(player)
      return player:hasAura(2526)
    end
  },
  {
    name = "Frost Wisp",
    price = 250,
    tooltip = { "This purchase is for your account and is permanent. You will be able to equip it on all characters on this account.", "yellow" },
    outfit = { aura = 2527 },
    rarity = RARITYS_STORE.LEGENDARY,
    animate = true,
    finish = function(player)
      return player:addAura(2527)
    end,
    check = function(player)
      return player:hasAura(2527)
    end
  },
  {
    name = "Lumen Wisp",
    price = 250,
    tooltip = { "This purchase is for your account and is permanent. You will be able to equip it on all characters on this account.", "yellow" },
    outfit = { aura = 2528 },
    rarity = RARITYS_STORE.LEGENDARY,
    animate = true,
    finish = function(player)
      return player:addAura(2528)
    end,
    check = function(player)
      return player:hasAura(2528)
    end
  },
  {
    name = "Void Wisp",
    price = 250,
    tooltip = { "This purchase is for your account and is permanent. You will be able to equip it on all characters on this account.", "yellow" },
    outfit = { aura = 2529 },
    rarity = RARITYS_STORE.LEGENDARY,
    animate = true,
    finish = function(player)
      return player:addAura(2529)
    end,
    check = function(player)
      return player:hasAura(2529)
    end
  },
  {
    name = "Angel Orb",
    price = 150,
    tooltip = { "This purchase is for your account and is permanent. You will be able to equip it on all characters on this account.", "yellow" },
    outfit = { aura = 2098 },
    rarity = RARITYS_STORE.RARE,
    animate = true,
    finish = function(player)
      return player:addAura(2098)
    end,
    check = function(player)
      return player:hasAura(2098)
    end
  },
  {
    name = "Decay",
    price = 150,
    tooltip = { "This purchase is for your account and is permanent. You will be able to equip it on all characters on this account.", "yellow" },
    outfit = { aura = 2102 },
    rarity = RARITYS_STORE.RARE,
    animate = true,
    finish = function(player)
      return player:addAura(2102)
    end,
    check = function(player)
      return player:hasAura(2102)
    end
  },
  {
    name = "Skeleton Soul",
    price = 150,
    tooltip = { "This purchase is for your account and is permanent. You will be able to equip it on all characters on this account.", "yellow" },
    outfit = { aura = 2154 },
    rarity = RARITYS_STORE.RARE,
    animate = true,
    finish = function(player)
      return player:addAura(2154)
    end,
    check = function(player)
      return player:hasAura(2154)
    end
  },
  {
    name = "Dollar",
    price = 150,
    tooltip = { "This purchase is for your account and is permanent. You will be able to equip it on all characters on this account.", "yellow" },
    outfit = { aura = 2092 },
    rarity = RARITYS_STORE.RARE,
    animate = true,
    finish = function(player)
      return player:addAura(2092)
    end,
    check = function(player)
      return player:hasAura(2092)
    end
  },
  {
    name = "Rain",
    price = 150,
    tooltip = { "This purchase is for your account and is permanent. You will be able to equip it on all characters on this account.", "yellow" },
    outfit = { aura = 2235 },
    rarity = RARITYS_STORE.RARE,
    animate = true,
    finish = function(player)
      return player:addAura(2235)
    end,
    check = function(player)
      return player:hasAura(2235)
    end
  },
  {
    name = "Bats",
    price = 100,
    tooltip = { "This purchase is for your account and is permanent. You will be able to equip it on all characters on this account.", "yellow" },
    outfit = { aura = 2018 },
    rarity = RARITYS_STORE.MAGIC,
    animate = true,
    finish = function(player)
      return player:addAura(2018)
    end,
    check = function(player)
      return player:hasAura(2018)
    end
  },
  {
    name = "Demonic",
    price = 100,
    tooltip = { "This purchase is for your account and is permanent. You will be able to equip it on all characters on this account.", "yellow" },
    outfit = { aura = 2040 },
    rarity = RARITYS_STORE.MAGIC,
    animate = true,
    finish = function(player)
      return player:addAura(2040)
    end,
    check = function(player)
      return player:hasAura(2040)
    end
  },
  {
    name = "Lightning",
    price = 100,
    tooltip = { "This purchase is for your account and is permanent. You will be able to equip it on all characters on this account.", "yellow" },
    outfit = { aura = 2386 },
    rarity = RARITYS_STORE.MAGIC,
    animate = true,
    finish = function(player)
      return player:addAura(2386)
    end,
    check = function(player)
      return player:hasAura(2386)
    end
  },
  {
    name = "Black Devil",
    price = 100,
    tooltip = { "This purchase is for your account and is permanent. You will be able to equip it on all characters on this account.", "yellow" },
    outfit = { aura = 2041 },
    rarity = RARITYS_STORE.MAGIC,
    animate = true,
    finish = function(player)
      return player:addAura(2041)
    end,
    check = function(player)
      return player:hasAura(2041)
    end
  },
  {
    name = "Demonic Tamer",
    price = 100,
    tooltip = { "This purchase is for your account and is permanent. You will be able to equip it on all characters on this account.", "yellow" },
    outfit = { aura = 2095 },
    rarity = RARITYS_STORE.MAGIC,
    animate = true,
    finish = function(player)
      return player:addAura(2095)
    end,
    check = function(player)
      return player:hasAura(2095)
    end
  },
  {
    name = "Archangel",
    price = 100,
    tooltip = { "This purchase is for your account and is permanent. You will be able to equip it on all characters on this account.", "yellow" },
    outfit = { aura = 2042 },
    rarity = RARITYS_STORE.MAGIC,
    animate = true,
    finish = function(player)
      return player:addAura(2042)
    end,
    check = function(player)
      return player:hasAura(2042)
    end
  },
  {
    name = "Charge",
    price = 100,
    tooltip = { "This purchase is for your account and is permanent. You will be able to equip it on all characters on this account.", "yellow" },
    outfit = { aura = 2030 },
    rarity = RARITYS_STORE.MAGIC,
    animate = true,
    finish = function(player)
      return player:addAura(2030)
    end,
    check = function(player)
      return player:hasAura(2030)
    end
  },
  {
    name = "Black Orbs",
    price = 30,
    tooltip = { "This purchase is for your account and is permanent. You will be able to equip it on all characters on this account.", "yellow" },
    outfit = { aura = 2033 },
    rarity = RARITYS_STORE.COMMON,
    animate = true,
    finish = function(player)
      return player:addAura(2033)
    end,
    check = function(player)
      return player:hasAura(2033)
    end
  },
  {
    name = "Fairy",
    price = 30,
    tooltip = { "This purchase is for your account and is permanent. You will be able to equip it on all characters on this account.", "yellow" },
    outfit = { aura = 2043 },
    rarity = RARITYS_STORE.COMMON,
    animate = true,
    finish = function(player)
      return player:addAura(2043)
    end,
    check = function(player)
      return player:hasAura(2043)
    end
  },
  {
    name = "Elven",
    price = 30,
    tooltip = { "This purchase is for your account and is permanent. You will be able to equip it on all characters on this account.", "yellow" },
    outfit = { aura = 2047 },
    rarity = RARITYS_STORE.COMMON,
    animate = true,
    finish = function(player)
      return player:addAura(2047)
    end,
    check = function(player)
      return player:hasAura(2047)
    end
  },
  {
    name = "Bloody",
    price = 30,
    tooltip = { "This purchase is for your account and is permanent. You will be able to equip it on all characters on this account.", "yellow" },
    outfit = { aura = 2007 },
    rarity = RARITYS_STORE.COMMON,
    animate = true,
    finish = function(player)
      return player:addAura(2007)
    end,
    check = function(player)
      return player:hasAura(2007)
    end
  },
}

