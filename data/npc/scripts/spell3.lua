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
-------------------- 21 LVL --------------------
-- INT EARTH
shopModule:addBuyableItem({'Rootgrasp'}, 38051, 20000, 1, 'Rootgrasp')
shopModule:addBuyableItem({'Wild Vines'}, 37321, 20000, 1, 'Wild Vines')
-- INT LIGHTNING
shopModule:addBuyableItem({'Spark'}, 37325, 20000, 1, 'Spark')
shopModule:addBuyableItem({'Maelstorm'}, 37371, 20000, 1, 'Maelstorm')
-- MELEE LIGHTNING
shopModule:addBuyableItem({'Tornado'}, 37328, 20000, 1, 'Tornado')
-- ICE RANGED
shopModule:addBuyableItem({'Frostbite'}, 37356, 20000, 1, 'Frostbite')
-- ICE MAGIC
shopModule:addBuyableItem({'Frozen Shards Aura'}, 38089, 20000, 1, 'Frozen Shards Aura')
-- ICE MELEE
shopModule:addBuyableItem({'Frozen Stomp'}, 37365, 20000, 1, 'Frozen Stomp')
-- INT FIRE
shopModule:addBuyableItem({'Fire Wall'}, 37355, 20000, 1, 'Fire Wall')
shopModule:addBuyableItem({'Fire Aura'}, 37313, 20000, 1, 'Fire Aura')
-- STR HOLY
shopModule:addBuyableItem({'Illumination'}, 37339, 20000, 1, 'Illumination') -- melee
shopModule:addBuyableItem({'Saint Cross'}, 38094, 20000, 1, 'Saint Cross') -- magic
-- STR PHYSICAL DOT
shopModule:addBuyableItem({'Perforate'}, 37332, 20000, 1, 'Perforate')
-- STR PHYSICAL
shopModule:addBuyableItem({'Amok'}, 37330, 20000, 1, 'Amok')
shopModule:addBuyableItem({'Anger Aura'}, 37314, 20000, 1, 'Anger Aura')
-- STR FIRE
shopModule:addBuyableItem({'Magma Fissue'}, 37364, 20000, 1, 'Magma Fissue')
-- DEX DEATH
shopModule:addBuyableItem({'Affliction Aura'}, 37336, 20000, 1, 'Affliction Aura')
shopModule:addBuyableItem({'Black Hole'}, 37350, 20000, 1, 'Black Hole')

-- DEX PHYSICAL
shopModule:addBuyableItem({'Fan Knives Aura'}, 38088, 20000, 1, 'Fan Knives Aura')

-- DEX EARTH
shopModule:addBuyableItem({'Plagued Burst'}, 37361, 20000, 1, 'Plagued Burst')


-- STR SHIELD
shopModule:addBuyableItem({'Crushing Blow'}, 38091, 20000, 1, 'Crushing Blow')
shopModule:addBuyableItem({'Riposte'}, 38092, 20000, 1, 'Riposte')



npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:setCallback(CALLBACK_ONADDFOCUS, onAddFocus)
npcHandler:addModule(FocusModule:new())
