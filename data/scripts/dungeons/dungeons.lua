local LoginEvent = CreatureEvent("DungeonsLogin")

function LoginEvent.onLogin(player)
  player:registerEvent("DungeonsExtended")
  player:registerEvent("DungeonsLogout")
  player:registerEvent("DungeonsDeath")

  player:updateRelictWeight()
  return true
end

local ReconnectEvent = CreatureEvent("DungeonsReconnect")
function ReconnectEvent.onReconnect(player)
  player:getPartyInfo()
  player:refreshBalance()
  player:updateRelictWeight()
  local dungeon = player:getDungeon()
  if not dungeon then
    return true
  end

  local instance = dungeon:getPlayerInstance(player)
  if not instance then
    return true
  end

  local config = INSTANCE_MONSTER_MODIFIERS[instance:getKeyUID()]
  local attr = {}
	local level = 0
	local tier = 0
	if config then
		attr = config.attr or {}
		level = config.mlvl or 0
		tier = config.tier or 0
  end
	player:sendExtendedOpcode(
		ExtendedOPCodes.CODE_DUNGEONS,
		json.encode(
			{
				action = "start",
				data = {
          level = level,
          tier = tier,
          dType = dungeon:getCompleteType(),
					boss = dungeon:getBoss(),
					left = instance:getMonstersTotalCount(),
					duration = dungeon:getDuration() - ((os.time() - config.started) * 1000),
					objectives = dungeon:getBonusObjectives(),
					title = dungeon:getTitle(),
					lives = instance:getLives(),
					attr = attr,
				}
			}
		)
	)

  local total = instance:getMonstersTotalCount()
  local required = math.floor((total * (dungeon:getKillPercent() / 100)) + 0.5)
  local left = instance:getMonstersCount()
  local percent = left > 0 and 100 - math.floor((((required - (total - left)) / required) * 100) + 0.5) or 100
  player:sendExtendedOpcode(ExtendedOPCodes.CODE_DUNGEONS, json.encode({action = "killed", data = {percent = percent, left = left}}))
  return true
end

local LogoutEvent = CreatureEvent("DungeonsLogout")

function LogoutEvent.onLogout(player)
  local dungeon = player:getDungeon()
  if dungeon then
    if player:inQueue() then
      dungeon:getQueue():onPlayerLeave(player)
    else
      dungeon:onPlayerLeave(player)
      player:teleportTo(player:getTown():getTemplePosition())
    end
  end
  return true
end

local DeathEvent = CreatureEvent("DungeonsDeath")

function DeathEvent.onDeath(player, corpse, killer, mostDamageKiller, unjustified, mostDamageUnjustified)
  local dungeon = player:getDungeon()
  if dungeon then
    if player:inQueue() then
      dungeon:getQueue():onPlayerLeave(player)
    else
      dungeon:onPlayerLeave(player)
    end
  end
  return true
end

local ExtendedEvent = CreatureEvent("DungeonsExtended")

function ExtendedEvent.onExtendedOpcode(player, opcode, buffer)
  if opcode == ExtendedOPCodes.CODE_DUNGEONS then
    local status, json_data =
      pcall(
      function()
        return json.decode(buffer)
      end
    )
    if not status then
      return false
    end

    local action = json_data.action
    local data = json_data.data

    if action == "q" then
      player:onJoinQueue(data)
    elseif action == "r" then
      player:startRandomDungeon()
    elseif action == "addKey" then
      local uid = data
      local item = player:getItem(uid)
      if not item then
        player:sendTooltipMessage("Something went wrong, please try again.")
        return false
      end

      local dataToSend = getItemTooltipData(item, false, player)
      player:sendExtendedOpcode(ExtendedOPCodes.CODE_DUNGEONS, json.encode({action = "addKey", data = dataToSend}))
    end
  end
  return true
end

INSTANCE_MONSTER_MODIFIERS = {}

DUNGEON_KEYS = { -- FOR ORB TO TRANSFROM ITEM
  37929, 37926, 37928, 37927, 2091, 2090
}

local poolTierToPool = {
  91, 71, 21, 0
}

