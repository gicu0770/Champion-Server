local DRAKEN_BOSS_POSITION = Position(702, 615, 10)
local ORCLOPS_BOSS_POSITION = Position(355, 799, 9)
local BURNING_BOSS_POSITION = Position(1333, 541, 7)
local FORGOTTEN_BOSS_POSITION = Position(1301, 529, 10)
local BROTHERHOOD_BOSS_POSITION = Position(592, 1996, 8)
local UNDEAD_BOSS_POSITION = Position(561, 1661, 11)
local ROYAL_BOSS_POSITION = Position(743, 1712, 6)
local RAGE_BOSS_POSITION = Position(277, 1936, 11)
local LIBRARIAN_BOSS_POSITION = Position(1668, 290, 10)

local tasksPerFetch = 10

local questStarted = 1510
local questStorage = 65000
local questStorageRest = 75000

local MONSTER_TASKS = {}

local LoginEvent = CreatureEvent("TasksLogin")
function LoginEvent.onLogin(player)
  player:registerEvent("TaskExtendedEvent")

  for i = 1, #GRIZZLY_TASKS do
    player:sendTaskUpdate(GRIZZLY_TASKS[i], i)
    if player:getStorageValue(questStarted + i) == 1 then
      player:sendTaskUpdate(GRIZZLY_TASKS[i], i, false, true)
    end
  end
  return true
end

function Player:startTask(id)
  local data = GRIZZLY_TASKS[id]
  if not data then
    return
  end
  self:setStorageValue(questStarted + id, 1)
  self:setStorageValue(questStorage + id, 0)
  self:sendTaskUpdate(data, id)
  self:sendTaskUpdate(data, id, false, true)
end

local ExtendedEvent = CreatureEvent("TaskExtendedEvent")
function ExtendedEvent.onExtendedOpcode(player, opcode, buffer)
  if opcode == ExtendedOPCodes.CODE_TASKS then
    local status, json_data =
      pcall(function()
        return json.decode(buffer)
      end)
    if not status then
      return false
    end

    if json_data.action == "accept" then
      player:acceptTask(json_data.id, json_data.name)
    elseif json_data.action == "cancel" then
      local data = GRIZZLY_TASKS[json_data.id]
      if not data or not data.raceName == json_data.name then
        return
      end
      local startedStorage = player:getStorageValue(questStarted + json_data.id)
      if startedStorage == 1 then
        player:setStorageValue(questStarted + json_data.id, 0)
        player:sendTaskUpdate(data, json_data.id, true)
      end
    elseif json_data.action == "finish" then
      player:finishTask(json_data.id, json_data.name)
    elseif json_data.action == "fetch" then
      player:sendTasksList()
    end
  end
end

function Player:acceptTask(id, name)
  local data = GRIZZLY_TASKS[id]
  if not data or not data.raceName == name then
    return
  end

  if self:getStorageValue(questStarted + id) < 1 then
    self:setStorageValue(questStarted + id, 1)
    self:sendTaskUpdate(data, id)
    self:sendTaskUpdate(data, id, false, true)
  end
end

function Player:openTasksList()
  self:sendExtendedOpcode(ExtendedOPCodes.CODE_TASKS, json.encode({action = "open"}))
end

function Player:closeTasksList()
  self:sendExtendedOpcode(ExtendedOPCodes.CODE_TASKS, json.encode({action = "close"}))
end

