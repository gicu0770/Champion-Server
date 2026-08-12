local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)

function onCreatureAppear(cid)              npcHandler:onCreatureAppear(cid)            end
function onCreatureDisappear(cid)           npcHandler:onCreatureDisappear(cid)         end
function onThink()                          npcHandler:onThink()                        end

function onPlayerSellMultiple(cid, items)
  npcHandler:onPlayerSellMultiple(cid, items)
end

local function onTradeRequest(cid)
    return true
end

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

for key, value in pairs(BASE_ITEMS) do
  for x = 1, #BASE_ITEMS[key] do
    local item = BASE_ITEMS[key][x]
    if item then
      shopModule:addSellableItem({item[1]}, item[2], 1, item[1])
    end
  end
end

function onSellMultipleItems(cid, items)

end

shopModule:addSellableItem({"Dexterity Ring"}, 7968, 1, "Dexterity Ring")

shopModule:addSellableItem({'Queen Lair Key'}, 37929, 200)
shopModule:addSellableItem({'Pyramid Ruins Key'}, 2086, 300)
shopModule:addSellableItem({'Golden Horizon Key'}, 2087, 400)
shopModule:addSellableItem({'Flame Cave Key'}, 37926, 500)
shopModule:addSellableItem({'Ice Castle Key'}, 2088, 600)
shopModule:addSellableItem({'Amethyst Peaks Key'}, 2089, 700)
shopModule:addSellableItem({'Swamp Pit Key'}, 37928, 800)
shopModule:addSellableItem({'Infernal Tar Key'}, 2092, 900)
shopModule:addSellableItem({'Undead Cave Key'}, 37927, 1000)
shopModule:addSellableItem({'Celestial Ascent Key'}, 2091, 1200)
shopModule:addSellableItem({'Glacier Pass Key'}, 2090, 1500)


shopModule:addSellableItem({''}, 7618, 5)
shopModule:addSellableItem({''}, 7620, 5)
shopModule:addSellableItem({''}, 7623, 15)


shopModule:addSellableItem({''}, 7588, 10)
shopModule:addSellableItem({''}, 7589, 10)
shopModule:addSellableItem({''}, 7622, 10)

shopModule:addSellableItem({''}, 7591, 30)
shopModule:addSellableItem({''}, 7590, 30)
shopModule:addSellableItem({''}, 8472, 30)

shopModule:addSellableItem({''}, 26029, 50)
shopModule:addSellableItem({''}, 8473, 50)
shopModule:addSellableItem({''}, 26030, 50)

shopModule:addSellableItem({''}, 26031, 150)
shopModule:addSellableItem({''}, 27217, 150)
shopModule:addSellableItem({''}, 7621, 150)

shopModule:addSellableItem({''}, 36912, 250)
shopModule:addSellableItem({''}, 36913, 250)
shopModule:addSellableItem({''}, 36916, 250)

shopModule:addSellableItem({''}, 36908, 500)
shopModule:addSellableItem({''}, 36924, 500)
shopModule:addSellableItem({''}, 12328, 500)
shopModule:addSellableItem({''}, 26915, 500)
shopModule:addSellableItem({''}, 36907, 500)


shopModule:addSellableItem({''}, 34256, 250)
shopModule:addSellableItem({''}, 21705, 250)
shopModule:addSellableItem({''}, 32367, 500)

-- Runes
-- 1 Lev
shopModule:addSellableItem({'Fireball'}, 1987, 200)
shopModule:addSellableItem({'Stomp'}, 37306, 200)
shopModule:addSellableItem({'Salvo'}, 37309, 200)
shopModule:addSellableItem({'Smite'}, 37310, 200)
shopModule:addSellableItem({'Curse'}, 37311, 200)
shopModule:addSellableItem({'Vortex'}, 37312, 200)
shopModule:addSellableItem({'Piercing Shot'}, 37320, 200)
shopModule:addSellableItem({'Charge'}, 37331, 200)
shopModule:addSellableItem({'Leap Slam'}, 37333, 200)
shopModule:addSellableItem({'Holy Dash'}, 37340, 200)
shopModule:addSellableItem({'Molten Strike'}, 37341, 200)
shopModule:addSellableItem({'Double Strike'}, 37343, 200)
shopModule:addSellableItem({'Earth Bolt'}, 37344, 200)
shopModule:addSellableItem({'Rend'}, 37345, 200)
shopModule:addSellableItem({'Weakness Arrow'}, 37342, 200)

shopModule:addSellableItem({'Multishot'}, 38081, 200)
shopModule:addSellableItem({'Mystic Focus'}, 38082, 200)
shopModule:addSellableItem({'Cleave'}, 38083, 200)
shopModule:addSellableItem({'Split Arrow'}, 38084, 200)

