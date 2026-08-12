ITEM_UPGRADE_CRYSTAL = 1
ITEM_ENCHANT_CRYSTAL = 2
ITEM_ALTER_CRYSTAL = 3
ITEM_CLEAN_CRYSTAL = 4
ITEM_FORTUNE_CRYSTAL = 5
ITEM_FAITH_CRYSTAL = 6
ITEM_PERFECT_FAITH_CRYSTAL = 7
ITEM_ORB_OR_PERFECTION = 8

RARITYS = {
    NORMAL = 0,
    COMMON = 1,
    MAGIC = 2,
    RARE = 3,
    LEGENDARY = 4,
    UNIQUE = 5,
    EXALTED = 6,
    SPECIAL = 8,
}
COMMON = 1
RARE = 2
EPIC = 3
LEGENDARY = 4
HEROIC = 5
MYTHIC = 6
DIVINE = 7



US_CONFIG = {
    {
        [ITEM_UPGRADE_CRYSTAL] = 0, -- Upgrade Crystal item id -------Upgrade OLD 26555
        [ITEM_ENCHANT_CRYSTAL] = 0, -- Enchantment Crystal item id-------add atribute
        [ITEM_ALTER_CRYSTAL] = 0, -- 18415, -- Alteration Crystal item id ------remove last attribute.
        [ITEM_CLEAN_CRYSTAL] = 0, -- 18422, -- Cleansing Crystal item id------remove all attribute.
        [ITEM_FORTUNE_CRYSTAL] = 0, -- 18421, -- Fortune Crystal item id --change value of last attribute
        [ITEM_FAITH_CRYSTAL] = 0, -- 18420, -- Faith Crystal item id --change value of all attribute
        [ITEM_PERFECT_FAITH_CRYSTAL] = 26527, -- Perfect Faith Crystal item id --change value of all attribute to MAX
        [ITEM_ORB_OR_PERFECTION] = 37122 -- orb of perfection
    },

    ITEM_MIND_CRYSTAL = 0, -- 26804, -- Mind Crystal item id
    ITEM_LIMITLESS_CRYSTAL = 0, -- 18414, -- Limitless Crystal item id
    ITEM_MIRRORED_CRYSTAL = 0, -- 18419, -- Mirrored Crystal item id
    ITEM_VOID_CRYSTAL = 0, -- Void Crystal item id
    ITEM_SCROLL_IDENTIFY = 26532, -- Scrol of Identification item id
    ITEM_INFINITY = 31069,
    ITEM_UPGRADE_CATALYST = 26805, -- Upgrade Catalyst item id
    CRYSTAL_EXTRACTOR = 0, -- 26840, -- Crystal Extractor item id
    CRYSTAL_FOSSIL = 24850, -- Crystal Fossil item id
    BOOK_FRAGMENT = 21250, -- Crystal Fossil item id
    ITEM_BOOK_PA = 26803, -- Unique passive ability
    ITEM_BOOK_PA_REMOVE = 18423, -- Unique passive ability re-draw
    ITEM_BOOK_CORRUPTED = 26807,
    ITEM_SOUL_SHARD_UPGRADE = 36979, -- upgrade shard
    ITEM_SOUL_SHARD_VITALITY = 36971, -- vitality shard
    --
    IDENTIFY_UPGRADE_LEVEL = false, -- if true, roll random upgrade level when identifing an item
    IDENTIFY_UPGRADE_LEVEL_MAX = 7, -- max roll upgrade level when indefity
    IDENTIFY_QUALITY_LEVEL = false, -- if true, roll random quality level when identifing an item
    IDENTIFY_QUALITY_LEVEL_MAX = 30, -- max roll quality level when indefity
--    UPGRADE_SUCCESS_CHANCE = {[1] = 100,[2] = 100,[3] = 100,[4] = 100,[5] = 100,[6] = 100,[7] = 100,[8] = 100,[9] = 100,[10] = 100,[11] = 100,[12] = 100,[13] = 100,[14] = 100,[15] = 100,[16] = 100}, -- TEST
    UPGRADE_SUCCESS_CHANCE = {[1] = 100, [2] = 95, [3] = 90, [4] = 75, [5] = 75, [6] = 70, [7] = 65, [8] = 60, [9] = 55, [10] = 50, [11] = 45, [12] = 40, [13] = 35, [14] = 30, [15] = 100, [16] = 100}, -- official
    UPGRADE_LEVEL_DESTROY = 16, -- at which upgrade level should it break if failed, for example if = 7 then upgrading from +6 to +7-9 can destroy item on failure.
    UPGRADE_DESTROY_CHANCE = {
        [17] = 30,
        [18] = 15,
        [19] = 5
    }, -- chance for the item to break at given upgrade level
    --
    MAX_ITEM_LEVEL = 300, -- max that Item Level can be assigned to item
    MAX_UPGRADE_LEVEL = 15, -- max level that item can be upgraded to,
    --
    ATTACK_PER_ITEM_LEVEL = 10000, -- every X Item Level +ATTACK_FROM_ITEM_LEVEL attack
    ATTACK_FROM_ITEM_LEVEL = 1, -- +X bonus attack for every ATTACK_PER_ITEM_LEVEL
    DEFENSE_PER_ITEM_LEVEL = 10000, -- every X Item Level +DEFENSE_FROM_ITEM_LEVEL defense
    DEFENSE_FROM_ITEM_LEVEL = 1, -- +X bonus defense for every DEFENSE_PER_ITEM_LEVEL
    ARMOR_PER_ITEM_LEVEL = 10000, -- every X Item Level +ARMOR_FROM_ITEM_LEVEL armor
    ARMOR_FROM_ITEM_LEVEL = 1, -- +X bonus armor for every ARMOR_PER_ITEM_LEVEL
    HITCHANCE_PER_ITEM_LEVEL = 10000, -- every X Item Level +HITCHANCE_FROM_ITEM_LEVEL hit chance
    HITCHANCE_FROM_ITEM_LEVEL = 1, -- +X bonus hit chance for every HITCHANCE_PER_ITEM_LEVEL
    --
    ITEM_LEVEL_PER_ATTACK = 1, -- +1 to Item Level for every X Attack in item
    ITEM_LEVEL_PER_DEFENSE = 1, -- +1 to Item Level for every X Defense in item
    ITEM_LEVEL_PER_ARMOR = 1, -- +1 to Item Level for every X Armor in item
    ITEM_LEVEL_PER_HITchance = 100, -- +1 to Item Level for every X Hit Chance in item
    ITEM_LEVEL_PER_UPGRADE = 2, -- additional item level per upgrade level
    --
    ATTACK_PER_UPGRADE = 5, -- amount of bonus attack per upgrade level
    DEFENSE_PER_UPGRADE = 1, -- amount of bonus defense per upgrade level
    EXTRADEFENSE_PER_UPGRADE = 1, -- amount of bonus extra defense per upgrade level
    ARMOR_PER_UPGRADE = 8, -- amount of bonus armor per upgrade level
    HITCHANCE_PER_UPGRADE = 1, -- amount of bonus hit chance per upgrade level
    --
    CRYSTAL_FOSSIL_DROP_CHANCE = 20, -- 1:X chance that Crystal Fossil will drop from monster, X means that approximately every X monster will drop Crystal Fossil	-- OFFICIAL 20
    CRYSTAL_FOSSIL_DROP_LEVEL = 1, -- X monster level needed to drop Crystal Fossil
    BOOK_FRAGMENT_DROP_CHANCE = 30, -- 1:X chance that Book Fragment will drop from monster, X means that approximately every X monster will drop Book Fragment		-- OFFICIAL 30
    BOOK_FRAGMENT_DROP_LEVEL = 1, -- X monster level needed to drop Book fragment
    CRYSTAL_BREAK_CHANCE = 30, -- 1:X chance that Crystal will break when extracted from Fossil, X means that approximately every X Crystal will break 				-- OFFICIAL 10	
    UNIQUE_CHANCE = -1, -- 1:X chance that unidentified item will become Unique, X means that approximately every X unidentified item will become unique
    REQUIRE_LEVEL = false, -- block equipping items with higher Item Level than Player Level
    RARITY = {
        [COMMON] = {
            name = "Common",
            maxBonus = 1, -- max amount of bonus attributes
            chance = 100000 -- 1:X chance that item will be common (1 = 100%)	100000 = 100%
        },
        [RARE] = {
            name = "Magic",
            maxBonus = 2, -- max amount of bonus attributes
            chance = 20000 -- 20000 -- 1:X chance that item will be common (1 = 100%)	-- 5 -- 50%
        },
        [EPIC] = {
            name = "Rare",
            maxBonus = 3, -- max amount of bonus attributes
            chance = 10000 -- 10000 -- 1:X chance that item will be common (1 = 100%)	-- 13 -- 20%
        },
        [LEGENDARY] = {
            name = "Unique",
            maxBonus = 3, -- max amount of bonus attributes
            chance = 0 -- 1000 -- 1:X chance that item will be common (1 = 100%) -- 50 -- 1.5%
        },
        [HEROIC] = { -- removed !!!
            name = "Heroic",
            maxBonus = 3, -- max amount of bonus attributes
            chance = 0 -- 100 -- 1:X chance that item will be common (1 = 100%)	-- 500 -- 0.5%
        },
        [MYTHIC] = { -- removed !!!
            name = "Mythic",
            maxBonus = 3, -- max amount of bonus attributes
            chance = 0 -- 50 -- 1:X chance that item will be common (1 = 100%)	-- 100 -- 0.05%
        },
        [DIVINE] = { -- removed !!!
            name = "Divine",
            maxBonus = 3, -- max amount of bonus attributes
            chance = 0 -- 1:X chance that item will be common (1 = 100%)	-- 100 -- 0.005%
        }
    }
}


