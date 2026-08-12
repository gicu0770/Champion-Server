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
-------------------- 12 LVL --------------------
-- STR fire
shopModule:addBuyableItem({'Blazing Shout'}, 37363, 10000, 1, 'Blazing Shout')
-- INT LIGHTING
shopModule:addBuyableItem({'Ball Lightning'}, 37354, 10000, 1, 'Ball Lightning')
-- INT MAGIC EARTH DOT
shopModule:addBuyableItem({'Toxic Split'}, 38109, 10000, 1, 'Toxic Split')
-- ICE RANGED
shopModule:addBuyableItem({'Ice Surge'}, 37347, 10000, 1, 'Ice Surge')
shopModule:addBuyableItem({'Frosty Sky'}, 38131, 10000, 1, 'Frosty Sky')
-- ICE MAGIC
shopModule:addBuyableItem({'Frigid Split'}, 38054, 10000, 1, 'Frigid Split')
-- ICE MELEE 
shopModule:addBuyableItem({'Shattering Dash'}, 37366, 10000, 1, 'Shattering Dash')
-- LIGHTNING MELEE 
shopModule:addBuyableItem({'Static Condition'}, 38120, 10000, 1, 'Static Condition')
-- INT FIRE
shopModule:addBuyableItem({'Lava Crash'}, 37348, 10000, 1, 'Lava Crash')
shopModule:addBuyableItem({'Fireball'}, 1987, 10000, 1, 'Fireball')
-- INT EARTH HIT
shopModule:addBuyableItem({'Sunder'}, 37334, 10000, 1, 'Sunder')
-- DEX DEATH
shopModule:addBuyableItem({'Phantom Run'}, 37359, 10000, 1, 'Phantom Run')
shopModule:addBuyableItem({'Essence Drain'}, 38055, 20000, 1, 'Essence Drain')
-- DEX DEATH DOT
shopModule:addBuyableItem({'Death Wave'}, 37346, 10000, 1, 'Death Wave')
-- Death magic
shopModule:addBuyableItem({'Rotten Vine'}, 38124, 10000, 1, 'Rotten Vine')
-- DEX LIGHTING
shopModule:addBuyableItem({'Shockchain Arrow'}, 37362, 10000, 1, 'Shockchain Arrow')
-- DEX PHYSICAL
shopModule:addBuyableItem({'Salvo'}, 37309, 10000, 1, 'Salvo')
-- DEX EARTH DOT
shopModule:addBuyableItem({'Bouncing Venom'}, 38105, 10000, 1, 'Bouncing Venom')
-- STR PHYSICAL DOT
shopModule:addBuyableItem({'Bloody Skulls'}, 38127, 10000, 1, 'Bloody Skulls')
-- STR PHYSICAL
shopModule:addBuyableItem({'Seismic Wave'}, 37308, 10000, 1, 'Seismic Wave')
shopModule:addBuyableItem({'Dancing Steel'}, 38101, 10000, 1, 'Dancing Steel')
-- STR SHIELD
shopModule:addBuyableItem({'Shield Bash'}, 37349, 10000, 1, 'Shield Bash')
-- STR HOLY

shopModule:addBuyableItem({'Holy Shine'}, 37352, 10000, 1, 'Holy Shine')
shopModule:addBuyableItem({'Smite'}, 37310, 10000, 1, 'Smite')

shopModule:addBuyableItem({'Blessed Aura'}, 37367, 10000, 1, 'Blessed Aura')
shopModule:addBuyableItem({'Hollow Aura'}, 37368, 10000, 1, 'Hollow Aura')
shopModule:addBuyableItem({'Physical Aura'}, 37315, 10000, 1, 'Physical Aura')
shopModule:addBuyableItem({'Elemental Aura'}, 37316, 10000, 1, 'Elemental Aura')
shopModule:addBuyableItem({'Stone Aura'}, 37317, 10000, 1, 'Stone Aura')
shopModule:addBuyableItem({'Magic Aura'}, 37318, 10000, 1, 'Magic Aura')
shopModule:addBuyableItem({'Thornmail Aura'}, 37319, 10000, 1, 'Thornmail Aura')

shopModule:addBuyableItem({'Combat Aura'}, 37331, 10000, 1, 'Combat Aura')
shopModule:addBuyableItem({'Frenzy Aura'}, 37369, 10000, 1, 'Frenzy Aura')

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:setCallback(CALLBACK_ONADDFOCUS, onAddFocus)
npcHandler:addModule(FocusModule:new())
