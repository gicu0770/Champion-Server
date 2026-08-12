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


shopModule:addBuyableItem({'Added Fire Damage Support'}, 37382, 5000, 1, 'Added Fire Damage Support')
shopModule:addBuyableItem({'Added Earth Damage Support'}, 37387, 5000, 1, 'Added Earth Damage Support')
shopModule:addBuyableItem({'Added Physical Damage Support'}, 37383, 5000, 1, 'Added Physical Damage Support')
shopModule:addBuyableItem({'Added Lighting Damage Support'}, 37388, 5000, 1, 'Added Lighting Damage Support')
shopModule:addBuyableItem({'Added Ice Damage Support'}, 37386, 5000, 1, 'Added Ice Damage Support')
shopModule:addBuyableItem({'Added Holy Damage Support'}, 37389, 5000, 1, 'Added Holy Damage Support')
shopModule:addBuyableItem({'Added Death Damage Support'}, 37390, 5000, 1, 'Added Death Damage Support')


npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:setCallback(CALLBACK_ONADDFOCUS, onAddFocus)
npcHandler:addModule(FocusModule:new())
