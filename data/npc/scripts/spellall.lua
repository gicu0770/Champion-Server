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


shopModule:addBuyableItem({'Mystic Aura'}, 38082, 2000, 1, 'Mystic Aura')
shopModule:addBuyableItem({'Multishot'}, 38081, 2000, 1, 'Multishot')
shopModule:addBuyableItem({'Cleave'}, 38083, 2000, 1, 'Cleave')


shopModule:addBuyableItem({'Added Fire Damage Support'}, 37382, 5000, 1, 'Added Fire Damage Support')
shopModule:addBuyableItem({'Added Earth Damage Support'}, 37387, 5000, 1, 'Added Earth Damage Support')
shopModule:addBuyableItem({'Added Physical Damage Support'}, 37383, 5000, 1, 'Added Physical Damage Support')
shopModule:addBuyableItem({'Added Lighting Damage Support'}, 37388, 5000, 1, 'Added Lighting Damage Support')
shopModule:addBuyableItem({'Added Ice Damage Support'}, 37386, 5000, 1, 'Added Ice Damage Support')
shopModule:addBuyableItem({'Added Holy Damage Support'}, 37389, 5000, 1, 'Added Holy Damage Support')
shopModule:addBuyableItem({'Added Death Damage Support'}, 37390, 5000, 1, 'Added Death Damage Support')

shopModule:addBuyableItem({'Blazing Shout'}, 37363, 10000, 1, 'Blazing Shout')
shopModule:addBuyableItem({'Magma Fissue'}, 37364, 10000, 1, 'Magma Fissue')
shopModule:addBuyableItem({'Blessed Aura'}, 37367, 10000, 1, 'Blessed Aura')
shopModule:addBuyableItem({'Hollow Aura'}, 37368, 10000, 1, 'Hollow Aura')
shopModule:addBuyableItem({'Physical Aura'}, 37315, 10000, 1, 'Physical Aura')
shopModule:addBuyableItem({'Elemental Aura'}, 37316, 10000, 1, 'Elemental Aura')
shopModule:addBuyableItem({'Stone Aura'}, 37317, 10000, 1, 'Stone Aura')
shopModule:addBuyableItem({'Magic Aura'}, 37318, 10000, 1, 'Magic Aura')
shopModule:addBuyableItem({'Thornmail Aura'}, 37319, 10000, 1, 'Thornmail Aura')
shopModule:addBuyableItem({'Seismic Wave'}, 37308, 10000, 1, 'Seismic Wave')
shopModule:addBuyableItem({'Cold Snap'}, 37326, 10000, 1, 'Cold Snap')
shopModule:addBuyableItem({'Death Wave'}, 37346, 10000, 1, 'Death Wave')
shopModule:addBuyableItem({'Ice Surge'}, 37347, 10000, 1, 'Ice Surge')
shopModule:addBuyableItem({'Lava Crash'}, 37348, 10000, 1, 'Lava Crash')
shopModule:addBuyableItem({'Frostbolt'}, 37353, 10000, 1, 'Frostbolt')
shopModule:addBuyableItem({'Phantom Run'}, 37359, 10000, 1, 'Phantom Run')
shopModule:addBuyableItem({'Rotten Gas Shot'}, 37358, 10000, 1, 'Rotten Gas Shot')
shopModule:addBuyableItem({'Lightning Arrow'}, 37357, 10000, 1, 'Lightning Arrow')
shopModule:addBuyableItem({'Shield Bash'}, 37349, 10000, 1, 'Shield Bash')
shopModule:addBuyableItem({'Wrath'}, 37351, 10000, 1, 'Wrath')
shopModule:addBuyableItem({'Ball Lightning'}, 37354, 10000, 1, 'Ball Lightning')

shopModule:addBuyableItem({'Chain Lighting'}, 37307, 20000, 1, 'Chain Lighting')
shopModule:addBuyableItem({'Poison Plague'}, 37327, 20000, 1, 'Poison Plague')
shopModule:addBuyableItem({'Illumination'}, 37339, 20000, 1, 'Illumination')
shopModule:addBuyableItem({'Amok'}, 37330, 20000, 1, 'Amok')
shopModule:addBuyableItem({'Spark'}, 37325, 20000, 1, 'Spark')
shopModule:addBuyableItem({'Fire Aura'}, 37313, 20000, 1, 'Fire Aura')
shopModule:addBuyableItem({'Anger Aura'}, 37314, 20000, 1, 'Anger Aura')
shopModule:addBuyableItem({'Affliction Aura'}, 37336, 20000, 1, 'Affliction Aura')
shopModule:addBuyableItem({'Black Hole'}, 37350, 20000, 1, 'Black Hole')
shopModule:addBuyableItem({'Holy Shine'}, 37352, 20000, 1, 'Holy Shine')
shopModule:addBuyableItem({'Fire Wall'}, 37355, 20000, 1, 'Fire Wall')
shopModule:addBuyableItem({'Frostbite'}, 37356, 20000, 1, 'Frostbite')
shopModule:addBuyableItem({'Frozen Stomp'}, 37365, 20000, 1, 'Frozen Stomp')
shopModule:addBuyableItem({'Shockchain Arrow'}, 37362, 20000, 1, 'Shockchain Arrow')
shopModule:addBuyableItem({'Plagued Burst'}, 37361, 20000, 1, 'Plagued Burst')
shopModule:addBuyableItem({'Toxic Arrows'}, 37360, 20000, 1, 'Toxic Arrows')
shopModule:addBuyableItem({'Shattering Dash'}, 37366, 20000, 1, 'Shattering Dash')

shopModule:addBuyableItem({'Rain Of Arrows'}, 37338, 30000, 1, 'Rain Of Arrows')
shopModule:addBuyableItem({'Flicker Strike'}, 37324, 30000, 1, 'Flicker Strike')
shopModule:addBuyableItem({'Arcane Barrage'}, 37329, 30000, 1, 'Arcane Barrage')
shopModule:addBuyableItem({'Acid Pool'}, 37337, 30000, 1, 'Acid Pool')
shopModule:addBuyableItem({'Perforate'}, 37332, 30000, 1, 'Perforate')
shopModule:addBuyableItem({'Ricochet'}, 37322, 50000, 1, 'Ricochet')
shopModule:addBuyableItem({'Tornado'}, 37328, 50000, 1, 'Tornado')
shopModule:addBuyableItem({'Winter Wind'}, 37335, 50000, 1, 'Winter Wind')
shopModule:addBuyableItem({'Sunder'}, 37334, 50000, 1, 'Sunder')





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

shopModule:addBuyableItem({'Elemental Weakness Support'}, 37401, 50000, 1, 'Elemental Weakness Support')
shopModule:addBuyableItem({'Physical Weakness Support'}, 37402, 50000, 1, 'Physical Weakness Support')
shopModule:addBuyableItem({'Elemental Penetration Support'}, 37395, 50000, 1, 'Elemental Penetration Support')
shopModule:addBuyableItem({'Armor Penetration Support'}, 37396, 50000, 1, 'Armor Penetration Support')


npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:setCallback(CALLBACK_ONADDFOCUS, onAddFocus)
npcHandler:addModule(FocusModule:new())