local randomKeysPool = {
  {37929, 37926, 37928, 37927, 2091, 2090, 38227, 38230, 38238, 38730, 38729, 38734},
  {37929, 37926, 37928, 37927, 2091, 2090, 38227, 38230, 38238},
  {37929, 37926, 37928, 37927, 2091, 2090},
  {37929, 37926, 37928, 37927}
}

keysToDungeon = {
  [37926] = "Flame Cave",
  [37929] = "Queen Lair",
  [37928] = "Swamp Pit",
  [37927] = "Undead Cave",
  [2091] = "Celestial Ascent",
  [2090] = "Glacier Pass",
  [2086] = "Pyramid Ruins",
  [2087] = "Golden Horizon",
  [2088] = "Ice Castle",
  [2089] = "Amethyst Peaks",
  [2092] = "Infernal Tar",
  [22605] = "Venom Grave",
  [22606] = "Bonebound Arena",
  [22604] = "Voidflare Arena",
  [22607] = "Reaper Castle",
  [38227] = "Underwater",
  [38238] = "Void Castle",
  [38230] = "Infernal Bridge",
  [38730] = "Lost Sanctum",
  [38729] = "Inferno Depths",
  [38734] = "Venom Caves",
  [38724] = "Soulbound Bridge",
  [38725] = "Gravebound Bridge",
  [38726] = "Liberator Bridge",
  [38728] = "Eldritch Bridge",
  [38727] = "Golden Vault"
}

function Player:onForceJoinQueue(dungeonName)
  local party = self:getParty()
  if isKeyTier and party then
    local members = party:getMembers()
    for _, member in ipairs(members) do
      if member:getStorageValue(PlayerStorage.endGame) < 0 then
        self:sendTooltipMessage(member:getName() .. " need to defeat Voort.")
        return false
      end
    end
  end

  if not dungeonName then
    self:sendTooltipMessage("This item is not valid dungeon key.")
    return false
  end

  local dungeons = Game.getDungeons()
  local dungeon
  for _, d in ipairs(dungeons) do
    if d:getTitle() == dungeonName then
      dungeon = d
      break
    end
  end

  if not dungeon then
    self:sendTooltipMessage("Dungeon not found.")
    return false
  end

  local reqParty = dungeon:getRequiredParty()
  if reqParty.max >= 2 and party then
    if party then
      if party:getLeader():getId() == self:getId() then
        if self:inQueue() then
          local playerDung = self:getDungeon()
          playerDung:getQueue():onPlayerLeave(self)
        else
          if dungeon:joinQueue(self, uid) then
            party:getLeader():sendExtendedOpcode(ExtendedOPCodes.CODE_DUNGEONS, json.encode({action = "queue", data = {joined = true, id = dungeon:getId()}}))
            local members = party:getMembers()
            for _, member in ipairs(members) do
              member:sendExtendedOpcode(ExtendedOPCodes.CODE_DUNGEONS, json.encode({action = "queue", data = {joined = true, id = dungeon:getId()}}))
            end
          end
        end
      else
        self:sendTooltipMessage("You need to be party leader to join queue.")
        return
      end
    end
  else
    if self:inQueue() then
      local playerDung = self:getDungeon()
      playerDung:getQueue():onPlayerLeave(self)
    else
      if dungeon:joinQueue(self, uid) then
        self:sendExtendedOpcode(ExtendedOPCodes.CODE_DUNGEONS, json.encode({action = "queue", data = {joined = true, id = dungeon:getId()}}))
      end
    end
  end
end

