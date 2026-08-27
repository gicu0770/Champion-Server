local configBag = {
  [2] = 37014,
  [3] = 37013,
  [4] = 37016,
  [5] = 37017,
  [6] = 37015,
  [7] = 37019,
}

local MAX_MONSTER_LEVEL = 100
SERVER_BASE_ITEMS = {}
SERVER_UNIQUE_ITEMS = {}
SERVER_BOSS_UNIQUE_ITEMS = {}
local SERVER_RUNES_ITEMS = {}
local SERVER_SUPPORT_ITEMS = {}
BASE_ITEMS_BY_ID = {}

SERVER_BASE_ITEMS_BY_TYPES = {}
SERVER_UNIQUE_ITEMS_BY_TYPES = {}

--[[
  CUSTOM_TIER_DROPS Config:
  Umożliwia ustawienie dropu przedmiotów z dowolną ilością implicits (i ich wartościami)
  na podstawie Tieru potwora (monster:getType():tier()).

  Struktura:
  [TIER] = {
    {
      name = "magic sword",      -- Nazwa przedmiotu (string) LUB ID przedmiotu (number)
      rarity = 4,                -- Rarity: 0: Normal, 1: Magic, 2: Magic/Rare, 3: Rare, 4: Legendary, 5: Unique
      chance = 100000,           -- Szansa na drop: 100000 = 100%, 50000 = 50% (lub wpisz 50 dla 50%)
      count = 1,                 -- Ilość sztuk (opcjonalne, domyślnie 1)
      implicits = {              -- Dowolna liczba implicits z ID i wartością:
        { id = 11, value = 50 },  -- 1. implict: Physical Attack +50
        { id = 18, value = 25 },  -- 2. implict: Spell Damage +25%
        { id = 280, value = 10 }, -- 3. implict: Critical Chance +10%
      }
    }
  }
]]
CUSTOM_TIER_DROPS = {
  [1] = { -- Tier 1
    {
      name = "magic sword",
      rarity = 4, -- Legendary
      chance = 100000, -- 100%
      count = 1,
      implicits = {
        { id = 11, value = 50 },  -- Physical Attack +50
        { id = 18, value = 25 },  -- Spell Damage +25%
        { id = 280, value = 10 }, -- Critical Chance +10%
      }
    },
    {
      name = "demon helmet",
      rarity = 3, -- Rare
      chance = 100000,
      implicits = {
        { id = 108, value = 30 }, -- Physical Armor +30
        { id = 1, value = 150 },   -- Max HP +150
      }
    },
    {
      name = "golden legs",
      rarity = 4, -- Legendary
      chance = 100000,
      implicits = {
        { id = 108, value = 40 },
        { id = 17, value = 15 },
        { id = 2, value = 10 },
      }
    },
  },
  [2] = { -- Tier 2
    {
      name = "dragon scale mail",
      rarity = 4,
      chance = 50000, -- 50%
      implicits = {
        { id = 108, value = 80 },
        { id = 1, value = 300 },
        { id = 12, value = 20 },
      }
    },
  },
  [3] = { -- Tier 3
    -- Dodaj kolejne przedmioty dla Tier 3...
  },
}



local DUNGEON_KEYS = {
  [100] = { -- Relicty regen/flask
    37929, -- Queen Lair 23mlvl  DUZY promocja 1
    37926, -- Flame Cave 40mlvl  DUZY sub talenty
    37928, -- Swamp Pit 67mlvl  DUZY fuzja bonus i promocja 2
  },
  [210] = { -- relicty z MAX HP/ES/MANA
    37927, -- Undead Cave 82mlvl  DUZY trait z innej klasy - Undead King
    2091, -- Celestial Ascent 85mlvl DUZY - Ethereal Seraph holy
    2090, -- Glacier Pass 90mlvl DUZY - Glacier Warlord
  },
  [820] = { -- relicty z mitigation
    38227, -- underwater key 90mlvl DUZY - Tidal Overlord
    38230, -- infernal bridge key 90mlvl DUZY - Fleshrend
    38238, -- void key 90mlvl DUZY - Arbaziloth
  },
  [1230] = {    -- 1230 T91 relicty z overpower
    38730, -- lostsanctum key Sand Colossus
    38729, -- infernodepths key Molten Abyss
    38734, -- venomcave key Toxic Witch
  },
  [2100] = {    -- 2100 mlvl Nowe? jakie relicty ???
    XXXX, -- xxx
    XXXX, -- xxx
    XXXX, -- xxx
  },
}

local RUNE_ITEMS = {
  [1] = {
    38118, -- Thunder Strike LIGHTNING MELEE
    38119, -- Blitz LIGHTNING MELEE
    37372, -- Fire Lance Fire INT
    38095, -- Flame Tongue Fire INT
    38107, -- Venom String Earth dot int
    37327, -- Poison Plague Earth dot int
    38111, -- Flame Sting Fire STR
    38112, -- Cold Burst Ice MELEE
    38102, -- Frosty Link ICE MELEE
    38110, -- Stoning earth HIT int
    37408, -- Icicle ICE RANGED
    38103, -- Arctic Volley ICE RANGED
    37353, -- Frostbolt ICE MAGIC
    38117, -- Frosty Bounce ICE MAGIC
    37370, -- Spark Dart LIGHT INT MAGIC single
    38106, -- Sacred Lance HOLY MELEE
    38126, -- Sacred Bolt HOLY MAGIC 
    38122, -- Death Bolt DEATH MAGIC
    38113, -- heavy Strike
    38114, -- Shield Strike

    38129, -- Vital Surge MELEE PHYSICAL DOT
    37345, -- Rend MELEE PHYSICAL DOT

    37311, -- Curse dex dot death
    37358, -- Rotten Gas Shot dex dot death

    37343, -- Double Strike
    37342, -- Weakness Arrow

    37329, -- Lighting Barrage


    
    37320, -- Aimed Shot
    37344, -- Earth Bolt
    37306, -- Stomp
    37333, -- Leap Slam
    37340, -- Holy Dash
    38104, -- Holy Scatter
    38123, -- Leaping Death
  --  37331, -- Charge
    37312, -- Vortex
    37341, -- Molten Strike
    37307, -- Chain Lighting
    38084, -- Split Arrow
    37357, -- Lightning Arrow
    37360, -- Toxic Arrows
    38100, -- Weapon Throw

    38081, -- Multishot drop only
    38082, -- Mystic Focus drop only
    38083, -- Cleave drop only

  },
  [12] = {
    38131, -- Frosty Sky
    38120, -- Static Condition LIGHTNING MELEE
    38127, -- Bloody Skulls MELEE PHYSICAL DOT


    37347, -- Ice Surge ICE RANGED
    38054, -- Frigid Split ICE MAGIC
    37366, -- Shattering Dash ICE MELEE

    38124, -- Rotten Vine
    37352, -- Holy Shine
    37310, -- Smite
    37334, -- Sunder
    1987, -- Fireball
    38109, -- Toxic Split
    37363, -- Blazing Shout
    37367, -- Blessed Aura
    37368, -- Hollow Aura

    38055, -- Essence Drain
    37359, -- Phantom Run

    37331, -- Combat Aura
    37369, -- Frenzy Aura

    38090, -- Shield Throw
    37349, -- Shield Bash

    37315, -- Physical Aura
    37316, -- Elemental Aura
    37317, -- Stone Aura
    37318, -- Magic Aura
    37319, -- Thornmail Aura
    37308, -- Seismic Wave
    37326, -- Cold Snap
    37346, -- Death Wave
    37348, -- Lava Crash
    38094, -- Saint Cross
    37309, -- Salvo
    37354, -- Ball Lighting
    37362, -- Shockchain Arrow
    38101, -- Dancing Steel
    38105, -- Bouncing Venom
  },
  [21] = {
    37328, -- Tornado LIGHTNING MELEE
    37332, -- Perforate MELEE PHYSICAL DOT
    37356, -- Frostbite ICE RANGED
    38089, -- Frozen Shards Aura ICE MAGIC
    37365, -- Frozen Stomp ICE MELEE

    37364, -- Magma Fissue
    37339, -- Illumination
    37325, -- Spark
    37330, -- Amok
    37313, -- Fire Aura
    37314, -- Anger Aura
    37336, -- Affliction Aura
    37350, -- Black Hole
    38088, -- Fan Knives Aura
    37321, -- Wild Vines Poison Aura
    37371, -- Maelstorm Lightning Aura

    38092, -- Riposte

    37355, -- Fire Wall
    38051, -- Rootgrasp

    
    37361, -- Plagued Burst
    38091, -- Crushing Blow
  },
  [30] = {
    38121, -- Zeus Wrath -- drop only LIGHTNING MELEE
    38128, -- Hemorrhage Nova -- drop only MELEE PHYSICAL DOT
    38125, -- Black Matter -- drop only
    38093, -- Judgement Aura -- drop only
    38076, -- Tempest -- drop only
    38077, -- Blizzard -- drop only
    38078, -- Oblivion -- drop only
    38079, -- Venom Nova -- drop only
    38080, -- Groundbreaker -- drop only
    37351, -- Wrath -- drop only
    37323, -- Firestorm -- drop only
    37338, -- Rain Of Arrows -- drop only
    38050, -- Stonefall -- only drop
    38096, -- Venom Arrow Rain -- only drop
    38097, -- Frozen Ground -- only drop
    38098, -- Sky Shock -- only drop
    38115, -- Dent -- drop only

    

    37324, -- Flicker Strike
    37337, -- Acid Pool
    37322, -- Ricochet
    37335, -- Winter Wind ICE MAGIC
  },
  --[[
  [39] = {
    37408, -- Bloody Path
    37372, -- Passing Path
    37370, -- Cryo Path
    37369, -- Pyro Path
    37331, -- Sacred path
  }
  --]]
}

local SUPPORT_ITEMS = {
  [12] = {
    37382, -- Added Fire Damage Support
    37387, -- Added Earth Damage Support
    37383, -- Added Physical Damage Support
    37388, -- Added Lighting Damage Support
    37386, -- Added Ice Damage Support
    37389, -- Added Holy Damage Support
    37390, -- Added Death Damage Support

    37380, -- Cooldown Reduction Support
    37381, -- Cost Reduction Support
    37392, -- Crit Chance Support
    37393, -- Crit Damage Support
    37397, -- Bloodthirst Support only drop
  },
  [25] = {
    37391, -- Quality Support
    37384, -- DoT Damage Support
    37377, -- Elemental Damage Support
    37378, -- Brute Damage Support
    38057, -- Duality Damage Support
    37379, -- Lifetap Support
    37405 -- Enhanced Support
  },
  [33] = {
    37401, -- Elemental Weakness Support
    37402, -- Physical Weakness Support
    38056, -- Duality Weakness Support
    37395, -- Elemental Penetration Support
    37396, -- Armor Penetration Support
    38058, -- Duality Penetration Support
    38085, -- Basic Penetration Support
    38086, -- Counterattack Penetration Support
    38087, -- Attack Speed Support drop only
  --  37394, -- Pinpoint Support
    37373, -- Increased Area Of Effect Support  drop only Expansion
  },
  [40] = {
    38130, -- Basic Damage
    38059, -- Wave Damage
    38060, -- Area Damage
    38067, -- Close Damage
    38075, -- Move Damage
--    38061, -- Bleed Power
--    38062, -- Poison Power
--    38063, -- Ignite Power
    38064, -- Life Drain
    38065, -- Energy Drain
    38066, -- Mana Drain
    38099, -- Single Damage

    38068, -- Vitality aura
    38069, -- Vlarity aura
    38070, -- Barrier aura
    38071, -- Momentum aura

    38072, -- Physical Mastery
    38073, -- Elemental Mastery
    38074, -- Duality Mastery
    38108, -- Basic Mastery

    38053, -- Split
    38052, -- Bounce


    37400, -- Splash Damage Support
    37406, -- Double Damage Support
    37404, -- Gambler's Fury Support
    37375, -- Cast On Damage Taken Support
    37376, -- Cast On Kill Support
--    37403, -- Cast On Potion Use Support
    37407, -- Cast On Crit Support
    38061, -- Affliction
    --  37374, -- Multicast Support
  },
}


CRAFT_ITEMS = { -- for tooltip info
  [8302] = true,
  [8303] = true,
  [37114] = true,
  [37115] = true,
  [37116] = true,
  [37117] = true,
  [37118] = true,
  [37119] = true,
  [37120] = true,
  [37140] = true,
  [37154] = true,
  [36959] = true,
  [18422] = true,
  [26804] = true,
  [26807] = true,
  [26805] = true,
  [37121] = true,
  [37148] = true,
  [37112] = true,
  [37131] = true,
  [37141] = true,
  [37125] = true,
  [37135] = true,
  [37122] = true,
  [38541] = true,
  [38542] = true,
  [38543] = true,
  [26555] = true,
  [38409] = true,
  [38265] = true,
  [38738] = true,
  [38425] = true,
  [38423] = true,
  [38496] = true,
  [38422] = true,
  [38431] = true,
  [38751] = true,
  [37113] = true,
  [38742] = true,
  [37109] = true,
  [31109] = true,
}

