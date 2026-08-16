--[[ --------------------------------------------------------------------------------------------------------------------------------------
		Author: Leo32
		File: lib/attributes.lua
		
		This is the attributes & rarity library.
		It contains all the functions used to roll 'rare', 'epic' or 'legendary' on items & apply the custom buff conditions (+Skill, +Max Health)
		(!) Rolls that affect combat require the file creatureevents/scripts/attributes.lua
		
		Config:
		stats {}

			stats[i].attribute
			stats[i].base
			stats[i].items
		
			[i] = { 
				attribute = {
					name = 'Attack',
					rare = {1, 3}, -- Customize roll numbers here
					epic = {4, 6},
					legendary = {7, 10},
				},
				value = "Percent" -- What type of roll is it? Percent/Static/Damage/Duration
				base = ITEM_ATTRIBUTE_ATTACK, -- If attribute is a vanilla stat, it should have a default or 'base' amount, what is it? (rollBase)
				items = {
					2392, -- These are specifically targeted items, that can roll this attribute.
					2414 
				}
			},
--]] --------------------------------------------------------------------------------------------------------------------------------------

stats = { -- Define the attribute and their rolls
	[1] = { -- Attack
		attribute = {
			name = 'Attack',
			rare = {1, 3}, -- Customize roll numbers here
			epic = {4, 6},
			legendary = {7, 10},
			perf = {7, 10},
		},
		value = "Static",
		base = ITEM_ATTRIBUTE_ATTACK -- If attribute is a vanilla stat, it should have a default or 'base' amount, what is it?
	},
	[2] = { -- Defense
		attribute = {
			name = 'Defense',
			rare = {1, 2},
			epic = {3, 4},
			legendary = {5, 6},
			perf = {7, 10},
		},
		value = "Static",
		base = ITEM_ATTRIBUTE_DEFENSE
	},
	[3] = { -- Extra Defense
		attribute = {
			name = 'Extra Defense',
			rare = {1, 1},
			epic = {2, 3},
			legendary = {4, 5},
			perf = {7, 10},
		},
		value = "Static",
		base = ITEM_ATTRIBUTE_EXTRADEFENSE	
	},
	[4] = { -- Armor
		attribute = {
			name = 'Armor',
			rare = {1, 1},
			epic = {2, 3},
			legendary = {4, 5},
			perf = {7, 10},
		},
		value = "Static",
		base = ITEM_ATTRIBUTE_ARMOR
	},
	[5] = { -- Accuracy
		attribute = {
			name = 'Accuracy',
			rare = {1, 5},
			epic = {6, 10},
			legendary = {11, 15},
			perf = {7, 10},
		},
		value = "Percent",
		base = ITEM_ATTRIBUTE_HITCHANCE
	},
	[6] = { -- Range
		attribute = {
			name = 'Range',
			rare = {1, 1},
			epic = {1, 1},
			legendary = {1, 1},
			perf = {1, 1},
		},
		value = "Static",
		base = ITEM_ATTRIBUTE_SHOOTRANGE
	},
	[7] = { -- Equipment with < 50 charges
		attribute = {
			name = 'Charges',
			rare = {5, 10},
			epic = {15, 20},
			legendary = {31, 35},
			perf = {40, 50},
		},
		value = "Static",
		base = ITEM_ATTRIBUTE_CHARGES
	},
	[8] = { -- Equipment with >= 50 charges
		attribute = {
			name = 'Charges',
			rare = {100, 250},
			epic = {350, 500},
			legendary = {1000, 2000},
			perf = {2000, 3000},
		},
		value = "Static",
		base = ITEM_ATTRIBUTE_CHARGES
	},
	[9] = { -- Time
		attribute = {
			name = 'Time',
			rare = {300000, 300000},
			epic = {900000, 900000},
			legendary = {2700000, 2700000},
			perf = {3700000, 3700000},
			
		},
		value = "Duration",
		base = ITEM_ATTRIBUTE_DURATION
	},
	[10] = { -- Crit Amount (Currently Unused)
		attribute = {
			name = 'Critical Hit Damage',
			rare = {1, 2},
			epic = {3, 4},
			legendary = {5, 6},
			perf = {7, 8},
		},
		value = "Percent",
	},
	[11] = { -- Crit Chance
		attribute = {
			name = 'Critical Chance',
			rare = {1, 2},
			epic = {3, 4},
			legendary = {5, 6},
			perf = {7, 8},
		},
		value = "Percent",
	},
	[12] = { -- Fire Damage
		attribute = {
			name = 'Enhanced Fire Damage',
			rare = {1, 2},
			epic = {3, 5},
			legendary = {5, 7},
			perf = {7, 9},
		},
		value = "Damage"
	},
	[13] = { -- Ice Damage
		attribute = {
			name = 'Enhanced Ice Damage',
			rare = {1, 2},
			epic = {3, 5},
			legendary = {5, 7},
			perf = {7, 9},
		},
		value = "Damage"
	},
	[14] = { -- Energy Damage
		attribute = {
			name = 'Enhanced Energy Damage',
			rare = {1, 3},
			epic = {5, 7},
			legendary = {7, 10},
			perf = {9, 13},
		},
		value = "Damage"
	},
	[15] = { -- Fire Resistance
		attribute = {
			name = 'Fire Protection',
			rare = {1, 2},
			epic = {2, 3},
			legendary = {4, 5},
			perf = {6, 7},
		},
		value = "Percent"
	},
	[16] = { -- Ice Resistance
		attribute = {
			name = 'Ice Protection',
			rare = {1, 2},
			epic = {2, 3},
			legendary = {4, 5},
			perf = {6, 7},
		},
		value = "Percent"
	},
	[17] = { -- Energy Resistance
		attribute = {
			name = 'Energy Protection',
			rare = {1, 2},
			epic = {2, 3},
			legendary = {4, 5},
			perf = {6, 7},
		},
		value = "Percent"
	},
	[18] = { -- Earth Resistance
		attribute = {
			name = 'Earth Protection',
			rare = {1, 2},
			epic = {2, 3},
			legendary = {4, 5},
			perf = {6, 7},
		},
		value = "Percent"
	},
	[19] = { -- Physical Resistance
		attribute = {
			name = 'Physical Protection',
			rare = {1, 2},
			epic = {2, 3},
			legendary = {4, 5},
			perf = {6, 7},
		},
		value = "Percent"
	},
	[20] = { -- Death Resistance
		attribute = {
			name = 'Death Protection',
			rare = {1, 2},
			epic = {2, 3},
			legendary = {4, 5},
			perf = {6, 7},
		},
		value = "Percent"
	},
	[21] = { -- Holy Resistance
		attribute = {
			name = 'Holy Protection',
			rare = {1, 2},
			epic = {2, 3},
			legendary = {4, 5},
			perf = {6, 7},
		},
		value = "Percent"
	},
	[22] = { -- Multi Shot
		attribute = {
			name = 'Multi Shot',
			rare = {1, 1},
			epic = {1, 1},
			legendary = {2, 2},
			perf = {2, 2},
		},
		value = "Static"
		-- Items targeted by this attribute are defined in a different way below.
	},
	[23] = { -- Stun Chance
		attribute = {
			name = 'Stun Chance',
			rare = {1, 1},
			epic = {2, 3},
			legendary = {4, 5},
			perf = {6, 7},
		},
		value = "Percent"
	},
	[24] = { -- Mana Shield
		atrribute = {
			name = 'Mana Shield',
			rare = {5, 10},
			epic = {11, 20},
			legendary = {21, 30},
			perf = {30, 35},
		},
		value = "Percent"
	},
	[25] = { -- Sword Skill
		attribute = {
			name = 'Sword Fighting',
			rare = {1, 2},
			epic = {3, 4},
			legendary = {5, 8},
			perf = {8, 10},
		},
		value = "Static",
		items = {
			8881, -- Fireborn
			12644 -- Shield of Corruption
		}
	},
	[26] = { -- Skill Axe
		attribute = {
			name = 'Axe Fighting',
			rare = {1, 2},
			epic = {3, 4},
			legendary = {5, 8},
			perf = {8, 10},
		},
		value = "Static",
		items = {
			8882 -- Earthborn
		}
	},
	[27] = { -- Skill Club
		attribute = {
			name = 'Club Fighting',
			rare = {1, 2},
			epic = {3, 4},
			legendary = {5, 8},
			perf = {8, 10},
		},
		value = "Static",
		items = {
			8883 -- Windborn
		}
	},
	[28] = { -- Skill Melee
		attribute = {
			name = 'Melee Skills',
			rare = {1, 2},
			epic = {3, 4},
			legendary = {5, 6},
			perf = {7, 8},
		},
		value = "Static"
	},
	[29] = { -- Skill Distance
		attribute = {
			name = 'Distance Fighting',
			rare = {1, 2},
			epic = {3, 4},
			legendary = {5, 6},
			perf = {7, 8},
		},
		value = "Static"
	},
	[30] = { -- Skill Shielding
		attribute = {
			name = 'Shielding',
			rare = {1, 2},
			epic = {3, 4},
			legendary = {5, 6},
			perf = {7, 8},
		},
		value = "Static"
	},
	[31] = { -- Magic Level
		attribute = {
			name = 'Magic Level',
			rare = {1, 2},
			epic = {3, 4},
			legendary = {5, 6},
			perf = {7, 8},
		},
		value = "Static"
	},
	[32] = { -- Max Health (+100)---------------------------------------
		attribute = {
			name = 'Max Health',
			rare = {1, 2},
			epic = {2, 3},
			legendary = {4, 5},
			perf = {6, 7},
		},
		value = "HpMana"
	},
	[33] = { -- Max Mana (+100)----------------------------------------
		attribute = {
			name = 'Max Mana',
			rare = {1, 2},
			epic = {2, 3},
			legendary = {4, 5},
			perf = {6, 7},
		},
		value = "HpMana"
	},
	[34] = { -- Max Health % (+10%)-
		attribute = {
			name = 'Max Health',
			rare = {1, 1},
			epic = {2, 2},
			legendary = {3, 3},
			perf = {4, 4},
		},
		value = "Percent"
	},
	[35] = { -- Max Mana % (+10%)
		attribute = {
			name = 'Max Mana',
			rare = {1, 1},
			epic = {2, 2},
			legendary = {3, 3},
			perf = {4, 4},
		},
		value = "Percent",
	},
	[36] = { -- Multi Shot
		attribute = {
			name = 'Multi Shot',
			rare = {1, 1},
			epic = {1, 1},
			legendary = {1, 1},
			perf = {1, 1},
		},
		value = "Static"
		-- Items targeted by this attribute are defined in a different way below.
	},
	[37] = { -- Physical Damage
		attribute = {
			name = 'Physical Damage',
			rare = {1, 3},
			epic = {4, 6},
			legendary = {7, 8},
			perf = {9, 10},
		},
		value = "Percent"
	},
	[38] = { -- Life Leech Chance
		attribute = {
			name = 'Life Leech Chance',
			rare = {2, 3},
			epic = {4, 5},
			legendary = {6, 7},
			perf = {8, 9},
		},
		value = "Percent"
		-- Items targeted by this attribute are defined in a different way below.
	},
	[39] = { -- Life Leech Amount
		attribute = {
			name = 'Life Leech Amount',
			rare = {1, 2},
			epic = {3, 4},
			legendary = {5, 6},
			perf = {7, 8},
		},
		value = "Percent"
		-- Items targeted by this attribute are defined in a different way below.
	},
	[40] = { -- Mana Leech Chance
		attribute = {
			name = 'Mana Leech Chance',
			rare = {2, 3},
			epic = {4, 5},
			legendary = {6, 7},
			perf = {8, 9},
		},
		value = "Percent"
		-- Items targeted by this attribute are defined in a different way below.
	},
	[41] = { -- Mana Leech Amount
		attribute = {
			name = 'Mana Leech Amount',
			rare = {1, 2},
			epic = {3, 4},
			legendary = {5, 6},
			perf = {7, 8},
		},
		value = "Percent"
		-- Items targeted by this attribute are defined in a different way below.
	},
		[42] = { -- Silence Chance
		attribute = {
			name = 'Silence Chance',
			rare = {1, 1},
			epic = {2, 3},
			legendary = {4, 5},
			perf = {6, 7},
		},
		value = "Percent"
	},
		[43] = { -- Penetration Damage
		attribute = {
			name = 'Penetration Damage',
			rare = {1, 2},
			epic = {3, 4},
			legendary = {5, 7},
			perf = {8, 10},
		},
		value = "Percent"
	},
	[44] = { -- Spell Damage
		attribute = {
			name = 'Spell Damage',
			rare = {1, 3},
			epic = {4, 6},
			legendary = {7, 8},
			perf = {9, 10},
		},
		value = "Percent"
	},
	[45] = { -- Disarm Chance
		attribute = {
			name = 'Disarm Chance',
			rare = {1, 1},
			epic = {2, 3},
			legendary = {4, 5},
			perf = {6, 7},
		},
		value = "Percent"
	},
	[46] = { -- Earth Damage
		attribute = {
			name = 'Enhanced Earth Damage',
			rare = {1, 2},
			epic = {3, 5},
			legendary = {5, 7},
			perf = {7, 9},
		},
		value = "Damage"
	},
	[47] = { -- Holy Damage
		attribute = {
			name = 'Enhanced Holy Damage',
			rare = {1, 2},
			epic = {3, 5},
			legendary = {5, 7},
			perf = {7, 9},
		},
		value = "Damage"
	},
	[48] = { -- Death Damage
		attribute = {
			name = 'Enhanced Death Damage',
			rare = {1, 2},
			epic = {3, 5},
			legendary = {5, 7},
			perf = {7, 9},
		},
		value = "Damage"
	},
	[49] = { -- Physical Damage
		attribute = {
			name = 'Enhanced Physical Damage',
			rare = {2, 3},
			epic = {4, 6},
			legendary = {6, 9},
			perf = {8, 11},
		},
		value = "Damage"
	}
}
local cannotroll = { -- These items are special and cannot be rolled rare/epic/legendary
	8905, -- Rainbow shield
	8906,
	8907,
	8908,
	8909,
	7744, -- These are the standard and transformed Dawnbreaker weapons
	7763,
	7751,
	7770,
	7756,
	7775
}

