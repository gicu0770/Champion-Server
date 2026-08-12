return {
  {
    name = "Drunk",
    price = 200,
    tooltip = { "This purchase is for your account and is permanent. You will be able to equip it on all characters on this account.", "yellow" },
    outfit = { type = 128, shader = "Drunk" },
    rarity = RARITYS_STORE.RARE,
    finish = function(player)
      return player:addShader("Drunk")
    end,
    check = function(player)
      return player:hasShader("Drunk")
    end
  },
  {
    name = "Green Rage",
    price = 150,
    rarity = RARITYS_STORE.COMMON,
    tooltip = { "This purchase is for your account and is permanent. You will be able to equip it on all characters on this account.", "yellow" },
    outfit = { type = 128, shader = "Green Rage" },
    finish = function(player)
      return player:addShader("Green Rage")
    end,
    check = function(player)
      return player:hasShader("Green Rage")
    end
  },
  {
    name = "Red Rage",
    price = 150,
    rarity = RARITYS_STORE.COMMON,
    tooltip = { "This purchase is for your account and is permanent. You will be able to equip it on all characters on this account.", "yellow" },
    outfit = { type = 128, shader = "Red Rage" },
    finish = function(player)
      return player:addShader("Red Rage")
    end,
    check = function(player)
      return player:hasShader("Red Rage")
    end
  },
  {
    name = "Unwind",
    price = 200,
    rarity = RARITYS_STORE.RARE,
    tooltip = { "This purchase is for your account and is permanent. You will be able to equip it on all characters on this account.", "yellow" },
    outfit = { type = 128, shader = "Unwind" },
    finish = function(player)
      return player:addShader("Unwind")
    end,
    check = function(player)
      return player:hasShader("Unwind")
    end
  },
   {
    name = "Ghost",
    price = 200,
    rarity = RARITYS_STORE.RARE,
    tooltip = { "This purchase is for your account and is permanent. You will be able to equip it on all characters on this account.", "yellow" },
    outfit = { type = 128, shader = "Ghost" },
    finish = function(player)
      return player:addShader("Ghost")
    end,
    check = function(player)
      return player:hasShader("Ghost")
    end
  },
    {
    name = "Rainbow",
    price = 300,
    rarity = RARITYS_STORE.LEGENDARY,
    tooltip = { "This purchase is for your account and is permanent. You will be able to equip it on all characters on this account.", "yellow" },
    outfit = { type = 128, shader = "Rainbow" },
    finish = function(player)
      return player:addShader("Rainbow")
    end,
    check = function(player)
      return player:hasShader("Rainbow")
    end
  },
 
}