-- 12 Lev
shopModule:addSellableItem({'Cold Snap'}, 37326, 300)
shopModule:addSellableItem({'Toxic Path'}, 37321, 300)
shopModule:addSellableItem({'Physical Aura'}, 37315, 300)
shopModule:addSellableItem({'Elemental Aura'}, 37316, 300)
shopModule:addSellableItem({'Stone Aura'}, 37317, 300)
shopModule:addSellableItem({'Blessed Aura'}, 37367, 300)
shopModule:addSellableItem({'Hollow Aura'}, 37368, 300)
shopModule:addSellableItem({'Magic Aura'}, 37318, 300)
shopModule:addSellableItem({'Thormail Aura'}, 37319, 300)
shopModule:addSellableItem({'Seismic Wave'}, 37308, 300)
shopModule:addSellableItem({'Shield Bash'}, 37349, 300)
shopModule:addSellableItem({'Death Wave'}, 37346, 300)
shopModule:addSellableItem({'Ice Surge'}, 37347, 300)
shopModule:addSellableItem({'Lava Crash'}, 37348, 300)
shopModule:addSellableItem({'Frostbolt'}, 37353, 300)
shopModule:addSellableItem({'Phantom Run'}, 37359, 300)
shopModule:addSellableItem({'Rotten Gas Shot'}, 37358, 300)
shopModule:addSellableItem({'Lightning Arrow'}, 37357, 300)
shopModule:addSellableItem({'Ball Lighting'}, 37354, 300)
shopModule:addSellableItem({'Shield Throw'}, 38090, 300)
-- 21 Lev
shopModule:addSellableItem({'Poison Plague'}, 37327, 400)
shopModule:addSellableItem({'Amok'}, 37330, 400)
shopModule:addSellableItem({'Chain Lightning'}, 37307, 400)
shopModule:addSellableItem({'Affliction Aura'}, 37336, 400)
shopModule:addSellableItem({'Illumination'}, 37339, 400)
shopModule:addSellableItem({'Spark'}, 37325, 400)
shopModule:addSellableItem({'Fire Aura'}, 37313, 400)
shopModule:addSellableItem({'Anger Aura'}, 37314, 400)
shopModule:addSellableItem({'Holy Shine'}, 37352, 400)
shopModule:addSellableItem({'Fire Wall'}, 37355, 400)
shopModule:addSellableItem({'Black Hole'}, 37350, 400)
shopModule:addSellableItem({'Frostbite'}, 37356, 400)

shopModule:addSellableItem({'Frozen Stomp'}, 37365, 400)
shopModule:addSellableItem({'Magma Fissue'}, 37364, 400)
shopModule:addSellableItem({'Blazing Shout'}, 37363, 400)
shopModule:addSellableItem({'Shockchain Arrow'}, 37362, 400)
shopModule:addSellableItem({'Plagued Burst'}, 37361, 400)
shopModule:addSellableItem({'Toxic Arrows'}, 37360, 400)
shopModule:addSellableItem({'Shattering Dash'}, 37366, 400)

shopModule:addSellableItem({'Crushing Blow'}, 38091, 400)
shopModule:addSellableItem({'Frozen Shards Aura'}, 38089, 400)
shopModule:addSellableItem({'Fan Knives Aura'}, 38088, 400)
shopModule:addSellableItem({'Essence Drain'}, 38055, 400)
shopModule:addSellableItem({'Rootgrasp'}, 38051, 400)
-- 30 Lev
shopModule:addSellableItem({'Tempest'}, 38076, 450)
shopModule:addSellableItem({'Blizzard'}, 38077, 450)
shopModule:addSellableItem({'Oblivion'}, 38078, 450)
shopModule:addSellableItem({'Venom Nova'}, 38079, 450)
shopModule:addSellableItem({'Groundbreaker'}, 38080, 450)
shopModule:addSellableItem({'Wrath'}, 37351, 450)
shopModule:addSellableItem({'Firestorm'}, 37323, 450)
shopModule:addSellableItem({'Stonefall'}, 38050, 450)


shopModule:addSellableItem({'Perforate'}, 37332, 450)
shopModule:addSellableItem({'Flicker Strike'}, 37324, 450)
shopModule:addSellableItem({'Acid Pool'}, 37337, 450)
shopModule:addSellableItem({'Rain of Arrow'}, 37338, 450)
shopModule:addSellableItem({'Arcane Barrage'}, 37329, 450)
shopModule:addSellableItem({'Frostbite'}, 37356, 450)
shopModule:addSellableItem({'Ricochet'}, 37322, 450)
shopModule:addSellableItem({'Sunder'}, 37334, 450)
shopModule:addSellableItem({'Winter Wind'}, 37335, 450)
shopModule:addSellableItem({'Tornado'}, 37328, 450) 
-- 40 Lev
shopModule:addSellableItem({'Toxic Path'}, 37321, 500) 
shopModule:addSellableItem({'Bloody Path'}, 37408, 500) 
shopModule:addSellableItem({'Passing Path'}, 37372, 500) 
shopModule:addSellableItem({'Thunder Path'}, 37371, 500) 
shopModule:addSellableItem({'Cryo Path'}, 37370, 500) 
shopModule:addSellableItem({'Pyro Path'}, 37369, 500) 
shopModule:addSellableItem({'Sacred path'}, 37331, 500) 
--shopModule:addSellableItem({''}, 37346, 300)
--shopModule:addSellableItem({''}, 37347, 300)
--shopModule:addSellableItem({''}, 37348, 300)


