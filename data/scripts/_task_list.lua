GRIZZLY_TASKS = {
  {
    killsRequired = 50,	-- 65001 1511
    level = 1,
    raceName = "Wolfs",
    rewards = {{type = "exp", values = 200},
    {type = "money", values = 2000},
    {type = "spellrune", count = 2},
  },
    monsters = {"wolf"},
  },

  {
    killsRequired = 100,		-- 65002 1523
    level = 3,
    raceName = "Minotaurs",
    rewards = {{type = "exp", values = 2000},
	  {type = "money", values = 4000},
    {type = "item", values = {8303, 5}},  -- Orb of Enchantment
    {type = "item", values = {37114, 5}}  -- Orb of Removal
  },
    monsters = {"minotaur", "minotaur guard", "minotaur archer", "minotaur mage"},
  },

  {
    killsRequired = 120,		-- 65003 1525
    level = 8,
    raceName = "Cyclops",
    rewards = {{type = "exp", values = 4000},
    {type = "money", values = 6000},
    {type = "spellrune", count = 2},
    {type = "item", values = {8303, 5}},  -- Orb of Enchantment
    {type = "item", values = {37114, 5}}  -- Orb of Removal
  },
    monsters = {"cyclops", "cyclops drone", "cyclops smith"},
  },

  {
    killsRequired = 150,		-- 65004 1537
    level = 12,
    raceName = "Dragons",
    rewards = {{type = "exp", values = 7500},
	  {type = "money", values = 10000},
    {type = "supportrune", count = 3},
    {type = "item", values = {8303, 10}},  -- Orb of Enchantment
    {type = "item", values = {8302, 10}}   -- Orb of Honored
  },
    monsters = {"dragon", "dragon hatchling", "dragon lord", "dragon lord hatchling"},
  },
  
  {
    killsRequired = 200,		-- 65005 1537
    level = 15,
    raceName = "Heros",
    rewards = {{type = "exp", values = 22500},
	  {type = "money", values = 15000},
    {type = "item", values = {37115, 10}},  -- Orb of Refinement
    {type = "item", values = {8302, 10}}    -- Orb of Honored
  },
    monsters = {"hero", "dark monk", "black knight"},
	
  },

  {
    killsRequired = 300,		-- 65006 1537
    level = 19,
    raceName = "Demons",
    -- repeatable = true,
    rewards = {{type = "exp", values = 37500},
	  {type = "money", values = 30000},
    {type = "spellrune", count = 3},
    {type = "item", values = {8302, 10}},    -- Orb of Honored
    {type = "item", values = {37116, 10}}    -- Orb of Shaping
  },
    monsters = {"demon", "destroyer", "hellfire fighter", "hellhound"},
  },
  {
    killsRequired = 20,			-- 65007
    level = 20,
    raceName = "Lava Golem",
  --  repeatable = true,
    rewards = {{type = "exp", values = 37500},
    {type = "storage", values = {PlayerStorage.promotionBoss1, 1}},
    {type = "questEnd", values = 1},
    {type = "questStart", values = 2},
	  {type = "money", values = 50000},
    {type = "item", values = {8302, 5}},    -- Orb of Honored
    {type = "item", values = {8303, 10}},    -- Orb of Enchantment
    {type = "item", values = {37114, 20}}    -- Orb of Removal
  },
    monsters = {"lava golem"},
  },
  {
    killsRequired = 300,		-- 65008 1571
    level = 26,
    raceName = "Fungus",
    rewards = {{type = "exp", values = 60000},
    {type = "money", values = 35000},
    {type = "item", values = {37114, 15}}   -- Orb of Removal
  },
    monsters = { "hideous fungus", "humongous fungus", "swampling"},
  },
  {
    killsRequired = 300,		-- 65009
    level = 28,
    raceName = "Spectres",
    rewards = {{type = "exp", values = 67500},
    {type = "money", values = 40000},
	  {type = "item", values = {8302, 10}}   -- Orb of Honored
  },
  monsters = { "bloody spectre", "dark spectre", "lost death"},
  },
  {
    killsRequired = 25,			-- 65010
    level = 29,
    raceName = "Netherbane",
    --repeatable = true,
    rewards = {{type = "exp", values = 75000},
	  {type = "money", values = 60000},
    {type = "item", values = {37109, 5}},   -- Orb of Scouring
    {type = "item", values = {37119, 10}}    -- Orb of Arcana
  },
    monsters = {"netherbane"},
  },
  {
    killsRequired = 300,			-- 65011
    level = 30,
    raceName = "Falcons",
    rewards = {{type = "exp", values = 82500},
    {type = "money", values = 50000},
    {type = "item", values = {8302, 10}},    -- Orb of Honored
    {type = "item", values = {37114, 10}}    -- Orb of Removal

  },
  monsters = { "falcon paladin", "falcon knight", "falcon wizard"},
  },
  {
    killsRequired = 400,		-- 65012
    level = 33,
    raceName = "Fortress",
    rewards = {{type = "exp", values = 100000},
    {type = "money", values = 60000},
    {type = "item", values = {37109, 5}},   -- Orb of Scouring

  },
  monsters = { "minotaur hunter", "moohtant", "worm priestess"},
  },
  {
    killsRequired = 400,		-- 65013
    level = 36,
    raceName = "Drakens",
    rewards = {{type = "exp", values = 115000},
    {type = "money", values = 70000},
    {type = "item", values = {37119, 5}},   -- Orb of Arcana

  },
  monsters = { "draken elite", "draken spellweaver", "draken warmaster"},
  },
  {
    killsRequired = 30,			-- 65014
    level = 38,
    raceName = "Ironhorn",
    --repeatable = true,
    rewards = {{type = "exp", values = 115000},
	  {type = "money", values = 80000},
	{type = "item", values = {8302, 15}},    -- Orb of Honored
	{type = "item", values = {37114, 15}}	 -- Orb of Removal
  },
    monsters = {"ironhorn"},
  },
  {
    killsRequired = 400,			-- 65015
    level = 39,
    raceName = "Orclops",
    rewards = {{type = "exp", values = 150000},
    {type = "money", values = 90000},
    {type = "item", values = {37114, 10}},    -- Orb of Removal
    {type = "item", values = {37115, 10}},  -- Orb of Refinement
    {type = "item", values = {37116, 10}}    -- Orb of Shaping

  },
  monsters = { "orclops doomhauler", "orclops mage", "orclops ravager"},
  },
  {
    killsRequired = 30,			-- 65016
    level = 40,
    raceName = "Rotburrow",
    --repeatable = true,
    rewards = {{type = "exp", values = 150000},
    {type = "storage", values = {PlayerStorage.promotionBoss2, 1}},
    {type = "questEnd", values = 3},
    {type = "questStart", values = 4},
    {type = "money", values = 120000},
    {type = "item", values = {8302, 10}},    -- Orb of Honored
    {type = "item", values = {8303, 20}},    -- Orb of Enchantment
    {type = "item", values = {37114, 30}}    -- Orb of Removal

  },
    monsters = {"rotburrow"},
  },
  {
    killsRequired = 500,		-- 65017
    level = 42,
    raceName = "Library",
    rewards = {{type = "exp", values = 200000},
    {type = "money", values = 100000},
    {type = "item", values = {37118, 5}},    -- Orb of Chance

  },
  monsters = { "biting book", "brain squid", "knowledge elemental"},
  },
  {
    killsRequired = 500,		-- 65018
    level = 47,
    raceName = "Forgottens",
    rewards = {{type = "exp", values = 225000},
    {type = "money", values = 100000},
    {type = "item", values = {37121, 5}},    -- Orb of Void

  },
  monsters = { "forgotten archer", "forgotten knight", "forgotten wizard"},
  },
  {
    killsRequired = 40,			-- 65019
    level = 50,
    raceName = "Sandfang",
    --repeatable = true,
    rewards = {{type = "exp", values = 250000},
    {type = "storage", values = {PlayerStorage.promotionBoss6, 1}},
    {type = "questEnd", values = 6},
    {type = "questStart", values = 7},
	  {type = "money", values = 150000},
    {type = "item", values = {37118, 10}},   -- Orb of Chance
    {type = "item", values = {37109, 10}},   -- Orb of Scouring
    {type = "item", values = {37119, 15}}    -- Orb of Arcana
  },
    monsters = {"sandfang"},
  },
  {
    killsRequired = 500,		-- 65020
    level = 51,
    raceName = "Burnings",
    rewards = {{type = "exp", values = 300000},
    {type = "money", values = 150000},
    {type = "item", values = {37118, 5}},    -- Orb of Chance

  },
  monsters = { "burning archer", "burning knight", "burning wizard"},
  },
  {
    killsRequired = 500,		-- 65021
    level = 55,
    raceName = "Undeads",
    rewards = {{type = "exp", values = 350000},
    {type = "money", values = 170000},
    {type = "item", values = {37121, 5}},    -- Orb of Void

  },
  monsters = { "death lich", "undead hunter", "undead warrior"},
  },
  {
    killsRequired = 40,			-- 65022
    level = 58,
    raceName = "Hellflayer",
    --repeatable = true,
    rewards = {{type = "exp", values = 400000},
	  {type = "money", values = 250000},
    {type = "item", values = {37121, 10}},   -- Orb of Void
    {type = "item", values = {37118, 15}}    -- Orb of Chance
  },
    monsters = {"hellflayer"},
  },
  {
    killsRequired = 500,			-- 65023
    level = 60,
    raceName = "Brotherhoods",
    rewards = {{type = "exp", values = 550000},
    {type = "money", values = 200000},
    {type = "item", values = {37118, 10}},    -- Orb of Chance

  },
  monsters = { "brotherhood lady", "brotherhood reaper", "brotherhood wizard"},
  },
  {
    killsRequired = 500,			-- 65024
    level = 65,
    raceName = "Prison",
    rewards = {{type = "exp", values = 750000},
    {type = "money", values = 200000},
    {type = "item", values = {37118, 15}},    -- Orb of Chance
    {type = "item", values = {37109, 15}},   -- Orb of Scouring
    {type = "item", values = {37119, 15}}    -- Orb of Arcana

  },
  monsters = { "bloody mage", "prisoned sinner", "soul hunter"},
  },
  {
    killsRequired = 50,			-- 65025
    level = 67,
    raceName = "Grimdelver",
    rewards = {{type = "exp", values = 1500000},
    {type = "storage", values = {PlayerStorage.promotionBoss3, 1}},
    {type = "questEnd", values = 8},
    {type = "questStart", values = 9},
    {type = "money", values = 300000},
    {type = "item", values = {37118, 10}},   -- Orb of Chance
    {type = "item", values = {37121, 10}}    -- Orb of Void
  },
    monsters = {"grimdelver"},
  },
  {
    killsRequired = 500,			-- 65026
    level = 70,
    raceName = "Underworld",
    rewards = {{type = "exp", values = 1200000},
    {type = "money", values = 300000},
    {type = "item", values = {37109, 10}},   -- Orb of Scouring
    {type = "item", values = {37119, 10}}    -- Orb of Arcana

  },
  monsters = { "choking fear", "guzzlemaw", "retching horror"},
  },
  {
    killsRequired = 50,				-- 65027
    level = 72,
    raceName = "Riftshade",
    rewards = {{type = "exp", values = 1500000},
    {type = "money", values = 400000},
	{type = "item", values = {37118, 15}},   -- Orb of Chance
  },
    monsters = {"riftshade"},
  },
  {
    killsRequired = 500,			-- 65028
    level = 75,
    raceName = "Rott Island",
    rewards = {{type = "exp", values = 1500000},
    {type = "money", values = 350000},
    {type = "item", values = {37118, 10}},   -- Orb of Chance
    {type = "item", values = {37121, 10}}    -- Orb of Void

  },
  monsters = { "cloak of terror", "infernal demon", "many faces"},
  },
  {
    killsRequired = 500,				-- 65029
    level = 80,
    raceName = "Toxic Cave",
    rewards = {{type = "exp", values = 2000000},
    {type = "money", values = 400000},
    {type = "item", values = {37118, 10}},   -- Orb of Chance

  },
  monsters = { "ogork", "ozizug", "zuzgil"},
  },
  {
    killsRequired = 50,						-- 65030
    level = 82,
    raceName = "Yeti",
    rewards = {{type = "exp", values = 2500000},
    {type = "storage", values = {PlayerStorage.promotionBoss4, 1}},
    {type = "questEnd", values = 10},
    {type = "questStart", values = 11},
    {type = "money", values = 500000},
    {type = "item", values = {37116, 20}},   -- Orb of Shaping
    {type = "item", values = {37118, 20}},   -- Orb of Chance
    {type = "item", values = {37121, 20}}    -- Orb of Void
  },
    monsters = {"yeti"},
  },
  {
    killsRequired = 500,				-- 65031
    level = 85,
    raceName = "Crimson Depths",
    rewards = {{type = "exp", values = 3750000},
    {type = "money", values = 450000},
    {type = "item", values = {37118, 10}},   -- Orb of Chance
    {type = "item", values = {37117, 5}}     -- Orb of Spellwaver

  },
  monsters = { "bloodbind", "bloodstone golem", "crimson spikefiend"},
  },
  {
    killsRequired = 500,			-- 65032
    level = 90,
    raceName = "Forsaken Ruins",
    rewards = {{type = "exp", values = 7000000},
    {type = "money", values = 450000},
    {type = "item", values = {37116, 20}},  -- Orb of Shaping
    {type = "item", values = {37121, 5}}    -- Orb of Void

  },
  monsters = { "bone cleaver", "bonecaster", "skeletal marksman"},
  },
  {
    killsRequired = 500,		-- 65033
    level = 95,
    raceName = "Ethereal Stingray",
    rewards = {{type = "exp", values = 10000000},
    {type = "money", values = 500000},
    {type = "item", values = {37118, 10}},   -- Orb of Chance

  },
  monsters = { "ethereal stingray"},
  },
  {
    killsRequired = 50,			-- 65034
    level = 97,
    raceName = "Thornroot",
    rewards = {{type = "exp", values = 15000000},
    {type = "money", values = 2000000},
    {type = "storage", values = {PlayerStorage.promotionBoss5, 1}},
    {type = "questEnd", values = 13},
    {type = "questStart", values = 14},
    {type = "item", values = {37121, 20}},    -- Orb of Void
    {type = "item", values = {37118, 20}}     -- Orb of Chance
  },
    monsters = {"thornroot"},
  },
  {
    killsRequired = 500,		-- 65035
    level = 100,
    raceName = "Decayed Realm",
    rewards = {{type = "exp", values = 15000000},
    {type = "money", values = 1000000},
    {type = "item", values = {37117, 5}},     -- Orb of Spellwaver
    {type = "item", values = {37121, 10}},    -- Orb of Void
    {type = "item", values = {37118, 10}}     -- Orb of Chance

  },
  monsters = { "blighted overgrowth", "fungal ravager", "twisted rootfiend"},
  },
  
  {
    killsRequired = 500,		-- 65036
    level = 95,
    raceName = "Horned Creeper",
    rewards = {{type = "exp", values = 10000000},
    {type = "money", values = 500000},
    {type = "item", values = {37117, 5}},     -- Orb of Spellwaver

  },
  monsters = { "horned creeper"},
  },
  
  {
    killsRequired = 500,		-- 65037
    level = 95,
    raceName = "Mutated Deepmaw",
    rewards = {{type = "exp", values = 10000000},
    {type = "money", values = 500000},
    {type = "item", values = {37121, 10}},    -- Orb of Void

  },
  monsters = { "mutated deepmaw"},
  },
  
  {
    killsRequired = 1000,		-- 65038
    level = 500,
    raceName = "Toxic Constructs",
    rewards = {{type = "exp", values = 15000000},
    {type = "money", values = 1500000},

  },
  monsters = { "biohazard plaguebot", "rustdrain scrapper", "toxipump construct"},
  },
  {
    killsRequired = 1000,		-- 65039
    level = 600,
    raceName = "Abyssal Dwellers",
    rewards = {{type = "exp", values = 20000000},
    {type = "money", values = 2500000},

  },
  monsters = { "abyssal shellfiend", "abyssroot sentinel", "reefbound overseer"},
  },
  {
    killsRequired = 1000,		-- 65040
    level = 700,
    raceName = "Frozen Abyssals",
    rewards = {{type = "exp", values = 30000000},
    {type = "money", values = 3500000},

  },
  monsters = { "depthguard", "frostwind bowserpent", "glacier serpent", "trident frostguard"},
  },
  {
    killsRequired = 100,		-- 65041
    level = 800,
    raceName = "Prism Beast",
    rewards = {{type = "exp", values = 50000000},
    {type = "money", values = 5000000},
	  {type = "storage", values = {PlayerStorage.promotionBoss7, 1}},
    {type = "questEnd", values = 17},
    {type = "questStart", values = 18},

  },
  monsters = { "prism beast" },
  },

}