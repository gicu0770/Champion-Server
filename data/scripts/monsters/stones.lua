local mType = Game.createMonsterType("Void Stone")

local Stone = {}
Stone.description = "Void Stone"
Stone.experience = 2000
Stone.outfit = {
	lookType = 54,
	lookHealthBar = 3,
	lookOutline = "Purple Outline",
}

Stone.health = 50000
Stone.maxHealth = 50000
Stone.corpse = 27196
Stone.speed = 0
Stone.items = "stone"

Stone.flags = {
	summonable = false,
	attackable = true,
	hostile = true,
	convinceable = false,
	illusionable = false,
	pushable = false,
	canPushItems = true,
	canPushCreatures = true,
}

Stone.changeTarget = {
	interval = 4 * 1000,
	chance = 100
}

Stone.attacks = {
	{
		name = "combat",
		type = COMBAT_ENERGYDAMAGE,
		minDamage = -200,
		maxDamage = -200,
		range = 6,
		effect = 668,
		chance = 100,
		shootEffect = 287,
		interval = 2 * 1000
	},
}

Stone.elements = {
	{type = COMBAT_PHYSICALDAMAGE, percent = 0},
	{type = COMBAT_ENERGYDAMAGE, percent = 0},
	{type = COMBAT_EARTHDAMAGE, percent = 0},
	{type = COMBAT_FIREDAMAGE, percent = 0},
	{type = COMBAT_LIFEDRAIN, percent = 0},
	{type = COMBAT_MANADRAIN, percent = 0},
	{type = COMBAT_DROWNDAMAGE, percent = 0},
	{type = COMBAT_ICEDAMAGE, percent = 0},
	{type = COMBAT_HOLYDAMAGE , percent = 0},
	{type = COMBAT_DEATHDAMAGE , percent = 0}
}

Stone.defenses = {
	defense = 1,
	armor = 1,
}

local SPELLS_CONFIG = {
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,

		damageRaw = 1000,
		damageType = COMBAT_DEATHDAMAGE,
		area = STONE_LEFT,
		effect = 663,
		bottomEffect = false,
		center = true,
		offsetX = 4,
		offsetY = 4,
		stay = true,
	},
	{
		interval = 2000,
		exhaust = 1000,
		startTime = 100,

		damageRaw = 1000,
		damageType = COMBAT_DEATHDAMAGE,
		area = STONE_RIGHT,
		effect = 663,
		bottomEffect = false,
		center = true,
		offsetX = 4,
		offsetY = 4,
		stay = true,
	},
}

function mType.onAppear(monster, creature)
	if monster and creature then
		local id = monster:getId()
		if id == creature:getId() then
			monster:registerEvent("Stonedeath_hp")
			monster:registerEvent("Stone_death")
			mType:isAttackable(true)
			mType:items(Stone.items)
			BOSS_MONSTER_CONFIG[id] = {
				ready = 0,
				phase = 0,
				spells = {}
			}
		end
	end
end

function spawnMonsterStone(position, zoneId, maxLifes, health, monsterLevel, tier, mapModifier, creatureId, isDungeon)
  local monster = Game.createMonster("Void Stone", position, true, true)
  if monster then
    monster:setStorageValue(MonsterStorages.stoneMaxLifes, maxLifes)
    monster:setStorageValue(MonsterStorages.stoneLifes, maxLifes)
    monster:setStorageValue(MonsterStorages.stoneZoneId, zoneId)
    monster:setStorageValue(PlayerStorage.keyTier, tier)
    monster:setStorageValue(PlayerStorage.monsterModifier_bonus, mapModifier)

		local creature = Creature(creatureId)
		if not creature or creature:isRemoved() then
			monster:remove()
			return true
		end

		local addedToInstance = false
		local dungeon = creature:getDungeon()
		if dungeon then
			local instance = dungeon:getPlayerInstance(creature)
			if instance then
				instance:addMonster(monster)
				addedToInstance = true
			end
		end

		if isDungeon and not addedToInstance then
			monster:remove()
			return true
		end

    monster:setMonsterLevel(monsterLevel)
    monster:setMaxHealth(health)
    monster:setHealth(health)
    local text = "Q"
    monster:setTitle(text:rep(maxLifes), "hex-14px", "#BF40BF")
    monster:registerEvent("Stone_preparedeath")
    return monster
  end
  return nil
end

mType:register(Stone)

