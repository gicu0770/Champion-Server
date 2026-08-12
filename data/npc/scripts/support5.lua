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


shopModule:addBuyableItem({'Splash Damage Support'}, 37400, 500000, 1, 'Splash Damage Support')
shopModule:addBuyableItem({'Double Damage Support'}, 37406, 500000, 1, 'Double Damage Support')
shopModule:addBuyableItem({'Gamblers Fury Support'}, 37404, 500000, 1, 'Gamblers Fury Support')


shopModule:addBuyableItem({'Added Fire Damage Support'}, 37382, 5000, 1, 'Added Fire Damage Support')
shopModule:addBuyableItem({'Added Earth Damage Support'}, 37387, 5000, 1, 'Added Earth Damage Support')
shopModule:addBuyableItem({'Added Physical Damage Support'}, 37383, 5000, 1, 'Added Physical Damage Support')
shopModule:addBuyableItem({'Added Lighting Damage Support'}, 37388, 5000, 1, 'Added Lighting Damage Support')
shopModule:addBuyableItem({'Added Ice Damage Support'}, 37386, 5000, 1, 'Added Ice Damage Support')
shopModule:addBuyableItem({'Added Holy Damage Support'}, 37389, 5000, 1, 'Added Holy Damage Support')
shopModule:addBuyableItem({'Added Death Damage Support'}, 37390, 5000, 1, 'Added Death Damage Support')
shopModule:addBuyableItem({'Cooldown Reduction Support'}, 37380, 15000, 1, 'Cooldown Reduction Support')
shopModule:addBuyableItem({'Cost Reduction Support'}, 37381, 15000, 1, 'Cost Reduction Support')
shopModule:addBuyableItem({'Crit Chance Support'}, 37392, 15000, 1, 'Crit Chance Support')
shopModule:addBuyableItem({'Crit Damage Support'}, 37393, 15000, 1, 'Crit Damage Support')
shopModule:addBuyableItem({'Quality Support'}, 37391, 30000, 1, 'Quality Support')
shopModule:addBuyableItem({'DoT Damage Support'}, 37384, 30000, 1, 'DoT Damage Support')
shopModule:addBuyableItem({'Lifetap Support'}, 37379, 30000, 1, 'Lifetap Support')
shopModule:addBuyableItem({'Elemental Damage Support'}, 37377, 30000, 1, 'Elemental Damage Support')
shopModule:addBuyableItem({'Brute Damage Support'}, 37378, 30000, 1, 'Brute Damage Support')
shopModule:addBuyableItem({'Duality Damage Support'}, 38057, 30000, 1, 'Duality Damage Support')
shopModule:addBuyableItem({'Lifetap Support'}, 37379, 30000, 1, 'Lifetap Support')
shopModule:addBuyableItem({'Enhanced Support'}, 37405, 30000, 1, 'Enhanced Support')
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
