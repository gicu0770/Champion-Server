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

-- 37397, -- Bloodthirst Support ONLYDROP
-- shopModule:addBuyableItem({'Enhanced Support'}, 37405, 30000, 1, 'Enhanced Support')

shopModule:addBuyableItem({'Quality Support'}, 37391, 30000, 1, 'Quality Support')
shopModule:addBuyableItem({'DoT Damage Support'}, 37384, 30000, 1, 'DoT Damage Support')
shopModule:addBuyableItem({'Lifetap Support'}, 37379, 30000, 1, 'Lifetap Support')

shopModule:addBuyableItem({'Elemental Damage Support'}, 37377, 30000, 1, 'Elemental Damage Support')
shopModule:addBuyableItem({'Brute Damage Support'}, 37378, 30000, 1, 'Brute Damage Support')
shopModule:addBuyableItem({'Duality Damage Support'}, 38057, 30000, 1, 'Duality Damage Support')
shopModule:addBuyableItem({'Lifetap Support'}, 37379, 30000, 1, 'Lifetap Support')
shopModule:addBuyableItem({'Enhanced Support'}, 37405, 30000, 1, 'Enhanced Support')

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:setCallback(CALLBACK_ONADDFOCUS, onAddFocus)
npcHandler:addModule(FocusModule:new())