CURRENCY_DROPS = {
  -- dropChance, ID, monsterLevel, storageId, countMax, name
  -- Immposible
  { 0.1,  36959, 70, 802013, 1, "Orb of Mirroring", false, "Immposible", 0 }, -- Orb of Mirroring Rerolls all item modifiers and their tiers
  { 0.2,  18422, 70, 802009, 1, "Orb of Corruption", false, "Immposible", 0 }, -- Orb of Corruption Modifies an item unpredictably and Corrupts it  -- zmiana na very rare ale za to daje tylko bonus i blokuje IT
  { 1,  37122, 70, 802017, 1, "Orb of Socketing", false, "Immposible", 0 }, -- Orb of Socketing Adds a socket (max 6 sockets).
  { 1,  38751, 200, 802028, 1, "Orb of Mystic", false, "Immposible", 0 }, -- Orb of Mystic Rerolls all relict modifiers and their tiers.
  { 2,  38409, 70, 802019, 1, "Scroll of Protection", false, "Immposible", 0 }, -- Anti Downgrade Scroll

  { 2,  38265, 500, 802020, 1, "Orb of Lownest", false, "Immposible", 0 }, -- Orb of Lownest - Removes the lowest Tier level modifications. 500mlvl start drop ???
  { 2,  38738, 500, 802022, 1, "Orb of Begin", false, "Immposible", 0 }, -- Orb of Begin - Removes the first modification. 500mlvl start drop ???

  { 10,  38425, 70, 802026, 1, "Quality Spell Shard", false, "Immposible", 0 }, -- "Increases the Quality of Spells Rune by 1% up to 20%."
  { 10,  38423, 200, 802027, 1, "Quality Relict Shard", false, "Immposible", 0 }, -- "Increases the Quality of Relicts by 1% up to 20%."

  { 15,  37120, 70, 802016, 1, "Orb of Seal", false, "Immposible", 0 }, -- Orb of Seal A random modifier is sealed, sealed modifiers can't be modified! Only usable when item have minimum 4 modifiers.
  { 15,  37112, 70, 802015, 1, "Orb of Apex", false, "Immposible", 0 }, -- Orb of Apex Rerolls an affix with T6 or T7

  { 30,  38496, 30, 802023, 1, "Quality Weapon Shard", false, "High", 0 }, -- "Increases the Quality of Weapons, Gloves and Shields by 1% up to 20%."
  { 30,  38422, 30, 802024, 1, "Quality Armor Shard", false, "High", 0 }, -- "Increases the Quality of Helmet, Armor, Legs and Boots by 1% up to 20%."
  { 30,  38431, 30, 802025, 1, "Quality Accessorie Shard", false, "High", 0 }, -- "Increases the Quality of Potions, Rings and Amulet by 1% up to 20%."

  { 70,  37121, 50, 802014, 1, "Orb of Void", false, "High", 0 }, -- Orb of Void Randomizes the tiers of all modifications again.

  -- High
  { 150,  37109, 55, 802021, 1, "Orb of Scouring", true, "High", 0 }, -- Orb of  Scouring
  { 12,  37117, 35, 802011, 1, "Orb of Spellweaver", false, "High", 0 }, -- Orb of Spellweaver Infuses an item with unstable arcane energy, granting a chance to empower all spells at once.
  { 150,  37119, 35, 802008, 1, "Orb of Arcana", true, "High", 0 }, -- Orb of Arcana Added new modificator max 6
  { 200,  37118, 35, 802007, 1, "Orb of Chance", true, "Medium", 0 }, -- Orb of Chance Rerolls all item modifiers and their tiers.


  -- Medium
  { 120,  37115, 15, 802002, 1, "Orb of Refinement", true, "Medium", 0 }, -- Orb of Refinement Rerolls the values of item modifiers -- 900
  { 120,  37116,  15, 802003, 1, "Orb of Shaping", true, "Medium", 0 }, -- Orb of Shaping Rerolls the values for each implicit -- 900
  { 300,  8302, 15, 802001, 1, "Orb of Honored", true, "Medium", 0 }, -- Orb of Honored added new slots max 6        -- 300

  -- Low 
  { 600,  26555, 1, 802018, 1, "Upgrade Crystal", true, "Low", 0 }, -- Upgrade Crysta
  { 600,  8303, 1, 802000, 1, "Orb of Enchantment", true, "Low", 500 }, -- Orb of Enchantment added new slots max 3 -- 1500
  { 600,  37114,  1, 802004, 1, "Orb of Removal", true, "Low", 0}, -- Orb of Removal Removes one of the modifiers. -- 900

--  { 1000,  37113,  1000, 802006, 1, "Orb of Ascension", false, "Immposible", 0, "stone" }, -- Orb of Ascension Increased Dungeon Tier
  { 1000,  38742,  1, 802029, 1, "Orb of Alteration", false, "Immposible", 0, "stone" }, -- Adds a random Added Modifier if none is present.Otherwise, replaces the existing one with another.Weapons, Shields and Gloves only.

  { 1,  31109,  1, 802030, 1, "Seal of Soulbound", false, "Immposible", 0, "abyss" }, -- Seal of Soulbound
}

  --[[
  --  { 50,  37154, 50, 802012, 1, "Orb of Perfect" }, -- Orb of Perfect Rune Spell/Support Rune increases rarity to Unique.
  --  { 100,  37140, 35, 802010, 1, "Orb of Greater" }, -- Orb of Greater Rune Spell/Support Rune increases rarity to Magic.
  --  { 250,  37148, 1, 802005, 2, "Orb of Lesser" }, -- Orb of Lesser Rune Spell/Support Rune increases rarity to Rare. -- 300
    { 200,  37113,  35, 802006, 1, "Orb of Ascension", true, "Medium" }, -- Orb of Quality Increased quality of Equipments, Potions and spells. -- 300


  { 50,  38287, 42, 61, {4,7,10,15}, "Necroshade Crystal", 14 }, -- Death Crystal
  { 50,  38255, 42, 62, {4,7,10,15}, "Sanctity Crystal", 14 }, -- Holy Crystal
  { 50,  38260, 42, 60, {4,7,10,15}, "Viper Crystal", 14 }, -- Poison Crystal
  { 50,  38256, 42, 57, {4,7,10,15}, "Emberheart Crystal", 14 }, -- Fire Crystal
  { 50,  38258, 42, 58, {4,7,10,15}, "Frostshard Crystal", 14 }, -- Ice Crystal
  { 50,  38254, 42, 59, {4,7,10,15}, "Thundercrack Crystal", 14 }, -- Lightning Cystal
  { 50,  38288, 42, 108, {4,7,10,15}, "Berserker Crystal", 14 }, -- Brute Damage Cystal
--{ 3,  38243, 100, 6, {5}, "Unity Crystal", 30, unique = true  }, -- All Attributes

  -- Only Weapons + Shield x4
  -- { 50,  36978, 100, 235, {1,1,2,3}, "Reflex Core Crystal", 4 }, -- Max Attack Speed Protection
  -- { 50,  38279, 42, 16, {4,7,10,15}, "Renewal Crystal", 8 }, -- Recovery Effectiveness Crystal
  --]]

CRYSTAL_DROPS = {
  -- Chance, ID, mlvlDrop, modId, value, name
  -- Special
  -- Only Spells x8
  { 5,  38240, 42, 228, {2,4,7,10}, "Prismatic Crystal", 8 }, -- Elemental Spells
  { 5,  38241, 42, 230, {2,4,7,10}, "Harmony Crystal", 8 }, -- Duality Spells
  { 5,  38244, 42, 229, {2,4,7,10}, "Titan Crystal", 8 }, -- Physical Spells
  { 5,  38242, 42, 262, {2,4,7,10}, "Hard Crystal", 8 }, -- Basic Spells

  -- All items x30 6x30 - 180
  { 30,  38289, 42, 4, {2,4,7,10}, "Titanforce Crystal", 30  }, -- Strength Crystal
  { 30,  38294, 42, 3, {2,4,7,10}, "Sage Insight Crystal", 30  }, -- Intelligence Crystal
  { 30,  38290, 42, 5, {2,4,7,10}, "Windstep Crystal", 30  }, -- Dexterity Crystal
  { 30,  38270, 42, 34, {2,4,7,10}, "Virtuoso Crystal", 30  }, -- Mastery Crystal
  { 30,  38293, 42, 7, {2,4,7,10}, "Heartroot Crystal", 10 }, -- Vitality Crystal
  { 30,  38269, 42, 210, {9,11,15,20}, "Amplifying Crystal", 14 }, -- all Ailment Chance

  -- Offensive Weapons, Shield, Spells and Gloves. x14
  { 30,  38259, 42, 11, {4,7,15,20}, "Stonefist Crystal", 14 }, -- Physical Crystal
  { 30,  38286, 42, 12, {4,7,15,20}, "Stormfire Crystal", 14 }, -- Elemental Damage Cystal
  { 30,  38297, 42, 196, {4,7,15,20}, "Duskblade Crystal", 14 }, -- Duality Damage Cystal
  { 30,  38275, 42, 18, {4,7,15,20}, "Archmage Crystal", 14 }, -- Spell Damage Cystal
  { 30,  38253, 42, 47, {10,25,45,70}, "Venombrand Crystal", 14 }, -- DoT Damage Cystal
  { 30,  38273, 42, 19, {4,7,15,20}, "Warrior Might Crystal", 14 }, -- Basic Damage Cystal
  { 30,  38283, 42, 49, {8,14,30,40}, "Riposte Crystal", 14 }, -- Counterattack Cystal
  { 30,  38382, 100, 55, {3,5,7,10}, "Swift Crystal", 14 }, -- Attack Speed
  { 30,  38278, 42, 29, {4,5,7,10}, "Blow Crystal", 14 }, -- Critical Chance

  -- Defensive Helmet, Armor, Legs, Boots and Shield x10
  { 30,  38271, 42, 13, {4,6,9,15}, "Ironwall Crystal", 10 }, -- Physical Protection Crystal
  { 30,  38298, 42, 14, {4,6,9,15}, "Elementguard Crystal", 10 }, -- Elemental Protection Crystal
  { 30,  38299, 42, 197, {4,6,9,15}, "Twilight Ward Crystal", 10 }, -- Duality Protection Crystal
  { 30,  38266, 42, 71, {120,225,330,450}, "Guardian Crystal", 10 }, -- Energy Shield Crystal
  { 30,  38272, 42, 2, {120,225,330,450}, "Arcanist Crystal", 10 }, -- Mana Crystal
  { 30,  38281, 42, 1, {120,225,330,450}, "Lifegem Crystal", 10 }, -- Health Crystal

  { 60,  37298, 100, 232, {2,4,7,10}, "Ironclad Bulwark Crystal", 10 }, -- Max Physical Protection
  { 60,  37295, 100, 233, {2,4,7,10}, "Elemental Wardstone Crystal", 10 }, -- Max Elemental Protection
  { 60,  37283, 100, 234, {2,4,7,10}, "Parity Aegis Crystal", 10 }, -- Max Duality Protection

  -- Spodnie Boots x2
  { 30,  38383, 42, 27, {6,9,15,20}, "Hermes Crystal", 2 }, -- Movements Speed -- only boots
  -- Helmet
  { 30,  38861, 100, 291, {4,5,7,10}, "Abyss Crystal", 1 }, -- Abyss Crystal Unique Penetration

  -- Only Shield x2
  { 30,  36972, 100, 236, {2,3,4,5}, "Bastion Crest Crystal", 2 }, -- Max Block Chance Protection

  -- Recovery Rings, Amulet and Potion x8
  { 30,  38300, 42, 46, {20,30,40,50}, "Crimson Leech Crystal", 8 }, -- Health On Hit Crystal
  { 30,  38302, 42, 111, {20,30,40,50}, "Aegis Siphon Crystal", 8 }, -- Energy Shield on Hit Crystal
  { 30,  38301, 42, 201, {20,30,40,50}, "Azure Tap Crystal", 8 }, -- Mana on Hit Crystal
  { 30,  38285, 42, 24, {10,15,20,30}, "Mindflow Crystal", 8 }, -- Mana Regeneration Crystal
  { 30,  38282, 42, 23, {20,55,80,110}, "Lifebloom Crystal", 8 }, -- Health Regeneration Crystal
  { 30,  38268, 42, 26, {20,55,80,110}, "Barrier Pulse Crystal", 8 }, -- Energy Shield Regeneration Crystal
}

CRYSTAL_DATA_FROM_ID = {}

