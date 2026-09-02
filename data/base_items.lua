BASE_ITEMS = {
  [1] = {
    {"Bronze Axe", 26618, { 
      {6, 10}, -- ID 6 (Physical Attack): +10
    }, 0, 10000}, -- Rarity ID: 0 (Normal), Chance: 10000 (10%)
    {"Druid Rod", 26445, { 
      {7, 10}, -- ID 7 (Magic Attack): +10
    }, 0, 10000},
    {"Amplifying Tome", 1955, { 
      {7, 10}, -- ID 7 (Magic Attack): +10
    }, 0, 10000},
    {"Doran's Blade", 2406, { 
      {6, 10}, -- ID 6 (Physical Attack): +10
      {1, 80}, -- ID 1 (Health): +80
      {17, 3}, -- ID 17 (Physical Lifesteal): +3%
    }, 0, 10000},
    {"Doran's Ring", 2124, { 
      {7, 18}, -- ID 7 (Magic Attack): +18
      {1, 90}, -- ID 1 (Health): +90
      {5, 5},  -- ID 5 (Mana Regeneration): +5
    }, 0, 10000},
    {"Doran's Shield", 2512, { 
      {1, 110}, -- ID 1 (Health): +110
      {4, 7},   -- ID 4 (Health Regeneration): +7
    }, 0, 10000},
    {"Doran's Wand", 2186, { 
      {7, 10}, -- ID 7 (Magic Attack): +10
      {1, 50}, -- ID 1 (Health): +50
      {18, 3}, -- ID 18 (Magic Lifesteal): +3%
    }, 0, 10000},
  },
  [11] = {
    {"Bronze Armor", 26393, { 
      {8, 10}, -- Physical Defense
    }, 0, 10000},
    {"Druid Cape", 26442, { 
      {9, 10}, -- Magic Defense
    }, 0, 10000},
    {"Pickaxe", 4874, { 
      {6, 15}, -- Physical Attack
    }, 0, 10000},
  },
  [21] = {
    {"Elven Plate", 26491, { 
      {1, 150}, -- Health
    }, 0, 10000},
    {"Blue Robe", 2656, { 
      {2, 250}, -- Mana
    }, 0, 10000},
    {"Icy Wand", 2184, { 
      {7, 20}, -- Magic Attack
    }, 1, 10000}, -- Common Rarity (1), 20 Magic Attack
    {"Blasting Wand", 2189, { 
      {7, 30}, -- Magic Attack
    }, 1, 10000},
  },
  [31] = {
    {"Boots", 26438, { 
      {21, 15}, -- Movement Speed
    }, 0, 10000},

    {"Recovery Ring", 38860, { 
      {4, 3}, -- Health Regeneration
    }, 0, 10000},

    {"Energy Ring", 38786, { 
      {5, 3}, -- Mana Regeneration
    }, 0, 10000},

    {"Negatron Cloak", 8870, { 
      {9, 25}, -- Magic Defense
    }, 1, 10000},
    {"B. F. Sword", 2393, { 
      {6, 40}, -- Physical Attack
    }, 3, 10000},
    {"Cloak of Agility", 2660, { 
      {12, 15}, -- Critical Chance
    }, 1, 10000},
  },
  [41] = {
    {"Monocle", 7900, { 
      {16, 10}, -- Cooldown Reduction
    }, 0, 10000},
    {"Black Bow", 25522, { 
      {11, 10}, -- Attack Speed
    }, 0, 10000},

    {"Dagger", 36676, { 
      {12, 8}, -- Critical Chance
    }, 0, 10000},

    {"Kindlegem", 38641, { 
      {1, 200}, -- Health
      {16, 10}, -- Cooldown Reduction
    }, 1, 10000},

    {"Lifestealer Ring", 26832, { 
      {6, 8},
      {17, 8}, -- Physical Lifesteal
    }, 0, 10000},
    {"Magicvamp Amulet", 26833, { 
      {7, 8},
      {18, 8}, -- Magic Lifesteal
    }, 0, 10000},
    {"Seeker's Armguard", 37790, {
      {7, 30},
      {8, 20},
    }, 1, 10000},
    {"Verdant Barrier", 2180, {
      {7, 30},
      {9, 20},
    }, 1, 10000},
    {"Oblivion Orb", 2176, {
      {7, 25},
      {48, 1},
    }, 1, 10000},
    {"Executioner's Calling", 7404, {
      {6, 15},
      {47, 1},
    }, 1, 10000},
    {"Last Whisper", 8856, {
      {6, 20},
      {14, 18},
    }, 2, 10000},
    {"Bami's Cinder", 2156, {
      {1, 200},
      {16, 5},
      {40, 1},
    }, 1, 10000},
    {"Bramble Vest", 2483, {
      {8, 30},
      {39, 1},
    }, 1, 10000},
    {"Chain Vest", 2464, {
      {8, 40},
    }, 1, 10000},
    {"Spectre's Cowl", 8871, {
      {1, 250},
      {9, 25},
      {4, 5},
    }, 1, 10000},
    {"Sheen", 7418, {
      {16, 10},
      {34, 1},
    }, 1, 10000},
    {"Phage", 7415, {
      {6, 15},
      {1, 200},
    }, 1, 10000},
    {"Hearthbound Axe", 7411, {
      {6, 20},
      {11, 12},
      {35, 1},
    }, 1, 10000},
    {"Recurve Bow", 8855, {
      {11, 15},
      {36, 1},
    }, 1, 10000},
    {"Fiendish Codex", 8902, {
      {7, 25},
      {16, 10},
    }, 1, 10000},
    {"Vampiric Scepter", 2424, {
      {6, 15},
      {17, 8},
    }, 1, 10000},
    {"Giant's Belt", 2487, {
      {1, 350},
    }, 1, 10000},
    {"Winged Moonplate", 2486, {
      {1, 150},
      {10, 4},
    }, 1, 10000},
    {"Crystalline Bracer", 2469, {
      {1, 200},
      {4, 5},
    }, 1, 10000},
    {"Dragon Wand", 2191, {
      {7, 20},
    }, 1, 10000},
    {"Blighting Jewel", 2178, {
      {7, 20},
      {15, 15},
    }, 1, 10000},
    {"Eclipse Wand", 8920, {
      {7, 45},
    }, 2, 10000},
  },
}