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


shopModule:addBuyableItem({'Elemental Weakness Support'}, 37401, 50000, 1, 'Elemental Weakness Support')
shopModule:addBuyableItem({'Physical Weakness Support'}, 37402, 50000, 1, 'Physical Weakness Support')
shopModule:addBuyableItem({'Duality Weakness Support'}, 38056, 50000, 1, 'Duality Weakness Support')
shopModule:addBuyableItem({'Elemental Penetration Support'}, 37395, 50000, 1, 'Elemental Penetration Support')
shopModule:addBuyableItem({'Armor Penetration Support'}, 37396, 50000, 1, 'Armor Penetration Support')
shopModule:addBuyableItem({'Duality Penetration Support'}, 38058, 50000, 1, 'Duality Penetration Support')
shopModule:addBuyableItem({'Basic Penetration Support'}, 38085, 50000, 1, 'Basic Penetration Support')
shopModule:addBuyableItem({'Counterattack Penetration Support'}, 38086, 50000, 1, 'Counterattack Penetration Support')


npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:setCallback(CALLBACK_ONADDFOCUS, onAddFocus)
npcHandler:addModule(FocusModule:new())