CRYSTAL_ITEMTYPES = {
  -- All items
   -- Offensive Weapons, Shield, Spells and Gloves. {1,2,3,4,5,6,7,8,15,16,18},
   -- Defensive Helmet, Armor, Legs, Boots and Shield. {9,11,12,13,16},
   -- Recovery Rings, Amulet and Potions. {10,14,17}
   -- Only Shield {16}
   -- Only Weapon {1,2,3,4,5,6,7,8}

  -- Only Weapons + Shield
  [36978] = {1,2,3,4,5,6,7,8,16}, -- Reflex Core Crystal RARE x2

  -- Offensive Weapons, Shield, Spells and Gloves. x7
  [38259] = {1,2,3,4,5,6,7,8,15,16,18}, -- Stonefist Crystal
  [38287] = {1,2,3,4,5,6,7,8,15,16,18}, -- Necroshade Crystal
  [38255] = {1,2,3,4,5,6,7,8,15,16,18}, -- Sanctity Crystal
  [38260] = {1,2,3,4,5,6,7,8,15,16,18}, -- Viper Crystal
  [38256] = {1,2,3,4,5,6,7,8,15,16,18}, -- Emberheart Crystal
  [38258] = {1,2,3,4,5,6,7,8,15,16,18}, -- Frostshard Crystal
  [38254] = {1,2,3,4,5,6,7,8,15,16,18}, -- Thundercrack Crystal
  [38288] = {1,2,3,4,5,6,7,8,15,16,18}, -- Berserker Crystal
  [38286] = {1,2,3,4,5,6,7,8,15,16,18}, -- Stormfire Crystal
  [38297] = {1,2,3,4,5,6,7,8,15,16,18}, -- Duskblade Crystal
  [38275] = {1,2,3,4,5,6,7,8,15,16,18}, -- Archmage Crystal
  [38253] = {1,2,3,4,5,6,7,8,15,16,18}, -- Venombrand Crystal
  [38273] = {1,2,3,4,5,6,7,8,15,16,18}, -- Warrior Might Crystal
  [38283] = {1,2,3,4,5,6,7,8,15,16,18}, -- Riposte Crystal
  [38382] = {1,2,3,4,5,6,7,8,15,16,18}, -- Swift Crystal
  [38278] = {1,2,3,4,5,6,7,8,15,16,18}, -- Blow Crystal
  -- Defensive Helmet, Armor, Legs, Boots and Shield
  [38271] = {9,11,12,13,16}, -- Ironwall Crystal
  [38298] = {9,11,12,13,16}, -- Elementguard Crystal
  [38299] = {9,11,12,13,16}, -- Twilight Ward Crystal
  [38266] = {9,11,12,13,16}, -- Guardian Crystal
  [38272] = {9,11,12,13,16}, -- Arcanist Crystal
  [38281] = {9,11,12,13,16}, -- Lifegem Crystal
--  [38293] = {9,11,12,13,16}, -- Heartroot Crystal przeniesione na all

  [37298] = {9,11,12,13,16}, -- Ironclad Bulwark Crystal RARE x5
  [37295] = {9,11,12,13,16}, -- Elemental Wardstone Crystal RARE x5
  [37283] = {9,11,12,13,16}, -- Parity Aegis Crystal RARE x5

  -- Only Shield
  [36972] = {16}, -- Bastion Crest Crystal RARE x1 

  -- Only Helmet
  [38861] = {12},

  --  Boots and Legs
  [38383] = {12,13}, -- Hermes Crystal

  -- Recovery Rings, Amulet and Potion x4
  [38300] = {10,14,17}, -- Crimson Leech Crystal
  [38302] = {10,14,17}, -- Aegis Siphon Crystal
  [38301] = {10,14,17}, -- Azure Tap Crystal
  [38279] = {10,14,17}, -- Renewal Crystal
  [38282] = {10,14,17}, -- Lifebloom Crystal
  [38285] = {10,14,17}, -- Mindflow Crystal
  [38268] = {10,14,17}, -- Barrier Pulse Crystal

  -- Only Spells
  [38240] = {18}, -- Prismatic Crystal
  [38241] = {18}, -- Harmony Crystal
  [38244] = {18}, -- Titan Crystal
  [38242] = {18}, -- Hard Crystal

}

BOSS_DROPS_BY_ID = {}
BOSS_DROP_ITEMS = {
  --[[
  38606 - Treasure Goblin
  38590 - Champion Relict
  38464 - Strongbox relict

  ]]
  ["Eldritch Reaver"] = {
    [38601] = { --  Added Elemental Damage
      unique = true,
      imps = {{69}, {{50}}},
      forceType = US_ITEM_TYPES.RELICT_OFFENSIVE,
      chance = 15000, -- 15000
      weight = {0, 0, 0, 0},
    },
  },
  ["Grave Spearlord"] = {
    [38593] = { --  Added Duality Damage
      unique = true,
      imps = {{68}, {{50}}},
      forceType = US_ITEM_TYPES.RELICT_OFFENSIVE,
      chance = 15000,
      weight = {0, 0, 0, 0},
    },
  },
  ["Minotaur Liberator"] = {
    [38562] = { --  Added Physical Damage
      unique = true,
      imps = {{70}, {{50}}},
      forceType = US_ITEM_TYPES.RELICT_OFFENSIVE,
      chance = 15000,
      weight = {0, 0, 0, 0},
    },
  },
  ["Soulbound Lich"] = {
    [38566] = { --  All Spells
      unique = true,
      imps = {{107}, {{50}}},
      forceType = US_ITEM_TYPES.RELICT_OFFENSIVE,
      chance = 15000,
      weight = {0, 0, 0, 0},
    },
  },
  -- Bossing
  ["Ascended Voort"] = {
    [38459] = { --  Boss Relict
      imps = {{267}, {{2,4,7,10}}},
      forceType = US_ITEM_TYPES.RELICT_BOSS,
      chance = 100000,
      weight = {0, 0, 0, 0},
    },
  },
  -- Events
  ["Gorok"] = {
    [38736] = { --  Champion Relict
      imps = {{265}, {{50,100,150,200}}},
      forceType = US_ITEM_TYPES.RELICT_CHAMPION,
      chance = 100000,
      weight = {0, 0, 0, 0},
    },
  },
  ["Bilbo"] = {
    [38732] = { --  Treasure Goblin
      imps = {{264}, {{50,100,150,200}}},
      forceType = US_ITEM_TYPES.RELICT_GOBLIN,
      chance = 100000,
      weight = {0, 0, 0, 0},
    },
  },
  ["Viliaan"] = {
    [38733] = { --  Strongbox relict
      imps = {{266}, {{50,100,150,200}}},
      forceType = US_ITEM_TYPES.RELICT_STRONGBOX,
      chance = 100000,
      weight = {0, 0, 0, 0},
    },
  },
  ["Void Stone"] = {
    [38693] = { --  Void Stone relict
      imps = {{288}, {{50,100,150,200}}},
      forceType = US_ITEM_TYPES.RELICT_VOIDSTONE,
      chance = 5000,
      weight = {0, 0, 0, 0},
    },
  },


  -- Regen percent
  ["Vampire Queen"] = {
    [38239] = { --  Health Regen
      imps = {{23}, {{150,200,400,750}}}, -- {{247}, {{0.25,0.5,1.0,2}}},
      forceType = US_ITEM_TYPES.RELICT_UTILITY,
      chance = 100000,
      weight = {7, 10, 12, 15},
    },
  },
  ["Toxic Hydra"] = {
    [32599] = { --  Energy Shield Regen
      imps = {{26}, {{150,200,400,750}}}, -- {{248}, {{0.25,0.5,1.0,2}}},
      forceType = US_ITEM_TYPES.RELICT_UTILITY,
      chance = 100000,
      weight = {7, 10, 12, 15},
    },
  },
  ["Pheonix"] = {
    [38400] = { -- Increase potion restore amount
      imps = {{249}, {{500,700,900,1200}}},
      forceType = US_ITEM_TYPES.RELICT_UTILITY,
      chance = 100000,
      weight = {7, 10, 12, 15},
    },
  },
  -- HP/ES/MANA
  ["Undead King"] = {
    [38641] = { -- Health Percent
      imps = {{109}, {{5,10,23,42}}},
      forceType = US_ITEM_TYPES.RELICT_DEFFENSIVE,
      chance = 100000,
      weight = {7, 10, 12, 15},
    },
  },
  ["Ethereal Seraph"] = {
    [38639] = { -- Energy Shield Percent
      imps = {{72}, {{5,10,23,42}}},
      forceType = US_ITEM_TYPES.RELICT_DEFFENSIVE,
      chance = 100000,
      weight = {7, 10, 12, 15},
    },
  },
  ["Glacier Warlord"] = {
    [38640] = { -- Mana Percent
      imps = {{110}, {{5,10,23,42}}},
      forceType = US_ITEM_TYPES.RELICT_DEFFENSIVE,
      chance = 100000,
      weight = {7, 10, 12, 15},
    },
  },
-- Mitigation
 ["Tidal Overlord"] = {
    [38447] = { -- knight emblem Physical Mitigation
      imps = {{237}, {{15,22,35,50}}},
      forceType = US_ITEM_TYPES.RELICT_DEFFENSIVE,
      chance = 100000,
      weight = {10, 12, 15, 20},
    },
  },
  ["Fleshrend"] = {
    [38519] = { -- elemental emblem Elemental Mitigation
      imps = {{238}, {{15,22,35,50}}},
      forceType = US_ITEM_TYPES.RELICT_DEFFENSIVE,
      chance = 100000,
      weight = {10, 12, 15, 20},
    },
  },
  ["Arbaziloth"] = {
    [38561] = { -- dulimar Duality Mitigation
      imps = {{239}, {{15,22,35,50}}},
      forceType = US_ITEM_TYPES.RELICT_DEFFENSIVE,
      chance = 100000,
      weight = {10, 12, 15, 20},
    },
  },

  -- overpower
  ["Sand Colossus"] = {
    [38448] = { -- Warrior Trophy Physical Overpower
      imps = {{240}, {{3,7,15,30}}},
      forceType = US_ITEM_TYPES.RELICT_OFFENSIVE,
      chance = 100000,
      weight = {5, 10, 15, 20},
    },
  },
  ["Toxic Witch"] = {
    [13946] = { -- The Epic Wisdom Elemental Overpower
      imps = {{241}, {{3,7,15,30}}},
      forceType = US_ITEM_TYPES.RELICT_OFFENSIVE,
      chance = 100000,
      weight = {5, 10, 15, 20},
    },
  },
  ["Molten Abyss"] = {
    [25546] = { -- Cursed Skull Emblem Duality Overpower
      imps = {{242}, {{3,7,15,30}}},
      forceType = US_ITEM_TYPES.RELICT_OFFENSIVE,
      chance = 100000,
      weight = {5, 10, 15, 20},
    },
  },

}

--[[
itemTypes = {
	[-1] = "All Items",
	[0] = "None",
	[1] = "Two-Handed Melee",
	[2] = "One-Handed Melee",
	[3] = "Two-Handed Bow",
	[4] = "One-Handed Bow",
	[5] = "Throwing Knife",
	[6] = "Two-Handed Wand",
	[7] = "Distance",
	[8] = "One-Handed Wand",
	[9] = "Helmet",
	[10] = "Necklace",
	[11] = "Armor",
	[12] = "Legs",
	[13] = "Boots",
	[14] = "Ring",
	[15] = "Gloves",
	[16] = "Shield",
	[17] = "Potion",
	[18] = "Spell Rune",
	[19] = "Support Rune",
	[20] = "Backpack",
	[21] = "Usable",
	[22] = "Craft Material",
	[23] = "Dungeon Key",
	[24] = "Store Item",
	[25] = "Crystal",
	[26] = "Container",
	[27] = "Relic",
	[28] = "Fragment" 
}
--]]

function Monster:onDropLoot(corpse)
  local pid = corpse:getCorpseOwner()
  local player = Player(pid)
  if not corpse or corpse.itemid == 0 or not player then
    return false
  end

  local eliteMonster = self:getSkull()
  local mType = self:getType()
  local monsterTier = mType:tier()
  local boss = self:getType():getRace() == 6
  local name = self:getName()
  local lootItems = {}
  local monsterLevel = self:getMonsterLevel()
  local uniqueChance = 15 + (15 * math.min(monsterLevel, 100) / 100)
  local strongBox = self:getStorageValue(PlayerStorage.strongBoxMonster)
  local strongBoxBoss = self:getStorageValue(PlayerStorage.strongBoxMonsterBoss)
  local typeItems = mType:items()
  local uniqueCount = 0
  local mapBonus = self:getStorageValue(PlayerStorage.monsterModifier_bonus) or 0
  mapBonus = mapBonus * (self:getStorageValue(PlayerStorage.monsterModifier_partyBonus) * 0.2 + 1.0)
  local magicFind = 0

  local global = 0
  if player:hasBuff(BUFF_GLOBAL_LOOT) then
    global = global + 20
  end
  if player:hasBuff(MONSTER_SOUL_LOOT) then
    global = global + 20
  end
  if player:hasBuff(SELF_LOOT_BOOST) then
    global = global + 20
  end
  if player:hasBuff(SHRINE_LOOT) then
		global = global + 30
	end

  math.randomseed(os.time())
  local bagRarirty = 0
  local highestRarity = 0
  --[[
  if SERVER_BOSS_UNIQUE_ITEMS[name] then
    bagRarirty = generateRandomBossUniqueItems(player, corpse, monsterLevel, name, lootItems, eliteMonster, strongBox, strongBoxBoss, uniqueChance, uniqueCount, magicFind)
    if bagRarirty > highestRarity then highestRarity = bagRarirty end
  end

  if BOSS_DROP_ITEMS[name] then
    bagRarirty = generateBossItemDrop(player, corpse, name, lootItems, magicFind)
    if bagRarirty > highestRarity then highestRarity = bagRarirty end
  end
  --]]

