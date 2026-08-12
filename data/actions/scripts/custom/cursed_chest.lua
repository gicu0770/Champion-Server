local CURSED_CHESTS_VERSION = "1.1.1"

local CURSED_CHESTS_SKULL_DEFAULT = SKULL_WHITE
local CURSED_CHESTS_SKULL_BOSS = SKULL_BLACK

CURSED_CHESTS_TIER_COMMON = 1
CURSED_CHESTS_TIER_RARE = 2
CURSED_CHESTS_TIER_EPIC = 3
CURSED_CHESTS_TIER_LEGENDARY = 4

CURSED_CHESTS_TIERS = {
	{
		tier = CURSED_CHESTS_TIER_COMMON,
		chance = 40,
		text = "Common Cursed Chest [Lv. 25+]",
		item = 1750,
		monstersPerWave = 1,
		reqLevel = 25
	},
	{
		tier = CURSED_CHESTS_TIER_RARE,
		chance = 30,
		text = "Rare Cursed Chest [Lv. 50+]",
		--item = 18473,
		item = 26841,
		monstersPerWave = 1,
		reqLevel = 50
	},
	{
		tier = CURSED_CHESTS_TIER_EPIC,
		chance = 10,
		text = "Epic Cursed Chest [Lv. 80+]",
		--item = 21385,
		item = 26842,
		monstersPerWave = 1,
		reqLevel = 80
	},
	{
		tier = CURSED_CHESTS_TIER_LEGENDARY,
		chance = 5,
		text = "Legendary Cursed Chest [Lv. 120+]",
		--item = 18472,
		item = 26843,
		monstersPerWave = 1,
		reqLevel = 120
	}
}

CURSED_CHESTS_CONFIG = {
    [1] = {
			message = "Prepare to defend against 5 waves of demon type monsters and a boss at the end.",
			rewards = {
				[CURSED_CHESTS_TIER_COMMON] = {
					{ -- Platinum Coins
						chance = 100,
						item = 2152,
						random = true,
						amount = 60
					},
					{ -- crystal fossile
						chance = 100,
						item = 24850,
						amount = 5
					},
					{ -- Crystal Coins
						chance = 20,
						item = 2160,
						random = true,
						amount = 2
					}
				},
				[CURSED_CHESTS_TIER_RARE] = {
					{ -- Platinum Coins
						chance = 100,
						item = 2152,
						random = true,
						amount = 80
					},
					{ -- crystal fossile
						chance = 100,
						item = 24850,
						amount = 15
					},
					{ -- crystal fossile
						chance = 30,
						item = 24850,
						amount = 15
					},
					{ -- Crystal Coins
						chance = 40,
						item = 2160,
						amount = 1
					},
					{ -- Upgrade Crystal
						chance = 100,
						item = 26555,
						amount = 1
					}
				},
				[CURSED_CHESTS_TIER_EPIC] = {
					{ -- Platinum Coins
						chance = 100,
						item = 2152,
						random = true,
						amount = 100
					},
					{ -- Crystal Coins
						chance = 60,
						item = 2160,
						amount = 1
					},
					{ -- crystal fossile
						chance = 100,
						item = 24850,
						amount = 30
					},
					{ -- crystal fossile
						chance = 30,
						item = 24850,
						amount = 15
					},
					{ -- SOI
						chance = 100,
						item = 26532,
						amount = 5
					},
					{ -- Upgrade Crystal
						chance = 100,
						item = 26555,
						amount = 3
					}
				},
				[CURSED_CHESTS_TIER_LEGENDARY] = {
					{ -- Platinum Coins
						chance = 100,
						item = 2152,
						random = true,
						amount = 100
					},
					{ -- Crystal Coins
						chance = 70,
						item = 2160,
						random = true,
						amount = 2
					},
					{ -- crystal fossile
						chance = 30,
						item = 24850,
						amount = 15
					},

					{ -- Crystal Fossil
						chance = 100,
						item = 24850,
						amount = 80
					},
					{ -- SOI
						chance = 100,
						item = 26532,
						amount = 10
					},
					{ -- Upgrade Crystal
						chance = 100,
						item = 26555,
						amount = 5
					}
				}
			},
			waves = {
				[CURSED_CHESTS_TIER_COMMON] = {
					{ -- Wave 1
						"Dwarf Guard"
					},
					{ -- Wave 2
						"Amazon"
					},
					{ -- Wave 3
						"Cyclops"
					},
					{ -- Wave 4
						"Fire Elemental"
					},
					{ -- Wave 5
						"Cyclops Smith"
					}
				},
				[CURSED_CHESTS_TIER_RARE] = {
					{ -- Wave 1
						"Cyclops"
					},
					{ -- Wave 2
						"Fire Devil"
					},
					{ -- Wave 3
						"Fire Elemental"
					},
					{ -- Wave 4
						"Dragon"
					},
					{ -- Wave 5
						"Barbarian Rider"
					}
				},
				[CURSED_CHESTS_TIER_EPIC] = {
					{ -- Wave 1
						"Demon Skeleton"
					},
					{ -- Wave 2
						"Fire Elemental"
					},
					{ -- Wave 3
						"Barbarian Rider"
					},
					{ -- Wave 4
						"Dragon Lord"
					},
					{ -- Wave 5
						"Hellspawn"
					}
				},
				[CURSED_CHESTS_TIER_LEGENDARY] = {
					{ -- Wave 1
						"Undead Dragon"
					},
					{ -- Wave 2
						"Dragon Lord"
					},
					{ -- Wave 3
						"Bog Raider"
					},
					{ -- Wave 4
						"Hellspawn"
					},
					{ -- Wave 5
						"Warlock"
					}
				}
			},
			boss = {
				name = "Forei Soldier",
				fightDuration = 60,
				message = "Boss incoming! You have 60 seconds to kill Forei Boss!"
			}
		}
}

