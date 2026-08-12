return {
  {
    name = "Blue",
    price = 200,
    tooltip = { "This purchase is for your account and is permanent. You will be able to equip it on all characters on this account.", "yellow" },
    outfit = { type = 128, shader = "outline", colorValue = "#0000FF" },
    rarity = RARITYS_STORE.MAGIC,
    finish = function(player)
      return player:addOutline("Blue Outline")
    end,
    check = function(player)
      return player:hasOutline("Blue Outline")
    end
  },
  {
    name = "Red",
    price = 200,
    tooltip = { "This purchase is for your account and is permanent. You will be able to equip it on all characters on this account.", "yellow" },
    outfit = { type = 128, shader = "outline", colorValue = "#FF0000" },
    rarity = RARITYS_STORE.MAGIC,
    finish = function(player)
      return player:addOutline("Red Outline")
    end,
    check = function(player)
      return player:hasOutline("Red Outline")
    end
  },
  {
    name = "Green",
    price = 200,
    tooltip = { "This purchase is for your account and is permanent. You will be able to equip it on all characters on this account.", "yellow" },
    outfit = { type = 128, shader = "outline", colorValue = "#00FF00" },
    rarity = RARITYS_STORE.MAGIC,
    finish = function(player)
      return player:addOutline("Green Outline")
    end,
    check = function(player)
      return player:hasOutline("Green Outline")
    end
  },
  {
    name = "Purple",
    price = 200,
    tooltip = { "This purchase is for your account and is permanent. You will be able to equip it on all characters on this account.", "yellow" },
    outfit = { type = 128, shader = "outline", colorValue = "#800080" },
    rarity = RARITYS_STORE.MAGIC,
    finish = function(player)
      return player:addOutline("Purple Outline")
    end,
    check = function(player)
      return player:hasOutline("Purple Outline")
    end
  },
  {
    name = "Gold",
    price = 200,
    tooltip = { "This purchase is for your account and is permanent. You will be able to equip it on all characters on this account.", "yellow" },
    outfit = { type = 128, shader = "outline", colorValue = "#FFA500" },
    rarity = RARITYS_STORE.MAGIC,
    finish = function(player)
      return player:addOutline("Gold Outline")
    end,
    check = function(player)
      return player:hasOutline("Gold Outline")
    end
  },
  {
    name = "Black",
    price = 200,
    tooltip = { "This purchase is for your account and is permanent. You will be able to equip it on all characters on this account.", "yellow" },
    outfit = { type = 128, shader = "outline", colorValue = "#000000" },
    rarity = RARITYS_STORE.MAGIC,
    finish = function(player)
      return player:addOutline("Black Outline")
    end,
    check = function(player)
      return player:hasOutline("Black Outline")
    end
  },
  {
    name = "White",
    price = 200,
    tooltip = { "This purchase is for your account and is permanent. You will be able to equip it on all characters on this account.", "yellow" },
    outfit = { type = 128, shader = "outline", colorValue = "#FFFFFF" },
    rarity = RARITYS_STORE.MAGIC,
    finish = function(player)
      return player:addOutline("White Outline")
    end,
    check = function(player)
      return player:hasOutline("White Outline")
    end
  },
  {
    name = "Cyan",
    price = 200,
    tooltip = { "This purchase is for your account and is permanent. You will be able to equip it on all characters on this account.", "yellow" },
    outfit = { type = 128, shader = "outline", colorValue = "#00FFFF" },
    rarity = RARITYS_STORE.MAGIC,
    finish = function(player)
      return player:addOutline("Cyan Outline")
    end,
    check = function(player)
      return player:hasOutline("Cyan Outline")
    end
  },
  {
    name = "Rainbow",
    price = 300,
    tooltip = { "This purchase is for your account and is permanent. You will be able to equip it on all characters on this account.", "yellow" },
    outfit = { type = 128, shader = "outline", colorValue = "#FFFFF0" },
    rarity = RARITYS_STORE.LEGENDARY,
    finish = function(player)
      return player:addOutline("Rainbow Outline")
    end,
    check = function(player)
      return player:hasOutline("Rainbow Outline")
    end
  },
}