--  bagRarirty = generateCustomTierDrops(player, corpse, monsterTier, monsterLevel, lootItems, magicFind)
  if bagRarirty > highestRarity then highestRarity = bagRarirty end
  local basicCount = 1
  local basicChance = 100000
  bagRarirty = generateRandomBaseItems(player, corpse, monsterLevel, monsterTier, lootItems, eliteMonster, strongBox, strongBoxBoss, basicCount, basicChance, magicFind)
--  if bagRarirty > highestRarity then highestRarity = bagRarirty end
--  bagRarirty = generateRandomUniqueItems(player, corpse, monsterLevel, monsterTier, lootItems, eliteMonster, strongBox, strongBoxBoss, uniqueChance, uniqueCount, magicFind)
--  if bagRarirty > highestRarity then highestRarity = bagRarirty end
--  bagRarirty = generateRandomSupportItems(player, corpse, monsterLevel, monsterTier, lootItems, eliteMonster, strongBox, strongBoxBoss, supportRuneChance, supportCount, self)
--  if bagRarirty > highestRarity then highestRarity = bagRarirty end
--  bagRarirty = generateRandomSpellItems(player, corpse, monsterLevel, monsterTier, lootItems, eliteMonster, strongBox, strongBoxBoss, spellRuneChance, spellCount, magicFind, self)
--  if player:getStorageValue(PlayerStorage.endGame) > 0 then
--    if bagRarirty > highestRarity then highestRarity = bagRarirty end
--    bagRarirty = generateDungeonKey(player, corpse, monsterLevel, monsterTier, lootItems, eliteMonster, strongBox, strongBoxBoss, keyChance, self, dungeonBoss)
--  end
--  if bagRarirty > highestRarity then highestRarity = bagRarirty end
--  bagRarirty = generateCurrency(player, corpse, 0, eliteMonster, boss, monsterLevel, strongBox, strongBoxBoss, lootItems, mapBonus, currencyChance, currencyCountChance, typeItems)
--  if bagRarirty > highestRarity then highestRarity = bagRarirty end
--  bagRarirty = generateCrystals(player, corpse, 0, eliteMonster, boss, monsterLevel, strongBox, strongBoxBoss, lootItems, mapBonus, crystalChance, abyssMonster)

