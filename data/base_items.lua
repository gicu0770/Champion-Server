BASE_ITEMS = {
  [1] = {
    -- wolf 1lvl
    {"Clerical Mace", 2423, { {19, 30}, {89, 45} }}, -- 1h melee damage
    {"Crimson Sword", 36666, { {19, 30}, {89, 45} }}, -- 1h melee damage
    {"Bronze Axe", 26618, { {19, 30}, {89, 45} }}, -- 2h melee damage
    {"Bow", 2456, { {19, 30}, {91, 45} }}, -- 2h distance damage
    {"Scout Knife", 13828, { {19, 30}, {91, 45} }}, -- 1h distance damage {19, 30}
    {"Wooden Wand", 26637, { {19, 30}, {90, 45} }}, -- 1h magic damage
    {"Staff of Vortex", 2190, { {19, 30}, {90, 45} }}, -- spell damage 2h magic damage

    {"Leather Helmet", 26435, { {53, 50}, {1, 250} }},
    {"Leather Armor", 26436, { {53, 50}, {1, 250} }},
    {"Leather Legs", 26437, { {53, 50}, {1, 250} }},
    {"Boots", 26438, { {53, 50}, {1, 250}, {27, 15} }},
    {"Leather Shield", 26439, { {9, 10}, {8,20}, {96, 45} }}, -- 12 defense melee damage

    {"Ring", 2169, {  }},
    {"Amulet", 2170, {  }},
    {"Gloves", 37798, {  }},

  },
  [5] = {
    -- minoua 5lvl
    {"Bronze Helmet", 26392, { {53, 100} }},
    {"Elven Helmet", 26490, { {9, 10} }},
    {"Elder Helmet", 26523, { {71, 250} }},

    {"Weak Gloves", 36400, { {19, 30} }}, -- basic damage

    {"Scarf", 2661, { {23, 6} }}, -- health regeneration
    {"Gearwheel Chain", 23541, { {53, 100} }}, -- Armor
    {"Scarab Amulet", 2135, { {71, 250} }}, -- Energy Shield

    {"Crystal Ring", 2124, { {1, 250} }}, -- health
    {"Weeding Ring", 2121, { {24, 4} }}, -- mana regeneration
  },
  [8] = {
    -- cyclops 8 lvl
    {"Throwing Knife", 37841, { {29, 3}, {91, 45} }}, -- 1h Knife 4 attack critical
    {"Bronze Sword", 26608, { {11, 15}, {89, 45} }}, -- 1h Sword 4 attack physical damage
    {"Nightmare Blade", 7418, { {55, 12}, {89, 45} }}, -- 2h Sword 8 attack attack speed
    {"Elven Bow", 15643, { {31, 10}, {91, 45} }}, -- 2h Bow 8 attack penetration
    {"Elder Wand", 26552, { {18, 10}, {90, 45} }}, -- 1h Rod 4 attack spell damage
    {"Snakebite Staff", 2182, { {12, 15}, {90, 45} }}, -- 2h Rod 8 attack -- Elemental Damage

    {"Elder Shield", 26749, { {71, 300}, {8, 40}, {96, 45} }}, -- 20 defense
  },
  [12] = {
    -- dragons 12 lvl
    {"Bronze Armor", 26393, { {53, 100} }},
    {"Elder Armor", 26524, { {71, 250} }},
    {"Elven Armor", 26491, { {9, 10} }},
  },
  [17] = {
    -- hellfire and hellhound 17 lvl
    {"Elder Legs", 26525, { {71, 250} }},
    {"Elven Legs", 26492, { {9, 10} }},
    {"Bronze Legs", 26394, { {53, 100} }},
    {"Bronze Shield", 26570, { {1, 200}, {8,45}, {96, 45} }}, -- bronze shield Rod 30 defense
    -- demons 21 lvl
    {"Copper Mace", 26643, { {46, 20}, {89, 45} }}, -- 6 attack 1h health on hit
    {"Moohtant Mace", 23544, { {1, 200}, {89, 45} }}, -- 12 attack 2h health
    {"Druid Wand", 26445, { {12, 15}, {90, 45} }}, -- 6 attack 1h elemental damage
    {"Skull Staff", 26590, { {18, 10}, {90, 45} }}, -- 12 attack 2h spell damage
    {"Lotus Knife", 26654, { {55, 12}, {91, 45} }}, -- 6 attack 1h attack speed
    {"Iron Bow", 25522, { {80, 50}, {91, 45} }}, -- 12 attack 2h Health Gain on Kill
  },

  ------------------------ Nowy Loot Pool
  [23] = {

    -- Start items
--    {"Moonlight Wand", 2186, { {18, 15}, {90, 45} }}, -- Spell Damage 1h magic damage 23
--    {"Magic Staff",26462, { {18, 15}, {90, 45} }}, -- 2h spell damage magic damage 23
--    {"Medusa Sword", 26433, { {19, 30}, {89, 45} }}, -- 1h BASIC Melee Damage 23
--    {"Medusa Axe", 26534, { {19, 30}, {89, 45} }}, -- 2h Basic Damage Melee Damage 23
--    {"Curved Knife", 38032, { {19, 30}, {91, 45} }}, -- 1h basic damage 23
--    {"Black Bow", 26502, { {19, 30}, {91, 45} }}, -- 2h Basic Damage Distance Damage  23
--    {"Energy War Club", 7882, { {59, 15}, {89, 45} }}, -- 1h Lighting Damage melee 47
--    {"Energy War Axe", 7878, { {59, 15}, {89, 45} }}, -- 2h Lighting Damage melee 47
--    {"Demonic Club", 7431, { {21, 5}, {1, 200}, {89, 45} }}, -- 2h Bledd Chance, HP melee 42
--    {"Bloody Chopper", 23547, { {11, 8}, {21, 3}, {89, 45} }}, -- 2h Physical Damage, bleed chance melee 42
--    {"Quick Knife", 36676, { {5, 10}, {91, 45} }}, -- DEX distane damage 42
--    {"Blacked Club", 22413, { {4, 10}, {89, 45} }}, -- STR, Melee Damage 2mac 30
--    {"Red Wood Staff", 36248, { {47, 10}, {90, 45} }}, -- dot damage 55
--    {"Cobra Wand", 31589, { {47, 10}, {90, 45} }}, -- dot damage 55

    {"Frosty Bow", 35765, { {58, 60}, {91, 45} }}, -- Ranged Ice 2h
    {"Frosty Knife", 38705, { {58, 60}, {91, 45} }}, -- Ranged Ice 1h

    {"Thunder Sword", 35786, { {59, 60}, {89, 45} }}, -- 1h Lightning Damage Melee
    {"Thunder Blade", 7407, { {59, 60}, {89, 45} }}, -- 2h Lightning Damage Melee

    {"Curse Wand", 26538, { {61, 60}, {90, 45} }}, -- Death Damage 1h magic damage 23 -- Nie ma buildu pod to
    {"Skeletar Staff",26604, { {61, 60}, {90, 45} }}, -- 2h death damage magic damage 28 -- Nie ma buildu pod to
    {"Light Wand", 7410, { {62, 60}, {90, 45} }}, -- 1h Holy damage
    {"Holy Staff", 35798, { {62, 60}, {90, 45} }}, -- 2h holy damage magic damage

    {"Fire Axe", 2432, { {57, 60}, {89, 45} }}, -- 1h Fire Damage Melee Damage 23 -- Fire Knight
    {"Flame Chooper", 35693, { {57, 60}, {89, 45} }}, -- 2h Fire Damage Melee Damage 23 -- Fire Knight

    {"Cursed Crossbow", 25523, { {61, 60}, {91, 45} }}, -- Death Damage 2h ranged damage 23 -- Shadow Death
    {"Cursed Knife", 2376, { {61, 60}, {91, 45} }}, -- Death Damage Distance Damage 1hand 30 -- Shadow Death

    {"Sky Knife", 38034, { {59, 60}, {91, 45} }}, -- 1h Lighting Damage distance 47 -- Archer lightning
    {"Sky Bow", 36056, { {59, 60}, {91, 45} }}, -- 2h Lighting Damage distance 47 -- Archer lightning

    {"Toxic Knife", 37925, { {60, 60}, {91, 45} }}, -- 1h Lighting Damage distance 47 -- Archer Poison
    {"Toxic Crossbow", 26782, { {60, 60}, {91, 45} }}, -- 2h Lighting Damage distance 47 -- Archer Poison

    {"Icy Maul", 7776, { {58, 60}, {89, 45} }}, -- 1h melee Ice damage 42 - Paladin ICE
    {"Icy Headchopper", 7771, { {58, 60}, {89, 45} }}, -- 2h melee Ice Damage 47 - Paladin ICE

    {"Black Knight Axe", 7433, { {11, 60}, {89, 45} }}, -- 1h Physical Damage Melee Damage 33
    {"Slayer Blade", 7403, { {11, 60}, {89, 45} }}, -- 2h Physical Damage Melee Damage 28

    {"Terra Wand", 2181, { {60, 60}, {90, 45} }}, -- 1h earth damage 30
    {"Earth Staff", 26607, { {60, 60}, {90, 45} }}, -- 2h earth damage 42

    {"Dragonic Wand", 8921, { {57, 60}, {90, 45} }}, -- 1h Fire Damage 1hand 30
    {"Flaming Staff", 37923, { {57, 60}, {90, 45} }}, -- 2h Fire Damage 42

    {"Cosmic Wand", 2189, { {59, 60}, {90, 45} }}, -- 1h Lighting damage 39
    {"Thunder Staff", 36008, { {59, 60}, {90, 45} }}, -- 2h lighting damage magic damage 39

    {"Chill Wand", 26551, { {58, 60}, {90, 45} }}, -- 1h Ice damage 42
    {"Frozen Staff", 37821, { {58, 60}, {90, 45} }}, -- 2h Ice Damage 47

    {"Saint Hammer", 2444, { {62, 60}, {89, 45} }}, -- 2h Holy damage melee 2hand
    {"Blessed Sword", 22402, { {62, 60}, {89, 45} }}, -- 1h Holy damage melee 1hand

    {"Sharp Knife", 36678, { {11, 60}, {91, 45} }}, -- 1h Physical Damage Distance Damage 33
    {"Heavy Crossbow", 8853, { {11, 60}, {91, 45} }}, -- 2h Physical Damage 33

    {"Barbed Club", 35777, { {49, 60}, {89, 45} }}, -- counterattack Melee Damage 23

    {"Royal Wand", 26468, { {29, 3}, {90, 45} }}, -- Critical Chance, Critical Damage 60
    {"Royal Staff", 18390, { {29, 3}, {90, 45} }}, -- Critical Chance, Critical Damage 60

    {"Primal Wand", 18411, { {29, 3}, {90, 45} }}, -- 1h Critical chance magic 23
    {"Primal Staff", 35778, { {29, 3}, {90, 45} }}, -- 2h Critical Chance magic 42

    {"Quick Wand", 37966, { {55, 12}, {90, 45} }}, -- 1h Attack Speed magic 23
    {"Quick Staff", 37965, { {55, 12}, {90, 45} }}, -- 2h Attack Speed magic 42

    {"Blow Gloves", 5875, { {29, 3} }}, -- Critical Chance GLOVES
    {"Agility Necklace", 26833, { {55, 12} }}, -- Attack Speed AMULET
    {"Mana Ring", 2166, { {24, 5} }}, -- mana regeneration  RING

    {"Recovery Necklace", 36114, { {74, 10} }}, -- health regeneration percent
    {"Barrier Necklace", 27053, { {73, 10} }}, -- energy shield regeneration percent
    {"Time Ring", 13825, { {27, 8} }}, -- movements speed  RING

    {"Full Plate Helmet", 26724, { {1, 250}, }}, -- life
    {"Full Plate Armor", 26725, { {1, 250}, }}, -- life
    {"Full Plate Legs", 26726, { {1, 250}, }}, -- life
    {"Full Plate Boots", 26727, { {1, 250}, {27,15} }}, -- life
    {"Full Plate Shield", 26827, { {1, 350}, {8,20}, {96, 45} }}, -- life
    {"Light Headband", 7901, { {71, 400} }}, -- energy shield
    {"Light Cape", 7898, { {71, 400} }}, -- energy shield
    {"Light Legs", 7895, { {71, 400} }}, -- energy shield
    {"Light Boots", 7893, { {71, 400}, {27, 15} }}, -- energy shield
    {"Light Aegis", 26747, { {71, 550}, {8,20}, {96, 45} }}, -- energy shield
    {"Spiked Helmet", 35769, { {1, 150}, {49, 25} }}, -- Counterattack
    {"Spiked Armor", 35770, { {1, 150}, {49, 25} }}, -- Counterattack
    {"Spiked Legs", 35771, { {1, 150}, {49, 25} }}, -- Counterattack
    {"Spiked Boots", 35772, { {1, 150}, {49, 25}, {27,15} }}, -- Counterattack
    {"Spiked Shield", 35773, { {1, 210}, {49, 70}, {8,20}, {96, 45} }}, -- Counterattack melee damage

    {"Dragon Plate Helmet", 35698, { {53, 50}, {1, 150} }}, -- armor life
    {"Dragon Plate Armor", 35699, { {53, 50}, {1, 150} }}, -- armor life
    {"Dragon Plate Legs", 35700, { {53, 50}, {1, 150} }}, -- armor life
    {"Dragon Plate Boots", 35701, { {53, 50}, {1, 150}, {27,15} }}, -- armor life
    {"Dragon Plate Shield", 35702, { {53, 75}, {1, 210}, {8,20}, {96, 45} }}, -- Armor life shield

  },
  [28] = {
    {"Refreshing Ring", 37075, { {56, 5} }}, -- cooldown reduction RING

    {"Force Gloves", 37772, { {11, 30} }}, -- Physical Damage GLOVES
    {"Lion Amulet", 34493, { {11, 30} }}, -- Physical Damage AMULET

    {"Sorcery Gloves", 37790, { {12, 30} }}, -- Elemental Damage GLOVES
    {"Elemental Amulet", 35484, { {12, 30} }}, -- Elemental Damage AMULET

    {"Duality Amulet", 37090, { {196, 30} }}, -- duality damage AMULET
    {"Duality Gloves", 37773, { {196, 30} }}, -- duality damage GLOVES

  },
  [30] = {
    {"Heavy Ring", 26832, { {4, 12} }}, -- Strenght  RING
    {"Wisdom Ring", 26965, { {3, 12} }}, -- Intelligence RING
    {"Dexterity Ring", 7967, { {5, 12} }}, -- Dexterity RING
    {"Ailment Ring", 38219, { {210, 10} }}, -- Ailment RING

    {"Lifesteal Gloves", 37799, { {55, 12} }}, -- attack speed
    {"Energysteal Gloves", 37804, { {210, 10} }}, -- aliment chance

    {"Energy Amulet", 10220, { {75, 10} }}, -- mana regen percent AMULET

    {"Crude Mace", 22410, { {55, 12}, {89, 45} }}, -- 1h Attack Speed Melee Damage 30
    {"Num Bow", 34485, { {55, 12}, {91, 45} }}, -- 2h Attack Speed Distance Damage 30
    {"Cheetah Knife", 36677, { {55, 12}, {91, 45} }}, -- 1h attack speed distane damage 42
    {"Thaian Blade", 7391, { {55, 12}, {89, 45} }}, -- 2h Attack speed melee 47

  },
  --- Tier 2 Fortress 33, Drakens 36, Orclops 39
  [33] = {
    {"Ruby Ring", 36113, { {1, 300} }}, -- Health RING
    {"Sapphire Ring", 2123, { {2, 300} }}, -- Mana RING
    {"Energy Ring", 38225, { {71, 400} }}, -- ENERGY RING
  },
  [36] = {
    {"Duality Knife", 36237, { {196, 60}, {91, 45} }}, -- duality damage
    {"Duality Mace", 37897, { {196, 60}, {89, 45} }}, -- duality damage

    {"Black Knife", 36675, { {29, 3}, {91, 45} }}, -- 1h Critical chance 23
    {"Ruby Bow", 26536, { {29, 3}, {91, 45} }}, -- 2h Critical Chance distance 42
  },
  [39] = {
    {"Samurai Helmet", 26409, { {9, 5} }}, -- dodge
    {"Samurai Armor", 26410, { {9, 5} }}, -- dodge
    {"Samurai Legs", 26411, { {9, 5} }}, -- dodge
    {"Samurai Boots", 26412, { {9, 5}, {27, 15} }}, -- dodge
    {"Samurai Shield", 26751, { {9, 8}, {8,20}, {96, 45} }}, -- dodge

    {"Animage Hood", 36121, {{35, 5} }}, -- spell avoid
    {"Animage Armor", 36122, {{35, 5} }}, -- spell avoid
    {"Animage Legs", 36123, {{35, 5} }}, -- spell avoid
    {"Animage Boots", 36124, {{35, 5}, {27, 15} }}, -- spell avoid
    {"Animage Shield", 36127, {{35, 8}, {8,20}, {96, 45} }}, -- spell avoid
  },

  --- Tier 3 Dung 42lvl boss 45
  [47] = {
    {"Wisdom Gloves", 37787, { {3, 15} }}, -- Intelligence GLOVES
    {"Black Gloves", 36403, { {4, 15} }}, -- Strength GLOVES
    {"Ranged Gloves", 37796, { {5, 15} }}, -- Dexterity GLOVES
  },
  [51] = {
    {"Guardian Helmet", 26476, { {1, 150}, {2, 150} }}, -- health mana
    {"Guardian Plate", 26477, { {1, 150}, {2, 150} }}, -- health mana
    {"Guardian Legs", 26478, { {1, 150}, {2, 150} }}, -- health mana
    {"Guardian Boots", 26479, { {1, 150}, {2, 150}, {27,15} }}, -- health mana
    {"Guardian Shield", 26480, { {1, 210}, {2, 150}, {8,20}, {96, 45} }}, -- health mana

    {"Medusa Helmet", 26427, { {1, 150}, {71, 200} }}, -- Health Energy SHield
    {"Medusa Armor", 26428, { {1, 150}, {71, 200} }}, -- Health Energy SHield
    {"Medusa Legs", 26429, { {1, 150},{71, 200} }}, -- Health Energy SHield
    {"Medusa Boots", 26430, { {1, 150},{71, 200}, {27,15} }}, -- Health Energy SHield
    {"Medusa Shield", 26431, { {1, 210}, {71, 260}, {8,20}, {96, 45} }}, -- Health Energy SHield

    {"Galaxy Helmet", 26404, { {71, 200}, {2, 150} }}, -- energy shield mana
    {"Galaxy Plate", 26405, { {71, 200}, {2, 150} }}, -- energy shield mana
    {"Galaxy Legs", 26406, { {71, 200}, {2, 150} }}, -- energy shield mana
    {"Galaxy Boots", 26407, { {71, 200}, {2, 150}, {27,15} }}, -- energy shield mana
    {"Galaxy Shield", 26408, { {71, 260}, {2, 210}, {8, 20}, {96, 45} }}, -- energy shield mana
  },

  --- Tier 4 55, 60, 65
  [60] = {
    {"Cobra Amulet", 26977, { {6, 13} }}, -- All Attributes AMULET
    {"Cheetah Hood", 26386, { {9, 2}, {35, 2} }}, -- dodge spell avoid
    {"Cheetah Coat", 26387, { {9, 2}, {35, 2} }}, -- dodge spell avoid
    {"Cheetah Legs", 26388, { {9, 2}, {35, 2} }}, -- dodge spell avoid
    {"Cheetah Feet", 26389, { {9, 2}, {35, 2}, {27,15} }}, -- dodge spell avoid
    {"Cheetah Shield", 26391, { {9, 3}, {35, 3}, {8,20}, {96, 45} }}, -- dodge spell avoid
    {"Steel Flail", 26614, {{29, 3}, {89, 45} }}, -- Critical Chance, Critical Damage 60
    {"Dragon Slayer Blade", 7402, { {29, 3}, {89, 45} }}, -- Critical Chance, Critical Damage 60
  },
  [70] = {
    {"Black Helmet", 26495, { {1, 150}, {11, 10} }}, -- Health Physical Damage
    {"Black Armor", 26496, { {1, 150},{11, 10} }}, -- Health Physical Damage
    {"Black Legs", 26497, { {1, 150}, {11, 10} }}, -- Health Physical Damage
    {"Black Boots", 26498, { {1, 150}, {11, 10}, {27, 15} }}, -- Health Physical Damage
    {"Black Shield", 26499, { {1, 210}, {11, 60}, {8,20}, {96, 45} }}, -- Health Physical Damage

    {"Barrier Helmet", 35943, { {1, 150},{12, 10} }}, -- Health Elemental Damage
    {"Barrier Cape", 35944, { {1, 150},{12, 10} }}, -- Health Elemental Damage
    {"Barrier Legs", 35947, { {1, 150},{12, 10} }}, -- Health Elemental Damage
    {"Barrier Boots", 35948, { {1, 150},{12, 10}, {27,15} }}, -- Health Elemental Damage
    {"Barrier Spellbook", 36247, { {1, 210}, {12, 60}, {8,20}, {96, 45} }}, -- Health Elemental Damage

    {"Beholder Helmet", 26471, { {1, 150}, {196, 10} }}, -- Health Duality Damage
    {"Beholder Plate", 26472, { {1, 150}, {196, 10} }}, -- Health Duality Damage
    {"Beholder Legs", 26473, { {1, 150}, {196, 10} }}, -- Health Duality Damage
    {"Beholder Boots", 26474, { {1, 150}, {196, 10}, {27,15} }}, -- Health Duality Damage
    {"Beholder Shield", 26475, { {1, 210}, {196, 60}, {8,20}, {96, 45} }}, -- Health Duality Damage

    {"Deep Helmet", 26414, { {71, 200}, {11, 10} }}, -- energy shield physical damage
    {"Deep Plate", 26415, { {71, 200}, {11, 10} }}, -- energy shield physical damage
    {"Deep Legs", 26416, { {71, 200}, {11, 10} }}, -- energy shield physical damage
    {"Deep Boots", 26417, { {71, 200}, {11, 10}, {27,15} }}, -- energy shield physical damage
    {"Deep Shield", 26413, { {71, 260}, {11, 60}, {8,20}, {96, 45} }}, -- energy shield physical damage

    {"Glacier Cap", 7902, { {71, 200}, {12, 10} }}, -- energy shield elemental damage
    {"Glacier Robe", 7897, { {71, 200}, {12, 10} }}, -- energy shield elemental damage
    {"Glacier Legs", 7896, { {71, 200}, {12, 10} }}, -- energy shield elemental damage
    {"Glacier Boots", 7892, { {71, 200}, {12, 10}, {27,15} }}, -- energy shield elemental damage
    {"Glacier Shield", 26746, { {71, 260}, {12, 60}, {8,20}, {96, 45} }}, -- energy shield elemental damage

    {"Energy Helmet", 26464, { {71, 200}, {196, 10} }}, -- energy shield duality damage
    {"Energy Cape", 26465, { {71, 200}, {196, 10} }}, -- energy shield duality damage
    {"Energy Legs", 26466, { {71, 200}, {196, 10} }}, -- energy shield duality damage
    {"Energy Boots", 26467, { {71, 200}, {196, 10}, {27,15} }}, -- energy shield duality damage
    {"Energy Shield", 35949, { {71, 260}, {196, 60}, {8,20}, {96, 45} }}, -- energy shield duality damage
  },

}