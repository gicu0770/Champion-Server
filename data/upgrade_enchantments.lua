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
        itemType = US_ITEM_TYPES.HELMET + US_ITEM_TYPES.ARMOR + US_ITEM_TYPES.LEGS + US_ITEM_TYPES.BOOTS + US_ITEM_TYPES.SHIELD + US_ITEM_TYPES.GLOVES + US_ITEM_TYPES.POTION + US_ITEM_TYPES.RELICT_DEFFENSIVE + US_ITEM_TYPES.RELICT_UTILITY
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
        itemType = US_ITEM_TYPES.HELMET + US_ITEM_TYPES.ARMOR + US_ITEM_TYPES.LEGS + US_ITEM_TYPES.BOOTS + US_ITEM_TYPES.SHIELD + US_ITEM_TYPES.GLOVES + US_ITEM_TYPES.POTION + US_ITEM_TYPES.RELICT_DEFFENSIVE + US_ITEM_TYPES.RELICT_UTILITY
    },
    [3] = {
        name = "Intelligence",
        desc = "Intelligence adds 0.25% Energy Shield per point.",
        category = 1,
        percent = false,
        combatType = US_TYPES.CONDITION,
        condition = CONDITION_ATTRIBUTES,
        param = CONDITION_PARAM_SKILL_FISHING,
        itemType = US_ITEM_TYPES.ALL,
        disableItemTypes = US_ITEM_TYPES.RELICT_DEFFENSIVE + US_ITEM_TYPES.RELICT_UTILITY + US_ITEM_TYPES.RELICT_ANY + US_ITEM_TYPES.RELICT_BOSS + US_ITEM_TYPES.RELICT_STRONGBOX + US_ITEM_TYPES.RELICT_GOBLIN + US_ITEM_TYPES.RELICT_CHAMPION
    },
    [4] = {
        name = "Strength",
        desc = "Strength adds 0.25% Health per point.",
        category = 1,
        percent = false,
        combatType = US_TYPES.CONDITION,
        condition = CONDITION_ATTRIBUTES,
        param = CONDITION_PARAM_SKILL_MELEE,
        itemType = US_ITEM_TYPES.ALL,
        disableItemTypes = US_ITEM_TYPES.RELICT_DEFFENSIVE + US_ITEM_TYPES.RELICT_UTILITY + US_ITEM_TYPES.RELICT_ANY + US_ITEM_TYPES.RELICT_BOSS + US_ITEM_TYPES.RELICT_STRONGBOX + US_ITEM_TYPES.RELICT_GOBLIN + US_ITEM_TYPES.RELICT_CHAMPION
    },
    [5] = {
        name = "Dexterity",
        desc = "Every 10 Dexterity grants 1% Dodge Chance.",
        category = 1,
        percent = false,
        combatType = US_TYPES.CONDITION,
        condition = CONDITION_ATTRIBUTES,
        param = CONDITION_PARAM_SKILL_DISTANCE,
        itemType = US_ITEM_TYPES.ALL,
        disableItemTypes = US_ITEM_TYPES.RELICT_DEFFENSIVE + US_ITEM_TYPES.RELICT_UTILITY + US_ITEM_TYPES.RELICT_ANY + US_ITEM_TYPES.RELICT_BOSS + US_ITEM_TYPES.RELICT_STRONGBOX + US_ITEM_TYPES.RELICT_GOBLIN + US_ITEM_TYPES.RELICT_CHAMPION
    },
    [6] = {
        name = "All Attributes",
        desc = "Increase Strength, Intelligence, Dexterity, Vitality and Mastery.",
        category = 1,
        percent = false,
        chance = 5,
        minLevel = 2000,
        itemType = US_ITEM_TYPES.RING + US_ITEM_TYPES.NECKLACE + US_ITEM_TYPES.RELICT_GOBLIN + US_ITEM_TYPES.RELICT_BOSS + US_ITEM_TYPES.RELICT_STRONGBOX + US_ITEM_TYPES.RELICT_CHAMPION + US_ITEM_TYPES.RELICT_VOIDSTONE
    },
    [7] = {
        name = "Vitality",
        desc = "Vitality adds 5 Health, Energy Shield and 2 Mana per point.",
        category = 2,
        percent = false,
        combatType = US_TYPES.CONDITION,
        condition = CONDITION_ATTRIBUTES,
        param = CONDITION_PARAM_SKILL_SHIELD,
        itemType = US_ITEM_TYPES.HELMET + US_ITEM_TYPES.ARMOR + US_ITEM_TYPES.LEGS + US_ITEM_TYPES.BOOTS + US_ITEM_TYPES.SHIELD + US_ITEM_TYPES.RELICT_DEFFENSIVE,
        disableItemTypes = US_ITEM_TYPES.RELICT_BOSS + US_ITEM_TYPES.RELICT_STRONGBOX + US_ITEM_TYPES.RELICT_GOBLIN + US_ITEM_TYPES.RELICT_CHAMPION
    },
    [8] = { -- SPECIAL
        name = "Block Chance",
        desc = "You have a chance to reduced Damage taken by 50%. Physical, Duality and Elemental Damages.",
        category = 2,
        minLevel = 2000,
        percent = true,
    },
    [9] = {
        name = "Dodge",
        desc = "You have a chance to dodge enemy physical attacks.",
        category = 2,
        percent = true,
        itemType = US_ITEM_TYPES.BOOTS + US_ITEM_TYPES.RING + US_ITEM_TYPES.LEGS
    },
    [10] = {
        name = "Experience",
        desc = "Increases experience received from monsters.",
        category = 4,
        percent = true,
        itemType = US_ITEM_TYPES.BOOTS + US_ITEM_TYPES.POTION
    },
    [11] = {
        name = "Physical Damage",
        desc = "Increases physical damage dealt.",
        category = 1,
        percent = true,
        combatDamage = COMBAT_PHYSICALDAMAGE,
        itemType = US_ITEM_TYPES.WEAPON_ANY + US_ITEM_TYPES.HELMET + US_ITEM_TYPES.GLOVES + US_ITEM_TYPES.SHIELD + US_ITEM_TYPES.RELICT_OFFENSIVE + US_ITEM_TYPES.RELICT_GOBLIN + US_ITEM_TYPES.RELICT_BOSS + US_ITEM_TYPES.RELICT_STRONGBOX + US_ITEM_TYPES.RELICT_CHAMPION + US_ITEM_TYPES.RELICT_VOIDSTONE
    },
    [12] = {
        name = "Elemental Damage",
        desc = "Increases damage dealt by all elements. (Fire, Ice, Lightning, Earth)",
        category = 1,
        percent = true,
        combatDamage = COMBAT_ENERGYDAMAGE + COMBAT_EARTHDAMAGE + COMBAT_FIREDAMAGE + COMBAT_ICEDAMAGE,
        itemType = US_ITEM_TYPES.WEAPON_ANY + US_ITEM_TYPES.HELMET + US_ITEM_TYPES.GLOVES + US_ITEM_TYPES.SHIELD + US_ITEM_TYPES.RELICT_OFFENSIVE + US_ITEM_TYPES.RELICT_GOBLIN + US_ITEM_TYPES.RELICT_BOSS + US_ITEM_TYPES.RELICT_STRONGBOX + US_ITEM_TYPES.RELICT_CHAMPION + US_ITEM_TYPES.RELICT_VOIDSTONE
    },
    [13] = {
        name = "Physical Protection",
        desc = "Reduces damage taken from physical damage.",
        category = 2,
        percent = true,
        combatDamage = COMBAT_PHYSICALDAMAGE,    
        itemType = US_ITEM_TYPES.ARMOR + US_ITEM_TYPES.SHIELD + US_ITEM_TYPES.BOOTS + US_ITEM_TYPES.HELMET + US_ITEM_TYPES.LEGS + US_ITEM_TYPES.RELICT_DEFFENSIVE
    },
    [14] = {
        name = "Elemental Protection",
        desc = "Reduces damage taken from all elements damage. (Fire, Ice, Energy, Earth)",
        category = 2,
        percent = true,
        combatDamage = COMBAT_ENERGYDAMAGE + COMBAT_EARTHDAMAGE + COMBAT_FIREDAMAGE + COMBAT_ICEDAMAGE,
        itemType = US_ITEM_TYPES.ARMOR + US_ITEM_TYPES.SHIELD + US_ITEM_TYPES.BOOTS + US_ITEM_TYPES.HELMET + US_ITEM_TYPES.LEGS + US_ITEM_TYPES.RELICT_DEFFENSIVE
    },
    [15] = { -- REMOVED
        name = "Explosion on Kill",
        desc = "After killing a monster, it causes a mass explosion that deals damage equal to a percentage of the monster HP.",
        category = 1,
        percent = true,
        minLevel = 2000,
        execute = function(player, value, center, target)
            local damage = math.ceil(target:getMaxHealth() * (10 / 100))
            exoriEffect(center, CONST_ME_FIREAREA)
            local specs = Game.getSpectators(center, false, false, 1, 1, 1, 1)
            if #specs > 0 then
                for i = 1, #specs do
                    if specs[i]:isMonster() then
                        doTargetCombatHealth(player:getId(), specs[i]:getId(), COMBAT_FIREDAMAGE, damage, damage, CONST_ME_NONE, ORIGIN_CONDITION)
                    end
                end
            end
        end,
        itemType = US_ITEM_TYPES.WEAPON_ANY
    },
    [16] = {
        name = "Recovery Effectiveness",
        desc = "Increases Healing and Mana restoration from potions. (Spells and Potions)",
        category = 3,
        percent = true,
        itemType = US_ITEM_TYPES.POTION + US_ITEM_TYPES.RELICT_UTILITY
    },
    [17] = {
        name = "Gold",
        desc = "Increases the amount of Gold from monsters.",
        category = 4,
        percent = true,
        itemType = US_ITEM_TYPES.BOOTS + US_ITEM_TYPES.RING + US_ITEM_TYPES.POTION
    },
    [18] = {
        name = "Spell Damage",
        desc = "Increases Damage from Spells attacks",
        category = 1,
        percent = true,
        itemType = US_ITEM_TYPES.RING + US_ITEM_TYPES.NECKLACE + US_ITEM_TYPES.WEAPON_ANY + US_ITEM_TYPES.HELMET
    },
    [19] = {
        name = "Basic Damage",
        desc = "Increases damage from basic attacks. [Auto attacks/hand attacks]",
        category = 1,
        percent = true,
        itemType = US_ITEM_TYPES.RING + US_ITEM_TYPES.NECKLACE + US_ITEM_TYPES.WEAPON_ANY + US_ITEM_TYPES.HELMET
    },
    [20] = { -- SPECIAL
        name = "Damage",
        desc = "Increase damage.",
        category = 1,
        percent = true,
        minLevel = 2000,
    },
    [21] = {
        name = "Bleed Chance",
        desc = "Your attacks can apply the Bleeding effect, which deals damage over 5 seconds.",
        category = 1,
        percent = true,
        itemType = US_ITEM_TYPES.GLOVES + US_ITEM_TYPES.WEAPON_ANY + US_ITEM_TYPES.RELICT_OFFENSIVE + US_ITEM_TYPES.RELICT_UTILITY + US_ITEM_TYPES.HELMET + US_ITEM_TYPES.NECKLACE + US_ITEM_TYPES.RING
    },
    [22] = { -- SPECIAL
        name = "Damage Reduction",
        desc = "Reduces damage taken.",
        category = 2,
        percent = true,
        minLevel = 2000,
    },
    [23] = {
        name = "Health Regeneration",
        desc = "You receive Health every second.",
        category = 3,
        percent = false,
        itemType = US_ITEM_TYPES.ARMOR + US_ITEM_TYPES.SHIELD + US_ITEM_TYPES.LEGS + US_ITEM_TYPES.POTION + US_ITEM_TYPES.RELICT_UTILITY
    },
    [24] = {
        name = "Mana Regeneration",
        desc = "You receive Mana every second.",
        category = 3,
        percent = false,
        itemType = US_ITEM_TYPES.RING + US_ITEM_TYPES.NECKLACE + US_ITEM_TYPES.POTION + US_ITEM_TYPES.RELICT_UTILITY
    },
    [25] = { -- SPECIAL FOR UNIQUE
        name = "Executor",
        desc = "If monster have below 10% of Health kill instanly. Boss/Titan 5%.",
        category = 1,
        percent = true,
        noValue = true,
        minLevel = 2000,
    },
    [26] = {
        name = "Energy Shield Regeneration",
        desc = "You receive Energy shield every second.",
        category = 3,
        percent = false,
        itemType = US_ITEM_TYPES.HELMET + US_ITEM_TYPES.SHIELD + US_ITEM_TYPES.NECKLACE + US_ITEM_TYPES.POTION + US_ITEM_TYPES.RELICT_UTILITY
    },
    [27] = {
        name = "Movement Speed",
        desc = "Increased your Movement Speed.",
        category = 2,
        percent = true,
        combatType = US_TYPES.CONDITION,
        condition = CONDITION_HASTE,
        itemType = US_ITEM_TYPES.BOOTS + US_ITEM_TYPES.POTION + US_ITEM_TYPES.RELICT_UTILITY + US_ITEM_TYPES.LEGS
    },
    [28] = {
        name = "Ignite Chance",
        desc = "Your Fire Damage can apply the Ignite effect, which deals damage over 5 seconds.",
        category = 1,
        percent = true,
        itemType = US_ITEM_TYPES.GLOVES + US_ITEM_TYPES.WEAPON_ANY + US_ITEM_TYPES.RELICT_OFFENSIVE + US_ITEM_TYPES.RELICT_UTILITY + US_ITEM_TYPES.HELMET + US_ITEM_TYPES.NECKLACE + US_ITEM_TYPES.RING
    },
    [29] = {
        name = "Critical Chance",
        desc = "Increases your Critical Chance.",
        category = 1,
        percent = true,
        combatType = US_TYPES.CONDITION,
        condition = CONDITION_ATTRIBUTES,
        param = CONDITION_PARAM_SPECIALSKILL_CRITICALHITCHANCE,
        itemType = US_ITEM_TYPES.RING + US_ITEM_TYPES.WEAPON_ANY + US_ITEM_TYPES.RELICT_OFFENSIVE + US_ITEM_TYPES.GLOVES + US_ITEM_TYPES.NECKLACE
    },
    [30] = {
        name = "Critical Damage",
        desc = "Increases your Critical Damage.",
        category = 1,
        percent = true,
        combatType = US_TYPES.CONDITION,
        condition = CONDITION_ATTRIBUTES,
        param = CONDITION_PARAM_SPECIALSKILL_CRITICALHITAMOUNT,
        itemType = US_ITEM_TYPES.WEAPON_ANY + US_ITEM_TYPES.RELICT_OFFENSIVE + US_ITEM_TYPES.GLOVES
    },
    [31] = {
        name = "Physical Penetration",
        desc = "Penetration is a property of hits that reduces the target's effective resistance. (Physical) ",
        category = 1,
        percent = true,
        combatDamage = COMBAT_PHYSICALDAMAGE,
        itemType = US_ITEM_TYPES.WEAPON_ANY
    },
    [32] = {
        name = "Poison Chance",
        desc = "Your Earth Damage can apply the Poison effect, which deals damage over 5 seconds.",
        category = 1,
        percent = true,
        itemType = US_ITEM_TYPES.GLOVES + US_ITEM_TYPES.WEAPON_ANY + US_ITEM_TYPES.RELICT_OFFENSIVE + US_ITEM_TYPES.RELICT_UTILITY + US_ITEM_TYPES.HELMET + US_ITEM_TYPES.NECKLACE + US_ITEM_TYPES.RING
    },
    [33] = { -- Wylaczony z normalnego losowania
        name = "Boss Damage",
        desc = "Increases Damage dealt to Boss.",
        category = 1,
        percent = true,
        minLevel = 2000,
        itemType = US_ITEM_TYPES.RING + US_ITEM_TYPES.NECKLACE + US_ITEM_TYPES.WEAPON_ANY
    },
    [34] = {
        name = "Mastery",
        desc = "Increase your Damage. Each Mastery increase your 1% Damage and 0.1% Damage Reduction.",
        category = 1,
        percent = false,
        chance = 5,
        combatType = US_TYPES.CONDITION,
        condition = CONDITION_ATTRIBUTES,
        param = CONDITION_PARAM_STAT_MAGICPOINTS,
        itemType = US_ITEM_TYPES.RING + US_ITEM_TYPES.NECKLACE + US_ITEM_TYPES.GLOVES + US_ITEM_TYPES.LEGS
    },
    [35] = {
        name = "Spell Avoid",
        desc = "You have a chance to Avoid spell.",
        category = 2,
        percent = true,
        itemType = US_ITEM_TYPES.HELMET + US_ITEM_TYPES.RING + US_ITEM_TYPES.SHIELD
    },
    [36] = { -- Wylaczony z normalnego losowania
        name = "Elite Damage",
        desc = "Increases Damage dealt to Elite Monsters.",
        category = 1,
        percent = true,
        minLevel = 2000,
        itemType = US_ITEM_TYPES.RING + US_ITEM_TYPES.NECKLACE + US_ITEM_TYPES.GLOVES
    },
    [37] = {
        name = "Chill Chance",
        desc = "Your Ice damage have chance Slow target by 30% for 2 seconds.",
        category = 1,
        percent = true,
        itemType = US_ITEM_TYPES.GLOVES + US_ITEM_TYPES.WEAPON_ANY + US_ITEM_TYPES.RELICT_OFFENSIVE + US_ITEM_TYPES.RELICT_UTILITY + US_ITEM_TYPES.HELMET + US_ITEM_TYPES.NECKLACE + US_ITEM_TYPES.RING
    },
    [38] = { -- SPECIAL
        name = "Damage Buff",
        desc = "On kill, you receive a buff that increases your Damage for the next 10 seconds.",
        category = 1,
        percent = true,
        minLevel = 2000,
        noQuality = true,
        execute = function(player, value)
            player:addBuff(BUFF_DAMAGE_ATTRIBUTES)
        end,
    },
    [39] = { -- BLOCK UNIQUE
        name = "Critical Chance Buff",
        desc = "On kill, you receive a buff that increases your Critical Chance for the next 10 seconds.",
        category = 1,
        percent = true,
        minLevel = 2000,
        buff = true,
        noQuality = true,
        execute = function(player, value)
            CriticalDamagecondition = Condition(CONDITION_ATTRIBUTES)
            CriticalDamagecondition:setParameter(CONDITION_PARAM_SPECIALSKILL_CRITICALHITCHANCE, 5)
            CriticalDamagecondition:setParameter(CONDITION_PARAM_TICKS, 30000)
            CriticalDamagecondition:setParameter(CONDITION_PARAM_SUBID, 3247)
            player:addCondition(CriticalDamagecondition)
            player:addBuff(BUFF_CRITICAL)
        end,
    },
    [40] = { -- BLOCK UNIQUE
        name = "Critical Damage Buff",
        desc = "On kill, you receive a buff that increases your Critical Damage for the next 10 seconds.",
        category = 1,
        percent = true,
        minLevel = 2000,
        buff = true,
        noQuality = true,
        execute = function(player, value)
            CriticalDamagecondition = Condition(CONDITION_ATTRIBUTES)
            CriticalDamagecondition:setParameter(CONDITION_PARAM_SPECIALSKILL_CRITICALHITAMOUNT, 30)
            CriticalDamagecondition:setParameter(CONDITION_PARAM_TICKS, 30000)
            CriticalDamagecondition:setParameter(CONDITION_PARAM_SUBID, 3249)
            player:addCondition(CriticalDamagecondition)
            player:addBuff(BUFF_CRITICAL_DAMAGE)
        end,
    },
    [41] = {
        name = "Shock Chance",
        desc = "Your Lightning Damage can apply the Shock effect, which makes the target take 20% more damage for 4 seconds. Deal Lightning Damage over time.",
        category = 1,
        percent = true,
        itemType = US_ITEM_TYPES.GLOVES + US_ITEM_TYPES.WEAPON_ANY + US_ITEM_TYPES.RELICT_OFFENSIVE + US_ITEM_TYPES.RELICT_UTILITY + US_ITEM_TYPES.HELMET + US_ITEM_TYPES.NECKLACE + US_ITEM_TYPES.RING
    },
    [42] = {
        name = "Harvest Chance",
        desc = "When a cursed target dies, it restores 1% of your HP and Mana. Deal Death Damage over time.",
        category = 1,
        percent = true,
        itemType = US_ITEM_TYPES.GLOVES + US_ITEM_TYPES.WEAPON_ANY + US_ITEM_TYPES.RELICT_OFFENSIVE + US_ITEM_TYPES.RELICT_UTILITY + US_ITEM_TYPES.HELMET + US_ITEM_TYPES.NECKLACE + US_ITEM_TYPES.RING
    },
    [43] = { -- REMOVED
        name = "Force",
        desc = "Each force point increase physical damage and spell damage by 1%",
        category = 1,
        percent = false,
        minLevel = 2000,
        combatDamage = COMBAT_PHYSICALDAMAGE,
        itemType = US_ITEM_TYPES.WEAPON_ANY + US_ITEM_TYPES.HELMET + US_ITEM_TYPES.LEGS + US_ITEM_TYPES.GLOVES
    },
    [44] = { -- REMOVED
        name = "Sorcery",
        desc = "Each Sorcer point increase Elemental Damage and Spell damage by 1%",
        category = 1,
        percent = false,
        minLevel = 2000,
        combatDamage = COMBAT_ENERGYDAMAGE + COMBAT_EARTHDAMAGE + COMBAT_FIREDAMAGE + COMBAT_ICEDAMAGE + COMBAT_HOLYDAMAGE + COMBAT_DEATHDAMAGE,
        itemSlot = {"US_ITEM_TYPES.WEAPON_CLUB", "US_ITEM_TYPES.WEAPON_SWORD", "US_ITEM_TYPES.WEAPON_WAND", "US_ITEM_TYPES.HELMET","US_ITEM_TYPES.LEGS", "US_ITEM_TYPES.GLOVES", "US_ITEM_TYPES.WEAPON_WANDAOE"},
        itemType = US_ITEM_TYPES.WEAPON_ANY + US_ITEM_TYPES.HELMET + US_ITEM_TYPES.LEGS + US_ITEM_TYPES.GLOVES
    },
    [45] = {
        name = "Suppression Chance",
        desc = "Your holy attacks can apply the Suppression effect, which weakens the target's attack by 20% for 5 seconds. Deal Holy Damage over time.",
        category = 1,
        percent = true,
        itemType = US_ITEM_TYPES.GLOVES + US_ITEM_TYPES.WEAPON_ANY + US_ITEM_TYPES.RELICT_OFFENSIVE + US_ITEM_TYPES.RELICT_UTILITY + US_ITEM_TYPES.HELMET + US_ITEM_TYPES.NECKLACE + US_ITEM_TYPES.RING
    },
    [46] = {
        name = "Health On Hit",
        desc = "Heal on basic hit or spell cast.",
        percent = false,
        category = 3,
        itemType = US_ITEM_TYPES.WEAPON_ANY + US_ITEM_TYPES.GLOVES + US_ITEM_TYPES.RELICT_UTILITY
    },
    [47] = {
        name = "DoT Damage",
        percent = true,
        desc = "Increase Damage Over Time (DoT).",
        category = 1,
        itemType = US_ITEM_TYPES.WEAPON_ANY + US_ITEM_TYPES.RING + US_ITEM_TYPES.NECKLACE + US_ITEM_TYPES.GLOVES
    },
    [48] = {
        name = "Cost Reduction",
        percent = true,
        desc = "Reduces the Mana cost of Spells and Aura reservation.",
        category = 3,
        itemType = US_ITEM_TYPES.NECKLACE + US_ITEM_TYPES.RING
    },
    [49] = {
        name = "Counterattack",
        percent = true,
        desc = "When you take damage, you perform a counterattack that deals Physical Damage. Scales with Strength, Shield Damage, and Attack.",
        category = 2,
        itemType = US_ITEM_TYPES.WEAPON_ANY + US_ITEM_TYPES.HELMET + US_ITEM_TYPES.ARMOR + US_ITEM_TYPES.LEGS + US_ITEM_TYPES.BOOTS + US_ITEM_TYPES.SHIELD
    },
    [50] = { -- Unique Shrunken Head Necklace
        name = "Critical Affliction ",
        desc = "1% Critical chance added 25% more DoT damage.",
        category = 1,
        subvalue = 7.5,
        minLevel = 2000,
        percent = false,
        noValue = true,
    },
    [51] = { -- SPECIAL boots
        name = "Haste",
        percent = true,
        desc = "Your attack have chance apply haste that give you movement speed 33% for 2s.",
        category = 3,
        minLevel = 2000,
        noQuality = true,
    },
    [52] = { -- SPECIAL boots
        name = "Evasion",
        desc = "Gain 1 stack of Evasion each step you do (up to 10). When stack reach 10 then next move restart. Each stack increase 2% of Dodge.",
        category = 1,
        minLevel = 2000,
        percent = true,
        noQuality = true,
    },
    [53] = {
        name = "Armor",
        desc = "Increase your Damage Reduction (Physical, Elemental, Duality).",
        category = 2,
        percent = false,
        itemType = US_ITEM_TYPES.HELMET + US_ITEM_TYPES.ARMOR + US_ITEM_TYPES.LEGS + US_ITEM_TYPES.BOOTS
    },
    [54] = { -- REMOVED
        name = "Cast Damage",
        percent = true,
        desc = "Increase Cast Damage.",
        category = 1,
        minLevel = 2000,
        itemType = US_ITEM_TYPES.WEAPON_ANY + US_ITEM_TYPES.RING + US_ITEM_TYPES.NECKLACE + US_ITEM_TYPES.GLOVES
    },
    [55] = {
        name = "Attack Speed",
        desc = "Increase attack speed of basic attacks.",
        category = 1,
        percent = true,
        itemType = US_ITEM_TYPES.WEAPON_ANY + US_ITEM_TYPES.RING + US_ITEM_TYPES.GLOVES + US_ITEM_TYPES.RELICT_OFFENSIVE
    },
    [56] = {
        name = "Cooldown Reduction",
        desc = "Reduces the time between spells used.",
        category = 3,
        percent = true,
        itemType = US_ITEM_TYPES.RING + US_ITEM_TYPES.NECKLACE + US_ITEM_TYPES.RELICT_UTILITY
    },
    [57] = {
        name = "Fire Damage",
        desc = "Increases damage dealt by fire elements.",
        category = 1,
        minLevel = 2000,
        percent = true,
        combatDamage = COMBAT_FIREDAMAGE,
        itemType = US_ITEM_TYPES.WEAPON_ANY + US_ITEM_TYPES.HELMET + US_ITEM_TYPES.GLOVES + US_ITEM_TYPES.SHIELD
    },
    [58] = {
        name = "Ice Damage",
        desc = "Increases damage dealt by ice elements.",
        category = 1,
        minLevel = 2000,
        percent = true,
        combatDamage = COMBAT_ICEDAMAGE,
        itemType = US_ITEM_TYPES.WEAPON_ANY + US_ITEM_TYPES.HELMET + US_ITEM_TYPES.GLOVES + US_ITEM_TYPES.SHIELD
    },
    [59] = {
        name = "Lightning Damage",
        desc = "Increases damage dealt by Lightning elements.",
        category = 1,
        minLevel = 2000,
        percent = true,
        combatDamage = COMBAT_ENERGYDAMAGE,
        itemType = US_ITEM_TYPES.WEAPON_ANY + US_ITEM_TYPES.HELMET + US_ITEM_TYPES.GLOVES + US_ITEM_TYPES.SHIELD
    },
    [60] = {
        name = "Earth Damage",
        desc = "Increases damage dealt by earth elements. (Poison and Earth is same)",
        category = 1,
        minLevel = 2000,
        percent = true,
        combatDamage = COMBAT_EARTHDAMAGE,
        itemType = US_ITEM_TYPES.WEAPON_ANY + US_ITEM_TYPES.HELMET + US_ITEM_TYPES.GLOVES + US_ITEM_TYPES.SHIELD
    },
    [61] = {
        name = "Death Damage",
        desc = "Increases damage dealt by death elements.",
        category = 1,
        minLevel = 2000,
        percent = true,
        combatDamage = COMBAT_DEATHDAMAGE,
        itemType = US_ITEM_TYPES.WEAPON_ANY + US_ITEM_TYPES.HELMET + US_ITEM_TYPES.GLOVES + US_ITEM_TYPES.SHIELD
    },
    [62] = {
        name = "Holy Damage",
        desc = "Increases damage dealt by holy elements.",
        category = 1,
        minLevel = 2000,
        percent = true,
        combatDamage = COMBAT_HOLYDAMAGE,
        itemType = US_ITEM_TYPES.WEAPON_ANY + US_ITEM_TYPES.HELMET + US_ITEM_TYPES.GLOVES + US_ITEM_TYPES.SHIELD
    },
    [63] = {
        name = "Endurance",
        desc = "Endurance is a defensive mechanic that allows you to take less damage while below a certain health value.",
        category = 2,
        minLevel = 2000,
        percent = true,
        itemType = US_ITEM_TYPES.ARMOR + US_ITEM_TYPES.SHIELD
    },
    [64] = {
        name = "Added Fire Damage",
        desc = "Increases base Fire damage.",
        category = 1,
        percent = false,
        minLevel = 2000,
        combatDamage = COMBAT_FIREDAMAGE,
        distance = 4,
        effect = 16,
        itemType = US_ITEM_TYPES.GLOVES + US_ITEM_TYPES.WEAPON_ANY + US_ITEM_TYPES.SHIELD
    },
    [65] = {
        name = "Added Ice Damage",
        desc = "Increases base Ice damage.",
        category = 1,
        percent = false,
        minLevel = 2000,
        combatDamage = COMBAT_ICEDAMAGE,
        distance = 37,
        effect = 44,
        itemType = US_ITEM_TYPES.GLOVES + US_ITEM_TYPES.WEAPON_ANY + US_ITEM_TYPES.SHIELD
    },
    [66] = {
        name = "Added Earth Damage",
        desc = "Increases base Earth damage.",
        category = 1,
        percent = false,
        minLevel = 2000,
        combatDamage = COMBAT_EARTHDAMAGE,
        distance = 30,
        effect = 21,
        itemType = US_ITEM_TYPES.GLOVES + US_ITEM_TYPES.WEAPON_ANY + US_ITEM_TYPES.SHIELD
    },
    [67] = {
        name = "Added Lightning Damage",
        desc = "Increases base Lightning damage.",
        category = 1,
        percent = false,
        minLevel = 2000,
        combatDamage = COMBAT_ENERGYDAMAGE,
        distance = 36,
        effect = 12,
        itemType = US_ITEM_TYPES.GLOVES + US_ITEM_TYPES.WEAPON_ANY + US_ITEM_TYPES.SHIELD
    },
    [68] = {
        name = "Added Duality Damage",
        desc = "Increases base holy & death damage.",
        category = 1,
        percent = false,
        combatDamage = COMBAT_HOLYDAMAGE + COMBAT_DEATHDAMAGE,
        distance = 11,
        effect = 18,
        itemType = US_ITEM_TYPES.GLOVES + US_ITEM_TYPES.WEAPON_ANY + US_ITEM_TYPES.SHIELD
    },
    [69] = {
        name = "Added Elemental Damage",
        desc = "Increases base fire, ice, earth and lightning damage.",
        category = 1,
        percent = false,
        combatDamage = COMBAT_ENERGYDAMAGE + COMBAT_EARTHDAMAGE + COMBAT_FIREDAMAGE + COMBAT_ICEDAMAGE,
        distance = 38,
        effect = 8,
        itemType = US_ITEM_TYPES.GLOVES + US_ITEM_TYPES.WEAPON_ANY + US_ITEM_TYPES.SHIELD
    },
    [70] = {
        name = "Added Physical Damage",
        desc = "Increases base physical damage.",
        category = 1,
        percent = false,
        combatDamage = COMBAT_PHYSICALDAMAGE,
        distance = 25,
        effect = 10,
        itemType = US_ITEM_TYPES.GLOVES + US_ITEM_TYPES.WEAPON_ANY + US_ITEM_TYPES.SHIELD
    },
    [71] = {
        name = "Energy Shield",
        desc = "Increase your Max Energy Shield points.",
        category = 2,
        percent = false,
        percentage = false,
        combatType = US_TYPES.CONDITION,
        condition = CONDITION_ATTRIBUTES,
        param = CONDITION_PARAM_STAT_MAXENERGYSHIELD,
        itemType = US_ITEM_TYPES.HELMET + US_ITEM_TYPES.ARMOR + US_ITEM_TYPES.LEGS + US_ITEM_TYPES.BOOTS + US_ITEM_TYPES.SHIELD + US_ITEM_TYPES.GLOVES + US_ITEM_TYPES.POTION + US_ITEM_TYPES.RELICT_DEFFENSIVE
    },
    [72] = {
        name = "Energy Shield Percent",
        desc = "Increase your Max Energy Shield percent points.",
        category = 2,
        percent = true,
        percentage = true,
        combatType = US_TYPES.CONDITION,
        condition = CONDITION_ATTRIBUTES,
        param = CONDITION_PARAM_STAT_MAXENERGYSHIELDPERCENT,
        itemType = US_ITEM_TYPES.HELMET + US_ITEM_TYPES.ARMOR + US_ITEM_TYPES.LEGS + US_ITEM_TYPES.BOOTS + US_ITEM_TYPES.SHIELD + US_ITEM_TYPES.GLOVES + US_ITEM_TYPES.RELICT_DEFFENSIVE
    },
    [73] = {
        name = "Energy Shield Regeneration Percent",
        desc = "Increase your Energy Shield regeneration.",
        category = 2,
        percent = true,
        percentage = true,
        itemType = US_ITEM_TYPES.HELMET + US_ITEM_TYPES.SHIELD + US_ITEM_TYPES.NECKLACE + US_ITEM_TYPES.POTION + US_ITEM_TYPES.RELICT_UTILITY
    },
    [74] = {
        name = "Health Regeneration Percent",
        desc = "You receive health every second.",
        category = 3,
        percent = true,
        itemType = US_ITEM_TYPES.ARMOR + US_ITEM_TYPES.SHIELD + US_ITEM_TYPES.LEGS + US_ITEM_TYPES.POTION + US_ITEM_TYPES.RELICT_UTILITY
    },
    [75] = {
        name = "Mana Regeneration Percent",
        desc = "You receive Mana every second.",
        category = 3,
        percent = true,
        itemType = US_ITEM_TYPES.RING + US_ITEM_TYPES.NECKLACE + US_ITEM_TYPES.POTION + US_ITEM_TYPES.RELICT_UTILITY
    },
    [76] = { -- Unique
        name = "You do not regenerate health",
        desc = "You do not regenerate health",
        category = 3,
        percent = false,
        minLevel = 2000,
        noValue = true,
    },
    [77] = { -- Unique
        name = "Deep Death",
        desc = "You deal only Death Damage, each Dexterity point inscrease your Death Damage.",
        category = 1,
        percent = false,
        noValue = true,
        minLevel = 2000,
    },
    [78] = { -- Unique
        name = "Maelstrom",
        desc = "Your Lightning spells have chance to cast Maelstrom that deals 15% of dealt damage as Lightning damage.",
        category = 1,
        percent = false,
        minLevel = 2000,
        noQuality = true,
    },
    [79] = { -- Unique
        name = "Flaming Corpse",
        desc = "The bodies of defeated enemies killed explode, dealing 10% of their maximum health as fire damage.",
        category = 1,
        percent = false,
        minLevel = 2000,
        noValue = true,
    },
    [80] = {
        name = "Health Gain on Kill",
        desc = "Give you Heal after kill.",
        category = 3,
        percent = false,
        itemType = US_ITEM_TYPES.RING + US_ITEM_TYPES.NECKLACE + US_ITEM_TYPES.GLOVES + US_ITEM_TYPES.WEAPON_ANY + US_ITEM_TYPES.POTION + US_ITEM_TYPES.RELICT_UTILITY
    },
    [81] = {
        name = "Mana Gain on Kill",
        desc = "Give you Mana after kill.",
        category = 3,
        percent = false,
        itemType = US_ITEM_TYPES.RING + US_ITEM_TYPES.NECKLACE + US_ITEM_TYPES.GLOVES + US_ITEM_TYPES.WEAPON_ANY + US_ITEM_TYPES.POTION + US_ITEM_TYPES.RELICT_UTILITY
    },
    [82] = {
        name = "Energy Shield Gain on Kill",
        desc = "Give you Energy Shield after kill.",
        category = 3,
        percent = false,
        itemType = US_ITEM_TYPES.RING + US_ITEM_TYPES.NECKLACE + US_ITEM_TYPES.GLOVES + US_ITEM_TYPES.WEAPON_ANY + US_ITEM_TYPES.POTION + US_ITEM_TYPES.RELICT_UTILITY
    },
    [83] = { -- Unique
        name = "Fire Weakness",
        desc = "Opponents affected by being Ignite take an additional 20% damage from your fire attacks.",
        category = 1,
        percent = false,
        minLevel = 2000,
        noValue = true,
    },
    [84] = { -- Unique
        name = "Fang Trust",
        desc = "Each Dexterity point increase your Physical Damage.",
        category = 1,
        percent = true,
        minLevel = 2000,
        noValue = true,
    },
    [85] = { -- Unique
        name = "Frostbitten Strength",
        desc = "Every target that takes ice damage will be slowed by 30%. Chilled targets take 1% more Damage for each 3 points of your Strength.",
        category = 1,
        noValue = true,
        percent = true,
        minLevel = 2000,
    },
    [86] = { -- Unique
        name = "Skin Laceration",
        desc = "Upon taking damage, the target receives a stack of bleeding.",
        category = 1,
        percent = true,
        minLevel = 2000,
        noValue = true,
    },
    [87] = { -- Unique
        name = "Hard Block",
        desc = "When you block an attack, your Damage Reduction increases by 1%, up to a maximum of 10 stacks.",
        category = 1,
        percent = false,
        minLevel = 2000,
        noValue = true,
    },
    [88] = { -- Unique
        name = "Demon Flame",
        desc = "You have 10% chance to cast Demon Flame that deal 50% of Monster damage as Fire damage.",
        category = 1,
        percent = true,
        minLevel = 2000,
        combatDamage = COMBAT_FIREDAMAGE,
        distance = 127,
        effect = 103,
        noValue = true,
        itemType = US_ITEM_TYPES.GLOVES + US_ITEM_TYPES.WEAPON_ANY
    },
    [89] = {
        name = "Melee Damage",
        desc = "Increases Melee damage dealt by melee weapons like axe, mace and sword and spells with Melee tags.",
        category = 1,
        percent = false,
        minLevel = 2000,
        itemType = US_ITEM_TYPES.WEAPON_ANY + US_ITEM_TYPES.HELMET + US_ITEM_TYPES.GLOVES
    },
    [90] = {
        name = "Magic Damage",
        desc = "Increases Magic damage dealt by magic weapons like wand, sceptes, staffes and spells with Magic tags.",
        category = 1,
        percent = false,
        minLevel = 2000,
        itemType = US_ITEM_TYPES.WEAPON_ANY + US_ITEM_TYPES.HELMET + US_ITEM_TYPES.GLOVES
    },
    [91] = {
        name = "Ranged Damage",
        desc = "Increases Ranged damage by ranged weapons like bows, crossbows, knifes and spells with Ranged tags.",
        category = 1,
        percent = false,
        minLevel = 2000,
        itemType = US_ITEM_TYPES.WEAPON_ANY + US_ITEM_TYPES.HELMET + US_ITEM_TYPES.GLOVES
    },
    [92] = { -- Unique
        name = "Absorb Energy",
        desc = "You have x% chance to reduced x% damage taken depend you max mana. Each 10 mana is 1%.",
        category = 1,
        percent = true,
        minLevel = 2000,
        noValue = true,
    },
    [93] = { -- Unique
        name = "Pain Avoid",
        desc = "You have chance to taken 0 damage.",
        category = 1,
        percent = true,
        minLevel = 2000,
        noValue = true,
    },
    [94] = { -- Unique
        name = "Critical Hits",
        desc = "You have chane to increase your Critical Chance by 1% to max 30 stacks. 3s duration",
        category = 1,
        percent = true,
        minLevel = 2000,
        noValue = true,
    },
    [95] = {
        name = "Health Recovery",
        desc = "Amount of recovery Health over 3 seconds.",
        category = 3,
        percent = false,
        percentage = false,
        itemType =  US_ITEM_TYPES.POTION
    },
    [96] = {
        name = "Shield Damage",
        desc = "Increase your Shield Spells damage and counterattack damage.",
        category = 2,
        minLevel = 2000,
        percent = false,
        itemType = US_ITEM_TYPES.SHIELD
    },
    [97] = {
        name = "Parry",
        desc = "You have a chance to reduced enemy melee attack by 33% and counter attack dealing 100% attack power as Physical damage.",
        category = 2,
        minLevel = 2000,
        percent = true,
        itemType = US_ITEM_TYPES.BOOTS + US_ITEM_TYPES.RING + US_ITEM_TYPES.GLOVES
    },
    [98] = { -- Unique
        name = "Queen Nails",
        desc = "You have chance to deal 20% of dealt damage Physical damage and apply bleed stack. Bleed Stack increased by 5.",
        category = 1,
        percent = true,
        minLevel = 2000,
        noValue = true,
        itemType = US_ITEM_TYPES.GLOVES + US_ITEM_TYPES.WEAPON_ANY
    },
    [99] = { -- Unique
        name = "Queen Curse",
        desc = "You spend Health instead of Mana to use Spells. Health cost is multiplied by the item's value.",
        category = 1,
        percent = true,
        minLevel = 2000,
        noValue = true,
        itemType = US_ITEM_TYPES.GLOVES + US_ITEM_TYPES.WEAPON_ANY
    },
    [100] = {
        name = "Fire Spells",
        desc = "Increase Fire spells level.",
        category = 1,
        percent = false,
        minLevel = 2000,
        itemType = US_ITEM_TYPES.WEAPON_ANY
    },
    [101] = {
        name = "Ice Spells",
        desc = "Increase Ice spells level.",
        category = 1,
        percent = false,
        minLevel = 2000,
        itemType = US_ITEM_TYPES.WEAPON_ANY
    },
    [102] = {
        name = "Lightning Spells",
        desc = "Increase Lightning spells level.",
        category = 1,
        percent = false,
        minLevel = 2000,
        itemType = US_ITEM_TYPES.WEAPON_ANY
    },
    [103] = {
        name = "Earth Spells",
        desc = "Increase Earth spells level.",
        category = 1,
        percent = false,
        minLevel = 2000,
        itemType = US_ITEM_TYPES.WEAPON_ANY
    },
    [104] = {
        name = "Death Spells",
        desc = "Increase Death spells level.",
        category = 1,
        percent = false,
        minLevel = 2000,
        itemType = US_ITEM_TYPES.WEAPON_ANY
    },
    [105] = {
        name = "Holy Spells",
        desc = "Increase Holy spells level.",
        category = 1,
        percent = false,
        minLevel = 2000,
        itemType = US_ITEM_TYPES.WEAPON_ANY
    },
    [106] = {
        name = "Physical Spells",
        desc = "Increase Physical spells level.",
        category = 1,
        percent = false,
        minLevel = 2000,
        itemType = US_ITEM_TYPES.WEAPON_ANY
    },
    [107] = {
        name = "All Spells",
        desc = "Increase all spells level.",
        category = 1,
        percent = false,
        chance = 10,
        itemType = US_ITEM_TYPES.WEAPON_ANY
    },
    [108] = { -- OFF
        name = "Brute Damage",
        desc = "Increases Physical damage dealt.",
        category = 1,
        percent = true,
        minLevel = 2000,
        combatDamage = COMBAT_PHYSICALDAMAGE,
        itemType = US_ITEM_TYPES.WEAPON_ANY + US_ITEM_TYPES.HELMET + US_ITEM_TYPES.LEGS + US_ITEM_TYPES.GLOVES
    },
    [109] = {
        name = "Health Percent",
        desc = "Increase your Health percent points.",
        category = 2,
        percent = true,
        percentage = true,
        combatType = US_TYPES.CONDITION,
        condition = CONDITION_ATTRIBUTES,
        param = CONDITION_PARAM_STAT_MAXHITPOINTSPERCENT,
        itemType = US_ITEM_TYPES.HELMET + US_ITEM_TYPES.ARMOR + US_ITEM_TYPES.LEGS + US_ITEM_TYPES.BOOTS + US_ITEM_TYPES.SHIELD + US_ITEM_TYPES.RELICT_DEFFENSIVE
    },
    [110] = {
        name = "Mana Percent",
        desc = "Increase your Mana percent points.",
        category = 2,
        percent = true,
        percentage = true,
        combatType = US_TYPES.CONDITION,
        condition = CONDITION_ATTRIBUTES,
        param = CONDITION_PARAM_STAT_MAXMANAPOINTSPERCENT,
        itemType = US_ITEM_TYPES.HELMET + US_ITEM_TYPES.ARMOR + US_ITEM_TYPES.LEGS + US_ITEM_TYPES.BOOTS + US_ITEM_TYPES.SHIELD + US_ITEM_TYPES.RELICT_DEFFENSIVE
    },
    [111] = {
        name = "Energy Shield on Hit",
        desc = "Recovery Energy Shield on hit basic or spells attacks.",
        category = 3,
        percent = false,
        itemType = US_ITEM_TYPES.WEAPON_ANY + US_ITEM_TYPES.GLOVES + US_ITEM_TYPES.RELICT_UTILITY
    },
    [112] = { -- Unique
        name = "Fire Critical Chance",
        desc = "Your Fire basic or Spells attacks can deal x2 Damage.",
        minLevel = 2000,
        category = 1,
        percent = true,
        percentage = true,
        itemType = US_ITEM_TYPES.RING
    },
    [113] = { -- Unique
        name = "Earth Weakness",
        desc = "Your Earth basic or Spells attacks deal more damage.",
        minLevel = 2000,
        subvalue = 20,
        category = 1,
        percent = true,
        percentage = true,
        itemType = US_ITEM_TYPES.RING
    },
    [114] = { -- Unique
        name = "Undead Curse",
        desc = "You deal only Physical damage, Culling Strike. [Culling Stikes kill enemies if their life is at 15% or below]",
        minLevel = 2000,
        category = 1,
        percent = true,
        percentage = true,
        noValue = true,
        itemType = US_ITEM_TYPES.RING
    },
    [115] = {
        name = "Mana Recovery",
        desc = "Restores Mana on use.",
        category = 3,
        percent = false,
        percentage = false,
        itemType = US_ITEM_TYPES.POTION
    },
    [116] = {
        name = "Health Barrier",
        desc = "Converts restored Health into Energy Shield at 100% + x% per Tier of Health.",
        category = 3,
        percent = true,
        percentage = true,
        itemType = US_ITEM_TYPES.POTION
    },
    [117] = {
        name = "Mana Transfusion",
        desc = "A percentage of the Mana spent is added to the Energy shield.",
        category = 3,
        percent = true,
        percentage = true,
        itemType = US_ITEM_TYPES.POTION
    },
    [118] = {
        name = "Haste on use",
        desc = "Increase your Movements speed on use for 1 second.",
        category = 3,
        percent = true,
        percentage = true,
        itemType = US_ITEM_TYPES.POTION
    },
    [119] = {
        name = "Energy Shield Recovery",
        desc = "Restores Energy Shield on use.",
        category = 3,
        percent = false,
        percentage = false,
        itemType = US_ITEM_TYPES.POTION
    },
    [120] = { -- Unique
        name = "Rebound",
        desc = "Gets three extra bounces.",
        category = 1,
        noValue = true,
        percent = true,
        minLevel = 2000,
    },
    [121] = { -- Unique
        name = "Repeating Fire",
        desc = "Fireball gets extra bounces.",
        category = 1,
        percent = true,
        noValue = true,
        minLevel = 2000,
    },
    [122] = {
        name = "Elemental Penetration",
        desc = "Penetration is a property of hits that reduces the target's effective resistance. (Fire, Ice, Lightning and Earth) ",
        category = 1,
        percent = true,
        combatDamage = COMBAT_FIREDAMAGE + COMBAT_ICEDAMAGE + COMBAT_ENERGYDAMAGE + COMBAT_EARTHDAMAGE,
        itemType = US_ITEM_TYPES.WEAPON_ANY
    },
    [123] = {
        name = "Quick Heal",
        desc = "Recovery instant percent of Health or Energy Shield potion.",
        category = 1,
        percent = true,
        itemType = US_ITEM_TYPES.POTION
    },

    -- Subklass Attributes
    -- Stormcaller
    [124] = {
        name = "Saint",
        desc = "Spell [Holy Dash] cast Holy Hammer and increase area of effect.\nSpell [Illumination] if the target dies under the effect of Illumination, you gain a buff. Each stack increases your Holy Damage by 5%. Maximum stacks: 50.\nSpell [Judgement Aura] every 0.5s gain Saint Buff stack. Each Stack add 1% more Holy Damage.",
        category = 1,
        percent = true,
        noValue = true,
        minLevel = 2000,
    },
    [125] = {
        name = "Cold Pulse",
        desc = "Spell [Cold Snap] hits 1 extra time.\nSpell [Ice Surge] increase area of effect.\nSpell [Arctic Volley] add 5 projectiles.",
        category = 1,
        subvalue = 5,
        percent = true,
        noValue = true,
        minLevel = 2000,
    },
    [126] = {
        name = "Arc Leech",
        desc = "Your spells restore 3% of Energy Shield.\nYour basic hits strike 3 additional enemies, dealing 25% of the damage dealt.",
        subvalue = 0.03,
        subvalue2 = 0.25,
        subvalue3 = 3,
        category = 1,
        percent = true,
        minLevel = 2000,
    },
    [127] = {
        name = "Overcharged Energy",
        desc = "Your spells cost 15% more Mana and gain 25% Damage Penetration.",
        subvalue = 15,
        subvalue2 = 25,
        category = 1,
        percent = true,
        minLevel = 2000,
    },
    [128] = {
        name = "Thunder",
        desc = "You have a 5% chance to deal 500% of damage dealt.",
        subvalue = 5,
        subvalue2 = 5.0,
        category = 1,
        percent = true,
        minLevel = 2000,
    },
    [129] = {
        name = "Storm Overlord",
        desc = "Your attacks deal random damage, from 25% to 75% more damage.",
        subvalue = 25,
        subvalue2 = 75,
        category = 1,
        percent = true,
        minLevel = 2000,
    },
    -- Pyromancer
    [130] = {
        name = "Mana Shield",
        desc = "10% of Mana is added as Energy Shield.",
        subvalue = 0.10,
        category = 1,
        percent = true,
        minLevel = 2000,
    },
    [131] = {
        name = "Fire Barrier",
        desc = "25% Elemental Mitigation.",
        subvalue = 25,
        category = 1,
        percent = true,
        minLevel = 2000,
    },
    [132] = {
        name = "Bloodfire",
        desc = "Casting spells costs 5% of your Health and grants 30% Penetration Damage.",
        subvalue = 0.05,
        subvalue2 = 30,
        category = 1,
        percent = true,
        minLevel = 2000,
    },
    [133] = {
        name = "Infernal Wrath",
        desc = "Enemies above 50% Health take 60% more Damage.",
        subvalue = 0.5,
        subvalue2 = 60,
        category = 1,
        percent = true,
        minLevel = 2000,
    },
    [134] = {
        name = "Fury Flames",
        desc = "Your spells cause an area explosion dealing 22% of damage dealt.",
        subvalue = 0.22,
        category = 1,
        percent = true,
        minLevel = 2000,
    },
    [135] = {
        name = "Icy Dragon Blink",
        desc = "Spell [Shattering Dash] cooldown is reduced to 0.3.\nSpell [Frozen Ground] cast Frozen Pulse and hits 1 extra time.\nSpell [Frozen Stomp] is supported by a Level 4 Expansion Rune.",
        category = 1,
        percent = true,
        noValue = true,
        minLevel = 2000,
    },
    -- Cryomancer
    [136] = {
        name = "Cold Skin",
        desc = "While above 50% Health, you gain 20% Damage Mitigation.\nWhile below 50% Health, attackers have a 25% chance to apply Chill and you recover 2 Mana.",
        category = 1,
        subvalue = 0.50,
        subvalue2 = 20,
        subvalue3 = 2,
        subvalue4 = 0.5,
        percent = true,
        minLevel = 2000,
    },
    [137] = {
        name = "Energy Imbue",
        desc = "Increase you Energy Shield Percent by 50% but reduced you Max Health Percent by 30%.",
        category = 1,
        subvalue = 50,
        subvalue2 = 30,
        percent = true,
        minLevel = 2000,
    },
    [138] = {
        name = "Toxity",
        desc = "Spell [Venom Nova] and [Acid Bomb] extends the damage over time duration to 3.5 seconds, with the Cast on Crit Support rune effect.",
        category = 1,
        percent = true,
        noValue = true,
        minLevel = 2000,
    },
    [139] = {
        name = "Permafrost Surge",
        desc = "20% Damage Penetration vs Chilled enemies.\nGain 10% Damage Mitigation against Chilled enemies.",
        category = 1,
        subvalue = 20,
        subvalue2 = 10,
        percent = true,
        minLevel = 2000,
    },
    [140] = {
        name = "Shatterstorm",
        desc = "If you attack a Chilled target, you gain a Shatterstorm stack, which grants 3% penetration damage. Stacks up to 10 times.",
        category = 1,
        subvalue = 3,
        percent = true,
        minLevel = 2000,
    },
    [141] = {
        name = "Frigid Execution",
        desc = "Enemies below 90% Life take 65% more Damage.",
        category = 1,
        subvalue = 0.90,
        subvalue2 = 65,
        percent = true,
        minLevel = 2000,
    },
    -- Shaman
    [142] = {
        name = "Rapid Decay",
        desc = "Spells [Death Wave], [Rotten Gas Shot], [Affliction Aura] and [Black Hole] dots duration reduced to 1.5 second.\nSpell [Curse] if the target dies, it applies the monsters debuff to enemies within a 4-tile radius instead of 1.\nDeath DoT Damage x1.2.",
        category = 1,
        subvalue = 0.5,
        percent = true,
        noValue = true,
        minLevel = 2000,
    },
    [143] = {
        name = "Skull Crasher",
        desc = "Spells [Rotten Vine] and [Death Bolt] add 5 projectiles, [Leaping Death] increase area of effect.\nSpells [Rotten Vine], [Death Bolt], [Leaping Death] and [Black Matter] adds 40% Critical Damage.",
        category = 1,
        subvalue = 5,
        subvalue2 = 40,
        noValue = true,
        percent = true,
        minLevel = 2000,
    },
    [144] = {
        name = "Plague",
        desc = "Deals 20% of damage dealt, and 20% more against enemies below 50% Health.",
        category = 1,
        subvalue = 0.20, -- pen
        subvalue2 = 0.20, -- pen
        subvalue3 = 0.50, -- hp
        percent = true,
        minLevel = 2000,
    },
    [145] = {
        name = "Epidemic",
        desc = "Poisoned enemies take 60% more damage.",
        category = 1,
        subvalue = 60,
        percent = true,
        minLevel = 2000,
    },
    [146] = {
        name = "Ruinous Tremous",
        desc = "Adds 20% Penetration, and an additional 20% against enemies below 50% Health.",
        category = 1,
        subvalue = 20, -- pen
        subvalue2 = 20, -- pen
        subvalue3 = 0.50, -- hp
        percent = true,
        minLevel = 2000,
    },
    [147] = {
        name = "Boulder",
        desc = "Your attacks have a 10% chance to cast a Boulder that deals 250% of the Damage dealt.",
        category = 1,
        subvalue = 2.50,
        subvalue2 = 10,
        percent = true,
        minLevel = 2000,
    },
    -- Saint
    [148] = {
        name = "Infernal Eruption",
        desc = "Spell [Magma Fissure] and [Molten Strike] add 5 projectiles.\nSpell [Blazing Shout] increases area of effect.",
        category = 1,
        subvalue = 5,
        noValue = true,
        percent = true,
        minLevel = 2000,
    },
    [149] = {
        name = "Holy Arrow",
        desc = "Aura [Multishot] hits 2 additional targets and deals extra 15% of the original damage.\n[Multishot] has a 10% chance to deal 200% of the original damage.",
        category = 1,
        subvalue = 10,
        subvalue2 = 0.15,
        subvalue3 = 1.0,
        percent = true,
        noValue = true,
        minLevel = 2000,
    },
    [150] = {
        name = "Crusader Onslaught",
        desc = "Your attacks have a 25% chance to deal 50% more damage, a 15% chance to deal 120% more damage, and a 10% chance to deal 200% more damage.",
        category = 1,
        subvalue = 25,
        subvalue2 = 50,
        subvalue3 = 15,
        subvalue4 = 120,
        subvalue5 = 10,
        subvalue6 = 200,
        percent = true,
        minLevel = 2000,
    },
    [151] = {
        name = "Righteous Fury",
        desc = "Every fourth cast creates an additional explosion dealing 100% of damage dealt.",
        category = 1,
        subvalue = 1.0,
        percent = true,
        minLevel = 2000,
    },
    [152] = {
        name = "Sacred Impact",
        desc = "Your spells have 35% Penetration Damage but increase coolodwn by 30%.",
        category = 1,
        subvalue = 0.3,
        subvalue2 = 35,
        percent = true,
        minLevel = 2000,
    },
    [153] = {
        name = "Grace",
        desc = "Your Duality spells heal 2% of your Health and Energy Shield per cast and have 18% Duality Penetration.",
        category = 1,
        subvalue = 18,
        subvalue2 = 0.02,
        percent = true,
        minLevel = 2000,
    },
    -- Inquisitor
    [154] = {
        name = "Multishock",
        desc = "Aura [Mystic Focus] hits 2 additional targets and deals extra 15% of the original damage.\n[Mystic Focus] has a 10% chance to deal 200% of the original damage.",
        category = 1,
        subvalue = 0.15,
        subvalue2 = 10,
        subvalue3 = 1,
        subvalue4 = 2,
        noValue = true,
        percent = true,
        minLevel = 2000,
    },
    [155] = {
        name = "Hack and Slash",
        desc = "Aura [Cleave] now deals 125% of the original damage instead of 100% and changes its effect.\n[Cleave] attacks have 10% change to deal 225% of original damage.",
        category = 1,
        subvalue = 10,
        subvalue2 = 0.25,
        subvalue3 = 1.25,
        percent = true,
        noValue = true,
        minLevel = 2000,
    },
    [156] = {
        name = "Frosty Pulse",
        desc = "Spell [Winter Wind] shoots projectiles in all directions.\nSpell [Blizzard] creates an ice wave pulse over a very large area and an additional wave of ice that deals 20% of the original damage.\nAura [Frozen Shards Aura] is supported by a Level 4 Expansion Rune.",
        category = 1,
        percent = true,
        noValue = true,
        minLevel = 2000,
    },
    [157] = {
        name = "Heaven's Strike",
        desc = "If the target is affected by [Suppression], your attacks have a 55% chance to deal 100% more damage.",
        category = 1,
        subvalue = 55,
        subvalue2 = 100,
        percent = true,
        minLevel = 2000,
    },
    [158] = {
        name = "Sanctified Assault",
        desc = "Your basic attacks have a 15% chance to deal 175% of damage dealt.",
        category = 1,
        subvalue = 15,
        subvalue2 = 1.75,
        percent = true,
        minLevel = 2000,
    },
    [159] = {
        name = "Heaven's Fury",
        desc = "If you wield a two-handed weapon, your block chance is increase 50% and gain 20% Penetration Damage.",
        category = 1,
        subvalue = 50,
        subvalue2 = 20,
        percent = true,
        minLevel = 2000,
    },
    -- Slayer
    [160] = {
        name = "Light Bringer",
        desc = "When your Health falls below 30%, you regenerate 100% of your maximum Health over 5 seconds Cooldown: 17s.",
        category = 1,
        subvalue = 0.30,
        subvalue2 = 1, -- 1 = 100%
        percent = true,
        minLevel = 2000,
    },
    [161] = {
        name = "Unbroken",
        desc = "15% Damage Mitigation",
        category = 1,
        subvalue = 15,
        percent = true,
        minLevel = 2000,
    },
    [162] = {
        name = "Rage",
        desc = "Melee attacks apply a [Rage] stack, which added more Damage by 2%. Max Stacks 30.",
        category = 1,
        subvalue = 2,
        percent = true,
        minLevel = 2000,
    },
    [163] = {
        name = "Bloody Fury",
        desc = "Bleeding enemies take 30% of damage dealt.",
        category = 1,
        subvalue = 0.30,
        percent = true,
        minLevel = 2000,
    },
    [164] = {
        name = "Mighty Hands",
        desc = "Your attacks have 25% Physical Penetration.",
        category = 1,
        subvalue = 25,
        percent = true,
        minLevel = 2000,
    },
    [165] = {
        name = "Catastrophic Blow",
        desc = "Your Basic [Melee] Attack creates a [Swing] that deals 50% damage in front and to the sides.",
        category = 1,
        subvalue = 0.50,
        percent = true,
        minLevel = 2000,
    },
    -- Colossus
    [166] = {
        name = "Disarmament",
        desc = "Block applies [Disarmament] to the target, reducing all damage it deals by 20%.",
        category = 1,
        subvalue = 20,
        percent = true,
        minLevel = 2000,
    },
    [167] = {
        name = "Titan Vitality",
        desc = "Increase your Max Health by 35%. Your Block recovery you 1% Max Health.",
        category = 1,
        subvalue = 35,
        subvalue2 = 0.01,
        percent = true,
        minLevel = 2000,
    },
    [168] = {
        name = "Determination",
        desc = "Added 50% more damage.",
        category = 1,
        subvalue = 50,
        percent = true,
        minLevel = 2000,
    },
    [169] = {
        name = "More Power",
        desc = "Your attacks deal 25% of damage dealt.",
        category = 1,
        subvalue = 0.25,
        percent = true,
        minLevel = 2000,
    },
    [170] = {
        name = "Arcane Insight",
        desc = "Your attacks have 25% Elemental Penetration.",
        category = 1,
        subvalue = 25,
        percent = true,
        minLevel = 2000,
    },
    [171] = {
        name = "Added Adaptive Damage",
        desc = "Increases base all damage.",
        category = 1,
        percent = false,
        minLevel = 2000,
        itemType = US_ITEM_TYPES.GLOVES + US_ITEM_TYPES.WEAPON_ANY + US_ITEM_TYPES.SHIELD
    },
    -- Marksman
    [172] = {
        name = "Fleetfoot",
        desc = "While moving increases Movments Speed by 15% and 10% Damage Mitigation.",
        category = 1,
        subvalue = 15,
        subvalue2 = 10,
        percent = true,
        minLevel = 2000,
    },
    [173] = {
        name = "Fire Knowledge",
        desc = "Spell [Fire Wall] creates two rings instead of a wall.\nSpell [Fireball] chains 2 times to nearby enemies.",
        category = 1,
        noValue = true,
        minLevel = 2000,
    },
    [174] = {
        name = "Bloody Arrow",
        desc = "Your attacks have 20% chance to cast [Bloody Arrow] that deals 100% of damage dealt in a small area.",
        category = 1,
        subvalue = 20, -- targets
        subvalue2 = 1.0, -- damage
        percent = true,
        minLevel = 2000,
    },
    [175] = {
        name = "Multishot Enhancement", -- dodanie efektu do global
        desc = "Your basic attacks hit 2 additional targets by 30% original damage.\nPenetration increased by 15%.",
        category = 1,
        subvalue = 2, -- targets
        subvalue2 = 0.3, -- damage
        subvalue3 = 15, -- penetration
        percent = true,
        minLevel = 2000,
    },
    [176] = {
        name = "Culling Strike",
        desc = "Adds 40% more Damage.\nCulling Strike. Culling Strike. [Culling Stikes kill enemies if their life is at 10% or below only against Normal Monsters]",
        category = 1,
        subvalue = 0.10,
        subvalue2 = 40,
        percent = true,
        minLevel = 2000,
    },
    [177] = {
        name = "Decimating Strike",
        desc = "Hits against [Full Health] enemies remove between 5% and 20% percent of Health, before the damage of the Hit is applied only against Normal Monsters.",
        category = 1,
        subvalue = 5,
        subvalue2 = 20,
        percent = true,
        minLevel = 2000,
    },
    -- Venomstorm
    [178] = {
        name = "Thunderlord",
        desc = "Spell [Thunder Strike] hits 5 additional targets.\nSpell [Zeus Wrath] cooldown is reduced to 1s.\nAura [Static Condition] is supported by a Level 4 Expansion Rune.",
        category = 1,
        subvalue = 5,
        noValue = true,
        percent = false,
        minLevel = 2000,
    },
    [179] = {
        name = "Elusive Recovery",
        desc = "When you Dodge or Spell Avoid, recover 2.5% of your maximum Health and Energy Shield.",
        category = 1,
        subvalue = 0.025,
        percent = true,
        minLevel = 2000,
    },
    [180] = {
        name = "Static Conduit",
        desc = "Adds 40% more damage.\nYour attacks additionally strike 2 nearby enemies, dealing 15% of the damage dealt.",
        category = 1,
        subvalue = 2,
        subvalue2 = 0.15,
        subvalue3 = 40,
        percent = true,
        minLevel = 2000,
    },
    [181] = {
        name = "Overcharged Arc",
        desc = "Your spells gain 25% Penetration Damage.",
        category = 1,
        subvalue = 25,
        percent = true,
        minLevel = 2000,
    },
    [182] = {
        name = "Venomous Shots",
        desc = "Your attacks deal extra 25% Earth Damage.",
        category = 1,
        subvalue = 0.25,
        percent = true,
        minLevel = 2000,
    },
    [183] = {
        name = "Berserker Fury",
        desc = "Spell [Amok] and [Leap Slam] has a 0.3 second Cooldown and increased Area of Effect.",
        category = 1,
        noValue = true,
        minLevel = 2000,
    },
    -- Assassin
    [184] = {
        name = "Mana Core",
        desc = "10% of Mana is converted to Health. Gain 350% increased Damage if your Mana is above 15,000.",
        category = 1,
        subvalue = 0.10,
        subvalue2 = 15000,
        subvalue3 = 350,
        noValue = true,
        minLevel = 2000,
    },
    [185] = {
        name = "Inflexibility",
        desc = "While above 80% Health, you gain 25% Damage Mitigation.",
        category = 1,
        subvalue = 0.80,
        subvalue2 = 25,
        percent = true,
        minLevel = 2000,
    },
    [186] = {
        name = "Deadly Precision",
        desc = "Critical strikes ignore 30% of the enemy's resistance.",
        category = 1,
    --    subvalue = 10,
        subvalue2 = 30,
        percent = true,
        minLevel = 2000,
    },
    [187] = {
        name = "Unrelenting Strike",
        desc = "Critical hits deals 25% of damage dealt.",
        category = 1,
        subvalue = 0.25,
        percent = true,
        minLevel = 2000,
    },
    [188] = {
        name = "Quick Slash",
        desc = "If you reach 100% Attack Speed, you gain 60% more Damage.",
        category = 1,
        subvalue = 60,
        percent = true,
        minLevel = 2000,
    },
    [189] = {
        name = "Swift Killer",
        desc = "Each of your basic attacks increases your attack Speed by 1%. Max stacks 75.",
        category = 1,
        subvalue = 1,
        percent = true,
        minLevel = 2000,
    },
    -- Soulblade
    [190] = {
        name = "Uncatchable Shadow",
        desc = "Below 40% Health and upon taking damage, you become immune to damage for 2.5 seconds. Cooldown: 30 seconds.",
        category = 1,
        subvalue = 0.4,
        subvalue2 = 2500,
        percent = true,
        minLevel = 2000,
    },
    [191] = {
        name = "Clawer",
        desc = "Spells [Flicker Strike], [Shattering Dash], [Blitz] and [Phantom Run] deal area damage.",
        category = 1,
        percent = false,
        noValue = true,
        minLevel = 2000,
    },
    [192] = {
        name = "Deferred Death",
        desc = "Your attacks cast [Deferred Death] effect, which slows the target by 30% for 2 seconds and deals 25% of damage dealt.",
        category = 1,
        subvalue = 0.30,
        subvalue2 = 0.20,
        percent = true,
        minLevel = 2000,
    },
    [193] = {
        name = "Elder Knowledge",
        desc = "Spell [Earth Bolt] add 5 projectiles.\nSpell [Sunder], [Rootgrasp] and [Stonefall] increases its area of effect.",
        category = 1,
        subvalue = 5,
        percent = true,
        noValue = true,
        minLevel = 2000,
    },
    [194] = {
        name = "Unstable Darkness",
        desc = "Your attacks deal 1% to 100% additional more damage.",
        category = 1,
        subvalue = 1,
        subvalue2 = 100,
        percent = true,
        minLevel = 2000,
    },
    [195] = {
        name = "Suffering Power",
        desc = "Your attacks gain 30% Damage Penetration, but you lose 5% of your Health after casting.",
        category = 1,
        subvalue = 30,
        subvalue2 = 0.05,
        percent = true,
        minLevel = 2000,
    },
    [196] = {
        name = "Duality Damage",
        desc = "Increases damage dealt by Death and Holy.",
        category = 1,
        percent = true,
        combatDamage = COMBAT_HOLYDAMAGE + COMBAT_DEATHDAMAGE,
        itemType = US_ITEM_TYPES.WEAPON_ANY + US_ITEM_TYPES.HELMET + US_ITEM_TYPES.GLOVES + US_ITEM_TYPES.SHIELD + US_ITEM_TYPES.RELICT_OFFENSIVE + US_ITEM_TYPES.RELICT_GOBLIN + US_ITEM_TYPES.RELICT_BOSS + US_ITEM_TYPES.RELICT_STRONGBOX + US_ITEM_TYPES.RELICT_CHAMPION + US_ITEM_TYPES.RELICT_VOIDSTONE
    },
    [197] = {
        name = "Duality Protection",
        desc = "Reduces damage taken from Death and Holy damage.",
        category = 2,
        percent = true,
        combatDamage = COMBAT_HOLYDAMAGE + COMBAT_DEATHDAMAGE,
        itemType = US_ITEM_TYPES.ARMOR + US_ITEM_TYPES.SHIELD + US_ITEM_TYPES.BOOTS + US_ITEM_TYPES.HELMET + US_ITEM_TYPES.LEGS + US_ITEM_TYPES.RELICT_DEFFENSIVE
    },
    [198] = {
        name = "Duality Penetration",
        desc = "Penetration is a property of hits that reduces the target's effective resistance. (Death and Holy) ",
        category = 1,
        percent = true,
        combatDamage = COMBAT_HOLYDAMAGE + COMBAT_DEATHDAMAGE,
        itemType = US_ITEM_TYPES.WEAPON_ANY
    },
    [199] = {
        name = "Health on Block",
        desc = "Recovery Health on Block.",
        category = 1,
        percent = false,
        itemType = US_ITEM_TYPES.SHIELD
    },
    [200] = {
        name = "Energy Shield on Block",
        desc = "Recovery Energy shield on Block.",
        category = 1,
        percent = false,
        itemType = US_ITEM_TYPES.SHIELD
    },
    [201] = {
        name = "Mana on Hit",
        desc = "Recovery Mana on hit basic or Spells attacks.",
        minLevel = 2000,
        category = 3,
        percent = false,
        itemType = US_ITEM_TYPES.GLOVES + US_ITEM_TYPES.RELICT_UTILITY
    },
    [202] = {
        name = "Spell Wisdom",
        desc = "Increase 1% Spell damage per level.",
        minLevel = 2000,
        category = 1,
        percent = false,
        noValue = true,
        itemType = US_ITEM_TYPES.GLOVES
    },
    [203] = {
        name = "Can be modified while Corrupted",
        category = 1,
        minLevel = 2000,
        noValue = true,
        percent = false,
    },
    [204] = {
        name = "Spell Dodge",
        desc = "30% of your Dodge added Spell Avoid",
        minLevel = 2000,
        category = 1,
        percent = false,
        noValue = true,
        itemType = US_ITEM_TYPES.GLOVES
    },
    [205] = {
        name = "Reflects opposite Ring",
        category = 1,
        minLevel = 2000,
        noValue = true,
        percent = false,
    },
    [206] = { -- Unique
        name = "Affliction Mastery",
        desc = "Each unique ailments on target taken more DoT Damage by 100%.",
        minLevel = 2000,
        subvalue = 100,
        category = 1,
        noValue = true,
        percent = false,
        itemType = US_ITEM_TYPES.GLOVES
    },
    [207] = { -- Unique
        name = "Resurrection",
        desc = "When you would die, instead revive with full Life, Energy Shield, Mana and become Immoratl for 5 seconds. Can only occur once every 3 minutes.",
        minLevel = 2000,
        category = 1,
        noValue = true,
        percent = false,
        itemType = US_ITEM_TYPES.GLOVES
    },
    [208] = { -- Unique
        name = "Bastion",
        desc = "Each Strength increase 5% Counterattack.",
        subvalue = 5,
        minLevel = 2000,
        category = 1,
        noValue = true,
        percent = false,
        itemType = US_ITEM_TYPES.GLOVES
    },
    [209] = { -- Unique
        name = "High Quality",
        desc = "This item can have up to 50% quality. Increasing the quality requires 5 orbs.",
        minLevel = 2000,
        category = 1,
        noValue = true,
        percent = false,
        itemType = US_ITEM_TYPES.GLOVES
    },
    [210] = { -- Unique
        name = "Ailments Chance",
        desc = "Increase all ailments chance.",
        minLevel = 2000,
        category = 1,
        percent = true,
        itemType = US_ITEM_TYPES.GLOVES
    },
    [211] = { -- Unique
        name = "Volcanic Erruption",
        desc = "Fire spells have 25% chance to cast [Volcanic Erruption] that deal 25% of damage dealt as Fire Damage.",
        minLevel = 2000,
        category = 1,
        noValue = true,
        percent = false,
        itemType = US_ITEM_TYPES.GLOVES
    },
    [212] = { -- Unique
        name = "Cosmic Focus",
        desc = "Increase Elemental Damage equal to 2% of your Max Health or Energy Shield (whichever is higher), capped at 400%.",
        minLevel = 2000,
        subvalue = 0.02,
        category = 1,
        noValue = true,
        percent = false,
        itemType = US_ITEM_TYPES.GLOVES
    },
    [213] = { -- Unique
        name = "Fire Blink",
        desc = "Fire spells can blink you to target and deal 25% dealt damage as Fire Damage.",
        minLevel = 2000,
        category = 1,
        noValue = true,
        percent = false,
        itemType = US_ITEM_TYPES.GLOVES
    },
    [214] = { -- Unique
        name = "Weak Points",
        desc = "Your Basic attacks have 5% chance to deal 300% more Damage.",
        minLevel = 2000,
        subvalue = 300,
        subvalue2 = 5,
        category = 1,
        noValue = true,
        percent = false,
        itemType = US_ITEM_TYPES.GLOVES
    },
    [215] = { -- Unique
        name = "Fury Hits",
        desc = "Each of your basic attacks increases your Basic Damage by 0.3% per hit, stacking up to 600 times.",
        minLevel = 2000,
        category = 1,
        noValue = true,
        percent = false,
        itemType = US_ITEM_TYPES.GLOVES
    },
    [216] = { -- Unique
        name = "Mana Fusion",
        desc = "33% of your Mana added to Energy Shield.",
        minLevel = 2000,
        category = 1,
        subvalue = 0.33,
        noValue = true,
        percent = false,
        itemType = US_ITEM_TYPES.GLOVES
    },
    [217] = { -- Unique
        name = "Adaptive",
        desc = "This weapon's attack increases with your level. 1.25 per level. 100 Level is cap.",
        minLevel = 2000,
        category = 1,
        subvalue = 1.25,
        noValue = true,
        percent = false,
        itemType = US_ITEM_TYPES.GLOVES
    },
    [218] = { -- Unique
        name = "Dragon Vitality",
        desc = "Each 3 Vitality point increase 1% Health Regeneration percent.",
        minLevel = 2000,
        category = 1,
        subvalue = 3,
        noValue = true,
        percent = false,
        itemType = US_ITEM_TYPES.GLOVES
    },
    [219] = { -- Unique
        name = "Dragon Absorb",
        desc = "Transfer 2.5% damage taken to you Health.",
        minLevel = 2000,
        category = 1,
        subvalue = 0.025,
        noValue = true,
        percent = false,
        itemType = US_ITEM_TYPES.GLOVES
    },
    [220] = { -- Unique
        name = "Evolved Attribute",
        desc = "The attribute with the lowest value is increased by 50% of the value of the highest one. [Strength, Dexterity, Intelligence]",
        minLevel = 2000,
        category = 1,
        subvalue = 3,
        noValue = true,
        percent = false,
        itemType = US_ITEM_TYPES.GLOVES
    },
    [221] = { -- Unique
        name = "Hermes Speed",
        desc = "Gain 0.7% increased damage per 1% Movement Speed, capped at 400%.",
        minLevel = 2000,
        category = 1,
        subvalue = 0.7,
        noValue = true,
        percent = false,
        itemType = US_ITEM_TYPES.GLOVES
    },
    [222] = { -- Unique
        name = "Red Salvo",
        desc = "Your spells have a 5% chance to trigger [Red Salvo], calling it down from the sky to deal area damage equal to 25% of the damage dealt.",
        minLevel = 2000,
        category = 1,
        subvalue = 5,
        subvalue2 = 0.25,
        noValue = true,
        percent = false,
        itemType = US_ITEM_TYPES.GLOVES
    },
    [223] = { -- Unique
        name = "Bloodlust",
        desc = "Each stack of Bleed on the enemy causes your attacks to deal 10% more damage.",
        minLevel = 2000,
        category = 1,
        subvalue = 10,
        noValue = true,
        percent = false,
        itemType = US_ITEM_TYPES.GLOVES
    },
    -- New enchantments for Frost Beast uniques
    [224] = { -- Unique
        name = "Frost Mighty",
        desc = "Each Strength and Intelligence point increases 3% Ice Damage.",
        minLevel = 2000,
        category = 1,
        subvalue = 3,
        noValue = true,
        percent = true,
        itemType = US_ITEM_TYPES.WEAPON_ANY + US_ITEM_TYPES.GLOVES
    },
    [225] = { -- Unique
        name = "North Protection",
        desc = "Chilled enemies deal 20% less damage to you.",
        minLevel = 2000,
        category = 2,
        subvalue = 20,
        noValue = true,
        percent = false,
        itemType = US_ITEM_TYPES.SHIELD + US_ITEM_TYPES.ARMOR
    },
    [226] = { -- Unique
        name = "Frost Barrier",
        desc = "Counterattacks deal only Ice Damage. Blocking have 15% chance to reflect [Ice Spear] that deals 200% of the damage taken as Ice Damage.",
        minLevel = 2000,
        category = 2,
        subvalue = 2.0,
        subvalue2 = 15,
        noValue = true,
        percent = true,
        itemType = US_ITEM_TYPES.SHIELD
    },
    [227] = { -- Unique NO INCLUEDED
        name = "Crystalize",
        desc = "Ice spells have a 5% chance to freeze the enemy for 2 seconds [Normal/Elite]. Frozen enemies take 150% more damage. Each Intelligence point increase 1% Ice Damage",
        minLevel = 2000,
        category = 1,
        subvalue = 5,
        subvalue2 = 150,
        noValue = true,
        percent = true,
        itemType = US_ITEM_TYPES.WEAPON_WAND
    },
    [228] = {
        name = "Elemental Spells",
        desc = "Increase Fire, Ice, Earth and Lightning spell level.",
        category = 1,
        percent = false,
        chance = 50,
        itemType = US_ITEM_TYPES.WEAPON_ANY + US_ITEM_TYPES.RELICT_GOBLIN + US_ITEM_TYPES.RELICT_BOSS + US_ITEM_TYPES.RELICT_STRONGBOX + US_ITEM_TYPES.RELICT_CHAMPION + US_ITEM_TYPES.RELICT_VOIDSTONE
    },
    [229] = {
        name = "Physical Spells",
        desc = "Increase Physical spell level.",
        category = 1,
        percent = false,
        chance = 50,
        itemType = US_ITEM_TYPES.WEAPON_ANY + US_ITEM_TYPES.RELICT_GOBLIN + US_ITEM_TYPES.RELICT_BOSS + US_ITEM_TYPES.RELICT_STRONGBOX + US_ITEM_TYPES.RELICT_CHAMPION + US_ITEM_TYPES.RELICT_VOIDSTONE
    },
    [230] = {
        name = "Duality Spells",
        desc = "Increase Death and Holy spell level.",
        category = 1,
        percent = false,
        chance = 50,
        itemType = US_ITEM_TYPES.WEAPON_ANY + US_ITEM_TYPES.RELICT_GOBLIN + US_ITEM_TYPES.RELICT_BOSS + US_ITEM_TYPES.RELICT_STRONGBOX + US_ITEM_TYPES.RELICT_CHAMPION + US_ITEM_TYPES.RELICT_VOIDSTONE
    },
    [231] = {
        name = "Reflected Attacks",
        desc = "Receiving damage grants you stacks that increase basic damage by 1% and Counterattack by 2% per stack. Maximum stacks 500.",
        minLevel = 2000,
        category = 1,
        subvalue = 1,
        noValue = true,
        percent = true,
        itemType = US_ITEM_TYPES.WEAPON_WAND
    },
    [232] = {
        name = "Max Physical Protection",
        desc = "Increases Physical Protection when your capacity exceeds 70%. Max 90%",
        category = 2,
        percent = true,
        minLevel = 2000,
        itemType = US_ITEM_TYPES.ALL
    },
    [233] = {
        name = "Max Elemental Protection",
        desc = "Increases Elemental Protection when your capacity exceeds 70%. Max 90%",
        category = 2,
        percent = true,
        minLevel = 2000,
        itemType = US_ITEM_TYPES.ALL
    },
    [234] = {
        name = "Max Duality Protection",
        desc = "Increases Duality Protection when your capacity exceeds 70%. Max 90%",
        category = 2,
        percent = true,
        minLevel = 2000,
        itemType = US_ITEM_TYPES.ALL
    },
    [235] = { -- OFF
        name = "Max Attack Speed",
        desc = "Increases Attack Speed when your capacity exceeds 80%. Max 92%",
        category = 1,
        percent = true,
        minLevel = 2000,
        combatType = US_TYPES.CONDITION,
        condition = CONDITION_ATTRIBUTES,
        param = CONDITION_PARAM_MAXATTACKSPEED,
        itemType = US_ITEM_TYPES.ALL
    },
    [236] = {
        name = "Max Block Chance",
        desc = "Increases Block chance when your capacity exceeds 75%. Max 92%",
        category = 2,
        percent = true,
        minLevel = 2000,
        itemType = US_ITEM_TYPES.ALL
    },
    [237] = {
        name = "Physical Mitigation",
        desc = "Decreased your Physical Damage taken. Cap 75%",
        category = 2,
        percent = true,
        minLevel = 2000,
        monsterLevel = 500,
        itemType = US_ITEM_TYPES.ARMOR + US_ITEM_TYPES.SHIELD + US_ITEM_TYPES.BOOTS + US_ITEM_TYPES.HELMET + US_ITEM_TYPES.LEGS
    },
    [238] = {
        name = "Elemental Mitigation",
        desc = "Decreased your Elemental Damage taken. Cap 75%",
        category = 2,
        percent = true,
        minLevel = 2000,
        monsterLevel = 500,
        itemType = US_ITEM_TYPES.ARMOR + US_ITEM_TYPES.SHIELD + US_ITEM_TYPES.BOOTS + US_ITEM_TYPES.HELMET + US_ITEM_TYPES.LEGS
    },
    [239] = {
        name = "Duality Mitigation",
        desc = "Decreased your Duality Damage taken. Cap 75%",
        category = 2,
        percent = true,
        minLevel = 2000,
        monsterLevel = 500,
        itemType = US_ITEM_TYPES.ARMOR + US_ITEM_TYPES.SHIELD + US_ITEM_TYPES.BOOTS + US_ITEM_TYPES.HELMET + US_ITEM_TYPES.LEGS
    },
    [240] = {
        name = "Physical Overpower",
        desc = "Empowers your strikes, greatly increasing Physical Damage as an additional multiplier.",
        category = 1,
        percent = true,
        minLevel = 2000,
        monsterLevel = 500,
        combatDamage = COMBAT_PHYSICALDAMAGE,
        itemType = US_ITEM_TYPES.WEAPON_ANY + US_ITEM_TYPES.HELMET + US_ITEM_TYPES.GLOVES + US_ITEM_TYPES.SHIELD
    },
    [241] = {
        name = "Elemental Overpower",
        desc = "Empowers your strikes, greatly increasing Elemental Damage as an additional multiplier.",
        category = 1,
        percent = true,
        minLevel = 2000,
        monsterLevel = 500,
        combatDamage = COMBAT_ENERGYDAMAGE + COMBAT_EARTHDAMAGE + COMBAT_FIREDAMAGE + COMBAT_ICEDAMAGE,
        itemType = US_ITEM_TYPES.WEAPON_ANY + US_ITEM_TYPES.HELMET + US_ITEM_TYPES.LEGS + US_ITEM_TYPES.GLOVES + US_ITEM_TYPES.SHIELD
    },
    [242] = {
        name = "Duality Overpower",
        desc = "Empowers your strikes, greatly increasing Duality Damage as an additional multiplier.",
        category = 1,
        percent = true,
        minLevel = 2000,
        monsterLevel = 500,
        combatDamage = COMBAT_HOLYDAMAGE + COMBAT_DEATHDAMAGE,
        itemType = US_ITEM_TYPES.WEAPON_ANY + US_ITEM_TYPES.HELMET + US_ITEM_TYPES.LEGS + US_ITEM_TYPES.GLOVES + US_ITEM_TYPES.SHIELD
    },
    [243] = {
        name = "Max Relict Box Weight",
        desc = "Increases the maximum weight of the Relict Box.",
        category = 3,
        percent = false,
        minLevel = 2000,
        monsterLevel = 500,
        itemType = US_ITEM_TYPES.WEAPON_ANY + US_ITEM_TYPES.HELMET + US_ITEM_TYPES.LEGS + US_ITEM_TYPES.GLOVES + US_ITEM_TYPES.SHIELD
    },
    [244] = {
        name = "Melee Range",
        desc = "Increases your Melee Range.",
        category = 1,
        percent = false,
        minLevel = 2000,
        combatType = US_TYPES.CONDITION,
        condition = CONDITION_ATTRIBUTES,
        param = CONDITION_PARAM_EXTRARANGEMELEE,
        itemType = US_ITEM_TYPES.ALL,
    },
    [245] = {
        name = "Distance Range",
        desc = "Increases your Distance Range.",
        category = 1,
        percent = false,
        minLevel = 2000,
        combatType = US_TYPES.CONDITION,
        condition = CONDITION_ATTRIBUTES,
        param = CONDITION_PARAM_EXTRARANGERANGE,
        itemType = US_ITEM_TYPES.ALL,
    },
    [246] = {
        name = "Cannot Crititcal",
        desc = "You cannot Critical.",
        category = 1,
        percent = false,
        percentage = false,
        combatType = US_TYPES.CONDITION,
        condition = CONDITION_DISABLECRIT,
        minLevel = 2000,
        itemType = US_ITEM_TYPES.ALL
    },
    [247] = {
        name = "Health Regeneration (%/s)",
        desc = "You receive Health every second.",
        category = 3,
        format = "%.2f",
        percent = true,
        minLevel = 2000,
        itemType = US_ITEM_TYPES.RELICT_UTILITY
    },
    [248] = {
        name = "Energy Shield (%/s)",
        desc = "You receive Energy Shield every second.",
        category = 3,
        format = "%.2f",
        percent = true,
        minLevel = 2000,
        itemType = US_ITEM_TYPES.RELICT_UTILITY
    },
    [249] = {
        name = "Mystic Flask",
        desc = "Increase potion restores Health.",
        category = 3,
    --    format = "%.2f",
        percent = false,
        minLevel = 2000,
        itemType = US_ITEM_TYPES.RELICT_UTILITY
    },
    [250] = {
        name = "Sparkpocalypse",
        desc = "Spell [Spark] fires 10 additional Projectiles.",
        subvalue = 10,
        category = 1,
        percent = true,
        minLevel = 2000,
        noValue = true,
        itemType = US_ITEM_TYPES.ALL
    },
    [251] = {
        name = "Divine Blessing",
        desc = "Increase Duality Damage equal to 2% of your Max Health or Energy Shield (whichever is higher), capped at 400%.",
        subvalue = 0.02,
        category = 1,
        percent = true,
        minLevel = 2000,
        noValue = true,
        itemType = US_ITEM_TYPES.ALL
    },
    [252] = {
        name = "Raw Strength",
        desc = "Increase Phsical Damage equal to 2% of your Max Health or Energy Shield (whichever is higher), capped at 400%.",
        subvalue = 0.02,
        category = 1,
        percent = true,
        minLevel = 2000,
        noValue = true,
        itemType = US_ITEM_TYPES.ALL
    },
    [253] = {
        name = "Frozen Core",
        desc = "3% of your Mana increase Vitality.\n20% of Mana added to Health.",
        subvalue = 0.03, -- 0.01 = 1%
        subvalue2 = 0.20,
        category = 1,
        percent = true,
        minLevel = 2000,
        noValue = true,
        itemType = US_ITEM_TYPES.ALL
    },
    [254] = {
        name = "Void Walker",
        desc = "Killing an elite monster applies a Void Walker stack to you, increasing your Overpower Damage by 20% for 60 seconds. It can stack up to 5 times.",
        subvalue = 1,
        category = 1,
        percent = true,
        minLevel = 2000,
        noValue = true,
        itemType = US_ITEM_TYPES.ALL
    },
    [255] = {
        name = "Shocked Chill",
        desc = "Shock chance is added to Chill chance.",
        subvalue = 0.004, -- 0.005 = 0.5%
        category = 1,
        percent = true,
        minLevel = 2000,
        noValue = true,
        itemType = US_ITEM_TYPES.ALL
    },
    [256] = {
        name = "Focused Strike",
        desc = "Gain 0.55% increased basic damage per 1% Attack Speed, capped at 400%.",
        subvalue = 0.55, -- 0.005 = 0.5%
        category = 1,
        percent = true,
        minLevel = 2000,
        noValue = true,
        itemType = US_ITEM_TYPES.ALL
    },
    [257] = {
        name = "Mana Imbue",
        desc = "10% of Mana is converted to Life. Gain 350% increased Damage while Mana is higher than Life or Energy Shield.",
        subvalue = 1, -- 0.005 = 0.5%
        category = 1,
        percent = true,
        minLevel = 2000,
        noValue = true,
        itemType = US_ITEM_TYPES.ALL
    },
    [258] = {
        name = "Demon Imbue",
        desc = "Converts Counterattack and All Damage to Fire Damage.\nGain +5% Counterattack per 1 Intelligence.",
        subvalue = 5, -- 0.005 = 0.5%
        category = 1,
        percent = true,
        minLevel = 2000,
        noValue = true,
        itemType = US_ITEM_TYPES.ALL
    },
    [259] = {
        name = "Swift Bleeding",
        desc = "Every 10% Attack Speed adds 1 Bleed Stack",
        subvalue = 10, -- 0.005 = 0.5%
        category = 1,
        percent = true,
        minLevel = 2000,
        noValue = true,
        itemType = US_ITEM_TYPES.ALL
    },
    [260] = {
        name = "Soul Piercing",
        desc = "Gain 0.15% Duality Penetration per point of your highest attribute (STR/DEX/INT), capped at 150%.",
        subvalue = 0.15, -- 0.005 = 0.5%
        subvalue2 = 150,
        category = 1,
        percent = true,
        minLevel = 2000,
        noValue = true,
        itemType = US_ITEM_TYPES.ALL
    },
    [261] = {
        name = "Raven Peck",
        desc = "Gain 0.15% Elemental Penetration per point of your highest attribute (STR/DEX/INT), capped at 150%.",
        subvalue = 0.15, -- 0.005 = 0.5%
        subvalue2 = 150,
        category = 1,
        percent = true,
        minLevel = 2000,
        noValue = true,
        itemType = US_ITEM_TYPES.ALL
    },
    [262] = {
        name = "Basic Spells",
        desc = "Increase Basic spell level.",
        category = 1,
        percent = false,
        chance = 50,
        itemType = US_ITEM_TYPES.WEAPON_ANY + US_ITEM_TYPES.RELICT_GOBLIN + US_ITEM_TYPES.RELICT_BOSS + US_ITEM_TYPES.RELICT_STRONGBOX + US_ITEM_TYPES.RELICT_CHAMPION + US_ITEM_TYPES.RELICT_VOIDSTONE
    },
    [263] = {
        name = "Bloody Pact",
        desc = "Gain 0.15% Physical Penetration per point of your highest attribute (STR/DEX/INT), capped at 150%.",
        subvalue = 0.15, -- 0.005 = 0.5%
        subvalue2 = 150,
        category = 1,
        percent = true,
        minLevel = 2000,
        noValue = true,
        itemType = US_ITEM_TYPES.ALL
    },
    [264] = {
        name = "Goblin Spawn Chance",
        desc = "Increases the chance to spawn a Treasure Goblin.",
        category = 1,
        percent = true,
        minLevel = 2000,
        itemType = US_ITEM_TYPES.ALL
    },
    [265] = {
        name = "Champion Spawn Chance",
        desc = "Increases the chance to spawn a Champion.",
        category = 1,
        percent = true,
        minLevel = 2000,
        itemType = US_ITEM_TYPES.ALL
    },
    [266] = {
        name = "Strongbox Spawn Chance",
        desc = "Increases the chance to spawn a Strongbox.",
        category = 1,
        percent = true,
        minLevel = 2000,
        itemType = US_ITEM_TYPES.ALL
    },
    [267] = {
        name = "Boss Clone Chance",
        desc = "Chance to create Boss Clone.",
        category = 1,
        percent = true,
        minLevel = 2000,
        itemType = US_ITEM_TYPES.ALL
    },
    -- All relicts
    [268] = {
        name = "Hunter Insight",
        desc = "Increases damage dealt to event bosses. [Dungeon Boss, Champion, Treasure Goblin Strongbox Boss]",
        category = 1,
        percent = true,
        itemType = US_ITEM_TYPES.RELICT_GOBLIN + US_ITEM_TYPES.RELICT_BOSS + US_ITEM_TYPES.RELICT_STRONGBOX + US_ITEM_TYPES.RELICT_CHAMPION + US_ITEM_TYPES.RELICT_VOIDSTONE
    },
    [269] = {
        name = "Challenging Encounter",
        desc = "Increases event bosses monster level and improves rewards.",
        category = 1,
        percent = false,
        itemType = US_ITEM_TYPES.RELICT_GOBLIN + US_ITEM_TYPES.RELICT_BOSS + US_ITEM_TYPES.RELICT_STRONGBOX + US_ITEM_TYPES.RELICT_CHAMPION + US_ITEM_TYPES.RELICT_VOIDSTONE
    },
    -- Boss/Champion
    [270] = {
        name = "Tactical Advantage",
        desc = "Reduces damage taken from bosses and champions.",
        category = 1,
        percent = true,
        itemType = US_ITEM_TYPES.RELICT_BOSS + US_ITEM_TYPES.RELICT_CHAMPION
    },
    -- Goblin 4
    [271] = {
        name = "Duplication",
        desc = "It gives a chance to spawn two or more goblins.",
        category = 1,
        percent = true,
        itemType = US_ITEM_TYPES.RELICT_GOBLIN
    },
    [272] = {
        name = "Goblin Fortune",
        desc = "Increases the gold and experience gained from goblins.",
        category = 1,
        percent = true,
        itemType = US_ITEM_TYPES.RELICT_GOBLIN
    },
    -- Strongbox 4
    [273] = {
        name = "Monster Horde",
        desc = "Increases the number of monsters spawned from strongboxes.",
        category = 1,
        percent = false,
        itemType = US_ITEM_TYPES.RELICT_STRONGBOX
    },
    [274] = {
        name = "Shiny Box",
        desc = "Strongbox boss grants a random shrine buffs.",
        category = 1,
        percent = true,
        itemType = US_ITEM_TYPES.RELICT_STRONGBOX
    },
    -- Champion 4
    [275] = {
        name = "Clone",
        desc = "It gives a chance to spawn second champion.",
        category = 1,
        percent = true,
        itemType = US_ITEM_TYPES.RELICT_CHAMPION
    },
    -- Boss 4
    [276] = {
        name = "Dungeon Rat",
        desc = "Increases the level of monsters in the dungeon.",
        category = 1,
        percent = false,
        itemType = US_ITEM_TYPES.RELICT_BOSS
    },
    [277] = {
        name = "Spark Speed",
        desc = "Each 1% Movement Speed increases your 0.2% Penetration, capped at 150%.",
        subvalue = 0.2, -- 0.005 = 0.5%
        subvalue2 = 150,
        category = 1,
        percent = true,
        minLevel = 2000,
        noValue = true,
        itemType = US_ITEM_TYPES.ALL
    },
    [278] = {
        name = "Red Speed",
        desc = "Each 1% Attack Speed increases your 0.15% Penetration, capped at 150%.",
        subvalue = 0.15, -- 0.005 = 0.5%
        subvalue2 = 150,
        category = 1,
        percent = true,
        minLevel = 2000,
        noValue = true,
        itemType = US_ITEM_TYPES.ALL
    },
    [279] = {
        name = "Blow Strike",
        desc = "Each 1% Critical Chance increases your 0.75% Penetration, capped at 150%.",
        subvalue = 0.75, -- 0.005 = 0.5%
        subvalue2 = 150,
        category = 1,
        percent = true,
        minLevel = 2000,
        noValue = true,
        itemType = US_ITEM_TYPES.ALL
    },
    [280] = {
        name = "Toxic Synergy",
        desc = "Each 1% of all Ailment Chance increases your 0.25% Penetration, capped at 150%.",
        subvalue = 0.25, -- 0.005 = 0.5%
        subvalue2 = 150,
        category = 1,
        percent = true,
        minLevel = 2000,
        noValue = true,
        itemType = US_ITEM_TYPES.ALL
    },
    [281] = {
        name = "Unstable Fury",
        desc = "Aura [Anger] is supported by a Level 4 Expansion Rune.\nSpell [Groundbreaker] increase area of effect and has a 1 second Cooldown.\nSpell [Seismic Wave] The wave effect is now around you and has been increased.",
        category = 1,
        percent = true,
        noValue = true,
        minLevel = 2000,
    },
    [282] = {
        name = "Unstable Pierce",
        desc = "Spell [Rain of Arrows] increase area of effect and deal 25% more total damage.\nSpell [Ricochet] deal area damage now.\nSpell [Split Arrow] add 5 projectiles.",
        category = 1,
        subvalue = 5,
        percent = true,
        noValue = true,
        minLevel = 2000,
    },
    [283] = {
        name = "Deform",
        desc = "Spell [Dent] increase area of effect, has a 1 second Cooldow and deal 25% more total damage.\nSpell [Shield Bash] wave became longer.",
        category = 1,
        subvalue = 5,
        percent = true,
        noValue = true,
        minLevel = 2000,
    },
    [284] = {
        name = "Plague River",
        desc = "Spell [Plague Burst], [Toxic Arrow] and [Bouncing Venom] increase area of effect and apply extra DoT stack.\nSpell [Venom Arrow Rain] increase area of effect and has a 1 second Cooldow.",
        category = 1,
        subvalue = 5,
        percent = true,
        noValue = true,
        minLevel = 2000,
    },
    [285] = {
        name = "Static Imbue",
        desc = "Spell [Lightning Arrow] add 5 projectiles.\nSpell [Shockchain Arrow] deal area damage.\nSpell [Lightning Barrage] shot 2 extra time.",
        category = 1,
        subvalue = 5,
        subvalue2 = 3,
        percent = true,
        noValue = true,
        minLevel = 2000,
    },
    [286] = {
        name = "Undead Imbue",
        desc = "Spell [Oblivion] hit 2 extra time and has a 1 second Cooldow.\nSpell [Weakness Explosion] increases area of effect.\nSpell [Essence Drain] hit extra 5 targets.",
        category = 1,
        subvalue = 5,
        subvalue2 = 5,
        percent = true,
        noValue = true,
        minLevel = 2000,
    },
    [287] = {
        name = "Holy Imbue",
        desc = "Spell [Smite] applies Holy Weakness, which increases Holy Damage taken by 50%.\nSpell [Holy Scatter] hits all targets in range.\nSpell [Saint Cross] increases area of effect and damage by 50%.",
        category = 1,
        subvalue = 50,
        percent = true,
        noValue = true,
        minLevel = 2000,
    },
    [288] = {
        name = "Void Stone Spawn Chance",
        desc = "Increases the chance to spawn a Strongbox.",
        category = 1,
        percent = true,
        minLevel = 2000,
        itemType = US_ITEM_TYPES.RELICT_VOIDSTONE
    },
    [289] = {
        name = "Void Blessing",
        desc = "Destroying the stone grants a stack of [Void Blessing] each stack adds 2% Overpower Damage for 5 minutes.",
        category = 1,
        percent = false,
        noValue = true,
        minLevel = 2000,
        itemType = US_ITEM_TYPES.RELICT_VOIDSTONE
    },
    [290] = {
        name = "Bloody Imbue",
        desc = "Spell [Hemorrhage Nova] increase area of effect and deal 50% more total damage.\nSpell [Bloody Skulls] and [Rend] increase area of effect.\nSpell [Perforate] hits all targets in range.",
        category = 1,
        subvalue = 50,
        percent = true,
        noValue = true,
        minLevel = 2000,
    },
    [291] = {
        name = "Penetration",
        desc = "Penetration is a property of hits that reduces the target's effective resistance.",
        category = 1,
        percent = true,
        minLevel = 2000,
        itemType = US_ITEM_TYPES.WEAPON_ANY
    },
}