-- Check if item can be rolled (this is for use outside of this lib, actions, quests etc)
function rollCheck(item)
	local itemtype = ItemType(item:getId())
	local itemid = itemtype:getId()
	if table.contains(cannotroll, itemid) then
		return false
	end
	for k,v in pairs(stats) do
		if v.items ~= nil then
			if table.contains(v.items, itemid) then
				return true
			end
		end
	end
	local weapontype = itemtype:getWeaponType()
	if weapontype > 0 then
		if itemtype:isStackable() then
			return false
		else
			return true
		end
	elseif itemtype:getArmor() > 0 then
		return true
	end
	return false
end

-- Get duration literally
function rollBaseDuration(item)
	local it_id = item:getId()
	local tid = ItemType(it_id):getTransformEquipId()
	if tid > 0 then
		item:transform(tid)
		local vx = item:getAttribute(ITEM_ATTRIBUTE_DURATION)
		item:transform(it_id)
		--item:removeAttribute(ITEM_ATTRIBUTE_DURATION)
		return vx
	end
	return 0
end

-- Get base/stock stat
function rollBase(item, attr)
	local id = ItemType(item:getId())
	local v = {
		[ITEM_ATTRIBUTE_ATTACK] = item:getAttribute(ITEM_ATTRIBUTE_ATTACK),
		[ITEM_ATTRIBUTE_DEFENSE] = item:getAttribute(ITEM_ATTRIBUTE_DEFENSE),
		[ITEM_ATTRIBUTE_EXTRADEFENSE] = item:getAttribute(ITEM_ATTRIBUTE_EXTRADEFENSE),
		[ITEM_ATTRIBUTE_ARMOR] = item:getAttribute(ITEM_ATTRIBUTE_ARMOR),
		[ITEM_ATTRIBUTE_HITCHANCE] = item:getAttribute(ITEM_ATTRIBUTE_HITCHANCE),
		[ITEM_ATTRIBUTE_SHOOTRANGE] = item:getAttribute(ITEM_ATTRIBUTE_SHOOTRANGE),
		[ITEM_ATTRIBUTE_CHARGES] = item:getAttribute(ITEM_ATTRIBUTE_CHARGES),
		[ITEM_ATTRIBUTE_DURATION] = rollBaseDuration(item)
	}
	return v[attr]
