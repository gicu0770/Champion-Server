return {
  {
    name = "Self Exp Boost",
    price = 30,
    tooltip = "Increase your experience gain by 20% for 1 hour. If it's already active, its duration will be increased.",
    icon = "/images/buffs/selfexp",
    disabled = false,
    finish = function(player, offer)
      local extraTextInfo = "activated"
      local showText = true
      if player:hasBuff(BUFF_EXP_BOOST) then
        extraTextInfo = "extended"
        showText = false
      end
      local textChat = "You have " .. extraTextInfo .. " a Self EXP Boost"
      local textBr = " You have " .. extraTextInfo .. " a {Self EXP Boost}!\nYou gain +20% EXP for the next 60 minutes!\nTime to grind!"
      player:sendExtendedOpcode(71, json.encode({text = textBr, color = "#f7ef8a"}))
      player:sendTextMessage(MESSAGE_EVENT_ORANGE, textChat)
      if showText then
        player:sendTextMessage(MESSAGE_EVENT_ORANGE, "You gain +20% EXP for the next 60 minutes!")
      end
      player:addBuff(BUFF_EXP_BOOST, 60 * 60 * 1000)
      return true
    end,
  },
  {
    name = "Self Gold Boost",
    price = 30,
    tooltip = "Increase your gold gain by 20% for 1 hour. If it's already active, its duration will be increased.",
    icon = "/images/buffs/selfgold",
    disabled = false,
    finish = function(player, offer)
      local extraTextInfo = "activated"
      local showText = true
      if player:hasBuff(SELF_GOLD_BOOST) then
        extraTextInfo = "extended"
        showText = false
      end
      local textChat = "You have " .. extraTextInfo .. " a Self Gold Boost"
      local textBr = " You have " .. extraTextInfo .. " a {Self Gold Boost}!\nYou gain +20% Gold for the next 60 minutes!\nTime to grind!"
      player:sendExtendedOpcode(71, json.encode({text = textBr, color = "#f7ef8a"}))
      player:sendTextMessage(MESSAGE_EVENT_ORANGE, textChat)
      if showText then
        player:sendTextMessage(MESSAGE_EVENT_ORANGE, "You gain +20% Gold for the next 60 minutes!")
      end
      player:addBuff(SELF_GOLD_BOOST, 60 * 60 * 1000)
      return true
    end,
  },
  {
    name = "Self Loot Boost",
    price = 30,
    tooltip = "Increase your loot chance by 20% for 1 hour. If it's already active, its duration will be increased.",
    icon = "/images/buffs/selfloot",
    disabled = false,
    finish = function(player, offer)
      local extraTextInfo = "activated"
      local showText = true
      if player:hasBuff(SELF_LOOT_BOOST) then
        extraTextInfo = "extended"
        showText = false
      end
      local textChat = "You have " .. extraTextInfo .. " a Self Loot Boost"
      local textBr = " You have " .. extraTextInfo .. " a {Self Loot Boost}!\nYou gain +20% Loot for the next 60 minutes!\nTime to grind!"
      player:sendExtendedOpcode(71, json.encode({text = textBr, color = "#f7ef8a"}))
      player:sendTextMessage(MESSAGE_EVENT_ORANGE, textChat)
      if showText then
        player:sendTextMessage(MESSAGE_EVENT_ORANGE, "You gain +20% Loot for the next 60 minutes!")
      end
      player:addBuff(SELF_LOOT_BOOST, 60 * 60 * 1000)
      return true
    end,
  },
  {
    name = "Global Exp Boost",
    price = 20,
    tooltip = "Increase everyone's experience gain by 20% for 1 hour. If it's already active, its duration will be extended.",
    icon = "/images/buffs/expglobal",
    disabled = false,
    finish = function(player, offer)
      local extraTextInfo = "activated"
      local showText = true
      if getGlobalBuff(BUFF_GLOBAL_EXP) then
        extraTextInfo = "extended"
        showText = false
      end
      local textChat = player:getName() .. " has " .. extraTextInfo .. " a Global EXP Boost"
      local textBr = " {" .. player:getName() .. "} has " .. extraTextInfo .. " a {Global EXP Boost}!\nAll players gain +20% EXP for the next 60 minutes!\nSay thank you and make the most of it, time to grind!"
      for _, targetPlayer in ipairs(Game.getPlayers()) do
        targetPlayer:sendExtendedOpcode(71, json.encode({text = textBr, color = "#f7ef8a"}))
        targetPlayer:sendTextMessage(MESSAGE_EVENT_ORANGE, textChat)
        if showText then
          targetPlayer:sendTextMessage(MESSAGE_EVENT_ORANGE, "All players gain +20% More EXP for the next 60 minutes!")
        end
        targetPlayer:sendTextMessage(MESSAGE_EVENT_ORANGE, "Say thank you and make the most of it, time to grind!")
      end
      addGlobalBuff(BUFF_GLOBAL_EXP, 60 * 60 * 1000)
      return true
    end,
  },
  {
    name = "Global Gold Boost",
    price = 20,
    tooltip = "Increase everyone's gold gain by 20% for 1 hour. If it's already active, its duration will be extended.",
    icon = "/images/buffs/goldglobal",
    disabled = false,
    finish = function(player, offer)
      local extraTextInfo = "activated"
      local showText = true
      if getGlobalBuff(BUFF_GLOBAL_GOLD) then
        extraTextInfo = "extended"
        showText = false
      end
      local textChat = player:getName() .. " has " .. extraTextInfo .. " a Global Gold Boost"
      local textBr = " {" .. player:getName() .. "} has " .. extraTextInfo .. " a {Global Gold Boost}!\nAll players gain +20% Gold for the next 60 minutes!\nSay thank you and make the most of it, time to grind!"
      for _, targetPlayer in ipairs(Game.getPlayers()) do
        targetPlayer:sendExtendedOpcode(71, json.encode({text = textBr, color = "#f7ef8a"}))
        targetPlayer:sendTextMessage(MESSAGE_EVENT_ORANGE, textChat)
        if showText then
          targetPlayer:sendTextMessage(MESSAGE_EVENT_ORANGE, "All players gain +20% More Gold for the next 60 minutes!")
        end
        targetPlayer:sendTextMessage(MESSAGE_EVENT_ORANGE, "Say thank you and make the most of it, time to grind!")
      end
      addGlobalBuff(BUFF_GLOBAL_GOLD, 60 * 60 * 1000)
      return true
    end,
  },
  {
    name = "Global Loot Boost",
    price = 20,
    tooltip = "Increase everyone's loot by 20% for 1 hour. If it's already active, its duration will be extended.",
    icon = "/images/buffs/globalloot",
    disabled = false,
    finish = function(player, offer)
      local extraTextInfo = "activated"
      local showText = true
      if getGlobalBuff(BUFF_GLOBAL_LOOT) then
        extraTextInfo = "extended"
        showText = false
      end
      local textChat = player:getName() .. " has " .. extraTextInfo .. " a Global Loot Boost"
      local textBr = " {" .. player:getName() .. "} has " .. extraTextInfo .. " a {Global Loot Boost}!\nAll players gain +20% Loot for the next 60 minutes!\nSay thank you and make the most of it, time to grind!"
      for _, targetPlayer in ipairs(Game.getPlayers()) do
        targetPlayer:sendExtendedOpcode(71, json.encode({text = textBr, color = "#f7ef8a"}))
        targetPlayer:sendTextMessage(MESSAGE_EVENT_ORANGE, textChat)
        if showText then
          targetPlayer:sendTextMessage(MESSAGE_EVENT_ORANGE, "All players gain +20% More Loot for the next 60 minutes!")
        end
        targetPlayer:sendTextMessage(MESSAGE_EVENT_ORANGE, "Say thank you and make the most of it, time to grind!")
      end
      addGlobalBuff(BUFF_GLOBAL_LOOT, 60 * 60 * 1000)
      return true
    end,
  },
}