CURSED_CHESTS_DATA = {}

function CursedChestsLoad()
	print(">> Loaded Cursed Chests v" .. CURSED_CHESTS_VERSION)
	ShowEffects()
end

function ShowEffects()
	for _, data in ipairs(CURSED_CHESTS_DATA) do
		local tile = Tile(data.pos)
		if tile then
			for _, item in ipairs(tile:getItems()) do
				if item:getId() == data.rarity.item then
					if data.active == 0 and data.finished == false then
						data.pos:sendMagicEffect(CONST_ME_YALAHARIGHOST)
						data.pos:sendAnimatedText(data.rarity.text)
					elseif data.active == 1 and data.wave > 0 then
						data.pos:sendMagicEffect(CONST_ME_YALAHARIGHOST)
						if data.wave <= #data.chest.waves[data.rarity.tier] and not data.bossWave then
							data.pos:sendAnimatedText(string.format("Wave %d / %d\nMonsters Alive: %d", data.wave, #data.chest.waves[data.rarity.tier], #data.monsters))
						elseif data.chest.boss ~= nil and data.bossWave == true then
						
			if data.rarity.tier == 1 then
				bossTrap = "Forei Soldier"
					elseif data.rarity.tier == 2 then
						bossTrap = "Forei Warrior"
							elseif data.rarity.tier == 3 then
								bossTrap = "Forei Champion"
									elseif data.rarity.tier == 4 then
										bossTrap = "Forei Gladiator"
										else
										bossTrap = "Forei Soldier"
											end
											
							data.pos:sendAnimatedText(string.format("Boss Fight\n%s", bossTrap))
						end
					elseif data.finished == true then
						data.pos:sendMagicEffect(CONST_ME_GIFT_WRAPS)
						data.pos:sendAnimatedText("Get your reward!")
					end
				end
			end
		end
	end
	addEvent(ShowEffects, 3000)
end

function CursedChestEvent(data)
	data.wave = data.wave + 1
	local from = Position(data.pos.x - 5, data.pos.y - 5, data.pos.z)
	local to = Position(data.pos.x + 5, data.pos.y + 5, data.pos.z)
	if data.wave <= #data.chest.waves[data.rarity.tier] then
		local mobs = CURSED_CHESTS_TIERS[data.rarity.tier].monstersPerWave * data.wave
		for i = 1, mobs do
			local mobName = data.chest.waves[data.rarity.tier][data.wave][math.random(1, #data.chest.waves[data.rarity.tier][data.wave])]
			local spawnPos = Position(math.random(from.x, to.x), math.random(from.y, to.y), data.pos.z)
			local tile = Tile(spawnPos)
			local spawnTest = 0
			while spawnTest < 100 do
				if data.pos == spawnPos or isBadTile(tile) then
					spawnPos = Position(math.random(from.x, to.x), math.random(from.y, to.y), data.pos.z)
					tile = Tile(spawnPos)
					spawnTest = spawnTest + 1
				else
					break
				end
			end
					

			if spawnTest < 100 then
				local mob = Game.createMonster(mobName, spawnPos, false, true)
				if mob then
					mob:setSkull(CURSED_CHESTS_SKULL_DEFAULT)
					mob:registerEvent("CursedChestsDeath")
					table.insert(data.monsters, mob:getId())
				end
			end
		end
	elseif data.chest.boss ~= nil then
		data.bossWave = true
		local spawnPos = Position(math.random(from.x, to.x), math.random(from.y, to.y), data.pos.z)
		local tile = Tile(spawnPos)
		local spawnTest = 0
		while spawnTest < 100 do
			if data.pos == spawnPos or isBadTile(tile) then
				spawnPos = Position(math.random(from.x, to.x), math.random(from.y, to.y), data.pos.z)
				tile = Tile(spawnPos)
				spawnTest = spawnTest + 1
			else
				break
			end
		end

		if spawnTest < 100 then -- print(data.rarity.tier)
			if data.rarity.tier == 1 then
				bossTrap = "Forei Soldier"
					elseif data.rarity.tier == 2 then
						bossTrap = "Forei Warrior"
							elseif data.rarity.tier == 3 then
								bossTrap = "Forei Champion"
									elseif data.rarity.tier == 4 then
										bossTrap = "Forei Gladiator"
										else
										bossTrap = "Forei Soldier"
											end
			local mob = Game.createMonster(bossTrap, spawnPos, false, true)
			if mob then
				mob:setSkull(CURSED_CHESTS_SKULL_BOSS)
				mob:registerEvent("CursedChestsDeath")
				table.insert(data.monsters, mob:getId())
				stopEvent(data.event)
				data.event = addEvent(CursedChestBoss, data.chest.boss.fightDuration * 1000, data)
			end
		end
	end
end

function CursedChestBoss(data)
	if #data.monsters == 1 then
		local boss = Monster(data.monsters[1])
		if boss then
			boss:remove()
			stopEvent(data.event)
			for i = 1, #CURSED_CHESTS_DATA do
				if CURSED_CHESTS_DATA[i] == data then table.remove(CURSED_CHESTS_DATA, i) end
			end
			data.container:getPosition():sendMagicEffect(CONST_ME_POFF)
			data.container:remove()
			CURSED_CHESTS_SPAWNS[data.spawnId].spawned = false
			data.pos:sendAnimatedText("Boss fight is over! You failed!")
		end
	end
end

function FinishCursedChestEvent(data)
	if data.chest.boss ~= nil and data.bossWave == true and #data.monsters == 0 or not data.chest.boss and data.wave == #data.chest.waves[data.rarity.tier] and #data.monsters == 0 then
		stopEvent(data.event)
		data.finished = true
		data.active = 0
		local loot = "Cursed Chest reward: "
		local items = {}

		for i = 1, #data.chest.rewards[data.rarity.tier] do
			if data.container:getEmptySlots() == 0 then break end

			local reward = data.chest.rewards[data.rarity.tier][i]
			if reward.chance == 100 then
				local amount = reward.random == true and math.random(1, reward.amount) or reward.amount
				local item = Game.createItem(reward.item, amount)
				data.container:addItemEx(item)
				if item:getType():isUpgradable() then
				item:setCustomAttribute("unidentified", true)
				item:setItemLevel(math.random(50, 60))
				end
				table.insert(items, item)
			elseif math.random(1, 100) <= reward.chance then
				local amount = reward.random == true and math.random(1, reward.amount) or reward.amount
				local item = Game.createItem(reward.item, amount)
				data.container:addItemEx(item)
				if item:getType():isUpgradable() then
				item:setCustomAttribute("unidentified", true)
				item:setItemLevel(math.random(50, 60))
				end
				table.insert(items, item)
			end
		end

		for i = #items, 1, -1 do
			if items[i]:getCount() > 1 then
				loot = loot .. items[i]:getCount() .. " "
				loot = loot .. items[i]:getPluralName()
			else
				loot = loot .. items[i]:getName()
			end
			if i > 1 then loot = loot .. ", " end
		end

		loot = loot .. "."

		local specs = Game.getSpectators(data.pos, false, true, 9, 9, 9, 9)
    if #specs > 0 then
        for i = 1, #specs do
            specs[i]:sendTextMessage(MESSAGE_STATUS_WARNING, loot)
        end
		end
		
		data.checks = 0
		data.event = addEvent(CursedChestCheck, 1000, data)
	end
end

function CursedChestCheck(data)
	data.event = addEvent(CursedChestCheck, 1000, data)
	addEvent(CursedChestDelete, 5 * 60 * 1000, data)
	if data.container:getEmptySlots() == data.container:getCapacity() then
		stopEvent(data.event)
		for i = 1, #CURSED_CHESTS_DATA do
			if CURSED_CHESTS_DATA[i] == data then table.remove(CURSED_CHESTS_DATA, i) end
		end
		data.container:getPosition():sendMagicEffect(CONST_ME_POFF)
		data.container:remove()
		CURSED_CHESTS_SPAWNS[data.spawnId].spawned = false
	end
end

function CursedChestDelete(data)
	for i = 1, #CURSED_CHESTS_DATA do
		if CURSED_CHESTS_DATA[i] == data then
			stopEvent(data.event)
			data.container:getPosition():sendMagicEffect(CONST_ME_POFF)
			data.container:remove()
			CURSED_CHESTS_SPAWNS[data.spawnId].spawned = false
			table.remove(CURSED_CHESTS_DATA, i)
		end
	end
end

function CursedChests_onDeath(creature, corpse, killer, mostDamageKiller, unjustified, mostDamageUnjustified)
	for _, data in ipairs(CURSED_CHESTS_DATA) do
		if data.active == 1 then
			for i = 1, #data.monsters do
				if data.monsters[i] == creature:getId() then
					table.remove(data.monsters, i)
					if data.wave < #data.chest.waves[data.rarity.tier] and #data.monsters == 0 then
						addEvent(CursedChestEvent, 1500, data)
					elseif data.chest.boss ~= nil and not data.bossWave and #data.monsters == 0 then
						killer:getPosition():sendAnimatedText(data.chest.boss.message)
						addEvent(CursedChestEvent, 3000, data)
					end
					if data.wave == #data.chest.waves[data.rarity.tier] and #data.monsters == 0 or data.bossWave == true and #data.monsters == 0 then FinishCursedChestEvent(data) end
					break
				end
			end
		end
	end
	return true
end

function onUse(player, item, fromPosition, target, toPosition, isHotkey)
	for _, data in ipairs(CURSED_CHESTS_DATA) do
		if data.pos == item:getPosition() then
			if data.active == 0 and data.finished == false then
				if CURSED_CHESTS_TIERS[data.rarity.tier].reqLevel > player:getLevel() then
					player:sendTextMessage(
						MESSAGE_STATUS_WARNING,
						"Required level to open this chest is " .. CURSED_CHESTS_TIERS[data.rarity.tier].reqLevel
					)
					player:getPosition():sendAnimatedText("Required level to open this chest is " .. CURSED_CHESTS_TIERS[data.rarity.tier].reqLevel)
					return false
				else
					player:getPosition():sendAnimatedText(data.chest.message .. "\nKill all monsters to get awesome rewards!")
					if player:getParty() then
						data.solo = false
					else
						data.solo = true
					end
					data.owner = player:getName()
					data.wave = 0
					data.monsters = {}
					data.active = 1
					data.finished = false
					data.container = item
					data.event = addEvent(CursedChestEvent, 2000, data)
				end
			elseif data.finished == true then
				if data.solo and data.owner == player:getName() then
					return false
				elseif not data.solo then
					local party = player:getParty()
					if not party then
						return true
					end
					if data.owner == player:getName() then
						return false
					end
					local members = party:getMembers()
					for i = 1, #members do
						if members[i]:getName() == player:getName() then
							return false
						end
					end
				end
				return true
			end
			return true
		end
	end
	return false
end