function Player:sendTasksList(last)
  if not last then
    last = 1
  end

  local available = {}
  for i = last, math.min(last + tasksPerFetch - 1, #GRIZZLY_TASKS) do
    local startedStorage = self:getStorageValue(questStarted + i)
    local killsStorage = self:getStorageValue(questStorage + i)
    local task = {
      id = GRIZZLY_TASKS[i].id,
      raceName = GRIZZLY_TASKS[i].raceName,
      killsRequired = GRIZZLY_TASKS[i].killsRequired,
      level = GRIZZLY_TASKS[i].level,
      active = startedStorage == 1 and killsStorage < GRIZZLY_TASKS[i].killsRequired,
      completed = killsStorage >= GRIZZLY_TASKS[i].killsRequired,
      finished = startedStorage == 2,
      kills = killsStorage,
      monsters = GRIZZLY_TASKS[i].monsters,
      outfits = GRIZZLY_TASKS[i].outfits,
      rewards = GRIZZLY_TASKS[i].rewardsTooltip,
      repeatable = GRIZZLY_TASKS[i].repeatable or false
    }
    table.insert(available, task)
  end

  self:sendExtendedOpcode(ExtendedOPCodes.CODE_TASKS, json.encode({action = "fetch", data = available}))
  last = last + tasksPerFetch
  if last <= #GRIZZLY_TASKS then
    self:sendTasksList(last)
  else
    self:sendExtendedOpcode(ExtendedOPCodes.CODE_TASKS, json.encode({action = "fetch_end"}))
    for i = 1, #GRIZZLY_TASKS do
      self:sendTaskUpdate(GRIZZLY_TASKS[i], i)
      if self:getStorageValue(questStarted + i) == 1 then
        self:sendTaskUpdate(GRIZZLY_TASKS[i], i, false, true)
      end
    end
  end
end

function Player:sendTaskUpdate(task, taskId, cancel, tracker)
  local startedStorage = self:getStorageValue(questStarted + taskId)
  local killsStorage = self:getStorageValue(questStorage + taskId)
  local killsRestStorage = self:getStorageValue(questStorageRest + taskId)
  if killsStorage < 0 then
    killsStorage = 0
    self:setStorageValue(questStorage + taskId, 0)
  end

  if killsRestStorage > 0 then 
    killsRestStorage = math.ceil(killsRestStorage/100 * 10) / 10
  else
    killsRestStorage = 0
  end

  local update = {
    id = taskId,
    active = startedStorage == 1 and killsStorage < task.killsRequired,
    completed = killsStorage >= task.killsRequired,
    finished = startedStorage == 2,
    kills = killsStorage + killsRestStorage,
    raceName = task.raceName,
    killsRequired = task.killsRequired,
  }
  if cancel then
    update.delete = true
  end

  local action = tracker and "tracker" or "update"
  self:sendExtendedOpcode(ExtendedOPCodes.CODE_TASKS, json.encode({action = action, data = update}))
end

function Player:finishTask(id, name)
  local data = GRIZZLY_TASKS[id]
  if not data or not data.raceName == name then
    return
  end

  if self:getStorageValue(questStarted + id) == 2 then
    return
  end

  local container = nil
  local inbox = self:getInbox()
  local isBackpack = false
  local backpack = self:getSlotItem(CONST_SLOT_BACKPACK)
  if backpack then
    if backpack and backpack:getEmptySlots(true) > 0 then
      container = backpack
      isBackpack = true
    end
  end

  if not container then
    container = self:getInbox()
    isBackpack = false
  end

  local lootItems = {}
  if self:getStorageValue(questStorage + id) >= data.killsRequired then
    for i = 1, #data.rewards do
      if isInArray({"boss", "teleport", 1}, data.rewards[i].type) then
        self:teleportTo(data.rewards[i].values)
      elseif isInArray({"exp", "experience", 2}, data.rewards[i].type) then
        local expReward = data.rewards[i].values
        self:addExperience(expReward, true)
      elseif isInArray({"item", 3}, data.rewards[i].type) then
        local rewardData = data.rewards[i].values  -- np. {37929, 1, 19}
        local rewardItem = nil
        if isBackpack then
          if backpack and backpack:getEmptySlots(true) <= 0 then
            isBackpack = false
            container = inbox
          end
        end
        local currencyStorage = self:getSlotItem(CONST_SLOT_STORE_INBOX):getItemById(38322)
        if currencyStorage then
          rewardItem = currencyStorage:addItem(rewardData[1], rewardData[2], INDEX_WHEREEVER, FLAG_NOLIMIT)
        else
          rewardItem = container:addItem(rewardData[1], rewardData[2], INDEX_WHEREEVER, FLAG_NOLIMIT)
        end
        if rewardItem then
          if rewardData[3] then
            rewardItem:setItemLevel(rewardData[3])
          --  print("Ustawiono monster level dla itemu " .. rewardData[1] .. " na " .. rewardData[3])
          end
          if rewardData[1] == 36664 then
            rewardItem:setTier(1)
            rewardItem:setRarity(6)
            rewardItem:setbindItem(self:getAccountId())
            local itemType = ItemType(rewardItem.itemid)
            local weaponType = itemType:getWeaponType()
            if not rewardItem:rollAttribute() then
              self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
            else
              self:getPosition():sendMagicEffect(12)
              self:sendExtendedOpcode(105, json.encode({reload = "reload"}))
            end
          end
        end
      elseif isInArray({"money", 4}, data.rewards[i].type) then
        self:setBankBalance(self:getBankBalance() + data.rewards[i].values)
        self:refreshBalance()
      elseif isInArray({"storage", "stor", 5}, data.rewards[i].type) then
        self:setStorageValue(data.rewards[i].values[1], data.rewards[i].values[2])
      elseif isInArray({"fragments", 6}, data.rewards[i].type) then
        for j = 1, data.rewards[i].count do
          if isBackpack then
            if backpack and backpack:getEmptySlots(true) <= 0 then
              isBackpack = false
              container = inbox
            end
          end
          randomFragments(self, container, 500)
        end
      elseif isInArray({"currency", 7}, data.rewards[i].type) then
        for j = 1, data.rewards[i].count do
          if isBackpack then
            if backpack and backpack:getEmptySlots(true) <= 0 then
              isBackpack = false
              container = inbox
            end
          end
          currencyDrop(self, container, 500)
          generateCurrency(self, container, 0, 0, 0, data.level, 0, 0, lootItems)
        end
      elseif isInArray({"spellrune", 8}, data.rewards[i].type) then
        for j = 1, data.rewards[i].count do
          if isBackpack then
            if backpack and backpack:getEmptySlots(true) <= 0 then
              isBackpack = false
              container = inbox
            end
          end
          generateRandomSpellItems(self, container, data.level, 0, lootItems, 0, 0, 0, 0, 1)
        end
      elseif isInArray({"supportrune", 9}, data.rewards[i].type) then
        for j = 1, data.rewards[i].count do
          if isBackpack then
            if backpack and backpack:getEmptySlots(true) <= 0 then
              isBackpack = false
              container = inbox
            end
          end
          generateRandomSupportItems(self, container, data.level, 0, lootItems, 0, 0, 0, 0, 1)
        end
      elseif isInArray({"potions", 10}, data.rewards[i].type) then
        for j = 1, data.rewards[i].count do
          if isBackpack then
            if backpack and backpack:getEmptySlots(true) <= 0 then
              isBackpack = false
              container = inbox
            end
          end
          generatePotions(self, container, 0, 0, 0, data.level, 0, 0, lootItems)
        end
      elseif isInArray({"questStart", "start", 11}, data.rewards[i].type) then
        self:startQuest(data.rewards[i].values)
      elseif isInArray({"questEnd", "end", 12}, data.rewards[i].type) then
        self:finishQuest(data.rewards[i].values)
      else
        print("[Warning - Npc::KillingInTheNameOf] Wrong reward type: " .. (data.rewards[i].type or "nil") .. ", reward could not be loaded.")
      end
    end

    if not data.repeatable then
      self:setStorageValue(questStarted + id, 2)
    else
      self:setStorageValue(questStarted + id, 0)
      self:setStorageValue(questStorage + id, 0)
    end

    self:sendTaskUpdate(data, id)
  end
end

local DeathMonster = CreatureEvent("TaskDeath")
function DeathMonster.onDeath(creature, corpse, killer, mostDamage, unjustified, mostDamage_unjustified)
  if not creature or creature:isPlayer() or creature:getMaster() then
    return true
  end
  if mostDamage and mostDamage:isPlayer() then
    local creatureName = creature:getName():lower()
    local task = nil
    if MONSTER_TASKS[creatureName] then
      task = MONSTER_TASKS[creatureName].tasks
    end

    if not task then
      return true
    end

    local party = mostDamage:getParty()
    if party and party:isSharedExperienceEnabled() then
      local members = party:getMembers()
      local memberCount = #members + 1
      for i = 1, #members do
        local member = members[i]
        if member then
          member:updateKillCount(task, creatureName, memberCount)
        end
      end

      local leader = party:getLeader()
      if leader then
        leader:updateKillCount(task, creatureName, memberCount)
      end
    else
      mostDamage:updateKillCount(task, creatureName)
    end
  end
  return true
end

function Player:updateKillCount(task, creatureName, memberCount)
  for i = 1, #task do 
    local kills = self:getStorageValue(questStorage + task[i].id)
    if kills < (task[i].killsRequired + 1) then
      if memberCount then
        local currentRestKills = self:getStorageValue(questStorageRest + task[i].id)
        currentRestKills = currentRestKills + (100 / memberCount)

        if currentRestKills >= 100 then
          currentRestKills = currentRestKills - 100
          kills = kills + 1
        end
        self:setStorageValue(questStorageRest + task[i].id, currentRestKills)
      else
        kills = kills + 1
      end
 
      self:setStorageValue(questStorage + task[i].id, kills)
      self:sendTaskUpdate(task[i], task[i].id, false, true)
    end
  end
end

function getOutfitForTasks()
  local monster = MonsterType("Wolf")
  if not monster then
    print("[TASKS] nie znaleziono monstera")
    addEvent(getOutfitForTasks, 1000)
    return
  end
  for i = 1, #GRIZZLY_TASKS do
    GRIZZLY_TASKS[i].outfits = {}
    GRIZZLY_TASKS[i].id = i
    for x = 1, #GRIZZLY_TASKS[i].monsters do
      local name = GRIZZLY_TASKS[i].monsters[x]
      name = name:gsub("(%l)(%w*)", function(a,b) return string.upper(a)..b end)
      local monster = MonsterType(name)
      if monster then
        local outfitM = monster:getOutfit()
        local outfit = {}
        if outfitM.lookType > 0 then
          outfit.type = outfitM.lookType
        end
        if outfitM.lookTypeEx > 0 then
          outfit.typeEx = outfitM.lookTypeEx
        end
        if outfitM.lookHead > 0 then
          outfit.head = outfitM.lookHead
        end
        if outfitM.lookBody > 0 then
          outfit.body = outfitM.lookBody
        end
        if outfitM.lookLegs > 0 then
          outfit.legs = outfitM.lookLegs
        end
        if outfitM.lookFeet > 0 then
          outfit.feet = outfitM.lookFeet
        end
        if outfitM.lookAddons > 0 then
          outfit.addons = outfitM.lookAddons
        end
        if outfitM.lookMount > 0 then
          outfit.mount = outfitM.lookMount
        end
        if outfitM.lookWings > 0 then
          outfit.wings = outfitM.lookWings
        end
        if outfitM.lookAura > 0 then
          outfit.aura = outfitM.lookAura
        end
        table.insert(GRIZZLY_TASKS[i].outfits, outfit)
      else
        print("[TASKS] Nie znaleziono monstera: " .. name)
      end
    end

    local rewards = {}
    local loot = {type = "item", values = {}}
    for k = 1, #GRIZZLY_TASKS[i].rewards do
      local reward = GRIZZLY_TASKS[i].rewards[k]
      if reward.type == "item" then
        local item = Game.createItem(reward.values[1], 1)
        if item then
          if reward.itemLevel then
            item:setItemLevel(reward.itemLevel)
          end
          item_data = {
            count = item:getCount(),
            sid = item:getId(),
            cid = item:getType():getClientId(),
            uid = item:getRealUID(),
            rarity = item:getColor() or item:getRarityId(),
          }
        end
        table.insert(loot.values, item_data)
        item:remove()
      else
        table.insert(rewards, reward)
      end
    end
    table.insert(rewards, loot)
    GRIZZLY_TASKS[i].rewardsTooltip = rewards

    for c = 1, #GRIZZLY_TASKS[i].monsters do
      if not MONSTER_TASKS[GRIZZLY_TASKS[i].monsters[c]] then
        MONSTER_TASKS[GRIZZLY_TASKS[i].monsters[c]] = {}
        MONSTER_TASKS[GRIZZLY_TASKS[i].monsters[c]].tasks = {}
      end
      local task = {
        id = GRIZZLY_TASKS[i].id,
        killsRequired = GRIZZLY_TASKS[i].killsRequired,
        raceName = GRIZZLY_TASKS[i].raceName,
      }
      table.insert(MONSTER_TASKS[GRIZZLY_TASKS[i].monsters[c]].tasks, task)
    end
  end
end
getOutfitForTasks()

DeathMonster:type("death")
DeathMonster:register()
LoginEvent:type("login")
LoginEvent:register()
ExtendedEvent:type("extendedopcode")
ExtendedEvent:register()