SPELL_RUNES = {
    [1] = 37306,
    [2] = 37338,
}
SUPPORT_RUNES = {
    [1] = 37373,
    [2] = 37384,
}

US_ITEM_TYPES = {
    ALL = bit.lshift(1, 0),
    HELMET = bit.lshift(1, 1),
    ARMOR = bit.lshift(1, 2),
    LEGS = bit.lshift(1, 3),
    BOOTS = bit.lshift(1, 4),
    RING = bit.lshift(1, 5),
    NECKLACE = bit.lshift(1, 6),
    SHIELD = bit.lshift(1, 7),
    WEAPON_CROSSBOW = bit.lshift(1, 8),
    WEAPON_BOW = bit.lshift(1, 9),
    WEAPON_KNIFE = bit.lshift(1, 10),
    WEAPON_WAND = bit.lshift(1, 11),
    WEAPON_WANDAOE = bit.lshift(1, 12),
    WEAPON_SWORD = bit.lshift(1, 13),
    WEAPON_CLUB = bit.lshift(1, 14),
    WEAPON_AXE = bit.lshift(1, 15),
    WEAPON_MELEE = bit.lshift(1, 16),
    WEAPON_ANY = bit.lshift(1, 17),
    GLOVES = bit.lshift(1, 18),
    BELT = bit.lshift(1, 19),
    RIGHT_RING = bit.lshift(1, 20),
    PET = bit.lshift(1, 21),
    POTION = bit.lshift(1, 22),

    RELICT_ANY = bit.lshift(1, 23),
    RELICT_DEFFENSIVE = bit.lshift(1, 24),
    RELICT_OFFENSIVE = bit.lshift(1, 25),
    RELICT_UTILITY = bit.lshift(1, 26),
    RELICT_GOBLIN = bit.lshift(1, 27),
    RELICT_CHAMPION = bit.lshift(1, 28),
    RELICT_STRONGBOX = bit.lshift(1, 29),
    RELICT_BOSS = bit.lshift(1, 30),
    RELICT_VOIDSTONE = bit.lshift(1, 31),
}

US_TYPES = {
    CONDITION = 0,
    OFFENSIVE = 1,
    DEFENSIVE = 2,
    TRIGGER = 3
}

