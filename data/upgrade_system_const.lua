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
}

US_PAS = {
    
}