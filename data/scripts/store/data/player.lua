return {
  {
    name = "Bless",
    price = 5,
    tooltip = "The next time you die, youw ill only lose 10% of the experience points\n(Without Bless you lose 20%)",
    icon = "images/bless",
    stackable = true,
    finish = function(player, offer)
      player:addBuff(BLESS)
      return true
    end,
    returnText = {
      [false] = "You already have this bless."
    },
    check = function(player)
      local buff = player:getBuff(BLESS)
      if buff then
        return buff.stacks
      end

      return 0
    end
  },
  {
    name = "Bless Plus",
    price = 10,
    tooltip = "The next time you die, youw ill only lose 6% of the experience points\n(Without Bless you lose 20%)",
    icon = "images/bless_plus",
    stackable = true,
    finish = function(player, offer)
      player:addBuff(BLESS_PLUS)
      return true
    end,
    returnText = {
      [false] = "You already have this bless."
    },
    check = function(player)
        local buff = player:getBuff(BLESS_PLUS)
        if buff then
          return buff.stacks
        end

        return 0
    end
  },
  {
    name = "Bless Ultra",
    price = 20,
    tooltip = "The next time you die, youw ill only lose 2% of the experience points\n(Without Bless you lose 20%)",
    icon = "images/bless_ultra",
    stackable = true,
    finish = function(player, offer)
      player:addBuff(BLESS_ULTRA)
      return true
    end,
    returnText = {
      [false] = "You already have this bless."
    },
    check = function(player)
      local buff = player:getBuff(BLESS_ULTRA)
      if buff then
        return buff.stacks
      end

      return 0
    end
  },
  {
    name = "Change Sex",
    price = 20,
    tooltip = "Change your character Sex",
    icon = "images/change_sex",
    finish = function(player, offer)
      return player:setSex(player:getSex() == PLAYERSEX_FEMALE and PLAYERSEX_MALE or PLAYERSEX_FEMALE)
    end,
    returnText = {
      [true] = "Successfully changed sex. ( Relogin to see changes )",
      [false] = "Something went wrong, try again."
    }
  },
  {
    name = "Change Name",
    price = 30,
    tooltip = "Change your character name",
    icon = "images/change_name",
    configure = true,
  },
  {
    name = "Orb's Bag",
    rarity = RARITYS_STORE.SPECIAL,
    price = 30, -- 50 albo 100
    tooltip = "All dropped orbs will be automatically picked up and moved to this container.",
    item_id = 38322,
    finish = function(player, offer)
      return Store:addItemToPlayer(player, offer)
    end,
  },
  {
    name = "Keychain",
    rarity = RARITYS_STORE.SPECIAL,
    price = 30, -- 50 albo 100
    tooltip = "All dropped keys will be automatically picked up and moved to this container.",
    item_id = 38445,
    finish = function(player, offer)
      return Store:addItemToPlayer(player, offer)
    end,
  },
  {
    name = "Fragment's Bag",
    rarity = RARITYS_STORE.SPECIAL,
    price = 30, -- 50 albo 100
    tooltip = "All dropped fragment will be automatically picked up and moved to this container.",
    item_id = 38391,
    finish = function(player, offer)
      return Store:addItemToPlayer(player, offer)
    end,
  },
  {
    name = "Relic's Bag",
    rarity = RARITYS_STORE.SPECIAL,
    price = 30, -- 50 albo 100
    tooltip = "All dropped relics will be automatically picked up and moved to this container.",
    item_id = 38387,
    finish = function(player, offer)
      return Store:addItemToPlayer(player, offer)
    end,
  },
  {
    name = "Crystal's Bag",
    rarity = RARITYS_STORE.SPECIAL,
    price = 30, -- 50 albo 100
    tooltip = "All dropped crystals will be automatically picked up and moved to this container.",
    item_id = 38390,
    finish = function(player, offer)
      return Store:addItemToPlayer(player, offer)
    end,
  },
  {
    name = "House Document",
    rarity = RARITYS_STORE.SPECIAL,
    price = 50,
    tooltip = "This document allows you to claim ownership of a house.",
    item_id = 38570,
    finish = function(player, offer)
      return Store:addItemToPlayer(player, offer)
    end,
  },
  {
    name = "Reset Talent Crystal",
    rarity = RARITYS_STORE.SPECIAL,
    price = 30,
    tooltip = "A crystal that resets your Sub-Talent tree.",
    item_id = 31181,
    finish = function(player, offer)
      return Store:addItemToPlayer(player, offer)
    end,
  },
  {
    name = "Reset Trait Crystal",
    rarity = RARITYS_STORE.SPECIAL,
    price = 30,
    tooltip = "A crystal that resets your Sub-Trait",
    item_id = 31180,
    finish = function(player, offer)
      return Store:addItemToPlayer(player, offer)
    end,
  },
  {
    name = "Wildgrove Backpack",
    rarity = RARITYS_STORE.SPECIAL,
    price = 10,
    tooltip = "Backpack with vol:100",
    item_id = 38469,
    finish = function(player, offer)
      return Store:addItemToPlayer(player, offer)
    end,
  },
  {
    name = "Blazing Backpack",
    rarity = RARITYS_STORE.SPECIAL,
    price = 10,
    tooltip = "Backpack with vol:100",
    item_id = 38332,
    finish = function(player, offer)
      return Store:addItemToPlayer(player, offer)
    end,
  },
  {
    name = "Storm Backpack",
    rarity = RARITYS_STORE.SPECIAL,
    price = 10,
    tooltip = "Backpack with vol:100",
    item_id = 38329,
    finish = function(player, offer)
      return Store:addItemToPlayer(player, offer)
    end,
  },
  {
    name = "Pumpkin Backpack",
    rarity = RARITYS_STORE.SPECIAL,
    price = 10,
    tooltip = "Backpack with vol:100",
    item_id = 37749,
    finish = function(player, offer)
      return Store:addItemToPlayer(player, offer)
    end,
  },
  {
    name = "Skull Backpack",
    rarity = RARITYS_STORE.SPECIAL,
    price = 10,
    tooltip = "Backpack with vol:100",
    item_id = 37750,
    finish = function(player, offer)
      return Store:addItemToPlayer(player, offer)
    end,
  },
  {
    name = "Hollowstalker Backpack",
    rarity = RARITYS_STORE.SPECIAL,
    price = 10,
    tooltip = "Backpack with vol:100",
    item_id = 37944,
    finish = function(player, offer)
      return Store:addItemToPlayer(player, offer)
    end,
  },
  {
    name = "Thorn Backpack",
    rarity = RARITYS_STORE.SPECIAL,
    price = 10,
    tooltip = "Backpack with vol:100",
    item_id = 37745,
    finish = function(player, offer)
      return Store:addItemToPlayer(player, offer)
    end,
  },
  {
    name = "Oakheart Backpack",
    rarity = RARITYS_STORE.SPECIAL,
    price = 10,
    tooltip = "Backpack with vol:100",
    item_id = 38470,
    finish = function(player, offer)
      return Store:addItemToPlayer(player, offer)
    end,
  },
  {
    name = "Evil Backpack",
    rarity = RARITYS_STORE.SPECIAL,
    price = 10,
    tooltip = "Backpack with vol:100",
    item_id = 38508,
    finish = function(player, offer)
      return Store:addItemToPlayer(player, offer)
    end,
  },
  {
    name = "Crimson Backpack",
    rarity = RARITYS_STORE.SPECIAL,
    price = 10,
    tooltip = "Backpack with vol:100",
    item_id = 38509,
    finish = function(player, offer)
      return Store:addItemToPlayer(player, offer)
    end,
  },


 
}