-- Support
-- 1 Lev
shopModule:addSellableItem({''}, 37382, 200) --Added Fire Damage Support
shopModule:addSellableItem({''}, 37383, 200) --Added Physical Damage Support
shopModule:addSellableItem({''}, 37386, 200) --Added Ice Damage Support
shopModule:addSellableItem({''}, 37387, 200) --Added Earth Damage Support
shopModule:addSellableItem({''}, 37388, 200) --Added Lighting Damage Support
shopModule:addSellableItem({''}, 37389, 200) --Added Holy Damage Support
shopModule:addSellableItem({''}, 37390, 200) --Added Death Damage Support
-- 12 Lev
shopModule:addSellableItem({''}, 37380, 300) --Cooldown Reduction Support
shopModule:addSellableItem({''}, 37381, 300) --Cost Reduction Support
shopModule:addSellableItem({''}, 37392, 300) --Crit Chance Support
shopModule:addSellableItem({''}, 37393, 300) --Crit Damage Support
shopModule:addSellableItem({''}, 37397, 300) --Bloodthirst Support"
-- 30 Lev
shopModule:addSellableItem({''}, 37384, 400) --DoT Damage Support
shopModule:addSellableItem({''}, 37379, 400) --Lifetap Support
shopModule:addSellableItem({''}, 37391, 400) --Quality Support
shopModule:addSellableItem({''}, 37405, 400) --Enhanced Support
shopModule:addSellableItem({''}, 37377, 400) --Elemental Damage Support
shopModule:addSellableItem({''}, 37378, 400) --Brute Damage Support

shopModule:addSellableItem({''}, 38085, 400) --Basic Penetration Support
shopModule:addSellableItem({''}, 38086, 400) --Counterattack Penetration Support
shopModule:addSellableItem({''}, 38087, 400) --Attack Speed Support
-- 40 Lev
shopModule:addSellableItem({''}, 37401, 450) --Elemental Weakness Support
shopModule:addSellableItem({''}, 37402, 450) --Physical Weakness Support
shopModule:addSellableItem({''}, 37394, 450) --Pinpoint Support
shopModule:addSellableItem({''}, 37395, 450) --Elemental Penetration Support
shopModule:addSellableItem({''}, 37396, 450) --Armor Penetration Support

shopModule:addSellableItem({''}, 38059, 450) --Wave Damage
shopModule:addSellableItem({''}, 38060, 450) --Area Damage
shopModule:addSellableItem({''}, 38067, 450) --Close Damage
shopModule:addSellableItem({''}, 38075, 450) --Move Damage
shopModule:addSellableItem({''}, 38061, 450) --Bleed Power
shopModule:addSellableItem({''}, 38062, 450) --Poison Power
shopModule:addSellableItem({''}, 38063, 450) --Ignite Power
shopModule:addSellableItem({''}, 38064, 450) --Life Drain
shopModule:addSellableItem({''}, 38065, 450) --Energy Drain
shopModule:addSellableItem({''}, 38066, 450) --Mana Drain

shopModule:addSellableItem({''}, 38068, 450) --Vitality aura
shopModule:addSellableItem({''}, 38069, 450) --Vlarity aura
shopModule:addSellableItem({''}, 38070, 450) --Barrier aura
shopModule:addSellableItem({''}, 38071, 450) --Momentum aura
shopModule:addSellableItem({''}, 38072, 450) --Physical Mastery
shopModule:addSellableItem({''}, 38073, 450) --Elemental Mastery
shopModule:addSellableItem({''}, 38074, 450) --Duality Mastery

shopModule:addSellableItem({''}, 38053, 450) --Split
shopModule:addSellableItem({''}, 38052, 450) -- Bounce

-- 50 Lev
shopModule:addSellableItem({''}, 37373, 500) --Increased Area Of Effect Support
shopModule:addSellableItem({''}, 37374, 500) --Multicast Support
shopModule:addSellableItem({''}, 37400, 500) --Splash Damage Support
shopModule:addSellableItem({''}, 37404, 500) --Gambler's Fury Support
shopModule:addSellableItem({''}, 37406, 500) --Double Damage Support

-- Nigdzie nie wypadaja póki co
shopModule:addSellableItem({''}, 37407, 500) --Cast On Crit Support
shopModule:addSellableItem({''}, 37375, 500) --Cast When Damage Taken Support
shopModule:addSellableItem({''}, 37376, 500) --Cast On Kill Support


npcHandler:setCallback(CALLBACK_ONSELLMULTIPLE, onSellMultipleItems)
npcHandler:setCallback(CALLBACK_ONTRADEREQUEST, onTradeRequest)
npcHandler:setCallback(CALLBACK_ONADDFOCUS, onAddFocus)
npcHandler:addModule(FocusModule:new())
