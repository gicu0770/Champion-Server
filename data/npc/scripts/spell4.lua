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
-------------------- 30 LVL --------------------
-- STR PHYSICAL
shopModule:addBuyableItem({'Flicker Strike'}, 37324, 30000, 1, 'Flicker Strike')
-- INT EARTH
shopModule:addBuyableItem({'Acid Pool'}, 37337, 30000, 1, 'Acid Pool')
-- DEX PHYSICAL
shopModule:addBuyableItem({'Ricochet'}, 37322, 30000, 1, 'Ricochet')
-- ICE MAGIC
shopModule:addBuyableItem({'Winter Wind'}, 37335, 30000, 1, 'Winter Wind')
-- MAGIC holy
-- melee holy


npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:setCallback(CALLBACK_ONADDFOCUS, onAddFocus)
npcHandler:addModule(FocusModule:new())