local function spawnStoneCreatures(zoneId, monsterLevel, position, monsterId, tier, mapModifier, health)
	local stone = Monster(monsterId)
	if not stone or stone:isRemoved() then
		return
	end

	local monsterNameEnter = {"Voidfang","Voidforged","Void Imp"}
	local isDungeon = stone:getInstance()
	if isDungeon then
		isDungeon = true
	else
		isDungeon = false
	end

	local countMonster = 10
	local start = 1
	for _ = 1, countMonster do
		start = start + 1
		local dataPos = position
		local from = Position(dataPos.x - 5, dataPos.y - 5, dataPos.z)
		local to = Position(dataPos.x + 5, dataPos.y + 5, dataPos.z)

		local spawnPos = Position(math.random(from.x, to.x), math.random(from.y, to.y), dataPos.z)
		local tile = Tile(spawnPos)
		local spawnTest = 0
		while spawnTest < 100 do
			if dataPos == spawnPos or isBadTileOEN(tile) or not stone:getPathTo(spawnPos, 0, 1, false, false) then
				spawnPos = Position(math.random(from.x, to.x), math.random(from.y, to.y), dataPos.z)
				tile = Tile(spawnPos)
				spawnTest = spawnTest + 1
			else
				break
			end
		end

		if spawnTest < 100 then
			local function createMonsterStone(cid)
				local stone = Monster(cid)
				if stone and not stone:isRemoved() then
					local monster = Game.createMonster(monsterNameEnter[math.random(1, #monsterNameEnter)], spawnPos, true)
					if monster then
						monster:setStorageValue(MonsterStorages.isStoneMonster, 1)
						monster:setMaster(stone)
						monster:getPosition():sendMagicEffect(11)
						monster:setMonsterLevel(monsterLevel)
						monster:setMaxHealth(health)
						monster:setHealth(health)
						if tier then
							monster:setStorageValue(PlayerStorage.keyTier, tier)
						end
						if mapModifier then
							monster:setStorageValue(PlayerStorage.monsterModifier_bonus, mapModifier)
						end
						monster:setTitle("Void Minion", "Reggae One-10px-bordered", "#BF40BF")
            local instance = stone:getInstance()
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
      addEvent(createMonsterStone, start * 100, monsterId)
		end
	end
end

function mType.onThink(monster, interval)
	local mid = monster:getId()
	if mid == 0 then return end
	if not BOSS_MONSTER_CONFIG[mid] then
		BOSS_MONSTER_CONFIG[mid] = {
			ready = 0,
			phase = 0,
			spells = {}
		}
	end
	onThinkBoss(monster, interval, SPELLS_CONFIG, BOSS_MONSTER_CONFIG[mid])
end

local eventPrepareDeath = CreatureEvent("Stone_preparedeath")
function eventPrepareDeath.onPrepareDeath(monster, corpse, killer)
	if not monster then
		return true
	end

	local lifes = monster:getStorageValue(MonsterStorages.stoneLifes)
	lifes = lifes - 1
	monster:setStorageValue(MonsterStorages.stoneLifes, lifes)
	if lifes < 0 then
		local creaturePos = monster:getPosition()
		creaturePos:sendMagicEffect(678)
		addEvent(function()
			if not creaturePos then
				return
			end
			local corpseStone = Game.createItem(38881, 1, creaturePos)
			if corpseStone then
				corpseStone:decay()
			end
		end, 200)
		return true
	end

	local maxLifes = monster:getStorageValue(MonsterStorages.stoneMaxLifes)
	local zoneId = monster:getStorageValue(MonsterStorages.stoneZoneId)
	local tier = monster:getStorageValue(PlayerStorage.keyTier)
  	local mapModifier = monster:getStorageValue(PlayerStorage.monsterModifier_bonus)
	local text = "Q"
	monster:setTitle(text:rep(lifes) .. string.rep("R", maxLifes - lifes), "hex-14px", "#BF40BF")
	monster:setHealth(monster:getMaxHealth())
	 spawnStoneCreatures(zoneId, monster:getMonsterLevel(), monster:getPosition(), monster:getId(), tier, mapModifier, (monster:getMaxHealth() / 5))
	return false
end

eventPrepareDeath:register()

local eventHealth = CreatureEvent("Stone_death_hp")

function eventHealth.onHealthChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
	if not creature or not attacker then
		return primaryDamage, primaryType, secondaryDamage, secondaryType
	end
	return primaryDamage, primaryType, secondaryDamage, secondaryType
end
eventHealth:register()

local DeathMonster = CreatureEvent("StoneRespawnDeath")
function DeathMonster.onDeath(creature, corpse, killer, mostDamage, unjustified, mostDamage_unjustified)
	if not creature or creature:isPlayer() or creature:getMaster() or not creature:isMonster() then
		return true
	end

	if not killer or not killer:isPlayer() then
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

	local storageValue = creature:getStorageValue(MonsterStorages.isStoneMonster)
	if storageValue == 1 then
		return true
	end

	local mType = creature:getType()
	if mType:items() == "titan" or mType:items() == "dummy" or mType:items() == "dungeonboss" or creature:getSkull() >= 1 or creature:getName() == "Treasure Goblin" then
		return false
	end

	local stoneChance = EVENT_CHANCE["Stone"].chance
	local killerInfo = colleftInfo[killer:getId()]
	if killerInfo and killerInfo.attributesItems[288] then -- Void Stone chance
		stoneChance = stoneChance + ((stoneChance * killerInfo.attributesItems[288].value) / 100)
	end
	if math.random(100000) >= stoneChance then
		return true
	end
	local creaturePos = creature:getPosition()
	local monsterLevel = creature:getMonsterLevel()
	local newHP = creature:getMaxHealth() * 5
	local tier = creature:getStorageValue(PlayerStorage.keyTier)
	local mapModifier = creature:getStorageValue(PlayerStorage.monsterModifier_bonus)
	local isDungeon = killer:getDungeon() ~= nil
	creaturePos:sendMagicEffect(211)
	if killer:isPlayer() then
		killer:sendExtendedOpcode(71,json.encode({ text ="A {Void Stone} has been summoned! Destroy it!", color ="#ff0000" }))
	end

	local creatureId = killer:getId()
	addEvent(function()
		if not creaturePos or not monsterLevel then
			return
		end

		spawnMonsterStone(creaturePos, zoneId, 5, newHP, monsterLevel, tier, mapModifier, creatureId, isDungeon)
	end, 2300)
  
	BOSS_MONSTER_CONFIG[creature:getId()] = nil
  return true
end

DeathMonster:type("death")
DeathMonster:register()