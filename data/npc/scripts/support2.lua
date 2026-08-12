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

shopModule:addBuyableItem({'Cooldown Reduction Support'}, 37380, 15000, 1, 'Cooldown Reduction Support')
shopModule:addBuyableItem({'Cost Reduction Support'}, 37381, 15000, 1, 'Cost Reduction Support')
shopModule:addBuyableItem({'Crit Chance Support'}, 37392, 15000, 1, 'Crit Chance Support')
shopModule:addBuyableItem({'Crit Damage Support'}, 37393, 15000, 1, 'Crit Damage Support')





npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:setCallback(CALLBACK_ONADDFOCUS, onAddFocus)
npcHandler:addModule(FocusModule:new())