--  if bagRarirty > highestRarity then highestRarity = bagRarirty end
--  if math.random(100000) <= potionChance then -- potionChance then
--    bagRarirty = generatePotions(player, corpse, 0, eliteMonster, boss, monsterLevel, strongBox, strongBoxBoss, lootItems, magicFind)
--    if bagRarirty > highestRarity then highestRarity = bagRarirty end
--  end
--  if eliteMonster >= 7 then -- only elites
--    if math.random(100000) <= 2000 then
--      bagRarirty = generateSelfFragment(player, corpse, difficulty, eliteMonster, boss, monsterLevel, strongBox, strongBoxBoss, lootItems, magicFind)
--    end
--  end
--  bagRarirty = generateBossFragments(player, corpse, lootItems, self, fragmentCount)
  if bagRarirty > highestRarity then highestRarity = bagRarirty end
  generateGold(player, monsterTier, 0, eliteMonster, boss, monsterLevel, strongBox, strongBoxBoss, typeItems, mapBonus, name, self)

  local items = corpse:getItems()
  if #lootItems == 0 and #items == 0 then
    corpse:remove()
    return true
  end


  corpse:setSize(#items)
  local outfit = self:getClientOutfit()
  local monsterId = corpse:getRealUID()
  local party = player:getParty()
 
  if party and party:isSharedExperienceEnabled() then
    local leader = party:getLeader()
    sendCreatureCorpse(leader, outfit, monsterId, name)
    sendLoot(leader, lootItems, monsterId)
    for _, member in ipairs(party:getMembers()) do
      sendCreatureCorpse(member, outfit, monsterId, name)
      sendLoot(member, lootItems, monsterId)
    end
  else
    sendCreatureCorpse(player, outfit, monsterId, name)
    sendLoot(player, lootItems, monsterId)
  end

  if #items == 0 then
    corpse:remove()
    return true
  end

  if corpse then
    corpse:setCorpseOwner(pid)
  end

  corpse:getPosition():sendMagicEffect(241)
  if configBag[highestRarity] then
    addEvent(function()
      if not corpse then return end
      corpse:transform(configBag[highestRarity])
      corpse:setCorpseOwner(pid)
    end, 950)
  end

  return true
end

function generateBossItemDrop(player, corpse, monsterName, lootItems, magicFind)
  local highestRarity = 0
  local looted = nil
  if not BOSS_DROP_ITEMS[monsterName] then
    return 0
  end

  local specialStorage = player:getSlotItem(CONST_SLOT_STORE_INBOX):getItemById(38387)
  local extraChance = magicFind / 100
  for id, dataItem in pairs(BOSS_DROP_ITEMS[monsterName]) do
    local chance = (dataItem.chance * 1000)
    chance = chance + (chance * extraChance)
    if math.random(1, 100000) <= dataItem.chance  then
      local item
      if specialStorage then
        item = specialStorage:addItem(id, 1, INDEX_WHEREEVER, FLAG_NOLIMIT)
        looted = player:getName()
      else
        item = corpse:addItem(id, 1, INDEX_WHEREEVER, FLAG_NOLIMIT)
      end
      if not item then
        print("boss Item: " .. id .. " not found")
        return 0
      end
      local rarityThresholds = {5, 250, 2500, 10000, 100000} -- {1000, 10000, 30000, 50000, 100000} -- rarity 4 najrzadsze, rarity 0 najczęstsze
      local randRarity = math.random(100000)
      local bestRarity = 0 -- domyślnie najczęstsze
      for i = 1, #rarityThresholds do
        if randRarity <= rarityThresholds[i] then
          bestRarity = #rarityThresholds - i
          break
        end
      end

      if dataItem.forceType then
        item:setCustomAttribute("forceType", dataItem.forceType)
      end

      item:setRarity(bestRarity)
      item:setItemLevel(100)
      item:setModifiersSlots(bestRarity)
      item:rollAttribute(magicFind, bestRarity)
      item:setCustomAttribute("relict", true)

      if dataItem.imps and dataItem.imps[1] then
        item:setImplictSlots(#dataItem.imps[1])
        if dataItem.unique then
            bestRarity = 1
            item:setRarity(5)
            item:setModifiersSlots(5)
            item:rollAttribute(magicFind, 5)
        end
        for x = 1, #dataItem.imps[1] do
          local value = dataItem.imps[2][x][bestRarity]
          if not value then
            value = dataItem.imps[2][x][1] / 2
          end
          item:setImplictValue(x, dataItem.imps[1][x].."|".. value .."|".. 0)
        end
      end

      highestRarity = addToLootInfo(item, lootItems, looted)
    end
  end

  return highestRarity
end
--[[
function generateCustomTierDrops(player, corpse, monsterTier, monsterLevel, lootItems, magicFind)
  local tierDrops = CUSTOM_TIER_DROPS[monsterTier]
  if not tierDrops then
    return 0
  end

  local highestRarity = 0
  local extraChance = (magicFind or 0) / 100

  for _, dropConfig in ipairs(tierDrops) do
    local chance = dropConfig.chance or 100000
    -- If chance is given as percentage <= 100 (e.g. 50 = 50%), convert to 1..100000 scale
    if chance <= 100 then
      chance = chance * 1000
    end
    chance = chance + (chance * extraChance)

    if math.random(1, 100000) <= chance then
      local itemId = nil
      if type(dropConfig.name) == "number" or type(dropConfig.id) == "number" then
        itemId = dropConfig.name or dropConfig.id
      elseif type(dropConfig.name) == "string" then
        local it = ItemType(dropConfig.name)
        if it and it:getId() > 0 then
          itemId = it:getId()
        end
      end

      if not itemId then
        print("[CUSTOM TIER DROP] Item not found: " .. tostring(dropConfig.name or dropConfig.id))
        goto continueCustomDrop
      end

      local count = dropConfig.count or 1
      local item = corpse:addItem(itemId, count, INDEX_WHEREEVER, FLAG_NOLIMIT)
      if not item then
        print("[CUSTOM TIER DROP] Failed to add item: " .. tostring(itemId))
        goto continueCustomDrop
      end

      -- Rarity handling (number 0..6 or string like "Rare", "Epic", "Legendary", "Unique")
      local rarity = dropConfig.rarity or 0
      if type(rarity) == "string" then
        local rName = rarity:lower()
        if rName == "magic" or rName == "common" then
          rarity = 1
        elseif rName == "rare" or rName == "epic" then
          rarity = 3
        elseif rName == "legendary" then
          rarity = 4
        elseif rName == "unique" then
          rarity = 5
        elseif rName == "exalted" then
          rarity = 6
        else
          rarity = 0
        end
      end

      item:setRarity(rarity)
      item:setItemLevel(dropConfig.level or monsterLevel or 100)
      item:setModifiersSlots(rarity)
      if dropConfig.rollAttributes ~= false then
        item:rollAttribute(magicFind or 0, rarity)
      end

      -- Set Implicits (any number of implicits with custom values!)
      local implicits = dropConfig.implicits or dropConfig.imps
      if implicits and #implicits > 0 then
        item:setImplictSlots(#implicits)
        for idx, imp in ipairs(implicits) do
          local impId = imp.id or imp[1]
          local impVal = imp.value or imp[2]
          local impTier = imp.tier or imp[3] or 0
          if impId and impVal then
            item:setImplictValue(idx, impId .. "|" .. impVal .. "|" .. impTier)
          end
        end
      end

      if addToLootInfo then
        local r = addToLootInfo(item, lootItems, nil)
        if r and r > highestRarity then
          highestRarity = r
        end
      end

      ::continueCustomDrop::
    end
  end

  return highestRarity
end
--]]

local FRAGMENTS_BOSS_SPECIAL = {
  {storage = PlayerStorage.monsterModifier_rift, itemID = 37132, orbID = 37131},
  {storage = PlayerStorage.monsterModifier_phantom, itemID = 37129, orbID = 37125},
  {storage = PlayerStorage.monsterModifier_bloody, itemID = 37136, orbID = 37135},
  {storage = PlayerStorage.monsterModifier_armored, itemID = 37142, orbID = 37141},
  -- Tier Boss
  {monsterLevel = 200, itemID = 37147}, -- First Boss zieony earth
  {monsterLevel = 500, itemID = 37155},  -- Second Boss bialy maly t50 = 500
  {monsterLevel = 1200, itemID = 37139},  -- Third Boss maly ognisty T90 = 1200mlvl
  {monsterLevel = 2100, itemID = 37145}, -- Fourth Boss Bialy kolce t120
  -- Bridge Fragments
  {bridge = true, name = "Vampire Queen", itemID = 11229},
  {bridge = true, name = "Toxic Hydra", itemID = 11199},
  {bridge = true, name = "Pheonix", itemID = 29559},

  {bridge = true, name = "Undead King", itemID = 34300},
  {bridge = true, name = "Ethereal Seraph", itemID = 5914},
  {bridge = true, name = "Glacier Warlord", itemID = 34447},

  {bridge = true, name = "Tidal Overlord", itemID = 5895},
  {bridge = true, name = "Fleshrend", itemID = 29802},
  {bridge = true, name = "Arbaziloth", itemID = 11223},

  {bridge = true, name = "Sand Colossus", itemID = 22532},
  {bridge = true, name = "Molten Abyss", itemID = 5809},
  {bridge = true, name = "Toxic Witch", itemID = 34292},
  -- Treasure Goblin special
  {goblin = true, name = "Treasure Goblin", itemID = {15546, 31543, 31540}},

  {realm = true, name = "Blackfang Archer", questDone = 22},
  {realm = true, name = "Thunderlord", questDone = 23},
  {realm = true, name = "Holy Protector", questDone = 24},
  {realm = true, name = "Frost Beast", questDone = 25},
}
function generateBossFragments(player, corpse, lootItems, monster, fragmentCount)
  local highestRarity = 0
  local looted = nil
  local fragmentChance = 1500 -- Szansa na fragment (1.5%)
  local fragmentChanceTier = 3000 -- Szansa na fragment (3%)
  local orbChance = 25      -- Szansa na orba (0.025%)
  local bridgeChance = 1500      -- Szansa na fragment (1.5%)
  local goblinChance = 25 -- 25 -- 0.025%
  local specialStorage = player:getSlotItem(CONST_SLOT_STORE_INBOX):getItemById(38391)
  local specialStorage2 = player:getSlotItem(CONST_SLOT_STORE_INBOX):getItemById(38322)
  if not fragmentCount then
    fragmentCount = 1
  end
  for _, modifier in ipairs(FRAGMENTS_BOSS_SPECIAL) do
    if modifier.realm and monster:getName() == modifier.name then
      	player:finishQuest(modifier.questDone)
			--	runner:startQuest(3)
    end
    if monster:getMonsterLevel() >= 850 and modifier.bridge then -- Bridge Fragments
      if math.random(100000) <= bridgeChance then
        if monster:getName() == modifier.name then
          local item = nil
          if specialStorage then
            item = specialStorage:addItem(modifier.itemID, 1, INDEX_WHEREEVER, FLAG_NOLIMIT)
            looted = player:getName()
          else
            item = corpse:addItem(modifier.itemID, 1, INDEX_WHEREEVER, FLAG_NOLIMIT)
          end
          if item then
            highestRarity = addToLootInfo(item, lootItems, looted)
          end
        end
      end
    end
    if monster:getMonsterLevel() >= 850 and modifier.goblin then -- goblin Fragments
      if math.random(100000) <= goblinChance then
        if monster:getName() == modifier.name then
          local item = nil
          local fragmentGoblin = math.random(1, #modifier.itemID)
          local chosenID = modifier.itemID[fragmentGoblin]
          if specialStorage then
            item = specialStorage:addItem(chosenID, 1, INDEX_WHEREEVER, FLAG_NOLIMIT)
            looted = player:getName()
          else
            item = corpse:addItem(chosenID, 1, INDEX_WHEREEVER, FLAG_NOLIMIT)
          end
          if item then
            highestRarity = addToLootInfo(item, lootItems, looted)
          end
        end
      end
    end
    if monster:getMonsterLevel() == modifier.monsterLevel then -- Losowanie fragmentu Tier Bossa
      if math.random(100000) <= fragmentChanceTier then
        local item = nil
        if specialStorage then
          item = specialStorage:addItem(modifier.itemID, 1, INDEX_WHEREEVER, FLAG_NOLIMIT)
          looted = player:getName()
        else
          item = corpse:addItem(modifier.itemID, 1, INDEX_WHEREEVER, FLAG_NOLIMIT)
        end
        if item then
          highestRarity = addToLootInfo(item, lootItems, looted)
        end
      end
    end
    if monster:getStorageValue(modifier.storage) >= 1 then
      -- Losowanie fragmentu
      if math.random(100000) <= fragmentChance then
        local item = nil
        if specialStorage then
          item = specialStorage:addItem(modifier.itemID, fragmentCount, INDEX_WHEREEVER, FLAG_NOLIMIT)
          looted = player:getName()
        else
          item = corpse:addItem(modifier.itemID, fragmentCount, INDEX_WHEREEVER, FLAG_NOLIMIT)
        end
        if item then
          highestRarity = addToLootInfo(item, lootItems, looted)
        end
      end

      -- Losowanie orba
      if math.random(100000) <= orbChance then
        local orb = nil
        local looted = nil
        if specialStorage2 then
          item = specialStorage2:addItem(modifier.orbID, 1, INDEX_WHEREEVER, FLAG_NOLIMIT)
          looted = player:getName()
        else
          item = corpse:addItem(modifier.orbID, 1, INDEX_WHEREEVER, FLAG_NOLIMIT)
        end
        if orb then
          highestRarity = addToLootInfo(item, lootItems, looted)
        end
      end
    end
  end

  return highestRarity
end

POTION_TIER_LOOT = {
  [1] = { minlevel = 1, maxlevel = 11, tierReward = {7618}, tier = 1, health = 120 }, -- 7620, 7623
  [2] = { minlevel = 12, maxlevel = 20, tierReward = {7588}, tier = 2, health = 230 }, -- 7589, 7622
  [3] = { minlevel = 21, maxlevel = 30, tierReward = {7591}, tier = 3, health = 350 }, -- 7591, 8472
  [4] = { minlevel = 31, maxlevel = 40, tierReward = {8473}, tier = 4, health = 600 }, -- 26029, 26030
  [5] = { minlevel = 41, maxlevel = 48, tierReward = {26031}, tier = 5, health = 800 }, -- 26031, 7621
  [6] = { minlevel = 49, maxlevel = 90, tierReward = {36912}, tier = 6, health = 1100 }, -- 36913, 36916
  [7] = { minlevel = 91, maxlevel = 999999, tierReward = {36912}, tier = 7, health = 1600 }, -- 36913, 36916
}

function generatePotions(player, corpse, difficulty, eliteMonster, boss, monsterLevel, strongBox, strongBoxBoss, lootItems, magicFind)
  local highestRarity = 0
  local looted = nil
    local item = false
    local itemChoose = false
    local tier = 1
    for i = 1, #POTION_TIER_LOOT do
      if monsterLevel >= POTION_TIER_LOOT[i].minlevel and monsterLevel <= POTION_TIER_LOOT[i].maxlevel then
        itemChoose = POTION_TIER_LOOT[i].tierReward[math.random(#POTION_TIER_LOOT[i].tierReward)]
        tier = POTION_TIER_LOOT[i].tier
      end
    end
    if itemChoose then
      item = corpse:addItem(itemChoose, 1, INDEX_WHEREEVER, FLAG_NOLIMIT)
    end

    local dropLevel = monsterLevel
    if monsterLevel > 100 then
      dropLevel = 100
    end

    if item then
      setLootItem(player, item, 0, dropLevel, strongBox, 0)

      item:addRandomCrystalSlots(monsterLevel, magicFind)
      local value = POTION_TIER_LOOT[tier].health
      item:setCustomAttribute("potionHealth", value)
      local rarity = addToLootInfo(item, lootItems, looted)
      if rarity > highestRarity then
        highestRarity = rarity
      end
    end
    return highestRarity
  end

function generateSelfFragment(player, corpse, difficulty, eliteMonster, boss, monsterLevel, strongBox, strongBoxBoss, lootItems, magicFind)
	local rewards = {
		[38541] = {name = "LOOT", buffID = SELF_LOOT_BOOST},
		[38542] = {name = "GOLD", buffID = SELF_GOLD_BOOST},
		[38543] = {name = "EXP",  buffID = BUFF_EXP_BOOST},
	}
  
  local currencyStorage = player:getSlotItem(CONST_SLOT_STORE_INBOX):getItemById(38391)
	-- Tabela z możliwymi fragmentami
  local item = false
  local looted = nil
  local highestRarity = 0
  --[[
	-- Szansa na drop (w procentach)
	local DROP_CHANCE = 100 -- 20%

	-- Sprawdzenie, czy fragment wypadnie
	if math.random(100) > DROP_CHANCE then
		return nil -- nic nie wypadło
	end
  --]]

	-- Wybierz losowy fragment
	local rewardIDs = {38541, 38542, 38543}
	local randomIndex = math.random(1, #rewardIDs)
	local itemChoose = rewardIDs[randomIndex]

	-- Ilość w zależności od poziomu potwora
	local amount = math.random(1,1)
	if monsterLevel >= 31 and monsterLevel <= 70 then
		amount = math.random(1,2)
	elseif monsterLevel >= 71 then
		amount = math.random(2,3)
	end
	-- Dodaj przedmiot do ciała potwora
  if currencyStorage then
    item = currencyStorage:addItem(itemChoose, amount, INDEX_WHEREEVER, FLAG_NOLIMIT)
    looted = player:getName()
  else
    item = corpse:addItem(itemChoose, amount, INDEX_WHEREEVER, FLAG_NOLIMIT)
  end
  if item then
    highestRarity = addToLootInfo(item, lootItems, looted)
  end
	return highestRarity
end
-- Chance 1, ID 2, mlvlDrop 3, modId 4, value 5
--        item:setCustomAttribute("crystal", true)
--        item:setCustomAttribute("slots", 1)
--        item:setAttributeValue(1, "1|50|0|0")
--        item:setRarity(3)
function generateCrystals(player, corpse, difficulty, eliteMonster, boss, monsterLevel, strongBox, strongBoxBoss, lootItems, mapBonus, crystalChance, abyssMonster)
  local highestRarity = 0
  local looted = nil
  local specialStorage = player:getSlotItem(CONST_SLOT_STORE_INBOX):getItemById(38390)
  for i = 1, #CRYSTAL_DROPS do
    if monsterLevel >= CRYSTAL_DROPS[i][3] then
      local rand = math.random(100000)
      local item = false
      local monsterBonus = math.min((monsterLevel / 10), 1000)
      local crystalDropBase = (CRYSTAL_DROPS[i][1] / 2)
      local dropChance = crystalDropBase + (crystalDropBase * (crystalChance + monsterBonus) / 100) -- CRYSTAL_DROPS[i][1] + (CRYSTAL_DROPS[i][1] * (crystalChance + monsterLevel) / 100)
      --[[
      if CRYSTAL_DROPS[i][6] == "Prismatic Crystal" then
        print("Prismatic "..CRYSTAL_DROPS[i][1].." dropChance "..(dropChance / 1000).."%")
      end
      if CRYSTAL_DROPS[i][6] == "Titanforce Crystal" then
        print("Titanforce "..CRYSTAL_DROPS[i][1].." dropChance "..(dropChance / 1000).."%")
      end
      --]]
      if CRYSTAL_DROPS[i][6] == "Abyss Crystal" and abyssMonster then
       dropChance = 100000 -- crystalDropBase + (crystalDropBase * (crystalChance + monsterBonus) / 100)
      end
      if rand <= dropChance then
        local rarityThresholds = {5, 100, 1000, 100000} -- {300, 3000, 9000, 100000}
        local bestRarity = 1
        local randRarity = math.random(100000)
        for x, threshold in ipairs(rarityThresholds) do
          if randRarity <= threshold then
            bestRarity = 5 - x
            break
          end
        end

        item = Game.createItem(CRYSTAL_DROPS[i][2], 1)
        if item then
          if CRYSTAL_DROPS[i].unique then
            bestRarity = 5
          end

          item:setRarity(bestRarity)
          if specialStorage then
            specialStorage:addItemEx(item, INDEX_WHEREEVER, FLAG_NOLIMIT)
            looted = player:getName()
          else
            corpse:addItemEx(item, INDEX_WHEREEVER, FLAG_NOLIMIT)
          end
        end
      end
      if item then
        local rarity = addToLootInfo(item, lootItems, looted)
        if rarity > highestRarity then
          highestRarity = rarity
        end
      end
    end
  end

  return highestRarity
end
-- 1 Chance, 2 ID, 3 mlvlDrop, 4 modId, 5 value

function getAllLootedCurrency(player)
  local currency = {}
  for i = 1, #CURRENCY_DROPS do
    local storedValue = player:getStorageValue(CURRENCY_DROPS[i][4])
    currency[CURRENCY_DROPS[i][6]] = storedValue
  end

  return currency
end

function generateCurrency(player, corpse, difficulty, eliteMonster, boss, monsterLevel, strongBox, strongBoxBoss, lootItems, mapBonus, currencyChance, currencyCountChance, typeItems)
  local highestRarity = 0
  local looted = nil
  local currencyStorage = player:getSlotItem(CONST_SLOT_STORE_INBOX):getItemById(38322)
  -- Special Currency
  for i = 1, #CURRENCY_DROPS do
    if CURRENCY_DROPS[i][10] and CURRENCY_DROPS[i][10] ~= typeItems then
      goto continue
    end

    if monsterLevel >= CURRENCY_DROPS[i][3] then
      local rand = math.random(100000)
      local item = false
      local monsterBonus = math.min((monsterLevel * 0.25), 1000)
      local dropChance = CURRENCY_DROPS[i][1] + (CURRENCY_DROPS[i][1] * (currencyChance + monsterBonus) / 100) -- 300mlvl to 100% szansy + mapa 300% + global 20% + self 20% + monstersoul 20% more currency 100% = 560%
      if CURRENCY_DROPS[i][9] > 0 then
        if monsterLevel > CURRENCY_DROPS[i][9] then
          dropChance = 0
        end
      end

      if strongBoxBoss > 0 and strongBox == 1 and CURRENCY_DROPS[i][8] == "Low" then
        dropChance = 80000
      end
      if strongBoxBoss > 0 and strongBox == 1 and CURRENCY_DROPS[i][8] == "Medium" then
        dropChance = 10000
      end
      if monsterLevel >= 1500 and CURRENCY_DROPS[i][2] == 8303 then -- szuka po ID jesli aby nie wypadal juz item
        dropChance = 0
      end
      local currencyCount = 0
      if rand <= dropChance then
        local maxExtra = 2
        local currentChance = currencyCountChance -- currencyCountChance
        if currencyCountChance > 0 then
          if CURRENCY_DROPS[i][7] then
            for i = 1, maxExtra do
              if math.random(1, 100000) <= currentChance then
                currencyCount = currencyCount + 1
                currentChance = math.floor(currentChance * 0.5)
              else
                break
              end
            end
          else
            currencyCount = 0
          end
        end

        currencyCount = math.random(1, CURRENCY_DROPS[i][5] + currencyCount)
        if currencyStorage then
          item = currencyStorage:addItem(CURRENCY_DROPS[i][2], currencyCount, INDEX_WHEREEVER, FLAG_NOLIMIT)
          looted = player:getName()
        else
          item = corpse:addItem(CURRENCY_DROPS[i][2], currencyCount, INDEX_WHEREEVER, FLAG_NOLIMIT)
        end
      end
      if item then
        local currentPlayerCount = player:getStorageValue(CURRENCY_DROPS[i][4])
        if currentPlayerCount < 0 then
          currentPlayerCount = 0
        end

        player:setStorageValue(CURRENCY_DROPS[i][4], currentPlayerCount + currencyCount)
        local itemType = ItemType(CURRENCY_DROPS[i][2])
        local rarity = addToLootInfo(item, lootItems, looted)
        sendOrb(player, itemType:getClientId(), itemType:getName(), rarity, item:getCount())
        if rarity > highestRarity then
          highestRarity = rarity
        end
      end
    end

    ::continue::
  end

  return highestRarity
end

function generateGold(player, monsterTier, difficulty, elite, boss, monsterLevel, strongBox, strongBoxBoss, typeItems, mapBonus, name, monster)
  local playerId = player:getId()
  local goldBasic = MONSTER_CONFIG[monster:getType():tier()].gold --goldFormula(monsterLevel)
  local gold = 0
  goldBasic = goldBasic + (goldBasic * gold / 100)
  goldBasic = math.ceil(goldBasic)
  local globalGold = 1
  if getGlobalBuff(BUFF_GLOBAL_GOLD) then
    globalGold = globalGold + 0.3 -- 1.2
  end
  if player:hasBuff(MONSTER_SOUL_GOLD) then
    globalGold = globalGold + 1 -- 0.2
  end
  if player:hasBuff(SELF_GOLD_BOOST) then
    globalGold = globalGold + 0.2
  end
  goldBasic = math.ceil(goldBasic * globalGold)
--  goldBasic = math.ceil(math.random(goldBasic * 0.25, goldBasic * 1.5))
  local party = player:getParty()
  if party and party:isSharedExperienceEnabled() then
      local leader = party:getLeader()
      local goldPARTY = math.floor(goldBasic / (party:getMemberCount() + 1))
      leader:setBankBalance(leader:getBankBalance() + goldPARTY)
      leader:refreshBalance()
      sendGold(leader, goldPARTY)
      for _, member in ipairs(party:getMembers()) do
        member:setBankBalance(member:getBankBalance() + goldPARTY)
        member:refreshBalance()
        sendGold(member, goldPARTY)
      end
  else
    player:setBankBalance(player:getBankBalance() + goldBasic)
    player:refreshBalance()
    sendGold(player, goldBasic)
  end
end


function generateRandomUniqueItems(player, corpse, monsterLevel, monsterTier, lootItems, eliteMonster, strongBox, strongBoxBoss, uniqueChance, uniqueCount, magicFind)
  local highestRarity = 0
  local looted = nil
  local itemCount = 0
  if uniqueCount then
    itemCount = itemCount + uniqueCount
  end

  for _ = 1, 1 do -- czy ma dropic kilka unique? math.random(0, math.ceil(monsterLevel/10))
    if math.random(1, 100000) <= uniqueChance then
      itemCount = itemCount + 1
    end
  end
  if itemCount == 0 then
    return 0
  end

  local dropLevel = monsterLevel
  if dropLevel > 100 then
    dropLevel = 100
  end

  local endList = #SERVER_UNIQUE_ITEMS[dropLevel]
  if endList == 0 then
    return 0
  end

  for _ = 1, itemCount do
    local id = math.random(1, endList)
    local uniqueId = SERVER_UNIQUE_ITEMS[dropLevel][id]
    local uniqueItem = US_UNIQUES[uniqueId]
    if uniqueItem then
      if math.random(1, 100) <= uniqueItem.chance then
        local item = generateUniqueItem(player, uniqueId, dropLevel)
        if not item then
          print("Item: "..uniqueItem.name.." not found")
          return
        end

        local itemType = formatItemType(item:getType(), item)
        if itemType ~= 18 and itemType ~= 19 and not uniqueItem.crystalSlots then
          item:addRandomCrystalSlots(monsterLevel, magicFind)
        end
        corpse:addItemEx(item, INDEX_WHEREEVER, FLAG_NOLIMIT)
        highestRarity = addToLootInfo(item, lootItems, looted)
      end
    end

    return highestRarity
  end
end

function generateRandomBossUniqueItems(player, corpse, monsterLevel, monsterName, lootItems, eliteMonster, strongBox, strongBoxBoss, uniqueChance, uniqueCount, magicFind)
  local highestRarity = 0
  local looted = nil
  if not SERVER_BOSS_UNIQUE_ITEMS[monsterName] then
    return 0
  end

  local endList = #SERVER_BOSS_UNIQUE_ITEMS[monsterName]
  if endList == 0 then
    return 0
  end
  local dropLevel = monsterLevel
  if dropLevel > 100 then
    dropLevel = 100
  end


  if math.random(100000) <= 100000 then -- uniqueChance then
    for i = 1, endList do
      local uniqueId = SERVER_BOSS_UNIQUE_ITEMS[monsterName][i]
      local uniqueItem = US_UNIQUES[uniqueId]
      if monsterLevel >= uniqueItem.monsterLevel then
        if math.random(1, 100) <= uniqueItem.chance then
          local item = generateUniqueItem(player, uniqueId, dropLevel)
          if not item then
            print("boss unique Item: " .. uniqueItem.name .. " not found")
            return 0
          end

          local itemType = formatItemType(item:getType(), item)
          if itemType ~= 18 and itemType ~= 19 and not uniqueItem.crystalSlots then
            item:addRandomCrystalSlots(monsterLevel, magicFind)
          end

          corpse:addItemEx(item, INDEX_WHEREEVER, FLAG_NOLIMIT)
          highestRarity = addToLootInfo(item, lootItems, looted)
        end
      end
    end
  end

  return highestRarity
end

function generateRandomSupportItems(player, corpse, monsterLevel, monsterTier, lootItems, eliteMonster, strongBox, strongBoxBoss, supportRuneChance, supportCount, monster)
  local highestRarity = 0
  local itemCount = 0
  local looted = nil
  if supportCount > 0 then
    itemCount = itemCount + supportCount
  end
  for _ = 1, 2 do -- math.random(0, math.ceil(monsterLevel/10))
    if math.random(1, 100000) <= supportRuneChance then
      itemCount = itemCount + 1
    end
  end

  if itemCount == 0 then
    return 0
  end

  local dropLevel = monsterLevel
  if dropLevel > 100 then
    dropLevel = 100
  end

  if not SERVER_SUPPORT_ITEMS[dropLevel] then
    return 0
  end

  local endList = #SERVER_SUPPORT_ITEMS[dropLevel]
  if endList == 0 then
    return 0
  end

  local tier = monster and monster:getStorageValue(PlayerStorage.keyTier) or 0
  if tier < 0 then
    tier = 0
  end

  local maxLevel = dropLevel + (tier * 1)
  maxLevel = math.min(maxLevel, 200)

  for _ = 1, itemCount do
    local id = math.random(1, endList)

    local randBase = SERVER_SUPPORT_ITEMS[dropLevel][id]
    local item = corpse:addItem(randBase, 1, INDEX_WHEREEVER, FLAG_NOLIMIT)
    if not item then
      print("Item: "..randBase.." not found")
      return 0
    end

    local level = math.floor(math.random() ^ 2 * maxLevel) + 1
    item:setCustomAttribute("level", level)
  	item:setCustomAttribute("exp", expForLevelSpell(level))
    correctSpellExpAndRarity(item, level)
    local rarirty = addToLootInfo(item, lootItems, looted)
    if rarirty > highestRarity then
      highestRarity = rarirty
    end
  end

  return highestRarity
end

function generateRandomSpellItems(player, corpse, monsterLevel, monsterTier, lootItems, eliteMonster, strongBox, strongBoxBoss, spellRuneChance, spellCount, magicFind, monster)
  local itemCount = 0
  local highestRarity = 0
  local looted = nil
  if spellCount > 0 then
    itemCount = itemCount + spellCount
  end
  for i = 1, 2 do -- math.random(0, math.ceil(monsterLevel/10))
    if math.random(1, 100000) <= spellRuneChance then
      itemCount = itemCount + 1
    end
  end

  if itemCount == 0 then
    return 0
  end

  local dropLevel = monsterLevel
  if dropLevel > 100 then
    dropLevel = 100
  end

  if not SERVER_RUNES_ITEMS[dropLevel] then
    print("can't find loot for level: " .. dropLevel)
    return 0
  end

  local endList = #SERVER_RUNES_ITEMS[dropLevel]
  if endList == 0 then
    return 0
  end
  local tier = monster and monster:getStorageValue(PlayerStorage.keyTier) or 0
  if tier < 0 then
    tier = 0
  end

  local maxLevel = dropLevel + (tier * 2)
  maxLevel = math.min(maxLevel, 300)

  for _ = 1, itemCount do
    local id = math.random(1, endList)
    local randBase = SERVER_RUNES_ITEMS[dropLevel][id]
    local item = corpse:addItem(randBase, 1, INDEX_WHEREEVER, FLAG_NOLIMIT)
    if not item then
      print("Item: "..randBase.." not found")
      return 0
    end

    local level = math.floor(math.random() ^ 2 * maxLevel) + 1
    item:setCustomAttribute("level", level)
    item:setCustomAttribute("exp", expForLevelSpell(level))

    item:addRandomCrystalSlots(monsterLevel, magicFind)

    correctSpellExpAndRarity(item, level)
    --[[
    if not item:getCustomAttribute("empower_spellrune") then
      if math.random(100000) <= 500 then
        item:setCustomAttribute("empower_spellrune", math.random(1, 10))
        item:setAttribute(ITEM_ATTRIBUTE_NAME, "Enhanced " .. item:getName() .. "")
      end
    else
      if math.random(100000) <= 500 then
        item:setCustomAttribute("empower_spellrune", math.random(1, 10))
        item:setAttribute(ITEM_ATTRIBUTE_NAME, "Enhanced " .. item:getName() .. "")
      else
        item:removeCustomAttribute("empower_spellrune")
      end
    end
    --]]
    local rand_quality = math.random(100)
    if rand_quality <= 5 then
      item:setQuality(math.random(8,10))
    elseif rand_quality <= 20 then
      item:setQuality(math.random(4,7))
    else
      item:setQuality(math.random(1,3))
    end

    local rarirty = addToLootInfo(item, lootItems, looted)
    if rarirty > highestRarity then
      highestRarity = rarirty
    end
  end

  return highestRarity
end

function generateRandomBaseItems(player, corpse, monsterLevel, monsterTier, lootItems, eliteMonster, strongBox, strongBoxBoss, basicCount, basicChance, magicFind)
  local highestRarity = 0
  local looted = nil
  local itemCount = 0
  if basicCount > 0 then
    itemCount = itemCount + basicCount
  end
  local countMob = math.min(10, (monsterLevel /10))
--  print("ilosc na mlvl moba "..countMob.." basicChance "..basicChance.."")
  for i = 1, math.random(0, countMob) do
    if math.random(1, 100000) <= basicChance then
      itemCount = itemCount + 1
    end
  end
  if itemCount == 0 then
    return 0
  end
  local dropLevel = monsterLevel
  if dropLevel > 100 then
    dropLevel = 100
  end
  local endList = #SERVER_BASE_ITEMS[dropLevel]
  if endList == 0 then
    return 0
  end
  for _ = 1, itemCount do
    local id = math.random(1, endList)
    local randBase = SERVER_BASE_ITEMS[dropLevel][id]
    if randBase then
      local chance = randBase[5] or 10000
      if math.random(1, 100000) <= chance then
        local item = generateBaseItem(player, strongBox, randBase, dropLevel, magicFind)
        if item then
          corpse:addItemEx(item, INDEX_WHEREEVER, FLAG_NOLIMIT)
          local rarity = addToLootInfo(item, lootItems, looted)
          if rarity > highestRarity then
            highestRarity = rarity
          end
        end
      end
    end
  end

  return highestRarity
end

local function getDrops(monsterLevel)
  local drops = {}
  for lvl, items in pairs(DUNGEON_KEYS) do
    if lvl <= monsterLevel then
      for _, item in ipairs(items) do
        table.insert(drops, item)
      end
    end
  end
  return drops
end

function generateDungeonKey(player, corpse, monsterLevel, monsterTier, lootItems, eliteMonster, strongBox, strongBoxBoss, keyChance, monster, dungeonBoss)
  local highestRarity = 0
  local looted = nil
  local specialStorage = player:getSlotItem(CONST_SLOT_STORE_INBOX):getItemById(38445)
  local itemCount = 0
  if math.random(1, 100000) <= keyChance then
    itemCount = itemCount + 1
  end

  if itemCount == 0 then
    return 0
  end

  local dropLevel = monsterLevel
  if dropLevel < 100 then
    return 0
  end

  local possibleDrops = getDrops(monsterLevel)
  if not possibleDrops or #possibleDrops == 0 then
    print("not found key for" .. dropLevel)
    return 0
  end

  local endList = #possibleDrops
  if endList == 0 then
    return 0
  end

  for _ = 1, itemCount do
    local id = math.random(1, endList)
    local randBase = possibleDrops[id]
    local item
    if specialStorage then
      item = specialStorage:addItem(randBase, 1, INDEX_WHEREEVER, FLAG_NOLIMIT)
      looted = player:getName()
    else
      item = corpse:addItem(randBase, 1, INDEX_WHEREEVER, FLAG_NOLIMIT)
    end
    if not item then
      print("Item: "..randBase.." not found dungeon key")
      return 0
    end

    local attrIds = {}
    local slots = math.random(1, 6)
    local specialModifiers = {12, 13, 14, 15}
    local specialUsed = false
    local rarity = slots
    if slots >= 3 then
      rarity = 3
    end
    item:setRarity(rarity)
    item:setModifiersSlots(slots)

    for i = 1, slots do
      local attrId = math.random(1, #US_DUNGEONS_MODIFIERS)
      local attr = US_DUNGEONS_MODIFIERS[attrId]
      while isInArray(attrIds, attrId) or attr.minLevel and monsterLevel < attr.minLevel or (isInArray(specialModifiers, attrId) and specialUsed) or
		  attr.chance and math.random(100) >= attr.chance do
        attrId = math.random(1, #US_DUNGEONS_MODIFIERS)
        attr = US_DUNGEONS_MODIFIERS[attrId]
      end
      if isInArray(specialModifiers, attrId) then
        specialUsed = true
      end
      table.insert(attrIds, attrId)

      local tierAttributeRandom = 1
      for i = 1, #TIER_AFFIXES do
        if monsterLevel >= TIER_AFFIXES[i][3] then
          local rand = math.random(100000)
          if rand <= TIER_AFFIXES[i][1] then
            tierAttributeRandom = math.random(1, TIER_AFFIXES[i][2])
            break
          end
        end
      end

      if monsterLevel >= EXALTED_ITEMS[1] and math.random(100) <= EXALTED_ITEMS[2] then
        if math.random(100) <= EXALTED_ITEMS[3] then
          tierAttributeRandom = 7
        else
          tierAttributeRandom = 6
        end
      end

      local value = {1, 1}
      local finalValue = 1
      if not attr.noValue then
        value = attr.TIER[tierAttributeRandom]
        finalValue = math.random(value[1], value[2])
      end
      item:addDungeonModifier(i, attrId, finalValue, tierAttributeRandom)
      if tierAttributeRandom >= 6 then 
        item:setRarity(6)
      end
    end

    item:setCustomAttribute("DungeonKey", true)
    item:setItemLevel(monsterLevel)
    if monsterLevel >= 100 and player:getStorageValue(PlayerStorage.endGame) > 0 then
      local keyTier = monster and monster:getStorageValue(PlayerStorage.keyTier) or 0
      if keyTier < 0 then
        keyTier = 1
      end

      if keyTier > 0 then
      local bossTier = player:getStorageValue(PlayerStorage.endGameBossTierUnlocked)
      if dungeonBoss then
        if keyTier < 20 then -- do 19 podnosi sie o 1
          keyTier = keyTier + 1
        elseif keyTier >= 121 and bossTier >= 5 then
          keyTier = keyTier + 1
        elseif keyTier >= 90 and keyTier < 120 and bossTier >= 4 then -- od 65 wzwyż podnosi się o 1 tylko jeśli bossTier == 3
          keyTier = keyTier + 1
        elseif keyTier >= 70 and keyTier < 90 and bossTier >= 3 then -- od 65 wzwyż podnosi się o 1 tylko jeśli bossTier == 3
          keyTier = keyTier + 1
        elseif keyTier >= 50 and keyTier < 70 and bossTier >= 2 then -- od 50 do 64 podnosi się o 1 tylko jeśli bossTier == 2 Relicty Mitigation ?
          keyTier = keyTier + 1
        elseif keyTier >= 20 and keyTier < 50 and bossTier >= 1 then -- od 20 do 49 podnosi się o 1 tylko jeśli bossTier == 1 Relicty Overpower ?
          keyTier = keyTier + 1
        elseif keyTier >= 1 and keyTier < 20 and bossTier < 0 then -- od 1 do 19
          keyTier = keyTier + 1
        else
        -- w przeciwnym wypadku keyTier nie wzrasta
        end

      end
      if keyTier >= 125 then
        keyTier = 125
      end
      local itemLevel = getMonsterLevelByKeyTier(keyTier)
      item:setItemLevel(itemLevel)
      item:setCustomAttribute("keytier", keyTier)
      end
    end

    item:updateSelf()
    local rarirty = addToLootInfo(item, lootItems, looted)
    if rarirty > highestRarity then
      highestRarity = rarirty
    end
  end

  return highestRarity
end

function generateServerBaseItems()
  for i = 0, MAX_MONSTER_LEVEL do
    SERVER_BASE_ITEMS[i] = {}
    for x = 1, i do
      if BASE_ITEMS[x] then
        for y = 1, #BASE_ITEMS[x] do
          table.insert(SERVER_BASE_ITEMS[i], BASE_ITEMS[x][y])
        end
      end
    end
  end
end
generateServerBaseItems()

function generateServerBaseItemsByTypes()
  for i = 0, MAX_MONSTER_LEVEL do
    SERVER_BASE_ITEMS_BY_TYPES[i] = {}
    for j = 1, 16 do
      SERVER_BASE_ITEMS_BY_TYPES[i][j] = {}
    end

    for x = 1, #SERVER_BASE_ITEMS[i] do
      local item = ItemType(SERVER_BASE_ITEMS[i][x][2])
      if item then
        local itemType = formatItemType(item)
        if itemType == 0 then
          print("Something went wrong with item: "..item:getName() .. " ID: "..item:getId())
        end

        if SERVER_BASE_ITEMS_BY_TYPES[i][itemType] then
          table.insert(SERVER_BASE_ITEMS_BY_TYPES[i][itemType], SERVER_BASE_ITEMS[i][x])
        end
      end
    end
  end
end
generateServerBaseItemsByTypes()

function generateBaseItemsById()
	for i = 1, MAX_MONSTER_LEVEL do
		if BASE_ITEMS[i] then
			for j = 1, #BASE_ITEMS[i] do
				local item = BASE_ITEMS[i][j]
				BASE_ITEMS_BY_ID[item[2]] = item
			end
		end
	end
end
generateBaseItemsById()


function generateServerRuneItems()
  for i = 1, MAX_MONSTER_LEVEL do
    if not SERVER_RUNES_ITEMS[i] then
      SERVER_RUNES_ITEMS[i] = {}
    end
    
    for x = 1, i do
      if RUNE_ITEMS[x] then
        for y = 1, #RUNE_ITEMS[x] do
          table.insert(SERVER_RUNES_ITEMS[i], RUNE_ITEMS[x][y])
        end
      end
    end
  end
end
generateServerRuneItems()

function generateServerSupportItems()
  for i = 1, MAX_MONSTER_LEVEL do
    if not SERVER_SUPPORT_ITEMS[i] then
      SERVER_SUPPORT_ITEMS[i] = {}
    end
    
    for x = 1, i do
      if SUPPORT_ITEMS[x] then
        for y = 1, #SUPPORT_ITEMS[x] do
          table.insert(SERVER_SUPPORT_ITEMS[i], SUPPORT_ITEMS[x][y])
        end
      end
    end
  end
end
generateServerSupportItems()

function generateServerUniqueItems()
  for i = 1, #US_UNIQUES do
    local uniqueItem = US_UNIQUES[i]
    local from = uniqueItem.monsterLevel
    local to = uniqueItem.maxMonsterLevel or 100

    if uniqueItem.boss then
      if not SERVER_BOSS_UNIQUE_ITEMS[uniqueItem.boss] then
        SERVER_BOSS_UNIQUE_ITEMS[uniqueItem.boss] = {}
      end

      table.insert(SERVER_BOSS_UNIQUE_ITEMS[uniqueItem.boss], i)
    else
      for x = from, to do
        if not SERVER_UNIQUE_ITEMS[x] then
          SERVER_UNIQUE_ITEMS[x] = {}
        end
        table.insert( SERVER_UNIQUE_ITEMS[x], i)
      end
    end
  end

  for i = 1, MAX_MONSTER_LEVEL do
    if not SERVER_UNIQUE_ITEMS[i] then
      SERVER_UNIQUE_ITEMS[i] = {}
    end
  end
end
generateServerUniqueItems()

function generateServerUniqueItemsByTypes()
  for i = 1, MAX_MONSTER_LEVEL do
    SERVER_UNIQUE_ITEMS_BY_TYPES[i] = {}
    for j = 1, 19 do
      SERVER_UNIQUE_ITEMS_BY_TYPES[i][j] = {}
    end

    for x = 1, #SERVER_UNIQUE_ITEMS[i] do
      local uniqueItem = US_UNIQUES[SERVER_UNIQUE_ITEMS[i][x]]
      if uniqueItem then
        local item = ItemType(uniqueItem.itemId)
        if item then
          local itemType = formatItemType(item)
          if itemType == 0 then
            print("Something went wrong with item: "..uniqueItem.name)
          else
            table.insert(SERVER_UNIQUE_ITEMS_BY_TYPES[i][itemType], SERVER_UNIQUE_ITEMS[i][x])
          end
        end
      end
    end
  end
end
generateServerUniqueItemsByTypes()

function generateRandomImplictBaseValue(item, value, monsterLevel, lastValue, perfect) -- First
  local minValue = math.floor((value * monsterLevel / 100) * 0.7) -- math.ceil((value + math.floor((value * monsterLevel / 100))) / 2)
  local maxValue = math.floor(value * monsterLevel / 100) -- math.ceil((value + math.ceil((value * monsterLevel / 100) )) * 1.5)
  if perfect then
    minValue = maxValue
  end
  local affix = math.random(minValue, maxValue)
  if affix <= 0 then affix = 1 end
  if lastValue then
    if lastValue > affix then
      affix = lastValue
    end
  end
  return affix
end

function sendCreatureCorpse(player, outfit, id, name)
	if not player or player == nil or player:isRemoved() or not id or not name then
		return
	end

  player:sendExtendedOpcode(ExtendedOPCodes.CODE_LOOTINFO, json.encode({1, {
    id = id,
    n = name,
    o = outfit,
  }}))
end

function sendLoot(player, loot, id)
	if not player or player == nil or player:isRemoved() or not id then
		return
	end

  player:sendExtendedOpcode(ExtendedOPCodes.CODE_LOOTINFO, json.encode({2, {
    id = id,
    l = loot
  }}))
end

function sendLootedItem(player, uid, id, errFound, sid)
  if not player or player == nil or player:isRemoved() or not uid or not id then
		return
	end

  sid = sid or 0

  if errFound and errFound == 1 then
    sendLootedItemToPlayer(player, "", uid, id, errFound, sid)
    return
  end

  local party = player:getParty()
  local name = player:getName()
  if party and party:isSharedExperienceEnabled() then
    local leader = party:getLeader()
    for _, member in ipairs(party:getMembers()) do
      sendLootedItemToPlayer(member, name, uid, id, 0, sid)
    end
    sendLootedItemToPlayer(leader, name, uid, id, 0, sid)
    return
  else
    sendLootedItemToPlayer(player, name, uid, id, 0, sid)
  end
end

function sendLootedItemToPlayer(player, name, uid, id, errFound, sid)
  if not player or player == nil or player:isRemoved() or not uid or not id then
    return
  end

  player:sendExtendedOpcode(ExtendedOPCodes.CODE_LOOTINFO, json.encode({3, {id = id, u = uid, n = name, e = errFound, s = sid}}))
end

function sendGold(player, gold)
  if not player or player == nil or player:isRemoved() or not gold then
		return
	end

  player:sendExtendedOpcode(ExtendedOPCodes.CODE_LOOTINFO, json.encode({4, gold}))
end

function sendExp(player, xp)
  if not player or player == nil or player:isRemoved() or not xp then
		return
	end

  player:sendExtendedOpcode(ExtendedOPCodes.CODE_LOOTINFO, json.encode({5, xp}))
end

function sendOrb(player, orb, text, color, count)
  if not player or player == nil or player:isRemoved() or not orb then
    return
  end

  player:sendExtendedOpcode(ExtendedOPCodes.CODE_LOOTINFO, json.encode({6, {orb,text,color,count}}))
end

local affixes = {
  {name = "damage reduced", skull = 7},
  {name = "reflect damage", skull = 8},
  {name = "More Health", skull = 9, multiplier = 1.5},
  {name = "Clone", skull = 10, clone = true},
  {name = "Plagued", skull = 13}, {name = "Waller", skull = 14},
  {name = "Stronger", skull = 15}, {name = "Vampiric", skull = 16},
  {name = "Electrified", skull = 17}, {name = "Pusher", skull = 18},
  {name = "Puller", skull = 19}, {name = "Dodger", skull = 20},
  {name = "Anti Magic", skull = 21}, {name = "Critical", skull = 22},
  {name = "Fast", skull = 23, condition = CONDITION_HASTE, speed = 1000},
  {name = "Golden", skull = 24}, {name = "Crystal", skull = 25},
  {name = "Lucker", skull = 26}, {name = "Iced", skull = 28},
  {name = "Fire", skull = 29}, {name = "Death", skull = 30},
  {name = "Holy", skull = 31}, {name = "Energy", skull = 32},
  {name = "Poison", skull = 33}, {name = "Physical", skull = 34}
}

function applyEliteAffix(monster, chance, pos, dungeon)
  local mType = monster:getType()
  local start = true
  if mType:items() == "titan" or mType:items() == "dummy" or mType:items() == "dungeonboss" or monster:getSkull() >= 7 then
    start = false
  end
  local monsterLevel = monster:getMonsterLevel()
  if math.random(1, 100) <= chance and monster and start then
      monster:registerEvent("SpellHealthChangeEvent")
      monster:registerEvent("UpgradeSystemHealth")
      monster:registerEvent("UpgradeSystemDeath")
      monster:registerEvent("BossDeath")
      monster:registerEvent("StrongBoxDeath")
      monster:registerEvent("StoneRespawnDeath")
      monster:registerEvent("TaskDeath")
      monster:registerEvent("EliteLoot")
      monster:registerEvent("EliteAffixHP")
      local rand = math.random(1, 25)
      if rand == 2 then
          rand = 3
      elseif rand == 5 then
          rand = 6
      elseif rand == 9 then
          rand = 10
      end
      local monsterHPset = monster:getMaxHealth() * 2.5
      monster:setMaxHealth(monsterHPset)
      monster:setHealth(monsterHPset)
      if dungeon then
        local instance = monster:getInstance()
        if instance then
          instance:addMonster(monster)
          local config = INSTANCE_MONSTER_MODIFIERS[instance:getKeyUID()]
          if config then
            monster:setStorageValue(PlayerStorage.keyTier, config.tier)
          end
        end
      end
      local affix = affixes[rand]
      if affix then
          monster:setStorageValue(PlayerStorage.eliteAffixes, rand)
          monster:setSkull(affix.skull)
          if affix.name == "More Health" then
              monster:setMaxHealth(monster:getMaxHealth() * affix.multiplier)
              monster:setHealth(monster:getMaxHealth())
          elseif affix.clone then
              local name = monster:getName()
              for i = 1, 2 do
                local clone = Game.createMonster(name, pos, false, true)
                if clone then
                  clone:setMonsterLevel(monsterLevel)
                  clone:setStorageValue(PlayerStorage.eliteAffixes, rand)
                  clone:setMaxHealth(monster:getMaxHealth())
                  clone:setHealth(monster:getMaxHealth())
                  clone:setSkull(affix.skull)
                  clone:registerEvent("EliteAffixHP")
                  if dungeon then
                    local instance = monster:getInstance()
                    if instance then
                      instance:addMonster(clone)
                      local config = INSTANCE_MONSTER_MODIFIERS[instance:getKeyUID()]
                      if config then
                        applyMonsterModifiers(clone, config, instance)
                      end
                    end
                  end
                end
              end
          elseif affix.condition then
              local condition = Condition(affix.condition)
              condition:setParameter(CONDITION_PARAM_TICKS, -1)
              condition:setParameter(CONDITION_PARAM_SPEED, affix.speed)
              monster:addCondition(condition)
          end
      end

      if monster:getSkull() >= 7 then
          local outfit = monster:getOutfit()
          outfit.lookHealthBar = 2
          monster:setOutfit(outfit)
      end
  end
end

function Monster:onSpawn(position, startup, artificial, dungeon)
  self:registerEvent("SpellHealthChangeEvent")
  self:registerEvent("UpgradeSystemHealth")
  self:registerEvent("UpgradeSystemDeath")
  self:registerEvent("BossDeath")
  self:registerEvent("StrongBoxDeath")
  self:registerEvent("StoneRespawnDeath")
  self:registerEvent("TaskDeath")
  self:registerEvent("EliteLoot")
  self:registerEvent("EliteAffixHP")
  self:registerEvent("BuffDeath")

  if self:getName() == "Dummy DPS" or self:getName() == "Dummy Armored" or self:getName() == "Dummy Boss" then
    self:registerEvent("EventDPS")
  end

  local selfName = self:getName()
  local mType = self:getType()
  local setHP = true

  if selfName =="Toxic Hydra" then
    setHP = false
  end
  if mType:items() == "titan" or mType:items() == "dummy" or mType:items() == "dungeonboss" or mType:items() == "stone" or mType:items() == "stoneminion" then
    setHP = false
  end
  if selfName =="Treasure Goblin" then
    setHP = false
  end
  if setHP then
    local chance = 3
    local monsterLevel = self:getMonsterLevel()
    local monsterHP = healthFormula(monsterLevel)
    self:setMaxHealth(monsterHP)
    self:setHealth(monsterHP)
    if not dungeon then
      applyEliteAffix(self, chance, position)
    end
  end
  return true
end

CRYSTAL_DATA_FROM_ID = {}
function prepareCrystals()
  for _, crystal in ipairs(CRYSTAL_DROPS) do
    CRYSTAL_DATA_FROM_ID[crystal[2]] = {crystal[4], crystal[5]}
  end
end
prepareCrystals()

function prepareOtherItemsForClient()
  local other_items = {}
  other_items.TOOLTIP_DATA = {}

  other_items.DUNGEON_KEYS = {}
  for level, id in pairs(DUNGEON_KEYS) do
    local item = ItemType(id[1])
    if item then
      table.insert(other_items.DUNGEON_KEYS, {item:getName(), id[1], level})
    end
  end

  other_items.SUPPORT_ITEMS = {}
  for level, id in pairs(SUPPORT_ITEMS) do
    for i = 1, #id do
      local item = ItemType(id[i])
      if item then
        table.insert(other_items.SUPPORT_ITEMS, {item:getName(), id[i], level, BUYABLE_ITEMS_BY_ID[id[i]]})
      end
    end
  end

  other_items.RUNE_ITEMS = {}
  for level, id in pairs(RUNE_ITEMS) do
    for i = 1, #id do
      local item = ItemType(id[i])
      if item then
        table.insert(other_items.RUNE_ITEMS, {item:getName(), id[i], level, BUYABLE_ITEMS_BY_ID[id[i]]})
      end
    end
  end

  other_items.CRYSTAL_ITEMS = {}
  for index, crystal in ipairs(CRYSTAL_DROPS) do
    local item = ItemType(crystal[2])
    if item then
      local extraInfoCrystal = table.copy(CRYSTAL_DATA_FROM_ID[crystal[2]])
      table.insert(other_items.CRYSTAL_ITEMS, {item:getName(), crystal[2], crystal[3], extraInfoCrystal[1], extraInfoCrystal[2], CRYSTAL_ITEMTYPES[crystal[2]], crystal[1]})
      other_items.TOOLTIP_DATA[crystal[2]] = {index, TYPE_CRYSTAL}
    end
  end

  other_items.CURRENCY_ITEMS = {}
  
  for _, currency in ipairs(CURRENCY_DROPS) do
    local item = ItemType(currency[2])
    if item then
      table.insert(other_items.CURRENCY_ITEMS, {currency[6], currency[2], currency[3], currency[1], item:getColor()})
    end
  end

  local extraCurrency = { 37131, 37125, 37135, 37141 }
  for _, id in ipairs(extraCurrency) do
    local itemType = ItemType(id)
    if itemType then
      table.insert(other_items.CURRENCY_ITEMS, {itemType:getName(), id, 0, 0, itemType:getColor()})
    end
  end

  other_items.RELICS = {}
  for bossName, data in pairs(BOSS_DROP_ITEMS) do
    for itemId, itemData in pairs(data) do
      local item = ItemType(itemId)
      if item then
        table.insert(other_items.RELICS, {item:getName(), itemId, bossName, itemData})
      end
    end
  end

  other_items.FRAGMENTS = {}

  local extraFramgents = { 38541, 38542, 38543 }

  for _, id in ipairs(extraFramgents) do
    local itemType = ItemType(id)
    if itemType then
      table.insert(other_items.FRAGMENTS, {itemType:getName(), id, itemType:getColor()})
    end
  end

  for fragmentId, fragmentData in pairs(FRAGMENTS_BOSS_SPECIAL) do
    if not fragmentData.itemID then
      goto continue
    end

    if type(fragmentData.itemID) == "table" then
      for _, id in ipairs(fragmentData.itemID) do
        local itemType = ItemType(id)
        if itemType then
          if itemType:getClientId() == 0 then
            print("Wrong fragment id in FRAGMENTS_BOSS_SPECIAL: "..id.."")
            goto continue
          end
          table.insert(other_items.FRAGMENTS, {itemType:getName(), id, itemType:getColor()})
        end
      end
      goto continue
    end

    local itemType = ItemType(fragmentData.itemID)
    if itemType then
      if itemType:getClientId() == 0 then
        print("Wrong fragment id in FRAGMENTS_BOSS_SPECIAL: "..fragmentData.itemID.."")
        goto continue
      end
      table.insert(other_items.FRAGMENTS, {itemType:getName(), fragmentData.itemID, itemType:getColor()})
    end
    ::continue::
  end

  local file = io.open("data/other_items.lua", "w")
  if not file then
    print("Error: Can't open file")
    return false
  end

  file:write("OTHER_ITEMS = " .. serpent.block(other_items, {comment = false, reflinks = true}))

  file:close()
end
addEvent(prepareOtherItemsForClient, 10000)

function createEncyclopediaInfo()
  local encyclopediaItems = {
    BASE_ITEMS = {}
  }

  for level, items in pairs(BASE_ITEMS) do
    for i = 1, #items do
      local data = items[i]
      local item = ItemType(data[2])
      if item then
        local multiplier = item:getSlotPosition() == 1072 and TWO_HANDED_MULTIPLIER or 1.0
        local implicts = {}
        for _, implict in ipairs(data[3]) do
          table.insert(implicts, {implict[1], implict[2] * multiplier})
        end

        if not encyclopediaItems.BASE_ITEMS[level] then
          encyclopediaItems.BASE_ITEMS[level] = {}
        end
        table.insert(encyclopediaItems.BASE_ITEMS[level], {data[1], item:getClientId(), formatItemType(item), implicts})
      end
    end
  end

  local file = io.open("data/encyclopedia_data.lua", "w")
  if not file then
    print("Error: Can't open file")
    return false
  end

  file:write("ENCYCLOPEDIA = " .. serpent.block(encyclopediaItems, {comment = false}))
  file:close()
end
createEncyclopediaInfo()

  CRYSTAL_SLOT_CHANCES = {
	-- chance, Tier, odMonsterLevel, 
--	{ 10,   6, 46 },
	{ 100,  5, 46 },
	{ 500,  4, 46 },
	{ 1000,  3, 46 },
	{ 2000, 2, 46 },
	{ 10000, 1, 46 },
  }
function Item:addRandomCrystalSlots(monsterLevel, magicFind)
  local slots = 0
  for i = 1, #CRYSTAL_SLOT_CHANCES do
    if monsterLevel >= CRYSTAL_SLOT_CHANCES[i][3] then
      local rand = math.random(100000)
      local chance = CRYSTAL_SLOT_CHANCES[i][1] + (CRYSTAL_SLOT_CHANCES[i][1] * (monsterLevel + magicFind) / 1000)
      if rand <= chance then
        slots = CRYSTAL_SLOT_CHANCES[i][2]
        break
      end
    end
  end
  self:setCrystalSlots(slots)
end

function addToLootInfo(item, lootItems, looted)
  local rarity = item:getRarityId()
  if rarity == 0 then
    rarity = item:getColor()
  end
  local uid = item:getRealUID()
  if uid == 0 then
    uid = nil
  end
  local crystalSlots = item:getCrystalSlots()
  if crystalSlots == 0 then
    crystalSlots = nil
  end
  local itemLevel = item:getItemLevel()
  if itemLevel == 0 then
    itemLevel = nil
  end
  local spellLevel = item:getCustomAttribute("level") or nil
  if spellLevel then
    itemLevel = spellLevel
  end

  local quality = item:isQuality()
  if quality == 0 then
    quality = nil
  end


  local itemType = item:getType()
  local currentAttr = item:getBonusAttributes()

  local item_data = {
    c = item:getCount(),
    ci = itemType:getClientId(),
    l = itemLevel,
    u = uid,
    t = formatItemType(itemType, item),
    r = rarity,
    i = item:getId(),
    m = currentAttr,
    cs = crystalSlots,
    lo = looted,
    qu = quality,
    dt = item:getCustomAttribute("keytier"),
  }
  table.insert(lootItems, item_data)

  return rarity
end

function prepareBossDropsById()
  for name, data in pairs(BOSS_DROP_ITEMS) do
    for id, itemData in pairs(data) do
      if BOSS_DROPS_BY_ID[id] then
        print("Found duplicate id in BOSS DROPS " .. id)
      end

      BOSS_DROPS_BY_ID[id] = itemData
      BOSS_DROPS_BY_ID[id].monster = name
    end
  end

  BOSS_DROPS_BY_ID[38418] = {
    chance = 0,
    weight = {0, 0, 0, 0},
  }
end
prepareBossDropsById()