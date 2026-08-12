STRONGBOX_WIDGET = {
	{
		id = 3,
		data = {
			"1", -- | RARITY |  1
			"Currency Strongbox"
		}
	},
	{
		id = 3,
		data = {
			"5", -- | RARITY |  2
			"Equipment Strongbox"
		}
	},
	{
		id = 3,
		data = {
			"6", -- | RARITY |  3
			"Elite Strongbox"
		}
	},
}

local function removeStrongBoxMonsters(cid)
	local monster = Monster(cid)
	if monster then
		monster:getPosition():sendMagicEffect(11)
		monster:remove()
	end
end

local removeTime = 2 * 60000 -- 18473 orbs 36241 eq 36239 elite
local boxRarity = { 38745, 38746, 38744 } 
local DeathMonster = CreatureEvent("StrongBoxDeath")
function DeathMonster.onDeath(creature, corpse, killer, mostDamage, unjustified, mostDamage_unjustified)
	if not creature or creature:isPlayer() or creature:getMaster() or not creature:isMonster() or not killer or not killer:isPlayer() then
		return true
	end

	local zoneId = creature:getZoneId()
	if zoneId == 0 then
		return true
	end

	local skull = creature:getSkull()
	if skull ~= 0 then
		return true
	end
	local mType = creature:getType()
	if mType:items() == "titan" or mType:items() == "dummy" or mType:items() == "dungeonboss" or creature:getSkull() >= 1 or creature:getName() == "Treasure Goblin" then
		return false
	end

	local strongboxChance = EVENT_CHANCE["Strongbox"].chance
	local globalSpawnChance = 1

	if getGlobalBuff(BUFF_GLOBAL_PORTALS) then
		globalSpawnChance = globalSpawnChance + 0.2
	end
	if killer:hasBuff(STORE_PORTALS_BOOST) then
		globalSpawnChance = globalSpawnChance + 0.2
	end
	if creature:getStorageValue(PlayerStorage.strongBoxMonster) > 0 then
    return true
  end

  local killerInfo = colleftInfo[killer:getId()]
  if killerInfo and killerInfo.attributesItems[266] then -- Strongbox Chance
    globalSpawnChance = globalSpawnChance + (killerInfo.attributesItems[266].value / 100)
  end
  local instance = creature:getInstance()
  local abox = strongboxChance + (globalSpawnChance * strongboxChance - strongboxChance)
  if math.random(100000) <= abox then
    local rand = math.random(#boxRarity)
    local boxSpawnPosition = creature:getPosition()
    local strongBox = Game.createItem(boxRarity[rand], 1, boxSpawnPosition)
    if strongBox then
      if instance then
        instance:addItem(strongBox)
        strongBox:setCustomAttribute("inDungeon", true)
      end
      local monsterLevel = creature:getMonsterLevel() or 1
      strongBox:setStrongBox(boxRarity[rand])
      strongBox:setStrongBoxId(rand)
      strongBox:setStrongBoxAffix(rand)
      strongBox:setCustomAttribute("zoneId", zoneId)
      strongBox:setCustomAttribute("monsterLevel", monsterLevel)
      local tier = creature:getStorageValue(PlayerStorage.keyTier)
      if tier and tier > 0 then
        strongBox:setCustomAttribute("tier", tier)
      end
      local mapModifier = creature:getStorageValue(PlayerStorage.monsterModifier_bonus)
      if mapModifier and mapModifier > 0 then
        strongBox:setCustomAttribute("mapModifier", mapModifier)
      end
      strongBox:setCustomAttribute("maxHp", creature:getMaxHealth())
      tile = Tile(boxSpawnPosition.x, boxSpawnPosition.y - 1, boxSpawnPosition.z)
      if tile then
        STRONGBOX_WIDGET[rand].data[3] = os.time() + math.ceil(removeTime / 1000)
        tile:setWidget(STRONGBOX_WIDGET[rand].id, STRONGBOX_WIDGET[rand].data)
      end
      if killer:isPlayer() then
        killer:sendExtendedOpcode(71,
          json.encode({ text = "You found {Strongbox} you have 2 minutes before the box disappears!", color ="#ff0000" }))
      end
      addEvent(function()
        local item = Tile(boxSpawnPosition):getItemById(boxRarity[rand])
        boxSpawnPosition.y = boxSpawnPosition.y - 1
        if item then
          item:remove()
          if Tile(boxSpawnPosition) then
            Tile(boxSpawnPosition):removeWidget()
          end
        end
      end, removeTime)
    end
  end

	return true
end

DeathMonster:type("death")
DeathMonster:register()

local czasMobow = 3 * 60 * 1000 -- 3min
local OnOpenStrongBox = Action()
function OnOpenStrongBox.onUse(player, item, fromPosition, itemEx, toPosition)
	if item:isStrongBox() then
		local zoneId = tonumber(item:getCustomAttribute("zoneId"))
		if zoneId == 0 then
			return true
		end

		local monsterLevel = tonumber(item:getCustomAttribute("monsterLevel"))
		if monsterLevel == 0 then
			return true
		end
		local relictBonus = 0
		if monsterLevel > 0 and colleftInfo[player:getId()].attributesItems[269] then -- Challenging Encounter
			relictBonus = colleftInfo[player:getId()].attributesItems[269].value
		end

		local tier = item:getCustomAttribute("tier")
		if tier then
			tier = tonumber(tier)
		end

		local isDungeon = item:getCustomAttribute("inDungeon")
		if isDungeon then
			isDungeon = true
		end

		local mapModifier = item:getCustomAttribute("mapModifier")
		if mapModifier then
			mapModifier = tonumber(mapModifier)
		end

		local monsterMaxHP = tonumber(item:getCustomAttribute("maxHp")) or 0

		local monsterNameEnter = {}
		local zoneMonsters = Game.getMonstersTypeByZoneId(zoneId)
		if zoneMonsters then
			for name, _ in pairs(zoneMonsters) do
				table.insert(monsterNameEnter, name)
			end
		end

		if #monsterNameEnter == 0 then
			print("Strong box without monsters?")
			return true
		end
		local relictHolder = false
		local bossNameEnter = monsterNameEnter[math.random(1, #monsterNameEnter)]
		if monsterLevel >= EVENT_CHANCE["Strongbox"].levelDrop then
			if math.random(100) <= EVENT_CHANCE["Strongbox"].relictHolderChance then
				bossNameEnter = EVENT_CHANCE["Strongbox"].name
				relictHolder = true
			end
		end

		local countMonster = 8
		if colleftInfo[player:getId()].attributesItems[273] then -- Monster Horde
			countMonster = countMonster + colleftInfo[player:getId()].attributesItems[273].value
		end
		local eliteBox = false
		if item:getStrongBoxId() == 3 then -- Elite strongbox
			eliteBox = true
		end
		local boxPosition = item:getPosition()
		local monsterAffix = item:getStrongBoxAffix()
		local start = 1
		for _ = 1, countMonster do
			start = start + 1
			local dataPos = player:getPosition()
			local from = Position(dataPos.x - 5, dataPos.y - 5, dataPos.z)
			local to = Position(dataPos.x + 5, dataPos.y + 5, dataPos.z)

			local spawnPos = Position(math.random(from.x, to.x), math.random(from.y, to.y), dataPos.z)
			local tile = Tile(spawnPos)
			local spawnTest = 0
			while spawnTest < 100 do
				if dataPos == spawnPos or isBadTileOEN(tile) or not player:getPathTo(spawnPos, 0, 1, false, false) then
					spawnPos = Position(math.random(from.x, to.x), math.random(from.y, to.y), dataPos.z)
					tile = Tile(spawnPos)
					spawnTest = spawnTest + 1
				else
					break
				end
			end

			if spawnTest < 100 then
				local function boxCreate(cid)
					local player = Player(cid)
					if player and not player:isRemoved() then
						local monster = Game.createMonster(monsterNameEnter[math.random(1, #monsterNameEnter)], spawnPos,
							true)
						if monster then
							local mid = monster:getId()
							addEvent(removeStrongBoxMonsters, czasMobow, mid)
							monster:setStorageValue(PlayerStorage.strongBoxMonster, monsterAffix)
							monster:registerEvent("StrongBox")
							monster:getPosition():sendMagicEffect(11)
							monster:setShader("Shimmering", 120)
							monster:setMonsterLevel(monsterLevel)
							monster:setMaxHealth(monsterMaxHP)
							monster:setHealth(monsterMaxHP)
							if tier then
								monster:setStorageValue(PlayerStorage.keyTier, tier)
							end

							if mapModifier then
								monster:setStorageValue(PlayerStorage.monsterModifier_bonus, mapModifier)
							end
							monster:setTitle("Strongbox", "Reggae One-10px-bordered", "white")
							if eliteBox then
								applyEliteAffix(monster, 100, spawnPos)
							end
							local dungeon = player:getDungeon()
							if isDungeon and not dungeon then
								monster:remove()
								return
							end

							if dungeon then
								local instance = dungeon:getPlayerInstance(player)
								if isDungeon and not instance then
									monster:remove()
									return
								end
								if instance then
									instance:addMonster(monster)
								end
							end
						end
					end
				end
				local id = player:getId()
				addEvent(boxCreate, start * 200, id)
			end
		end

		local function createBoss(cid, pos, relictHolder)
			local player = Player(cid)
			if player and not player:isRemoved() then
				local boss = Game.createMonster(bossNameEnter, pos, true, true)
				if boss then
					boss:setSkull(SKULL_WHITE)
					boss:setMaxHealth(monsterMaxHP * 4)
					boss:setHealth(monsterMaxHP * 4)
					local bId = boss:getId()
					addEvent(removeStrongBoxMonsters, czasMobow, bId)
					boss:registerEvent("StrongBox")
					boss:setMonsterLevel(monsterLevel + relictBonus)
					boss:setStorageValue(PlayerStorage.strongBoxMonsterBoss, 1)
					if tier then
						boss:setStorageValue(PlayerStorage.keyTier, tier)
					end
					if mapModifier then
						boss:setStorageValue(PlayerStorage.monsterModifier_bonus, mapModifier)
					end
					boss:setStorageValue(PlayerStorage.strongBoxMonster, monsterAffix)
					boss:setShader("Circle Shine", 120)
					boss:setTitle("Strongbox Boss", "Reggae One-10px-bordered", "white")

					--	local aurasRandom = { 2169, 2170, 2171, 2172, 2123, 2124, 2125, 2126, 2098, 2099, 2100, 2101, 2102 }
					--	boss:setAura(aurasRandom[math.random(#aurasRandom)], 120)
					boss:setAura(2154, 120)
					local dungeon = player:getDungeon()
					if isDungeon and not dungeon then
						boss:remove()
						return
					end
					if dungeon then
						local instance = dungeon:getPlayerInstance(player)
						if isDungeon and not instance then
							boss:remove()
							return
						end
						if instance then
							instance:addMonster(boss)
						end
					end
					if eliteBox then
						applyEliteAffix(boss, 100, pos)
					end
					local outfit = boss:getOutfit()
					if relictHolder then
						boss:setStorageValue(PlayerStorage.strongboxRelictBoss, 1)
						outfit.lookOutline = "White Outline"
						outfit.lookShader = "Red Rage"
						boss:setMonsterLevel(monsterLevel + 20 + relictBonus)
						boss:setTitle("Relict Holder", "Reggae One-10px-bordered", "white")
					end
					outfit.lookHealthBar = 3
					boss:setOutfit(outfit)
				end
			end
		end
		local pid = player:getId()
		if boxPosition then
			addEvent(createBoss, 5000, pid, boxPosition, relictHolder)
		end


		local pos = item:getPosition()
		pos.y = pos.y - 1
		Tile(pos):removeWidget()
		item:remove()
		player:getPosition():sendMagicEffect(50)
	end
	return true
end

OnOpenStrongBox:id(38745, 38746, 38744)
OnOpenStrongBox:register()
