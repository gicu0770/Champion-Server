local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)

function onCreatureAppear(cid)              npcHandler:onCreatureAppear(cid)            end
function onCreatureDisappear(cid)           npcHandler:onCreatureDisappear(cid)         end
function onThink()                          npcHandler:onThink()                        end

local shopModule = ShopModule:new()
npcHandler:addModule(shopModule)

function onAddFocus(cid)
  npcHandler:addFocus(cid)
  shopModule.requestTrade(cid, "trade", nil, {module = shopModule})
  return true
end

function onCreatureSay(cid, type, msg)
  if getDistanceBetween(getThingPos(cid), Creature(getNpcCid()):getPosition()) >= 4 then
    return false
  end

  if not cid:isShopping() then
    shopModule.requestTrade(cid:getId(), "trade", nil, {module = shopModule})
  end
  npcHandler:onCreatureSay(cid, type, msg)
end
-------------------- 1 LVL --------------------
-- BASIC AUTO ATTACK AURA
shopModule:addBuyableItem({'Mystic Aura'}, 38082, 2000, 1, 'Mystic Aura')
shopModule:addBuyableItem({'Multishot'}, 38081, 2000, 1, 'Multishot')
shopModule:addBuyableItem({'Cleave'}, 38083, 2000, 1, 'Cleave')
-- INT EARTH
shopModule:addBuyableItem({'Stoning'}, 38110, 2000, 1, 'Stoning')
shopModule:addBuyableItem({'Earth Bolt'}, 37344, 2000, 1, 'Earth Bolt')
-- INT EARTH DOT
shopModule:addBuyableItem({'Venom String'}, 38107, 2000, 1, 'Venom String')
shopModule:addBuyableItem({'Poison Plague'}, 37327, 2000, 1, 'Poison Plague')
-- INT LIGHTING
shopModule:addBuyableItem({'Spark Dart'}, 37370, 2000, 1, 'Spark Dart')
shopModule:addBuyableItem({'Chain Lighting'}, 37307, 2000, 1, 'Chain Lighting')
-- MELEE LIGHTING
shopModule:addBuyableItem({'Thunder Strike'}, 38118, 2000, 1, 'Thunder Strike')
shopModule:addBuyableItem({'Blitz'}, 38119, 2000, 1, 'Blitz')
-- INT ICE
shopModule:addBuyableItem({'Frostbolt'}, 37353, 2000, 1, 'Frostbolt')
shopModule:addBuyableItem({'Frosty Bounce'}, 38117, 2000, 1, 'Frosty Bounce')
-- ICE RANGED
shopModule:addBuyableItem({'Icicle'}, 37408, 2000, 1, 'Icicle')
shopModule:addBuyableItem({'Arctic Volley'}, 38103, 2000, 1, 'Arctic Volley')
-- INT FIRE
shopModule:addBuyableItem({'Fire Lance'}, 37372, 2000, 1, 'Fire Lance')
shopModule:addBuyableItem({'Flame Tongue'}, 38095, 2000, 1, 'Flame Tongue')
-- STR PHYSICAL DOT
shopModule:addBuyableItem({'Rend'}, 37345, 2000, 1, 'Rend')
shopModule:addBuyableItem({'Vital Surge'}, 38129, 2000, 1, 'Vital Surge')
-- STR PHYSICAL
shopModule:addBuyableItem({'Stomp'}, 37306, 2000, 1, 'Stomp')
shopModule:addBuyableItem({'Leap Slam'}, 37333, 2000, 1, 'Leap Slam')
shopModule:addBuyableItem({'Weapon Throw'}, 38100, 2000, 1, 'Weapon Throw')
-- MAGIC DEATH
shopModule:addBuyableItem({'Death Bolt'}, 38122, 2000, 1, 'Death Bolt')
shopModule:addBuyableItem({'Leaping Death'}, 38123, 2000, 1, 'Leaping Death')

-- STR HOLY
shopModule:addBuyableItem({'Sacred Lance'}, 38106, 2000, 1, 'Sacred Lance')
shopModule:addBuyableItem({'Sacred Bolt'}, 38126, 2000, 1, 'Sacred Bolt')

shopModule:addBuyableItem({'Holy Scatter'}, 38104, 10000, 1, 'Holy Scatter')
shopModule:addBuyableItem({'Holy Dash'}, 37340, 2000, 1, 'Holy Dash')
-- STR ICE
shopModule:addBuyableItem({'Frosty Link'}, 38102, 2000, 1, 'Frosty Link')
shopModule:addBuyableItem({'Cold Burst'}, 38112, 2000, 1, 'Cold Burst')
-- STR SHIELD
shopModule:addBuyableItem({'Shield Throw'}, 38090, 2000, 1, 'Shield Throw')
shopModule:addBuyableItem({'Shield Strike'}, 38114, 2000, 1, 'Shield Strike')
-- DEX LIGHTING
shopModule:addBuyableItem({'Lightning Arrow'}, 37357, 2000, 1, 'Lightning Arrow')
shopModule:addBuyableItem({'Lighting Barrage'}, 37329, 2000, 1, 'Lighting Barrage')
-- DEX PHYSICAL
shopModule:addBuyableItem({'Aimed Shot'}, 37320, 2000, 1, 'Aimed Shot')
shopModule:addBuyableItem({'Vortex'}, 37312, 2000, 1, 'Vortex')
shopModule:addBuyableItem({'Split Arrow'}, 38084, 2000, 1, 'Split Arrow')
-- DEX EARTH
shopModule:addBuyableItem({'Toxic Arrows'}, 37360, 2000, 1, 'Toxic Arrows')
-- DEX DEATH
shopModule:addBuyableItem({'Death Strike'}, 37343, 2000, 1, 'Death Strike')
shopModule:addBuyableItem({'Weakness Arrow'}, 37342, 2000, 1, 'Weakness Arrow')
-- DEX DEATH DOT
shopModule:addBuyableItem({'Curse'}, 37311, 2000, 1, 'Curse')
shopModule:addBuyableItem({'Rotten Gas Shot'}, 37358, 2000, 1, 'Rotten Gas Shot')
-- STR FIRE
shopModule:addBuyableItem({'Molten Strike'}, 37341, 2000, 1, 'Molten Strike')
shopModule:addBuyableItem({'Flame Sting'}, 38111, 2000, 1, 'Flame Sting')




npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:setCallback(CALLBACK_ONADDFOCUS, onAddFocus)
npcHandler:addModule(FocusModule:new())