function Player:startRandomDungeon()
  local party = self:getParty()
  local partyCount = 0
  local tierBonusTotal = 0
  if self:getStorageValue(PlayerStorage.endGame) < 0 then
    self:sendTooltipMessage(self:getName() .. " need to defeat Voort.")
    return false
  end

  if isKeyTier and party then
    local members = party:getMembers()
    for _, member in ipairs(members) do
      if member:getDungeon() then
        self:sendTooltipMessage(member:getName() .. " is already in dungeon.")
        return false
      end
      if member:getStorageValue(PlayerStorage.endGame) < 0 then
        self:sendTooltipMessage(member:getName() .. " need to defeat Voort.")
        return false
      end
    end
  end

  if self:getDungeon() then
    self:sendTooltipMessage("You are already in dungeon.")
    return false
  end

  local playerDungeonTier = self:getDungeonTier()
  local dungeonKeysPool = randomKeysPool[0]
  local dungeonModifiers = {}

  for index, tier in ipairs(poolTierToPool) do
    if playerDungeonTier >= tier then
      dungeonKeysPool = randomKeysPool[index]
      break
    end
  end

  local randomKeyId = dungeonKeysPool[math.random(1, #dungeonKeysPool)]
  local dungeonName = keysToDungeon[randomKeyId]

  local dungeons = Game.getDungeons()
  local dungeon
  for _, d in ipairs(dungeons) do
    if d:getTitle() == dungeonName then
      dungeon = d
      break
    end
  end

  local uid = self:getId()
  INSTANCE_MONSTER_MODIFIERS[uid] = {}
  if not dungeon then
    self:sendTooltipMessage("Dungeon not found.")
    INSTANCE_MONSTER_MODIFIERS[uid] = nil
    return false
  end

  playerDungeonTier = playerDungeonTier - 1
  if playerDungeonTier <= 0 then playerDungeonTier = 1 end
  local cost = 10000 * playerDungeonTier
  if not self:removeTotalMoney(cost, true) then
    self:sendTooltipMessage("You don't have enough gold to start random dungeon. \nCost: " .. cost .. " gold.")
    INSTANCE_MONSTER_MODIFIERS[uid] = nil
    return false
  end

  local itemLevel = getMonsterLevelByKeyTier(playerDungeonTier)
  if party then
    partyCount = party:getMemberCount()
  end

  local attrIds = {}
  local slots = math.random(1, 6)
  local specialModifiers = {12, 13, 14, 15}
  local specialUsed = false
  for i = 1, slots do
    local attrId = math.random(1, #US_DUNGEONS_MODIFIERS)
    local attr = US_DUNGEONS_MODIFIERS[attrId]
    while isInArray(attrIds, attrId) or attr.minLevel and itemLevel < attr.minLevel or (isInArray(specialModifiers, attrId) and specialUsed) or
    attr.chance and math.random(100) >= attr.chance do
      attrId = math.random(1, #US_DUNGEONS_MODIFIERS)
      attr = US_DUNGEONS_MODIFIERS[attrId]
    end
    if isInArray(specialModifiers, attrId) then
      specialUsed = true
    end
    table.insert(attrIds, attrId)

    local tierAttributeRandom = 1
    for i = 1, #TIER_AFFIXES do
      if itemLevel >= TIER_AFFIXES[i][3] then
        local rand = math.random(100000)
        if rand <= TIER_AFFIXES[i][1] then
          tierAttributeRandom = math.random(1, TIER_AFFIXES[i][2])
          break
        end
      end
    end

    if itemLevel >= EXALTED_ITEMS[1] and math.random(100) <= EXALTED_ITEMS[2] then
      if math.random(100) <= EXALTED_ITEMS[3] then
        tierAttributeRandom = 7
      else
        tierAttributeRandom = 6
      end
    end

    local value = {1, 1}
    local finalValue = 1
    if not attr.noValue then
      value = attr.TIER[tierAttributeRandom]
      finalValue = math.random(value[1], value[2])
    end
    table.insert(dungeonModifiers, {attrId, finalValue, tierAttributeRandom, i})

    tierBonusTotal = tierBonusTotal + (attr.bonus * tierAttributeRandom)
    INSTANCE_MONSTER_MODIFIERS[uid][attrId] = finalValue
  end

  tierBonusTotal = tierBonusTotal + (tierBonusTotal * itemLevel / 100)
  INSTANCE_MONSTER_MODIFIERS[uid].mlvl = itemLevel
  INSTANCE_MONSTER_MODIFIERS[uid].bonus = 0
  INSTANCE_MONSTER_MODIFIERS[uid].partyBonus = partyCount
  INSTANCE_MONSTER_MODIFIERS[uid].attr = dungeonModifiers
  INSTANCE_MONSTER_MODIFIERS[uid].players = 1
  INSTANCE_MONSTER_MODIFIERS[uid].tier = playerDungeonTier
  local reqParty = dungeon:getRequiredParty()
  if reqParty.max >= 2 and party then
    if party then
      if party:getLeader():getId() == self:getId() then
        INSTANCE_MONSTER_MODIFIERS[uid].players = party:getMemberCount()
        if self:inQueue() then
          local playerDung = self:getDungeon()
          playerDung:getQueue():onPlayerLeave(self)
        else
          if dungeon:joinQueue(self, uid) then
            party:getLeader():sendExtendedOpcode(ExtendedOPCodes.CODE_DUNGEONS, json.encode({action = "queue", data = {joined = true, id = dungeon:getId()}}))
            local members = party:getMembers()
            for _, member in ipairs(members) do
              member:sendExtendedOpcode(ExtendedOPCodes.CODE_DUNGEONS, json.encode({action = "queue", data = {joined = true, id = dungeon:getId()}}))
            end
            return true
          end
        end
      else
        self:sendTooltipMessage("You need to be party leader to join queue.")
        INSTANCE_MONSTER_MODIFIERS[uid] = nil
        self:setBankBalance(self:getBankBalance() + cost)
        return
      end
    end
  else
    if self:inQueue() then
      local playerDung = self:getDungeon()
      playerDung:getQueue():onPlayerLeave(self)
    else
      if dungeon:joinQueue(self, uid) then
        self:sendExtendedOpcode(ExtendedOPCodes.CODE_DUNGEONS, json.encode({action = "queue", data = {joined = true, id = dungeon:getId()}}))
        return true
      end
    end
  end
end

function Player:onJoinQueue(uid)
  local item = self:getItem(uid)
  if not item then
    self:sendTooltipMessage("Something went wrong, please try again.")
    return false
  end

  local isKeyTier = item:getCustomAttribute("keytier") and item:getCustomAttribute("keytier") > 0
  if isKeyTier then
    if self:getStorageValue(PlayerStorage.endGame) < 0 then
      self:sendTooltipMessage("You need to defeat Voort.")
      return false
    end
  end

  local party = self:getParty()
  local partyCount = 0
  if isKeyTier and party then
    local members = party:getMembers()
    for _, member in ipairs(members) do
      if member:getStorageValue(PlayerStorage.endGame) < 0 then
        self:sendTooltipMessage(member:getName() .. " need to defeat Voort.")
        return false
      end
    end
  end

  local dungeonName = keysToDungeon[item:getId()]
  if not dungeonName then
    self:sendTooltipMessage("This item is not valid dungeon key.")
    return false
  end

  INSTANCE_MONSTER_MODIFIERS[uid] = {}
  local dungeonModifiers = item:getDungeonModifiers()
  local tierBonusTotal = 0
  local keyTier = item:getCustomAttribute("keytier") or 1
  local itemLevel = item:getItemLevel()
  -- Sprawdź, czy id itema zgadza się z którymś z fragmentów i ustaw itemLevel
  local specialKey = false
  for _, frag in ipairs(BOSS_FRAGMENTS_SPECIAL) do
    if frag.reward == item:getId() and frag.fragmentSetitemLevel then
      itemLevel = itemLevel
      specialKey = true
      break
    elseif frag.reward == item:getId() and frag.itemLevel then
        itemLevel = frag.itemLevel
        specialKey = true
        break
    end
  end

  if specialKey then
    itemLevel = itemLevel
  elseif keyTier then
    itemLevel = getMonsterLevelByKeyTier(keyTier)
  end
  if colleftInfo[self:getId()].attributesItems[276] then -- Dungeon Rat
    itemLevel = itemLevel + colleftInfo[self:getId()].attributesItems[276].value
  end


  if dungeonModifiers and #dungeonModifiers > 0 then
    for i = 1, #dungeonModifiers do
      local attrId = dungeonModifiers[i][1]
      local value = dungeonModifiers[i][2]
      local tier = dungeonModifiers[i][3]
      local attr = US_DUNGEONS_MODIFIERS[attrId]
      if attr then
        tierBonusTotal = tierBonusTotal + (attr.bonus * tier)
        INSTANCE_MONSTER_MODIFIERS[uid][attrId] = value
      end
      if attrId == 12 and not self:isQuestAlreadyActive(22) then
        self:startQuest(22)
      end
      if attrId == 13 and not self:isQuestAlreadyActive(23) then
        self:startQuest(23)
      end
      if attrId == 14 and not self:isQuestAlreadyActive(24) then
        self:startQuest(24)
      end
      if attrId == 15 and not self:isQuestAlreadyActive(25) then
        self:startQuest(25)
      end
    end
  end
  if party then
    partyCount = party:getMemberCount()
  end
  tierBonusTotal = tierBonusTotal + (tierBonusTotal * itemLevel / 100)
  INSTANCE_MONSTER_MODIFIERS[uid].mlvl = itemLevel
  INSTANCE_MONSTER_MODIFIERS[uid].bonus = tierBonusTotal
  INSTANCE_MONSTER_MODIFIERS[uid].partyBonus = partyCount
  INSTANCE_MONSTER_MODIFIERS[uid].item = item:clone()
  INSTANCE_MONSTER_MODIFIERS[uid].attr = dungeonModifiers
  INSTANCE_MONSTER_MODIFIERS[uid].players = 1
  INSTANCE_MONSTER_MODIFIERS[uid].tier = keyTier
  if not soloDungeons[dungeonName] and keyTier >= 121 then
    local randomChance = 5
    local voidRelict = self:getBossRelict()
    if voidRelict then
      voidRelict = 2
      randomChance = 10
    end

    if party and not voidRelict then
      local members = party:getMembers()
      for _, member in ipairs(members) do
        local memberRelict = member:getBossRelict()
        if memberRelict then
          voidRelict = 2
          randomChance = 10
          break
        end
      end
    end
    local roll = math.random(1, 100)
    if roll <= randomChance then
      INSTANCE_MONSTER_MODIFIERS[uid].void = true
    end
  end

  local dungeons = Game.getDungeons()
  local dungeon
  for _, d in ipairs(dungeons) do
    if d:getTitle() == dungeonName then
      dungeon = d
      break
    end
  end

  if not dungeon then
    self:sendTooltipMessage("Dungeon not found.")
    INSTANCE_MONSTER_MODIFIERS[uid].item:remove()
    INSTANCE_MONSTER_MODIFIERS[uid] = nil
    return false
  end

  local reqParty = dungeon:getRequiredParty()
  if reqParty.max >= 2 and party then
    if party then
      if party:getLeader():getId() == self:getId() then
        INSTANCE_MONSTER_MODIFIERS[uid].players = party:getMemberCount()
        if self:inQueue() then
          local playerDung = self:getDungeon()
          playerDung:getQueue():onPlayerLeave(self)
        else
          if dungeon:joinQueue(self, uid) then
            party:getLeader():sendExtendedOpcode(ExtendedOPCodes.CODE_DUNGEONS, json.encode({action = "queue", data = {joined = true, id = dungeon:getId()}}))
            local members = party:getMembers()
            for _, member in ipairs(members) do
              member:sendExtendedOpcode(ExtendedOPCodes.CODE_DUNGEONS, json.encode({action = "queue", data = {joined = true, id = dungeon:getId()}}))
            end
            item:remove()
            return true
          end
        end
      else
        self:sendTooltipMessage("You need to be party leader to join queue.")
        INSTANCE_MONSTER_MODIFIERS[uid].item:remove()
        INSTANCE_MONSTER_MODIFIERS[uid] = nil
        return
      end
    end
  else
    if self:inQueue() then
      local playerDung = self:getDungeon()
      playerDung:getQueue():onPlayerLeave(self)
    else
      if dungeon:joinQueue(self, uid) then
        self:sendExtendedOpcode(ExtendedOPCodes.CODE_DUNGEONS, json.encode({action = "queue", data = {joined = true, id = dungeon:getId()}}))
        item:remove()
        return true
      end
    end
  end
end

function Player:inQueue()
  local dungeon = self:getDungeon()
  if dungeon then
    if dungeon:getQueue():getPlayerPosition(self) ~= -1 then
      return true
    end
  end
  return false
end

function Player:removeBonusObjective(id)
  self:sendExtendedOpcode(ExtendedOPCodes.CODE_DUNGEONS, json.encode({action = "objective", data = {id = id}}))
end

function Player:finishBonusObjective(id)
  self:sendExtendedOpcode(ExtendedOPCodes.CODE_DUNGEONS, json.encode({action = "objective", data = {id = id, finished = true}}))
end

function DungeonInstance:removeBonusObjective(id)
  local runners = self:getRunners()
  for _, runner in ipairs(runners) do
    runner:removeBonusObjective(id)
  end
end

function DungeonInstance:finishBonusObjective(id)
  self:completeObjective(id)
  local runners = self:getRunners()
  for _, runner in ipairs(runners) do
    runner:finishBonusObjective(id)
  end

  local dungeon = self:getDungeon()
  if dungeon and dungeon:getCompleteType() == DUNGEONTYPE_OBJECTIVES then
    if self:areAllObjectivesComplete() and not self:isBossSpawned() then
      spawnDungeonBoss(dungeon, self)
    end
  end
end

function onDungeonPartyJoin(party, player)
  local leader = party:getLeader()
  if leader:inQueue() and player:inQueue() then
    do
      local dungeon = player:getDungeon()
      if dungeon then
        dungeon:getQueue():onPlayerLeave(player)
        player:sendExtendedOpcode(ExtendedOPCodes.CODE_DUNGEONS, json.encode({action = "queue", data = {joined = false}}))
      end
    end
    do
      local dungeon = leader:getDungeon()
      if dungeon then
        leader:popupFYI("Someone joined party when in queue. Your party is now removed from queue.")
        dungeon:getQueue():onPlayerLeave(leader)
        leader:sendExtendedOpcode(ExtendedOPCodes.CODE_DUNGEONS, json.encode({action = "queue", data = {joined = false}}))
        local members = party:getMembers()
        for _, member in ipairs(members) do
          member:setDungeon(nil)
          member:sendExtendedOpcode(ExtendedOPCodes.CODE_DUNGEONS, json.encode({action = "queue", data = {joined = false}}))
        end
      end
    end
    return
  end

  local dungeon = leader:getDungeon()
  if dungeon then
    local instance = dungeon:getPlayerInstance(leader)
    if instance then
      return
    end
    if not dungeon:canJoin(player, true) then
      leader:popupFYI(string.format("New member %s doesn't meet dungeon requirements. Your party is now removed from queue.", player:getName()))
      dungeon:getQueue():onPlayerLeave(leader)
      local members = party:getMembers()
      for _, member in ipairs(members) do
        member:setDungeon(nil)
      end
      return
    else
      player:popupFYI(
        string.format("You have joined party in queue for %s. Position in queue: %d", dungeon:getTitle(), dungeon:getQueue():getPlayerPosition(leader))
      )
    end
  end
end

function onDungeonPartyLeave(party, player)
  local leader = party:getLeader()
  local dungeon = leader:getDungeon()
  if leader:inQueue() then
    leader:popupFYI("Someone left party, you are removed from queue.")
    dungeon:getQueue():onPlayerLeave(leader)
    leader:sendExtendedOpcode(ExtendedOPCodes.CODE_DUNGEONS, json.encode({action = "stopQueue"}))
    local members = party:getMembers()
    for _, member in ipairs(members) do
      member:popupFYI("Someone left party, you are removed from queue.")
      member:setDungeon(nil)
      member:sendExtendedOpcode(ExtendedOPCodes.CODE_DUNGEONS, json.encode({action = "stopQueue"}))
    end
  end
end

function onDungeonPartyDisband(party)
  local leader = party:getLeader()
  local dungeon = leader:getDungeon()
  if leader:inQueue() then
    leader:popupFYI("Party was disbanded and removed from queue.")
    dungeon:getQueue():onPlayerLeave(leader)
    leader:sendExtendedOpcode(ExtendedOPCodes.CODE_DUNGEONS, json.encode({action = "stopQueue"}))
    local members = party:getMembers()
    for _, member in ipairs(members) do
      member:popupFYI("Party was disbanded and removed from queue.")
      member:setDungeon(nil)
      member:sendExtendedOpcode(ExtendedOPCodes.CODE_DUNGEONS, json.encode({action = "stopQueue"}))
    end
  end
end

function onDungeonPartyLeaderPass(party, oldLeader, newLeader)
  local dungeon = oldLeader:getDungeon()
  if dungeon then
    local instance = dungeon:getPlayerInstance(oldLeader)
    if instance then
      return
    end
    dungeon:getQueue():switchPlayer(oldLeader, newLeader)
  end
end

function Player:getItemLevel()
  local iLvl = 0
  for slot = CONST_SLOT_HEAD, CONST_SLOT_RING2 do
    local item = self:getSlotItem(slot)
    if item then
      local itemType = item:getType()
      if itemType:usesSlot(slot) then
        iLvl = iLvl + item:getItemLevel()
      end
    end
  end
  return iLvl
end

local BossDeathEvent = CreatureEvent("DungeonBossDeath")
local MonsterDeathEvent = CreatureEvent("DungeonMonsterDeath")

function BossDeathEvent.onDeath(target, corpse, killer, mostDamageKiller, unjustified, mostDamageUnjustified)
  if killer:isPlayer() then
    local dungeon = killer:getDungeon()
    if dungeon then
      local instance = dungeon:getPlayerInstance(killer)
      if instance then
        dungeon:onBossKill(instance)
        local runners = instance:getRunners()
        for _, runner in ipairs(runners) do
          runner:sendExtendedOpcode(ExtendedOPCodes.CODE_DUNGEONS, json.encode({action = "killed", data = {boss = true}}))
        end
      end
    end
  end
  return true
end
local mods_attributes = {
	[3] = PlayerStorage.monsterModifier_damage,
	[5] = PlayerStorage.monsterModifier_physicalProtection,
	[6] = PlayerStorage.monsterModifier_elementalProtection,
  [7] = PlayerStorage.monsterModifier_dualityProtection,
  [8] = PlayerStorage.monsterModifier_spell_avoid,
	[9] = PlayerStorage.monsterModifier_dodge,
	[10] = PlayerStorage.monsterModifier_ailments,
	[11] = PlayerStorage.monsterModifier_movements,
	[22] = PlayerStorage.monsterModifier_damage_elemental,
	[23] = PlayerStorage.monsterModifier_damage_physical,
}

function spawnDungeonBoss(dungeon, instance)
  instance:spawnBoss()
  local partyMebmers = dungeon:getPlayersCount()
  local boss = instance:getBoss()
  if boss then
    boss:registerEvent("SpellHealthChangeEvent")
    boss:registerEvent("UpgradeSystemHealth")
    boss:registerEvent("UpgradeSystemMana")
    boss:registerEvent("UpgradeSystemKill")
    boss:registerEvent("EliteAffixHP")
    boss:registerEvent("EliteAffixMANA")
    boss:registerEvent("UpgradeSystemDeath")
    boss:registerEvent("TaskDeath")
    boss:registerEvent("DungeonBossTP")
    local config = INSTANCE_MONSTER_MODIFIERS[instance:getKeyUID()]
    if config then
      local monsterLevel = config.mlvl+5
      if config.tier >= 1 then
        boss:setStorageValue(PlayerStorage.keyTier, config.tier)
        if config.void then
          boss:setStorageValue(MonsterStorages.voidRelict, 1)
          monsterLevel = monsterLevel + math.floor(monsterLevel * 0.1)
        end
      end
      local hpMulti = (config[1] and config[1] or 0) + (config[2] and config[2] or 0)
      hpMulti = hpMulti + (config.players - 1) * 50
      boss:setMonsterLevel(monsterLevel)
      local monsterHP = (healthFormula(monsterLevel) * 15) -- boss:getMaxHealth() + (healthFormula(config.mlvl+5) * 15)
      monsterHP = monsterHP + (monsterHP * hpMulti / 100)
      monsterHP = math.ceil(monsterHP * partyMebmers)
      if dungeon:getTitle() == "Soulbound Bridge" or dungeon:getTitle() == "Gravebound Bridge" or dungeon:getTitle() == "Liberator Bridge" or dungeon:getTitle() == "Eldritch Bridge" then
        monsterHP = monsterHP * 2.5
      end
      if boss:getName() == "Voidflare Wisp" then
        monsterHP = 500 * 1000000000
      elseif boss:getName() == "Reaper Shade" then
        monsterHP = 800 * 1000000000
      end
      boss:setMaxHealth(monsterHP)
      boss:setHealth(monsterHP)
      local damageMulti = (config[3] and config[3] or 0) + (config[4] and config[4] or 0)
      boss:setStorageValue(PlayerStorage.monsterModifier_damage, damageMulti)
      boss:setStorageValue(PlayerStorage.monsterModifier_bonus, config.bonus)
      boss:setStorageValue(PlayerStorage.monsterModifier_partyBonus, config.partyBonus)

      if config[18] then -- More Bosses
          local clone = Game.createMonster(boss:getName(), boss:getPosition())
          if clone then
            clone:setMaxHealth(monsterHP)
            clone:setHealth(monsterHP)
            clone:registerEvent("EliteAffixHP")
            instance:addMonster(clone)
            clone:setMonsterLevel(config.mlvl+5)
            clone:setStorageValue(PlayerStorage.monsterModifier_bonus, config.bonus)
            clone:setStorageValue(PlayerStorage.monsterModifier_partyBonus, config.partyBonus)
            clone:setStorageValue(PlayerStorage.bossClone, 1)
            for index, storageKey in pairs(mods_attributes) do
              local value = config[index] or 0
              if value > 0 then
                clone:setStorageValue(storageKey, value)
                if index == 11 then
                  local sped =  value
                  local Chilling = Condition(CONDITION_PARALYZE)
                  Chilling:setParameter(CONDITION_PARAM_TICKS, -1)
                  Chilling:setParameter(CONDITION_PARAM_SPEED, sped)
                  clone:addCondition(Chilling)
                end
              end
            end
            if config.tier >= 1 then
              clone:setStorageValue(PlayerStorage.keyTier, config.tier)
            end
          end
      end

      for index, storageKey in pairs(mods_attributes) do
        local value = config[index] or 0
        if value > 0 then
          boss:setStorageValue(storageKey, value)
          if index == 11 then
            local sped =  value
            local Chilling = Condition(CONDITION_PARALYZE)
            Chilling:setParameter(CONDITION_PARAM_TICKS, -1)
            Chilling:setParameter(CONDITION_PARAM_SPEED, sped)
            boss:addCondition(Chilling)
          end
        end
      end

    end
  end
end

function MonsterDeathEvent.onDeath(target, corpse, killer, mostDamageKiller, unjustified, mostDamageUnjustified)
  if killer then
    if killer:isPlayer() then
      local dungeon = killer:getDungeon()
      if dungeon then
        local instance = dungeon:getPlayerInstance(killer)
        if instance then
          local completeType = dungeon:getCompleteType()
          local left = instance:getMonstersCount() - 1
          instance:setMonstersCount(left)
          
          if completeType == DUNGEONTYPE_KILL_PERCENT then
            local total = instance:getMonstersTotalCount()
            local required = math.floor((total * (dungeon:getKillPercent() / 100)) + 0.5)
            local runners = instance:getRunners()
            local percent = left > 0 and 100 - math.floor((((required - (total - left)) / required) * 100) + 0.5) or 100
            if percent >= 100 and not instance:isBossSpawned() then
              spawnDungeonBoss(dungeon, instance)
            end
            for _, runner in ipairs(runners) do
              runner:sendExtendedOpcode(ExtendedOPCodes.CODE_DUNGEONS, json.encode({action = "killed", data = {percent = percent, left = left}}))
            end
          else
            local runners = instance:getRunners()
            for _, runner in ipairs(runners) do
              runner:sendExtendedOpcode(ExtendedOPCodes.CODE_DUNGEONS, json.encode({action = "killed", data = {left = left}}))
            end
          end
        end
      end
    end
  end
  return true
end

BossDeathEvent:type("death")
BossDeathEvent:register()
MonsterDeathEvent:type("death")
MonsterDeathEvent:register()
LoginEvent:type("login")
LoginEvent:register()
LogoutEvent:type("logout")
LogoutEvent:register()
ReconnectEvent:type("reconnect")
ReconnectEvent:register()
DeathEvent:type("death")
DeathEvent:register()
ExtendedEvent:type("extendedopcode")
ExtendedEvent:register()