REDUCTION_ATTR_VALUES = {
[289] = {
    [1] = {1, 1}, [2] = {2, 2}, [3] = {3, 3}, [4] = {4, 4}, [5] = {5, 5}, [6] = {7, 7}, [7] = {10, 10}
}, -- "Void Blessing"
[268] = {
    [1] = {10, 13}, [2] = {14, 16}, [3] = {17, 20}, [4] = {21, 30}, [5] = {29, 34}, [6] = {35, 41}, [7] = {42, 50}
}, -- "Hunters Insight"
[269] = {
    [1] = {5, 8}, [2] = {9, 13}, [3] = {14, 20}, [4] = {21, 30}, [5] = {50, 60}, [6] = {70, 90}, [7] = {110, 150}
}, -- Challenging Encounter
[270] = {
    [1] = {3, 4}, [2] = {5, 6}, [3] = {7, 8}, [4] = {9, 13}, [5] = {14, 20}, [6] = {21, 26}, [7] = {27, 35}
}, -- Tactical Advantage
[271] = {
    [1] = {5, 6}, [2] = {7, 8}, [3] = {9, 11}, [4] = {14, 18}, [5] = {20, 30}, [6] = {40, 50}, [7] = {60, 75}
}, -- Duplication
[272] = {
    [1] = {10, 13}, [2] = {14, 16}, [3] = {17, 20}, [4] = {25, 30}, [5] = {40, 50}, [6] = {60, 70}, [7] = {80, 90}
}, -- Goblins Fortune
[273] = {
    [1] = {2, 2}, [2] = {3, 4}, [3] = {5, 6}, [4] = {7, 8}, [5] = {9, 12}, [6] = {13, 16}, [7] = {17, 20}
}, -- Monster Horde
[274] = {
    [1] = {5, 10}, [2] = {11, 15}, [3] = {16, 29}, [4] = {30, 40}, [5] = {50, 60}, [6] = {70, 80}, [7] = {90, 100}
}, -- Shiny Box
[275] = {
    [1] = {3, 4}, [2] = {5, 6}, [3] = {7, 8}, [4] = {9, 13}, [5] = {14, 20}, [6] = {21, 26}, [7] = {27, 35}
}, -- Clone
[276] = {
    [1] = {3, 4}, [2] = {5, 6}, [3] = {7, 8}, [4] = {9, 13}, [5] = {14, 24}, [6] = {25, 30}, [7] = {40, 50}
}, -- Dungeon Rat

[199] = {
    [1] = {10, 13}, [2] = {14, 16}, [3] = {17, 20}, [4] = {21, 30}, [5] = {29, 34}, [6] = {35, 41}, [7] = {42, 50}
}, -- Health on Block
[200] = {
    [1] = {10, 13}, [2] = {14, 16}, [3] = {17, 20}, [4] = {21, 30}, [5] = {29, 34}, [6] = {35, 41}, [7] = {42, 50}
}, -- Energy Shield on Block
[201] = {
	[1] = {1, 2}, [2] = {3, 4}, [3] = {5, 6}, [4] = {7, 8}, [5] = {9, 10}, [6] = {11, 12}, [7] = {13, 14}
}, -- Mana On Hit
[63] = {
    [1] = {2, 3}, [2] = {4, 6}, [3] = {7, 9}, [4] = {10, 13}, [5] = {14, 19}, [6] = {20, 25}, [7] = {26, 35}
}, -- Endurance
[123] = {
    [1] = {8, 10}, [2] = {11, 14}, [3] = {15, 18}, [4] = {19, 22}, [5] = {23, 26}, [6] = {27, 30}, [7] = {31, 35}
 }, -- Quick Heal
[95] = {
    [1] = {30, 50}, [2] = {60, 80}, [3] = {90, 110}, [4] = {120, 150}, [5] = {180, 210}, [6] = {271, 310}, [7] = {400, 500}
}, -- Health Recovery
[119] = {
    [1] = {50, 70}, [2] = {90, 110}, [3] = {120, 160}, [4] = {200, 300}, [5] = {340, 400}, [6] = {500, 700}, [7] = {800, 1000}
}, -- Energy Shield Recovery
[118] = {
    [1] = {10, 15}, [2] = {16, 20}, [3] = {21, 25}, [4] = {26, 30}, [5] = {31, 35}, [6] = {36, 40}, [7] = {41, 50}
}, -- Haste on use
[115] = {
    [1] = {13, 17}, [2] = {18, 22}, [3] = {23, 25}, [4] = {26, 37}, [5] = {40, 50}, [6] = {60, 70}, [7] = {80, 100}
}, -- Mana Recover
[116] = {
    [1] = {1, 1}, [2] = {2, 2}, [3] = {3, 3}, [4] = {4, 4}, [5] = {5, 5}, [6] = {6, 6}, [7] = {7, 10}
}, -- Health also applies to Energy Shield
[117] = {
    [1] = {10, 13}, [2] = {14, 16}, [3] = {17, 26}, [4] = {31, 49}, [5] = {54, 67}, [6] = {69, 80}, [7] = {90, 100}
}, -- Mana Spent gained as Energy Shield
[110] = {
    [1] = {3, 4}, [2] = {5, 7}, [3] = {8, 10}, [4] = {11, 13}, [5] = {14, 16}, [6] = {17, 20}, [7] = {25, 30}
 }, -- Mana Percent
[109] = {
   [1] = {3, 4}, [2] = {5, 7}, [3] = {8, 10}, [4] = {11, 13}, [5] = {14, 16}, [6] = {17, 20}, [7] = {25, 30}
}, -- Health Percent
[100] = {
    [1] = {1, 3}, [2] = {4, 6}, [3] = {7, 9}, [4] = {10, 12}, [5] = {13, 15}, [6] = {16, 19}, [7] = {20, 25}
}, -- fire spells
[101] = {
    [1] = {1, 3}, [2] = {4, 6}, [3] = {7, 9}, [4] = {10, 12}, [5] = {13, 15}, [6] = {16, 19}, [7] = {20, 25}
}, -- ice spells
[102] = {
    [1] = {1, 3}, [2] = {4, 6}, [3] = {7, 9}, [4] = {10, 12}, [5] = {13, 15}, [6] = {16, 19}, [7] = {20, 25}
}, -- Lightning spells
[103] = {
    [1] = {1, 3}, [2] = {4, 6}, [3] = {7, 9}, [4] = {10, 12}, [5] = {13, 15}, [6] = {16, 19}, [7] = {20, 25}
}, -- earth spells
[104] = {
    [1] = {1, 3}, [2] = {4, 6}, [3] = {7, 9}, [4] = {10, 12}, [5] = {13, 15}, [6] = {16, 19}, [7] = {20, 25}
}, -- death spells
[105] = {
    [1] = {1, 3}, [2] = {4, 6}, [3] = {7, 9}, [4] = {10, 12}, [5] = {13, 15}, [6] = {16, 19}, [7] = {20, 25}
}, -- holy spells
[106] = {
    [1] = {1, 3}, [2] = {4, 6}, [3] = {7, 9}, [4] = {10, 12}, [5] = {13, 15}, [6] = {16, 19}, [7] = {20, 25}
}, -- physical spells
[107] = {
    [1] = {1, 2}, [2] = {3, 4}, [3] = {5, 6}, [4] = {7, 8}, [5] = {9, 10}, [6] = {11, 14}, [7] = {15, 20}
}, -- all spells
[228] = {
    [1] = {1, 2}, [2] = {3, 4}, [3] = {5, 6}, [4] = {7, 8}, [5] = {9, 10}, [6] = {11, 14}, [7] = {15, 20}
}, -- Elemental spells
[262] = {
    [1] = {1, 2}, [2] = {3, 4}, [3] = {5, 6}, [4] = {7, 8}, [5] = {9, 10}, [6] = {11, 14}, [7] = {15, 20}
}, -- Basic spells
[229] = {
    [1] = {1, 2}, [2] = {3, 4}, [3] = {5, 6}, [4] = {7, 8}, [5] = {9, 10}, [6] = {11, 14}, [7] = {15, 20}
}, -- Physical spells
[230] = {
    [1] = {1, 2}, [2] = {3, 4}, [3] = {5, 6}, [4] = {7, 8}, [5] = {9, 10}, [6] = {11, 14}, [7] = {15, 20}
}, -- Duality spells
	-- atrybuty maja 7 tierow craftowac mozna do t5 a wypadaja specialne od t6-7
[89] = {
	[1] = {2, 3}, [2] = {4, 5}, [3] = {6, 7}, [4] = {8, 9}, [5] = {10, 11}, [6] = {12, 14}, [7] = {16, 18}
}, -- melee damage
[90] = {
	[1] = {2, 3}, [2] = {4, 5}, [3] = {6, 7}, [4] = {8, 9}, [5] = {10, 11}, [6] = {12, 14}, [7] = {16, 18}
}, -- magic damage
[91] = {
	[1] = {2, 3}, [2] = {4, 5}, [3] = {6, 7}, [4] = {8, 9}, [5] = {10, 11}, [6] = {12, 14}, [7] = {16, 18}
}, -- distance damage
[80] = {
	[1] = {50, 70}, [2] = {80, 100}, [3] = {110, 130}, [4] = {140, 160}, [5] = {200, 250}, [6] = {350, 400}, [7] = {500, 800}
}, -- Health Gain on Kill
[81] = {
	[1] = {7, 10}, [2] = {11, 17}, [3] = {18, 25}, [4] = {26, 34}, [5] = {35, 45}, [6] = {46, 55}, [7] = {65, 75}
}, -- Mana Gain on Kill
[82] = {
	[1] = {50, 70}, [2] = {80, 100}, [3] = {110, 130}, [4] = {140, 160}, [5] = {200, 250}, [6] = {350, 400}, [7] = {500, 800}
}, -- Energy Shield Gain on Kill
[72] = {
	[1] = {3, 4}, [2] = {5, 7}, [3] = {8, 10}, [4] = {11, 13}, [5] = {14, 16}, [6] = {17, 20}, [7] = {21, 26}
}, -- Energy Shield Percent
[73] = {
	[1] = {2, 4}, [2] = {5, 7}, [3] = {8, 10}, [4] = {11, 15}, [5] = {16, 20}, [6] = {21, 25}, [7] = {26, 30}
}, -- Energy Shield Recharge Rate OFF
[64] = {
	[1] = {3, 6}, [2] = {7, 11}, [3] = {12, 16}, [4] = {17, 22}, [5] = {23, 28}, [6] = {29, 40}, [7] = {41, 50} -- X
}, -- Added Fire Damage
[65] = {
	[1] = {3, 6}, [2] = {7, 11}, [3] = {12, 16}, [4] = {17, 22}, [5] = {23, 28}, [6] = {29, 40}, [7] = {41, 50} -- X
}, -- Added Ice Damage
[66] = {
	[1] = {3, 6}, [2] = {7, 11}, [3] = {12, 16}, [4] = {17, 22}, [5] = {23, 28}, [6] = {29, 40}, [7] = {41, 50} -- X
}, -- Added Earth Damage
[67] = {
	[1] = {3, 6}, [2] = {7, 11}, [3] = {12, 16}, [4] = {17, 22}, [5] = {23, 28}, [6] = {29, 40}, [7] = {41, 50} -- X
}, -- Added Lightning Damage
[68] = {
	[1] = {3, 6}, [2] = {7, 11}, [3] = {12, 16}, [4] = {17, 22}, [5] = {23, 28}, [6] = {29, 40}, [7] = {41, 50} -- X
}, -- Added Death Damage
[69] = {
	[1] = {3, 6}, [2] = {7, 11}, [3] = {12, 16}, [4] = {17, 22}, [5] = {23, 28}, [6] = {29, 40}, [7] = {41, 50} -- X
}, -- Added Holy Damage
[70] = {
	[1] = {3, 6}, [2] = {7, 11}, [3] = {12, 16}, [4] = {17, 22}, [5] = {23, 28}, [6] = {29, 40}, [7] = {41, 50} -- X
}, -- Added Physical Damage
[48] = {
	[1] = {2, 3}, [2] = {4, 5}, [3] = {6, 7}, [4] = {8, 9}, [5] = {10, 11}, [6] = {12, 13}, [7] = {14, 17}
}, -- Mana cost
[46] = {
	[1] = {7, 6}, [2] = {7, 9}, [3] = {12, 15}, [4] = {20, 25}, [5] = {30, 40}, [6] = {60, 70}, [7] = {120, 150}
}, -- Health On Hit
[111] = {
	[1] = {7, 6}, [2] = {7, 9}, [3] = {12, 15}, [4] = {20, 25}, [5] = {30, 40}, [6] = {60, 70}, [7] = {120, 150}
}, -- Energy Shield On Hit
[21] = {
	[1] = {6, 7}, [2] = {8, 9}, [3] = {10, 12}, [4] = {13, 15}, [5] = {16, 20}, [6] = {21, 24}, [7] = {25, 30}
}, -- Bleed
[28] = {
	[1] = {6, 7}, [2] = {8, 9}, [3] = {10, 12}, [4] = {13, 15}, [5] = {16, 20}, [6] = {21, 24}, [7] = {25, 30}
}, -- Ignite
[32] = {
	[1] = {6, 7}, [2] = {8, 9}, [3] = {10, 12}, [4] = {13, 15}, [5] = {16, 20}, [6] = {21, 24}, [7] = {25, 30}
}, -- Poison
[37] = {
	[1] = {6, 7}, [2] = {8, 9}, [3] = {10, 12}, [4] = {13, 15}, [5] = {16, 20}, [6] = {21, 24}, [7] = {25, 30}
}, -- Chill
[41] = {
	[1] = {6, 7}, [2] = {8, 9}, [3] = {10, 12}, [4] = {13, 15}, [5] = {16, 20}, [6] = {21, 24}, [7] = {25, 30}
}, -- Shock
[42] = {
	[1] = {6, 7}, [2] = {8, 9}, [3] = {10, 12}, [4] = {13, 15}, [5] = {16, 20}, [6] = {21, 24}, [7] = {25, 30}
}, -- Harvest
[45] = {
	[1] = {6, 7}, [2] = {8, 9}, [3] = {10, 12}, [4] = {13, 15}, [5] = {16, 20}, [6] = {21, 24}, [7] = {25, 30}
}, -- Suppression

[1] = {
	-- [1] = {50, 70}, [2] = {80, 130}, [3] = {185, 230}, [4] = {290, 330}, [5] = {380, 450}, [6] = {580, 700}, [7] = {1000, 1200}
    --[1] = {150, 160}, [2] = {170, 260}, [3] = {270, 360}, [4] = {370, 470}, [5] = {480, 570}, [6] = {580, 700}, [7] = {1000, 1200}
    [1] = {220, 280}, [2] = {313, 365}, [3] = {388, 450}, [4] = {463, 588}, [5] = {680, 763}, [6] = {825, 975}, [7] = {1250, 1500}
}, -- Max Health
[2] = {
    [1] = {150, 160}, [2] = {170, 260}, [3] = {270, 360}, [4] = {370, 470}, [5] = {480, 570}, [6] = {580, 700}, [7] = {1000, 1200}
--	[1] = {50, 70}, [2] = {80, 130}, [3] = {185, 230}, [4] = {290, 330}, [5] = {380, 450}, [6] = {580, 700}, [7] = {1000, 1200} -- przed startem 2.0
--  [1] = {180, 250}, [2] = {380, 495}, [3] = {577, 645}, [4] = {735, 885}, [5] = {975, 1175}, [6] = {1370, 1550}, [7] = {1700, 1800} -- przesadzilem 2.0
}, -- Max Mana
[71] = {
	--[1] = {150, 160}, [2] = {170, 260}, [3] = {270, 360}, [4] = {370, 470}, [5] = {480, 570}, [6] = {580, 700}, [7] = {1000, 1200}
    [1] = {220, 280}, [2] = {313, 365}, [3] = {388, 450}, [4] = {463, 588}, [5] = {680, 763}, [6] = {825, 975}, [7] = {1250, 1500}
}, -- Energy Shield
[3] = {
	[1] = {1, 3}, [2] = {4, 7}, [3] = {8, 9}, [4] = {10, 11}, [5] = {12, 17}, [6] = {18, 23}, [7] = {30, 37}
}, -- Strength
[4] = {
	[1] = {1, 3}, [2] = {4, 7}, [3] = {8, 9}, [4] = {10, 11}, [5] = {12, 17}, [6] = {18, 23}, [7] = {30, 37}
}, -- Intelligence
[5] = {
	[1] = {1, 3}, [2] = {4, 7}, [3] = {8, 9}, [4] = {10, 11}, [5] = {12, 17}, [6] = {18, 23}, [7] = {30, 37}
}, -- Dexterity
[6] = {
	[1] = {1, 1}, [2] = {2, 2}, [3] = {3, 3}, [4] = {4, 5}, [5] = {6, 7}, [6] = {8, 10}, [7] = {15, 20}
}, -- All Attributes
[7] = {
	[1] = {3, 4}, [2] = {5, 7}, [3] = {8, 13}, [4] = {14, 19}, [5] = {20, 26}, [6] = {27, 33}, [7] = {45, 60}
}, -- Vitality
[9] = {
	[1] = {1, 1}, [2] = {2, 2}, [3] = {3, 3}, [4] = {4, 5}, [5] = {6, 7}, [6] = {8, 9}, [7] = {12, 15}
}, -- Dodge
[97] = {
	[1] = {2, 3}, [2] = {4, 5}, [3] = {6, 7}, [4] = {8, 9}, [5] = {10, 11}, [6] = {12, 14}, [7] = {16, 18}
}, -- Parry OFF
[35] = {
	[1] = {1, 1}, [2] = {2, 2}, [3] = {3, 3}, [4] = {4, 5}, [5] = {6, 7}, [6] = {8, 9}, [7] = {12, 15}
}, -- Avoid
[10] = {
	[1] = {2, 3}, [2] = {4, 5}, [3] = {6, 7}, [4] = {8, 9}, [5] = {10, 11}, [6] = {12, 14}, [7] = {20, 25}
}, -- EXP
[11] = {
	[1] = {10, 15}, [2] = {16, 22}, [3] = {23, 29}, [4] = {30, 35}, [5] = {36, 39}, [6] = {40, 45}, [7] = {65, 80}
}, -- Physical Damage
[57] = {
	[1] = {10, 15}, [2] = {16, 22}, [3] = {23, 29}, [4] = {30, 35}, [5] = {36, 39}, [6] = {40, 45}, [7] = {65, 80}
}, -- Fire Damage
[58] = {
	[1] = {10, 15}, [2] = {16, 22}, [3] = {23, 29}, [4] = {30, 35}, [5] = {36, 39}, [6] = {40, 45}, [7] = {65, 80}
}, -- Ice Damage
[59] = {
	[1] = {10, 15}, [2] = {16, 22}, [3] = {23, 29}, [4] = {30, 35}, [5] = {36, 39}, [6] = {40, 45}, [7] = {65, 80}
}, -- Lightning Damage
[60] = {
	[1] = {10, 15}, [2] = {16, 22}, [3] = {23, 29}, [4] = {30, 35}, [5] = {36, 39}, [6] = {40, 45}, [7] = {65, 80}
}, -- Earth Damage
[61] = {
	[1] = {10, 15}, [2] = {16, 22}, [3] = {23, 29}, [4] = {30, 35}, [5] = {36, 39}, [6] = {40, 45}, [7] = {65, 80}
}, -- Death Damage
[62] = {
	[1] = {10, 15}, [2] = {16, 22}, [3] = {23, 29}, [4] = {30, 35}, [5] = {36, 39}, [6] = {40, 45}, [7] = {65, 80}
}, -- Holy Damage
[12] = {
	[1] = {10, 15}, [2] = {16, 22}, [3] = {23, 29}, [4] = {30, 35}, [5] = {36, 39}, [6] = {40, 45}, [7] = {65, 80}
}, -- Elemental Damage
[108] = {
	[1] = {10, 15}, [2] = {16, 22}, [3] = {23, 29}, [4] = {30, 35}, [5] = {36, 39}, [6] = {40, 45}, [7] = {65, 80}
}, -- Brute Damage
[196] = {
	[1] = {10, 15}, [2] = {16, 22}, [3] = {23, 29}, [4] = {30, 35}, [5] = {36, 39}, [6] = {40, 45}, [7] = {65, 80}
}, -- Duality Damage
[13] = {
    [1] = {10, 13}, [2] = {14, 15}, [3] = {16, 17}, [4] = {18, 21}, [5] = {22, 25}, [6] = {26, 31}, [7] = {35, 40}
}, -- Physical Protection
[14] = {
   [1] = {10, 13}, [2] = {14, 15}, [3] = {16, 17}, [4] = {18, 21}, [5] = {22, 25}, [6] = {26, 31}, [7] = {35, 40}
}, -- Elemental Protection
[197] = {
    [1] = {10, 13}, [2] = {14, 15}, [3] = {16, 17}, [4] = {18, 21}, [5] = {22, 25}, [6] = {26, 31}, [7] = {35, 40}
}, -- Duality Protection
[237] = {
    [1] = {4, 5}, [2] = {6, 7}, [3] = {8, 10}, [4] = {11, 13}, [5] = {14, 16}, [6] = {17, 19}, [7] = {20, 22}
}, -- Physical Mitigation
[238] = {
    [1] = {4, 5}, [2] = {6, 7}, [3] = {8, 10}, [4] = {11, 13}, [5] = {14, 16}, [6] = {17, 19}, [7] = {20, 22}
}, -- Elemental Mitigation
[239] = {
    [1] = {4, 5}, [2] = {6, 7}, [3] = {8, 10}, [4] = {11, 13}, [5] = {14, 16}, [6] = {17, 19}, [7] = {20, 22}
}, -- Duality Mitigation
[16] = {
	[1] = {8, 10}, [2] = {11, 14}, [3] = {15, 17}, [4] = {18, 22}, [5] = {23, 27}, [6] = {28, 35}, [7] = {42, 52}
}, -- Recovery Effectiveness
[17] = {
	[1] = {6, 9}, [2] = {11, 17}, [3] = {19, 24}, [4] = {25, 29}, [5] = {30, 36}, [6] = {37, 44}, [7] = {50, 60}
}, -- Gold
[18] = {
	[1] = {10, 15}, [2] = {16, 22}, [3] = {23, 29}, [4] = {30, 35}, [5] = {36, 39}, [6] = {40, 45}, [7] = {65, 80}
}, -- Spell Damage
[19] = {
	--[1] = {10, 15}, [2] = {16, 22}, [3] = {23, 29}, [4] = {30, 35}, [5] = {36, 39}, [6] = {40, 45}, [7] = {65, 80}
    [1] = {15, 23}, [2] = {24, 33}, [3] = {35, 44}, [4] = {45, 53}, [5] = {54, 66}, [6] = {70, 85}, [7] = {98, 120}
}, -- Basic Damage
[23] = {
	--[1] = {10, 18}, [2] = {19, 25}, [3] = {30, 40}, [4] = {45, 60}, [5] = {65, 80}, [6] = {90, 120}, [7] = {220, 300}
    [1] = {18, 20}, [2] = {30, 40}, [3] = {50, 70}, [4] = {80, 110}, [5] = {165, 200}, [6] = {290, 350}, [7] = {400, 500}
}, -- Health Regeneration
[24] = {
	[1] = {2, 3}, [2] = {4, 5}, [3] = {6, 9}, [4] = {10, 13}, [5] = {14, 17}, [6] = {18, 25}, [7] = {35, 40}
}, -- Mana Regeneration
[26] = {
	--[1] = {10, 18}, [2] = {19, 25}, [3] = {30, 40}, [4] = {45, 60}, [5] = {65, 80}, [6] = {90, 120}, [7] = {220, 300}
    [1] = {18, 20}, [2] = {30, 40}, [3] = {50, 70}, [4] = {80, 110}, [5] = {165, 200}, [6] = {290, 350}, [7] = {400, 500}
}, -- Energy Shield Regeneration
[27] = {
	[1] = {10, 15}, [2] = {16, 19}, [3] = {20, 25}, [4] = {26, 30}, [5] = {31, 35}, [6] = {36, 40}, [7] = {50, 60}
}, -- Movement Speed
[29] = {
	[1] = {1, 1}, [2] = {2, 2}, [3] = {3, 3}, [4] = {4, 5}, [5] = {5, 6}, [6] = {7, 8}, [7] = {11, 15}
}, -- Critical Chance
[30] = {
	[1] = {2, 5}, [2] = {6, 8}, [3] = {9, 11}, [4] = {12, 14}, [5] = {15, 19}, [6] = {20, 25}, [7] = {30, 35}
}, -- Critical Damage
[31] = {
	[1] = {2, 3}, [2] = {4, 5}, [3] = {6, 7}, [4] = {8, 9}, [5] = {10, 11}, [6] = {12, 15}, [7] = {20, 25}
}, -- Physical Penetration
[33] = {
	[1] = {4, 10}, [2] = {11, 13}, [3] = {14, 19}, [4] = {20, 29}, [5] = {30, 45}, [6] = {46, 55}, [7] = {56, 70}
}, -- Boss Damage special
[34] = {
	[1] = {2, 3}, [2] = {4, 5}, [3] = {6, 7}, [4] = {8, 9}, [5] = {10, 11}, [6] = {15, 18}, [7] = {25, 30}
}, -- Mastery
[36] = {
	[1] = {4, 10}, [2] = {11, 13}, [3] = {14, 19}, [4] = {20, 29}, [5] = {30, 45}, [6] = {46, 55}, [7] = {56, 70}
}, -- Elite Damage special
[43] = {
	[1] = {2, 3}, [2] = {4, 5}, [3] = {6, 7}, [4] = {8, 9}, [5] = {10, 11}, [6] = {15, 18}, [7] = {21, 25}
}, -- Force OFF
[44] = {
	[1] = {2, 3}, [2] = {4, 5}, [3] = {6, 7}, [4] = {8, 9}, [5] = {10, 11}, [6] = {15, 18}, [7] = {21, 25}
}, -- Sorcery OFF
[47] = {
	--[1] = {10, 15}, [2] = {16, 22}, [3] = {23, 29}, [4] = {30, 35}, [5] = {36, 39}, [6] = {40, 45}, [7] = {65, 80}
    [1] = {18, 27}, [2] = {28, 39}, [3] = {41, 51}, [4] = {53, 59}, [5] = {60, 73}, [6] = {80, 90}, [7] = {114, 140}
}, -- DoT Damage
[49] = {
	[1] = {10, 15}, [2] = {16, 22}, [3] = {23, 29}, [4] = {30, 35}, [5] = {36, 39}, [6] = {40, 45}, [7] = {65, 80}
}, -- Counterattack
[53] = {
	[1] = {5, 9}, [2] = {10, 14}, [3] = {15, 19}, [4] = {20, 27}, [5] = {30, 40}, [6] = {50, 70}, [7] = {120, 180}
}, -- extra armor
[96] = {
	[1] = {11, 19}, [2] = {20, 30}, [3] = {40, 55}, [4] = {65, 80}, [5] = {90, 110}, [6] = {120, 170}, [7] = {230, 350}
}, -- extra defense
[54] = {
    [1] = {5, 10}, [2] = {11, 15}, [3] = {16, 25}, [4] = {26, 32}, [5] = {33, 40}, [6] = {41, 55}, [7] = {65, 75}
}, -- Cast Damage
[55] = {
	--[1] = {4, 5}, [2] = {6, 8}, [3] = {9, 11}, [4] = {12, 14}, [5] = {15, 18}, [6] = {20, 25}, [7] = {35, 45}
    [1] = {10, 11}, [2] = {12, 14}, [3] = {15, 19}, [4] = {20, 24}, [5] = {25, 29}, [6] = {30, 35}, [7] = {42, 54}
}, -- Attack Speed
[56] = {
	[1] = {2, 2}, [2] = {3, 3}, [3] = {4, 4}, [4] = {5, 5}, [5] = {6, 7}, [6] = {8, 9}, [7] = {13, 15}
}, -- Cooldown Reduction
[74] = {
	[1] = {1, 4}, [2] = {5, 7}, [3] = {8, 10}, [4] = {11, 13}, [5] = {14, 17}, [6] = {18, 21}, [7] = {30, 35}
}, -- Health Regeneration Percent
[75] = {
	[1] = {10, 13}, [2] = {14, 17}, [3] = {18, 21}, [4] = {22, 26}, [5] = {27, 30}, [6] = {31, 34}, [7] = {42, 50}
}, -- Mana Regeneration Percent
[122] = {
	[1] = {2, 3}, [2] = {4, 5}, [3] = {6, 7}, [4] = {8, 9}, [5] = {10, 11}, [6] = {12, 15}, [7] = {20, 25}
}, -- Elemental Penetration
[198] = {
	[1] = {2, 3}, [2] = {4, 5}, [3] = {6, 7}, [4] = {8, 9}, [5] = {10, 11}, [6] = {12, 15}, [7] = {20, 25}
}, -- Duality Penetration
}
