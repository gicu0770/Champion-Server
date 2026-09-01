US_ENCHANTMENTS = {
    [1] = {
        name = "Health",
        desc = "Increase your Max Health points.",
        category = 2,
        percent = false,
        percentage = false,
        combatType = US_TYPES.CONDITION,
        condition = CONDITION_ATTRIBUTES,
        param = CONDITION_PARAM_STAT_MAXHITPOINTS,
        itemType = US_ITEM_TYPES.ALL 
    },
    [2] = {
        name = "Mana",
        desc = "Increase your Max Mana points.",
        category = 2,
        percent = false,
        percentage = false,
        combatType = US_TYPES.CONDITION,
        condition = CONDITION_ATTRIBUTES,
        param = CONDITION_PARAM_STAT_MAXMANAPOINTS,
        itemType = US_ITEM_TYPES.ALL
    },
    [3] = {
        name = "Energy Shield",
        desc = "Increase your Max Energy Shield points.",
        category = 2,
        percent = false,
        percentage = false,
        combatType = US_TYPES.CONDITION,
        condition = CONDITION_ATTRIBUTES,
        param = CONDITION_PARAM_STAT_MAXENERGYSHIELD,
        itemType = US_ITEM_TYPES.ALL
    },
    [4] = {
        name = "Health Regeneration",
        desc = "You receive Health every second.",
        category = 3,
        percent = false,
        itemType = US_ITEM_TYPES.ALL
    },
    [5] = {
        name = "Mana Regeneration",
        desc = "You receive Mana every second.",
        category = 3,
        percent = false,
        itemType = US_ITEM_TYPES.ALL
    },
    [6] = {
        name = "Physical Attack",
        desc = "Increases physical damage dealt.",
        category = 1,
        percent = false,
        combatDamage = COMBAT_PHYSICALDAMAGE,
        itemType = US_ITEM_TYPES.ALL
    },
    [7] = {
        name = "Magic Attack",
        desc = "Increases magic damage dealt.",
        category = 1,
        percent = false,
        combatDamage = COMBAT_ENERGYDAMAGE + COMBAT_EARTHDAMAGE + COMBAT_FIREDAMAGE + COMBAT_ICEDAMAGE + COMBAT_HOLYDAMAGE + COMBAT_DEATHDAMAGE,
        itemType = US_ITEM_TYPES.ALL
    },
    [8] = {
        name = "Physical Defense",
        desc = "Reduces damage taken from physical damage.",
        category = 2,
        percent = false,
        combatDamage = COMBAT_PHYSICALDAMAGE,    
        itemType = US_ITEM_TYPES.ALL
    },
    [9] = {
        name = "Magic Defense",
        desc = "Reduces damage taken from magic damage.",
        category = 2,
        percent = false,
        combatDamage = COMBAT_ENERGYDAMAGE + COMBAT_EARTHDAMAGE + COMBAT_FIREDAMAGE + COMBAT_ICEDAMAGE + COMBAT_HOLYDAMAGE + COMBAT_DEATHDAMAGE,
        itemType = US_ITEM_TYPES.ALL
    },
    [10] = {
        name = "Movement Speed",
        desc = "Increased your Movement Speed.",
        category = 2,
        percent = true,
        combatType = US_TYPES.CONDITION,
        condition = CONDITION_HASTE,
        itemType = US_ITEM_TYPES.ALL
    },
    [11] = {
        name = "Attack Speed",
        desc = "Increase attack speed of basic attacks.",
        category = 1,
        percent = true,
        itemType = US_ITEM_TYPES.ALL
    },
    [12] = {
        name = "Critical Chance",
        desc = "Increases your Critical Chance.",
        category = 1,
        percent = true,
        combatType = US_TYPES.CONDITION,
        condition = CONDITION_ATTRIBUTES,
        param = CONDITION_PARAM_SPECIALSKILL_CRITICALHITCHANCE,
        itemType = US_ITEM_TYPES.RING + US_ITEM_TYPES.WEAPON_ANY + US_ITEM_TYPES.RELICT_OFFENSIVE + US_ITEM_TYPES.GLOVES + US_ITEM_TYPES.NECKLACE
    },
    [13] = {
        name = "Critical Damage",
        desc = "Increases your Critical Damage.",
        category = 1,
        percent = true,
        combatType = US_TYPES.CONDITION,
        condition = CONDITION_ATTRIBUTES,
        param = CONDITION_PARAM_SPECIALSKILL_CRITICALHITAMOUNT,
        itemType = US_ITEM_TYPES.WEAPON_ANY + US_ITEM_TYPES.RELICT_OFFENSIVE + US_ITEM_TYPES.GLOVES
    },
    [14] = {
        name = "Physical Penetration",
        desc = "Penetration is a property of hits that reduces the target's effective resistance. (Physical) ",
        category = 1,
        percent = false,
        combatDamage = COMBAT_PHYSICALDAMAGE,
        itemType = US_ITEM_TYPES.ALL
    },
    [15] = {
        name = "Magic Penetration",
        desc = "Penetration is a property of hits that reduces the target's effective resistance. (Magic) ",
        category = 1,
        percent = false,
        combatDamage = COMBAT_PHYSICALDAMAGE,
        itemType = US_ITEM_TYPES.ALL
    },
    [16] = {
        name = "Cooldown Reduction",
        desc = "Reduces the time between spells used.",
        category = 3,
        percent = true,
        itemType = US_ITEM_TYPES.ALL
    },
    [17] = {
        name = "Physical Lifesteal",
        desc = "A percentage of physical damage dealt by spells and autoattacks is returned to the caster as increased health.",
        category = 3,
        percent = true,
        itemType = US_ITEM_TYPES.ALL
    },
    [18] = {
        name = "Magic Lifesteal",
        desc = "A percentage of damage dealt by magic damage is returned to the caster as increased health.",
        category = 3,
        percent = true,
        itemType = US_ITEM_TYPES.ALL
    },
    [19] = {
        name = "Resilience",
        desc = "Redukuje czas CC.",
        category = 3,
        percent = true,
        itemType = US_ITEM_TYPES.ALL
    },
    [20] = {
        name = "Energy Shield Regeneration",
        desc = "You receive Enrgy Shield every second.",
        category = 3,
        percent = false,
        itemType = US_ITEM_TYPES.ALL
    },
    [21] = {
        name = "Movement Speed",
        desc = "Increased your Movement Speed.",
        category = 3,
        percent = false,
        itemType = US_ITEM_TYPES.ALL
    },
    [22] = {
        name = "Concussive Blast",
        desc = "After the next Basic Attack, deal 100(+7% Total HP) Magic Damage to nearby enemies. Cooldown: 15s.",
        category = 1,
        percent = false,
        noValue = true,
        unique = true,
        itemType = US_ITEM_TYPES.ALL
    },
    [23] = {
        name = "Brave Smite",
        desc = "Dealing skill damage to an enemy recovers 3% Max HP. Cooldown: 9 seconds.",
        category = 1,
        percent = false,
        noValue = true,
        unique = true,
        itemType = US_ITEM_TYPES.ALL
    },
    [24] = {
        name = "Focusing Mark",
        desc = "After damaging an enemy deal 10% more damage to them and gain 10% Movement Speed. Duration: 3 seconds. Cooldown: 4 seconds.",
        category = 1,
        percent = false,
        noValue = true,
        unique = true,
        itemType = US_ITEM_TYPES.ALL
    },
    [25] = {
        name = "Weakness Finder",
        desc = "Basic Attacks slow enemies by 50% and reduce their Attack Speed by 30%. Duration: 1 second. Cooldown: 10 seconds (each Basic Attack reduces it bv 1 seconds, down to 3 seconds).",
        category = 1,
        percent = false,
        noValue = true,
        unique = true,
        itemType = US_ITEM_TYPES.ALL
    },
    [26] = {
        name = "Merciless",
        desc = "Grants 20% increased damage against targets below 40% health.",
        category = 1,
        percent = false,
        noValue = true,
        unique = true,
        itemType = US_ITEM_TYPES.ALL
    },
    [27] = {
        name = "Gigantism",
        desc = "Each 500 Hp increase you damage by 2%.",
        category = 1,
        percent = false,
        noValue = true,
        unique = true,
        itemType = US_ITEM_TYPES.ALL
    },
    [28] = {
        name = "Glass Cannon",
        desc = "Each 1% of missing HP increase you damage by 1%.",
        category = 1,
        percent = false,
        noValue = true,
        unique = true,
        itemType = US_ITEM_TYPES.ALL
    },
    [29] = {
        name = "Unmake",
        desc = "Nearby enemies within 4 tiles have their Magic Defense reduced by 30%.",
        category = 1,
        percent = true,
        noValue = true,
        unique = true,
        itemType = US_ITEM_TYPES.ALL
    },
    [30] = {
        name = "Magical Opus",
        desc = "Increase your magic attack by 30%.",
        category = 1,
        percent = true,
        noValue = true,
        unique = true,
        itemType = US_ITEM_TYPES.ALL
    },
    [31] = {
        name = "Carve & Fervor",
        desc = "Physical hits reduce enemy Physical Defense by 6% (up to 30%) and grant +20 Movement Speed.",
        category = 1,
        percent = true,
        noValue = true,
        unique = true,
        itemType = US_ITEM_TYPES.ALL
    },
    [32] = {
        name = "Ichor Shield",
        desc = "Excess healing from Physical Lifesteal at full HP is converted into a shield (up to 10% Max HP).",
        category = 1,
        percent = true,
        noValue = true,
        unique = true,
        itemType = US_ITEM_TYPES.ALL
    },
    [33] = {
        name = "Warmog's Heart",
        desc = "Regenerates 3% of your Maximum Health every second.",
        category = 1,
        percent = true,
        noValue = true,
        unique = true,
        itemType = US_ITEM_TYPES.ALL
    },
    [34] = {
        name = "Spellblade",
        desc = "After using an ability, your next basic attack deals 200% base AD bonus physical damage on-hit (1.5s CD).",
        category = 1,
        percent = true,
        noValue = true,
        unique = true,
        itemType = US_ITEM_TYPES.ALL
    },
    [35] = {
        name = "Quicken",
        desc = "Basic attacks on-hit grant +20 bonus Movement Speed for 2 seconds.",
        category = 1,
        percent = true,
        noValue = true,
        unique = true,
        itemType = US_ITEM_TYPES.ALL
    },
    [36] = {
        name = "Fray",
        desc = "Basic attacks deal bonus magic damage on-hit.",
        category = 1,
        percent = false,
        noValue = false,
        unique = true,
        itemType = US_ITEM_TYPES.ALL
    },
    [37] = {
        name = "Icathian Bite",
        desc = "Basic attacks deal 15 (+15% Magic Attack) bonus magic damage on-hit.",
        category = 1,
        percent = false,
        noValue = false,
        unique = true,
        itemType = US_ITEM_TYPES.ALL
    },
    [38] = {
        name = "Mist's Edge",
        desc = "Basic attacks deal bonus physical damage equal to (9% melee / 6% ranged) of the target's current health on-hit.",
        category = 1,
        percent = false,
        noValue = false,
        unique = true,
        itemType = US_ITEM_TYPES.ALL
    },
    [39] = {
        name = "Thorns",
        desc = "When struck by a basic attack, deal 20 (+10% Physical Defense) magic damage to the attacker.",
        category = 2,
        percent = false,
        noValue = false,
        unique = true,
        itemType = US_ITEM_TYPES.ALL
    },
    [40] = {
        name = "Immolate",
        desc = "When taking damage, deal 20 (+1% Max HP) magic damage to nearby enemies.",
        category = 2,
        percent = false,
        noValue = false,
        unique = true,
        itemType = US_ITEM_TYPES.ALL
    },
    [41] = {
        name = "Plating",
        desc = "Reduces all incoming basic attack damage by 10%.",
        category = 2,
        percent = false,
        noValue = false,
        unique = true,
        itemType = US_ITEM_TYPES.ALL
    },
    [42] = {
        name = "Fleetfooted",
        desc = "Increases Movement Speed and grants Slow Resistance.",
        category = 1,
        percent = false,
        noValue = false,
        unique = true,
        itemType = US_ITEM_TYPES.ALL
    },
    [43] = {
        name = "Boundless Vitality",
        desc = "Increases all healing, shielding received, and health regeneration by 25%.",
        category = 2,
        percent = true,
        noValue = false,
        unique = true,
        itemType = US_ITEM_TYPES.ALL
    },
    [44] = {
        name = "Torment",
        desc = "Abilities and attacks burn enemies for 1% of their Max HP per second for 4 seconds.",
        category = 1,
        percent = false,
        noValue = false,
        unique = true,
        itemType = US_ITEM_TYPES.ALL
    },
    [45] = {
        name = "Time Stop",
        desc = "Upon falling below 30% HP, gain Immortality for 3 seconds (120s cooldown).",
        category = 2,
        percent = false,
        noValue = false,
        unique = true,
        itemType = US_ITEM_TYPES.ALL
    },
    [46] = {
        name = "Annul",
        desc = "Grants a Spell Shield that blocks the next hostile ability (40s cooldown).",
        category = 2,
        percent = false,
        noValue = false,
        unique = true,
        itemType = US_ITEM_TYPES.ALL
    },
    [47] = {
        name = "Grievous Wounds",
        desc = "Physical damage inflicts Grievous Wounds for 3s, reducing healing received by 40%.",
        category = 1,
        percent = false,
        noValue = false,
        unique = true,
        itemType = US_ITEM_TYPES.ALL
    },
    [48] = {
        name = "Cursed Touch",
        desc = "Magic damage inflicts Grievous Wounds for 3s, reducing healing received by 40%.",
        category = 1,
        percent = false,
        noValue = false,
        unique = true,
        itemType = US_ITEM_TYPES.ALL
    },
}

REDUCTION_ATTR_VALUES = {
[289] = {
    [1] = {1, 1}, [2] = {2, 2}, [3] = {3, 3}, [4] = {4, 4}, [5] = {5, 5}, [6] = {7, 7}, [7] = {10, 10}
}, -- "Void Blessing"
}