end

-- Roll a container or item
function rollRarity(container, forced)
	-- Tiers
	local tiers = {
		[1] = {
			prefix = 'low',
			chance = {
				[1] = 5000, -- 5.0% chance to roll
				[2] = 10000 -- 100% chance for second stat
			}
		},

		[2] = {
			prefix = 'medium',
			chance = {
				[1] = 1000, -- 1.00% chance to roll
				[2] = 10000, -- 100% chance for second stat
				[3] = 10000 -- 100% chance for second stat
			}
		},
		[3] = {
			prefix = 'high',
			chance = {
				[1] = 10, -- 0.01% chance to roll
				[2] = 10000, -- 100% chance for second stat
				[3] = 10000, -- 100% chance for second stat
				[4] = 10000 -- 100% chance for second stat
			}
		},
		[4] = {
			prefix = 'perfect',
			chance = {
				[1] = 10, -- 0.01% chance to roll
				[2] = 10000, -- 100% chance for second stat
				[3] = 10000, -- 100% chance for second stat
				[4] = 10000, -- 100% chance for second stat
				[5] = 10000 -- 100% chance for second stat
			}
		},
	}
	local rares = 0
	local available_stats = {}
	local it_u = container
	local it_id = ItemType(it_u:getId())
	if it_u:isContainer() then
		local h = it_u:getItemHoldingCount()
		if h > 0 then
			local i = 1 
			while i <= h do
				local bagitem = it_u:getItem(i - 1)
				if bagitem:isContainer() then
					h = h - bagitem:getItemHoldingCount()
				end
				local manualroll = forced or false
				local crares = rollRarity(bagitem, manualroll)
				rares = rares + crares
				i = i + 1
			end
		end
	else
		if not it_id:isStackable() then
			local wp = it_id:getWeaponType()
			if wp > 0 then
				-- Shields
				if wp == WEAPON_SHIELD then
					table.insert(available_stats, stats[30]) -- Skill Shield
					table.insert(available_stats, stats[math.random(15, 21)]) -- odpornsci
					table.insert(available_stats, stats[29]) -- Skill Distance
					table.insert(available_stats, stats[28]) -- melee Skill
					table.insert(available_stats, stats[31]) -- Magic Level
					table.insert(available_stats, stats[32]) -- Max Health +100
					table.insert(available_stats, stats[33]) -- Max Mana +100
				
				-- Distance Items
				elseif wp == WEAPON_DISTANCE then
					table.insert(available_stats, stats[38]) -- life leech chance
					table.insert(available_stats, stats[40]) -- mana leech chance
					table.insert(available_stats, stats[11]) -- Critical Chance
					table.insert(available_stats, stats[29]) -- Skill Distance
					table.insert(available_stats, stats[31]) -- Magic Level
					table.insert(available_stats, stats[math.random(12,14)]) -- extra damage
					table.insert(available_stats, stats[42]) -- Silence Chance
					table.insert(available_stats, stats[43]) -- Penetration damage
					table.insert(available_stats, stats[23]) -- stun chance
					table.insert(available_stats, stats[45]) -- disarm chance
					table.insert(available_stats, stats[math.random(46,48)]) -- extra damage
					if it_id:getSlotPosition() == 2096 then -- Two-handed Weapon
						table.insert(available_stats, stats[22]) -- Multi Shot
					end
					if it_id:getSlotPosition() == 48 then -- One-handed Weapon
						table.insert(available_stats, stats[39]) -- Multi Shot
					end
				
				-- Wands and Rods
				elseif wp == WEAPON_WAND then -- type wand
				    --table.insert(available_stats, stats[1]) -- Attack
					table.insert(available_stats, stats[38]) -- life leech chance
					table.insert(available_stats, stats[40]) -- mana leech chance
					table.insert(available_stats, stats[43]) -- Penetration damage
					table.insert(available_stats, stats[44]) -- Spell Damage
					table.insert(available_stats, stats[33]) -- Max Mana
					table.insert(available_stats, stats[31]) -- Magic Level
					table.insert(available_stats, stats[math.random(12,14)]) -- extra damage
					table.insert(available_stats, stats[11]) -- Critical Chance
					table.insert(available_stats, stats[42]) -- Silence Chance
					table.insert(available_stats, stats[23]) -- stun chance
					table.insert(available_stats, stats[45]) -- disarm chance
					table.insert(available_stats, stats[math.random(46,48)]) -- extra damage
				
				-- Sword, Clubs and Axes
				elseif table.contains({WEAPON_SWORD, WEAPON_CLUB, WEAPON_AXE}, wp) then -- Melee Weapon
					table.insert(available_stats, stats[38]) -- life leech chance
					table.insert(available_stats, stats[40]) -- mana leech chance
					table.insert(available_stats, stats[37]) -- physical damage
					table.insert(available_stats, stats[23]) -- stun chance
					table.insert(available_stats, stats[28]) -- melee Skill
					table.insert(available_stats, stats[31]) -- Magic Level
					table.insert(available_stats, stats[math.random(12,14)]) -- extra damage
					table.insert(available_stats, stats[11]) -- Critical Chance
					table.insert(available_stats, stats[42]) -- Silence Chance
					table.insert(available_stats, stats[43]) -- Penetration damage
					table.insert(available_stats, stats[45]) -- disarm chance
					table.insert(available_stats, stats[math.random(46,48)]) -- extra damage
				end
			else -- Armors, Amulets, Runes and Rings
				if it_id:getArmor() > 0 then -- Ignore clothing/things with no armor stat
					table.insert(available_stats, stats[39]) -- life leech amount
					table.insert(available_stats, stats[41]) -- mana leech amount
					table.insert(available_stats, stats[10]) -- critical damage
					table.insert(available_stats, stats[math.random(15, 21)]) -- odpornsci
					table.insert(available_stats, stats[31]) -- Magic Level
					table.insert(available_stats, stats[32]) -- Max Health +100
					table.insert(available_stats, stats[33]) -- Max Mana +100
					table.insert(available_stats, stats[28]) -- melee Skill
					table.insert(available_stats, stats[29]) -- Skill Distance
					table.insert(available_stats, stats[30]) -- Skill Shield
				end

				-- Duration
				local eq_id = it_id:getTransformEquipId()
				if eq_id > 0 then
					table.insert(available_stats, stats[9]) -- Time
				end
				
				-- Charges
				local chargecount = it_id:getCharges()
				if chargecount > 0  and it_u.itemid ~= 2173 then -- Ignore AOL
					if chargecount >= 50 then -- If its base charge is greater than 50
						table.insert(available_stats, stats[8]) -- High Charges
					else -- Its base charge is less than 50
						table.insert(available_stats, stats[7]) -- Low Charges
					end
				end
			end
			
			-- Specifically Targeted Items
			for k,v in pairs(stats) do
				if v.items ~= nil then
					if table.contains(v.items, it_u.itemid) then
						table.insert(available_stats, stats[k])
					end
				end
			end
		end
	end
	if #available_stats > 0 then -- Skips it all if it's empty
		local tier = 0 -- Normal item
		local rarity = math.random(1, 100000)
		-- Manual trigger
		if type(forced) == "string" then -- rollRarity(item, "rare")  OR  /roll legendary
			for i = 1, #tiers do
				if forced == tiers[i].prefix then
					tier = i
				end
			end
		elseif forced == true then -- rollRarity(item, true)  OR  /roll
			tier = math.random(1,#tiers)
		-- Natural rolls
		else
			for i = 1, #tiers do -- Get best roll
				if rarity <= tiers[i].chance[1] then
					tier = i -- Rolled a rare/epic/legendary
				end
			end
		end
		if tier > 0 then -- Item has rolled rare or higher
			local stats_used = {}
			for stat = 1, #tiers[tier].chance do
				if #available_stats > 0 then
					local roll = math.random(1, 10000)
					if stat == 1 then -- First stat is guaranteed
						roll = tiers[tier].chance[stat]
					end
					if roll <= tiers[tier].chance[stat] then -- All other stats are rolled by chance
						local selected_stat = math.random(1, #available_stats)
						table.insert(stats_used, available_stats[selected_stat])
						table.remove(available_stats, selected_stat)
					end
				end
			end
			if #stats_used > 0 then
				rares = rares + 1
				local stat_desc = {}
				for stat = 1, #stats_used do
					local statmin = 0
					local statmax = 0
					if tiers[tier].prefix == tiers[4].prefix then
						statmin = stats_used[stat].attribute.perf[1]
						statmax = stats_used[stat].attribute.perf[2]
					elseif tiers[tier].prefix == tiers[3].prefix then
						statmin = stats_used[stat].attribute.legendary[1]
						statmax = stats_used[stat].attribute.legendary[2]
					elseif tiers[tier].prefix == tiers[2].prefix then
						statmin = stats_used[stat].attribute.epic[1]
						statmax = stats_used[stat].attribute.epic[2]
					else
						statmin = stats_used[stat].attribute.rare[1]
						statmax = stats_used[stat].attribute.rare[2]
					end

					local critv = math.random(statmin, statmax) -- The actual roll amount
					local ilvl = it_u:getItemLevel()
					local ilvlItem = math.random(statmin * ilvl, statmax * ilvl) -- The actual roll amount
					local ilvlItemMinimum = math.ceil(statmin * ilvl) -- The actual roll amount
					local ilvlItemMaximum = math.ceil(statmax * ilvl) -- The actual roll amount
					if stats_used[stat].value ~= nil then -- Is the value type defined?
						local basestat = 0
						-- Fill basestat
						

						if stats_used[stat].base ~= nil then
							basestat = rollBase(it_u, stats_used[stat].base) -- This is the base/stock value of the stat
							it_u:setAttribute(stats_used[stat].base, basestat + critv)
						end
						-- Static
						if stats_used[stat].value == "Static" then
							table.insert(stat_desc, ' ' .. stats_used[stat].attribute.name .. ' +' .. critv .. ' ['..statmin..'-'..statmax..'] ') -- Standard value "+10"
						elseif stats_used[stat].value == "HpMana" then
							table.insert(stat_desc, ' ' .. stats_used[stat].attribute.name .. ' +' .. ilvlItem .. ' ['..ilvlItemMinimum..'-'..ilvlItemMaximum..'] ') -- Standard value "+10 ale HP"
						-- Percentage
						elseif stats_used[stat].value == "Percent" then
							table.insert(stat_desc, ' ' .. stats_used[stat].attribute.name ..' +' .. critv .. '% ['..statmin..'-'..statmax..'] ') -- Percent value "+10%"
						-- Damage
						elseif stats_used[stat].value == "Damage" then
							table.insert(stat_desc, ' ' .. stats_used[stat].attribute.name ..' '.. ilvlItemMinimum .. '-' .. ilvlItem .. ' ['..ilvlItemMinimum..'-'..ilvlItemMaximum..'] ') -- Damage value "13-35"
						-- Duration
						elseif stats_used[stat].value == "Duration" then
							local timeconvert = critv / 60000
							table.insert(stat_desc, ' ' .. stats_used[stat].attribute.name .. ' +' .. timeconvert .. ' minutes ') -- Duration value "+15 minutes"
						end
						-- If this is a vanilla attribute, overwrite it with new roll

						----------------
				end
			end
				-- Rarity prefix
				if it_id:getArticle() ~= "" then -- Replace article if exists
					if tiers[tier].prefix == "epic" then
						it_u:setAttribute(ITEM_ATTRIBUTE_ARTICLE, "an " .. tiers[tier].prefix)
					else
						it_u:setAttribute(ITEM_ATTRIBUTE_ARTICLE, "a " .. tiers[tier].prefix)
					end
				else -- Add rarity prefix to item article (this allows for easy identification of rolled items in scripts outside of this lib 'item:getArticle():find("rare")')
					it_u:setAttribute(ITEM_ATTRIBUTE_ARTICLE, tiers[tier].prefix)
				end
				-- If item has a description, retain it instead of over-writing it
				if it_id:getDescription() == "" then
				--"..tiers[tier].prefix.."
				-- Capitalize tier.prefix to be used for the animated text above corpses
				rare_text = (tiers[tier].prefix:gsub("^%l", string.upper) .. " Quality")
					it_u:setAttribute(ITEM_ATTRIBUTE_DESCRIPTION, "" .. table.concat(stat_desc, " | "))
				else
					it_u:setAttribute(ITEM_ATTRIBUTE_DESCRIPTION, it_id:getDescription() .. " | " .. " | " .. table.concat(stat_desc, " | "))
				end
				-- Capitalize tier.prefix to be used for the animated text above corpses
				rare_text = (tiers[tier].prefix:gsub("^%l", string.upper) .. " Quality!")
			end
		end
	end
	return rares
end

-- Apply condition
function rollCondition(player, item, slot)
	local attributes = {
		 [1] = {"% " .. stats[25].attribute.name .. " ", CONDITION_PARAM_SKILL_SWORD}, -- "[Sword Skill: "
		 [2] = {"% " .. stats[26].attribute.name .. " ", CONDITION_PARAM_SKILL_AXE},
		 [3] = {"% " .. stats[27].attribute.name .. " ", CONDITION_PARAM_SKILL_CLUB},
		 [4] = {"% " .. stats[28].attribute.name .. " ", CONDITION_PARAM_SKILL_MELEE},
		 [5] = {"% " .. stats[29].attribute.name .. " ", CONDITION_PARAM_SKILL_DISTANCE},
		 [6] = {"% " .. stats[30].attribute.name .. " ", CONDITION_PARAM_SKILL_SHIELD},
		 [7] = {"% " .. stats[31].attribute.name .. " ", CONDITION_PARAM_STAT_MAGICPOINTS},
		 [8] = {"% " .. stats[32].attribute.name .. " ", CONDITION_PARAM_STAT_MAXHITPOINTS},
		 [9] = {"% " .. stats[33].attribute.name .. " ", CONDITION_PARAM_STAT_MAXMANAPOINTS},
		[10] = {"% " .. stats[34].attribute.name .. " ", CONDITION_PARAM_STAT_MAXHITPOINTSPERCENT, percent = true},
		[11] = {"% " .. stats[35].attribute.name .. " ", CONDITION_PARAM_STAT_MAXMANAPOINTSPERCENT, percent = true},
		[13] = {"% " .. stats[10].attribute.name .. " ", CONDITION_PARAM_SPECIALSKILL_CRITICALHITAMOUNT, percent = true},
		[12] = {"% " .. stats[11].attribute.name .. " ", CONDITION_PARAM_SPECIALSKILL_CRITICALHITCHANCE, percent = true},
		[14] = {"% " .. stats[38].attribute.name .. " ", CONDITION_PARAM_SPECIALSKILL_LIFELEECHCHANCE, percent = true},
		[15] = {"% " .. stats[39].attribute.name .. " ", CONDITION_PARAM_SPECIALSKILL_LIFELEECHAMOUNT, percent = true},
		[16] = {"% " .. stats[40].attribute.name .. " ", CONDITION_PARAM_SPECIALSKILL_MANALEECHCHANCE, percent = true},
		[17] = {"% " .. stats[41].attribute.name .. " ", CONDITION_PARAM_SPECIALSKILL_MANALEECHAMOUNT, percent = true},
	}
	local itemDesc = item:getAttribute(ITEM_ATTRIBUTE_DESCRIPTION)
	for k = 1,#attributes do
		local skillBonus = 0 -- reset
		local attributeSearchValue = "%+(%d+)% " -- "+10]"
		if attributes[k].percent ~= nil then
			attributeSearchValue = "%+(%d+)%%% " -- "+10%]"
			--if attributes[k].absolute ~= nil then
			--	skillBonus = 100 -- These conditions require absolutes (108%, 145% etc.)
			--end
		end
		local attributeString = attributes[k][1] .. attributeSearchValue -- "%[Attack: %+(%d+)%]"
		if string.match(itemDesc, attributeString) ~= nil then -- "[Attack: +10]"
			local offset = (10 * k) + slot -- ((CONST_SLOT_LAST) * k) + slot
			local skillBonus = skillBonus + tonumber(string.match(itemDesc, attributeString)) -- Raw (%d+) value
			
			if player:getCondition(CONDITION_ATTRIBUTES, CONDITIONID_COMBAT, offset) == nil then
				local condition = Condition(CONDITION_ATTRIBUTES)
				condition:setParameter(CONDITION_PARAM_SUBID, offset)
				condition:setParameter(CONDITION_PARAM_TICKS, -1)
				condition:setParameter(attributes[k][2], skillBonus)
				player:addCondition(condition)

			else
				player:removeCondition(CONDITION_ATTRIBUTES, CONDITIONID_COMBAT, offset)
			end
		end
	end
end
			
-- Get item attributes
function itemAttributes(player, item, slot, equip)
	-- Check if item is rolled
	if item:getArticle() ~= "" then
		if item:getArticle():find("low") or item:getArticle():find("medium") or item:getArticle():find("high") or item:getArticle():find("perfect") then
			local appropriateSlot = false
			local slotType = ItemType(item.itemid):getSlotPosition()
			-- What slots do we want to check? this ignores CONST_SLOT_AMMO and CONST_SLOT_BACKPACK
			local raritySlots = {
				[CONST_SLOT_LEFT] = {validPositions = {[1] = SLOTP_LEFT,[2] = SLOTP_RIGHT,[3] = SLOTP_TWO_HAND}},
				[CONST_SLOT_RIGHT] = {validPositions = {[1] = SLOTP_LEFT,[2] = SLOTP_RIGHT,[3] = SLOTP_TWO_HAND}},
				[CONST_SLOT_HEAD] = {validPositions = {[1] = SLOTP_HEAD}},
				[CONST_SLOT_NECKLACE] = {validPositions = {[1] = SLOTP_NECKLACE}},
				[CONST_SLOT_ARMOR] = {validPositions = {[1] = SLOTP_ARMOR}},
				[CONST_SLOT_LEGS] = {validPositions = {[1] = SLOTP_LEGS}},
				[CONST_SLOT_FEET] = {validPositions = {[1] = SLOTP_FEET}},
				[CONST_SLOT_RING] = {validPositions = {[1] = SLOTP_RING}},
				[CONST_SLOT_TRZY] = {validPositions = {[1] = SLOTP_TRZY}}
			}
			-- If slot is one that we check
			if raritySlots[slot] ~= nil then
				-- Validate that item is being equipped to the right slot
				if slot == CONST_SLOT_LEFT or slot == CONST_SLOT_RIGHT then
					local weapon = ItemType(item.itemid):getWeaponType()
					if weapon ~= WEAPON_NONE then
						if weapon ~= WEAPON_AMMO then
							appropriateSlot = true
						end
					end
				else
					for i = 1,#raritySlots[slot].validPositions do
						if bit.band(slotType, raritySlots[slot].validPositions[i]) ~= 0 then
							appropriateSlot = true
							break
						end
					end
				end
				if appropriateSlot then -- Item is in the wrong slotType
					-- Checks have all passed, run apply/remove attribute
					rollCondition(player, item, slot)
				end
			end
		end
	end
end