US_TRIGGERS = {
    ATTACK = 0,
    HIT = 1,
    KILL = 2
}
US_UNIQUES = {
    [1] = {
        name = "Eddo Sword",
        itemId = 31588,
        attack = 20,
        chance = 100, -- 1/10 to 10%
        monsterLevel = 1, -- od ktorego poziomu ma dropic
        maxMonsterLevel = 25,
        itemType = 2,
        implicit = {
            {
                id = 89, -- melee damage
                min = 15,
                max = 30,
            },
            {
                id = 19, -- basic damage
                min = 20,
                max = 30,
            },
        },
        attr = {
            {
                id = 11, -- physical damage
                min = 20,
                max = 30,
            },
            {
                id = 21, -- chance bleed
                min = 5,
                max = 10,
            },
            {
                id = 55, -- attack speed
                min = 7,
                max = 10,
            }
        },
    },
    [2] = {
        name = "Gloom Wand",
        itemId = 26632,
        attack = 20,
        chance = 100, -- 1/10 to 10%
        monsterLevel = 1, -- od ktorego poziomu ma dropic
        itemType = 8,
        maxMonsterLevel = 25,
        implicit = {
            {
                id = 90, -- magic damage
                min = 15,
                max = 30,
            },
            {
                id = 19, -- basic damage
                min = 20,
                max = 30,
            },
        },
        attr = {
            {
                id = 18, -- spell damage
                min = 20,
                max = 30,
            },
            {
                id = 210, -- aliment chance
                min = 5,
                max = 10,
            },
            {
                id = 55, -- attack speed
                min = 7,
                max = 10,
            }
        },
    },
    [3] = {
        name = "Silkweaver Bow",
        itemId = 8857,
        attack = 20,
        chance = 100, -- 1/10 to 10%
        itemType = 3,
        monsterLevel = 1, -- od ktorego poziomu ma dropic
        maxMonsterLevel = 25,
        implicit = {
            {
                id = 91, -- ranged damage
                min = 15,
                max = 30,
            },
            {
                id = 19, -- basic damage
                min = 20,
                max = 30,
            },
        },
        attr = {
            {
                id = 60, -- physical damage
                min = 20,
                max = 30,
            },
            {
                id = 32, -- chance poison
                min = 5,
                max = 10,
            },
            {
                id = 55, -- attack speed
                min = 7,
                max = 10,
            }
        },
    },
    [4] = {
        name = "Boots Of haste",
        itemId = 2195,
        chance = 100, -- 1/10 to 10%
        monsterLevel = 1, -- od ktorego poziomu ma dropic
        itemType = 13,
        maxMonsterLevel = 25,
        implicit = {
            {
                id = 27,
                min = 15,
                max = 30,
            },
        },
        attr = {
            {
                id = 9, -- dodge
                min = 5,
                max = 8,
            },
            {
                id = 6, -- all atributes
                min = 2,
                max = 5,
            },
            {
                id = 10, -- exp
                min = 5,
                max = 20,
            }
        },
    },
    [5] = {
        name = "Liferuby Ring",
        itemId = 24324,
        chance = 100, -- 1/10 to 10%
        monsterLevel = 1, -- od ktorego poziomu ma dropic
        maxMonsterLevel = 25,
        itemType = 14,
        implicit = {
            {
                id = 46, -- health on hit
                min = 4,
                max = 6,
            },
        },
        attr = {
            {
                id = 56, -- CD
                min = 6,
                max = 10,
            },
            {
                id = 1, -- HP
                min = 110,
                max = 150,
            },
            {
                id = 6, -- all atributes
                min = 4,
                max = 6,
            }
        },
    },
    [6] = {
        name = "Dwarven Armor",
        itemId = 2503,
        chance = 100, -- 1/10 to 10%
        monsterLevel = 1, -- od ktorego poziomu ma dropic
        maxMonsterLevel = 25,
        itemType = 11,
        implicit = {
            {
                id = 53, -- Armor
                min = 30,
                max = 50,
            },
            {
                id = 1, -- HP
                min = 125,
                max = 155,
            },
            {
                id = 16, -- Recovery Effectivenes
                min = 20,
                max = 25,
            },
        },
        attr = {
            {
                id = 22, -- Damage Reduction
                min = 5,
                max = 8,
            },
            {
                id = 23, -- Health Regeneration
                min = 3,
                max = 5,
            },
        },
    },
    [7] = {
        name = "Dwarven Legs",
        itemId = 2504,
        chance = 100, -- 1/10 to 10%
        monsterLevel = 1, -- od ktorego poziomu ma dropic
        maxMonsterLevel = 25,
        itemType = 12,
        implicit = {
            {
                id = 53, -- Armor
                min = 35,
                max = 45,
            },
            {
                id = 1, -- HP
                min = 90,
                max = 155,
            },
            {
                id = 16, -- Recovery Effectivenes
                min = 20,
                max = 25,
            },
        },
        attr = {
            {
                id = 22, -- Damage Reduction
                min = 5,
                max = 8,
            },
            {
                id = 23, -- HP regen
                min = 3,
                max = 5,
            },
        },
    },
    [8] = {
        name = "Blackness Gloves",
        itemId = 36402,
        chance = 100, -- 1/10 to 10%
        monsterLevel = 1, -- od ktorego poziomu ma dropic
        maxMonsterLevel = 25,
        itemType = 15,
        implicit = {
            {
                id = 55, -- Attack Speed
                min = 5,
                max = 15,
            },
        },
        attr = {
            {
                id = 108, -- Brute damage
                min = 5,
                max = 25,
            },
            {
                id = 196, -- Duality damage
                min = 5,
                max = 25,
            },
            {
                id = 12, -- Elemental damage
                min = 5,
                max = 25,
            },
        },
    },
    [9] = {
        name = "Wisdom Cap",
        itemId = 26709,
        chance = 100, -- 1/10 to 10%
        monsterLevel = 1, -- od ktorego poziomu ma dropic
        maxMonsterLevel = 25,
        itemType = 9,
        implicit = {
            {
                id = 71, -- Energy Shield
                min = 70,
                max = 155,
            },
            {
                id = 10, -- EXP
                min = 5,
                max = 25,
            },
        },
        attr = {
            {
                id = 16, -- Recovery Effectiveness
                min = 5,
                max = 25,
            },
            {
                id = 23, -- Health Regeneration
                min = 5,
                max = 10,
            },
            {
                id = 24, -- Mana Regeneration
                min = 2,
                max = 5,
            },
        },
    },
    -- mid game
    [10] = {
        name = "Headchopper",
        itemId = 7380,
        attack = 47,
        chance = 100, -- 1/10 to 10%
        monsterLevel = 26, -- od ktorego poziomu ma dropic
        maxMonsterLevel = 45,
        itemType = 1,
        implicit = {
            {
                id = 89, -- melee damage
                min = 15,
                max = 47,
            },
            {
                id = 19, -- basic damage
                min = 20,
                max = 30,
            },
        },
        attr = {
            {
                id = 11, -- physical damage
                min = 30,
                max = 40,
            },
            {
                id = 21, -- chance bleed
                min = 15,
                max = 30,
            },
            {
                id = 25, -- Executor
                min = 10,
                max = 10,
            }
        },
    },
    [11] = {
        name = "Yalahar Staff",
        itemId = 36134,
        attack = 47,
        chance = 100, -- 1/10 to 10%
        monsterLevel = 26, -- od ktorego poziomu ma dropic
        maxMonsterLevel = 45,
        itemType = 6,
        implicit = {
            {
                id = 90, -- magic damage
                min = 15,
                max = 47,
            },
            {
                id = 19, -- basic damage
                min = 20,
                max = 30,
            },
        },
        attr = {
            {
                id = 18, -- spell damage
                min = 30,
                max = 40,
            },
            {
                id = 210, -- aliments chance
                min = 5,
                max = 5,
            },
            {
                id = 202, -- Spell Wisdom 1% spell damage per level
                min = 0,
                max = 0,
            }
        },
    },
    [12] = {
        name = "Gilded Crossbow",
        itemId = 36138,
        attack = 47,
        chance = 100, -- 1/10 to 10%
        monsterLevel = 26, -- od ktorego poziomu ma dropic
        maxMonsterLevel = 45,
        itemType = 3,
        implicit = {
            {
                id = 91, -- ranged damage
                min = 15,
                max = 47,
            },
            {
                id = 19, -- basic damage
                min = 20,
                max = 30,
            },
        },
        attr = {
            {
                id = 11, -- physical damage
                min = 30,
                max = 40,
            },
            {
                id = 21, -- chance bleed
                min = 15,
                max = 30,
            },
            {
                id = 31, -- Physical Penetration
                min = 10,
                max = 15,
            }
        },
    },
    [13] = {
        name = "Magic Cape",
        itemId = 26687,
        chance = 100, -- 1/10 to 10%
        monsterLevel = 26, -- od ktorego poziomu ma dropic
        maxMonsterLevel = 65,
        itemType = 11,
        implicit = {
            {
                id = 71, -- Energy Shield
                min = 120,
                max = 225,
            },
            {
                id = 72, -- Energy Shield Percent
                min = 20,
                max = 35,
            },
            {
                id = 109, -- Health Percent
                min = -25,
                max = -25,
            },
        },
        attr = {
            {
                id = 23, -- Health Regeneration
                min = -8,
                max = -14,
            },
            {
                id = 26, -- Energy Shield Regeneration
                min = 20,
                max = 30,
            },
        },
    },
    [14] = {
        name = "Lion Medalion", -- all attributes
        desc = "XXX.",
        itemId = 34495,
        chance = 1, -- 1/10 to 10%
        monsterLevel = 26, -- od ktorego poziomu ma dropic
        maxMonsterLevel = 100,
        itemType = 10,
        implicit = {
            {
                id = 4, -- Strength
                min = 1,
                max = 70,
            },
        },
        attr = {
            {
                id = 34, -- Mastery
                min = 1,
                max = 35,
            },
            {
                id = 7, -- Vitality
                min = 1,
                max = 35,
            },
        },
    },
    [15] = {
        name = "Black Curse Helmet", -- all attributes
        itemId = 37817,
        chance = 1, -- 1/10 to 10%
        monsterLevel = 26, -- od ktorego poziomu ma dropic
        maxMonsterLevel = 100,
        itemType = 9,
        attr = {
            {
                id = 203,
                min = 1,
                max = 1,
            },
            {
                id = 6, -- all atributes
                min = 1,
                max = 15,
            },
        },
    },
    [16] = {
        name = "Golden Helmet", -- all attributes
        itemId = 26560,
        chance = 3, -- 1/10 to 10%
        monsterLevel = 1, -- od ktorego poziomu ma dropic
        maxMonsterLevel = 100,
        itemType = 9,
        attr = {
            {
                id = 17, -- Gold
                min = 1,
                max = 75,
            },
            {
                id = 10, -- exp
                min = 1,
                max = 30,
            },
            {
                id = 6, -- all atributes
                min = 1,
                max = 18,
            },
        },
    },
    -- Endgame
    [17] = {
        name = "Mirror Ring",
        itemId = 38037,
        chance = 1,
        monsterLevel = 70,
        maxMonsterLevel = 100,
        mirrored = true,
        itemType = 14,
        noCrystalSlots = true,
        crystalSlots = 0,
        attr = {
            {
                id = 205,
                min = 1,
                max = 1,
            },
        },
    },
    [18] = {
        name = "Heaven Robe",
        itemId = 9776,
        chance = 100, -- 1/10 to 10%
        monsterLevel = 70, -- od ktorego poziomu ma dropic
        maxMonsterLevel = 100,
        itemType = 11,
        implicit = {
            {
                id = 53, -- Armor
                min = 50,
                max = 100,
            },
            {
                id = 1, -- HP
                min = 50,
                max = 400,
            },
            {
                id = 109, -- Health Percent
                min = 1,
                max = 10,
            },
        },
        attr = {
            {
                id = 22, -- Damage Reduction
                min = 1,
                max = 4,
            },
            {
                id = 207, -- Resurrection
                min = 0,
                max = 0,
            },
        },
    },
    [19] = {
        name = "Ailment Ring",
        itemId = 37765,
        chance = 100,
        monsterLevel = 70,
        maxMonsterLevel = 100,
        itemType = 14,
        implicit = {
            {
                id = 47, -- DoT Damage
                min = 5,
                max = 50,
            },
            {
                id = 210, -- All aliment
                min = 3,
                max = 10,
            },
        },
        attr = {
            {
                id = 206, -- Affliction Mastery
                min = 1,
                max = 1,
            },
        },
    },
    [20] = {
        name = "Adaptive Knife",
        desc = "xxx",
        itemId = 36681,
        attack = 15,
        chance = 100, -- 1/10 to 10%
        monsterLevel = 1, -- od ktorego poziomu ma dropic
        maxMonsterLevel = 100,
        itemType = 5,
        implicit = {
            {
                id = 20, -- Damage
                min = 9,
                max = 20,
            },
        },
        attr = {
            {
                id = 55, -- Attack Speed
                min = 5,
                max = 10,
            },
            {
                id = 107, -- All Spells
                min = 2,
                max = 5,
            },
            {
                id = 217, -- Adaptive
                min = 1,
                max = 1,
            }
        },
    },
    [21] = {
        name = "Adaptive Wand",
        desc = "xxx",
        itemId = 35921,
        attack = 15,
        chance = 100, -- 1/10 to 10%
        monsterLevel = 1, -- od ktorego poziomu ma dropic
        maxMonsterLevel = 100,
        itemType = 8,
        implicit = {
            {
                id = 20, -- Damage
                min = 9,
                max = 20,
            },
        },
        attr = {
            {
                id = 55, -- Attack Speed
                min = 5,
                max = 10,
            },
            {
                id = 107, -- All Spells
                min = 2,
                max = 5,
            },
            {
                id = 217, -- Adaptive
                min = 1,
                max = 1,
            }
        },
    },
    [22] = {
        name = "Adaptive Sword",
        desc = "xxx",
        itemId = 36109,
        attack = 15,
        chance = 100, -- 1/10 to 10%
        monsterLevel = 1, -- od ktorego poziomu ma dropic
        maxMonsterLevel = 100,
        itemType = 2,
        implicit = {
            {
                id = 20, -- Damage
                min = 9,
                max = 20,
            },
        },
        attr = {
            {
                id = 55, -- Attack Speed
                min = 5,
                max = 10,
            },
            {
                id = 107, -- All Spells
                min = 2,
                max = 5,
            },
            {
                id = 217, -- Adaptive
                min = 1,
                max = 1,
            }
        },
    },
    [23] = {
        name = "Dragon Scale Mail",
        desc = "XXX.",
        itemId = 2492,
        chance = 100, -- 1/10 to 10%
        monsterLevel = 26, -- od ktorego poziomu ma dropic
        maxMonsterLevel = 100,
        itemType = 11,
        implicit = {
            {
                id = 23, -- Health Regeneration
                min = 4,
                max = 12,
            },
            {
                id = 74, -- Health Regeneration Percent
                min = 1,
                max = 13,
            },
            {
                id = 7, -- Vitality
                min = 1,
                max = 10,
            },
        },
        attr = {
            {
                id = 22, -- damage reduction
                min = 1,
                max = 4,
            },
            {
                id = 218, -- Dragon Vitality
                min = 1,
                max = 1,
            },
        },
    },
    [24] = {
        name = "Dragon Scale Legs",
        desc = "XXX.",
        itemId = 2469,
        chance = 100, -- 1/10 to 10%
        monsterLevel = 26, -- od ktorego poziomu ma dropic
        maxMonsterLevel = 100,
        itemType = 12,
        implicit = {
            {
                id = 23, -- Health Regeneration
                min = 4,
                max = 12,
            },
            {
                id = 74, -- Health Regeneration Percent
                min = 5,
                max = 15,
            },
            {
                id = 7, -- Vitality
                min = 1,
                max = 10,
            },
        },
        attr = {
            {
                id = 22, -- damage reduction
                min = 1,
                max = 4,
            },
            {
                id = 219, -- Dragon Absorb
                min = 1,
                max = 1,
            },
        },
    },
    -- Frost Beast Unique Items
    [25] = {
        name = "Crystalline Plate",
        itemId = 29714,
        chance = 100,
        monsterLevel = 46,
        maxMonsterLevel = 100,
        crystalSlots = 7,
        itemType = 11,
        implicit = {
            {
                id = 22, -- damage reduction
                min = 1,
                max = 5,
            },
            {
                id = 1, -- HP
                min = 100,
                max = 300,
            },
            {
                id = 71, -- Energy Shield
                min = 100,
                max = 300,
            },
        },
    },
    [26] = {
        name = "Nox Gloves",
        boss = "Annihilator", -- quest
        desc = "xxx",
        itemId = 37780,
        chance = 100, -- 1/10 to 10%
        monsterLevel = 20, -- od ktorego poziomu ma dropic
        maxMonsterLevel = 100,
        itemType = 15,
        implicit = {
            {
                id = 46, -- health on hit
                min = 1,
                max = 12,
            },
            {
                id = 111, -- Energy Shield on Hit
                min = 1,
                max = 12,
            },
        },
        attr = {
            {
                id = 20, -- Damage
                min = 1,
                max = 40,
            },
            {
                id = 55, -- Attack Speed
                min = 1,
                max = 15,
            },
            {
                id = 10, -- Exp
                min = 1,
                max = 20,
            },
        },
    },
    [27] = {
        name = "Nox Armor",
        boss = "Annihilator", -- quest
        desc = "xxx",
        itemId = 37972,
        chance = 100, -- 1/10 to 10%
        monsterLevel = 20, -- od ktorego poziomu ma dropic
        maxMonsterLevel = 100,
        itemType = 11,
        implicit = {
            {
                id = 1, -- health
                min = 1,
                max = 200,
            },
            {
                id = 71, -- Energy Shield
                min = 1,
                max = 200,
            },
        },
        attr = {
            {
                id = 22, -- Damage Reduction
                min = 1,
                max = 10,
            },
            {
                id = 23, -- Health Regeneration
                min = 1,
                max = 10,
            },
            {
                id = 26, -- Energy Shield Regeneration
                min = 1,
                max = 10,
            },
        },
    },
    [28] = {
        name = "Nox Boots",
        boss = "Annihilator", -- quest
        desc = "xxx",
        itemId = 37974,
        chance = 100, -- 1/10 to 10%
        monsterLevel = 20, -- od ktorego poziomu ma dropic
        maxMonsterLevel = 100,
        itemType = 13,
        implicit = {
            {
                id = 27, -- movements speed
                min = 1,
                max = 30,
            },
            {
                id = 9, -- dodge
                min = 1,
                max = 5,
            },
            {
                id = 35, -- spell avoid
                min = 1,
                max = 5,
            },
        },
        attr = {
            {
                id = 48, -- Cost Reduction
                min = 1,
                max = 15,
            },
            {
                id = 17, -- Gold
                min = 1,
                max = 30,
            },
        },
    },
    [29] = {
        name = "Nox Shield",
        boss = "Annihilator", -- quest
        desc = "xxx",
        itemId = 15413,
        chance = 100, -- 1/10 to 10%
        monsterLevel = 50, -- od ktorego poziomu ma dropic
        maxMonsterLevel = 100,
        itemType = 16,
        implicit = {
            {
                id = 8, -- Block Chance
                min = 1,
                max = 50,
            },
            {
                id = 49, -- Counterattack
                min = 1,
                max = 50,
            },
            {
                id = 22, -- Damage Reduction
                min = 1,
                max = 14,
            },
            {
                id = 96, -- Shield Damage
                min = 20,
                max = 35,
            },
        },
        attr = {
            {
                id = 107, -- All Spells
                min = 1,
                max = 11,
            },
            {
                id = 109, -- Health Percent
                min = 1,
                max = 25,
            },
            {
                id = 72, -- Energy Shield Percent
                min = 1,
                max = 25,
            },
        },
    },
    [30] = {
        name = "Nox Mask",
        boss = "Annihilator", -- quest
        desc = "xxx",
        itemId = 32341,
        chance = 100, -- 1/10 to 10%
        monsterLevel = 50, -- od ktorego poziomu ma dropic
        maxMonsterLevel = 100,
        itemType = 9,
        implicit = {
            {
                id = 6, -- All Attributes
                min = 1,
                max = 20,
            },
            {
                id = 18, -- Spell Damage
                min = 1,
                max = 25,
            },
        },
        attr = {
            {
                id = 107, -- All Spells
                min = 1,
                max = 10,
            },
            {
                id = 34, -- Mastery
                min = 1,
                max = 30,
            },
        },
    },
    [31] = {
        name = "Nox Amulet",
        boss = "Annihilator", -- quest
        desc = "xxx",
        itemId = 18407,
        chance = 100, -- 1/10 to 10%
        monsterLevel = 50, -- od ktorego poziomu ma dropic
        maxMonsterLevel = 100,
        itemType = 10,
        implicit = {
            {
                id = 19, -- Basic Damage
                min = 1,
                max = 50,
            },
            {
                id = 33, -- Boss Damage
                min = 1,
                max = 70,
            },
        },
        attr = {
            {
                id = 107, -- All Spells
                min = 1,
                max = 7,
            },
            {
                id = 198, -- Duality Penetration
                min = 1,
                max = 11,
            },
            {
                id = 122, -- Elemental Penetration
                min = 1,
                max = 11,
            },
            {
                id = 31, -- Physical Penetration
                min = 1,
                max = 11,
            },
        },
    },
    [32] = {
        name = "Multicast",
        itemId = 37374,
        chance = 1, -- 1/10 to 10%
        monsterLevel = 70, -- od ktorego poziomu ma dropic
        fakeUnique = true,
        noItemLevel = true,
        noCrystalSlots = true,
        itemType = 19,
    },
    -- Fuzion Uniquest
    -- Thundershot Sorcerer + Archer
    [33] = {
        name = "Hermes Helmet", -- movement speed
        desc = "XXX.",
        itemId = 26699,
        chance = 1, -- New uniques
        monsterLevel = 100, -- od ktorego poziomu ma dropic
        itemType = 9,
        implicit = {
            {
                id = 27, -- Movement Speed
                min = 10,
                max = 30,
            },
        },
        attr = {
            {
                id = 9, -- Dodge
                min = 1,
                max = 7,
            },
            {
                id = 35, -- Spell Avoid
                min = 1,
                max = 7,
            },
            {
                id = 221, -- Hermes Speed
                min = 1,
                max = 1,
            },
        },
    },
    -- Archer + Knight Siegebreaker
    [34] = {
        name = "Focused Helmet", -- basic damage helmet
        desc = "XXX.",
        itemId = 25410,
        chance = 1, -- New uniques
        monsterLevel = 100, -- od ktorego poziomu ma dropic
        itemType = 9,
        implicit = {
            {
                id = 19, -- basic damage
                min = 1,
                max = 60,
            },
            {
                id = 55, -- attack speed
                min = 1,
                max = 20,
            },
        },
        attr = {
            {
                id = 22, -- damage reduction
                min = 1,
                max = 6,
            },
            {
                id = 107, -- all spell
                min = 3,
                max = 10,
            },
            {
                id = 256, -- focused strike Each 1% of Attack Speed increases basic damage by 3%.
                min = 1,
                max = 1,
            },
        },
    },
    [35] = {
        name = "Cosmic Helmet", -- elemental dmage per HP/ES
        desc = "XXX.",
        itemId = 38687,
        chance = 1, -- New uniques
        monsterLevel = 100, -- od ktorego poziomu ma dropic
        itemType = 9,
        implicit = {
            {
                id = 12, -- elemental damage
                min = 5,
                max = 60,
            },
            {
                id = 210, -- alimenty Chance
                min = 1,
                max = 10,
            },
        },
        attr = {
            {
                id = 22, -- damage reduction
                min = 1,
                max = 4,
            },
            {
                id = 107, -- all spells
                min = 1,
                max = 10,
            },
            {
                id = 212, -- Cosmic Focus
                min = 1,
                max = 1,
            },
        },
    },
    [36] = {
        name = "Horned Helmet", -- physical dmage per HP/ES
        desc = "XXX.",
        itemId = 38661,
        chance = 1, -- New uniques
        monsterLevel = 100, -- od ktorego poziomu ma dropic
        itemType = 9,
        implicit = {
            {
                id = 11, -- physical damage
                min = 5,
                max = 60,
            },
            {
                id = 210, -- alimenty Chance
                min = 1,
                max = 10,
            },
        },
        attr = {
            {
                id = 22, -- damage reduction
                min = 1,
                max = 4,
            },
            {
                id = 107, -- all spells
                min = 1,
                max = 10,
            },
            {
                id = 252, -- Raw Focus 3% of your Max Health or Energy Shield (whichever is higher) increase Physical Damage
                min = 1,
                max = 1,
            },
        },
    },
    [37] = {
        name = "Divine Helmet", -- duality dmage per HP/ES
        desc = "XXX.",
        itemId = 38668,
        chance = 1, -- New uniques
        monsterLevel = 100, -- od ktorego poziomu ma dropic
        itemType = 9,
        implicit = {
            {
                id = 196, -- duality damage
                min = 5,
                max = 60,
            },
            {
                id = 210, -- alimenty Chance
                min = 1,
                max = 10,
            },
        },
        attr = {
            {
                id = 22, -- damage reduction
                min = 1,
                max = 4,
            },
            {
                id = 107, -- all spells
                min = 1,
                max = 10,
            },
            {
                id = 251, -- Divine Blessing 3% of your Max Health or Energy Shield (whichever is higher) increase Duality Damage
                min = 1,
                max = 1,
            },
        },
    },
    -- Archer + Shadow Nightstalker
    [38] = {
        name = "Claw Ring",
        boss = "Thunderlord",
        itemId = 38435,
        chance = 15, -- New uniques
        monsterLevel = 100,
        itemType = 14,
        implicit = {
            {
                id = 107, -- All Spells
                min = 1,
                max = 15,
            },
        },
        attr = {
            {
                id = 107, -- All Spells
                min = 1,
                max = 15,
            },
        },
    },
    -- Knight + Paladin Crusader
    [39] = {
        name = "Reflected Shield", -- counter attack
        itemId = 35722,
        chance = 10, -- New uniques
        monsterLevel = 100, -- od ktorego poziomu ma dropic
        itemType = 16,
        implicit = {
            {
                id = 8, -- block chance
                min = 20,
                max = 60,
            },
            {
                id = 96, -- Shield Damage
                min = 1,
                max = 55,
            },
            {
                id = 49, -- counterattack
                min = 25,
                max = 75,
            },
            {
                id = 1, -- Health
                min = 30,
                max = 500,
            },
        },
        attr = {
            {
                id = 20, -- Damage
                min = 50,
                max = 75,
            },
            {
                id = 171, -- Added Adaptive damage
                min = 25,
                max = 35,
            },
            {
                id = 107, -- All Spells
                min = 1,
                max = 7,
            },
            {
                id = 208, -- Bastion
                min = 0,
                max = 0,
            },
        },
    },
    -- Paladin + Shadow Abyssal Cleric
    [40] = {
        name = "Darkness Ring", -- dex to duality
        boss = "Holy Protector",
        itemId = 37764,
        chance = 15, -- New uniques
        monsterLevel = 100, -- od ktorego poziomu ma dropic
        itemType = 14,
        implicit = {
            {
                id = 20, -- Damage
                min = 5,
                max = 60,
            },
            {
                id = 107, -- All Spells
                min = 1,
                max = 10,
            },
        },
        attr = {
            {
                id = 260, -- Soul Piercing
                min = 0,
                max = 0,
            },
        },
    },
    [41] = {
        name = "Raven Ring", -- int to elmental penetration
        boss = "Thunderlord",
        itemId = 38528,
        chance = 15, -- New uniques
        monsterLevel = 100,
        itemType = 14,
        implicit = {
            {
                id = 20, -- Damage
                min = 5,
                max = 60,
            },
            {
                id = 107, -- All Spells
                min = 1,
                max = 10,
            },
        },
        attr = {
            {
                id = 261, -- Raven Peck
                min = 1,
                max = 1,
            },
        },
    },
    [42] = {
        name = "Bloody Skull Ring", -- str to phys penetration
        boss = "Blackfang Archer",
        itemId = 38222,
        chance = 15, -- New uniques
        monsterLevel = 100,
        itemType = 14,
        implicit = {
            {
                id = 20, -- Damage
                min = 5,
                max = 60,
            },
            {
                id = 107, -- All Spells
                min = 1,
                max = 10,
            },
        },
        attr = {
            {
                id = 263, -- Bloody pact
                min = 1,
                max = 1,
            },
        },
    },
    [43] = {
        name = "Multi Strike",
        itemId = 38116,
        chance = 1, -- 1/10 to 10%
        monsterLevel = 70, -- od ktorego poziomu ma dropic
        fakeUnique = true,
        noItemLevel = true,
        noCrystalSlots = true,
        itemType = 19,
    },
    [44] = {
        name = "Sapphire Spark Ring", -- str to phys penetration
        boss = "Holy Protector",
        itemId = 38578,
        chance = 15, -- New uniques
        monsterLevel = 100,
        itemType = 14,
        implicit = {
            {
                id = 20, -- Damage
                min = 5,
                max = 60,
            },
            {
                id = 107, -- All Spells
                min = 1,
                max = 10,
            },
        },
        attr = {
            {
                id = 277, -- Spark Speed
                min = 1,
                max = 1,
            },
        },
    },
    [45] = {
        name = "Fast Ruby Ring", -- str to phys penetration
        boss = "Blackfang Archer",
        itemId = 38592,
        chance = 15, -- New uniques
        monsterLevel = 100,
        itemType = 14,
        implicit = {
            {
                id = 20, -- Damage
                min = 5,
                max = 60,
            },
            {
                id = 107, -- All Spells
                min = 1,
                max = 10,
            },
        },
        attr = {
            {
                id = 278, -- Ruby Speed
                min = 1,
                max = 1,
            },
        },
    },
    [46] = {
        name = "Blow Void Ring", -- str to phys penetration
        boss = "Frost Beast",
        itemId = 38604,
        chance = 15, -- New uniques
        monsterLevel = 100,
        itemType = 14,
        implicit = {
            {
                id = 20, -- Damage
                min = 5,
                max = 60,
            },
            {
                id = 107, -- All Spells
                min = 1,
                max = 10,
            },
        },
        attr = {
            {
                id = 279, -- Blow Strike
                min = 1,
                max = 1,
            },
        },
    },
    [47] = {
        name = "Toxic Boble Ring", -- str to phys penetration
        boss = "Frost Beast",
        itemId = 38582,
        chance = 15, -- New uniques
        monsterLevel = 100,
        itemType = 14,
        implicit = {
            {
                id = 20, -- Damage
                min = 5,
                max = 60,
            },
            {
                id = 107, -- All Spells
                min = 1,
                max = 10,
            },
        },
        attr = {
            {
                id = 280, -- Toxic Synergy
                min = 1,
                max = 1,
            },
        },
    },
    [48] = {
        name = "Void Walker",
        itemId = 38690,
        chance = 0, -- 1/10 to 10%
        monsterLevel = 100, -- od ktorego poziomu ma dropic
        itemType = 13,
        implicit = {
            {
                id = 27,
                min = 15,
                max = 50,
            },
            {
                id = 9, -- dodge
                min = 1,
                max = 12,
            },
            {
                id = 35, -- avoid
                min = 1,
                max = 12,
            },
        },
        attr = {
            {
                id = 1, -- Health
                min = 1,
                max = 500,
            },
            {
                id = 71, -- ES
                min = 1,
                max = 500,
            },
            {
                id = 6, -- all atributes
                min = 1,
                max = 20,
            },
            {
                id = 254, -- Void Walker
                min = 1,
                max = 1,
            }
        },
    },
    [49] = {
        name = "Hermes Amulet", -- all attributes
        desc = "XXX.",
        itemId = 18402,
        chance = 1, -- 1/10 to 10%
        monsterLevel = 26, -- od ktorego poziomu ma dropic
        maxMonsterLevel = 100,
        itemType = 10,
        implicit = {
            {
                id = 27, -- movement speed
                min = 1,
                max = 40,
            },
        },
        attr = {
            {
                id = 34, -- Mastery
                min = 1,
                max = 35,
            },
            {
                id = 7, -- Vitality
                min = 1,
                max = 35,
            },
        },
    },
    [50] = {
        name = "Toxic Amulet", -- all attributes
        desc = "XXX.",
        itemId = 38586,
        chance = 1, -- 1/10 to 10%
        monsterLevel = 26, -- od ktorego poziomu ma dropic
        maxMonsterLevel = 100,
        itemType = 10,
        implicit = {
            {
                id = 210, -- Ailments Chance
                min = 1,
                max = 44,
            },
        },
        attr = {
            {
                id = 34, -- Mastery
                min = 1,
                max = 35,
            },
            {
                id = 7, -- Vitality
                min = 1,
                max = 35,
            },
        },
    },
    [51] = {
        name = "Doom Amulet", -- all attributes
        desc = "XXX.",
        itemId = 37994,
        chance = 1, -- 1/10 to 10%
        monsterLevel = 26, -- od ktorego poziomu ma dropic
        maxMonsterLevel = 100,
        itemType = 10,
        implicit = {
            {
                id = 29, -- Critical Chance
                min = 1,
                max = 18,
            },
        },
        attr = {
            {
                id = 34, -- Mastery
                min = 1,
                max = 35,
            },
            {
                id = 7, -- Vitality
                min = 1,
                max = 35,
            },
        },
    },
    [52] = {
        name = "Quick Amulet", -- all attributes
        desc = "XXX.",
        itemId = 38599,
        chance = 1, -- 1/10 to 10%
        monsterLevel = 26, -- od ktorego poziomu ma dropic
        maxMonsterLevel = 100,
        itemType = 10,
        implicit = {
            {
                id = 55, -- attack speed
                min = 1,
                max = 90,
            },
        },
        attr = {
            {
                id = 34, -- Mastery
                min = 1,
                max = 35,
            },
            {
                id = 7, -- Vitality
                min = 1,
                max = 35,
            },
        },
    },
    [53] = {
        name = "Mage Medalion", -- all attributes
        desc = "XXX.",
        itemId = 38438,
        chance = 1, -- 1/10 to 10%
        monsterLevel = 26, -- od ktorego poziomu ma dropic
        maxMonsterLevel = 100,
        itemType = 10,
        implicit = {
            {
                id = 3, -- Intelligence
                min = 1,
                max = 70,
            },
        },
        attr = {
            {
                id = 34, -- Mastery
                min = 1,
                max = 35,
            },
            {
                id = 7, -- Vitality
                min = 1,
                max = 35,
            },
        },
    },
    [54] = {
        name = "Snake Medalion", -- all attributes
        desc = "XXX.",
        itemId = 26982,
        chance = 1, -- 1/10 to 10%
        monsterLevel = 26, -- od ktorego poziomu ma dropic
        maxMonsterLevel = 100,
        itemType = 10,
        implicit = {
            {
                id = 5, -- Dexterity
                min = 1,
                max = 70,
            },
        },
        attr = {
            {
                id = 34, -- Mastery
                min = 1,
                max = 35,
            },
            {
                id = 7, -- Vitality
                min = 1,
                max = 35,
            },
        },
    },
    [55] = {
        name = "Demon Shield", -- counter attack
        itemId = 2520,
        chance = 1, -- New uniques
        monsterLevel = 100, -- od ktorego poziomu ma dropic
        itemType = 16,
        implicit = {
            {
                id = 8, -- block chance
                min = 20,
                max = 60,
            },
            {
                id = 96, -- Shield Damage
                min = 1,
                max = 55,
            },
            {
                id = 49, -- counterattack
                min = 25,
                max = 75,
            },
            {
                id = 1, -- Health
                min = 30,
                max = 500,
            },
        },
        attr = {
            {
                id = 12, -- Elemental damage
                min = 50,
                max = 75,
            },
            {
                id = 69, -- added elemental damage
                min = 25,
                max = 35,
            },
            {
                id = 228, -- Elemental Spells
                min = 1,
                max = 7,
            },
            {
                id = 258, -- Demon Imbue
                min = 0,
                max = 0,
            },
        },
    },
    [56] = {
        name = "Storm Unbound Staff",
        itemId = 38372,
        spellUnique = true,
        spellUniqueID = 250,
        attack = 107,
        chance = 1, -- 1/10 to 10%
        monsterLevel = 100,
        itemType = 6,
        implicit = {
            {
                id = 90, -- magic damage
                min = 88,
                max = 99,
            },
            {
                id = 59, -- lightning damage
                min = 100,
                max = 136,
            },
        },
        attr = {
            {
                id = 69, -- added elemental damage
                min = 60,
                max = 85,
            },
            {
                id = 122, -- Elemental Penetration
                min = 10,
                max = 32,
            },
            {
                id = 228, -- Elemental Spells
                min = 1,
                max = 12,
            },
            {
                id = 250, -- Spell [Spark] fires 10 additional Projectiles.
                min = 0,
                max = 0,
            }
        },
    },
    [57] = {
        name = "The Last Druid Staff",
        itemId = 38538,
        spellUnique = true,
        spellUniqueID = 193,
        attack = 107,
        chance = 1, -- 1/10 to 10%
        monsterLevel = 100,
        itemType = 6,
        implicit = {
            {
                id = 90, -- magic damage
                min = 88,
                max = 99,
            },
            {
                id = 58, -- ice damage
                min = 100,
                max = 136,
            },
            {
                id = 60, -- earth damage
                min = 100,
                max = 136,
            },
        },
        attr = {
            {
                id = 69, -- added elemental damage
                min = 60,
                max = 85,
            },
            {
                id = 122, -- Elemental Penetration
                min = 10,
                max = 32,
            },
            {
                id = 228, -- Elemental Spells
                min = 1,
                max = 12,
            },
            {
                id = 193, -- Elder Knowledge Spell [Earth Bolt] add 5 projectiles.\nSpell [Sunder], [Rootgrasp] and [Stonefall] increases its area of effect.
                min = 0,
                max = 0,
            }
        },
    },
    [58] = {
        name = "Drakann Gloves",
        itemId = 38035,
        chance = 1, -- 1/10 to 10%
        monsterLevel = 100,
        itemType = 15,
        implicit = {
            {
                id = 20, -- damage
                min = 1,
                max = 60,
            },
            {
                id = 171, -- added adaptive damage
                min = 60,
                max = 78,
            },
        },
        attr = {
            {
                id = 29, -- critical chance
                min = 1,
                max = 8,
            },
            {
                id = 191, -- Spells [Flicker Strike], [Shattering Dash], and [Phantom Run] deal area damage.
                min = 1,
                max = 1,
            },
        },
    },
    [59] = {
        name = "Mana Cape",
        desc = "xxx",
        itemId = 15489,
        chance = 1, -- 1/10 to 10%
        monsterLevel = 100,
        itemType = 11,
        implicit = {
            {
                id = 2, -- Mana
                min = 1600,
                max = 2000,
            },
        },
        attr = {
            {
                id = 22, -- Damage Reduction
                min = 1,
                max = 10,
            },
            {
                id = 184, -- Mana Core 10% of Mana is converted to Health. Gain 350% increased Damage if your Mana is above 15,000.
                min = 1,
                max = 10,
            },
        },
    },
    [60] = {
        name = "Berserker Axe",
        itemId = 36064,
        spellUnique = true,
        spellUniqueID = 183,
        attack = 107,
        chance = 1, -- 1/10 to 10%
        monsterLevel = 100,
        itemType = 1,
        implicit = {
            {
                id = 89, -- melee damage
                min = 88,
                max = 99,
            },
            {
                id = 11, -- physical damage
                min = 100,
                max = 136,
            },
        },
        attr = {
            {
                id = 70, -- added physical damage
                min = 60,
                max = 85,
            },
            {
                id = 31, -- Physical Penetration
                min = 10,
                max = 32,
            },
            {
                id = 229, -- Physical Spells
                min = 1,
                max = 12,
            },
            {
                id = 183, -- Berserker Fury Spell [Amok] and [Leap Slam] has a 0.3 second Cooldown and increased Area of Effect.
                min = 0,
                max = 0,
            }
        },
    },
    [61] = {
        name = "Mjolnir",
        itemId = 38645,
        spellUnique = true,
        spellUniqueID = 178,
        attack = 107,
        chance = 1, -- 1/10 to 10%
        monsterLevel = 100,
        itemType = 1,
        implicit = {
            {
                id = 89, -- melee damage
                min = 88,
                max = 99,
            },
            {
                id = 59, -- lightning damage
                min = 100,
                max = 136,
            },
        },
        attr = {
            {
                id = 69, -- added elemental damage
                min = 60,
                max = 85,
            },
            {
                id = 122, -- Elemental Penetration
                min = 10,
                max = 32,
            },
            {
                id = 102, -- Lightning Spells
                min = 1,
                max = 12,
            },
            {
                id = 178, -- Thunderlord "Spell [Thunder Strike] hits 3 additional targets.\nSpell [Zeus Wrath] cooldown is reduced to 1s.\nAura [Static Condition] is supported by a Level 4 Expansion Rune.",
                min = 0,
                max = 0,
            }
        },
    },
    [62] = {
        name = "Inferno Staff",
        itemId = 38656,
        spellUnique = true,
        spellUniqueID = 173,
        attack = 107,
        chance = 1, -- 1/10 to 10%
        monsterLevel = 100,
        itemType = 6,
        implicit = {
            {
                id = 90, -- magic damage
                min = 88,
                max = 99,
            },
            {
                id = 57, -- fire damage
                min = 100,
                max = 136,
            },
        },
        attr = {
            {
                id = 69, -- added elemental damage
                min = 60,
                max = 85,
            },
            {
                id = 122, -- Elemental Penetration
                min = 10,
                max = 32,
            },
            {
                id = 228, -- Elemental Spells
                min = 1,
                max = 12,
            },
            {
                id = 173, -- Fire Knowledge Spell [Fire Wall] creates two rings instead of a wall.\nSpell [Fireball] chains 2 times to nearby enemies.
                min = 0,
                max = 0,
            }
        },
    },
    [63] = {
        name = "Hailstorm Staff",
        itemId = 2183,
        spellUnique = true,
        spellUniqueID = 156,
        attack = 107,
        chance = 1, -- 1/10 to 10%
        monsterLevel = 100,
        itemType = 6,
        implicit = {
            {
                id = 90, -- magic damage
                min = 88,
                max = 99,
            },
            {
                id = 58, -- ice damage
                min = 100,
                max = 136,
            },
        },
        attr = {
            {
                id = 69, -- added elemental damage
                min = 60,
                max = 85,
            },
            {
                id = 122, -- Elemental Penetration
                min = 10,
                max = 32,
            },
            {
                id = 228, -- Elemental Spells
                min = 1,
                max = 12,
            },
            {
                id = 156, -- Fire Knowledge Spell [Fire Wall] creates two rings instead of a wall.\nSpell [Fireball] chains 2 times to nearby enemies.
                min = 0,
                max = 0,
            }
        },
    },
    [64] = {
        name = "Gru'Al Chopper",
        itemId = 38535,
        spellUnique = true,
        spellUniqueID = 155,
        attack = 107,
        chance = 1, -- 1/10 to 10%
        monsterLevel = 100,
        itemType = 1,
        implicit = {
            {
                id = 89, -- melee damage
                min = 88,
                max = 99,
            },
            {
                id = 11, -- physical damage
                min = 100,
                max = 136,
            },
        },
        attr = {
            {
                id = 70, -- added physical damage
                min = 60,
                max = 85,
            },
            {
                id = 31, -- Physical Penetration
                min = 10,
                max = 32,
            },
            {
                id = 262, -- Basic Spells
                min = 1,
                max = 12,
            },
            {
                id = 155, -- Hack and Slash Aura [Cleave] now deals 125% of the original damage instead of 100% and changes its effect.
                min = 0,
                max = 0,
            }
        },
    },
    [65] = {
        name = "Blitz Staff",
        itemId = 38677,
        spellUnique = true,
        spellUniqueID = 154,
        attack = 107,
        chance = 1, -- 1/10 to 10%
        monsterLevel = 100,
        itemType = 6,
        implicit = {
            {
                id = 90, -- magic damage
                min = 88,
                max = 99,
            },
            {
                id = 59, -- lightning damage
                min = 100,
                max = 136,
            },
        },
        attr = {
            {
                id = 69, -- added elemental damage
                min = 60,
                max = 85,
            },
            {
                id = 122, -- Elemental Penetration
                min = 10,
                max = 32,
            },
            {
                id = 262, -- Basic Spells
                min = 1,
                max = 12,
            },
            {
                id = 154, -- Multishock Aura [Mystic Focus] hits 3 additional targets and deals 115% of the original damage.\n[Mystic Focus] has a 10% chance to deal 225% of the original damage.
                min = 0,
                max = 0,
            }
        },
    },
    [66] = {
        name = "God's Bow",
        itemId = 38539,
        spellUnique = true,
        spellUniqueID = 149,
        attack = 107,
        chance = 1, -- 1/10 to 10%
        monsterLevel = 100,
        itemType = 3,
        implicit = {
            {
                id = 91, -- ranged damage
                min = 88,
                max = 99,
            },
            {
                id = 62, -- holy damage
                min = 100,
                max = 136,
            },
        },
        attr = {
            {
                id = 68, -- added duality damage
                min = 60,
                max = 85,
            },
            {
                id = 198, -- Duality Penetration
                min = 10,
                max = 32,
            },
            {
                id = 262, -- Basic Spells
                min = 1,
                max = 12,
            },
            {
                id = 149, -- Aura [Multishot] now deals 115% of the original damage instead of 100% and changes its effect.\n[Multishot] attacks have 10% change to deal 200% of original damage.
                min = 0,
                max = 0,
            }
        },
    },

    [67] = {
        name = "Infernal Blade",
        itemId = 38652,
        spellUnique = true,
        spellUniqueID = 148,
        attack = 107,
        chance = 1, -- 1/10 to 10%
        monsterLevel = 100,
        itemType = 1,
        implicit = {
            {
                id = 89, -- melee damage
                min = 88,
                max = 99,
            },
            {
                id = 57, -- fire damage
                min = 100,
                max = 136,
            },
        },
        attr = {
            {
                id = 69, -- added elemental damage
                min = 60,
                max = 85,
            },
            {
                id = 122, -- Elemental Penetration
                min = 10,
                max = 32,
            },

            {
                id = 228, -- elemental Spells
                min = 1,
                max = 12,
            },
            {
                id = 148, -- Infernal Eruption Spell [Magma Fissure] and [Molten Strike] add 5 projectiles.\nSpell [Blazing Shout] increases area of effect.
                min = 0,
                max = 0,
            }
        },
    },
    [68] = {
        name = "Skull Blade Staff",
        itemId = 38657,
        spellUnique = true,
        spellUniqueID = 143,
        attack = 107,
        chance = 1, -- 1/10 to 10%
        monsterLevel = 100,
        itemType = 6,
        implicit = {
            {
                id = 90, -- magic damage
                min = 88,
                max = 99,
            },
            {
                id = 61, -- death damage
                min = 100,
                max = 136,
            },
        },
        attr = {
            {
                id = 68, -- added duality damage
                min = 60,
                max = 85,
            },
            {
                id = 198, -- Duality Penetration
                min = 10,
                max = 32,
            },
            {
                id = 230, -- Duality Spells
                min = 1,
                max = 12,
            },
            {
                id = 143, -- Multishock Aura [Mystic Focus] hits 3 additional targets and deals 115% of the original damage.\n[Mystic Focus] has a 10% chance to deal 225% of the original damage.
                min = 0,
                max = 0,
            }
        },
    },

    [69] = {
        name = "Boner Bow",
        itemId = 38362,
        spellUnique = true,
        spellUniqueID = 142,
        attack = 107,
        chance = 1, -- 1/10 to 10%
        monsterLevel = 100,
        itemType = 3,
        implicit = {
            {
                id = 91, -- ranged damage
                min = 88,
                max = 99,
            },
            {
                id = 61, -- death damage
                min = 100,
                max = 136,
            },
        },
        attr = {
            {
                id = 68, -- added duality damage
                min = 60,
                max = 85,
            },
            {
                id = 198, -- Duality Penetration
                min = 10,
                max = 32,
            },
            {
                id = 230, -- Duality Spells
                min = 1,
                max = 12,
            },
            {
                id = 142, -- Spells [Death Wave], [Rotten Gas Shot], [Affliction Aura] and [Black Hole] dots duration reduced to 0.5 second.\nSpell [Curse] if the target dies, it applies the monsters debuff to enemies within a 6-tile radius instead of 1.
                min = 0,
                max = 0,
            }
        },
    },
    [70] = {
        name = "Vine Staff",
        itemId = 38346,
        spellUnique = true,
        spellUniqueID = 138,
        attack = 107,
        chance = 1, -- 1/10 to 10%
        monsterLevel = 100,
        itemType = 6,
        implicit = {
            {
                id = 90, -- magic damage
                min = 88,
                max = 99,
            },
            {
                id = 60, -- earth damage
                min = 100,
                max = 136,
            },
        },
        attr = {
            {
                id = 69, -- added elemental damage
                min = 60,
                max = 85,
            },
            {
                id = 122, -- Elemental Penetration
                min = 10,
                max = 32,
            },
            {
                id = 228, -- Elemental Spells
                min = 1,
                max = 12,
            },
            {
                id = 138, -- Toxity Spell [Venom Nova] and [Acid Bomb] extends the damage over time duration to 3.5 seconds, with the Cast on Crit Support rune effect.
                min = 0,
                max = 0,
            }
        },
    },
    [71] = {
        name = "Icy Dragon Blade",
        itemId = 7767,
        spellUnique = true,
        spellUniqueID = 135,
        attack = 107,
        chance = 1, -- 1/10 to 10%
        monsterLevel = 100,
        itemType = 1,
        implicit = {
            {
                id = 89, -- melee damage
                min = 88,
                max = 99,
            },
            {
                id = 58, -- ice damage
                min = 100,
                max = 136,
            },
        },
        attr = {
            {
                id = 69, -- added elemental damage
                min = 60,
                max = 85,
            },
            {
                id = 122, -- Elemental Penetration
                min = 10,
                max = 32,
            },
            {
                id = 228, -- elemental Spells
                min = 1,
                max = 12,
            },
            {
                id = 135, -- Icy Dragon Blink Spell [Shattering Dash] recasts automatically if the target is killed.\nSpell [Frozen Ground] cast Frozen Pulse and hits 1 extra time.\nSpell [Frozen Stomp] is supported by a Level 4 Expansion Rune.
                min = 0,
                max = 0,
            }
        },
    },
    [72] = {
        name = "Chill Pulse Bow",
        itemId = 25915,
        spellUnique = true,
        spellUniqueID = 125,
        attack = 107,
        chance = 1, -- 1/10 to 10%
        monsterLevel = 100,
        itemType = 3,
        implicit = {
            {
                id = 91, -- ranged damage
                min = 88,
                max = 99,
            },
            {
                id = 58, -- ice damage
                min = 100,
                max = 136,
            },
        },
        attr = {
            {
                id = 69, -- added Elemental damage
                min = 60,
                max = 85,
            },
            {
                id = 122, -- Elemental Penetration
                min = 10,
                max = 32,
            },
            {
                id = 228, -- Elemental Spells
                min = 1,
                max = 12,
            },
            {
                id = 125, -- Cold Pulse - Spell [Cold Snap] hits 1 extra time.\nSpell [Ice Surge] increase area of effect.\nSpell [Arctic Volley] add 5 projectiles.
                min = 0,
                max = 0,
            }
        },
    },
    [73] = {
        name = "Saint Magic Long Sword",
        itemId = 34651,
        spellUnique = true,
        spellUniqueID = 124,
        attack = 107,
        chance = 1, -- 1/10 to 10%
        monsterLevel = 100,
        itemType = 1,
        implicit = {
            {
                id = 89, -- melee damage
                min = 88,
                max = 99,
            },
            {
                id = 62, -- holy damage
                min = 100,
                max = 136,
            },
        },
        attr = {
            {
                id = 68, -- added duality damage
                min = 60,
                max = 85,
            },
            {
                id = 198, -- Duality Penetration
                min = 10,
                max = 32,
            },
            {
                id = 230, -- Duality Spells
                min = 1,
                max = 12,
            },
            {
                id = 124, -- Spell [Holy Dash] cast Holy Hammer and increase area of effect.\nSpell [Illumination] if the target dies under the effect of Illumination, you gain a buff. Each stack increases your Holy Damage by 5%. Maximum stacks: 50.\nSpell [Judgement Aura] every 0.5s gain Saint Buff stack. Each Stack add 1% more Holy Damage.
                min = 0,
                max = 0,
            }
        },
    },
    [74] = {
        name = "Unstable Chooper",
        itemId = 37898,
        spellUnique = true,
        spellUniqueID = 281,
        attack = 107,
        chance = 1, -- 1/10 to 10%
        monsterLevel = 100,
        itemType = 1,
        implicit = {
            {
                id = 89, -- melee damage
                min = 88,
                max = 99,
            },
            {
                id = 11, -- physical damage
                min = 100,
                max = 136,
            },
        },
        attr = {
            {
                id = 70, -- added physical damage
                min = 60,
                max = 85,
            },
            {
                id = 31, -- Physical Penetration
                min = 10,
                max = 32,
            },
            {
                id = 106, -- Physical Spells
                min = 1,
                max = 12,
            },
            {
                id = 281, -- Aura [Anger] is supported by a Level 4 Expansion Rune.\nSpell [Groundbreaker] increase area of effect and has a 1 second Cooldown.\nSpell [Seismic Wave] The wave effect is now around you and has been increased.
                min = 0,
                max = 0,
            }
        },
    },
    [75] = {
        name = "Unstable Crossbow",
        itemId = 37909,
        spellUnique = true,
        spellUniqueID = 282,
        attack = 107,
        chance = 1, -- 1/10 to 10%
        monsterLevel = 100,
        itemType = 3,
        implicit = {
            {
                id = 91, -- ranged damage
                min = 88,
                max = 99,
            },
            {
                id = 11, -- physical damage
                min = 100,
                max = 136,
            },
        },
        attr = {
            {
                id = 70, -- added physical damage
                min = 60,
                max = 85,
            },
            {
                id = 31, -- Physical Penetration
                min = 10,
                max = 32,
            },
            {
                id = 106, -- Physical Spells
                min = 1,
                max = 12,
            },
            {
                id = 282, -- Unstable Pierce - Spell [Rain of Arrows] increase area of effect and deal 25% more damage.\nSpell [Ricochet] deal area damage now.\nSpell [Split Arrow] add 5 projectiles.
                min = 0,
                max = 0,
            }
        },
    },
    [76] = {
        name = "Behemoth Steel Shield", -- counter attack
        itemId = 38576,
        chance = 1, -- New uniques
        monsterLevel = 100, -- od ktorego poziomu ma dropic
        itemType = 16,
        implicit = {
            {
                id = 8, -- block chance
                min = 20,
                max = 60,
            },
            {
                id = 96, -- Shield Damage
                min = 1,
                max = 55,
            },
            {
                id = 49, -- counterattack
                min = 25,
                max = 75,
            },
            {
                id = 1, -- Health
                min = 30,
                max = 500,
            },
        },
        attr = {
            {
                id = 11, -- physical damage
                min = 50,
                max = 75,
            },
            {
                id = 70, -- added physical damage
                min = 25,
                max = 35,
            },
            {
                id = 106, -- Physical Spells
                min = 1,
                max = 7,
            },
            {
                id = 283, -- Deform Spell [Dent] increase area of effect, has a 1 second Cooldow and deal 25% more total damage.\nSpell [Shield Bash] wave became longer.
                min = 0,
                max = 0,
            },
        },
    },

    [77] = {
        name = "Acid Crossbow",
        itemId = 38804,
        spellUnique = true,
        spellUniqueID = 284,
        attack = 107,
        chance = 1, -- 1/10 to 10%
        monsterLevel = 100,
        itemType = 3,
        implicit = {
            {
                id = 91, -- ranged damage
                min = 88,
                max = 99,
            },
            {
                id = 60, -- earth damage
                min = 100,
                max = 136,
            },
        },
        attr = {
            {
                id = 69, -- added elemental damage
                min = 60,
                max = 85,
            },
            {
                id = 122, -- Elemental Penetration
                min = 10,
                max = 32,
            },
            {
                id = 228, -- Elemental Spells
                min = 1,
                max = 12,
            },
            {
                id = 284, -- Spell [Plague Burst] increase area of effect and apply extra DoT stack.\nSpell [Venom Arrow Rain] increase area of effect and has a 1 second Cooldow./nSpell [Toxic Arrow] and [Bouncing Venom] add 5 projectiles and apply extra DoT stack.
                min = 0,
                max = 0,
            }
        },
    },
    [78] = {
        name = "Static Bow",
        itemId = 38815,
        spellUnique = true,
        spellUniqueID = 285,
        attack = 107,
        chance = 1, -- 1/10 to 10%
        monsterLevel = 100,
        itemType = 3,
        implicit = {
            {
                id = 91, -- ranged damage
                min = 88,
                max = 99,
            },
            {
                id = 59, -- lightning damage
                min = 100,
                max = 136,
            },
        },
        attr = {
            {
                id = 69, -- added elemental damage
                min = 60,
                max = 85,
            },
            {
                id = 122, -- Elemental Penetration
                min = 10,
                max = 32,
            },
            {
                id = 228, -- Elemental Spells
                min = 1,
                max = 12,
            },
            {
                id = 285, -- Spell [Lightning Arrow] and [Shockchain Arrow] deal area damage and add 5 projectiles/bounces.\nSpell [Lightning Barrage] shot 2 extra time.
                min = 0,
                max = 0,
            }
        },
    },
    [79] = {
        name = "Undead Crossbow",
        itemId = 38817,
        spellUnique = true,
        spellUniqueID = 286,
        attack = 107,
        chance = 1, -- 1/10 to 10%
        monsterLevel = 100,
        itemType = 3,
        implicit = {
            {
                id = 91, -- ranged damage
                min = 88,
                max = 99,
            },
            {
                id = 61, -- death damage
                min = 100,
                max = 136,
            },
        },
        attr = {
            {
                id = 68, -- added duality damage
                min = 60,
                max = 85,
            },
            {
                id = 198, -- Duality Penetration
                min = 10,
                max = 32,
            },
            {
                id = 230, -- Duality Spells
                min = 1,
                max = 12,
            },
            {
                id = 286, -- Spell [Oblivion] hit 2 extra time and has a 1 second Cooldow.\nSpell [Weakness Explosion] increases area of effect.\nSpell [Essence Drain] hit extra 5 targets.
                min = 0,
                max = 0,
            }
        },
    },
    [80] = {
        name = "Blessed Staff",
        itemId = 38814,
        spellUnique = true,
        spellUniqueID = 287,
        attack = 107,
        chance = 1, -- 1/10 to 10%
        monsterLevel = 100,
        itemType = 6,
        implicit = {
            {
                id = 90, -- magic damage
                min = 88,
                max = 99,
            },
            {
                id = 62, -- holy damage
                min = 100,
                max = 136,
            },
        },
        attr = {
            {
                id = 68, -- added duality damage
                min = 60,
                max = 85,
            },
            {
                id = 198, -- Duality Penetration
                min = 10,
                max = 32,
            },
            {
                id = 230, -- Duality Spells
                min = 1,
                max = 12,
            },
            {
                id = 287, -- Spell [Smite] applies Holy Weakness, which increases Holy Damage taken by 50%.\nSpell [Holy Scatter] hits all targets in range.\nSpell [Saint Cross] increases area of effect and damage by 50%."
                min = 0,
                max = 0,
            }
        },
    },
    [81] = {
        name = "Void Gloves",
        itemId = 38642,
        boss = "Void Stone",
        chance = 2.5, -- 1/10 to 10%
        monsterLevel = 1, -- od ktorego poziomu ma dropic
        maxMonsterLevel = 100,
        itemType = 15,
        implicit = {
            {
                id = 20, -- damage
                min = 1,
                max = 70,
            },
            {
                id = 171, -- added adaptive damage
                min = 25,
                max = 30,
            },
        },
        attr = {
            {
                id = 29, -- critical chance
                min = 1,
                max = 13,
            },
        },
    },
    [82] = {
        name = "Void Amulet",
        boss = "Void Stone",
        itemId = 38596,
        chance = 2.5, -- 1/10 to 10%
        monsterLevel = 1, -- od ktorego poziomu ma dropic
        maxMonsterLevel = 100,
        itemType = 10,
        implicit = {
            {
                id = 107, -- All Spells
                min = 1,
                max = 12,
            },
        },
        attr = {
            {
                id = 107, -- All Spells
                min = 1,
                max = 12,
            },
        },
    },
    [83] = {
        name = "Blooddrip Mace",
        itemId = 7431,
        spellUnique = true,
        spellUniqueID = 290,
        attack = 107,
        chance = 1, -- 1/10 to 10%
        monsterLevel = 100,
        itemType = 1,
        implicit = {
            {
                id = 89, -- melee damage
                min = 88,
                max = 99,
            },
            {
                id = 11, -- physical damage
                min = 100,
                max = 136,
            },
        },
        attr = {
            {
                id = 70, -- added physical damage
                min = 60,
                max = 85,
            },
            {
                id = 31, -- Physical Penetration
                min = 10,
                max = 32,
            },
            {
                id = 106, -- Physical Spells
                min = 1,
                max = 12,
            },
            {
                id = 290, -- Spell [Hemorrhage Nova] increase area of effect and deal 50% more total damage.\nSpell [Bloody Skulls] and [Rend] increase area of effect.\nSpell [Perforate] hits all targets in range.
                min = 0,
                max = 0,
            },
        },
    },
    [84] = {
        name = "Abysswalker Legs",
        abyss = true,
        itemId = 38775,
        chance = 1, -- 1/10 to 10%
        monsterLevel = 100,
        itemType = 12,
        implicit = {
            {
                id = 1, -- Health
                min = 1,
                max = 800,
            },
            {
                id = 2, -- Mana 
                min = 1,
                max = 800,
            },
            {
                id = 71, -- Energy Shield
                min = 1,
                max = 800,
            },
        },
        attr = {
            {
                id = 109, -- Health Percent
                min = 1,
                max = 18,
            },
            {
                id = 110, -- Mana Percent
                min = 1,
                max = 18,
            },
            {
                id = 72, -- Energy Shield Percent
                min = 1,
                max = 18,
            },
            {
                id = 237, -- Physical mitigation
                min = 1,
                max = 6,
            },
            {
                id = 238, -- Elemental mitigation
                min = 1,
                max = 6,
            },
            {
                id = 239, -- Duality mitigation
                min = 1,
                max = 6,
            },
        },
    },
    [85] = {
        name = "Abyssbound Ring", -- 
        abyss = true,
        itemId = 38580,
        chance = 1, -- New uniques
        monsterLevel = 100,
        itemType = 14,
        implicit = {
            {
                id = 20, -- Damage
                min = 5,
                max = 60,
            },
            {
                id = 107, -- All Spells
                min = 1,
                max = 10,
            },
        },
        attr = {
            {
                id = 56, -- Cooldown Reduction
                min = 1,
                max = 10,
            },
            {
                id = 30, -- Crit Damage
                min = 1,
                max = 20,
            },
            {
                id = 291, -- Penetration
                min = 1,
                max = 20,
            },
        },
    },
}

US_PAS = {
    
}