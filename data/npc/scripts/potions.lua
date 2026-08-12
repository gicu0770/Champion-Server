local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)

function onCreatureAppear(cid)              npcHandler:onCreatureAppear(cid)            end
function onCreatureDisappear(cid)           npcHandler:onCreatureDisappear(cid)         end
function onThink()                          npcHandler:onThink()                        end
function onPlayerSellMultiple(cid, items)
  npcHandler:onPlayerSellMultiple(cid, items)
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

  shopModule.requestTrade(cid:getId(), "trade", nil, {module = shopModule})
  npcHandler:onCreatureSay(cid, type, msg)
end

--shopModule:addBuyableItem({'health potion'}, 7618, 10, 1, 'health potion', function(item) item:setRarity(1) end)
--shopModule:addBuyableItem({'strong health'}, 7588, 30, 1, 'strong health potion')
--shopModule:addBuyableItem({'great health'}, 7591, 250, 1, 'great health potion')
--shopModule:addBuyableItem({'ultimate health'}, 8473, 500, 1, 'ultimate health potion')
--shopModule:addBuyableItem({'supreme health'}, 26031, 2000, 1, 'supreme health potion')
--shopModule:addBuyableItem({'heroic health'}, 36912, 3500, 1, 'heroic health potion')


--shopModule:addBuyableItem({'Town Portal'}, 6533, 500, 1)

--shopModule:addBuyableItem({'Orb of Mirroring'}, 36959, 1, 1, 'Orb of Mirroring')
--shopModule:addBuyableItem({'Orb of Socketing'}, 37122, 1, 1, 'Orb of Socketing')
--shopModule:addBuyableItem({'Orb of Seal'}, 37120, 1, 1, 'Orb of Seal')
--shopModule:addBuyableItem({'Orb of Apex'}, 37112, 1, 1, 'Orb of Apex')
--shopModule:addBuyableItem({'Orb of Void'}, 37121, 1, 1, 'Orb of Void')
--shopModule:addBuyableItem({'Orb of Spellweaver'}, 37117, 1, 1, 'Orb of Spellweaver')
--shopModule:addBuyableItem({'Orb of Corruption'}, 18422, 1, 1, 'Orb of Corruption')
--shopModule:addBuyableItem({'Orb of Arcana'}, 37119, 1, 1, 'Orb of Arcana')
--shopModule:addBuyableItem({'Orb of Quality'}, 37113, 1, 1, 'Orb of Quality')
--shopModule:addBuyableItem({'Orb of Chance'}, 37118, 1, 1, 'Orb of Chance')
--shopModule:addBuyableItem({'Orb of Refinement'}, 37115, 1, 1, 'Orb of Refinement')
--shopModule:addBuyableItem({'Orb of Shaping'}, 37116, 1, 1, 'Orb of Shaping')
--shopModule:addBuyableItem({'Orb of Honored'}, 8302, 1, 1, 'Orb of Honored')
--shopModule:addBuyableItem({'Orb of Enchantment'}, 8303, 1, 1, 'Orb of Enchantment')
--shopModule:addBuyableItem({'Orb of Removal'}, 37114, 1, 1, 'Orb of Removal')


shopModule:addBuyableItem({'Fireball'}, 1987, 2000, 1, 'Fireball')
shopModule:addBuyableItem({'Stomp'}, 37306, 2000, 1, 'Stomp')
shopModule:addBuyableItem({'Earth Bolt'}, 37344, 2000, 1, 'Earth Bolt')
shopModule:addBuyableItem({'Smite'}, 37310, 1500, 1, 'Smite')
shopModule:addBuyableItem({'Double Strike'}, 37343, 2000, 1, 'Double Strike')
shopModule:addBuyableItem({'Piercing Shot'}, 37320, 2000, 1, 'Piercing Shot')

shopModule:addBuyableItem({'Backpack'}, 1988, 3000, 1, 'Backpack')
shopModule:addBuyableItem({'Green Backpack'}, 1998, 3000, 1, 'Green Backpack')
shopModule:addBuyableItem({'Yellow Backpack'}, 1999, 3000, 1, 'Yellow Backpack')
shopModule:addBuyableItem({'Red Backpack'}, 2000, 3000, 1, 'Red Backpack')
shopModule:addBuyableItem({'Purple Backpack'}, 2001, 3000, 1, 'Purple Backpack')
shopModule:addBuyableItem({'Blue Backpack'}, 2002, 3000, 1, 'Blue Backpack')
shopModule:addBuyableItem({'Grey Backpack'}, 2003, 3000, 1, 'Grey Backpack')
shopModule:addBuyableItem({'Golden Backpack'}, 2004, 3000, 1, 'Golden Backpack')

shopModule:addBuyableItem({'Backpack of Holding'}, 2365, 5000, 1, 'Backpack of Holding')
shopModule:addBuyableItem({'Mushroom Backpack'}, 18393, 5000, 1, 'Mushroom Backpack')
shopModule:addBuyableItem({'Demon Backpack'}, 10518, 5000, 1, 'Demon Backpack')
shopModule:addBuyableItem({'Winged Backpack'}, 26976, 5000, 1, 'Winged Backpack')
shopModule:addBuyableItem({'Minotaur Backpack'}, 11244, 5000, 1, 'Minotaur Backpack')
shopModule:addBuyableItem({'Buggy Backpack'}, 15646, 5000, 1, 'Buggy Backpack')

--shopModule:addBuyableItem({'Skull Backpack'}, 37750, 50000, 1, 'Skull Backpack')
--shopModule:addBuyableItem({'Pumpkin Backpack'}, 37749, 50000, 1, 'Pumpkin Backpack')
--shopModule:addBuyableItem({'Rotten Backpack'}, 37748, 50000, 1, 'Rotten Backpack')
--shopModule:addBuyableItem({'Spiky Backpack'}, 37747, 50000, 1, 'Spiky Backpack')
--shopModule:addBuyableItem({'Titan Backpack'}, 37746, 50000, 1, 'Titan Backpack')
--shopModule:addBuyableItem({'Harvest Backpack'}, 37944, 50000, 1, 'Harvest Backpack')
--shopModule:addBuyableItem({'Twitch Backpack'}, 37461, 100000000, 1, 'Twitch Backpack')
-- shopModule:addBuyableItem({'Crystal of Trait'}, 28236, 5000, 1, 'Crystal of Trait')
-- shopModule:addBuyableItem({'Reset Talent Crystal '}, 31181, 5000, 1, 'Reset Talent Crystal ')

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

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:setCallback(CALLBACK_ONADDFOCUS, onAddFocus)
npcHandler:addModule(FocusModule:new())
